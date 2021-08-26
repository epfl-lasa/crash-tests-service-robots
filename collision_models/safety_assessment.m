    % Short script fir simulating multiple parameter changes on the robot
    % desing and control
    % Author: Diego F. Paez G.
    % Date: 28 April 2021

%% Script for Fitting Injury Metrics through Contact Models
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
        
        
        global DUBUG_FLAG;
        DUBUG_FLAG=true;
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
                         {'4-$133kg$, $3.1ms^{-1}$'}... % SUCCESFULL IMPACT
                         {'5-$133kg$, $3.1ms^{-1}$'}...
                         ];
         H3.testSpeed = [1.0 1.5 3.1 3.1 3.1];
         H3.testMass = [133 133 133 133 133];
        % Constants from the current dataset
        Freq = 20000;
        Ts = 1/Freq; % Sampling period in [s]
        g_const = 9.81;
%% Data Structure short explanation:

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
      
%%  *MODEL BASED IMPACT FORCE SIMULATION*
% Getting Model-based response from [Vemula2018] 
% 
% Previous work [Haddadin2009 and Park.et.al.2011] assummed a Hunt-Crossley 
% Model.
% 
% This model applies only in the case of a free-floating body (head impact on 
% short-time window, and perhaps limbs)
% 
% Vemula, B. R., Ramteen, M., Spampinato, G., & Fagerström, B. (2018). Human-robot 
% impact model: For safety assessment of collaborative robot design. _Proceedings 
% - 2017 IEEE 5th International Symposium on Robotics and Intelligent Sensors, 
% IRIS 2017_, _2018_-_Janua_, 236–242. https://doi.org/10.1109/IRIS.2017.8250128

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

%% ########### Simulation and Fitting for HCF Model ############## 

    %%%%%%%% Filling simulation parameters: for HCF Model ############
    close all; clc;
    clear robot human ColModel deformation state Khr Fext timeVec
    nfig =1;
    DUBUG_FLAG = false;
    % Getting mechanical data of the robots and tests setup (sizes, elastic modulus, and masses)
    robot_mechanical_properties;
    
    sampDown = 1;
    % Simulation method for the collision
    method.condition = 'unconstrained';
    method.contact = 'Spring'; %'CCF' or 'HCF' or 'Spring'
    % % % EA =EB = 2.3e9
    method.time = 10; % time in ms
    method.tstep= 0.05 * sampDown; % time in ms
    state.pos = 0.0; state.acc = 0.0;
    
%     qolo_bumper or qolo_driver_bumper
    robot.part = 'qolo_driver_bumper'; 
    human.part = 'head_child'; % For collision data
    
    % Parameters for HCF Model
    robot.n_cs = 1.65;
    robot.n_cb = 1.8;
    robot.n_rb = 2.65;
    human.limit_def = 0.8;
    robot.limit_def = 0.8;
    
    % Parameters for CCF Model
    robot.n_d = 1.5;
    robot.n_s = 1.5;
    robot.n_c = 1.5;
    robot.n_f = 0.8;
    robot.xgainA = 2;
    robot.EA = 5.0e9; %% Fitted Gain --> To be determine
    human.EB = 2.0e9; %% Fitted Gain --> To be determine
    human.cover_width = 0.003;
    
    % Parameters for Spring-Model
    human.stiffness = 150 * 1e3; % N/m --> Skull
    
%     for j_test=5:7
%         % For Test Data from Mobile Service Robots:
%         qolo_robot = service_test{j_test};
%         state.vel = qolo_robot.speed;
%         robot.part = qolo_robot.part; 
%         human.part = 'head_child'; % For collision data
%         service_test{j_test}.colModel = contact_simulation(state,robot,human,method);
%         figure;
%         plot(service_test{j_test}.colModel.timeVec,-service_test{j_test}.colModel.Fext)
%     end     
    j_test = 5;
    vel_0 = service_test{j_test}.speed;
    timeVec = [0:method.tstep:method.time]';
    variable_set = 150*1e3;
%     variable_set = [...
%                     1.65; %     robot.n_cs = 1.65;
%                     1.8; %     robot.n_cb = 1.8;
%                     2.65; %     robot.n_rb = 2.65;
%                     ];
%                     0.003; %     human skin thickness = 0.003
%                     0.8; %     robot.limit_def = 0.8;
%                     0.8; %      human.limit_def = 0.8;
%                     ];
    Fext = collision_sim(vel_0,timeVec,variable_set,robot,human,method);
    
    % Testing the new collision models for fitting
    figure;
    plot(timeVec,Fext)
    hold on;
    figure;
    minTime = timeVec(1); maxTime = timeVec(end);
    
    % Data to be fitted and downsampled: 
    plot_range5 = find(data_filtered.test_5.time>minTime,1):...
                        find(data_filtered.test_5.time>maxTime,1);
    plot_range6 = find(data_filtered.test_6.time>minTime,1):...
                        find(data_filtered.test_6.time>maxTime,1);
    plot_range7 = find(data_filtered.test_7.time>minTime,1):...
                        find(data_filtered.test_7.time>maxTime,1);

    timeSet = downsample([data_filtered.test_5.time(plot_range5) ...
                            data_filtered.test_6.time(plot_range6) ...
                            data_filtered.test_7.time(plot_range7) ], sampDown);
    F_set = downsample([data_filtered.test_5.impact.Fx(plot_range5) ...
                            data_filtered.test_6.impact.Fx(plot_range6)...
                            data_filtered.test_7.impact.Fx(plot_range7)], sampDown);

    end1 = find(timeSet(:,1)>6.1,1);
    F1 = F_set(1:end1,1);
    time1 = timeSet(1:end1,1);
    end2 = find(timeSet(:,2)>6.1,1);
    F2 = F_set(1:end2,2);
    time2 = timeSet(1:end2,2);
    end3 = find(timeSet(:,3)>5.1,1);
    F3 = F_set(1:end3,3);
    time3 = timeSet(1:end3,3);
    
    [fitresult1, gof1] = forceFit(time1, F1)
    [fitresult2, gof2] = forceFit(time2, F2)
    [fitresult3, gof3] = forceFit(time3, F3)

    F_fit = [fitresult1(timeSet(:,1)),...
             fitresult2(timeSet(:,2)),...
             fitresult3(timeSet(:,3))
             ];
    Fmax = max(F_set);
    V_in = [1.0, 1.5, 3.1];
    
