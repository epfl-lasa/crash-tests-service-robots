% Script for reading and plotting collision models at specific pedestrian locations.
% Author: Diego F. Paez G.
% Date: 17 Mar 2021

% Configuration: 
% Clone the repository:
%  git clone https://github.com/epfl-lasa/service_robots_collisions.git
%  git checkout -b new_branch
    
    %% Load paths and data
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
        
    % Options
        global DEBUG_FLAG;
        DEBUG_FLAG=true;
        DRAW_PLOTS = false;
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
        
    % Load Data-set of Collisions
        % Calling data of injury from AIS car crashing lading crash tests:
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
        g_const = 9.81;
        
	% Data Structure short explanation:

        % Head Acceleration (norm of 3-d accelerations) areas = sqrt(ax^2+ay^2+az^2)
        % data_raw_Q3.test_7.head.areas
        % Impact Force measured at the robot (Fx is the frontal force)
        % data_filtered.test_7.impact.Fx

        % Data taken from Crash report - manually labeled the start of
        % contact on the ground;
        % [1]'Test_01_Q3-Ribcage' [1.0m/s]
        % [2]'Test_02_Q3-Ribcage' [1.5m/s]
        % [3]'Test_03-2_Q3-Ribcage' [3.1m/s]
        % [4]'Test_03_Q3-Ribcage_FAILED' [3.2m/s]
        % [5]'Test_04_Q3-Head' [1.0m/s]
        % [6]'Test_05_Q3-Head' [1.5m/s]
        % [7]'Test_06_Q3-Head' [3.1m/s]
        % [8]'Test_07_Q3-Legs' [1.0m/s]
        % [9]'Test_08_Q3-Legs' [1.5m/s]
        % [10]'Test_09_Q3-Legs' [3.1m/s]
        %[16]'Test_13_Q3-Ribcage' [1.0m/s]
        %[17]'Test_14_Q3-Ribcage' [1.5m/s]
        %[18]'Test_15-2_Q3-Ribcage' [3.1m/s]
        %[19]'Test_15_Q3-Ribcage_FAILED' [3.0m/s]
      
        
