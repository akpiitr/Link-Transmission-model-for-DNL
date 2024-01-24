%%
clear
load car_only_7x7_input.mat
fname='save_name.mat';
n=7; %number of intersections on one edge
ll=0.2; %link length km
v0=40; %free-flow speed kmh
cap=2400; %capacity veh/hr
jam=270; %jam density veh/km
[links,nodes,int_nodes,origins,destinations,sig_nodes,per]=gen_net(n,v0,ll,jam,cap);
[nodes,links,int_nodes,sig_nodes] = reord_net(nodes,links,int_nodes,sig_nodes,origins,destinations,ex);
fNod = links.fromNode;
tNod = links.toNode;
in_out=IN_OUT(links,nodes);
u_turn_check=168; %determine this by looking at the network plot
newlinks=generate_turning_links(links,nodes,sig_nodes,in_out,u_turn_check,fNod,tNod);
NL=size(links,1);
NN=size(nodes,1);

demand=5;
t0=ll/v0; %free-flow travel time
fnode2=[fNod',newlinks(:,1)'];
tnode2=[tNod',newlinks(:,2)'];
G=digraph(fnode2,tnode2);
fnode2=fnode2';
tnode2=tnode2';
[ G2link,link2G ] = indexer( fnode2,tnode2,G );
OD=zeros(NN);
OD(origins,destinations)=demand;
OD(sub2ind(size(OD),origins,destinations))=0;
dt = 0.0025; %one time step in hr
totT=400; %simulation duration in time steps
%%
[ODmatrices,timeSeries]=ODformat(OD,origins);
[ODmatrix,origins,destinations] = buildODmatrix(ODmatrices,timeSeries,dt,totT+1);
tree=cell(size(origins,2),2); %destination set for each origin
for i=1:size(origins,2)
    tree{i,1}=origins(i);
    dset=[];
    for j=1:size(destinations,2)
        dset(size(dset,1)+1,1)=destinations(j);
    end
    tree{i,2}=dset;
end
ffttime=links.length./links.freeSpeed;

[signal] = signalphase(links,sig_nodes);
route_choice_sensitivity=140;
detour_limit=99;
tic
[cvn_up, cvn_down, density] = LTM_CAR(nodes,links,origins,destinations,ODmatrix,dt,totT,signal,NL,t0,G,link2G,in_out,tree,newlinks,sig_nodes,G2link,route_choice_sensitivity,detour_limit,u_turn_check);
toc
% save(fname)

  