%     plot(time1,F1);
%     plot(time2,F2);
%     plot(time3,F3);

%         plot(timeSet(:,1),F_set(:,1),'.','Color',[0, 0.4470, 0.7410]);
%         plot(timeSet(:,2),F_set(:,2),'.','Color',[0.4940, 0.1840, 0.5560]);
%         plot(timeSet(:,3),F_set(:,3),'.','Color',[0.8500, 0.3250, 0.0980]);
%         hold on;
%         plot(timeSet(:,1),F_fit(:,1),'-','Color',[0, 0.4470, 0.7410]);
%         plot(timeSet(:,2),F_fit(:,2),'-','Color',[0.4940, 0.1840, 0.5560]);
%         plot(timeSet(:,3),F_fit(:,3),'-','Color',[0.8500, 0.3250, 0.0980]);
         
%% %  % % % Fitting Spring model through Non-linear least-square % % % % % % % %


	    mdl1 = @(beta,x) collision_sim(1.0,x,beta,robot,human,method);
		mdl2 = @(beta,x) collision_sim(1.5,x,beta,robot,human,method);
        mdl3 = @(beta,x) collision_sim(3.1,x,beta,robot,human,method);
		% Prepare input for NLINMULTIFIT and perform fitting
% 		x_cell = {x1, x2};
% 		y_cell = {y1, y2};
        
        t_cell = {timeSet(:,1), timeSet(:,2), timeSet(:,3)};
		F_cell = {F_fit(:,1), F_fit(:,2), F_fit(:,3)};
        
		mdl_cell = {mdl1, mdl2, mdl3};
% 		beta0 = [1, 1, 1, 1];
        beta0 = variable_set;
        
        % Options for the Non-linear Fitting function handling
%         opts = statset('nlinfit');
%         opts.RobustWgtFun = 'bisquare';
		[beta,r,J,Sigma,mse,errorparam,robustw] = ...
					nlinmultifit(t_cell, F_cell, mdl_cell, beta0);

 		% Calculate model predictions and confidence intervals
		[ypred1,delta1] = nlpredci(mdl1,timeSet(:,1),beta,r,'covar',Sigma);
		[ypred2,delta2] = nlpredci(mdl2,timeSet(:,1),beta,r,'covar',Sigma);
        [ypred3,delta3] = nlpredci(mdl3,timeSet(:,1),beta,r,'covar',Sigma);

		% Calculate parameter confidence intervals
		ci = nlparci(beta,r,'Jacobian',J);   
        
        beta
        
		% Plot results
		figure;
		hold all;
		box on;
		scatter(timeSet(:,1),F_set(:,1),'blue');
		scatter(timeSet(:,1),F_set(:,2),'green');
        scatter(timeSet(:,1),F_set(:,3),'r');
		plot(timeSet(:,1),ypred1,'Color','blue');
		plot(timeSet(:,1),ypred1+delta1,'Color','blue','LineStyle',':');
		plot(timeSet(:,1),ypred1-delta1,'Color','blue','LineStyle',':');
		plot(timeSet(:,1),ypred2,'Color',[0 0.5 0]);
		plot(timeSet(:,1),ypred2+delta2,'Color',[0 0.5 0],'LineStyle',':');
		plot(timeSet(:,1),ypred2-delta2,'Color',[0 0.5 0],'LineStyle',':');   
        plot(timeSet(:,1),ypred3,'Color','r');
		plot(timeSet(:,1),ypred3+delta3,'Color','r','LineStyle',':');
		plot(timeSet(:,1),ypred3-delta3,'Color','r','LineStyle',':');   
        
        


%%  %%%%%%%% Simulation parameters for HCF Model ############
    close all; clc;
    clear robot human ColModel deformation state Khr Fext timeVec F_fit
    nfig =1;
    DUBUG_FLAG = false;
    % Getting mechanical data of the robots and tests setup (sizes, elastic modulus, and masses)
    robot_mechanical_properties;
    
    sampDown = 1;
    % Simulation method for the collision
    method.condition = 'unconstrained';
    method.contact = 'HCF'; %'CCF' or 'HCF' or 'Spring'
    % % % EA =EB = 2.3e9
    method.time = 15; % time in ms
    method.tstep= 0.01 * sampDown; % time in ms
    state.pos = 0.0; 
    state.acc = 0.0;
    
    robot.part = 'qolo_driver_bumper'; 
    human.part = 'head_child'; % For collision data
    
    % Parameters for HCF Model
    robot.n_cs = 1.65;
    robot.n_cb = 1.8;
    robot.n_rb = 2.65;
    human.limit_def = 0.8;
    robot.limit_def = 0.8;
    
    % Parameters for CCF Model
    robot.n_d = 1.5;
    robot.n_s = 1.5;
    robot.n_c = 1.5;
    robot.n_f = 0.8;
    robot.xgainA = 2;
    robot.EA = 5.0e9; %% Fitted Gain --> To be determine
    human.EB = 2.0e9; %% Fitted Gain --> To be determine
    human.cover_width = 0.003;
    
    % Parameters for Spring-Model
    human.stiffness = 150 * 1e3; % N/m --> Skull

%     for j_test=5:7
%         % For Test Data from Mobile Service Robots:
%         qolo_robot = service_test{j_test};
%         state.vel = qolo_robot.speed;
%         robot.part = qolo_robot.part; 
%         human.part = 'head_child'; % For collision data
%         service_test{j_test}.colModel = contact_simulation(state,robot,human,method);
%         figure;
%         plot(service_test{j_test}.colModel.timeVec,-service_test{j_test}.colModel.Fext)
%     end     
    j_test = 7;
    vel_0 = service_test{j_test}.speed;
    minTime = 0; 
    timeVec = [minTime:method.tstep:method.time].*1e-3';

    variable_set = [...
                    1.25; %     robot.n_cs = 1.65;
                    1.5; %     robot.n_cb = 1.8;
                    2.65; %     robot.n_rb = 2.65;
                    3.4; %      human skin thickness = 0.003 m --> 3 [mm]
                    ];
    human.cover_width = 0.04;
    robot.limit_def = 0.7;
    human.limit_def = 0.7;
