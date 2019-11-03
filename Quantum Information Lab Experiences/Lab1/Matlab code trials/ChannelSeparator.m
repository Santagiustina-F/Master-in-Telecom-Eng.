data(:,1)=data(:,1)-data(1,1); % time shifting so that t1=0
UnitTime = 80.955 * 10^(-12);
data_sec(:,1)= UnitTime.*data(:,1);

%Separating Channels
j=0;
k=0;
TempOne = data_sec(:,1);
TempTwo = data_sec(:,1);
for i=1:size(data_sec,1);
    if data_sec(i,2) == 1
        j = j+1;
        TempOne(j) =  data_sec(i,1);
    end
    if data_sec(i,2) == 2
        k = k+1;
        TempTwo(k) =  data_sec(i,1);
        
    end
end
ChannelOne = TempOne(1:j);
ChannelTwo = TempTwo(1:k);

total = size(data_sec,1) -j -k;

clear TempOne TempTwo;



