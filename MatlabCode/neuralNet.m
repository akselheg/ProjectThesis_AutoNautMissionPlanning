function [net, performance, e, tr] = neuralNet(x,t,nh)
% Solve an Input-Output Fitting problem with a Neural Network
% Script generated by Neural Fitting app
% Created 28-Oct-2020 11:02:22
%
% This script assumes these variables are defined:
%
%   nninputs - input data.
%   sog_data - target data.

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.

trainFcn = 'trainlm';

% Create a Fitting Network
hiddenLayerSize = nh;
net = fitnet(hiddenLayerSize,trainFcn);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;

net.divideParam.valRatio = 15/100;

net.divideParam.testRatio = 15/100;
% Train the Network

[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y);

% View the Network
%view(net)
% Plots 
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotfit(net,x,t)
end


