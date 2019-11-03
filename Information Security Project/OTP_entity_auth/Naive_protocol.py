import random, numpy as np, scipy, math, sys, hashlib

def ow_hash(password):
    h = str(int(hashlib.sha256(str(password).encode('utf-8')).hexdigest(), 16) % 10**20)
    while (len(h)<L_MAX):
        h = '0' + h #leftside padding should maintain uniformity
    return h

#-------------------------------------CLIENT CLASS-------------------------------

class Client:
    def __init__(self,identity):
        self.ID = identity
        self.x = [] #will store the hashes
    def initiate_setup(self,server):
        p_A = input('Please enter a natural number of at most ' + str(L_MAX) + ' digits :')

        while((not isinstance(p_A, int) and  not isinstance(p_A, long)) or p_A >= 10**(L_MAX) or p_A < 0):
            p_A = input('Please enter a natural number of at most ' + str(L_MAX) + ' digits :')

        print('Input password :')
        print(p_A)
        #----------------------------------padding the password with zeros
        while (p_A < 10**(L_MAX-1) and p_A > 0):
            p_A = 10* p_A
        if (p_A == 0): p_A = '0'*(L_MAX) 
        p_A = str(p_A)
        print('Padded password :')
        print(p_A)
        #---------------------------hashing the padded password N times (and storing all values for simplicity)
        self.x = [] #reset the hashes
        self.x.append(ow_hash(p_A))
        for i in range(N-1):
            self.x.append(ow_hash(self.x[i]))
        server.setup(self.x[N-1],self.ID)
    
    def  request_challenge(self,server, identity):
            self.n, self.r_n = server.provide_challenge(identity) #send its identity and receive the challenge
    def  answer_challenge(self,server):   
            if (self.n > 0): #no errors occured
                server.verify(self.x[self.n-1], self.r_n) #sends back the hash corresponding to n and the received r_n

#-------------------------------------SERVER CLASS-------------------------------

class Server:
    def __init__(self):
        self.n =0 #will count the number of attempted authentications
        self.ID_reg = -1
    
    def setup(self,N_fold_hash,identity):
        if (self.ID_reg == -1 or self.ID_reg == identity):
            self.ID_reg = identity
            self.x_N = N_fold_hash
            self.c=0 # a new OTP entity auth. has started so n=0
            print 'N-Fold hashed password:', self.x_N , 'has been associated to identity:', self.ID_reg, '.'
        else :
            print('Setup faillure.')
    
    def provide_challenge(self, identity):
        print('Identity authentication request received.')
        if (self.ID_reg == identity and self.n < N):
            self.n = self.n + 1
            self.r_n = random.randrange(0,R)
            print('The challenge is [n, r_n] = [' + str(self.n) + ' , ' + str(self.r_n) + ']')
            return self.n , self.r_n
        else :
            if not self.ID_reg == identity : print('Identity not recognized')
            else : 
                if  not self.n < N : print('Max number of authentications reached for this password, please reinitiate setup.')
            return -1 , -1
    
    def verify(self,x,r):
        if(r == self.r_n):
            for i in range(N-self.n):
                x=ow_hash(x)
            if (x == self.x_N): print('Successful authentication as ' + str(self.ID_reg))
            else : print('Unsuccessful authentication.')
        else : print('Unsuccessful authentication.')

#-------------------------SIMULATION OF THE PROTOCOL--------------------------

#-----------------------------------------setting parameters
L_MAX = 20 # 20 digits are nearly equal to 64 bit
N = 1000 # not too large for n-fold hash computation time, but enough for a good number of runs before resetting the password
R= 2**256
#-----------------------------------------initialisation
A = Client('Pippo')
B = Server()
#-----------------------------------------simulation
A.initiate_setup(B)
for i in range(11):
    A.request_challenge(B,A.ID)
    A.answer_challenge(B)