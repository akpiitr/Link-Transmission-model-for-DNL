function [cvn_up3, cvn_down3, density] = LTM_CAR(nodes,links,origins,destinations,ODmatrix,dt,totT,signal,NL,t0,G,link2G,in_out,tree,newlinks,sig_nodes,G2link,sensitivity,Llim,u_turn_check)
totLinks = length(links.fromNode);
totDest = length(destinations);
timeSlices =(0:totT)*dt;
incvnup=zeros(totLinks,1,totDest);
endcvnup=zeros(totLinks,1,totDest);
cvn_up2 = zeros(totLinks,10,totDest);
cvn_down2 = zeros(totLinks,10,totDest);
rt=zeros(1,totT+1);
cvn_up3=zeros(totLinks,totT+1);
cvn_down3=zeros(totLinks,totT+1);
fromNodes = links.fromNode;
toNodes = links.toNode;
freeSpeeds = links.freeSpeed;
capacities = links.capacity;
kJams = links.kJam;
lengths = links.length;
wSpeeds = capacities./(kJams-capacities./freeSpeeds);
normalNodes = setdiff(nodes.id,[origins,destinations]);
signalmode=1;
ass_start=20;
cycle=6;
t=2;
crit=1;
rt(1,1)=1;
signalhist=zeros(NL,1)+1;
ctime2=zeros(NL,1)+t0;
ctime3=zeros(NL,1)+t0;
asscrit=1;
while crit==1
    t_in=mod(t-1,10)+1; %shortened time index
    rt(1,t)=t_in; %real time index
    if mod(t,0.5*cycle)==0
        if signalmode==1
            signalmode=2;
        elseif signalmode==2
            signalmode=1;
        end
    end
    if  (mod(t,cycle)==0 || t==2) && asscrit==1 %&& t>=ass_start %|| t==2%
        ctime2=round(ctime2,8);
        [EW]=edgeweights_car(ctime2,lengths,link2G,newlinks);
        [SP,cost,SPL]=pathfinder_v4(G,destinations,tree,normalNodes,EW,sig_nodes,in_out,ctime2,G2link,newlinks,toNodes);
    end
    ctime3=round(ctime3,8);
    for i=1:size(normalNodes,1)
        for d_in=1:size(destinations,2)
            if SPL(i,d_in)<=Llim
            cost(i,d_in)=sum(ctime3(SP{i,d_in}));
            else
                path=SP{i,d_in};
                cost(i,d_in)=sum(ctime3(path(1:Llim,1)));
            end
        end
    end
    if t>400
        ODc(:,:)=0;      
    else
        ODc=ODmatrix(:,:,t-1);
    end
    %ORIGIN NODES<--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %this nested function goes over all origin nodes
    loadOriginNodes(t);
    %ACTUAL LTM <---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %go over all normal nodes in this time step
    for nIndex=1:length(normalNodes)
        n=normalNodes(nIndex);
        outgoingLinks = find(fromNodes==n);
        nbOut = length(outgoingLinks);
        incomingLinks = in_out{n,1};
        out=in_out{n,2};
        TF=cell(1,totDest);
        nbIn = length(incomingLinks);
        SF_d = zeros(nbIn,totDest);
        SF_d2 = zeros(nbIn,totDest);
        SF_tot = zeros(nbIn,1);
        SF = zeros(nbIn,1);
        for l_index=1:nbIn
            l=incomingLinks(l_index);
%             stime = timeSlices(t)-lengths(l)/freeSpeeds(l);
            stime = timeSlices(t)-t0;
            dt1=ceil(stime/dt);
            dt2=dt1+1;
            cv1=incvnup(l,1,:);
            cv2=endcvnup(l,1,:);
            if dt1<=0
                dt1=1;
                dt2=dt1+1;
            end
            cv3=cvn_up2(l,rt(1,dt1),:);
            cv4=cvn_up2(l,rt(1,dt2),:);
            SF_d(l_index,:) = calculateDestSendFlow(l,t,stime,cv1,cv2,cv3,cv4,dt1);
            if signal(l,signalmode)==0 && t>=ass_start
                 SF_d(l_index,:)=0;
            end
