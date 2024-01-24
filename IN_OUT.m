function [in_out] = IN_OUT(links,nodes)
NN=size(nodes,1);
fromNodes = links.fromNode;
toNodes = links.toNode;
in_out=cell(NN,2);
for i=1:NN
    in_out{i,1}=find(toNodes==i); %incominglinks
    in_out{i,2}=find(fromNodes==i); %outgoinglinks
end
end

