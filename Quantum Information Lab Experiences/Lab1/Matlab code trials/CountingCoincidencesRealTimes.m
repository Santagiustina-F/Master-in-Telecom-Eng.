
%Counting coincidences
data(:,1)=data(:,1)-data(1,1); % time shifting so that t1=0
UnitTime = 80.955 * 10^(-12);
data(:,1)= UnitTime.*data(:,1);
Coincid = 0;
ind_max=0;
for k= 1:size(data,1);
    if data(k,1) < 5;
        ind_max=ind_max+1;
    end
end
      
for i=1:ind_max;
        if data(i,2) == 1;
                   f=0; %coincidence not found yet
                   d_min = max(1,i-5);
                   d_max = min(i+5,ind_max);
                   d=0; %distance
                   reached_right=0;
                   reached_left=0;
            while reached_right+reached_left<2 
                d=d+1;
                k=0;
                if i+d==ind_max %avoid index out of bounds
                    reached_right=1;
                end    
                if  reached_right==0 && data(i+d,2)==2; %look at the right
                    reached_right=1;
                    if abs(data(i,1)-data(i+d,1)) < 10*UnitTime;
                        Coincid = Coincid + 1;
                        f=1; 
                    end
                end
                if i-d==0; %avoid index out of bounds
                    reached_left=1;
                end
                if reached_left==0 ; %look at the left
                    if data(i-d,2)==2;
                    reached_left=1;
                        if f==0 && abs(data(i,1)-data(i-d,1)) < 10*UnitTime;
                            Coincid = Coincid + 1;
                            f=1 ;
                        end    
                    end
                end
            end
        end
end   
Coincid;
