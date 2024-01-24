function [ G2link,link2G ] = indexer( f,t,G )
%UNTÝTLED2 Summary of this function goes here
%   Detailed explanation goes here
index=[G.Edges.EndNodes,f,t];
for i=1:size(index,1)
    from=find(index(:,3)==index(i,1));
    to=find(index(from,4)==index(i,2));
    G2link(i,1)=i;
    G2link(i,2)=from(to,1);
    from2=find(index(:,1)==index(i,3));
    to2=find(index(from2,2)==index(i,4));
    link2G(i,1)=i;
    link2G(i,2)=from2(to2,1);
end

