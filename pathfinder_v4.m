function [allpaths,cost,L] = pathfinder_v4(G,destinations,tree,normal,EW,sig_nodes,in_out,timeUE,G2link,newlinks,tNod)
allpaths=cell(size(normal,1),size(destinations,2));
cost=zeros(size(normal,1),size(destinations,2));
L=zeros(size(normal,1),size(destinations,2));
% allbuspaths=cell(size(destinations,2),size(destinations,2));
allcosts=zeros(size(destinations,2),size(destinations,2));
% busG=G;
G.Edges.Weight=EW;
% busG.Edges.Weight=EW2;
NL=size(timeUE,1);

for k=1:size(normal,1)
    if sig_nodes(k,1)==1
        [~,C,E]=shortestpathtree(G,normal(k,1),tree{1,2},'OutputForm','cell');
    end
    allcosts(k,:)=C;
    for j=1:size(destinations,2)
        d1=G2link(E{j},2);
        d2=[];
        d_in=1;
        for i=1:size(d1,1)
            if d1(i,1)<=NL
                d2(d_in,1)=d1(i,1);
                d_in=d_in+1;
            else
                nin=d1(i,1)-NL;
                exp2=newlinks(nin,3:4)';
                d2=[d2;exp2];
                d_in=size(d2,1)+1;
            end
        end
        allpaths{k,j}=d2;
    end
end
for i=1:size(normal,1)
    if sig_nodes(i,1)==0
        node=i;
        out=in_out{node,2};
        ns=tNod(out);
        d=ns(ns>size(normal,1));
        is=ns(ns<=size(normal,1));
        isc=allcosts(is,:);
        isc(1,:)=isc(1,:)+timeUE(out(1,1),1);
        isc(2,:)=isc(2,:)+timeUE(out(2,1),1);
        mcn=isc(1,:)<isc(2,:);
        test=sum(isc(1,:)==isc(2,:));
        ds=find(destinations==d);
        for d_in=1:size(destinations,2)
            if d_in==ds
                allpaths{i,d_in}=in_out{d,1};
            elseif mcn(1,d_in)==1
                allpaths{i,d_in}=[out(1,1);allpaths{is(1,1),d_in}];
            else
                allpaths{i,d_in}=[out(2,1);allpaths{is(2,1),d_in}];
            end
            
        end
    end
    for d_in=1:size(destinations,2)
        L(i,d_in)=length(timeUE(allpaths{i,d_in}));
        cost(i,d_in)=sum(timeUE(allpaths{i,d_in}));
    end
end
end


