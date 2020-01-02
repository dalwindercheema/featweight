function pos = initialization_weighted_knn(lb,ub,dim,N )
pos=zeros(N,dim);
if(size(lb)==1)
    for i=1:N
        pos(i,:)=unifrnd(lb,ub,[1 dim]);
    end
else
    for i=1:N
        for j=1:dim
            pos(i,j)=unifrnd(lb(j),ub(j),1);
        end
    end
end
pos(:,dim)=round(pos(:,dim));
end