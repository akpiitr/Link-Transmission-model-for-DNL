function [ ODmatrices,timeSeries ] = ODformat(ODc, or_set)
%UNTÝTLED Summary of this function goes here
%   Detailed explanation goes here
    ODmatrices(1,1)={zeros(size(or_set,2))};
    timeSeries{1,1}=0;
    for i=1:4
        dOD=(i/4)*ODc;
        ODmatrices(1,i)={dOD};
        if i<=3
            timeSeries{1,i+1}=(i*5)/60;
        else
            timeSeries{1,i+1}=30/60;
        end
    end
%     for i=1:4
%         dOD=((4-i)/4)*ODc;
%         ODmatrices(1,i+4)={dOD};
%         if i<=3
%             timeSeries{1,i+5}=0.5+((i*5)/60);
%         else
%             timeSeries{1,i+5}=90/60;
%         end
%         
%     end
%     for i=1:size(timeSeries,2)
%         frac=i*lfrac;
%         if frac>1
%             frac=1;
%         end
% %         dOD=zeros(NN+(2*nor));
% %         for j1=1:nor
% %             for k1=1:nor
% %                 j=ordes(1,j1);
% %                 k=ordes(1,k1);
% %                 dOD(j1+NN,k1+NN+nor)=frac*ODc(j,k);
% %             end
% %         end
%         dOD=frac*ODc; %%%%
%         ODmatrices(1,i)={dOD};
%     end
% 
end

