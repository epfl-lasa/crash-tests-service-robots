%% HCF Model
% Function to estimate the force excerted in deformation ckntact between a
% robot and a human body part based on a Hertzian Reference Frame between a
% deformable

% author: Diego Paez-G.

function [Fext, Krh, elastic_mod]  = HCF_contact(state,robot,human,...
                                    varargin)
    % Hunt-Crossley Model output of contact force

    p = inputParser;
    chkscalar     = @(x) isnumeric(x) && isscalar(x) ; %&& (x >= 0)
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
    chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'state',chkscalar);
    addRequired(p,'robot',@isstruct);
    addRequired(p,'human',@isstruct);
    % Optional Inputs

    parse(p,state,robot,human,varargin{:});
    deformation = state(1);
    deformation_dt = state(2);
    
    robot = p.Results.robot;
    human = p.Results.human;

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

    if deformation <= (robot.deformation_sm) % bs_{max}
        Krh = robot.stiffness_kcs;
        Fext = -robot.stiffness_kcs * (deformation^robot.n_cs);
%         Fext = - robot.stiffness_kcs * (deformation^robot.n_cs) * (deformation_dt *(3/2)*robot.damping_cs + 1);

        elastic_mod(1,1) = human.elastic_mod_cover;
        elastic_mod(2,1)= robot.elastic_mod_cover;

        if DEBUG_FLAG && ~isreal(Fext)
            fprintf("imaginary Fext: %f \n", Fext);
            disp(robot.stiffness_kcs)
            disp(deformation)
        end

    elseif deformation > (robot.deformation_sm) && deformation <= (robot.deformation_cm) % bc_{max}
        Krh = robot.stiffness_kcb;
        Fext = - (robot.stiffness_kcb * ((deformation - robot.deformation_sm)^robot.n_cb)...
                        + robot.force_skin_max);

        elastic_mod(1,1) = human.elastic_mod_bone;
        elastic_mod(2,1)= robot.elastic_mod_cover;

        if DEBUG_FLAG && ~isreal(Fext)
            fprintf("imaginary Fext b_sm: %f \n", Fext);
            disp(robot.stiffness_kcb)
            disp(deformation)
        end
    elseif deformation > (robot.deformation_cm) %\deformation > bc_{max}
        Krh = robot.stiffness_krb;
        Fext = - (robot.stiffness_krb * ((deformation - robot.deformation_cm)^robot.n_rb)...
                        + robot.force_cover_max);
        elastic_mod(1,1) = human.elastic_mod_bone;
        elastic_mod(2,1)= robot.elastic_mod_frame;

        if DEBUG_FLAG && ~isreal(Fext)
            fprintf("imaginary Fext b_cm: %f \n", Fext);
            disp(robot.stiffness_krb)
            disp(deformation)
        end
    end

end
