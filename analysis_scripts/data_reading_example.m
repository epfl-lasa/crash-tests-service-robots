% Short script for reading and plotting collisions of a given location on
% the dummy side.
% Author: Diego F. Paez G.
% Date: 17 Mar 2021

% Configuration: 
% Clone the repository:
%  git clone https://github.com/epfl-lasa/service_robots_collisions.git
%  git checkout -b new_branch

%% Script for gettinng standard Injury Metrics
 % Load paths and data
        clearvars; close all; clc; 
        [parentdir,~,~]=fileparts(pwd);
        [maindir,~,~]=fileparts(parentdir);
        % Folders Configuration 
        outputPath = fullfile(maindir,'collision_data', 'data_metrics');
        addpath(fullfile(maindir,'collision_data','data_metrics'));
        addpath(fullfile(maindir,'collision_data','data_raw'));
        addpath(fullfile(parentdir, 'general_functions'));%
        addpath(fullfile(parentdir, 'analysis_scripts'));%
        addpath(fullfile(parentdir, 'collision_models'));%
        figPath = fullfile(parentdir, 'figures/');

%        data_folder = (fullfile(maindir,'collision_data','data_raw'));

    %% Options    
        DRAW_PLOTS = true;
        SAVE_PLOTS = false;
        SAVE_VIDEO = false;
        READDATA   = false;
        nfig=1;
        
        PicSize = [10 10 780 480];
        FaceALphas = 0.18;
        FontSizes = 24;
        MarkersSizes = 14;
        LinesWidths = 2.8;
        figureFormat = 'epsc';%'png';
        Fonts = 'Times New Roman';
        load('ColorsData'); 
        
    %% Load Data-set of Collisions   
        % Calling data of injury from AIS car crashing
        % lading crash tests:
        load('Q3_raw_collision_struct.mat')
        load('H3_raw_collision_struct.mat')
        load('filtered_collision_struct.mat')
        data_q3 = [1:10,16:19];
        
        q3_testNames = [{'Thorax-$1.0m/s$'}... $test_1
                     {'Thorax-$1.5m/s$'}... $test_2
                     {'Thorax-$3.1m/s$'}... $test_3
                     {'Thorax-$3.2m/s$'}... $test_4
                     {'Head-$1.0m/s$'}... $test_5
                     {'Head-$1.5m/s$'}... $test_6
                     {'Head-$3.1m/s$'}... $test_7
                     {'Tibia-$1.0m/s$'}... $test_8
                     {'Tibia-$1.5v$'}... $test_9
                     {'Tibia-$3.1m/s$'}... $test_10
                     {'Thorax-$1.0m/s ^*$'}... $test_16
                     {'Thorax-$1.5m/s ^*$'}... $test_17
                     {'Thorax-$3.1m/s ^*$'}... $test_18
                     {'Thorax-$3.0m/s ^*$'}... $test_19
                    ...
                    ];
        Q3.testSpeed = [1.0 1.5 3.1 3.2 ...
                        1.0 1.5 3.1...
                        1.0 1.5 3.1...
                        1.0 1.5 3.1 3.0...
                        ];
        Q3.testMass = [133 133 133 133 ...
                        133 133 133 ...
                        133 133 133 ...
                        60  60  60  60 ...
                        ];
        data_h3 = 11:15;
        
        h3_testNames = [{'1-$133kg$, $1.0ms^{-1}$'}...
                         {'2-$133kg$, $1.5ms^{-1}$'}...
                         {'3-$133kg$, $3.1ms^{-1}$'}...
                         {'4-$133kg$, $3.1ms^{-1}$'}... %SUCCESFULL IMPACT
                         {'5-$133kg$, $3.1ms^{-1}$'}...
                         ];
         H3.testSpeed = [1.0 1.5 3.1 3.1 3.1];
         H3.testMass = [133 133 133 133 133];
        % Constants from the current dataset
        Freq = 20000;
        Ts = 1/Freq; % Sampling period in [s]
        
        groundTimes = [...
                          640; %1
                          596;
                          449;
                          459;
                          653; %5
                          648;  
                          670;
                          1002;
                          1034;
                          1255;  %10
                          1630;
                          1428;
                          0;    %13
                          1654; %14
                          0;    %15
                          685;  %16
                          555;
                          489;
                          467;
                            ];
        h3_groundTimes = [...
                          1630; %11
                          1428; %12
                          0;    %13
                          1654; %14
                          0;    %15
                          ];     
     
        %% Data Structure short explanation:
        
        % Head Acceleration (norm of 3-d accelerations) areas = sqrt(ax^2+ay^2+az^2)
        % data_raw_Q3.test_7.head.areas
        % Impact Force measured at the robot (Fx is the frontal force)
        % data_filtered.test_7.impact.Fx
        
        %% =================== DATA VISUALIZATION =================== %
        if DRAW_PLOTS
            % ======================= Setup B ========================== %
            % ---------- Robot Mass = 133 kg / impact at head --------- %
            
            % ---------- Impact Force Data --------- %
            minTime = -5;
            maxTime = 50;
            minY = -10;
            maxY = 5000;
            AxisPlots = [minTime maxTime minY maxY];
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_5.time>200,1); %length(data_raw.test_5.time) ;
            plot_range = find(data_filtered.test_1.time>minTime,1):find(data_filtered.test_1.time>maxTime,1);
            plotNpairedData(nfig,[data_filtered.test_5.time(plot_range) ...
                                    data_filtered.test_6.time(plot_range) ...
                                    data_filtered.test_7.time(plot_range) ],...
                                [data_filtered.test_5.impact.Fx(plot_range) ...
                                    data_filtered.test_6.impact.Fx(plot_range)...
                                    data_filtered.test_7.impact.Fx(plot_range)],...
                                '-','Impact-Q3-Head-Robot [133Kg]',{'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                                'time [ms]','Head Impact Force [N]',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);
            
            % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 0;
            maxY = 200;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Head-Acceleration-Impact-Q3-Head-Robot[133Kg]';
            plegends = {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'};
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_1.time>200,1);
            plot_range = find(data_raw_Q3.test_1.time>minX,1):...
                                find(data_raw_Q3.test_1.time>maxX,1);
            plotNpairedData(nfig,[data_raw_Q3.test_5.time(plot_range) ...
                                    data_raw_Q3.test_6.time(plot_range) ...%                                 data_raw.test_3.time(plot_range) ...
                                    data_raw_Q3.test_7.time(plot_range) ],...
                                [data_raw_Q3.test_5.head.areas(plot_range) ...
                                    data_raw_Q3.test_6.head.areas(plot_range)...%                                 data_raw.test_3.head.ay(plot_range)...
                                    data_raw_Q3.test_7.head.areas(plot_range)],...
                                '-',figName,...
                                {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                                'time [ms]','Acceleration [g]',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);  
                            
            
            % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 20;
            maxY = -160;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Head-Acceleration-ax-Impact-Q3-Head-Robot[133Kg]';
            plegends = {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'};
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_1.time>200,1);
            plot_range = find(data_raw_Q3.test_1.time>minX,1):...
                                find(data_raw_Q3.test_1.time>maxX,1);
            plotNpairedData(nfig,[data_raw_Q3.test_5.time(plot_range) ...
                                    data_raw_Q3.test_6.time(plot_range) ...%                                 data_raw.test_3.time(plot_range) ...
                                    data_raw_Q3.test_7.time(plot_range) ],...
                                [data_raw_Q3.test_5.head.ax(plot_range) ...
                                    data_raw_Q3.test_6.head.ax(plot_range)...%                                 data_raw.test_3.head.ay(plot_range)...
                                    data_raw_Q3.test_7.head.ax(plot_range)],...
                                '-',figName,...
                                {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                                'time [ms]','Acceleration Ax [g]',SAVE_PLOTS,figPath,...
                                figureFormat);  

             % ---------- Head Acceleration Data --------- %
            minX = -5;
            maxX = 50;
            minY = 20;
            maxY = -200;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Head-Acceleration-ay-Impact-Q3-Head-Robot[133Kg]';
            plegends = {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'};
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_1.time>200,1);
            plot_range = find(data_raw_Q3.test_1.time>minX,1):...
                                find(data_raw_Q3.test_1.time>maxX,1);
            plotNpairedData(nfig,[data_raw_Q3.test_5.time(plot_range) ...
                                    data_raw_Q3.test_6.time(plot_range) ...%                                 data_raw.test_3.time(plot_range) ...
                                    data_raw_Q3.test_7.time(plot_range) ],...
                                [data_raw_Q3.test_5.head.ay(plot_range) ...
                                    data_raw_Q3.test_6.head.ay(plot_range)...%                                 data_raw.test_3.head.ay(plot_range)...
                                    data_raw_Q3.test_7.head.ay(plot_range)],...
                                '-',figName,...
                                {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                                'time [ms]','Acceleration Ay [g]',SAVE_PLOTS,figPath,...
                                figureFormat);  
                                               
        end       