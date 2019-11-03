clc;
clear;
coincidence_time_bins=zeros(16,1);
coincidences_list=zeros(16,1);
data_files = {'x0a0y0b0.txt','x0a0y0b1.txt','x0a0y1b0.txt','x0a0y1b1.txt','x0a1y0b0.txt','x0a1y0b1.txt','x0a1y1b0.txt','x0a1y1b1.txt','x1a0y0b0.txt','x1a0y0b1.txt','x1a0y1b0.txt','x1a0y1b1.txt','x1a1y0b0.txt','x1a1y0b1.txt','x1a1y1b0.txt','x1a1y1b1.txt'};
for n= 1:16
        importfile(char(data_files(n)));

%% -------Pre-processing :
data(:,1)=data(:,1)-data(1,1); % time shifting so that t1=0
UNIT_TIME = 80.955 * 10^(-12);  % unit of the time tags
data_sec= [UNIT_TIME.*data(:,1), data(:,2)]; %get the time of arrivals in seconds
%cutting out all data after 5 seconds of recording
ind_max=0;
for k= 1:size(data_sec,1);
    if data_sec(k,1) < 5;
        ind_max=ind_max+1;
    end
    clear k;
end
data_sec=data_sec(1:ind_max,1:2);

%% --------Finding the pairs (not necessarily coincidences) of arrivals (that is the
%closer arrival on channel 2 corrisponding to each arrival in channel 1)


n_pairs = 0; %counting pairs
diff=data_sec(:,1); %time differences between pairs(nonsense initial value that must be uptaded)
for i=1:ind_max;
    
        if data_sec(i,2) == 1; %that is for each click of channel one
                   d=0; %distance from element of ch1 in the list
                   reached_right=0; %!reached 1st time-tag of ch2 in the future
                   reached_left=0;  %!reached 1st time-tag of ch2 in the past
            while not(reached_right && reached_left) 
                d=d+1; %I increase distance of 1
                if i+d>ind_max ; 
                    reached_right=1;
                    n_pairs = n_pairs + 1;
                    diff(n_pairs)=10; % time out of domain, will be replaced
                end %avoid index out of bounds
                
                if  reached_right==0 && data_sec(i+d,2)==2; %1st ch2 time-tag in the future reached
                    reached_right=1;
                    if reached_left == 0;
                        n_pairs = n_pairs + 1;
                        diff(n_pairs)=data_sec(i,1)-data_sec(i+d,1); 
                    else 
                        if abs(data_sec(i,1)-data_sec(i+d,1))< abs(diff(n_pairs));
                            diff(n_pairs)=data_sec(i,1)-data_sec(i+d,1);
                        end
                    end
                end
                
                if i-d==0; 
                    reached_left=1;
                    n_pairs = n_pairs + 1;
                    diff(n_pairs)= 10; % time out of domain, will be replaced;
                end %avoid index out of bounds
                
                if reached_left==0 && data_sec(i-d,2)==2; %1st ch2 time-tag in the past reached
                   reached_left=1;
                   if reached_right == 0;
                        n_pairs = n_pairs + 1;
                        diff(n_pairs)=abs(data_sec(i,1)-data_sec(i-d,1)); 
                   else
                       if abs(data_sec(i,1)-data_sec(i-d,1))< abs(diff(n_pairs));
                        diff(n_pairs) = data_sec(i,1)-data_sec(i-d,1);
                       end
                   end
                   
                end
            end %end of while : the matching ch2 tag has been found for this ch1 tag
        end  
end   %end of for : for each ch1 tag we have the time difference to the closer ch2 tag
diff=diff(1:n_pairs);
clear i d;


%% ------------Histogram of time differences between pairs of channel 1 and 2 clicks
%I filter out all time-differences above 2*10.*(-9) as I expect that the photons generated together
%arrive within this time interval

diff_filt = diff; 
count = 0;
 for j= 1:n_pairs;
     if abs(diff(j))< 2*10.^(-9);
         count= count+1;
         diff_filt(count)=diff(j);
     end
 end
 clear j;
 diff_filt = diff_filt(1:count);
 hist(diff_filt,sqrt(count));
 title 'Histogram of time differences between arrival at ch1 and ch2' ;
 xlabel 'seconds'
 ylabel 'number of pairs'
 figure(gcf)

%I obtain from this Gaussian distribution a more precise interval of
%confidence to be used as coincidence time-bin

