function [links,nodes,int_nodes,origins,destinations,sig_nodes,per] = gen_net(n,v0,L,kjam,cap)
%generates square symetric network
a=2*n*(n-1);
N_or=a;
N_des=a;
N_int=n^2;
N_mid=a;
N_tot=N_mid+N_int+N_or+N_des;
NL_or=a;
NL_des=a;
NL_en=2*a;
NL_ws=2*a;
NL_tot=NL_or+NL_des+NL_en+NL_ws;
id=linspace(1,NL_tot,NL_tot)';
fromNode=zeros(NL_tot,1);
toNode=zeros(NL_tot,1);
length=zeros(NL_tot,1);
freeSpeed=zeros(NL_tot,1);
capacity=zeros(NL_tot,1);
kJam=zeros(NL_tot,1);
links=table(id,fromNode,toNode,length,freeSpeed,capacity,kJam);
id=linspace(1,N_tot,N_tot)';
xco=zeros(N_tot,1);
yco=zeros(N_tot,1);
nodes=table(id,xco,yco);
int_nodes=ones(N_int+N_mid,1);
per=zeros(N_int+N_mid,1);
modifier=0;
n_in=1;
orn_in=N_int+N_mid+1;
desn_in=N_int+N_mid+N_or+1;
orl_in=NL_en+NL_ws+1;
desl_in=NL_en+NL_ws+NL_or+1;
l_in=1;
origins=[];
destinations=[];
xc1=(linspace(1,2*n-1,2*n-1)*10)-5;
xc2=(linspace(1,n,n)*20)-15;
nodes.yco(n_in)=-5;
for i=1:((3*n)-2)
   ass_mod=mod(modifier,3);
   if ass_mod==0
       nodes.xco(n_in)=xc1(1);
       nodes.yco(n_in)=nodes.yco(n_in)+10;
       for j=1:2*(n-1)
           if mod(j,2)==1
               links.fromNode(l_in)=n_in;
               links.toNode(l_in)=n_in+1;
               links.length(l_in)=L;
               links.freeSpeed(l_in)=v0;
               links.capacity(l_in)=cap;
               links.kJam(l_in)=kjam;
               links.dir(l_in)=1;
               n_in=n_in+1;
               l_in=l_in+1;
               nodes.xco(n_in)=xc1(j+1);
               nodes.yco(n_in)=nodes.yco(n_in-1);
               links.fromNode(orl_in)=orn_in;
               origins(size(origins,1)+1,1)=orn_in;
               links.toNode(orl_in)=n_in;
               links.length(orl_in)=L;
               links.freeSpeed(orl_in)=v0;
               links.capacity(orl_in)=cap;
               links.kJam(orl_in)=30000;
               links.fromNode(desl_in)=n_in;
               links.toNode(desl_in)=desn_in;
               destinations(size(destinations,1)+1,1)=desn_in;
               links.length(desl_in)=L;
               links.freeSpeed(desl_in)=v0;
               links.capacity(desl_in)=cap;
               links.kJam(desl_in)=30000;
               nodes.xco(orn_in)=nodes.xco(n_in)+3;
               nodes.yco(orn_in)=nodes.yco(n_in)+3;
               nodes.xco(desn_in)=nodes.xco(n_in)-3;
               nodes.yco(desn_in)=nodes.yco(n_in)-3;
               orn_in=orn_in+1;
               desn_in=desn_in+1;
               orl_in=orl_in+1;
               desl_in=desl_in+1;
           else
               links.fromNode(l_in)=n_in;
               links.toNode(l_in)=n_in+1;
               links.length(l_in)=L;
               links.freeSpeed(l_in)=v0;
               links.capacity(l_in)=cap;
               links.kJam(l_in)=kjam;
               links.dir(l_in)=1;
               n_in=n_in+1;
               nodes.xco(n_in)=xc1(j+1);
               nodes.yco(n_in)=nodes.yco(n_in-1);
               l_in=l_in+1;
           end
       end
       
   elseif ass_mod==1
       for j=1:n
           links.fromNode(l_in)=(n_in+1)-(2*n-j);
           links.toNode(l_in)=n_in+1;
           links.length(l_in)=L;
           links.freeSpeed(l_in)=v0;
           links.capacity(l_in)=cap;
           links.kJam(l_in)=kjam;
           links.dir(l_in)=2;
           n_in=n_in+1;
           nodes.xco(n_in)=xc2(j);
           nodes.yco(n_in)=nodes.yco((n_in)-(2*n-j))+10;
           l_in=l_in+1; 
           links.fromNode(orl_in)=orn_in;
           origins(size(origins,1)+1,1)=orn_in;
           links.toNode(orl_in)=n_in;
           links.length(orl_in)=L;
           links.freeSpeed(orl_in)=v0;
           links.capacity(orl_in)=cap;
           links.kJam(orl_in)=30000;
           links.fromNode(desl_in)=n_in;
           links.toNode(desl_in)=desn_in;
           destinations(size(destinations,1)+1,1)=desn_in;
           links.length(desl_in)=L;
           links.freeSpeed(desl_in)=v0;
           links.capacity(desl_in)=cap;
           links.kJam(desl_in)=30000;
           nodes.xco(orn_in)=nodes.xco(n_in)+3;
           nodes.yco(orn_in)=nodes.yco(n_in)+3;
           nodes.xco(desn_in)=nodes.xco(n_in)-3;
           nodes.yco(desn_in)=nodes.yco(n_in)-3;
           orn_in=orn_in+1;
           desn_in=desn_in+1;
           orl_in=orl_in+1;
           desl_in=desl_in+1;           
       end
       nodes.yco(n_in+1)=nodes.yco(n_in);
   elseif ass_mod==2
       for j=1:n
           links.fromNode(l_in)=(n_in+1)-(n+j-1);
           links.toNode(l_in)=n_in+1;
           links.length(l_in)=L;
           links.freeSpeed(l_in)=v0;
           links.capacity(l_in)=cap;
           links.kJam(l_in)=kjam;
           links.dir(l_in)=2;
           n_in=n_in+2;
           l_in=l_in+1;
           if j==n
               n_in=(n_in+1)-(n+j-1)-1;
           end
       end
   end
   modifier=modifier+1;
end
links.fromNode(NL_ws+1:NL_ws+NL_en)=links.toNode(1:NL_en);
links.toNode(NL_ws+1:NL_ws+NL_en)=links.fromNode(1:NL_en);
links.length(NL_ws+1:NL_ws+NL_en)=links.length(1:NL_en);
links.freeSpeed(NL_ws+1:NL_ws+NL_en)=links.freeSpeed(1:NL_en);
links.capacity(NL_ws+1:NL_ws+NL_en)=links.capacity(1:NL_en);
links.kJam(NL_ws+1:NL_ws+NL_en)=links.kJam(1:NL_en);
links.dir(NL_ws+1:NL_ws+NL_en)=links.dir(1:NL_en);
int_nodes(links.fromNode(links.id>NL_ws+NL_en+NL_or))=0;
% per(links.fromNode(links.id>NL_ws+NL_en+NL_or))=0;
sig_nodes=int_nodes;
for i=1:size(int_nodes,1)
   if size(find(links.fromNode==i),1)<4
       per(i,1)=1;
       if size(find(links.fromNode==i),1)==2
            int_nodes(i,1)=0;
            per(i,1)=0;
       end
   end
end
per(links.fromNode(links.id>NL_ws+NL_en+NL_or))=0;
per=find(per==1);
int_nodes=find(int_nodes==1);
origins=origins';
destinations=destinations';

end

