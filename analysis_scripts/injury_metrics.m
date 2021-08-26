
    %% List of Setups from the data recordings:
    % % Each scenario comprises of 3 speeds at contact --> [1.0, 1.5 3.1] [m/s]
    % 4 setups with child dumm Q3 (3-years-old dummy) [1.05m height / 15kg weight]
    % %     Setup A: Dummy Q3 impact at the Chest - [133kg carrier robot]
    % %     Setup A2: Dummy Q3 impact at the Chest - [60kg carrier robot]
    % %     Setup B: Dummy Q3 impact at the Head - [133kg carrier robot]
    % %     Setup C: Dummy Q3 impact at the Legs (Tibia / fibia)  - [133kg carrier robot]

    % Setups with adult dumm HIII (50-percentile adult) [1.77m height / 81.5kg weight] 
    % %     Setup D: Dummy H3 impact at the Legs (Tibia / fibia)  - [133kg carrier robot]
    
    % Author: Diego F. Paez G.
    % Copyright 2020, Dr. Diego Paez-G.
    
    %% Script for gettinng standard Injury Metric
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

    %% Options    
        SAVE_TAB = true;
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
        figureFormat = 'epsc';%'epsc';
        Fonts = 'Times New Roman';
        load('ColorsData'); 
        
    %% Load Data-set of Collisions   
        % Calling data of injury from AIS car crashing
        injury_references;
        % lading crash tests:
        load('test_folders.mat')
        load('Q3_raw_collision_struct.mat')
        load('H3_raw_collision_struct.mat')
        load('filtered_collision_struct.mat')

        load('Q3_metrics.mat')
        load('H3_metrics.mat')
        data_q3 = [1:10,16:19];
        q3_testNames = [{'Thorax-$1.0m/s$'}...
                     {'Thorax-$1.5m/s$'}...
                     {'Thorax-$3.1m/s$'}...
                     {'Thorax-$3.2m/s$'}...
                     {'Head-$1.0m/s$'}...
                     {'Head-$1.5m/s$'}...
                     {'Head-$3.1m/s$'}...
                     {'Tibia-$1.0m/s$'}...
                     {'Tibia-$1.5m/s$'}...
                     {'Tibia-$3.1m/s$'}...
                     {'$^*$ Thorax-$1.0m/s$'}...
                     {'$^*$ Thorax-$1.5m/s$'}...
                     {'$^*$ Thorax-$3.1m/s$'}...
                     {'$^*$ Thorax-$3.0m/s$'}...
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
        Q3.weight = 15; %[kg]
        data_h3 = 11:15;
        
        h3_testNames = [{'1. $1.0m/s$'}... %test_11
                         {'2. $1.5m/s$'}...%test_12
                         {'3. $3.1m/s$'}...%test_13
                         {'4. $3.1m/s$'}...  %test_14  %SUCCESFULL IMPACT
                         {'5. $3.1m/s$'}...%test_15
                         ];
         H3.testSpeed = [1.0 1.5 3.1 3.1 3.1];
         H3.testMass = [133 133 133 133 133];
         H3.weight = 81.5; %[kg]
        % Constants from the current dataset
        Freq = 20000;
        Ts = 1/Freq; % Sampling period in [s]
     
       % Data taken from Crash report - manually labeled the start of
        % contact on the ground;
%         [1]'Test_01_Q3-Ribcage' [1.0m/s]
%         [2]'Test_02_Q3-Ribcage' [1.5m/s]
%         [3]'Test_03-2_Q3-Ribcage' [3.1m/s]
%         [4]'Test_03_Q3-Ribcage_FAILED' [3.2m/s]
%         [5]'Test_04_Q3-Head' [1.0m/s]
%         [6]'Test_05_Q3-Head' [1.5m/s]
%         [7]'Test_06_Q3-Head' [3.1m/s]
%         [8]'Test_07_Q3-Legs' [1.0m/s]
%         [9]'Test_08_Q3-Legs' [1.5m/s]
%         [10]'Test_09_Q3-Legs' [3.1m/s]
%         [11] 'Test_10_H3-Legs' [1.0m/s]
%         [12] 'Test_11_H3-Legs' [1.5m/s]
%         [13] 'Test_12-2_H3-Legs_FAILED' [3.1m/s]
%         [14] 'Test_12-3_H3-Legs' [3.1m/s]
%         [15] 'Test_12_H3-Legs_FAILED' [3.1m/s]
%         [16]'Test_13_Q3-Ribcage' [1.0m/s]
%         [17]'Test_14_Q3-Ribcage' [1.5m/s]
%         [18]'Test_15-2_Q3-Ribcage' [3.1m/s]
%         [19]'Test_15_Q3-Ribcage_FAILED' [3.0m/s]
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
                      
%% ################### Getting Neck Injury Criteria ###################                      

    Q3.NFz =  []; Q3.NFz_impact =  [];
    Q3.NMy =  []; Q3.NMy_impact =  [];
    Q3.PeakAcc = [];
    minX = -5; maxX = 200;
    impactRange = find(data_raw_Q3.test_1.time>minX,1):...
                        find(data_raw_Q3.test_1.time>maxX,1);
    for itest = data_q3
        Q3.NFz_impact(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(itest),'.neck.Fz(impactRange)))'])./1000;
        Q3.NMy_impact(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(itest),'.neck.My(impactRange)))'])./1000;
        Q3.NFz(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(itest),'.neck.Fz))'])./1000;
        Q3.NMy(end+1) =  eval(['max(abs(data_raw_Q3.test_',num2str(itest),'.neck.My))'])./1000;
        Q3.PeakAcc(end+1) = eval(['max(data_raw_Q3.test_',num2str(itest),'.head.areas(impactRange));']);
    end
        
