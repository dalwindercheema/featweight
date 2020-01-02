% This function calculates the newer position of ants using blend crossover
% operation. Refer to Figure 4 and eq. 11 in the paper

function ant=BLX(dim,RA,RE,lb,ub)
alpha=0.5;
d=abs(RA-RE);
x1=min(RA,RE)-alpha*d;
x2=max(RA,RE)+alpha*d;
ant=unifrnd(x1,x2);
for i=1:dim-1
    ant(1,i)=max(min(ant(1,i),ub(i)),lb(i));
end
ant(1,dim)=max(min(floor(ant(1,dim)),ub(dim)),lb(dim));