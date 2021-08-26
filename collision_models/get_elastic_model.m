%% Setting parameters of elastic modulus for roobt an human contact
% based on the input selection for known experimental conditions

function output_struct = get_elastic_model(model_part,input_struct)
    global adult_human child_head qolo_robot manipulator_robot child_chest child_leg
    output_struct = input_struct;
    switch (model_part)
        case {'qolo_driver_bumper'}
            output_struct.mass = qolo_robot.mass_w_driver;
            output_struct.elastic_mod_frame = qolo_robot.elastic_mod_frame;
            output_struct.elastic_mod_cover = qolo_robot.elastic_mod_robot_cover;
            output_struct.poisson_ratio_cover = qolo_robot.poisson_ratio_cover;
            output_struct.poisson_ratio = qolo_robot.poisson_ratio_robot;
            output_struct.inner_radius = qolo_robot.bumper_radius;
            output_struct.cover_width = qolo_robot.cover_width; 
            output_struct.radius = output_struct.cover_width + output_struct.inner_radius;

            % Parameters to fit from DATA:
            % Gain for considering the robot's larger elastic modulus compared with a expected soft-human body part.
            xgain = output_struct.xgainA; % 2 
            Egain = output_struct.EA; % 2.0e9; %% Fitted Gain --> To be determine
            hertz_coeff = output_struct.n_c;
            exp2 = (output_struct.elastic_mod_cover./output_struct.elastic_mod_frame).^output_struct.n_f;
            ratio_substrate = output_struct.elastic_mod_cover ./ output_struct.elastic_mod_frame;

        case {'qolo_bumper'}
            output_struct.mass = qolo_robot.mass;
            output_struct.elastic_mod_frame = qolo_robot.elastic_mod_frame;
            output_struct.elastic_mod_cover = qolo_robot.elastic_mod_robot_cover;
            output_struct.poisson_ratio_cover = qolo_robot.poisson_ratio_cover;
            output_struct.poisson_ratio = qolo_robot.poisson_ratio_robot;
            output_struct.inner_radius = qolo_robot.bumper_radius;
            output_struct.cover_width = qolo_robot.cover_width; 
            output_struct.radius = output_struct.cover_width + output_struct.inner_radius;                

            % Parameters to fit from DATA:
            % Gain for considering the robot's larger elastic modulus compared with a expected soft-human body part.
            xgain = output_struct.xgainA; % 2 
            Egain = output_struct.EA; % 2.0e9; %% Fitted Gain --> To be determine

            exp2 = (output_struct.elastic_mod_cover./output_struct.elastic_mod_frame).^output_struct.n_f;
            hertz_coeff = output_struct.n_c;
            ratio_substrate = output_struct.elastic_mod_cover ./ output_struct.elastic_mod_frame;
            
        case {'manipulator'}
            output_struct.mass = manipulator_robot.mass;
            output_struct.elastic_mod_frame = manipulator_robot.elastic_mod_frame;
            output_struct.elastic_mod_cover = manipulator_robot.elastic_mod_robot_cover;
            output_struct.poisson_ratio_cover = manipulator_robot.poisson_ratio_cover;
            output_struct.poisson_ratio = manipulator_robot.poisson_ratio_robot;
            output_struct.inner_radius = manipulator_robot.bumper_radius;
            output_struct.cover_width = manipulator_robot.cover_width; 
            output_struct.radius = output_struct.cover_width + output_struct.inner_radius;                
            % Parameters to fit from DATA:
            % Gain for considering the robot's larger elastic modulus compared with a expected soft-human body part.
            xgain = output_struct.xgainA; % 1 
            Egain = output_struct.EA; % 2.0e9; %% Fitted Gain --> To be determine
            
            exp2 = (output_struct.elastic_mod_cover./output_struct.elastic_mod_frame).^output_struct.n_f;
            hertz_coeff = output_struct.n_c;
            ratio_substrate = output_struct.elastic_mod_cover ./ output_struct.elastic_mod_frame;
            
        case{'head_child'}
            output_struct.mass = child_head.head_mass;
            output_struct.elastic_mod_bone = child_head.elastic_mod_bone;
            output_struct.elastic_mod_cover = child_head.elastic_mod_scalp;
            output_struct.poisson_ratio_cover = child_head.poisson_ratio_skin;
            output_struct.poisson_ratio = child_head.poisson_ratio_human_scalp;
            output_struct.inner_radius = child_head.human_radius_head;
%             output_struct.cover_width = child_head.scalp_width; % bs
            output_struct.radius = output_struct.cover_width + output_struct.inner_radius;
            
           xgain = output_struct.xgainB; % 
           Egain = output_struct.EB; % 2.0e9; %% Fitted Gain --> To be determine
