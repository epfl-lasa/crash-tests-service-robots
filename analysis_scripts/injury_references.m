% Injury Metrics from LIterature:


        %% ================= Data of Injury limits for safety ==============%
        %  All Values are given for the standard Hybrid-III (H3) Dummy
        % Q3 Dummy values need to be converted using the given constants
        % for AIS --> check pAIS function for detailed values.
        
        % ======== Head Criteria values ======= %
        % Source: [EuroNcap 2015]
        % Higher performance limit 
        % HIC15 < 500
        % Resultant Acc. 3 msec exceedence < 72g
        %
        % Lower performance and capping limit 
        % HIC15 < 700  % (20% ﻿risk of injury ? AIS3 [1,2])
        % Resultant Acc. 3 msec exceedence < 80g
        
        % Values for H3 from EuroNcap 2008
        H3encapH.pAIS = 0.05;
        H3encapL.pAIS = 0.20;
        H3encap50.pAIS = 0.50;
        
        H3encapH.HIC15 = 500;       % 5% p(AIS+3)
        H3encapH.a3ms= 72;          % 5% p(AIS+3)
        H3encapL.HIC15 = 700;    % 20% p(AIS+3)
        H3encapL.a3ms= 80;    % 20% p(AIS+3)
        
        H3encap50.HIC15 = 1000; % 50% p(AIS+3)
        H3encap50.a3ms = 86; % 50% p(AIS+3)
        H3encap50.pAIS = 0.5;
        
        % Values for Q3: from EEVC report and CHILD project
        Q3eevcL.HIC15 = 790;  % 20% p(AIS+3)
        Q3eevcL.a3ms= 84;     % 20% p(AIS+3)
        
        Q3eevc50.HIC15 = 940; % 50% p(AIS+3)
        Q3eevc50.a3ms= 92;     % 50% p(AIS+3)
        
        % ======== Neck Injury Criteria values ======= %
        % Source: [EuroNcap 2015] Neck
        % Higher performance limit 
        % Shear force Fx = 1.9kN @ 0 msec, 1.2kN @ 25 - 35msec, 1.1kN @ 45msec 
        % Tension force Fz  2.7kN @ 0 msec, 2.3kN @ 35msec, 1.1kN @ 60msec
        % Extension  My =  42Nm 
        %
        % Lower performance and capping limit 
        % Shear force Fx = 3.1kN @ 0msec, 1.5kN @ 25 - 35msec, 1.1kN @ 45msec*
        % Tension force Fz = 3.3kN @ 0msec, 2.9kN @ 35msec, 1.1kN @ 60msec*
        % Extension My = 57Nm* (Significant risk of injury [4])
        % (*EEVC Limits)
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        %﻿Note: Neck Shear and Tension are assessed from cumulative 
        % exceedence plots, with the limits being functions of time. 
        % By interpolation, a plot of points against time is computed. 
        % The minimum point on this plot gives the score. Plots of the 
        % limits and colour rating boundaries are given in Appendix I
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        
        % Values for H3 from EuroNcap 2008
        H3encapH.pAIS = 0.05;
        H3encapH.Fz = 1900;   % 5% p(AIS+3)
        H3encapH.Fx = 2700;   % 5% p(AIS+3)
        H3encapH.My = 42;     % 5% p(AIS+3)
        
        H3encapL.pAIS = 0.20;
        H3encapL.Fz = 3300;    % 20% p(AIS+3)
        H3encapL.Fx = 3100;    % 20% p(AIS+3)
        H3encapL.My = 57;    % 20% p(AIS+3)
        
        Q3encapL.pAIS = 0.20;
        Q3encapL.Fz = 1350;    % 20% p(AIS+3)
        Q3encapL.Fx = 1200;    % 20% p(AIS+3)
        Q3encapL.My = 63;    % 20% p(AIS+3)
        
        % Values for Q3: from EEVC report and CHILD project
        Q3eevcL.Fz = 1555;  % 20% p(AIS+3)
        Q3eevcL.My= 79;     % 20% p(AIS+3)
        Q3eevc50.pAIS = 0.50;
        Q3eevc50.Fz = 1705; % 50% p(AIS+3)
        Q3eevc50.My= 96;     % 50% p(AIS+3)
        
        % ======== Chest Injury Criteria values ======= %
        % Source: [EuroNcap 2015] 
        % Higher performance limit 
        % Compression < 22mm  (5% risk of injury > AIS3 [5]) 
        % Viscous Criterion 0.5m/sec (5% risk of injury > AIS4)
        %
        % Lower performance and capping limit 
        % Compression < 42mm  --> WHY?? 
        % Viscous Criterion 1.0m/sec (25% risk of injury > AIS4)
        
        % Values for H3 from EuroNcap 2015
        
        H3encapH.CC = 22; % 5% p(AIS+3)
        H3encapH.VC = 0.5; % 5% p(AIS+3)
        
        H3encapL.CC = 42;    % 20% p(AIS+3)
        H3encapL.VC = 1.0;    % 20% p(AIS+3)
        
        % ﻿because of the low elastic modulus of their ribs, children 
        % can undergo large sternal deflections without rib fractures 
        % but with organ injury. 
        % The risk of AIS4+ thoracic organ injury, particularly heart injury,
        % must be taken into account.
        
        % Values for Q3: from EEVC report and CHILD project
        Q3eevcL.pAIS = 0.20;
        Q3eevcL.CC = 33;    % 20% p(AIS+3)
        Q3eevcL.VC = 1.0;   % 20% p(AIS+3)
        Q3eevc50.CC = 46;   % 50% p(AIS+3)
        
        
        % ======== Tibia Injury Criteria values ======= %
        % ﻿Higher performance limit 
        % Tibia Index (TI) = 0.4
        % Tibia Compression = 2 kN
        
        % Lower performance limit 
        % Tibia Index = 1.3* 
        % Tibia Compression = 8kN*  10%﻿risk of fracture [4,8]
        % EEVC limits
        % Values for H3 from EuroNcap 2015
        H3encapH.TI = 0.4;  % 5% p(AIS+3)
        H3encapH.TC = 2000; % 5% p(AIS+3)
        H3encapL.TI = 1.3;	% 20% p(AIS+3)
        H3encapL.TC = 8000; % 20% p(AIS+3)
        
         % ======== Femur/Knee/Pelvis Injury Criteria values ======= %
        % Higher performance limit 
        % Femur compression = 3.8kN  (5% risk of pelvis injury [6])
        % Knee slider compressive displacement = 6mm 
        
        % Lower performance limit 
        % Femur Compression  9.07kN @ 0msec, 7.56kN @ ? 10msec* % (Femur fracture limit [4]) 
        % Knee slider compressive displacement  = 15mm*
        % (Cruciate ligament failure limit [4,7]) (*EEVC Limit)
        % Values for H3 from EuroNcap 2015
        H3encapH.femur = 3800;
        H3encapH.kneeD = 6; %[mm]
        H3encapL.femur = 9070;    % 20% p(AIS+3)
        H3encapL.kneeD = 15;    % 20% p(AIS+3)
        
        % ========= Bones Force Injury Criteria =============%
        % [Haddadin 2009] details these values from multiple literature
        % used in tests with the average 50-percetile H3
        % Frontal Bone (forehead) = 4kN
        % Mandible  = 1.78kN
        boneFracture.frontal = 4000;
        boneFracture.mandibleF = 1780;
        boneFracture.mandibleL = 890;
        boneFracture.neck = 190; %[Nm]  tolerance of the neck flexion
        
        % ﻿According to [24] the maximum tolerable contact force for
        % the chest lies within the tolerance band of [1.15 . . . 1.7] kN
        % ﻿L. Patrick 1998, “Impact Force Deflection of the Human Thorax,” SAE Paper No.811014
        boneFracture.chestL = 1150;
        boneFracture.chestH = 1700;