%                     4.4; %     
%                     0.8; %     robot.limit_def = 0.8;
%                     0.8; %     human.limit_def = 0.8;
%                     ];

	beta1 = [
            1.29
            1.5
            2.6500
            3.4085
            ];

%             0.8000
%             0.8084
%             ];
    
    Fext = collision_sim(vel_0,timeVec,beta1,robot,human,method);
    body_stress = zeros(size(Fext));
%     for iindx=1:length(Fext)
%         body_stress(iindx) = get_strain_stress(deformation,-Fext(iindx),robot,human);
%     end
    
    % Testing the new collision models for fitting
    figure;
    plot(timeVec.*1e3,Fext)
%     hold on;
%
    maxTime = method.time;
    
    % Data to be fitted for Head Impact
        plot_range5 = find(data_filtered.test_5.time>minTime,1):...
                            find(data_filtered.test_5.time>maxTime,1);
        plot_range6 = find(data_filtered.test_5.time>minTime,1):...
                            find(data_filtered.test_5.time>maxTime,1);
        plot_range7 = find(data_filtered.test_5.time>minTime,1):...
                            find(data_filtered.test_5.time>maxTime,1);
        
        timeSet = downsample([data_filtered.test_5.time(plot_range5) ...
                                data_filtered.test_6.time(plot_range6) ...
                                data_filtered.test_7.time(plot_range7) ], sampDown);
        F_set = downsample([data_filtered.test_5.impact.Fx(plot_range5) ...
                                data_filtered.test_6.impact.Fx(plot_range6)...
                                data_filtered.test_7.impact.Fx(plot_range7)], sampDown);
    % Data to be fitted for Chest Impact
    maxTime = method.time;
        plot_range1 = find(data_filtered.test_1.time>minTime,1):...
                            find(data_filtered.test_1.time>maxTime,1);
        plot_range2 = find(data_filtered.test_2.time>minTime,1):...
                            find(data_filtered.test_2.time>maxTime,1);
        plot_range3 = find(data_filtered.test_3.time>minTime,1):...
                            find(data_filtered.test_3.time>maxTime,1);
        plot_range4 = find(data_filtered.test_4.time>minTime,1):...
                            find(data_filtered.test_4.time>maxTime,1);  % 3.2m/s
        plot_range16 = find(data_filtered.test_16.time>minTime,1):...
                            find(data_filtered.test_16.time>maxTime,1); % 1.0m/s - 60kg
        plot_range17 = find(data_filtered.test_17.time>minTime,1):...
                            find(data_filtered.test_17.time>maxTime,1);
        plot_range18 = find(data_filtered.test_18.time>minTime,1):...
                            find(data_filtered.test_18.time>maxTime,1);
        plot_range19 = find(data_filtered.test_19.time>minTime,1):...
                            find(data_filtered.test_19.time>maxTime,1); % 3.0m/s
                        
        timeSetc = downsample([data_filtered.test_1.time(plot_range1) ...
                                data_filtered.test_2.time(plot_range2) ...
                                data_filtered.test_3.time(plot_range3)...
                                data_filtered.test_4.time(plot_range4)...
                                data_filtered.test_16.time(plot_range16)...
                                data_filtered.test_17.time(plot_range17)...
                                data_filtered.test_18.time(plot_range18)...
                                data_filtered.test_19.time(plot_range19)...
                                ], sampDown).*1e-3;
                            
        F_setc = downsample([data_filtered.test_1.impact.Fx(plot_range1) ...
                                data_filtered.test_2.impact.Fx(plot_range2)...
                                data_filtered.test_3.impact.Fx(plot_range3)...
                                data_filtered.test_4.impact.Fx(plot_range4)...
                                data_filtered.test_16.impact.Fx(plot_range16)...
                                data_filtered.test_17.impact.Fx(plot_range17)...
                                data_filtered.test_18.impact.Fx(plot_range18)...
                                data_filtered.test_19.impact.Fx(plot_range19)...
                                ], sampDown);
                            
        Fmax = max(F_set);
        V_in = [1.0, 1.5, 3.1];
        hold on;
        plot(timeSet(:,3),F_set(:,3));
        %
        end1 = find(timeSet(:,1)>6.1,1);    
        F1 = F_set(1:end1,1);
        time1 = timeSet(1:end1,1);
        end2 = find(timeSet(:,2)>6.1,1);
        F2 = F_set(1:end2,2);
        time2 = timeSet(1:end2,2);
        end3 = find(timeSet(:,3)>5.1,1);
        F3 = F_set(1:end3,3);
        time3 = timeSet(1:end3,3);

        [fitresult1, gof1] = forceFit(time1, F1)
        [fitresult2, gof2] = forceFit(time2, F2)
        [fitresult3, gof3] = forceFit(time3, F3)

        F_fit = [fitresult1(timeSet(:,1)),...
                 fitresult2(timeSet(:,2)),...
                 fitresult3(timeSet(:,3))
                 ];
        Fmax = max(F_set);
        V_in = [1.0, 1.5, 3.1];
        %
        minTime = 0;
        maxTime = 10;
        minY = -10;
        maxY = 5000;
        AxisPlots = [minTime maxTime minY maxY];
        nfig = 5;
        plotNpairedData(nfig,[timeSet ],...
                            [F_set],...
                            '--','Impact-Q3-Head-Robot [133Kg]',{'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                            'time [ms]','Head Impact Force [N]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        plotNpairedData(nfig,[timeSet ],...
                            [F_fit],...
                            '-','Gaussian_Fit_Impact-Q3-Head-Robot133Kg',{'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]'},...
                            'time [ms]','Fitted Impact Force [N]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        plot(timeVec.*1e3,Fext,'*r')
        

%% % Fitting Single model data
        variable_set = [...
                    1.25; %     robot.n_cs = 1.65;
                    1.5; %     robot.n_cb = 1.8;
                    2.5; %     robot.n_rb = 2.65;
                    3.4; %     human skin thickness = 0.003 m --> 3 [mm]
                    ];
        human.cover_width = 0.04;
        robot.limit_def = 0.7;
        human.limit_def = 0.8;
        
%                     0.8; %     robot.limit_def = 0.8;
%                     0.8; %     human.limit_def = 0.8;
%                     ];

        beta1 = [
                1.45
                1.5
                2.6500
                4.4;
                ];
        
        timeSet = timeSet.*1e-3;
        mdl3 = @(beta,x) collision_sim(3.1,x,beta,robot,human,method);
        
		% Prepare input for NLINMULTIFIT and perform fitting        
        t_cell = {timeSet(:,3)};
		F_cell = {F_fit(:,3)};
        
		mdl_cell = {mdl3};
% 		Initial estiamte
        beta0 = variable_set;
        beta = beta0;
        % Options for the Non-linear Fitting function handling
        opts = statset('nlinfit');
        opts.RobustWgtFun = 'bisquare';
        [beta,r,J,Sigma,mse,errorparam,robustw]...
                        = nlinfit(timeSet(:,3), F_fit(:,3), mdl3, beta0);

 		% Calculate model predictions and confidence intervals
        [ypred3,delta3] = nlpredci(mdl3,timeSet(:,1),beta,r,'covar',Sigma);

		% Calculate parameter confidence intervals
		ci = nlparci(beta,r,'Jacobian',J);   
        
        beta
        % Plot results % % % % 
        nfig = nfig+1;
		FigName = 'Fitting-HCF_model-Child_head';
        figure(nfig);
		hold all;
		box on;
        p3 = scatter(timeSet(:,1),F_fit(:,3),'r');
        plot(timeSet(:,1),ypred3,'Color','r','LineWidth',LinesWidths);
		plot(timeSet(:,1),ypred3+delta3,'Color','r','LineStyle',':');
		plot(timeSet(:,1),ypred3-delta3,'Color','r','LineStyle',':');   
        XLabel = 'time [s]';
        YLabel = 'Impact Force [N]';
        hYLabel=ylabel(YLabel);
        hXLabel=xlabel(XLabel);
        plegends = {'3.1 m/s'};
        
        set(gcf, 'Position', [10 10 1080 480]);
        hLegend = legend([p3],...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'horizontal',...
                  'location', 'NorthOutside' );
%         Ymin=min(min(YDATA));
%         Ymax=max(max(YDATA));
            set(gca, ...
              'Box'         , 'off'     , ...
              'TickDir'     , 'out'     , ... % 'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'on'      , ...
              'YMinorTick'  , 'on'      , ...
              'YGrid'       , 'on'      , ...
              'XColor'      , [0.1 0.1 0.1], ...
              'YColor'      , [0.1 0.1 0.1], ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
              'LineWidth'   , 1         );
        set([hXLabel, hYLabel]  , ...
            'FontName',  Fonts,...
            'FontSize',  FontSizes,...
            'color',     [0 0 0]);
        
        if SAVE_PLOTS
            set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,FigName),figureFormat);
        end

        