%             if dwell_in(l)==1
%                 SF_d(l_index,:)=0;%SF_d(l_index,:)*0.5;
%             end
            SF_d2(l_index,:)=SF_d(l_index,:);
            neg_in=find(SF_d(l_index,:)<0);
            SF_d(l_index,neg_in)=ceil(SF_d(l_index,neg_in));
            SF_tot(l_index) = sum(SF_d(l_index,:));
            SF(l_index) = min(capacities(l)*dt,SF_tot(l_index));
           
        end     
        if nbOut==1
           TF_n(1:nbIn,1) = 1;
        else
           TF_n=zeros(nbIn,nbOut);
        end
        for dest=1:totDest
           dcell=zeros(size(incomingLinks,1),size(out,1));
           for l_index=1:nbIn
               if SF_d(l_index,dest)~=0
                   if sig_nodes(n,1)==0 %&& l_index<nbIn
                       tLink=SP{n,dest};
                       tL=find(out==tLink(1,1));
                       dcell(l_index,tL)=1;
                   else
                       minL=SPL(n,dest);
                       outN=toNodes(out);
                       dumL=SPL(outN,dest);
                       dumL2=(dumL<=(minL-1));
                       if sum(dumL2)==0
                           tLink=SP{n,dest};
                           dumL2=out==tLink(1,1);
                       end
                       dumc=cost(outN,dest)+ctime2(out);
                       dumL4=dumc<min(dumc(dumL2));
                       if sum(dumL4)>0
                           for l_in=1:length(dumc)
                                if dumL4(l_in)==1
                                    outL=out(l_in);
                                    fLsp=SP{outN,dest};
                                    fLsp=fLsp(1,1);
                                    if abs(outL-fLsp)~=u_turn_check %u-turn check
                                        dumL2(l_in)=1;
                                    end
                                end
                           end
                       end
                       if sum(dumL2)==1
                           tLink=SP{n,dest};
                           tL=find(out==tLink(1,1));
                           dcell(l_index,tL)=1;
                           continue
                       end
                       int=0;
                       tri=0;
                       util=exp(int-(dumc*sensitivity));
                       while sum(util(dumL2))==0
                            tri=tri+1;
                            int=tri*10;
                            util=exp(int-(dumc*sensitivity));
                       end
                       for o_in=1:length(util)
                           if dumL2(o_in,1)==1
                               dcell(l_index,o_in)=util(o_in)/sum(util(dumL2));
                           end
                       end
                   end
               end
           end
           TF_n=TF_n+repmat(SF_d(:,dest),1,nbOut).*dcell;
           TF{1,dest}=dcell;
        end
        TF_n = TF_n./repmat(sum(TF_n,2),1,nbOut);
        n_in=isnan(TF_n);
        TF_n(n_in)=0;
        %CALCULATE RECEIVING FLOW<-----------------------------------------------------------------------------------------------------------------------------------------------------------
        %this is the maximum number of vehicles that can flow into the
        %outgoing links within this time interval
        
        RF = zeros(nbOut,1);
        for l_index=1:nbOut
            l=outgoingLinks(l_index);
            RF(l_index) = calculateReceivingFlow_FQ(l,t);
        end
        %compute transfer flows with the NODE MODEL
        TransferFlow = NodeModel(nbIn,nbOut,SF,TF_n,RF,capacities(incomingLinks)*dt);
        neg_in=find(TransferFlow<0);
        TransferFlow(neg_in)=ceil(TransferFlow(neg_in));
        red = sum(TransferFlow,2)./(SF_tot);
        nan_in=isnan(red);
        red(nan_in)=0;
        redm=repmat(red,1,totDest);
        redm=redm.*SF_d;
        cvn_down2(incomingLinks,rt(1,t),:)=cvn_down2(incomingLinks,rt(1,t-1),:)+reshape(redm,size(cvn_down2(incomingLinks,rt(1,t-1),:)));
        for d = 1:totDest
            redm(:,d)=((redm(:,d))'*TF{1,d})';
        end
        cvn_up2(outgoingLinks,rt(1,t),:)=cvn_up2(outgoingLinks,rt(t-1),:)+reshape(redm,size(cvn_up2(incomingLinks,rt(1,t-1),:)));
    end
    if t==totT+1
        endcvnup=cvn_up2(:,rt(1,t),:);
    end
    %DESTINATION NODES<----------------------------------------------------------------------------------------------------------------------------
    %this nested function goes over all destination nodes
    loadDestinationNodes(t);
    for i=1:NL
        cd=sum(cvn_down2(i,rt(1,t),:),3);
        cu=sum(cvn_up2(i,rt(1,t),:),3);
        if cd>cu
            rio=cd/cu;
            cvn_up2(i,rt(1,t),:)=cvn_up2(i,rt(1,t),:)*rio;
        end
    end   
    
    cvn_up3(:,t)=sum(cvn_up2(:,rt(1,t),:),3);
    cvn_down3(:,t)=sum(cvn_down2(:,rt(1,t),:),3);
    den=(cvn_up3(:,t)-cvn_down3(:,t))*5;
    density(:,t)=den;
    for i=1:NL
        if t>=cycle
            time_in=(t-cycle+1):t;
        else
            time_in=1:t;
        end        
        ctime2(i,1)=getTT(mean(density(i,time_in)),freeSpeeds(i,1),capacities(i,1),kJams(i,1)); % average link travel time during last signal cycle
        ctime3(i,1)=getTT(density(i,t),freeSpeeds(i,1),capacities(i,1),kJams(i,1)); %link travel time during last time step
    end
    if max(den)<30 && t>400
        asscrit=0;
    end
    %%
    if t==totT+1 
        timeSlices(1,totT+2)=timeSlices(1,totT+1)+dt;
        totT=totT+1;
    end
    if max(den)==0 && t>300 %
        c_emp_t=t;
        crit=0;
    end
    if t<ass_start
        signalhist(:,t)=1;
    else
        signalhist(:,t)=signal(:,signalmode);
    end
    t=t+1;
end

    %%
    %All nested function follow below:

    %Nested function for finding destination based sending flows
    function SF = calculateDestSendFlow(l,t,time,cv1,cv2,cv3,cv4,dt1)
        SFCAP = capacities(l)*dt;              
        if time<=timeSlices(1)
            val=cv1;
        elseif time>=timeSlices(end)
            val=cv2;
        else
            val=cv3+(time/dt-dt1+1)*(cv4-cv3);
        end
        SF = val-cvn_down2(l,rt(1,t-1),:);
        if SF > SFCAP
            red = SFCAP/sum(SF);    
            SF = red*SF;
        end
    end
    %Nested function for finding receiving flows for a physical queue
    function RF = calculateReceivingFlow_FQ(l,t)
        RF = capacities(l)*dt;
        time = timeSlices(t)-lengths(l)/wSpeeds(l);
        cvn=cvn_down3(l,:);
        if time<=timeSlices(1)
            val1=cvn(1,1);
        elseif time>=timeSlices(end)
            val1=cvn(1,end);
        else
            t1=ceil(time/dt);
            t2=t1+1;
            val1 = cvn(1,t1)+(time/dt-t1+1)*(cvn(1,t2)-cvn(1,t1));
        end
        val = val1+kJams(l)*lengths(l);
        RF = min(RF,val-cvn_up3(l,t-1));
        if RF<0
            RF=ceil(RF);
        end
    end
    %Nested function that assigns the origin flow
    function loadOriginNodes(t)
        %update origin nodes
        for o_index=1:length(origins)
            o = origins(o_index);
            outgoingLinks = find(fromNodes==o);
            for l_index = 1:length(outgoingLinks)
                l=outgoingLinks(l_index);
                for d_index = 1:totDest
                    %calculation sending flow          
%                         SF_d = sum(ODmatrix(o_index,d_index,t-1))*dt;
                        SF_d = sum(ODc(o_index,d_index))*dt;
                        cvn_up2(l,rt(1,t),d_index)=cvn_up2(l,rt(1,t-1),d_index) + SF_d;     
                end
            end
        end 
    end
    %Nested function that assigns the destination flow
    function loadDestinationNodes(t)
        %update origin nodes
        for d_index=1:length(destinations)
            d = destinations(d_index);
            incomingLinks = find(toNodes==d);
            for l_index=1:length(incomingLinks)
                l=incomingLinks(l_index);
%                  for d_index = 1:totDest
                    %calculation sending flow
                    time=timeSlices(t)-lengths(l)/freeSpeeds(l);
                    if time<=timeSlices(1)
                        SF_d=incvnup(l,1,:);
                    elseif time>=timeSlices(end)
                        SF_d=endcvnup(l,1,:);
                    else
                        t1=ceil(time/dt);
                        t2=t1+1;
                        SF_d=(cvn_up2(l,rt(1,t1),:)+(time/dt-t1+1)*(cvn_up2(l,rt(1,t2),:)-cvn_up2(l,rt(1,t1),:)))-cvn_down2(l,rt(1,t-1),:);
                    end
                    cvn_down2(l,rt(1,t),:)=cvn_down2(l,rt(1,t-1),:) + SF_d;
%                  end
            end
        end 
    end
end