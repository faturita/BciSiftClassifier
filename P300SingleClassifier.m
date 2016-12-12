%run('/Users/rramele/work/vlfeat/toolbox/vl_setup')
% P300 for ALS patients.
clear mex;clearvars;close all;clc;

% Clean all the directories where the images are located.
cleanimagedirectory();

load('/Users/rramele/GoogleDrive/BCI.Dataset/008-2014/A06.mat');

% NN.NNNNN
% data.X(sample, channel)
% data.y(sample)  --> 0: no, 1:nohit, 2:hit
% data.y_stim(sample) --> 1-12, 1-6 cols, 7-12 rows

%     'Fz'    'Cz'    'Pz'    'Oz'    'P3'    'P4'    'PO7'    'PO8'

% Parameters ==========================
epochRange = 1:4200;
epochRange = 1:600;
channelRange=2:2;
labelRange = zeros(1,4200);
imagescale=1;    % Para agarrar dos decimales NN.NNNN
siftscale=3;  % 2 mvoltios y medio.
siftdescriptordensity=1;
Fs=256;
length=1;
% =====================================




