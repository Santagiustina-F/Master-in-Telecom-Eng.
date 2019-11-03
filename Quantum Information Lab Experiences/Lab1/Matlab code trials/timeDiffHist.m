importfile(char(data_files(1)));
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

%Histogram of time differences all time-tags
diff = data_sec(:,1);
for j= 1:size(data_sec,1)-1;
    diff(j)=data_sec(j+1,1)-data_sec(j,1);
end
diff(length(diff))=0;
diff_filt = diff; 
count = 0;
 for j= 1:n_pairs;
     if diff(j)< 2*10.^(-9);
         count= count+1;
         diff_filt(count)=diff(j);
     end
 end
 clear j;
 diff_filt = diff_filt(1:count);
 hist(diff_filt,sqrt(count));