%% DATA VISUALIZATION 

        if DRAW_PLOTS
            % ======================= Setup A-A2 ========================== %
            % ---------- Robot Mass = 133 kg / impact at head --------- %
            % Figure of Force Impact
            nfig = nfig+1
            figName = 'Impact-Q3-Chest-Robot[133Kg]';
            minTime = -5;
            maxTime = 100;
            minY = -10;
            maxY = 1500;
            plegend = {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'};
            AxisPlots = [minTime maxTime minY maxY];
    %         plot_range = 1:find(data_raw.test_1.time>200,1);
            plot_range = find(data_filtered.test_1.time>minTime,1):find(data_filtered.test_1.time>maxTime,1);
            plotNpairedData(nfig,[data_filtered.test_1.time(plot_range) ...
                                    data_filtered.test_2.time(plot_range) ...
                                    data_filtered.test_3.time(plot_range) ... % data_filtered.test_4.time(plot_range)
                                    ],...
                                [data_filtered.test_1.impact.Fx(plot_range) ...
                                    data_filtered.test_2.impact.Fx(plot_range)...
                                    data_filtered.test_3.impact.Fx(plot_range)... %data_filtered.test_4.impact.Fx(plot_range)
                                    ],...
                                '-',figName,plegend,...
                                'time [ms]','Chest Impact Force [N]',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);
            hold on;
            plotNpairedData(nfig,...
                            [data_filtered.test_16.time(plot_range) ...
                                data_filtered.test_17.time(plot_range)...
                                data_filtered.test_18.time(plot_range)],...
                            [data_filtered.test_16.impact.Fx(plot_range) ...
                                data_filtered.test_17.impact.Fx(plot_range) ...
                                data_filtered.test_18.impact.Fx(plot_range) ],...
                            '--',figName,plegend,...
                            'time [ms]','Force [N]',false,figPath,...
                            figureFormat,AxisPlots);
            hold on;
            dim_ann = [0.65 0.1 0.3 0.3]; % [x y w h]
            str_ann = {'Solid lines = 133kg robot','Dotted lines = 60kg robot'};
            annotation('textbox',dim_ann,'String',str_ann,'FitBoxToText','on',...
                           'FontName','TimesNewRoman','FontSize',16);
            
            if SAVE_PLOTS       
                set(gcf, 'Position', [10 10 680 1080]);
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
                saveas(FigureNumber,'Name','epsc');
                saveas(nfig,strcat(figPath,figName,'_V'),figureFormat);
            end
            
            % ---------- Thorax Acceleration Data --------- %
            minX = -5;
            maxX = 100;
            minY = 0;
            maxY = 30;
            AxisPlots = [minX maxX minY maxY];
            figName = 'Thorax-Acceleration-Q3-Chest-Robot[133Kg]';
            plegends = {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'};
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_1.time>200,1);
            plot_range = find(data_raw_Q3.test_1.time>minX,1):...
                                find(data_raw_Q3.test_1.time>maxX,1);
            plotNpairedData(nfig,[data_raw_Q3.test_1.time(plot_range) ...
                                    data_raw_Q3.test_2.time(plot_range) ...%                                 data_raw.test_3.time(plot_range) ...
                                    data_raw_Q3.test_3.time(plot_range)...
                                    ],...
                                [data_raw_Q3.test_1.thorax.areas(plot_range) ...
                                    data_raw_Q3.test_2.thorax.areas(plot_range)...%                                 data_raw.test_3.head.ay(plot_range)...
                                    data_raw_Q3.test_3.thorax.areas(plot_range)...
                                    ],...
                                '-',figName,...
                                plegends,...
                                'time [ms]','Acceleration [g]',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);  
             hold on;
            plotNpairedData(nfig,...
                            [data_raw_Q3.test_16.time(plot_range) ...
                                data_raw_Q3.test_17.time(plot_range) ...%                                 data_raw.test_3.time(plot_range) ...
                                data_raw_Q3.test_18.time(plot_range)...
                                ],...
                            [data_raw_Q3.test_16.thorax.areas(plot_range) ...
                                    data_raw_Q3.test_17.thorax.areas(plot_range)...%                                 data_raw.test_3.head.ay(plot_range)...
                                    data_raw_Q3.test_18.thorax.areas(plot_range)...
                                ],...
                            '--',figName,plegends,...
                            'time [ms]','Acceleration [g]',false,figPath,...
                            figureFormat,AxisPlots);
            hold on;
            dim_ann = [0.65 0.1 0.3 0.3]; % [x y w h]
            str_ann = {'Solid lines = 133kg robot','Dotted lines = 60kg robot'};
            annotation('textbox',dim_ann,'String',str_ann,'FitBoxToText','on',...
                           'FontName','TimesNewRoman','FontSize',16);
            
            if SAVE_PLOTS       
                set(gcf, 'Position', [10 10 680 1080]);
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
                saveas(nfig,strcat(figPath,figName,'_V'),figureFormat);
            end
            
            % Figure of Chest-Defelction vs. Forces
            figName = 'pAIS-Q3-Chest-Robot-Force';
            minX = 0;
            maxX = 35;
            minY = 0;
            maxY = 1500;
            AxisPlots = [minX maxX minY maxY];
            
            nfig = nfig +1;
            plot_range = find(data_filtered.test_1.time>-5,1):find(data_filtered.test_1.time>100,1);
            plotNpairedData(nfig,...
                                [data_filtered.test_1.thorax.deflection(plot_range) ...
                                    data_filtered.test_2.thorax.deflection(plot_range)...
                                    data_filtered.test_3.thorax.deflection(plot_range)],...
                                [data_filtered.test_1.impact.Fx(plot_range) ...
                                    data_filtered.test_2.impact.Fx(plot_range) ...
                                    data_filtered.test_3.impact.Fx(plot_range) ],...
                                '-',figName,{'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                                'Chest Deflection [mm]','Force [N]',false,figPath,...
                                figureFormat,AxisPlots);
                % Probability of AIS+3 > 20%
                
%                 xPose = (-Q3eevcL.CC)./(AxisPlots(1)-AxisPlots(2)) - 0.082;
%                 arrowX = [xPose-0.05 xPose]; % [y1 y2]
%                 arrowY = [0.25 0.3]; % [x1 x2]
%                 str_ann = ['p(AIS+3)=' , num2str(round(Q3eevcL.pAIS*100)),'%'];
%                 annotation('textarrow',arrowX,arrowY,'String',str_ann,...
%                            'FontName','TimesNewRoman','FontSize',16); 
                            
            hold on;
            plotNpairedData(nfig,...
                                [data_filtered.test_16.thorax.deflection(plot_range) ...
                                    data_filtered.test_17.thorax.deflection(plot_range)...
                                    data_filtered.test_18.thorax.deflection(plot_range)],...
                                [data_filtered.test_16.impact.Fx(plot_range) ...
                                    data_filtered.test_17.impact.Fx(plot_range) ...
                                    data_filtered.test_18.impact.Fx(plot_range) ],...
                                '--',figName,{'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                                'Chest Deflection [mm]','Impact Force [N]',false,figPath,...
                                figureFormat,AxisPlots);
            hold on;
            dim_ann = [0.15 0.5 0.3 0.3]; % [x y w h]
            str_ann = {'Solid lines = 133kg robot','Dotted lines = 60kg robot'};
            annotation('textbox',dim_ann,'String',str_ann,'FitBoxToText','on',...
                           'FontName','TimesNewRoman','FontSize',16); 
                       
                       
            if SAVE_PLOTS       
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
                saveas(nfig,strcat(figPath,figName),figureFormat);
            end
            
            hold off;
            
            % ======================= Setup B ========================== %
            % ---------- Head Impact --------- %
            % ---------- Robot mass: 133 kg --------- %
            
            minTime = -5;
            maxTime = 200;
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
                                figureFormat);
            
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
        
            
            % ======================= Setup C ========================== %
            % % % Robot Mass = 133 kg / impact at legs (tibia-fibia) 
            minTime = -5;
            maxTime = 60;
            minY = -10;
            maxY = 2500;
            AxisPlots = [minTime maxTime minY maxY];
            nfig = nfig +1;
    %         plot_range = 1:find(data_raw.test_8.time>200,1); %lengths(data_raw.test_5.time) ;
            plotNpairedData(nfig,[data_filtered.test_8.time(plot_range) ...
                                    data_filtered.test_9.time(plot_range) ...
                                    data_filtered.test_10.time(plot_range) ],...
                                [data_filtered.test_8.impact.Fx(plot_range) ...
                                    data_filtered.test_9.impact.Fx(plot_range)...
                                    data_filtered.test_10.impact.Fx(plot_range)],...
                                '-','Impact-Q3-Legs-Robot [133Kg]',{'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                                'time [ms]','Legs Impact Force [N]',SAVE_PLOTS,figPath,...
                                figureFormat,AxisPlots);
                        
        end
        

%%  *MODEL BASED IMPACT FORCE SIMULATION*
% Getting Model-based response from [Vemula2018] 
% 
% Previous work [Haddadin2009] assummed a Hunt-Crossley Model but it was shown 
% to be very limited fitting.
% 
% This model applies only in the case of a free-floating body (head impact on 
% short-time window, and perhaps limbs)
% 
% Vemula, B. R., Ramteen, M., Spampinato, G., & Fagerström, B. (2018). Human-robot 
% impact model: For safety assessment of collaborative robot design. _Proceedings 
% - 2017 IEEE 5th International Symposium on Robotics and Intelligent Sensors, 
% IRIS 2017_, _2018_-_Janua_, 236–242. https://doi.org/10.1109/IRIS.2017.8250128

% Based on ISO/TS 15066 for 75 kg
    mass_adult = [
        40 	   % chest
        40 	   % belly
        40 	   % pelvis
        75  % upper legs    <-- Previous implementation was different
        75  % shins         <-- Previous implementation was different
        75  % ankles/feet (Same as shin)    <-- Previous implementation was different
        3   % upper arms
        2   % forearms
        0.6  % hands
        1.2 	   % neck
        8.8 	   % head + face (?)
        75  % soles (Same as shin)  <-- Previous implementation was different
        75     % toes (Same as shin)   <-- Previous implementation was different
        40	   % chest (back)
        40	   % belly (back)
        40	   % pelvis (back)
        1.2	   % neck (back)
        4.4	   % head (back)
    ];
    
    eff_spring_const_human = [
        25	 % chest
        10	 % belly
        25	 % pelvis
        50% upper legs
        60 % shins
        75 % ankles/feet (Same as shin)    <-- From Previous implementation
        30% upper arms    <-- Previous implementation was different
        40 % forearms      <-- Previous implementation was different
        75 % hands
        50	 % neck
        150	 % head (face ?)
        75 % soles (Same as shin)  <-- From Previous implementation
        75 % toes (Same as shin)   <-- From Previous implementation
        35	 % chest (back)
        35	 % belly (back)
        35	 % pelvis (back)
        50	 % neck (back)
        150	 % head (back)
    ] .*1e3;
    
    elastic_mod_human_adult = [
        7.44	   % chest
        7.44	   % belly
        11	   % pelvis
        17.1   % upper legs    <-- Previous implementation was different
        0.634    % shins         <-- Previous implementation was different
        0.634    % ankles/feet (Same as shin)    <-- Previous implementation was different
        33     % upper arms
        22     % forearms
        0.6 % hands
        6.5	   % neck
        6.5	   % head + face (?)
        0.634   % soles (Same as shin)  <-- Previous implementation was different
        0.634   % toes (Same as shin)   <-- Previous implementation was different
        7.44	   % chest (back)
        7.44	   % belly (back)
        11	   % pelvis (back)
        6.5	   % neck (back)
        6.5	   % head (back)
    ] .*1e9;
    
    human_radius_adult = [
        0.27	   % chest
        0.25	   % belly
        0.21	   % pelvis
        0.07    % upper legs    <-- Previous implementation was different
        0.039    % shins         <-- Previous implementation was different
        0.034   % ankles/feet (Same as shin)    <-- Previous implementation was different
        0.06      % upper arms
        0.03      % forearms
        0.6  % hands
        0.09	   % neck
        0.1	   % head + face (?)
        0.04   % soles (Same as shin)  <-- Previous implementation was different
        0.04   % toes (Same as shin)   <-- Previous implementation was different
        0.27	   % chest (back)
        0.25	   % belly (back)
        0.21	   % pelvis (back)
        0.09	   % neck (back)
        0.1	   % head (back)
    ];
    
    mass_robot = [
        55.5  % Main Body
        1.5 % Left Wheel
        1.5 % Right Wheel
        1.5 % Bumper
    ];
    driver_mass = 73.0;
    
    eff_spring_const_robot = [
        10 % Main Body
        1  % Left Wheel
        1  % Right Wheel
        10 % Bumper
    ] .* 1e3;
    
%% ############# Main Simulation Loop ################
% ######################################################################
    %%%%%%%% Filling simulation parameters:
    % Getting mechanical data of the robots and tests setup (sizes, elastic modulus, and masses)
    robot_mechanical_properties;
    
    close all; clc;
    clear robot human ColModel deformation state Khr Fext timeVec
    nfig =nfig+4;
    DEBUG_FLAG = false;
    
    % Simulation method for the collision
    method.condition = 'unconstrained';
    method.contact = 'HCF'; %'CCF' or 'HCF'
    % % % EA =EB = 2.3e9
    method.time = 15; % time in ms
    method.tstep= 0.01; % time in ms
    state.pos = 0.0; state.acc = 0.0;

    % Parameters for HCF Model
    robot.n_cs = 1.65; %% Coefficient --> To be determine
    robot.n_cb = 1.8; %% Coefficient --> To be determine
    robot.n_rb = 2.65; %% Coefficient --> To be determine
    human.limit_def = 0.8; %% Coefficient --> To be determine
    robot.limit_def = 0.8; %% Coefficient --> To be determine
    
    % Parameters for CCF Model
    robot.n_d = 1.5; % Hertzian Deformation exponential
    human.n_s = 1.5; % Skin Deformation exponential
    robot.n_c = 1.5; % Robot cover Deformation exponential
    human.n_f = 0.9; % human differential deformation
    robot.n_f = 0.8; % robot differential deformation
    robot.xgainA = 2;
    human.xgainB = 1;
    robot.EA = 1.0e9; %% Fitted Gain --> To be determine
    human.EB = 1.0e9; %% Fitted Gain --> To be determine
    human.cover_width = 0.003;

    for j_test=[15,17,19,26,27,31]
        % For Test with Manipulator:
        manipulator_robot = manipulator_data{j_test};
        adult_human.human_radius_head = manipulator_data{j_test}.head_radius;
        state.vel = manipulator_robot.speed; % initial Speed
        robot.part = manipulator_robot.part; 
        human.part = 'head_adult'; % For collision data    
        manipulator_data{j_test}.colModel = contact_simulation(state,robot,human,method);
    end
    nfig = 6;
    
    %% Debugging ODE:
        j_test = 19
        nfig = nfig+1;
        figName = 'Manipulators-1-Contact_deformation';
        plegends = {'pos', 'vel', 'acc'};%, 'pos', 'vel'};
        AxisPlots = [0 method.time -100 15000];
        plotNpairedData(nfig,[manipulator_data{j_test}.colModel.timeVec,...
                                manipulator_data{j_test}.colModel.timeVec...
                                manipulator_data{j_test}.colModel.timeVec ... 
%                                 manipulator_data{15}.colModel.timeVec ... 
                                ],...
                            [manipulator_data{j_test}.colModel.deformation.pos,...
                                    manipulator_data{j_test}.colModel.deformation.vel...
                                    manipulator_data{j_test}.colModel.deformation.acc...
%                                     manipulator_data{15}.colModel.deformation.pos, ...
%                                     manipulator_data{15}.colModel.deformation.vel ...
                                ],...
                            '-',figName,plegends,...
                            'time [ms]','Deformation [x] / [dx/dt]'...
                            ,false,figPath,figureFormat...%                             ,AxisPlots...
                            );
	         %
         nfig = nfig+1;
        figName = 'Manipulators-1-Contact_Force';
        plegends = {'K_{hr}'};
        AxisPlots = [0 method.time.*1e-3 -5e7 5e7];
        plotNpairedData(nfig,[manipulator_data{j_test}.colModel.timeVec...
                                ],...
                            [manipulator_data{j_test}.colModel.Khr,...
                                ],...
                            '-',figName,plegends,...
                            'time [s]','Head Impact Force [N]'...
                            ,false,figPath,figureFormat...
                            ,AxisPlots...
                            );        
        nfig = nfig+1;
        figName = 'Manipulators-1-Contact_Force';
        plegends = {'Fext'};
        AxisPlots = [0 method.time.*1e-3 -100 20000];
        plotNpairedData(nfig,[manipulator_data{j_test}.colModel.timeVec...
                                ],...
                            [-manipulator_data{j_test}.colModel.Fext...
                                ],...
                            '-',figName,plegends,...
                            'time [s]','Head Impact Force [N]'...
                            ,false,figPath,figureFormat... %,AxisPlots...
                            );
        
                        
%%
    %      % Plotting Comparative Data for Manipulator Tests - 15, 17 and 19
        nfig = nfig+1;
        figName = 'Manipulators-1-Contact_Force';
        plegends = {'Exp.15', 'Exp.17', 'Exp.19'};
        AxisPlots = [0 method.time.*1e-3 -100 15000];
        plotNpairedData(nfig,[manipulator_data{15}.colModel.timeVec,...
                                manipulator_data{17}.colModel.timeVec,...
                                manipulator_data{19}.colModel.timeVec ... 
                                ],...
                            [-manipulator_data{15}.colModel.Fext,...
                                    -manipulator_data{17}.colModel.Fext,...
                                    -manipulator_data{19}.colModel.Fext ...
                                ],...
                            '-',figName,plegends,...
                            'time [s]','Head Impact Force [N]'...
                            ,false,figPath,figureFormat...
                            ,AxisPlots...
                            );
        
        nfig = nfig+1;
        figName = 'Manipulators-1-Stress';
        plegends = {'Exp.15', 'Exp.17', 'Exp.19'};
        AxisPlots = [0 method.time.*1e-3 0 15];
        plotNpairedData(nfig,[manipulator_data{15}.colModel.timeVec,...
                                manipulator_data{17}.colModel.timeVec,...
                                manipulator_data{19}.colModel.timeVec ... 
                                ],...
                            [-manipulator_data{15}.colModel.body_stress,...
                                    -manipulator_data{17}.colModel.body_stress,...
                                    -manipulator_data{19}.colModel.body_stress ...
                                ],...
                            '-',figName,plegends,...
                            'time [s]','Compressive Stress [MPa]'...
                            ,false,figPath,figureFormat...%                             ,AxisPlots...
                            );
        nfig = nfig+1;
        figName = 'Manipulators-1-Deformation';
        plegends = {'Exp.15', 'Exp.17', 'Exp.19'};
        AxisPlots = [0 method.time.*1e-3 0 15];
        plotNpairedData(nfig,[manipulator_data{15}.colModel.timeVec,...
                                manipulator_data{17}.colModel.timeVec,...
                                manipulator_data{19}.colModel.timeVec ... 
                                ],...
                            [manipulator_data{15}.colModel.deformation.pos,...
                                    manipulator_data{17}.colModel.deformation.pos,...
                                    manipulator_data{19}.colModel.deformation.pos ...
                                ],...
                            '-',figName,plegends,...
                            'time [s]','Deformation [m]'...
                            ,false,figPath,figureFormat...%                             ,AxisPlots...
                            );
%%                        
%      % Plotting Comparative Data for Manipulator Tests - 16, 27, 31
        nfig = nfig+1;
        figName = 'Manipulators-2-Contact_Force';
        plegends = {'Exp.26', 'Exp.27', 'Exp.31'};
        AxisPlots = [0 method.time.*1e-3 -100 12000];
        plotNpairedData(nfig,[manipulator_data{26}.colModel.timeVec,...
                                manipulator_data{27}.colModel.timeVec,...
                                manipulator_data{31}.colModel.timeVec ... 
                                ],...
                            [-manipulator_data{26}.colModel.Fext,...
                                    -manipulator_data{27}.colModel.Fext,...
                                    -manipulator_data{31}.colModel.Fext ...
                                ],...
                            '-',figName,plegends,...
                            'time [s]','Head Impact Force [N]'...
                            ,false,figPath,figureFormat...
                            ,AxisPlots...
                            );

    %%
    % % %  % Plotting Comparative Data for Mobile service robot tests % % %
    minTime = 0;
    maxTime = 15;
    
    for j_test=1:4
        % For Test Data from Mobile Service Robots:
        qolo_robot = service_test{j_test};
        state.vel = qolo_robot.speed;
        robot.part = qolo_robot.part; 
        human.part = 'chest_child'; % For collision data
        service_test{j_test}.colModel = contact_simulation(state,robot,human,method);
    end
    
    for j_test=5:7
        % For Test Data from Mobile Service Robots: Head Impact Child dummy
        qolo_robot = service_test{j_test};
        state.vel = qolo_robot.speed;
        robot.part = qolo_robot.part; 
        human.part = 'head_child'; % For collision data
        service_test{j_test}.colModel = contact_simulation(state,robot,human,method);
        data_range =  eval(['find(data_raw_Q3.test_',num2str(j_test),'.time > minTime,1):find(data_raw_Q3.test_',num2str(j_test),'.time>maxTime,1);']);
%                 find(service_test{j_test}.data.time>minTime,1):find(service_test{j_test}.data.time>maxTime,1);
        service_test{j_test}.data.time = eval(['data_raw_Q3.test_',num2str(j_test),'.time(data_range)']);
        service_test{j_test}.data.acc = eval(['data_raw_Q3.test_',num2str(j_test),'.head.areas(data_range)']);
        
        service_test{j_test}.data.vel = cumtrapz(service_test{j_test}.data.time.*1e-3,service_test{j_test}.data.acc.*9.81);
        service_test{j_test}.data.pos = cumtrapz(service_test{j_test}.data.time.*1e-3,service_test{j_test}.data.vel);
        service_test{j_test}.data.Fext = eval(['data_filtered.test_',num2str(j_test),'.impact.Fx']);
    end

        % Head Impact : 
        nfig = nfig+1;
        figName = 'Q3_Model_Impact-Head_at_133kg';
        plegends = {'F_{e} 1.0m/s', 'F_{e} 1.5m/s', 'F_{e} 3.1m/s'};
        minTime = 0;
        maxTime = method.time;
        AxisPlots = [minTime maxTime -100 7000];
        plotNpairedData(nfig,[service_test{5}.colModel.timeVec.*1e3, ...
                                service_test{6}.colModel.timeVec.*1e3,...
                                service_test{7}.colModel.timeVec.*1e3 ... 
                                ],...
                            [-service_test{5}.colModel.Fext,...
                            -service_test{6}.colModel.Fext,...
                            -service_test{7}.colModel.Fext ...
                            ],...
                            '-',figName,plegends,...
                            'time [ms]','Head Impact Force [N]'...
                            ,false,figPath,figureFormat...
                            ,AxisPlots...
                            );
        hold on;
        % ---------- Head Impact --------- %
        % ---------- Robot mass: 133 kg --------- %
%         minTime = -5;
%         maxTime = 20;
%         minY = -10;
%         maxY = 5000;
%         AxisPlots = [minTime maxTime minY maxY];
%         plot_range = 1:find(data_raw.test_5.time>200,1); %length(data_raw.test_5.time);
        plot_range = find(data_filtered.test_1.time>minTime,1):find(data_filtered.test_1.time>maxTime,1);
        plotNpairedData(nfig,[data_filtered.test_5.time(plot_range) ...
                                data_filtered.test_6.time(plot_range) ...
                                data_filtered.test_7.time(plot_range) ],...
                            [data_filtered.test_5.impact.Fx(plot_range) ...
                                data_filtered.test_6.impact.Fx(plot_range)...
                                data_filtered.test_7.impact.Fx(plot_range)],...
                            '--',figName,plegends,...
                            'time [ms]','Head Impact Force [N]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        if SAVE_PLOTS       
            set(gcf,'PaperPositionMode','auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        hold off;
                        
        nfig = nfig+1;
        figName = 'ChildHead_at_133kg-Deformation';
        plegends = {'F_{e} 1.0m/s', 'F_{e} 1.5m/s', 'F_{e} 3.1m/s'};
        minTime = 0;
        maxTime = method.time;
        AxisPlots = [minTime maxTime -100 7000];
        plotNpairedData(nfig,[service_test{5}.colModel.timeVec.*1e3, ...
                                service_test{6}.colModel.timeVec.*1e3,...
                                service_test{7}.colModel.timeVec.*1e3 ... 
                                ],...
                            [service_test{5}.colModel.deformation.pos,...
                                    service_test{6}.colModel.deformation.pos,...
                                    service_test{7}.colModel.deformation.pos ...
                                ],...
                            '-',figName,plegends,...
                            'time [ms]','Deformation [m]'...
                            ,false,figPath,figureFormat...%                             ,AxisPlots...
                            );
        hold on;
%         plot_range5 = find(service_test{5}.data.time>minTime,1):find(service_test{5}.data.time>maxTime,1);
%         plot_range6 = find(service_test{6}.data.time>minTime,1):find(service_test{6}.data.time>maxTime,1);
%         plot_range7 = find(service_test{7}.data.time>minTime,1):find(service_test{7}.data.time>maxTime,1);
        
        plotNpairedData(nfig,[service_test{5}.data.time ...
                                service_test{6}.data.time ...
                                service_test{7}.data.time ],...
                            [service_test{5}.data.pos ...
                                service_test{6}.data.pos...
                                service_test{7}.data.pos],...
                            '--',figName,plegends,...
                            'time [ms]','Deformation [m]'...
                            ,false,figPath,figureFormat...%                             ,AxisPlots...
                            );
        hold on;
        if SAVE_PLOTS       
            set(gcf,'PaperPositionMode','auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        hold off;