%% ################### Exporting Data Table for LATEX ###################
%     Table of results for Q3(Child dummy 3-years-old):
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

    for i_indx = data_q3
        Q3.testNum(end+1) = i_indx;
        Q3.fileName{end+1} = eval(['metrics_Q3.test_',num2str(i_indx),'.TestName']);
        Q3.HIC15_robot(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.HIC15_robot']);
        Q3.HIC15_ground(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.HIC15_ground']);
        Q3.Acc_3m(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.head_a_3ms']);
        Q3.Nij(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.Nij']);
        Q3.ThCC(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.ThCC']);
        Q3.Thorax_a3ms(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.Thorax_a3ms']);
        Q3.Vc(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.VC']);
        Q3.CTI(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.CTI']);
        eval(['metrics_Q3.test_',num2str(i_indx),...
             '.PeakForce = max(data_filtered.test_',num2str(i_indx),'.impact.Fx);'])
        Q3.Force(end+1) = eval(['metrics_Q3.test_',num2str(i_indx),'.PeakForce']);
    end
    % Correcting Zero Values in HIC-15 (imported this way from excel),
    % however, it should be Non-applicable
    Q3.HIC15_robot(~Q3.HIC15_robot)=NaN;
    Q3.testNames = q3_testNames;

%%  Table of results for H3(50-percentil adult human dummy):
    H3.testNum = [];

    H3.HIC15_ground = [];
    H3.TCFC_right = [];
    H3.TCFC_left  = [];
    H3.TI_lower_right = [];
    H3.TI_lower_left = [];
    H3.TI_upper_right = [];
    H3.TI_upper_left = [];
    H3.Force = [];

    for i_indx = data_h3
        H3.testNum(end+1) = i_indx;
        H3.HIC15_ground(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.HIC15_ground']);
        H3.TCFC_right(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TCFC_right']);
        H3.TCFC_left(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TCFC_left']);
        H3.TI_lower_right(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TI_lower_right']);
        H3.TI_lower_left(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TI_lower_left']);
        H3.TI_upper_right(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TI_upper_right']);
        H3.TI_upper_left(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.TI_upper_left']);
        eval(['metrics_H3.test_',num2str(i_indx),...
             '.PeakForce = max(data_filtered.test_',num2str(i_indx),'.impact.Fx);'])
        H3.Force(end+1) = eval(['metrics_H3.test_',num2str(i_indx),'.PeakForce']);

    end
    H3.testNames = h3_testNames;

    % Getting RTI crieteria

    H3.RTI_lower_right = [];
    H3.RTI_lower_left = [];
    H3.RTI_upper_right = [];
    H3.RTI_upper_left = [];
    H3.RTI_lower_right_idx = [];
    H3.RTI_lower_left_idx = [];
    H3.RTI_upper_right_idx = [];
    H3.RTI_upper_left_idx = [];
    H3.hic_ground = [];
    H3.acc3ms_ground = [];
    H3.acc_peak_ground = [];
    H3.ground_interval = []; 
    H3.ground_acc_interval = []; 
    
    for i_indx = data_h3
        mint = -20;
        maxt = 1000;
        rangeImpact = find(eval(['data_raw_H3.test_',num2str(i_indx),'.time'])>mint,1):...
                            find(eval(['data_raw_H3.test_',num2str(i_indx),'.time'])>maxt,1);

        [H3.RTI_lower_right(end+1),...
         H3.RTI_lower_right_idx(end+1)]  = RTI_criteria(...
                                   eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loRFz(rangeImpact)'])...
                                  ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loRMx(rangeImpact)'])...
                                  ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loRMx(rangeImpact)'])...
                                            );
        [H3.RTI_lower_left(end+1),...
            H3.RTI_lower_left_idx(end+1)]  = RTI_criteria(...
                                           eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loLFz(rangeImpact)'])...
                                          ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loLMx(rangeImpact)'])...
                                          ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loLMx(rangeImpact)'])...
                                            );
        [H3.RTI_upper_right(end+1),...
            H3.RTI_upper_right_idx(end+1)]  = RTI_criteria(...
                                           eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loRFz(rangeImpact)'])...
                                          ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.upRMx(rangeImpact)'])...
                                          ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.upRMy(rangeImpact)'])...
                                            );
        [H3.RTI_upper_left(end+1),...
            H3.RTI_upper_left_idx(end+1)]  = RTI_criteria(...
                                           eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.loLFz'])...
                                          ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.upLMx'])...
                                          ,eval(['data_raw_H3.test_',num2str(i_indx),'.tibia.upLMy'])...
                                            );
        % HIC assessment for blunt impact to the head on the ground (concrete)
        minX = -20;
        maxX = 200;
        evalRange = eval(['find(data_raw_H3.test_',num2str(i_indx),...
                '.time>groundTimes(i_indx)+minX,1):find(data_raw_H3.test_',num2str(i_indx),...
                '.time>groundTimes(i_indx)+maxX,1)']);

        [H3.hic_ground(end+1),H3.ground_interval(end+1,:)] = ...
                                eval(['HIC15_criteria(data_raw_H3.test_',num2str(i_indx),...
                                    '.time(evalRange).*1e-3,data_raw_H3.test_',num2str(i_indx),'.head.areas(evalRange))']);

        [H3.acc3ms_ground(end+1),H3.ground_acc_interval(end+1,:)] = ...
                                eval(['acc3ms_criteria(data_raw_H3.test_',num2str(i_indx),...
                                    '.time(evalRange),data_raw_H3.test_',num2str(i_indx),'.head.areas(evalRange))']);
        H3.acc_peak_ground(end+1) = eval(['max(data_raw_H3.test_',num2str(i_indx),'.head.areas(evalRange));']);

    end
        
    %%  HIC-15 Analysis for Q3 Dummy tests -  Acceleration at the Head for Q3
    % Value from literature and standards:
    % Palisson, A., Cassan, F., Trosseille, X., Lesire, P., & Alonzo, F. (2007). 
    % Estimating Q3 dummy injury criteria for frontal impacts using the child project 
    % results and scaling reference values. In International IRCOBI Conference on the 
    % Biomechanics of Injury (pp. 263–276). Netherlands.

    % HIC assessment for blunt impact to the head on the ground (concrete)
    minX = -20;
    maxX = 200;
    Q3_coeff=1;
    Q3.hic_value = zeros(1,length(Q3.testNum));
    Q3.hic_interval = zeros(length(Q3.testNum),2);
    Q3.acc3ms = zeros(1,length(Q3.testNum));
    Q3.acc_interval = zeros(length(Q3.testNum),2);
    jindx=1;
    for i_test=Q3.testNum
         evalRange = eval(['find(data_raw_Q3.test_',num2str(i_test),...
                    '.time>minX,1):find(data_raw_Q3.test_',num2str(i_test),...
                    '.time>maxX,1)']);
        [Q3.hic_value(jindx),Q3.hic_interval(jindx,:)] = ...
                                    eval(['HIC15_criteria(data_raw_Q3.test_',num2str(i_test),...
                                        '.time(evalRange).*1e-3,data_raw_Q3.test_',num2str(i_test),'.head.areas(evalRange))']);
                                    
        [Q3.acc3ms(jindx),Q3.acc_interval(jindx,:)] = ...
                                    eval(['acc3ms_criteria(data_raw_Q3.test_',num2str(i_test),...
                                        '.time(evalRange),data_raw_Q3.test_',num2str(i_test),'.head.areas(evalRange))']);
        jindx = jindx+1;
    end
    
%  % HIC assessment for Ground Impacts:
    jindx=1;
    for i_test=Q3.testNum
         evalRange = eval(['find(data_raw_Q3.test_',num2str(i_test),...
                    '.time>groundTimes(i_test)+minX,1):find(data_raw_Q3.test_',num2str(i_test),...
                    '.time>groundTimes(i_test)+maxX,1)']);
        [Q3.hic_ground(jindx),Q3.ground_interval(i_test,:)] = ...
                                    eval(['HIC15_criteria(data_raw_Q3.test_',num2str(i_test),...
                                        '.time(evalRange).*1e-3,data_raw_Q3.test_',num2str(i_test),'.head.areas(evalRange))']);
                                    
        [Q3.acc3ms_ground(jindx),Q3.ground_acc_interval(i_test,:)] = ...
                                    eval(['acc3ms_criteria(data_raw_Q3.test_',num2str(i_test),...
                                        '.time(evalRange),data_raw_Q3.test_',num2str(i_test),'.head.areas(evalRange))']);
        Q3.acc_peak_ground(jindx) = eval(['max(data_raw_Q3.test_',num2str(i_test),'.head.areas(evalRange));']);
        jindx = jindx+1;
    end
    
    %% Plotting all injuries for tests with Q3 Dummy
        
        plot_injuries_Q3;
        
        %% ==================== Assessment of the AIS levels ============= %
        
        %  HIC-15 conversion to AIS levels
        % ======================= Setup D ========================== %
        % % % Robot Mass = 133 kg 
        % % % Dummy H-3: 50-percentile adult
        figName = 'H3-AIS_HIC15-Robot-133kg-ground-impact'; 
        typeInjury = 'HIC15_u';
        typeDummy = 'H3';
        % Tests on H3 where 1-10
        for itest=[1,2,3,4,5]
            [H3.AIS_ground(itest,:), H3.AISlevel(itest)] = pAIS(H3.HIC15_ground(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);   
            
        end
        H3.AIS_ground(itest,:)
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % ======================= Setup A-B-C ========================== %
        % % % Robot Mass: 133 kg 
        % % % Dummy Q-3: 50-percentile 3-years-old
        figName = 'Q3-AIS_HIC15-Robot-133kg-ground-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on H3 were 11-15
        typeInjury = 'HIC15_u';
        typeDummy = 'Q3';
        for itest=1:10
            [Q3.AIS_ground(itest,:),Q3.AISlevel_ground(itest)] = pAIS(Q3.HIC15_ground(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % ======================= Setup A-2 ========================== %
        % % % Robot Mass: 60 kg 
        % % % Dummy Q-3: 50-percentile 3-years-old
        figName = 'Q3-AIS_HIC15-Robot-60kg-ground-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on Q3 were 16-19
        typeInjury = 'HIC15_u';
        typeDummy = 'Q3';
        for itest=[11:14]
            [Q3.AIS_ground(itest,:),Q3.AISlevel_ground(itest)] = pAIS(Q3.HIC15_ground(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % ======================= Setup B ========================== %
        % % % Setup B: Dummy Q3 impact at the Head - [133kg carrier robot]
        figName = 'Q3-AIS_HIC15-Robot-133kg-head-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        typeInjury = 'HIC15_u';
        typeDummy = 'Q3';
        % Tests on Q3-head were 5-7
        for itest=[5:7]
            [Q3.AIS_HIC(itest,:),Q3.AISlevel_HIC(itest)] = pAIS(Q3.HIC15_robot(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        Q3.AIS_HIC(8:14,:)=zeros(7,3);
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        %% Neck Injury Criteria from Neck Tension/Extension - Q3-dummy
        % ======================= Setup A-A2-B-C ========================== %
        % % % Robot Mass: 133 kg 
        % % % Dummy Q-3: 50-percentile 3-years-old
        figName = 'Q3-AIS_NFz-Robot-direct-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on H3 were 11-15
        typeInjury = 'NFz';
        typeDummy = 'Q3';
        for itest=[1:14]
            [Q3.AIS_NFz(itest,:),Q3.AISlevel_NFz(itest)] = pAIS(Q3.NFz_impact(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        %  Thorax Compression Criteria (CC) Analysis for Q3-dummy
        % ======================= Setup A ========================== %
        % % % Setup A: Dummy Q3 impact at the Chest - [133kg carrier robot]
        figName = 'Q3-AIS_ThCC-Robot-133kg-ground-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on Q3 were 16-19
        typeInjury = 'ThCC';
        typeDummy = 'Q3';
        for itest=[1:4]
            [Q3.AIS_ThCC(itest,:),Q3.AISlevel_ThCC(itest)] = pAIS(Q3.ThCC(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end        
        
        % ======================= Setup A-2 ========================== %
        % % % Robot Mass: 60 kg
        % % % Dummy Q-3: 50-percentile 3-years-old
        figName = 'Q3-AIS_ThCC-Robot-60kg-ground-impact'; 
        nfig = nfig+ 1;
        figure(nfig);
        % Tests on Q3 were 16-19
        typeInjury = 'ThCC';
        typeDummy = 'Q3';
        for itest=[11:14]
            [Q3.AIS_ThCC(itest,:),Q3.AISlevel_ThCC(itest)] = pAIS(Q3.ThCC(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
        end
        
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        % Haddadin-2008:
% AIS(F(∆xH)) --> Probabilty of injury from [27 - 
% AIS(F(∆xH)) = 0.859 + 0.000652*F(∆xH).
        
        
        %%  Lower Leg - Tibia Injury probability
        % ======================= Setup D ========================== %
        % Dummy H-3: 50-percentile adult and Robot 133kg
        nfig = nfig +1;
        for itest=[1,2,3,4,5]
            H3.pFract_right(itest) = pfract_tibia(H3.TCFC_right(itest)./1e3,'M',70,H3.weight,...
                                        DRAW_PLOTS,nfig);
        end
        
        nfig = nfig +1;
        for itest=[1,2,3,4,5]
            H3.pFract_left(itest) = pfract_tibia(H3.TCFC_left(itest)./1e3,'M',40,H3.weight,...
                                        DRAW_PLOTS,nfig);
                                    hold on;
            H3.pFract_left_f(itest) = pfract_tibia(H3.TCFC_left(itest)./1e3,'F',75,H3.weight,...
                                        DRAW_PLOTS,nfig);
        end
        figName = 'H3-Fracture-Robot-133kg-right'; 
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        %% ----------- pAIS+2(RTI) ----------- %
        figName = 'H3-AIS_RTI-Robot-133kg-right'; 
        nfig = nfig +1;
        typeInjury = 'RTI';
        typeDummy = 'H3';
        % Tests on H3 where 1-10
        for itest=[1,2,3,4,5]
            [H3.AIS_RTI_ur(itest,:), ~] = pAIS(H3.RTI_upper_right(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
            [H3.AIS_RTI_lr(itest,:), ~] = pAIS(H3.RTI_lower_right(itest),...
                                    typeDummy,typeInjury,...
                                    false,nfig+1);
        end
        H3.AIS_RTI_right = [];
        H3.AIS_RTI_right = max( [ H3.AIS_RTI_ur(:,2) H3.AIS_RTI_lr(:,2)],[],2);
        PicSize = [10 10 800 800];
        set(gcf, 'Position', PicSize);
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        figName = 'H3-AIS_RTI-Robot-133kg-left'; 
        nfig = nfig+1;
        for itest=[1,2,3,4,5]
            [H3.AIS_RTI_ul(itest,:), H3.AISlevel_TI(itest)] = pAIS(H3.RTI_upper_left(itest),...
                                    typeDummy,typeInjury,...
                                    DRAW_PLOTS,nfig);
            [H3.AIS_RTI_ll(itest,:), H3.AISlevel_TI(itest)] = pAIS(H3.RTI_lower_left(itest),...
                                    typeDummy,typeInjury,...
                                    false,nfig+1);
        end
        H3.AIS_RTI_left = [];
        H3.AIS_RTI_left = max( [ H3.AIS_RTI_ul(:,2) H3.AIS_RTI_ll(:,2)],[],2);
        set(gcf, 'Position', PicSize);
        if SAVE_PLOTS
            saveas(nfig,strcat(figPath,figName),figureFormat);
        end
        
        H3.AIS_RTI = max( [ H3.AIS_RTI_left H3.AIS_RTI_right],[],2 );
        
%% ==========  Summarizing results of all injury metrics ========== %

%      Plotting Each metric pAIS comapred with the IARV:
%       For Q3 Dummy = Q3eevcL / Q3eevc50
%       For H3 Dummy = H3encapH / H3encapL / H3encap50
        typeDummy = 'Q3'; 
        typeInjury = 'HIC15_u';
        Q3eevcL.HIC15 = 500; % New 2020 - EuroNcap for Q6
        AIS3Q3.headL = pAIS(Q3eevcL.HIC15,...
                    typeDummy,typeInjury,true,1);
           % Adult
        typeDummy = 'H3';    
        AIS3H3.headH = pAIS(H3encapH.HIC15,...
                    typeDummy,typeInjury,true,1);
                
        typeInjury = 'ThCC';
        AIS3Q3.chestL = pAIS(Q3eevcL.CC,...
                    typeDummy,typeInjury,false,1);
        
        typeDummy = 'H3'; 
        typeInjury = 'HIC15';
        AIS3H3.headL = pAIS(H3encapL.HIC15,...
                    typeDummy,typeInjury,false,1);
        typeInjury = 'ThCC';
        AIS3H3.chestL = pAIS(H3encapL.CC,...
                    typeDummy,typeInjury,false,1);
                
        typeInjury = 'HIC15';
        AIS3H3.headH = pAIS(H3encapH.HIC15,...
                    typeDummy,typeInjury,false,1);
        typeInjury = 'ThCC';
        AIS3H3.chestH = pAIS(H3encapH.CC,...
                    typeDummy,typeInjury,false,1);
        
        %% ========= Exporting the metric results and pAIS+3 =========== %
        % ---------- Results for Q3 Child-dummy ----------- %
        Q3.pAIS3 = max([Q3.AIS_HIC(:,2) Q3.AIS_ThCC(:,3) Q3.AIS_NFz_impact(:,3)]')';
        
        table_indx3 = [13;3;7;10;14;4];  % 4 --> 3.2 m/s, 14 --> 3.0 m/s
        table_indx2 = [12;2;6;9];
        table_indx1 = [11;1;5;8];
        
        tb_indx = [table_indx3; table_indx2; table_indx1];
        rowNames = [{'1.0 Thorax (133kg)'}...
                     {'1.5 Thorax (133kg)'}...
                     {'3.1 Thorax (133kg)'}...
                     {'3.2 Thorax (133kg)'}...
                     {'1.0 Head'}...
                     {'1.5 Head'}...
                     {'3.1 Head'}...
                     {'1.0 Tibia'}...
                     {'1.5 Tibia'}...
                     {'3.1 Tibia'}...
                     {'1.0 Thorax (60kg)'}...
                     {'1.5 Thorax (60kg)'}...
                     {'3.1 Thorax (60kg)'}...
                     {'3.0 Thorax (60kg)'}...
                    ...
                    ];
        
        % Exporting Latex Table
        Q3.metrics_table = table( Q3.testSpeed(tb_indx)', Q3.testMass(tb_indx)', ...
                                Q3.HIC15_robot(tb_indx)',Q3.Acc_3m(tb_indx)',Q3.PeakAcc(tb_indx)'...
                                ,Q3.ThCC(tb_indx)',Q3.Thorax_a3ms(tb_indx)'...
                                ,Q3.NFz(tb_indx)',Q3.Force(tb_indx)'.*1e-3,Q3.pAIS3(tb_indx).*100 ...
                                );
        inputl.tableColLabels = {'Vel (m/s)','Mass (kg)',...
                                 '$HIC15$','$Head Acc_{3ms}$ (g)','Head Peak Acc (g)',...
                                'CD (mm)','Thx $Acc_{3ms}$'...
                                ,'Neck Fz (kN)','Peak Force (kN)'...
                                ,'p(AIS+3)  (\%)'...
                                };

        Q3.metrics_table.Properties.RowNames = rowNames(tb_indx);
        Q3.metrics_table.Properties.VariableNames = inputl.tableColLabels;

        inputl.data = Q3.metrics_table;
        inputl.dataFormat = {'%.1f',1,'%.0f',2,'%.1f',4,'%.3f',2,'%.1f',1};
        inputl.tableColumnAlignment = 'c';
    %     inputl.dataFormatMode = 'column';
        latex_tot = latexTable(inputl);
        if SAVE_TAB
            fileID = fopen([outputPath,'/Q3_pAIS.txt'],'w');
            formatSpec = '%s\n';
            [nrows,ncols] = size(latex_tot);
            for row = 1:nrows
                fprintf(fileID,formatSpec,latex_tot{row,:});
            end
            fclose(fileID);
        end
        % Exporting table to Excel:
        filename = [outputPath,'/Q3_pAIS.xlsx'];
        writetable(Q3.metrics_table,filename,'Sheet',1,'Range','A1')
    
        
        %% ---------- Results for H3 Adult-dummy ----------- %
        H3.metrics_table = table(H3.Force'.*1e-3,...
                                H3.TCFC_right'.*1e-3, H3.TCFC_left'.*1e-3,...  H3.TI_lower_right',H3.TI_lower_left',...
                                H3.TI_upper_right',H3.TI_upper_left',...
                                H3.AIS_RTI.*100, ...
                                H3.pFract_left'.*100, ...
                                H3.pFract_left_f'.*100 ...
                                );
        inputl.tableColLabels = {'Peak Force (kN)',...
                                    '$TCFC_{r}$ (kN)', '$TCFC_{l}$ (kN)',...%                                     'TI low-right','TI low-left',...
                                    '$TI_{r}$','$TI_{l}$'...
                                    ,'p(AIS+2) (\%)'...
                                    ,'pF(70,M) (\%)'...
                                    ,'pF(70,F) (\%)'...
                                    };

        H3.metrics_table.Properties.RowNames = H3.testNames;
        H3.metrics_table.Properties.VariableNames = inputl.tableColLabels;

        inputl.data = H3.metrics_table;
        inputl.dataFormat = {'%.3f',3,'%.2f',2,'%.1f',3};
        inputl.tableColumnAlignment = 'c';
        inputl.dataFormatMode = 'column';

        latex_tot = latexTable(inputl);
    
        if SAVE_TAB
            fileID = fopen([outputPath,'/H3_pAIS.txt'],'w');
                formatSpec = '%s\n';
                [nrows,ncols] = size(latex_tot);
                for row = 1:nrows
                    fprintf(fileID,formatSpec,latex_tot{row,:});
                end
            fclose(fileID);
        end
        
        % Exporting table to Excel:
        filename = [outputPath,'/H3_pAIS.xlsx'];
        writetable(H3.metrics_table,filename,'Sheet',1,'Range','A1')
       