%                 EB = 1; %% Fitted Gain --> To be determine
            exp2 = (output_struct.elastic_mod_cover./output_struct.elastic_mod_bone).^output_struct.n_f;
            hertz_coeff = output_struct.n_s;
            ratio_substrate = output_struct.elastic_mod_cover ./ output_struct.elastic_mod_bone;

        case{'head_adult'}
            output_struct.mass = adult_human.head_mass;
            output_struct.elastic_mod_bone = adult_human.elastic_mod_bone;
            output_struct.elastic_mod_cover = adult_human.elastic_mod_scalp;
            output_struct.poisson_ratio_cover = adult_human.poisson_ratio_skin;
            output_struct.poisson_ratio = adult_human.poisson_ratio_human_scalp;
            output_struct.inner_radius = adult_human.human_radius_head;
%             output_struct.cover_width = adult_human.scalp_width;
            output_struct.radius = output_struct.cover_width + output_struct.inner_radius;
            xgain = output_struct.xgainB; % 1 
            Egain = output_struct.EB; % 5.0e9; %% Fitted Gain --> To be determine
%                 EB = 1; %% Fitted Gain --> To be determine
            exp2 = (output_struct.elastic_mod_cover./output_struct.elastic_mod_bone).^output_struct.n_f;
            hertz_coeff = output_struct.n_s;
            ratio_substrate = output_struct.elastic_mod_cover ./ output_struct.elastic_mod_bone;

        case{'chest_child'}
            output_struct.mass = child_chest.mass;
            output_struct.elastic_mod_bone = child_chest.elastic_mod_bone;
            output_struct.elastic_mod_cover = child_chest.elastic_mod_scalp;
            output_struct.poisson_ratio_cover = child_chest.poisson_ratio_skin;
            output_struct.poisson_ratio = child_chest.poisson_ratio_rib;
            output_struct.inner_radius = child_chest.human_radius_chest;
%             output_struct.cover_width = child_head.scalp_width; % bs
            output_struct.radius = output_struct.cover_width + output_struct.inner_radius;
            
           xgain = output_struct.xgainB; % output_struct.xgainB; % 
           Egain = output_struct.EB; % 2.0e9; %% Fitted Gain --> To be determine
%                 EB = 1; %% Fitted Gain --> To be determine
            exp2 = (output_struct.elastic_mod_cover./output_struct.elastic_mod_bone).^output_struct.n_f;
            hertz_coeff = output_struct.n_s;
            ratio_substrate = output_struct.elastic_mod_cover ./ output_struct.elastic_mod_bone;

        case{'tibia_child'}
            output_struct.mass = child_leg.legs;%child_leg.mass;
            output_struct.elastic_mod_bone = child_leg.elastic_mod_bone;
            output_struct.elastic_mod_cover = child_leg.elastic_mod_scalp;
            output_struct.poisson_ratio_cover = child_leg.poisson_ratio_skin;
            output_struct.poisson_ratio = child_leg.poisson_ratio_human_leg;
            output_struct.inner_radius = child_leg.human_radius_tibia;
%             output_struct.cover_width = child_head.scalp_width; % bs
            output_struct.radius = output_struct.cover_width + output_struct.inner_radius;
            
           xgain = output_struct.xgainB; % 
           Egain = output_struct.EB; % 2.0e9; %% Fitted Gain --> To be determine
%                 EB = 1; %% Fitted Gain --> To be determine
            exp2 = (output_struct.elastic_mod_cover./output_struct.elastic_mod_bone).^output_struct.n_f;
            hertz_coeff = output_struct.n_s;
            ratio_substrate = output_struct.elastic_mod_cover ./ output_struct.elastic_mod_bone;

        case{'tibia_adult'}
            output_struct.mass = adult_human.tibia_mass;
            output_struct.elastic_mod_bone = adult_human.elastic_mod_bone;
            output_struct.elastic_mod_cover = adult_human.elastic_mod_scalp;
            output_struct.poisson_ratio_cover = adult_human.poisson_ratio_skin;
            output_struct.poisson_ratio = adult_human.poisson_ratio_human_leg;
            output_struct.inner_radius = adult_human.human_radius_tibia;
%             output_struct.cover_width = adult_human.scalp_width;
            output_struct.radius = output_struct.cover_width + output_struct.inner_radius;
            xgain = output_struct.xgainB; % 1 
            Egain = output_struct.EB; % 5.0e9; %% Fitted Gain --> To be determine
%                 EB = 1; %% Fitted Gain --> To be determine
            exp2 = (output_struct.elastic_mod_cover./output_struct.elastic_mod_bone).^output_struct.n_f;
            hertz_coeff = output_struct.n_s;
            ratio_substrate = output_struct.elastic_mod_cover ./ output_struct.elastic_mod_bone;
%             % Deformation is expected to be on the negative plane wihtin contact
%             eff_elastic_mod  = @(deformation) Egain.*(1 + ( ((ratio_substrate)-1)...
%                                  .*exp( -((deformation./(xgain .* output_struct.cover_width)).^output_struct.n_s).*exp2 ) ));
        otherwise

    end
    
    output_struct.eff_elastic_mod  = @(deformation) Egain.*(1 + ( (ratio_substrate-1)...
                                 .*exp( ((deformation./(xgain .* output_struct.cover_width)).^hertz_coeff).*exp2 ) ));

end