%% %  % % % Fitting HCF model through Non-linear least-square % % % % % % % %
	    mdl1 = @(beta,x) collision_sim(1.0,x,beta,robot,human,method);
		mdl2 = @(beta,x) collision_sim(1.5,x,beta,robot,human,method);
        mdl3 = @(beta,x) collision_sim(3.1,x,beta,robot,human,method);
        
		% Prepare input for NLINMULTIFIT and perform fitting        
        t_cell = {timeSet(:,1), timeSet(:,2), timeSet(:,3)};
		F_cell = {F_fit(:,1), F_fit(:,2), F_fit(:,3)};
        
		mdl_cell = {mdl1, mdl2, mdl3};
% 		Initial estiamte
        beta0 = variable_set;
        
        % Options for the Non-linear Fitting function handling
%         opts = statset('nlinfit');
%         opts.RobustWgtFun = 'bisquare';
		[beta,r,J,Sigma,mse,errorparam,robustw] = ...
					nlinmultifit(t_cell, F_cell, mdl_cell, beta0);

 		% Calculate model predictions and confidence intervals
		[ypred1,delta1] = nlpredci(mdl1,timeSet(:,1),beta,r,'covar',Sigma);
		[ypred2,delta2] = nlpredci(mdl2,timeSet(:,1),beta,r,'covar',Sigma);
        [ypred3,delta3] = nlpredci(mdl3,timeSet(:,1),beta,r,'covar',Sigma);

		% Calculate parameter confidence intervals
		ci = nlparci(beta,r,'Jacobian',J);   
        
        beta
        
        %% % Plot results % % % % 
        nfig = nfig+1;
		FigName = 'Fitting-HCF_model-Child_head';
        figure(nfig);
		hold all;
		box on;
		p1 = scatter(timeSet(:,1),F_set(:,1),'blue');
		p2 = scatter(timeSet(:,1),F_set(:,2),'green');
        p3 = scatter(timeSet(:,1),F_set(:,3),'r');
		plot(timeSet(:,1),ypred1,'Color','blue','LineWidth',LinesWidths);
		plot(timeSet(:,1),ypred1+delta1,'Color','blue','LineStyle',':');
		plot(timeSet(:,1),ypred1-delta1,'Color','blue','LineStyle',':');
		plot(timeSet(:,1),ypred2,'Color',[0 0.5 0],'LineWidth',LinesWidths);
		plot(timeSet(:,1),ypred2+delta2,'Color',[0 0.5 0],'LineStyle',':');
		plot(timeSet(:,1),ypred2-delta2,'Color',[0 0.5 0],'LineStyle',':');   
        plot(timeSet(:,1),ypred3,'Color','r','LineWidth',LinesWidths);
		plot(timeSet(:,1),ypred3+delta3,'Color','r','LineStyle',':');
		plot(timeSet(:,1),ypred3-delta3,'Color','r','LineStyle',':');   
        XLabel = 'time [ms]';
        YLabel = 'Impact Force [N]';
        hYLabel=ylabel(YLabel);
        hXLabel=xlabel(XLabel);
        plegends = {'1.0m/s', '1.5m/s', '3.1 m/s'};
        
        set(gcf, 'Position', [10 10 1080 480]);
        hLegend = legend([p1, p2, p3],...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'horizontal',...
                  'location', 'NorthOutside' );