coincidence_time = 2*sqrt(var(diff_filt));

%% -------------Counting coincidences
coincidences=0;
if coincidence_time < 2*10.^(-9)
    for i=1:count
        if abs(diff_filt(i)-mean(diff_filt))<coincidence_time
            coincidences = coincidences+1;
        end
    end
else
    for i=1:n_pairs
        if abs(diff(i))<coincidence_time
            coincidences = coincidences+1;
        end
    end
end
coincidence_time_bins(n)=coincidence_time;
coincidences_list(n)= coincidences;
clearvars -except coincidences_list data_files
end
%% --------------Computing correlations and CHSH inequality
coincidences_matrix=[coincidences_list(1:4),coincidences_list(5:8),coincidences_list(9:12),coincidences_list(13:16)];

blockA=coincidences_matrix(1:2,1:2);
blockB=coincidences_matrix(1:2,3:4);
blockC=coincidences_matrix(3:4,1:2);
blockD=coincidences_matrix(3:4,3:4);

%Probabilities
probA=blockA.*1/sum(sum(blockA));
probB=blockB.*1/sum(sum(blockB));
probC=blockC.*1/sum(sum(blockC));
probD=blockD.*1/sum(sum(blockD));

%Correlations
corrA=probA(1,1)+probA(2,2)-probA(1,2)-probA(2,1);
corrB=probB(1,1)+probB(2,2)-probB(1,2)-probB(2,1);
corrC=probC(1,1)+probC(2,2)-probC(1,2)-probC(2,1);
corrD=probD(1,1)+probD(2,2)-probD(1,2)-probD(2,1);

S=corrA-corrB+corrC+corrD;

%% Error propagation
%Considering each coincidences count as a poisson process we have a
%standard deviation equal to the square root of the mean :
%sigma_i=sqrt(coincidences_list(i))=sqrt(Ni)

err_blockA=zeros(2,2);
err_blockA(1,1) = (1-corrA)/(sum(sum(blockA)));
err_blockA(2,2) = (1-corrA)/(sum(sum(blockA)));
err_blockA(1,2)= (1+corrA)/(sum(sum(blockA))) - (2*blockA(1,2)/((sum(sum(blockA)))^2));
err_blockA(2,1)= (1+corrA)/(sum(sum(blockA))) - (2*blockA(2,1)/((sum(sum(blockA)))^2));
err_blockA = blockA .* err_blockA.^2; 


err_blockB=zeros(2,2);
err_blockB(1,1) = (1-corrB)/(sum(sum(blockB)));
err_blockB(2,2) = (1-corrB)/(sum(sum(blockB)));
err_blockB(1,2)= (1+corrB)/(sum(sum(blockB))) - (2*blockB(1,2)/((sum(sum(blockB)))^2));
err_blockB(2,1)= (1+corrB)/(sum(sum(blockB))) - (2*blockB(2,1)/((sum(sum(blockB)))^2));
err_blockB = blockB .* err_blockB.^2 ;

err_blockC=zeros(2,2);
err_blockC(1,1) = (1-corrC)/(sum(sum(blockC)));
err_blockC(2,2) = (1-corrC)/(sum(sum(blockC)));
err_blockC(1,2)= (1+corrC)/(sum(sum(blockC))) - (2*blockC(1,2)/((sum(sum(blockC)))^2));
err_blockC(2,1)= (1+corrC)/(sum(sum(blockC))) - (2*blockC(2,1)/((sum(sum(blockC)))^2));
err_blockC = blockC .* err_blockC.^2  ;

err_blockD=zeros(2,2);
err_blockD(1,1) = (1-corrD)/(sum(sum(blockD)));
err_blockD(2,2) = (1-corrD)/(sum(sum(blockD)));
err_blockD(1,2)= (1+corrD)/(sum(sum(blockD))) - (2*blockD(1,2)/((sum(sum(blockD)))^2));
err_blockD(2,1)= (1+corrD)/(sum(sum(blockD))) - (2*blockD(2,1)/((sum(sum(blockD)))^2));
err_blockD = blockD .* err_blockD.^2 ;

sigma_S= sqrt(sum(sum(err_blockA))+ sum(sum(err_blockB))+sum(sum(err_blockC))+sum(sum(err_blockD)));

if S-sigma_S>2
    disp(['S = ', num2str(S),'  > 2 and sigma_S = ', num2str(sigma_S), ' so the Bell inequalities have been broken with high confidence.']);
    
end