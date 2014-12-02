function [Ymax, YmaxVal] = onto_greedy_labeling(gradient)
    % gradient: a 5|E| column vector
    % Ymax:     max gradient labeling
    % YmaxVal:  activation order
    global E;
   % ontoid = dlmread('onto_labels_iden.txt');
%    root = find(ontoid == 24431);
    root = 1;
    m = numel(gradient)/(5*size(E,1));   
    YmaxVal=zeros(m,max(max(E)));
    
    for i = 1:m % iterate over data examples
        %disp(sprintf('infer for %d example',i));
        % BFS-like search
        cur_g = gradient(:,(i-1)*size(E,1)+1:i*size(E,1));
        v = root;
        Q = []; % when the element is 0, means removed
        V = [];
  
        V = [V, v];
        Q = [Q, v];
        yind=zeros(1,max(max(E))); % activation order
        yind(v) = 1;
        while nnz(Q) > 0 
          ind = find(Q>0,1); % find remain avaliable elements in Q
          %disp(sprintf('find chl for %d node',ind));          
          Q(ind) = 0; % mimic removing an element from Q
          chls = E(E(:,1)==ind,2);
          chlcount = 0; % the good children we will consider
          nc = length(chls);
          if nc == 0
            break
          end
          for j = 1:nc
            chl = chls(j);  
            if length(find(chl==V)) == 0 % not in V yet
              gain = getgain(ind, chl, cur_g); % the gradient gain for labeling chl with '+'
              if gain > 0
                %disp(sprintf('add chl %d',chl));        
                chlcount = chlcount + 1;
                Q = [Q, chl];
                V = [V, chl];
                yind(chl) = max(yind)+1;
                %dummy = input(sprintf('add chl by gain! (%d-> %d, %f),',ind,chl,gain));
              end
            end    
          end % iterate over children
          if chlcount == 0 % select the least worst chl with higest '+' gradient 
            chl = leastworst(ind, chls, cur_g);
            %disp(sprintf('add chl %d by least worst',chl));    
            Q = [Q, chl];
            V = [V, chl];    
            yind(chl) = max(yind)+1;        
          end
        end % end while 
        YmaxVal(i,:)=yind;
    end
    Ymax=(YmaxVal>0)*2-1;

  function gain = getgain(pid, cid, cur_g)
    eind = find(E(:,1)==pid & E(:,2)==cid); % find the index of the edge pid -> cid
    gain = cur_g(4,eind) - cur_g(3, eind); % g("++") - g("+-")
  end

  function cind = leastworst(pid, cids, cur_g)
    c = -inf; % least worst potential of labeling with "++"
    cind = 0; % least worst child of labeling with "++"
    nc = length(cids);
    for t = 1:nc
      cid = cids(t);
      eind = find(E(:,1)==pid & E(:,2)==cid); % find the index of the edge pid -> cid
      gain = cur_g(4,eind) - cur_g(3, eind); % g("++") - g("+-")      
      if gain > c
        c = gain;
        cind = cid;
        %disp(sprintf('least wrost: add %d to search, gain=%f',cind,gain))
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Su's code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        cur_g1 = cur_g(4,:)-cur_g(3,:);
%        cur_g2 = cur_g(5,:)-cur_g(2,:);
%        for j = 1:size(yind,2)
%            y2y(j,E(E(:,1)==j,2)) = cur_g1(E(:,1)==j);
%            y2y(j,E(E(:,2)==j,1)) = cur_g2(E(:,2)==j);
%        end
%        n=1;
%        while 1
%            n = n+1;
%            if n>1000
%                break
%            end
%            [a,b] = find(y2y(yind==1,:)==max(max(y2y(yind==1,:))));
%            a=a(1);
%            b=b(1);
            % [n,a,b,y2y(a,b)]
%            if y2y(a,b) <0
%                break
%            end
%            y2y(b,yind==1)=-1;
%            y2y(a,b)=-1;
%            yind(b)=n;
%        end
%        YmaxVal(i,:)=yind;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %error('For debug!')



