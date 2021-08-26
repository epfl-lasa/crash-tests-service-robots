
% Script for reading the analyzed data and orginizing it on a structure
% The metrics taken here were considered in accordance to dummies standarized 
% testing for pedestrian crash tests.
% Author: Diego F. Paez G.
% Date: 8 Dec 2020 --> 
% Copyright 2020, Dr. Diego Paez-G.

%% Script for extracting and plotting test data
    clearvars; close all; clc; 
    [parentdir,~,~]=fileparts(pwd);
    [maindir,~,~]=fileparts(parentdir);
    % Folders Configuration 
    saveDir = fullfile(maindir,'collision_data', 'data_raw');
    addpath(fullfile(parentdir, 'general_functions'));      
    % Set here the desired ooutput directory for saving the process dataset
    % Set here the path to the analysis dataset
    data_folder = fullfile('../../collision_data/', 'collision_test_analysis');
    %     data_folder = fullfile(parentdir, 'collision_test_analysis');
    test_folders = dir(fullfile(data_folder,'Test_*'))';
    
    metrics_Q3 = struct();
    metrics_H3 = struct();
    Freq = 20000;
    Ts = 1/Freq; % Sampling period in [s]
    data_filtered = struct();

    %% Options    
    DRAW_PLOTS = 1;
    SAVE_PLOTS = 0;
    SAVE_VIDEO = 0;
    READDATA = false;

    %% Read Raw data from .xlsx files
    if READDATA
        % Reading Q3 dummy data
        data_q3 = [1:10,16:19];
        for indx_i= data_q3
                metrics_Q3.(['test_',num2str(indx_i)]) = read_Q3data(test_folders(indx_i));
                metrics_Q3.(['test_',num2str(indx_i)]).TestName = test_folders(indx_i).name;
        end

        % Reading H3 dummy data
        for indx_i=11:15
                metrics_H3.(['test_',num2str(indx_i)]) = read_H3data(test_folders(indx_i));
                metrics_H3.TestName = test_folders(indx_i).name;
        end

        % Saving Data 
        save([data_folder,'/Q3_metrics.mat'],'metrics_Q3') 
        save([data_folder,'/H3_metrics.mat'],'metrics_H3') 
    else
        load('Q3_metrics.mat')
        load('H3_metrics.mat')
    end
    
    %% Readinng xls Files

function data = read_Q3data(test_folder)
        %READ_FT_DATA read data from test folder and store them in struct
        warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
        Ts = 1/20000;
        %         sheet_name = 'SAE-J211_Data';
        sheet_name = 'Grafiken';
        data_file = dir(fullfile(test_folder.folder, test_folder.name, ...
                        '01_values', '*.xlsx'))';

        data_file=data_file(1);
        tb = readtable(fullfile(data_file.folder, data_file.name),...
                            'ReadVariableNames',false,'Sheet',sheet_name,...
                            'Range','A65:B76');
        data = struct();
        data.('HIC15_robot')  = tb.Var2(1);
        data.('HIC15_ground')  = tb.Var2(2);
        data.('head_a_3ms')  = tb.Var2(3);
        data.('Neck')  = tb.Var2(5);
        data.('Nij')  = tb.Var2(6);
        data.('Thorax')  = tb.Var2(8);
        data.('ThCC')  = tb.Var2(9);
        data.('Thorax_a3ms')  = tb.Var2(10);
        data.('VC')  = tb.Var2(11);
        data.('CTI')  = tb.Var2(12);
        
        warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
end

function data = read_H3data(test_folder)
        %READ_FT_DATA read data from test folder and store them in struct
        warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
        Ts = 1/20000;
        %         sheet_name = 'SAE-J211_Data';
        sheet_name = 'Grafiken';
        data_file = dir(fullfile(test_folder.folder, test_folder.name, ...
                        '01_values', '*.xlsx'))';

        data_file=data_file(1);
        tb = readtable(fullfile(data_file.folder, data_file.name),...
                            'ReadVariableNames',false,'Sheet',sheet_name,...
                            'Range','A64:B81');

        data = struct();
        data.('HIC15_ground')  = tb.Var2(1);
        data.('TCFC_right')  = tb.Var2(11);
        data.('TCFC_left')  = tb.Var2(12);
        data.('TI_lower_right')  = tb.Var2(13);
        data.('TI_upper_right')  = tb.Var2(14);
        data.('TI_lower_left')  = tb.Var2(15);
        data.('TI_upper_left')  = tb.Var2(16);
        
        warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
end