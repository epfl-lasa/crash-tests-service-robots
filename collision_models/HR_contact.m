%% HCF Model
% Function to estimate the force excerted in deformation ckntact between a
% robot and a human body part based on a Hertzian Reference Frame between a
% deformable

% author: Diego Paez-G.

function [Fext, Krh, elastic_mod]  = HR_contact(state,robot,human,...
                                    varargin)
    % Hunt-Crossley Model output of contact force

    p = inputParser;
    chkscalar     = @(x) isnumeric(x) && isscalar(x) ; %&& (x >= 0)
    chkvec     = @(x) validateattributes(x ,{'double'},{'column'}, mfilename,'outputPath',1);
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
    chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'state',chkvec);
    addRequired(p,'robot',@isstruct);
    addRequired(p,'human',@isstruct);
    % Optional Inputs

    parse(p,state,robot,human,varargin{:});
    deformation = state(1);
    deformation_dt = state(2);
%     deformation = p.Results.deformation;
%     robot = p.Results.robot;
%     human = p.Results.human;
    
    global DEBUG_FLAG
%        Er = elastic_mod_robot
%        Eh = elastic_mod_human
%        Vc = poisson_ratio_robot_cover
%        Vs = poisson_ratio_human (scalp)
%        Eh = elastic_mod_human
%        Er = elastic_mod_robot
%        Eh = elastic_mod_human
%        Er = elastic_mod_robot
%        Rc = radius_human = scalp_width+human_radius_adult[human_part_id]
%        Rs = radius_robot = cover_width+robot_radius


%         Expecting  deformation in the negative plane for the
%         current equations to work properly
%         deformation = -deformation;

    % Checking if collision looses contact
    if deformation < 0
%         fprintf("Collision off-contact: %.2f \n",deformation)
        deformation = 0;
    end
    
    if ~isreal(deformation)
%         fprintf("Deformation format incorrect (img): %.2f \n",deformation)
        deformation = 0;
    end

%     if deformation <= (robot.deformation_sm) % bs_{max}
    % % % % USING STIFFNESS FROM SKIN-TO-COVER
        Krh = robot.stiffness_hr;
%         Fext = - robot.stiffness_kcs * (deformation^robot.n_cs) * (deformation_dt *(3/2)*robot.damping_cs + 1);

    % % % % USING STIFFNESS FROM BONE-TO-COVER
%         Krh = robot.stiffness_kcb ;
        Fext = - Krh * (deformation^robot.n_hr) * (deformation_dt *(3/2)*robot.damping_hr + 1);
        
        elastic_mod(1,1) = human.elastic_mod_cover;
        elastic_mod(2,1)= robot.elastic_mod_cover;
        
        if DEBUG_FLAG && ~isreal(Fext)
            fprintf("imaginary Fext: %f \n", Fext);
            disp(Krh)
            disp(deformation)
        end

%     elseif deformation > (robot.deformation_sm) && deformation <= (robot.deformation_cm) % bc_{max}
%     else
%         Krh = robot.stiffness_kcb;
% %         Fext = - (Krh * ((deformation - robot.deformation_sm)^robot.n_cb)...
% %                         + robot.force_skin_max);
%                                 
%         Fext = - robot.stiffness_kcb * ((deformation - robot.deformation_sm)^robot.n_cb)...
%                     * (deformation_dt *(3/2)*robot.damping_cs + 1) + robot.force_skin_max;
% 
%         elastic_mod(1,1) = human.elastic_mod_bone;
%         elastic_mod(2,1)= robot.elastic_mod_cover;
% % 
%         if DEBUG_FLAG && ~isreal(Fext)
%             fprintf("imaginary Fext b_sm: %f \n", Fext);
%             disp(Krh)
%             disp(deformation)
%         end
% %     elseif deformation > (robot.deformation_cm) %\deformation > bc_{max}
% %         Krh = robot.stiffness_krb;
% %         Fext = - (Krh * ((deformation - robot.deformation_cm)^robot.n_rb)...
% %                         + robot.force_cover_max);
% %         elastic_mod(1,1) = human.elastic_mod_bone;
% %         elastic_mod(2,1)= robot.elastic_mod_frame;
% % 
% %         if DEBUG_FLAG && ~isreal(Fext)
% %             fprintf("imaginary Fext b_cm: %f \n", Fext);
% %             disp(Krh)
% %             disp(deformation)
% %         end
%     end

end
