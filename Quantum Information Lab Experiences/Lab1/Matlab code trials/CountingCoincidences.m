%Counting coincidences

f=0;
Coincid = 0;
for i=1:size(data,1);
        if data(i,2) == 1;
                   d_min = max(1,i-5);
                   d_max = min(i+5,size(data,1));
            for d = d_min:d_max;
                k=0;
                if data(d,2)==2;
                    if abs(data(i,1)-data(d,1)) < 10;
                        Coincid = Coincid + 1;
                        k=k+1;
                        if k > 1 ;
                            f=1
                        end                
                    end
                end
            end
        end
end   
Coincid
f