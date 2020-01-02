% Source Code for Feature Weighting with Ant Lion optimization (Version 1.0)
%
% This aims to search for the feature weights with the optimal of closet
% nearest neighbor parameter (i.e. k) simultaneously.
%
% This code is inspired from the original Ant Lion Optimization algorithm. 
% However, this code is modified for feature weighting as well as an error
% has been removed from the original code. The details of error as given
% below:
% The variable "sorted_antlion_fitness" is used to create "double_fitness",
% but this variable never updated in code. Therefore, values of
% "sorted_antlion_fitness" is used from iteration 1 "only" throughout all 
% iterations causing convergence problems.

% Input Parameters: 
% train:    training data where rows represent instances and columns 
%           represents  features
% label:    Class label vector
% Popu:     Total Population of antlions and ants
% Max_iter: Maximum Iterations to search for solutions
%
%
% Output Parameters: 
%
% GlobalBest: A structure with the information of best fitness value and
%             best solution
%             GlobalBest.Cost = Best Fitness
%             GlobalBest.Post = Best Solution
% ConCurve:   A vector of length equal to Max_iter which shows the
%             convergence of the algorithm
%
% Please cite the code by referring to this paper:
%
% Dalwinder Singh and Birmohan Singh, "Hybridization of feature selection 
% and feature weighting for high dimensional data", Applied Intelligence,
% Vol., 49, No. 4, pp: 1580-1596, 2019
% 

function [GlobalBest,ConCurve]=FW_ALO(train,label,Popu,Max_iter)
N=Popu;
[~,dim]=size(train);
ub=1*ones(dim,1);
ub(dim+1,1)=11;
ub=ub';
lb=0*ones(dim,1);
lb(dim+1,1)=1;
lb=lb';

antlion_position=initialization_weighted_knn(lb,ub,dim+1,N);

ant_position=zeros(N,dim+1);
Sorted_antlions=zeros(N,dim+1);
antlions_fitness=zeros(1,N);
ants_fitness=zeros(1,N);
ConCurve=zeros(Max_iter,1);

for i=1:size(antlion_position,1)
    ntrain=calcweights(train,antlion_position(i,1:dim)',dim);
    [~,nn]=size(ntrain);
    if(nn==0)
        cost=1;
    else
        model = fitcknn(ntrain,label,'KFold',10,'NumNeighbors',antlion_position(i,dim+1)); %performing 10-fold cross validation
        cost = kfoldLoss(model);
    end
    antlions_fitness(1,i)=cost;
end

[sorted_antlion_fitness,sorted_indexes]=sort(antlions_fitness);

for newindex=1:N
     Sorted_antlions(newindex,:)=antlion_position(sorted_indexes(newindex),:);
end
    
Elite_antlion_position=Sorted_antlions(1,:);
Elite_antlion_fitness=sorted_antlion_fitness(1);

ConCurve(1)=Elite_antlion_fitness;

Current_iter=2; 
while Current_iter<Max_iter+1
    Current_iter
    for i=1:size(antlion_position,1)
        Rolette_index=RWS(sorted_antlion_fitness);
        if Rolette_index==-1  
            Rolette_index=1;
        end
       
        RA=RWalks(dim+1,Max_iter,lb,ub, Sorted_antlions(Rolette_index,:),Current_iter);
       
        RE=RWalks(dim+1,Max_iter,lb,ub, Elite_antlion_position(1,:),Current_iter);
        ant_position(i,:)=BLX(dim+1,RA(Current_iter,:),RE(Current_iter,:),lb,ub);
    end
    for i=1:size(ant_position,1)
        Flag4ub=ant_position(i,:)>ub;
        Flag4lb=ant_position(i,:)<lb;
        ant_position(i,:)=(ant_position(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;    
        ntrain=calcweights(train,ant_position(i,1:dim)',dim);
        [~,nn]=size(ntrain);
        if(nn==0)
            cost=1;
        else
            model = fitcknn(ntrain,label,'KFold',10,'NumNeighbors',ant_position(i,dim+1));
            cost =kfoldLoss(model);
        end
        ants_fitness(i)=cost;
    end

    double_population=[Sorted_antlions;ant_position];
    double_fitness=[sorted_antlion_fitness ants_fitness];
    
    [double_fitness_sorted,I]=sort(double_fitness);
    double_sorted_population=double_population(I,:);
        
    sorted_antlion_fitness=double_fitness_sorted(1:N);
    Sorted_antlions=double_sorted_population(1:N,:);
        
    Elite_antlion_position=Sorted_antlions(1,:);
    Elite_antlion_fitness=sorted_antlion_fitness(1);
        
    ConCurve(Current_iter)=Elite_antlion_fitness;
    Current_iter=Current_iter+1;
end
GlobalBest.Cost=Elite_antlion_fitness;
GlobalBest.Post=Elite_antlion_position;
end