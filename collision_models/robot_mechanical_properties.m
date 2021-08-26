%% Global variables with mechanical properties of the robots' tested
    global adult_human child_head qolo_robot manipulator_robot child_chest child_leg

    %  *MODEL BASED IMPACT FORCE SIMULATION*
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

    
    % Adult Head data used from [Park et al.2011]
    adult_human.human_radius_head = 0.077; %0.056;
    adult_human.human_radius_tibia = human_radius_adult(5);
    adult_human.elastic_mod_bone = 6.5*1e9; %Eb
    adult_human.elastic_mod_scalp = 16.7*1e6; %Es
    adult_human.poisson_ratio_human_scalp = 0.22; % Vb
    adult_human.poisson_ratio_human_leg = 0.269;
    adult_human.poisson_ratio_skin = 0.42; % Vs
    adult_human.scalp_width = 0.003; %bs
    adult_human.tibia_mass = mass_adult(5);
    adult_human.head_mass = 4.5; %mass_adult(11);
    
    child_head.human_radius_head = 0.056; % Circunference= 0.3519 m
    child_head.human_radius_tibia = 0.039;
    child_head.elastic_mod_bone = 4.7*1e9; %Eb  [Irwin1997]% DOI:10.1155/2016/1768512
    child_head.elastic_mod_scalp = 16.7*1e6; %Es
    child_head.poisson_ratio_human_scalp = 0.26; % 0.28 --> 3-months old
    child_head.poisson_ratio_human_leg = 0.269;
    child_head.poisson_ratio_skin = 0.42; % 
    child_head.scalp_width = 0.003; %bs = 0.003 (human skin)
