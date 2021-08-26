    %% Simulating Variations on Speed, Mass and Mechanical properties
    % Author: Diego F. Paez G.
    % Date: 1st Apr 2021
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
        figPath0 = fullfile(parentdir, 'figures/');
        
        
        % Options
        global DEBUG_FLAG;
        DEBUG_FLAG = false;
        DRAW_PLOTS = true;
        SAVE_PLOTS = true;
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
        load('Q3_metrics.mat')
        load('H3_metrics.mat')
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
        Ts = 1/Freq; % Sampling period in (s)
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
        
%% ################### Getting Injury Criteria ###################                      

    Q3.NFz =  []; Q3.NFz_impact =  [];
    Q3.NMy =  []; Q3.NMy_impact =  [];
    Q3.PeakAcc = [];
    minX = -5; maxX = 200;
    impactRange = find(data_raw_Q3.test_1.time>minX,1):...
                        find(data_raw_Q3.test_1.time>maxX,1);
    Q3.fileName = [];
    Q3.testNum = [];
    Q3.HIC15_robot = [];
    Q3.HIC15_ground = [];
    Q3.Acc_3m = [];
    Q3.Nij  = [];
    Q3.ThCC = [];
    Q3.Thorax_a3ms = [];
    Q3.Vc = [];
    Q3.CTI = [];
    Q3.Force = [];

    for i_test = data_q3
        Q3.testNum(end+1) = i_test;
        Q3.fileName{end+1} = eval(['metrics_Q3.test_',num2str(i_test),'.TestName']);
        Q3.HIC15_robot(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.HIC15_robot']);
        Q3.HIC15_ground(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.HIC15_ground']);
        Q3.Acc_3m(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.head_a_3ms']);
        Q3.Nij(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.Nij']);
        Q3.ThCC(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.ThCC']);
        Q3.Thorax_a3ms(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.Thorax_a3ms']);
        Q3.Vc(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.VC']);
        Q3.CTI(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.CTI']);
        eval(['metrics_Q3.test_',num2str(i_test),...
             '.PeakForce = max(data_filtered.test_',num2str(i_test),'.impact.Fx);'])
        Q3.Force(end+1) = eval(['metrics_Q3.test_',num2str(i_test),'.PeakForce']);
        
        Q3.NFz_impact(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(i_test),'.neck.Fz(impactRange)))'])./1000;
        Q3.NMy_impact(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(i_test),'.neck.My(impactRange)))'])./1000;
        Q3.NFz(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(i_test),'.neck.Fz))'])./1000;
        Q3.NMy(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(i_test),'.neck.My))'])./1000;
        Q3.PeakAcc(end+1) = eval(['max(data_raw_Q3.test_',num2str(i_test),'.head.areas(impactRange));']);
    end

    
    
    
    %% Using parameters from the fitted data:
   for age_range=1:4
        
        
    clear service_sim max_energy_density max_tensile max_Fext
    clc
    close all
    
    robot_mechanical_properties;
        
    % Q1.5 = 11kg
    
    % Q3 = 14.5kg
    % Head circunference=0.3519 radius:0.056m  Head+ neck = 3.17 kg / Head = 2.7kg
    head.radius(1) = 0.056;
    head.mass(1) = 2.7;
    head.poisson(1) = 0.26;
    head.elastic_mod(1) = 4.7*1e9;
    pedestrian_speed(1) = 1.53;
    age(1) = 3;
    % Q6 = 23kg / 1.14 m
    % Head circunference=0.4945 radius:0.078m  % Head+ neck = 3.94 kg / Head = 3.4 kg
    head.radius(2) = 0.078;
    head.mass(2) = 3.4;
    head.poisson(2) = 0.24;
    head.elastic_mod(2) = 5.7*1e9;
    pedestrian_speed(2) = 1.53;
    age(2) = 6;
    % Q10 = 35.5kg
    % Head circunference=0.5138 :0.081m  % Head+ neck = 4.21 kg / Head = 3.7kg
    head.radius(3) = 0.080;
    head.mass(3) = 3.7;
    head.poisson(3) = 0.23;
    head.elastic_mod(3) = 6.0*1e9;
    pedestrian_speed(3) = 1.53;
    age(3) = 10;
    % Adult = 78.5 kg / 1.78m
    % Head radius:0.056m  % Head = 4.54kg
    head.radius(4) = 0.081;
    head.mass(4) = 4.54;
    head.poisson(4) = 0.22;
    head.elastic_mod(4) = 6.5*1e9;
    pedestrian_speed(4) = 1.55;
    age(4) = 35;

    child_head.human_radius_head = head.radius(age_range); % Diameter=
    child_head.head_mass = head.mass(age_range);
    child_head.poisson_ratio_human_scalp = head.poisson(age_range);
    child_head.elastic_mod_bone = head.elastic_mod(age_range); %Eb
    pedestrian_vel = pedestrian_speed(age_range);
    figPath = strcat(figPath0,[num2str(age(age_range)),'-']);
    
    sampDown = 1;
    % Parameters for HCF Model
    robot.n_cs = 1.65;
    robot.n_cb = 1.8;
    robot.n_rb = 2.65;
    human.limit_def = 0.8;
    robot.limit_def = 0.8;
    
    % Parameters for CCF Model
    robot.n_d = 1.5; % Hertzian Deformation exponential
    human.n_s = 1.5; % Skin Deformation exponential
    robot.n_c = 1.5; % Robot cover Deformation exponential
    human.n_f = 0.9; % human differential deformation
    robot.n_f = 0.8; % robot differential deformation
    robot.xgainA = 4;
    human.xgainB = 1;
    robot.EA = 1.0e9; %% Fitted Gain --> To be determine
    human.EB = 1.0e9; %% Fitted Gain --> To be determine
    human.cover_width = 0.003;
    
    % Parameters for HRC Model
%   Beta =  [3.2048
%           1.2372
%           168.3891];
    robot.n_hr = 2.5; % 2.55;
    robot.damping_hr = 2.2;%1.32;
    robot.stiffness_hr = 168*1e8;
    
    human.limit_def = 0.8;
    robot.limit_def = 0.8;
    
    % Simulation method for the collision
    method.condition = 'unconstrained';
    method.contact = 'HRC'; %'CCF' or 'HCF' or 'HRC'
    % % % EA =EB = 2.3e9
    method.time = 15; % time in ms
    method.tstep= 0.01; % time in ms
    state.pos = 0.0; state.acc = 0.0;

%     service_sim = struct();
%     vel_samples = [1.0:1:10.0];
    vel_samples = [pedestrian_vel-1, 1.0, 1.5, 2.0, 2.5, 3.0, 3.1, 3.2, 3.3, 3.4, 3.5, 4.0, 5.0, 6.0, pedestrian_vel+6];
    operational_vel = vel_samples - pedestrian_vel;
    weight_samples = [5,10,15,20,25,40,60,90,110,150,200];
    radius_samples = [0.010:0.040:0.41];
    
    material_names = {'EPDM',   'HDPE',   'PP',   'ABS',  'PBT',   'Nylon',    'PC' }; % 'Al-7075'};
    material_modulus = [6.73*1e6 ; 1e9; 1.325e9; 1.4*1e9; 1.93e9; 3.3*1e9; 6.0*1e9; ]; %368*1e9; ];
    material_poisson = [0.5 ;     0.46;    0.42;   0.29;   0.39;    0.41;     0.32; ]; %  0.35;  ];
    
    X_variable = weight_samples;
    Variable2_label='Robot mass (kg)';
%     qolo_robot.elastic_mod_robot_cover = material_samples(i_material);
%     qolo_robot.bumper_radius = radius_samples(i_radius);
    
    % Initiating arrays for varying parameters on simulation of contacts
    max_Fext = zeros(length(vel_samples),length(X_variable));
    max_energy_density = max_Fext;
    max_tensile = max_Fext;
    max_compressive = max_Fext;
    max_acc = max_Fext;
    HIC_tab = max_Fext;
    
    for k_weight=1:length(X_variable)
        % For Test Data from Mobile Service Robots: Head Impact Child dummy
        qolo_robot = service_test{7};
        qolo_robot.mass_w_driver = X_variable(k_weight);
        
        for j_test=1:length(vel_samples)
            robot.part = qolo_robot.part; 
            state.vel = vel_samples(j_test);
            human.part = 'head_child'; % For collision data
            service_sim{j_test,k_weight}.colModel = contact_simulation(state,robot,human,method);
            max_energy_density(j_test,k_weight) = service_sim{j_test,k_weight}.colModel.max_energy_density; 
            max_compressive(j_test,k_weight) = max(service_sim{j_test,k_weight}.colModel.compressive_stress);
            max_tensile(j_test,k_weight) = service_sim{j_test,k_weight}.colModel.max_tensile;
            max_Fext(j_test,k_weight) = -min(service_sim{j_test,k_weight}.colModel.Fext);
            max_acc(j_test,k_weight) = max(service_sim{j_test,k_weight}.colModel.acc);
            [HIC_tab(j_test,k_weight),~] = HIC15_criteria(service_sim{j_test,k_weight}.colModel.timeVec,...
                                                        service_sim{j_test,k_weight}.colModel.acc,1,false);            
        end
        
    end
%     j_test=3; k_weight=3;
%     [HIC_test, interval_test]= HIC15_criteria(service_sim{j_test,k_weight}.colModel.timeVec,...
%                                                         service_sim{j_test,k_weight}.colModel.acc,1,true)

% Getting Model data for actual values captured with real robot
    minTime = 0;
    maxTime = method.time;
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
        service_test{j_test}.data.Fext = eval(['data_filtered.test_',num2str(j_test),'.impact.Fx']);
    end
    
    
    %% Estimating Max/min change and sturation of inertia influence
    
    for k_test = 1:length(X_variable)
        norm_acc(:,k_test) = max_acc(:,k_test)./ max_acc(:,end);
        mean_max_norm(1,k_test) = 1 - mean(norm_acc(:,k_test));
        sd_max_norm(1,k_test) = std(norm_acc(:,k_test));
        
        norm_hic(:,k_test) = HIC_tab(:,k_test)./ HIC_tab(:,end);
        mean_hic_norm(1,k_test) = 1 - mean(norm_hic(:,k_test));
        sd_hic_norm(1,k_test) = std(norm_hic(:,k_test)); 
    end
    X_variable(find(mean_max_norm<0.10,1))
    mean_max_norm(find(mean_max_norm<0.10,1))
    
    X_variable(find(mean_hic_norm<0.10,1))
    mean_hic_norm(find(mean_hic_norm<0.10,1))
    
    
    %% Head Impact Simulation Plots: 
        clc; close all;

        nfig = nfig+1;
        figName = 'weightSim-Force_peak-child-head';
%         plegends = material_names;
        plegends = {};
        for i_label=1:length(X_variable)
            plegends{end+1} = num2str(X_variable(i_label));
        end
        
        minTime = 0;
        maxTime = method.time;
        AxisPlots = [minTime maxTime -100 7000];
        plotNpairedData(nfig,[operational_vel',... 
                               operational_vel', ... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                                ],...
                            [max_Fext(:,1),...
                            max_Fext(:,2),...
                            max_Fext(:,3)...
                            max_Fext(:,4)...
                            max_Fext(:,5)...
                            max_Fext(:,6)...
                            max_Fext(:,7)...
                            ].*1e-3,...
                            '-',figName,plegends,...
                            'Speed at impact (m/s)','Max Contact Force (kN)'...
                            ,true,figPath,figureFormat...%                             ,AxisPlots...
                            );
        hold on;
        plot(1.0,max(data_filtered.test_5.impact.Fx).*1e-3,'ok','lineWidth',LinesWidths,'MarkerSize',14);
        plot(1.5,max(data_filtered.test_6.impact.Fx).*1e-3,'ok','lineWidth',LinesWidths,'MarkerSize',14);
        plot(3.1,max(data_filtered.test_7.impact.Fx).*1e-3,'ok','lineWidth',LinesWidths,'MarkerSize',14);
        PicSize = [10 10 780 780];
        hLegend = legend(...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'horizontal',...
                  'location', 'northoutside' );
        set(gcf, 'Position', PicSize);
        if SAVE_PLOTS
             set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        
        nfig = nfig+1;
        figName = 'weightSim-Acceleration-peak-child-head';
%         plegends = material_names;
        minTime = 0;
        maxTime = method.time;
        AxisPlots = [minTime maxTime -100 7000];
        plotNpairedData(nfig,[operational_vel',... 
                               operational_vel', ... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                                ],...
                            [max_acc(:,1),...
                            max_acc(:,2),...
                            max_acc(:,3)...
                            max_acc(:,4)...
                            max_acc(:,5)...
                            max_acc(:,6)...
                            max_acc(:,7)...
                            ],...
                            '-',figName,plegends,...
                            'Speed at impact (m/s)','Max Acceleration (g)'...
                            ,true,figPath,figureFormat...%                             ,AxisPlots...
                            );
        hold on;
        plot(1.0,Q3.PeakAcc(5),'ok','lineWidth',LinesWidths,'MarkerSize',12);
        plot(1.5,Q3.PeakAcc(6),'ok','lineWidth',LinesWidths,'MarkerSize',12);
        plot(3.1,Q3.PeakAcc(7),'ok','lineWidth',LinesWidths,'MarkerSize',12);
        PicSize = [10 10 780 780];
        hLegend = legend(...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'horizontal',...
                  'location', 'northoutside' );
        set(gcf, 'Position', PicSize);
        if SAVE_PLOTS
             set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
         nfig = nfig+1;
        figName = 'weightSim-HIC-child-head';
%         plegends = material_names;
        minTime = 0;
        maxTime = method.time;
        AxisPlots = [minTime maxTime -100 7000];
        plotNpairedData(nfig,[operational_vel',... 
                               operational_vel', ... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                               operational_vel'... 
                                ],...
                            [HIC_tab(:,1),...
                            HIC_tab(:,2),...
                            HIC_tab(:,3)...
                            HIC_tab(:,4)...
                            HIC_tab(:,5)...s
                            HIC_tab(:,6)...
                            HIC_tab(:,7)...
                            ],...
                            '-',figName,plegends,...
                            'Speed at impact (m/s)','HIC'...
                            ,true,figPath,figureFormat...%                             ,AxisPlots...
                            );
        hold on;
        plot(1.0,Q3.HIC15_robot(5),'ok','lineWidth',LinesWidths,'MarkerSize',14);
        plot(1.5,Q3.HIC15_robot(6),'ok','lineWidth',LinesWidths,'MarkerSize',14);
        plot(3.1,Q3.HIC15_robot(7),'ok','lineWidth',LinesWidths,'MarkerSize',14);
        PicSize = [10 10 780 780];
        hLegend = legend(...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'horizontal',...
                  'location', 'northoutside' );
        set(gcf, 'Position', PicSize);
        if SAVE_PLOTS
             set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        %%
         nfig = nfig+1;
        figName = 'weightSim-HIC-weight-child-head';
%         plegends = material_names;
        minTime = 0;
        maxTime = method.time;
        X_data = weight_samples';
        Y_data = HIC_tab(1,:)';
%         AxisPlots = [10 max(X_data) 0 1100];
        AxisPlots = [10 40 0 1100];
        plegends = {};
        for j_speed=2:12
            X_data = [X_data, weight_samples'];
            Y_data = [Y_data, HIC_tab(j_speed,:)'];
            plegends{end+1} = num2str(operational_vel(j_speed));
        end
        
        plotNpairedData(nfig,X_data,Y_data,...
                            '-',figName,plegends,...
                            'Robot weight (kg)','HIC'...
                            ,true,figPath,figureFormat...%                             
                            ,AxisPlots...
                            ,5 ...
                            );
        hold on;
        plot(133,Q3.HIC15_robot(5),'ok','lineWidth',LinesWidths,'MarkerSize',14);
        plot(133,Q3.HIC15_robot(6),'ok','lineWidth',LinesWidths,'MarkerSize',14);
        plot(133,Q3.HIC15_robot(7),'ok','lineWidth',LinesWidths,'MarkerSize',14);
        PicSize = [10 10 780 780];
        hLegend = legend(...
                  plegends, ...
                  'FontName',Fonts,...
                  'FontSize', FontSizes,'FontWeight','bold',...
                  'orientation', 'vertical',...
                  'location', 'northeast' );
        set(gcf, 'Position', PicSize);
        if SAVE_PLOTS
             set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        

        %% ----- Contour map of Peak forces  ---------- %
        contour_len = 100;
        nfig = nfig + 1;
        figure(nfig)    
        Xrange=1:6;
        Zcontour = max_acc(:,Xrange);
        zmin = floor(min(Zcontour(:))); 
        zmax = ceil(max(Zcontour(:)));
        zinc = (zmax - zmin) / contour_len;
        zlevs = zmin:zinc:zmax;
        zindex = zlevs(find(zlevs>=69,1));
        zindex(end+1) = zlevs(find(zlevs>=105,1));
        if find(zlevs>=180,1)
            zindex(end+1) = zlevs(find(zlevs>=180,1));
        end
        if find(zlevs>=250,1)
            zindex(end+1) = zlevs(find(zlevs>=250,1));
        end
%         contourf(X_variable,operational_vel,Zcontour,'--');
        
        % Customized color map:    
        ColorDivergent= [
               57, 92, 107
               242, 244, 229
               211, 203, 146
               221,115,64%239,138,98
               142,16,30%178,24,43
                ]./255;
        LB=flipud(lbmap(256,'RedBlue'));%'BrownBlue'));
                % Setting the Zero value around a desired point:
                largest=abs(zmax);
                smallest=abs(zmin);
                indexValue = 180;     % value for which to set a particular color
                indexValue2 = 260;     % value for which to set a particular color
                topColor = ColorDivergent(5,:);%LB(end,:);         % color for maximum data value (red = [1 0 0])
                indexColor2 = ColorDivergent(4,:); % LB(128,:);       % color for indexed data value (white = [1 1 1])
                indexColor = ColorDivergent(2,:); % LB(128,:);       % color for indexed data value (white = [1 1 1])
                bottomcolor = ColorDivergent(1,:); %LB(1,:);      % color for minimum data value (blue = [0 0 1])
                % Calculate where proportionally indexValue lies between minimum and max
                index = contour_len*abs(indexValue-smallest)/(largest-smallest);
                index2 = contour_len*abs(indexValue2-smallest)/(largest-smallest);
                % Create color map ranging from bottom color to index color
                % Multipling number of points by 100 adds more resolution
                customCMap1 = [linspace(bottomcolor(1),indexColor(1),100*index)',...
                            linspace(bottomcolor(2),indexColor(2),100*index)',...
                            linspace(bottomcolor(3),indexColor(3),100*index)'];
                % Create color map ranging from index color to top color
                % Multipling number of points by 100 adds more resolution
                customCMap2 = [linspace(indexColor(1),indexColor2(1),100*(contour_len-index2))',...
                        linspace(indexColor(2),indexColor2(2),100*(contour_len-index2))',...
                        linspace(indexColor(3),indexColor2(3),100*(contour_len-index2))'];
                customCMap3 = [linspace(indexColor2(1),topColor(1),100*(contour_len-index2))',...
                            linspace(indexColor2(2),topColor(2),100*(contour_len-index2))',...
                            linspace(indexColor2(3),topColor(3),100*(contour_len-index2))'];
        customCMap = [customCMap1;customCMap2;customCMap3];  % Combine colormaps
        colormap(customCMap);
        
        contourf(X_variable(Xrange),operational_vel,Zcontour,zlevs,'edgecolor','none');
        hold on
        contour(X_variable(Xrange),operational_vel,Zcontour,zindex,'--k','LineWidth',3)
        
        cb = colorbar('southoutside');
        set(get(cb,'label'),'string','Peak Acceleration (g)');
        Ylabel = 'Operational velocity (m/s)';
        Xlabel= Variable2_label;
        figName = 'weightSim-Heatmap-Max-acceleration-Child-head';
        set(gcf, 'name', figName);
        set(gcf, 'Position', [10 10 880 1080]);
        set(gca,'FontName',Fonts,...
                'FontSize', FontSizes,...
                'LineWidth',LinesWidths);
        hYLabel=ylabel(Ylabel);
        hXLabel=xlabel(Xlabel);
            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'out'     , ... % 'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'on'      , ...
              'YMinorTick'  , 'on'      , ...
              'YGrid'       , 'off'      , ...
              'XColor'      , 'k', ...
              'YColor'      , 'k', ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
              'LineWidth'   , 1         );

        set([hXLabel, hYLabel]  , ...
                'FontName',  Fonts,...
                'FontSize',  FontSizes,...
                'color',     [0 0 0]);
        AxisPlots = [X_variable(1) X_variable(Xrange(end)) operational_vel(1) operational_vel(end)];
    %     hold on;
    %     for jj=1:length(failed_weight)
    %         sq = plot(failed_weight(jj),failed_height(jj),'h','Color','black','MarkerSize',6);
    %         set(sq, 'markerfacecolor', get(sq, 'color'));
    %     end
    %     
    %     for jj=1:length(failed_weight_sit)
    %         sq = plot(failed_weight_sit(jj),failed_height_sit(jj),'d','Color','black','MarkerSize',6);
    %         set(sq, 'markerfacecolor', get(sq, 'color'));
    %     end
    %     
        if (SAVE_PLOTS) 
            set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        
%% ----- Contour map of HIC ---------- %

       contour_len = 100;
        nfig = nfig + 1;
        figure(nfig)    
        Zcontour = HIC_tab(:,Xrange);
        zmin = floor(min(Zcontour(:))); 
        zmax = ceil(max(Zcontour(:)));
        zinc = (zmax - zmin) / contour_len;
        zlevs = zmin:zinc:zmax;
        zindex = zlevs(find(zlevs>=500,1));
%         zindex(end+1) = zlevs(find(zlevs>=700,1));
        if find(zlevs>=180,1)
            zindex(end+1) = zlevs(find(zlevs>=1000,1));
        end
%         contourf(X_variable,operational_vel,Zcontour,'--');
        contourf(X_variable(Xrange),operational_vel,Zcontour,zlevs,'edgecolor','none');
        hold on
        contour(X_variable(Xrange),operational_vel,Zcontour,zindex,'--k','LineWidth',3);

        % Customized color map:    
        ColorDivergent= [
               57, 92, 107
               242, 244, 229
               211, 203, 146
               221,115,64%239,138,98
               142,16,30%178,24,43
                ]./255;
        LB=flipud(lbmap(256,'RedBlue'));%'BrownBlue'));
                % Setting the Zero value around a desired point:
                largest=abs(zmax);
                smallest=abs(zmin);
                indexValue = 500;     % value for which to set a particular color
                indexValue2 = 1000;     % value for which to set a particular color
                topColor = ColorDivergent(5,:);%LB(end,:);         % color for maximum data value (red = [1 0 0])
                indexColor2 = ColorDivergent(4,:); % LB(128,:);       % color for indexed data value (white = [1 1 1])
                indexColor = ColorDivergent(2,:); % LB(128,:);       % color for indexed data value (white = [1 1 1])
                bottomcolor = ColorDivergent(1,:); %LB(1,:);      % color for minimum data value (blue = [0 0 1])
                % Calculate where proportionally indexValue lies between minimum and max
                index = contour_len*abs(indexValue-smallest)/(largest-smallest);
                index2 = contour_len*abs(indexValue2-smallest)/(largest-smallest);
                % Create color map ranging from bottom color to index color
                % Multipling number of points by 100 adds more resolution
                customCMap1 = [linspace(bottomcolor(1),indexColor(1),100*index)',...
                            linspace(bottomcolor(2),indexColor(2),100*index)',...
                            linspace(bottomcolor(3),indexColor(3),100*index)'];
                % Create color map ranging from index color to top color
                % Multipling number of points by 100 adds more resolution
                customCMap2 = [linspace(indexColor(1),indexColor2(1),100*(contour_len-index2))',...
                        linspace(indexColor(2),indexColor2(2),100*(contour_len-index2))',...
                        linspace(indexColor(3),indexColor2(3),100*(contour_len-index2))'];
                customCMap3 = [linspace(indexColor2(1),topColor(1),100*(contour_len-index2))',...
                            linspace(indexColor2(2),topColor(2),100*(contour_len-index2))',...
                            linspace(indexColor2(3),topColor(3),100*(contour_len-index2))'];
                customCMap = [customCMap1;customCMap2;customCMap3];  % Combine colormaps
                
        colormap(customCMap);
        
        cb = colorbar('southoutside');
        set(get(cb,'label'),'string','HIC_{15}'); 
        Ylabel='Operational velocity (m/s)';
        figName = 'weightSim-Heatmap-HIC-Child-head';
        set(gcf, 'name', figName);
        set(gcf, 'Position', [10 10 880 1080]);
        set(gca,'FontName',Fonts,...
                'FontSize', FontSizes,...
                'LineWidth',LinesWidths);
        hYLabel=ylabel(Ylabel);
        hXLabel=xlabel(Xlabel);
            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'out'     , ... % 'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'on'      , ...
              'YMinorTick'  , 'on'      , ...
              'YGrid'       , 'off'      , ...
              'XColor'      , 'k', ...
              'YColor'      , 'k', ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
              'LineWidth'   , 1         );

        set([hXLabel, hYLabel]  , ...
                'FontName',  Fonts,...
                'FontSize',  FontSizes,...
                'color',     [0 0 0]);

    %     hold on;
    %     for jj=1:length(failed_weight)
    %         sq = plot(failed_weight(jj),failed_height(jj),'h','Color','black','MarkerSize',6);
    %         set(sq, 'markerfacecolor', get(sq, 'color'));
    %     end
    %     
    %     for jj=1:length(failed_weight_sit)
    %         sq = plot(failed_weight_sit(jj),failed_height_sit(jj),'d','Color','black','MarkerSize',6);
    %         set(sq, 'markerfacecolor', get(sq, 'color'));
    %     end
    %     
        if (SAVE_PLOTS) 
            set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end

       end
%%
% %         close all
%         x_int = X_variable';
%         for i_vel=2:length(operational_vel)
%             x_int = [x_int; X_variable'];
%         end
%         y_int = operational_vel';
%         for i_vel=2:length(X_variable)
%             y_int = [y_int; operational_vel'];
%         end
%         nfig = nfig + 1;
%         figure(nfig)    
%         LB=flipud(lbmap(256,'BrownBlue'));%'BrownBlue'));
% %         % Scatter Plot Pareto Front
%         F = scatteredInterpolant(x_int,y_int,HIC_tab(:)...
%             ,'linear','none');
%         sgr = min(x_int):.1:max(x_int);
%         ygr = min(y_int):.1:max(y_int);
%         [XX,YY] = meshgrid(sgr,ygr);
%         ZZ = F(XX,YY);
%         nfig = nfig+1;
%         figure(nfig);
%         surf(XX,YY,ZZ,'LineStyle','none')
%         
% %         contourf(X_variable,operational_vel,HIC_tab,'--');
% %         colormap(LB);
%     %     colormap(lbmap(11))
%         cb = colorbar('eastoutside');
%         set(get(cb,'label'),'string','HIC_{15}');
%         Ylabel='Operational velocity (m/s)';
%         figName = 'weightSim-ScatterPlot-HIC-Child-head';
%         set(gcf, 'name', figName);
%         set(gcf, 'Position', [10 10 880 1080]);
%         set(gca,'FontName',Fonts,...
%                 'FontSize', FontSizes,...
%                 'LineWidth',LinesWidths);
%         hYLabel=ylabel(Ylabel);
%         hXLabel=xlabel(Xlabel);
%             set(gca, ...
%               'Box'         , 'on'     , ...
%               'TickDir'     , 'out'     , ... % 'TickLength'  , [.02 .02] , ...
%               'XMinorTick'  , 'on'      , ...
%               'YMinorTick'  , 'on'      , ...
%               'YGrid'       , 'off'      , ...
%               'XColor'      , 'k', ...
%               'YColor'      , 'k', ...%           'XTick'       , 0:round(m/10):(m+1), ... %           'YTick'       , Ymin:round((Ymax-Ymin)/10):Ymax, ...
%               'LineWidth'   , 1         );
% 
%         set([hXLabel, hYLabel]  , ...
%                 'FontName',  Fonts,...
%                 'FontSize',  FontSizes,...
%                 'color',     [0 0 0]);
% 
%     %     hold on;
%     %     for jj=1:length(failed_weight)
%     %         sq = plot(failed_weight(jj),failed_height(jj),'h','Color','black','MarkerSize',6);
%     %         set(sq, 'markerfacecolor', get(sq, 'color'));
%     %     end
%     %     
%     %     for jj=1:length(failed_weight_sit)
%     %         sq = plot(failed_weight_sit(jj),failed_height_sit(jj),'d','Color','black','MarkerSize',6);
%     %         set(sq, 'markerfacecolor', get(sq, 'color'));
%     %     end
%     %     
%         if (SAVE_PLOTS) 
%             set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
%             saveas(nfig,strcat(figPath,figName),figureFormat);
%         end
        