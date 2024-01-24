function [signal] = signalphase(links,sig_nodes)
NL=size(links,1);
signal=zeros(NL,2);
for i=1:NL   
    if links.toNode(i)<=size(sig_nodes,1) && sig_nodes(links.toNode(i),1)==1
            if links.dir(i)==1
                signal(i,1)=1;
            else
                signal(i,2)=1;
            end
    else
        signal(i,:)=1;
    end
end

