
clear;
importfile('x0a0y0b0.txt');

%-------Pre-processing :
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

%--------Finding the pairs (not necessarily coincidences) of arrivals (that is the
%closer arrival on channel 2 corrisponding to each arrival in channel 1)


n_pairs = 0; %counting pairs
diff=data_sec(:,1); %time differences between pairs(nonsense initial value that must be uptaded)
for i=1:ind_max;
    
        if data_sec(i,2) == 1; %that is for each click of channel one
                   d=0; %distance from element of ch1 in the list
                   reached_right=0; %still not reached 1st time-tag of ch2 in the future
                   reached_left=0;  %still not reached 1st time-tag of ch2 in the past
            while not(reached_right && reached_left) 
                d=d+1;
                if i+d>ind_max ; 
                    reached_right=1;
                    n_pairs = n_pairs + 1;
                    diff(n_pairs)=10; % time out of domain, will be replaced
                end %avoid index out of bounds
                
                if  reached_right==0 && data_sec(i+d,2)==2; 
                    reached_right=1;
                    if reached_left == 0;
                        n_pairs = n_pairs + 1;
                        diff(n_pairs)=abs(data_sec(i,1)-data_sec(i+d,1)); 
                    else
                        diff(n_pairs)=min(diff(n_pairs),abs(data_sec(i,1)-data_sec(i+d,1)));
                    end
                end
                
                if i-d==0; 
                    reached_left=1;
                    n_pairs = n_pairs + 1;
                    diff(n_pairs)= 10; % time out of domain, will be replaced;
                end %avoid index out of bounds
                
                if reached_left==0 && data_sec(i-d,2)==2; 
                   reached_left=1;
                   if reached_right == 0;
                        n_pairs = n_pairs + 1;
                        diff(n_pairs)=abs(data_sec(i,1)-data_sec(i-d,1)); 
                   else
                        diff(n_pairs) = min( diff(n_pairs),abs(data_sec(i,1)-data_sec(i-d,1)));
                   end
                   
                end
            end %end of while : the matching ch2 tag has been found for this ch1 tag
        end  
end   %end of for : for each ch1 tag we have the time difference to the closer ch2 tag
diff=diff(1:n_pairs);
clear i d;


%------------Histogram of time differences between pairs of channel 1 and 2 clicks
%I filter out all time-differences above 3*10.*(-9) as I expect the photons generated together
%arrive within this time interval

diff_filt = diff; 
count = 0;
 for j= 1:n_pairs;
     if diff(j)< 3*10.^(-9);
         count= count+1;
         diff_filt(count)=diff(j);
     end
 end
 clear j;
 diff_filt = diff_filt(1:count);
 hist(diff_filt,sqrt(count));figure(gcf);

%I obtain from this Poisson-like distribution a more precise interval of
%confidence to be used as coincidence time-bin

CoincidenceTime = mean(diff_filt)+3*sqrt(var(diff_filt));

%-------------Counting coincidences
coincidences=0;
if CoincidenceTime < 3*10.^(-9)
    for i=1:count
        if diff_filt(i)<CoincidenceTime
            coincidences = coincidences+1;
        end
    end
else
    for i=1:n_pairs
        if diff(i)<CoincidenceTime
            coincidences = coincidences+1;
        end
    end
end