%         Ymin=min(min(YDATA));
%         Ymax=max(max(YDATA));
            set(gca, ...
              'Box'         , 'off'     , ...
              'TickDir'     , 'out'     , ... % 'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'on'      , ...
              'YMinorTick'  , 'on'      , ...
              'YGrid'       , 'on'      , ...
              'XColor'      , [0.1 0.1 0.1], ...
              'YColor'      , [0.1 0.1 0.1], ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
              'LineWidth'   , 1         );
        set([hXLabel, hYLabel]  , ...
            'FontName',  Fonts,...
            'FontSize',  FontSizes,...
            'color',     [0 0 0]);
        
    if true
        set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
        saveas(nfig,strcat(figPath,FigName),figureFormat);
    end
    
%%
%%  %%%%%%%% Simulation parameters for HCF Model ############
    close all; clc;
    clear robot human ColModel deformation state Khr Fext timeVec F_fit
    nfig =1;
    DUBUG_FLAG = false;
    % Getting mechanical data of the robots and tests setup (sizes, elastic modulus, and masses)
    robot_mechanical_properties;
    
    sampDown = 1;
    % Simulation method for the collision
    method.condition = 'unconstrained';
    method.contact = 'HCF'; %'CCF' or 'HCF' or 'Spring'
    % % % EA =EB = 2.3e9
    method.time = 100; % time in ms
    method.tstep= 0.01 * sampDown; % time in ms
    state.pos = 0.0; state.acc = 0.0;
    
    robot.part = 'qolo_driver_bumper'; 
    human.part = 'thorax_child'; % For collision data
    
    % Parameters for HCF Model
    robot.n_cs = 1.65;
    robot.n_cb = 1.8;
    robot.n_rb = 2.65;
    human.limit_def = 0.8;
    robot.limit_def = 0.8;
    
    % Parameters for CCF Model
    robot.n_d = 1.5;
    robot.n_s = 1.5;
    robot.n_c = 1.5;
    robot.n_f = 0.8;
    robot.xgainA = 2;
    robot.EA = 5.0e9; %% Fitted Gain --> To be determine
    human.EB = 2.0e9; %% Fitted Gain --> To be determine
    human.cover_width = 0.003;
    
    % Parameters for Spring-Model
    human.stiffness = 150 * 1e3; % N/m --> Skull

%     for j_test=1:4
%         % For Test Data from Mobile Service Robots:
%         qolo_robot = service_test{j_test};
%         state.vel = qolo_robot.speed;
%         robot.part = qolo_robot.part; 
%         human.part = 'chest_child'; % For collision data
%         service_test{j_test}.colModel = contact_simulation(state,robot,human,method);
%         figure;
%         plot(service_test{j_test}.colModel.timeVec,-service_test{j_test}.colModel.Fext)
%     end     
    j_test = 7;
    vel_0 = service_test{j_test}.speed;
    minTime = -10; 
    timeVec = [minTime:method.tstep:method.time].*1e-3';

    variable_set = [...
                    1.5; %     robot.n_cs = 1.65;
                    1.8; %     robot.n_cb = 1.8;
                    2.65; %     robot.n_rb = 2.65;
                    4.4; %     human skin thickness = 0.003 m --> 3 [mm]
                    0.8; %     robot.limit_def = 0.8;
                    0.8; %      human.limit_def = 0.8;
                    ];
	beta1 = [
            1.2
            1.5
            2.6500
            3.4085
            0.8000
            0.8084
            ];

% Testing the new collision models for fitting
%     Fext = collision_sim(vel_0,timeVec,beta1,robot,human,method);
%     figure;
%     plot(timeVec.*1e3,Fext)
    

    maxTime = method.time;
    
    % Data to be fitted for Chest Impact
    maxTime = method.time;
        plot_range1 = find(data_filtered.test_1.time>minTime,1):...
                            find(data_filtered.test_1.time>maxTime,1);
        plot_range2 = find(data_filtered.test_2.time>minTime,1):...
                            find(data_filtered.test_2.time>maxTime,1);
        plot_range3 = find(data_filtered.test_3.time>minTime,1):...
                            find(data_filtered.test_3.time>maxTime,1);
        plot_range4 = find(data_filtered.test_4.time>minTime,1):...
                            find(data_filtered.test_4.time>maxTime,1);  % 3.2m/s
        plot_range16 = find(data_filtered.test_16.time>minTime,1):...
                            find(data_filtered.test_16.time>maxTime,1); % 1.0m/s - 60kg
        plot_range17 = find(data_filtered.test_17.time>minTime,1):...
                            find(data_filtered.test_17.time>maxTime,1);
        plot_range18 = find(data_filtered.test_18.time>minTime,1):...
                            find(data_filtered.test_18.time>maxTime,1);
        plot_range19 = find(data_filtered.test_19.time>minTime,1):...
                            find(data_filtered.test_19.time>maxTime,1); % 3.0m/s
                        
        timeSet = downsample([data_filtered.test_1.time(plot_range1) ...
                                data_filtered.test_2.time(plot_range2) ...
                                data_filtered.test_3.time(plot_range3)...
                                data_filtered.test_4.time(plot_range4)...
                                data_filtered.test_16.time(plot_range16)...
                                data_filtered.test_17.time(plot_range17)...
                                data_filtered.test_18.time(plot_range18)...
                                data_filtered.test_19.time(plot_range19)...
                                ], sampDown);
                            
        F_set = downsample([data_filtered.test_1.impact.Fx(plot_range1) ...
                                data_filtered.test_2.impact.Fx(plot_range2)...
                                data_filtered.test_3.impact.Fx(plot_range3)...
                                data_filtered.test_4.impact.Fx(plot_range4)...
                                data_filtered.test_16.impact.Fx(plot_range16)...
                                data_filtered.test_17.impact.Fx(plot_range17)...
                                data_filtered.test_18.impact.Fx(plot_range18)...
                                data_filtered.test_19.impact.Fx(plot_range19)...
                                ], sampDown);
                            
        Fmax = max(F_set);
        V_in = [1.0, 1.5, 3.1, 3.2, 1.0, 1.5, 3.1, 3.0];
        Mass = [133, 133, 133, 133, 60,  60,  60,  60];
        hold on;
        plot(timeSet(:,3),F_set(:,3));
        
        [~,n]=size(F_set);
        for itest=1:n
            end1 = find(timeSet(:,1)>61,itest);    
            [fit{itest}.fitresult, fit{itest}.gof] = ...
                    forceFit(timeSet(1:end1,itest), F_set(1:end1,itest));
                
            F_fit(:,itest) = fit{itest}.fitresult(timeSet(:,1));
        end
