% This is demo code to perform feature weighting using Ant Lion
% Optimization.

clear
clc
load('datasets/wine.mat')
Population=8;
Maximum_iterations=70;
[GlobalBest,ConCurve]=FW_ALO(train,label,Population,Maximum_iterations);
plot(ConCurve)