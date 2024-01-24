function [TT] = getTT(d,fs,cap,jam)
cden=cap/fs;
d=round(d,8);
if d<=cden
    v=fs;
else
    v=(cap*(jam-d))/(d*(jam-cden));
    if v<0
        v=0;
    end
end
TT=(0.2/v);%+0.00625;
if TT>5
    TT=5;
end
end

