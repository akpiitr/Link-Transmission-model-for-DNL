function [EW] = edgeweights_car(ctime,lengths,link2G,newlinks)
    NL=size(lengths,1);
    NnewL=size(newlinks,1);
    EW=zeros((NL+NnewL),1);
for i=1:(NL+NnewL)
    if i<=NL
        EW(link2G(i,2),1)=100+ctime(i,1);
    else
        i2=i-NL;
        if newlinks(i2,5)==1
            EW(link2G(i,2),1)=sum(ctime(newlinks(i2,3:4))); %duz
        elseif newlinks(i2,5)==2 
            EW(link2G(i,2),1)=sum(ctime(newlinks(i2,3:4)))+10^-9; %sag
        elseif newlinks(i2,5)==3
            EW(link2G(i,2),1)=sum(ctime(newlinks(i2,3:4)))+(2*10^-9); %sol
        end
    end
end
end

