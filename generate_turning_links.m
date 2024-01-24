function [newlinks] = generate_turning_links(links,nodes,sig_nodes,in_out,u_turn_check,fNod,tNod)
int=find(sig_nodes);
newlinks=zeros(1,4);
in1=1;
for i=1:size(int,1)
    node=int(i,1);
    in=in_out{node,1};
    out=in_out{node,2};
    nlinks=zeros(1,4);
    in2=1;
    for j=1:size(in,1)
        for k=1:size(out,1)
            if abs(in(j,1)-out(k,1))~=u_turn_check
                f=fNod(in(j,1));
                m=tNod(in(j,1));
                t=tNod(out(k,1));
                L1=in(j,1);
                L2=out(k,1);
                d1=links.dir(in(j,1));
                d2=links.dir(out(k,1));
                if d1==d2
                    trn=1; %straight
                else
                    x1=nodes.xco(f)-nodes.xco(m);
                    x2=nodes.xco(t)-nodes.xco(m);
                    y1=nodes.yco(f)-nodes.yco(m);
                    y2=nodes.yco(t)-nodes.yco(m);
                    if x1==0
                        if y1>0
                            p1=3;
                        else
                            p1=1;
                        end
                    else
                        if x1>0
                            p1=2;
                        else
                            p1=4;
                        end
                    end
                    if x2==0
                        if y2>0
                            p2=3;
                        else
                            p2=1;
                        end
                    else
                        if x2>0
                            p2=2;
                        else
                            p2=4;
                        end
                    end
                    if (p1==1 && p2==2) || (p1==2 && p2==3) || (p1==3 && p2==4) || (p1==4 && p2==1)
                        trn=2; %Right turn
                    else
                        trn=3; %left turn
                    end
                end
                nlinks(in2,1)=f;
                nlinks(in2,2)=t;
                nlinks(in2,3)=L1;
                nlinks(in2,4)=L2;
                nlinks(in2,5)=trn;
                newlinks(in1,1)=f;
                newlinks(in1,2)=t;
                newlinks(in1,3)=L1;
                newlinks(in1,4)=L2;
                newlinks(in1,5)=trn;
                in1=in1+1;
                in2=in2+1;
            end
        end
    end
   
end
end