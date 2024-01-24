function [nodes_2,links_2,int_nodes_2,sig_nodes_2] = reord_net(nodes_1,links_1,int_nodes_1,sig_nodes_1,origins,destinations,ex)
%written by Murat Bayrak. Use/modify it as you want. 
%   Reorders the indices of the nodes in the network. This process is required
%for dynamic route assignment. If the route assingment is static this
%function is not needed.
%   nodes,links,int_nodes,sig_nodes are created by gen_net function

%   ex is the variable for the changing the indices of the nodes in the
% network. for example if ex(2,1)=5, the fifth node in the network becomes
% the second node. ex is created by hand. 

nodes_2=nodes_1;
links_2=links_1;
int_nodes_2=int_nodes_1;
sig_nodes_2=sig_nodes_1;
n_inside_nodes=size(nodes_1,1)-size(destinations,2)-size(origins,2);
for i=1:n_inside_nodes
        in1=i;
        in2=ex(i,1);
        x1=nodes_1.xco(in1);
        y1=nodes_1.yco(in1);
        d1t=links_1.toNode==in1;
        d1f=links_1.fromNode==in1;
        int1=int_nodes_1==in1;
        sig1=sig_nodes_1(in1,1);
        nodes_2.xco(in2)=x1;
        nodes_2.yco(in2)=y1;
        links_2.toNode(d1t)=in2;
        links_2.fromNode(d1f)=in2;
        int_nodes_2(int1)=in2;
        sig_nodes_2(in2)=sig1;
end
end

