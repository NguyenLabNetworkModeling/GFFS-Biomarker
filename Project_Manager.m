%% ML(17-AAG) project code

clear
close all
clc;


% Include dependencies
addpath('./lib'); % dependencies
addpath('./common files'); % FS methods
addpath(genpath('./packages'));
addpath('./Training dataset'); % FS methods
addpath('./results'); % FS methods

rootwd = pwd;

% Select a simulation tas from the list

listJob = {
    'model_train';      % (1)
    'model_valid';      % (2)
    'feature_select';   % (3)
    'signaure_analy';   % (4)
    'companion_marker'; % (5)
    'compact_marker';   % (6)
    'shuffle_test';     % (7)
    'prepare_valid';    % (8)
    'myTest'            % (9)
    };

[ jobID ] = readInput( listJob );
jobcode = listJob{jobID}; % Selected



Task_Manager