% 
%         F_fit = [fitresult1(timeSet(:,1)),...
%                  fitresult2(timeSet(:,2)),...
%                  fitresult3(timeSet(:,3))
%                  ];

        %%
        close all;
        nfig = 1;
        minTime = -10;
        maxTime = 100;
        minY = -10;
        maxY = 1500;
        AxisPlots = [minTime maxTime minY maxY];
        plegend = {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]' '3.2 [m/s]'};
        plotNpairedData(nfig,[timeSet(:,1:4) ],...
                            [F_set(:,1:4)],...
                            '--','Impact-Q3-Chest-Robot-133Kg',plegend,...
                            'time [ms]','Chest Impact Force [N]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        plotNpairedData(nfig,[timeSet(:,1:4) ],...
                            [F_fit(:,1:4)],...
                            '-','Gaussian_Fit_Impact-Q3-Chest-Robot133kg',plegend,...
                            'time [ms]','Fitted Impact Force [N]',true,figPath,...
                            figureFormat,AxisPlots);

        nfig = 1 + nfig;
        minTime = -10;
        maxTime = 100;
        minY = -10;
        maxY = 1500;
        AxisPlots = [minTime maxTime minY maxY];
        plegend = {'1.0 [m/s]' '1.5 [m/s]' '3.1 [m/s]' '3.0 [m/s]'};
        plotNpairedData(nfig,[timeSet(:,5:8) ],...
                            [F_set(:,5:8)],...
                            '--','Impact-Q3-Chest-Robot-60kg',plegend,...
                            'time [ms]','Chest Impact Force [N]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        plotNpairedData(nfig,[timeSet(:,5:8) ],...
                            [F_fit(:,5:8)],...
                            '-','Gaussian_Fit_Impact-Q3-Chest-Robot60kg',plegend,...
                            'time [ms]','Fitted Impact Force [N]',true,figPath,...
                            figureFormat,AxisPlots);
    
    
    
%%
    %%%%%%%% Filling simulation parameters: for CCF Model ############
    
    close all; clc;
    clear robot human ColModel deformation state Khr Fext timeVec
    nfig =1;
    DUBUG_FLAG = false;
        
    sampDown = 1;
    % Simulation method for the collision
    method.condition = 'unconstrained';
    method.contact = 'CCF'; %'CCF' or 'HCF'
    % % % EA =EB = 2.3e9
    method.time = 10; % time in ms
    method.tstep= 0.01*sampDown; % time in ms
    state.pos = 0.0; state.acc = 0.0; 
    
    robot.part = qolo_robot.part; 
    human.part = 'head_child'; % For collision data
    
    % Parameters for HCF Model
    robot.n_cs = 1.65;
    robot.n_cb = 1.8;
    robot.n_rb = 2.65;
    human.limit_def = 0.8;
    robot.limit_def = 0.8;
    
    % Parameters for CCF Model
    robot.n_d = 1.5;
    robot.n_s = 1.5;
    robot.n_c = 1.5;
    robot.n_f = 0.8;
    robot.EA = 4.0e8; %% Fitted Gain --> To be determine
    human.EB = 4.0e8; %% Fitted Gain --> To be determine
    robot.xgainA = 2;
    human.cover_width = 0.003;
    
%     for j_test=5:7
%         % For Test Data from Mobile Service Robots:
%         qolo_robot = service_test{j_test};
%         state.vel = qolo_robot.speed;
%         robot.part = qolo_robot.part; 
%         human.part = 'head_child'; % For collision data
%         service_test{j_test}.colModel = contact_simulation(state,robot,human,method);
% %         figure;
% %         plot(service_test{j_test}.colModel.timeVec,-service_test{j_test}.colModel.Fext)
%     end     
    j_test = 7;
    vel_0 = service_test{j_test}.speed;
    timeVec = [0:method.tstep:method.time]';
    variable_set = [...
                    1.3; % robot.n_d = 1.5;
                    1.3; % robot.n_s = 1.5;
                    1.3; % robot.n_c = 1.5;
                    0.8; % robot.n_f = 0.8;
                    20.0; % robot.EA = 5.0  Input in GPa [0.1e9]; %% Fitted Gain --> To be determine
                    5; % human.EB = 2.0 --> Input in GPa [0.1e9]; %% Fitted Gain --> To be determine
                    2; % robot.xgainA = 2;
                    5; % human.cover_width = 0.003; --> Input in [mm]
                    ];

%                     ];
    Fext = collision_sim(vel_0,timeVec.*1e-3,variable_set,robot,human,method);
    % Testing the new collision models for fitting
    figure;
    plot(timeVec,Fext)
    hold on;
    minTime = timeVec(1); maxTime = timeVec(end);
    
    % Data to be fitted: 
        plot_range5 = find(data_filtered.test_5.time>minTime,1):...
                            find(data_filtered.test_5.time>maxTime,1);
        plot_range6 = find(data_filtered.test_5.time>minTime,1):...
                            find(data_filtered.test_5.time>maxTime,1);
        plot_range7 = find(data_filtered.test_5.time>minTime,1):...
                            find(data_filtered.test_5.time>maxTime,1);
        
        timeSet = downsample([data_filtered.test_5.time(plot_range5) ...
                                data_filtered.test_6.time(plot_range6) ...
                                data_filtered.test_7.time(plot_range7) ], sampDown);
        F_set = downsample([data_filtered.test_5.impact.Fx(plot_range5) ...
                                data_filtered.test_6.impact.Fx(plot_range6)...
                                data_filtered.test_7.impact.Fx(plot_range7)], sampDown);
        hold on;
        plot(timeSet(:,3),F_set(:,3));
        
        
