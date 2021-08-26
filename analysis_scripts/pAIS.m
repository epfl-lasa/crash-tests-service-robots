% % Computing AIS (Abbreviated Injury Scale from Injury metrics (NFz, Thcc, HIC15, HIC36)
% Author: Diego F. Paez G.
% Date: 1 Dec 2020
%% pAIS v1.01
% Inputs:
%           criteriaValue: [REQ'D] scalar{double}; Column-wise vector of sampling times
%           typeDummy: [OPTIONAL] {array}; Type of Dummy - [H3 or Q3] % can be extended to other Q1 Q1.5 Q6
%           typeInjury,:   [OPTIONAL] {array};         
%               [HIC15 or HIC36 
%               [a3ms]---> in [g]
%               [NFz, Nij] --> in [kN]
%               [thCC] --> in [mm]
%           ShowPlots:  [OPTIONAL]  {logical}    ;    Plot AIS scales and results (DEFAULT = FALSE)
%           figPath:  [OPTIONAL]  {char} ; path to save plots
%           nfig:  [OPTIONAL]  {scalar} ; figure number

% Outputs:
%           AIS_p :     scalar {double} Prbability of Injury in the given scale [0-1]
%           AIS_level:: scalar {double}    ;  Estimated AIS to be used
% Examples:
%          [AIScol,AISlevel] = pAIS(700,...
%                                     'Q3','HIC15',...
%                                     true,1);    
% Copyright 2020, Dr. Diego Paez-G.
%%%
function [AISp,AISlevel] = pAIS(criteriaValue,typeDummy,typeInjury,...
                                varargin)
    %        Parse User Inputs/Outputs                                        
    p = inputParser;
    chkscalar     = @(x) isnumeric(x) && isscalar(x) && (x >= 0);
    chknum     = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    chkchar     = @(x) ischar(x);
    chkcell     = @(x) iscell(x);
%     chkstring     = @(x) validateattributes(x ,{'string'});

    % Required Inputs
    addRequired(p,'criteriaValue',chkscalar);
    % Optional Inputs
    addRequired(p,'typeDummy' , chkchar)
    addRequired(p,'typeInjury', chkchar)
    addOptional(p,'ShowPlots'   ,false      ,@islogical);
    addOptional(p,'nfig',1,chkscalar);
    parse(p,criteriaValue,typeDummy,typeInjury,varargin{:});
    
    %% =============== Plots setup ===================% 
    AxisPlots = [0 2000 0 1];
    PicSize = [10 10 780 480];
    FigureFile = 'png';
    FaceALphas = 0.18;
    FontSizes = 28;
    MarkersSizes = 14;
    LinesWidths = 2.8;
    figureFormat = 'epsc'; %'png'
    Fonts = 'Times New Roman';
    
    %% =============== AIS conversion constants per level ===============%
    
    % ============= Head Injury Criteria ============= %
    % From [NHSTA-2004, Kuppa]  --> ﻿ES-2re DUMMY (side impact dummy)
    % [NHSTA-1999] --> shows the same values for AIS2+
    % where φ is the cumulative normal distribution 
    % µ=6.96352 and σ=0.84664 for AIS 2+ head injuries, 
    % µ=7.45231 and σ=0.73998 for AIS 3+ head injuries, 
    % µ=7.65605 and σ=0.60580 for AIS 4+ head injuries.
    % mu = [6.96352 7.45231 7.65605];
    %sigma = [0.84664 0.73998 0.60580];
    AIScoefH3.HIC36 = [6.96352 0.84664; %AIS2
                        7.45231 0.73998; %AIS3
                        7.65605 0.60580 ]; %AIS4
    
    % Accordigly to [NHSTA-2008] AIS+3 for HIC15 used the same parameters as HIC36
    % [NHSTA-1999] shows the same values for AIS2
	AIScoefH3.HIC15_u = AIScoefH3.HIC36;
    
	% However, [Haddadin2007-2012] showed these values for HIC15 to AIS3
    % ﻿The predicted distribution of head injury incidence was derived 
    % from the following injury risk probability formula 
    
    % (Prasad and Mertz estimated head injury risk as a function of HIC): AIS 1+:
    % AIS 2+: AIS 3+: AIS 4+: AIS 5+: Fatal:
    % [1 + exp((1.54 + 200/HIC) – 0.0065 x HIC)]-1
    % [1 + exp((2.49 + 200/HIC) – 0.00483 x HIC)]-1 
    % [1 + exp((3.39 + 200/HIC) – 0.00372 x HIC)]-1 
    % [1 + exp((4.9 + 200/HIC) – 0.00351 x HIC)]-1 
    % [1 + exp((7.82 + 200/HIC) – 0.00429 x HIC)]-1 
    % [1 + exp((12.24 + 200/HIC) – 0.00565 x HIC)]-1
    AIScoefH3.HIC15 = [1.54, 200, 0.0065; % AIS1
                       2.49, 200, 0.00483; % AIS2
                       3.39, 200, 0.00372; %AIS3
                       4.9, 200, 0.00351; %AIS4
                       7.82, 200, 0.00429; %AIS5
                       12.24, 200, 0.00565;]; %AIS6

    % ============= Neck Injury Criteria ============= %
    % From [NHSTA-2008]
    % AIS_p(3) = 1 / (1 + exp(3.2269-1.9688.*Nij));   
    % From [NHSTA-1999]: AIS2-4
    AIScoefH3.Nij = [2.054, 1.195; %AIS2
                    3.2269, 1.9688; %AIS3
                    2.693, 1.195;  %AIS4
                    3.817, 1.195];  %AIS5
                
    % Using Input forcess on tension or compression in [kN]
    AIScoefH3.NFz = [10.9745, 2.375; %AIS3
                    10.9745, 2.375; %AIS3
                    10.9745, 2.375; %AIS3
                    ];
   
    % ============= Chest Deflection Criteria ============= %
    % From [NHSTA-2008]
    % AIS_p(3) = 1 / (1 + exp(10.5456-1.568.*(CC^0.4612)));              
    AIScoefH3.thCC = [  10.5456, 1.568, 0.4612; %AIS3
                        10.5456, 1.568, 0.4612; %AIS3
                        10.5456, 1.568, 0.4612; %AIS3
                    ];  
    
    % From [NHSTA-2004, Kuppa] --> ﻿ES-2re DUMMY
    % AIS_p(3) = 1 / (1 + exp(2.0975-0.0482.*CC));            
    %     AIScoefH3.CC = [2.0975, 0.0482; % AIS3
    %                     3.4335, 0.0482]; % AIS4
                
    % ============= Abdominal Criteria ============= %            
    %     Maximum Abdominal Force
    %     1/(1+exp(abdomen(iAIS,1)-abdomen(iAIS,2).*F))
    AIScoefH3.abdomen = [6.403 0.00163; %AIS2
                        7.5969 0.0011]; %AIS3
                        
    % ============= Pelvic Injury Criteria ============= %  
    %     Maximum Pelvic Force
    %     1/(1+exp(pelvic(iAIS,1)-pelvic(iAIS,2).*F))
    AIScoefH3.pelvic = [6.403 0.00163; %AIS2
                        7.5969 0.0011]; %AIS3
    
    % ============= Femur Injury Criteria ============= %  
    % From [NHSTA-2008]
    %     Maximum Femur Force in --> [kN]
    %     1/(1+exp(femur(iAIS,1)-femur(iAIS,2).*F))
    AIScoefH3.femur = [5.795 0.5196]; %AIS2
	
    % Joint Probability: P = 1 - (1-p.head)*(1-p.neck)*(1-p.chest)*(1-p.femur)

    % ============= Tibia Injury Criteria ============= %  
    % From [NHSTA-2008]
    %     Maximum RTI --> [ 0-2]
    %     1 - exp( (ln(RTI) - coeffs(iAIS,1))/coeffs(iAIS,2) ))
    AIScoefH3.RTI = [0.2728 0.2468;...
                    0.2728 0.2468]; %AIS2
    
    % From [Kuppa-2001]
    %    F [kN]--> uper tibia axial force
    %     p(AIS+2) - tibia bone fracture --> [ 0-2]
    %     1/(1+exp(coeff(iAIS,1)-coeff(iAIS,2).*F + coeff(iAIS,2).*mass))
    AIScoefH3.tibia_upper = [0.5204 0.8189 0.0686 %AIS2
                            0.5204 0.8189 0.0686]; %AIS2
	
    % From [Kuppa-2001]
    %    F [kN]--> lower tibia axial force
    %     p(AIS+2) - tibia bone fracture 
    %     1/(1+exp(coeff(iAIS,1)-coeff(iAIS,2).*F))
    AIScoefH3.tibia_lower = [4.572 0.670%AIS2
                             4.572 0.670]; %AIS2       
                    
    
    %% Adapting the probabilities of injury accordingly to the dummy used
    % These values were taken from the Q-project results on biomechanical
    % anlaysis of the poperties of Q-series dummies compared with the
    % standard adult dummy series Hybrid-III for a male adult 50-percentile
    
    % REF:  EECV project reported in \cite{Wismans2008}
    switch (typeDummy)
        case {'Q0'}
            scaleFactor.acc = 0.99;
            scaleFactor.HIC = 0.49;
            scaleFactor.NF = 0.13;
            scaleFactor.NM = 0.07;
            scaleFactor.txbelt = 0.84;
            scaleFactor.txbag = 0.20;
            scaleFactor.txacc = 1.8;
            % There is not clear definition for TI becuase Q dummies do not include lower-leg sensors
            scaleFactor.RTI = 1.0; 
        case {'Q1'}
            scaleFactor.acc = 0.84;
            scaleFactor.HIC = 0.45;
            scaleFactor.NF = 0.29;
            scaleFactor.NM = 0.22;
            scaleFactor.txbelt = 1.03;
            scaleFactor.txbag = 0.33;
            scaleFactor.txacc = 1.5;
            % There is not clear definition for TI becuase Q dummies do not include lower-leg sensors
            scaleFactor.RTI = 1.0; 
        case {'Q1.5'}
            scaleFactor.acc = 0.87;
            scaleFactor.HIC = 0.53;
            scaleFactor.NF = 0.33;
            scaleFactor.NM = 0.25;
            scaleFactor.txbelt = 0.98;
            scaleFactor.txbag = 0.36;
            scaleFactor.txacc = 1.51;
            % There is not clear definition for TI becuase Q dummies do not include lower-leg sensors
            scaleFactor.RTI = 1.0; 
        case {'Q3'}
            scaleFactor.acc = 0.94;
            scaleFactor.HIC = 0.71;
            scaleFactor.NF = 0.41;
            scaleFactor.NM = 0.33;
            scaleFactor.txbelt = 0.93;
            scaleFactor.txbag = 0.44;
            scaleFactor.txacc = 1.58;
            % There is not clear definition for TI becuase Q dummies do not include lower-leg sensors
            scaleFactor.RTI = 1.0; 
        case {'Q6'}
            scaleFactor.acc = 1.03;
            scaleFactor.HIC = 0.98;
            scaleFactor.NF = 0.56;
            scaleFactor.NM = 0.50;
            scaleFactor.txbelt = 0.84;
            scaleFactor.txbag = 0.56;
            scaleFactor.txacc = 1.63;
            % There is not clear definition for TI becuase Q dummies do not include lower-leg sensors
            scaleFactor.RTI = 1.0; 
        otherwise
            % case {'H3'}
            scaleFactor.acc = 1;
            scaleFactor.HIC = 1;
            scaleFactor.NF = 1;
            scaleFactor.NM = 1;
            scaleFactor.txbelt = 1;
            scaleFactor.txbag = 1;
            scaleFactor.txacc = 1;
            scaleFactor.RTI = 1.0; 
    end
    
    %%  Computing the HIC-15 and interval
    switch (typeInjury)
        case {'HIC15'}
            AISpH15 = @(coefs,HIC15)(1 ./ (1 + ...
                    exp(coefs(1)+(coefs(2)./(HIC15./scaleFactor.HIC))...
                                    -(coefs(3).*(HIC15./scaleFactor.HIC) ) )));
            for iAISlevel=1:6
                AIS_p(iAISlevel) = AISpH15(AIScoefH3.HIC15(iAISlevel,:),...
                                            criteriaValue);
            end
            
            if p.Results.ShowPlots
                xHIC=[0:3100]';
                AxisPlots = [0 xHIC(end) 0 1];
%                 yHIC=AISpH15(coefsHIC15_H3(3,:),xHIC);
                figName = 'AIS-HIC15';
%                 plegends={'AIS1+' 'AIS2+' 'AIS3+' 'AIS4+' 'AIS5+' 'AIS6+'};
%                 plegends={'AIS2+' 'AIS3+' 'AIS4+'};
                plegends={'AIS3+'};
                plotNpairedData(p.Results.nfig,[xHIC],...
                                     [ AISpH15(AIScoefH3.HIC15(3,:),xHIC)... % AISpH15(AIScoefH3.HIC15(4,:),xHIC)],...
                                     ],...
                                '-',figName,plegends,...
                                'HIC_{15}','Head Injury Probability',...
                                false,pwd,figureFormat,AxisPlots,4);
                hold on;
                for iAISlevel=3
                    plot([0 criteriaValue],[AIS_p(iAISlevel) AIS_p(iAISlevel)],...
                            '-.k','linewidth',2);
                end
                hold on; 
                
                plot([criteriaValue criteriaValue],[0 AIS_p(2)],...
                    '--k','linewidth',2);
                
                hLegend = legend( ...
                          plegends, ...
                          'FontName',Fonts,...
                          'FontSize', FontSizes,'FontWeight','bold',...
                          'orientation', 'vertical',...
                          'location', 'SouthEast' );
                set(gcf, 'Position', PicSize);
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            end
        case {'HIC15_u'}
%           AIS_p = normcdf((log(criteriaValue) - mu) ./ sigma);
            AISpH15 = @(coefs,HIC15_u)(normcdf(...
                            (log(HIC15_u./scaleFactor.HIC) - coefs(1)) ./ coefs(2)));
            for iAISlevel=1:3
                AIS_p(iAISlevel) = AISpH15(AIScoefH3.HIC15_u(iAISlevel,:),...
                                            criteriaValue);
            end
            
            if p.Results.ShowPlots
                xHIC=[0:5000]';
                AxisPlots = [0 xHIC(end) 0 1];
%                 yHIC=AISpH36(coefsHIC36_H3(3,:),xHIC);
                figName = 'AIS-HIC15_u';
                plegends={'AIS3+'};
                plotNpairedData(p.Results.nfig,[xHIC],...
                                     [AISpH15(AIScoefH3.HIC15_u(2,:),xHIC)...
                                     ],...
                                '-',figName,plegends,...
                                'HIC_{15}','Head Injury Probability AIS3+',...
                                false,pwd,figureFormat,AxisPlots,4);
                hold on;
                for iAISlevel=2
                    plot([0 criteriaValue],[AIS_p(iAISlevel) AIS_p(iAISlevel)],...
                        '-.k','linewidth',2);
                end
                hold on;
                plot([criteriaValue criteriaValue],[0 AIS_p(2)],...
                    '--k','linewidth',2);
                
                hLegend = legend( ...
                          plegends, ...
                          'FontName',Fonts,...
                          'FontSize', FontSizes,'FontWeight','bold',...
                          'orientation', 'vertical',...
                          'location', 'SouthEast' );
                set(gcf, 'Position', PicSize);
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            end
        case {'ThCC'}
            % AIS_p(3) = 1 / (1 + exp(10.5456-1.568.*(CC^0.4612)));              
            %     AIScoefH3.thCC = [10.5456, 1.568, 0.4612; %AIS3

            AISpthcc = @(coefs,thCC)(1 ./ (1 + ...
                    exp(coefs(1)-(coefs(2).*(thCC./scaleFactor.txbag).^coefs(3) ) )));
%             for iAISlevel=1:6
                iAISlevel=3;
                AIS_p(iAISlevel) = AISpthcc(AIScoefH3.thCC(iAISlevel,:),...
                                            criteriaValue);
%             end
            if p.Results.ShowPlots
                xthCC=[0:100]';
                AxisPlots = [0 xthCC(end) 0 1];
%                 yHIC=AISpH15(coefsHIC15_H3(3,:),xHIC);
                figName = 'AIS-ThCC';
%                 plegends={'AIS1+' 'AIS2+' 'AIS3+' 'AIS4+' 'AIS5+' 'AIS6+'};
                plegends={'AIS3+'};
                plotNpairedData(p.Results.nfig,[xthCC],...
                                     [AISpthcc(AIScoefH3.thCC(2,:),xthCC)],...
                                '-',figName,plegends,...
                                'Thorax CC','Thorax Injury Probability',...
                                false,pwd,figureFormat,AxisPlots,1);
                hold on;
%                 for iAISlevel=2:4
                    plot([0 criteriaValue],[AIS_p(iAISlevel) AIS_p(iAISlevel)],...
                            '-.k','linewidth',2);
%                 end
                hold on; 
                plot([criteriaValue criteriaValue],[0 AIS_p(3)],...
                    '--k','linewidth',2);
                hLegend = legend( ...
                          plegends, ...
                          'FontName',Fonts,...
                          'FontSize', FontSizes,'FontWeight','bold',...
                          'orientation', 'vertical',...
                          'location', 'SouthEast' );
                set(gcf, 'Position', PicSize);
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            end
            
         case {'NFz'}
            % Criteria value must be given in [kN]
            AISpNFz = @(coefs,NFz)(1 ./ (1 + ...
                    exp(coefs(1)-(coefs(2).*(NFz./scaleFactor.NF)) )));
%             for iAISlevel=1:6
                iAISlevel=3;
                AIS_p(iAISlevel) = AISpNFz(AIScoefH3.NFz(iAISlevel,:),...
                                            criteriaValue);
%             end
            if p.Results.ShowPlots
                xNFz=[0:0.01:5]';
                AxisPlots = [0 xNFz(end) 0 1];
%                 yHIC=AISpH15(coefsHIC15_H3(3,:),xHIC);
                figName = 'AIS-Neck-Fz';
%                 plegends={'AIS1+' 'AIS2+' 'AIS3+' 'AIS4+' 'AIS5+' 'AIS6+'};
                plegends={'AIS3+'};
                plotNpairedData(p.Results.nfig,[xNFz],...
                                     [AISpNFz(AIScoefH3.NFz(iAISlevel,:),xNFz)],...
                                '-',figName,plegends,...
                                'Neck Tension/Compression [N]','Neck Injury Probability',...
                                false,pwd,figureFormat,AxisPlots,1);
                hold on;
%                 for iAISlevel=2:4
                    plot([0 criteriaValue],[AIS_p(iAISlevel) AIS_p(iAISlevel)],...
                            '-.k','linewidth',2);
%                 end
                hold on; 
                plot([criteriaValue criteriaValue],[0 AIS_p(3)],...
                    '--k','linewidth',2);
                
                hLegend = legend( ...
                          plegends, ...
                          'FontName',Fonts,...
                          'FontSize', FontSizes,'FontWeight','bold',...
                          'orientation', 'vertical',...
                          'location', 'SouthEast' );
                set(gcf, 'Position', PicSize);
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            end
            
        case {'HIC36'}
%           AIS_p = normcdf((log(criteriaValue) - mu) ./ sigma);
            AISpH36 = @(coefs,HIC36)(normcdf((...
                            log(HIC36./scaleFactor.HIC) - coefs(1)) ./ coefs(2)));
            for iAISlevel=1:3
                AIS_p(iAISlevel) = AISpH36(AIScoefH3.HIC36(iAISlevel,:),...
                                            criteriaValue);
            end
            
            if p.Results.ShowPlots
                xHIC=[0:5000]';
                AxisPlots = [0 xHIC(end) 0 1];
%                 yHIC=AISpH36(coefsHIC36_H3(3,:),xHIC);
                figName = 'AIS-HIC36';
                plegends={'AIS2+' 'AIS3+' 'AIS4+'};
                plotNpairedData(p.Results.nfig,[xHIC xHIC xHIC],...
                                     [AISpH36(AIScoefH3.HIC36(1,:),xHIC)...
                                     AISpH36(AIScoefH3.HIC36(2,:),xHIC)...
                                     AISpH36(AIScoefH3.HIC36(3,:),xHIC)],...
                                '-',figName,plegends,...
                                'HIC_{36}','Head Injury Probability',...
                                false,figPath,figureFormat,AxisPlots);
                hold on;
                for iAISlevel=1:3
                    plot([0 criteriaValue],[AIS_p(iAISlevel) AIS_p(iAISlevel)],...
                        '-.k','linewidth',2);
                end
                hold on;
                plot([criteriaValue criteriaValue],[0 AIS_p(2)],...
                    '--k','linewidth',2);
                
                hLegend = legend( ...
                          plegends, ...
                          'FontName',Fonts,...
                          'FontSize', FontSizes,'FontWeight','bold',...
                          'orientation', 'vertical',...
                          'location', 'SouthEast' );
                set(gcf, 'Position', PicSize);
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            end
        case {'RTI'}
%           1/(1+exp( (ln(index) - TI(iAIS,1))/TI(iAIS,2) ));
            AISTI = @(coefs,RTI)(1 - exp( -exp((log(RTI) - coefs(1))./ coefs(2))) );
                
%             for iAISlevel=1:3
            iAISlevel = 2;
            AIS_p(iAISlevel) = AISTI(AIScoefH3.RTI(iAISlevel,:),...
                                            criteriaValue);
%             end
            
            if p.Results.ShowPlots
                xTI=[0:0.1:2]';
                AxisPlots = [0 xTI(end) 0 1];
%                 yHIC=AISpH36(coefsHIC36_H3(3,:),xHIC);
                figName = 'AIS-RTI';
                plegends={'AIS2+'};
                plotNpairedData(p.Results.nfig,xTI,...
                                     AISTI(AIScoefH3.RTI(2,:),xTI),...
                                '-',figName,plegends,...
                                'RTI','Probability of Tibia Fracture',...
                                false,pwd,figureFormat,AxisPlots,1);
                hold on;
%                 for iAISlevel=1:3
                    plot([0 criteriaValue],[AIS_p(iAISlevel) AIS_p(iAISlevel)],...
                        '-.k','linewidth',2);
%                 end
                hold on;
                plot([criteriaValue criteriaValue],[0 AIS_p(2)],...
                    '--k','linewidth',2);
                
                hLegend = legend( ...
                          plegends, ...
                          'FontName',Fonts,...
                          'FontSize', FontSizes,'FontWeight','bold',...
                          'orientation', 'vertical',...
                          'location', 'SouthEast' );
                set(gcf, 'Position', PicSize);
                set(gcf,'PaperPositionMode', 'auto');   % Required for exporting graphs
            end
                        
        otherwise
            AIS_p = zeros(1,3);
    end
    
    % Output all AIS probabiliites for AIS 1,2 and 3.
    
    AISp = AIS_p;%(AISlevel);
    % Usually the highest p(AIS+n) > 20% is used for measuring
    AISlevel = find(((AISp)>=0.5),1,'last');
    if isempty(AISlevel)
        AISlevel=0;
    end
end

    