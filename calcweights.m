% This code perform linear feature weighting by multipling the 
% weights with the features.

function ntrain = calcweights(train,weights,bb)
ntrain=[];
count=1;
for pp=1:bb
    if(weights(pp)~=0)
        ntrain(:,count)=train(:,pp)*weights(pp);
        count=count+1;
    end
end