%%
        % Prepare function handling for NLINMULTIFIT
        mdl1 = @(beta,x) collision_sim(1.0,x,beta,robot,human,method);
		mdl2 = @(beta,x) collision_sim(1.5,x,beta,robot,human,method);
        mdl3 = @(beta,x) collision_sim(3.1,x,beta,robot,human,method);
        
		% Prepare input for NLINMULTIFIT
        t_cell = {timeSet(:,1), timeSet(:,2), timeSet(:,3)};
		F_cell = {F_set(:,1), F_set(:,2), F_set(:,3)};
		mdl_cell = {mdl1, mdl2, mdl3};
        % Initial estimates
        beta0 = variable_set;
        
        % Options for the Non-linear Fitting function handling
%         opts = statset('nlinfit');
%         opts.RobustWgtFun = 'bisquare';
		[beta,r,J,Sigma,mse,errorparam,robustw] = ...
					nlinmultifit(t_cell, F_cell, mdl_cell, beta0);

 		% Calculate model predictions and confidence intervals
		[ypred1,delta1] = nlpredci(mdl1,timeSet(:,1),beta,r,'covar',Sigma);
		[ypred2,delta2] = nlpredci(mdl2,timeSet(:,1),beta,r,'covar',Sigma);
        [ypred3,delta3] = nlpredci(mdl3,timeSet(:,1),beta,r,'covar',Sigma);

		% Calculate parameter confidence intervals
		ci = nlparci(beta,r,'Jacobian',J); 
        beta
        
		% Plot results
		figure;
		hold all;
		box on;
		scatter(timeSet(:,1),F_set(:,1),'blue');
		scatter(timeSet(:,1),F_set(:,2),'green');
        scatter(timeSet(:,1),F_set(:,3),'r');
		plot(timeSet(:,1),ypred1,'Color','blue');
		plot(timeSet(:,1),ypred1+delta1,'Color','blue','LineStyle',':');
		plot(timeSet(:,1),ypred1-delta1,'Color','blue','LineStyle',':');
		plot(timeSet(:,1),ypred2,'Color',[0 0.5 0]);
		plot(timeSet(:,1),ypred2+delta2,'Color',[0 0.5 0],'LineStyle',':');
		plot(timeSet(:,1),ypred2-delta2,'Color',[0 0.5 0],'LineStyle',':');   
        plot(timeSet(:,1),ypred3,'Color','r');
		plot(timeSet(:,1),ypred3+delta3,'Color','r','LineStyle',':');
		plot(timeSet(:,1),ypred3-delta3,'Color','r','LineStyle',':');   
        
        
%%
  