%     child_head.tibia_mass = 12; % Whole Q3 mass
    child_head.head_mass = 2.7; % Head Child Q3 / with Neck = 3.17kg
   
    child_chest.human_radius_chest = 0.156; % Diameter=
    child_chest.elastic_mod_bone = 2.3*1e9; %Eb Adults: 14.5 GPa
    child_chest.youngs_modulus = 2.3e6; % (Mizuno et al., 2005)
    child_chest.elastic_mod_scalp = 16.7*1e6; %Es
    child_chest.poisson_ratio_human_scalp = 0.26; % 0.28 --> 3-months old
    child_chest.poisson_ratio_rib = 0.379; % Adult value
    child_chest.poisson_ratio_human_leg = 0.269;
    child_chest.poisson_ratio_skin = 0.42;
    child_chest.scalp_width = 0.050; %bs = 0.003 (human skin)
    child_chest.mass = 14.59; % Whole mass Child Q3
    child_chest.torso = 6.30; % Torso Child Q3
    
    child_leg.human_radius_tibia = 0.039;
    child_leg.elastic_mod_bone = 4.7*1e9; %Eb Adults: 14.5 GPa
    child_leg.youngs_modulus = 2.3e6; % (Mizuno et al., 2005)
    child_leg.elastic_mod_scalp = 16.7*1e6; %Es
    child_leg.poisson_ratio_human_leg = 0.269;
    child_leg.poisson_ratio_skin = 0.42;
    child_leg.skin_width = 0.003; %bs = 0.003 (human skin)
    child_leg.mass = 14.59; % Whole mass Child Q3
    child_leg.legs = 3.54; % Torso Child Q3
    
    qolo_robot.part = 'qolo_driver_bumper'; 
    qolo_robot.elastic_mod_frame = 368*1e9; %Nylon - Ec % 68*1e9; % Aluminium Er
    qolo_robot.elastic_mod_robot_cover = 3.3*1e9; %Nylon - Ec
    qolo_robot.poisson_ratio_robot = 0.33;
    qolo_robot.poisson_ratio_cover = 0.41; %
    qolo_robot.bumper_radius = 0.400; % Bumper radius
    qolo_robot.cover_width = 0.0; %bc
    qolo_robot.mass_w_driver = sum(mass_robot)+driver_mass;
    qolo_robot.mass = sum(mass_robot);
    
    % For collision data from Manipulators from [Park et.al.2011]
    manipulator_robot.part = 'manipulator'; 
    manipulator_robot.mass = 5.31;
    manipulator_robot.speed = 7.05;
    manipulator_robot.elastic_mod_robot_cover = 70*1e6; %Ec - Polystyrene-100:48.3
    manipulator_robot.poisson_ratio_cover = 0.25; % Vc - used  0 - 0.25
    manipulator_robot.elastic_mod_frame = 70*1e9; %Er
    manipulator_robot.poisson_ratio_robot = 0.3; % Vr
    manipulator_robot.bumper_radius = 0.01; % Rr 0.015 for Manipulator
    manipulator_robot.cover_width = 0.02; %bc
    
    
    %% From Experimental data of service crash
    service_test{1} = qolo_robot;
    service_test{1}.part = 'qolo_driver_bumper'; % For collision data from crash testing
    service_test{1}.mass = 133;
    service_test{1}.speed = 1.0;
    service_test{2} = service_test{1};
    service_test{2}.speed = 1.5;
    service_test{3} = service_test{1};
    service_test{3}.speed = 3.1;
    service_test{4} = service_test{1};
    service_test{4}.speed = 3.2;
    
    service_test{5} = qolo_robot;
    service_test{5}.mass = 133;
    service_test{5}.speed = 1.0;
    service_test{5}.part = 'qolo_driver_bumper'; % For collision data from crash testing
    service_test{6} = service_test{5};
    service_test{6}.speed = 1.5;
    service_test{7} = service_test{5};
    service_test{7}.speed = 3.1;
    
    % service_test{16-19}.part = 'qolo_bumper'; % For collision data from crash testing
    service_test{16} = qolo_robot;
    service_test{16}.mass = 60;
    service_test{16}.speed = 1.0;
    service_test{16}.part = 'qolo_bumper'; % For collision data from crash testing
    service_test{17} = service_test{16};
    service_test{17}.speed = 1.5;
    service_test{18} = service_test{16};
    service_test{18}.speed = 3.1;
    service_test{19} = service_test{16};
    service_test{19}.speed = 3.0;
    
    service_test{8} = qolo_robot;
    service_test{8}.mass = 133;
    service_test{8}.speed = 1.0;
    service_test{8}.part = 'qolo_driver_bumper'; % For collision data from crash testing
    service_test{9} = service_test{8};
    service_test{9}.speed = 1.5;
    service_test{10} = service_test{8};
    service_test{10}.speed = 3.1;
    
    % H3-Adult collision:
    service_test{11} = qolo_robot;
    service_test{11}.mass = 133;
    service_test{11}.speed = 1.0;
    service_test{11}.part = 'qolo_driver_bumper'; % For collision data from crash testing
    service_test{12} = service_test{11};
    service_test{12}.speed = 1.5;
    service_test{13} = service_test{11};
    service_test{13}.speed = 3.1;
    service_test{14} = service_test{13};
    service_test{15} = service_test{13};
    
    %% From experimental data in [Park et al.2011]
    % EXP.15 from 
    manipulator_data{15} = manipulator_robot;
    manipulator_data{15}.mass = 5.31;
    manipulator_data{15}.speed = 6.29;
    manipulator_data{15}.elastic_mod_robot_cover = 70*1e6; %Ec - Polystyrene-100:48.3
    manipulator_data{15}.head_radius = 0.077;
    %EXP.17 from [Park et al.2011]
    manipulator_data{17} = manipulator_robot;
    manipulator_data{17}.mass = 5.30;
    manipulator_data{17}.speed = 7.33;
    manipulator_data{17}.elastic_mod_robot_cover = 130*1e6; %Ec - Polystyrene-100:48.3
    manipulator_data{17}.head_radius = 0.079;
    
    %EXP.19 from [Park et al.2011]
    manipulator_data{19} = manipulator_robot;
    manipulator_data{19}.mass = 5.31;
    manipulator_data{19}.speed = 7.05;
    manipulator_data{19}.elastic_mod_robot_cover = 70*1e6; %Ec - Polystyrene-100:48.3
    manipulator_data{19}.head_radius = 0.075;
    
    %EXP.26 from [Park et al.2011]
    manipulator_data{26} = manipulator_robot;
    manipulator_data{26}.mass = 5.31; 
    manipulator_data{26}.speed = 4.63;
    manipulator_data{26}.elastic_mod_robot_cover = 100*1e6; %Ec - Polystyrene-100:48.3
    manipulator_data{26}.head_radius = 0.078;
    %EXP.27 from [Park et al.2011]
    manipulator_data{27} = manipulator_robot;
    manipulator_data{27}.mass = 5.18; 
    manipulator_data{27}.speed = 3.8;
    manipulator_data{27}.elastic_mod_robot_cover = 30*1e6; %Ec - Polystyrene-100:48.3
    manipulator_data{27}.head_radius = 0.078;
    %EXP.31 from [Park et al.2011]
    manipulator_data{31} = manipulator_robot;
    manipulator_data{31}.mass = 5.31; 
    manipulator_data{31}.speed = 7.05;
    manipulator_data{31}.elastic_mod_robot_cover = 100*1e6; %Ec - Polystyrene-100:48.3
    manipulator_data{31}.head_radius = 0.078;
    