% Plotting Comparative Data for Mobile service robot tests
        nfig = nfig+1;
        figName = 'Q3_Model_Impact-Head_at_133kg';
        plegends = {'F_{e} 1.0m/s', 'F_{e} 1.5m/s', 'F_{e} 3.1m/s'};
        minTime = 0;
        maxTime = method.time;
        AxisPlots = [minTime maxTime -100 20000];
        plotNpairedData(nfig,[service_test{5}.colModel.timeVec, ...
                                service_test{6}.colModel.timeVec,...
                                service_test{7}.colModel.timeVec ... 
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
%         minTime = -5;
%         maxTime = 20;
%         minY = -10;
%         maxY = 5000;
%         AxisPlots = [minTime maxTime minY maxY];
%         plot_range = 1:find(data_raw.test_5.time>200,1); %length(data_raw.test_5.time);

        plotNpairedData(nfig,[data_filtered.test_5.time(plot_range5) ...
                                data_filtered.test_6.time(plot_range6) ...
                                data_filtered.test_7.time(plot_range7) ],...
                            [data_filtered.test_5.impact.Fx(plot_range5) ...
                                data_filtered.test_6.impact.Fx(plot_range6)...
                                data_filtered.test_7.impact.Fx(plot_range7)],...
                            '--',figName,plegends,...
                            'time [ms]','Head Impact Force [N]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);
        hold on;
        if SAVE_PLOTS       
            set(gcf,'PaperPositionMode','auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        hold off;

%% HIC criteria for simulated and real-data
%         close all; clc;
        Q3_coeff = 1;
        minTime = 0;
        maxTime = method.time;
%         AxisPlots = [minTime maxTime -100 20000];
        plot_range5 = find(data_raw_Q3.test_5.time>minTime,1):...
                            find(data_raw_Q3.test_5.time>maxTime,1);
        plot_range6 = find(data_raw_Q3.test_6.time>minTime,1):...
                            find(data_raw_Q3.test_6.time>maxTime,1);
        plot_range7 = find(data_raw_Q3.test_7.time>minTime,1):...
                            find(data_raw_Q3.test_7.time>maxTime,1);
        
        nfig = nfig+1;
        figName = 'Head_Acceleration-Service_Robot_133kg';
        plegends = {'\Delta v 1.0m/s', '\Delta v 1.5m/s', '\Delta v 3.1m/s'};
        AxisPlots = [minTime maxTime -1 600];
        plot_range = find(service_test{5}.colModel.timeVec>minTime,1):...
                            find(service_test{5}.colModel.timeVec>=maxTime,1);
        plotNpairedData(nfig,[service_test{5}.colModel.timeVec,...
                                service_test{6}.colModel.timeVec,...
                                service_test{7}.colModel.timeVec... 
                                ],...
                            [-service_test{5}.colModel.deformation.acc,...
                            -service_test{6}.colModel.deformation.acc,...
                            -service_test{7}.colModel.deformation.acc...
                                ]./g_const,...
                            '-',figName,plegends,...
                            'time [ms]','Head Acceleration [g]'...
                            ,false,figPath,figureFormat... 
                            ,AxisPlots...
                            );  
        hold on;

        plotNpairedData(nfig,[data_raw_Q3.test_5.time(plot_range5) ...
                                data_raw_Q3.test_6.time(plot_range6) ...%                                 data_raw.test_3.time(plot_range) ...
                                data_raw_Q3.test_7.time(plot_range7) ],...
                            [data_raw_Q3.test_5.head.areas(plot_range5) ...
                                data_raw_Q3.test_6.head.areas(plot_range6)...%                                 data_raw.test_3.head.ay(plot_range)...
                                data_raw_Q3.test_7.head.areas(plot_range7)],...
                            '--',figName,...
                            plegends,...
                            'time [ms]','Acceleration [g]',SAVE_PLOTS,figPath,...
                            figureFormat,AxisPlots);     
        
         hold on;
        if SAVE_PLOTS       
            set(gcf,'PaperPositionMode','auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        hold off;
        
        % Estiamting HIC from Real data and from Simulations
        [q3{5}.hic,q3{5}.interval] = HIC15_criteria(data_raw_Q3.test_5.time(plot_range5),...
                                                data_raw_Q3.test_5.head.areas(plot_range5),...
                                                Q3_coeff,false);
        [q3{6}.hic,q3{6}.interval] = HIC15_criteria(data_raw_Q3.test_6.time(plot_range6),...
                                                data_raw_Q3.test_6.head.areas(plot_range6),...
                                                Q3_coeff,false);
        [q3{7}.hic,q3{7}.interval] = HIC15_criteria(data_raw_Q3.test_7.time(plot_range7),...
                                                data_raw_Q3.test_7.head.areas(plot_range7),...
                                                Q3_coeff,false);
               
     
%% %  Plotting Comparative Data for Manipulators' Tests

    close all; clc;
    clear robot human ColModel deformation state Khr Fext timeVec
    nfig =1;
    DUBUG_FLAG = false;
        
    % Simulation method for the collision
    method.condition = 'unconstrained';
    method.contact = 'HCF'; %'CCF' or 'HCF'
    % % % EA =EB = 2.3e9
    method.time = 15; % time in ms
    method.tstep= 0.1; % time in ms
    state.pos = 0.0; state.acc = 0.0;
    
    robot.limit_def = 0.8;
    robot.n_cs = 1.65;
    robot.n_cb = 1.8;
    robot.n_rb = 2.65;

    for j_test=[15,17,19,26,27,31]
        % For Test with Manipulator:
        manipulator_robot = manipulator_data{j_test};
        state.vel = manipulator_robot.speed; % initial Speed
        robot.part = manipulator_robot.part; 
        human.part = 'head_adult'; % For collision data    
        manipulator_data{j_test}.colModel = contact_simulation(state,robot,human,method);
    end
        
    %% Plotting Contact Forces %%
        nfig = nfig+1;
        figName = 'Manipulators-1-Contact_Force';
        plegends = {'Exp.15', 'Exp.17', 'Exp.19'};
        AxisPlots = [0 method.time -100 15000];
        plotNpairedData(nfig,[manipulator_data{15}.colModel.timeVec,...
                                manipulator_data{17}.colModel.timeVec,...
                                manipulator_data{19}.colModel.timeVec ... 
                                ],...
                            [-manipulator_data{15}.colModel.Fext,...
                                    -manipulator_data{17}.colModel.Fext,...
                                    -manipulator_data{19}.colModel.Fext ...
                                ],...
                            '-',figName,plegends,...
                            'time [ms]','Head Impact Force [N]'...
                            ,false,figPath,figureFormat...
                            ,AxisPlots...
                            );
        nfig = nfig+1;
        figName = 'Manipulators-2-Contact_Force';
        plegends = {'Exp.26', 'Exp.27', 'Exp.31'};
        AxisPlots = [0 method.time -100 10000];
        plotNpairedData(nfig,[manipulator_data{26}.colModel.timeVec,...
                                manipulator_data{27}.colModel.timeVec,...
                                manipulator_data{31}.colModel.timeVec ... 
                                ],...
                            [-manipulator_data{26}.colModel.Fext,...
                                    -manipulator_data{27}.colModel.Fext,...
                                    -manipulator_data{31}.colModel.Fext ...
                                ],...
                            '-',figName,plegends,...
                            'time [ms]','Head Impact Force [N]'...
                            ,false,figPath,figureFormat...
                            ,AxisPlots...
                            );

% %         % Acceleration to the head
        nfig = nfig+1;
        figName = 'Manipulators-1-Acceleration_Head';
        plegends = {'Exp.15', 'Exp.17', 'Exp.19'};
        AxisPlots = [0 method.time -100 600];
        plotNpairedData(nfig,[manipulator_data{15}.colModel.timeVec,...
                                manipulator_data{17}.colModel.timeVec,...
                                manipulator_data{19}.colModel.timeVec ... 
                                ],...
                            [-manipulator_data{15}.colModel.deformation.acc,...
                            -manipulator_data{17}.colModel.deformation.acc,...
                            -manipulator_data{19}.colModel.deformation.acc ...
                                ]./g_const,...
                            '-',figName,plegends,...
                            'time [ms]','Head Acceleration [g]'...
                            ,false,figPath,figureFormat... 
                            ,AxisPlots...
                            );
        nfig = nfig+1;
        figName = 'Manipulators-2-Acceleration_Head';
        plegends = {'Exp.26', 'Exp.27', 'Exp.31'};
        AxisPlots = [0 method.time -100 600];
        plotNpairedData(nfig,[manipulator_data{26}.colModel.timeVec,...
                                manipulator_data{27}.colModel.timeVec,...
                                manipulator_data{31}.colModel.timeVec ... 
                                ],...
                            [-manipulator_data{26}.colModel.deformation.acc,...
                            -manipulator_data{27}.colModel.deformation.acc,...
                            -manipulator_data{31}.colModel.deformation.acc ...
                                ]./g_const,...
                            '-',figName,plegends,...
                            'time [ms]','Head Acceleration [g]'...
                            ,false,figPath,figureFormat... 
                            ,AxisPlots...
                            );     
        
        Q3_coeff = 1;
        [hic_value,interval] = HIC15_criteria(manipulator_data{15}.colModel.timeVec,...
                                -manipulator_data{15}.colModel.deformation.acc,...
                                    Q3_coeff,true);
                                
                                
    function Fmax = SpringContact(vel_0,K,human,robot)
        
    end