%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               GearShiftLogic.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               30-April-2019 
 % @brief              Automatic calculation of gear positions
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @attention
 %
 %THE PRESENT SCRIPT IS FOR GUIDANCE ONLY AIMS AT PROVIDING DEVELOPER WITH
 %CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE
 %TIME. AS A RESULT, OUR TEAM SHALL NOT BE HELD LIABLE FOR ANY DIRECT, 
 %INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING
 %FROM THE CONTENT OF SUCH SCRIPT AND/OR THE USE MADE BY CUSTOMERS OF THE
 %CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
 %
 %COPYRIGHT 2019 JLUHybrid
%}
% @ Warning: in this program, the name of each relay module corresponds to the corresponding gear position. 
% Do not modify the name of the relay module, and modifying or adding relay module 
% to prevent modification of the name of the relay module. For example, relay1 corresponds to For gear 1
%{
 % @brief  Automatic calculation of gear positions
 % @param wheelPara: wheel parameters
 %        gbPara   : gearbox parameters
 %        engShiftSpd :
 %        engDownSpd :
 %        
 % @retval simt: time      vector
 %         simy: Gear position changes with time      vector
%}

function [simt,simy] = GearShiftLogic(wheelPara,gbPara,engDownSpd,engShiftSpd)
    k = 1:length(gbPara.ratio)-1;
    Judge = min(gbPara.ratio(k+1)/gbPara.ratio(k));
    if Judge < engDownSpd/engShiftSpd
       error(['Due to ',num2str(Judge),'<',num2str(engDownSpd/engShiftSpd),', Please re-determine the engine speed of the lift or check whether the speed ratio is correct.']) ;
    end
    open 'gearTest17.slx'
    Vshift = engShiftSpd*3.6*wheelPara.radius/30*pi/gbPara.fdRatio./gbPara.ratio;
    Vdown = engDownSpd*3.6*wheelPara.radius/30*pi/gbPara.fdRatio./gbPara.ratio;
%     sim('gearTest');
    h = find_system('gearTest17', 'findall','on','blockType','Relay');
    hName = get(h,'name');
    % Reset the relay module parameter speed to avoid the lower limit being greater than the upper limit
    for ii = 1: length(h)
        str = ['Relay',num2str(ii)];
        id1 = ismember(hName,str);
        set(h(id1), 'OffSwitchValue', num2str(-10000));
        set(h(id1), 'OnSwitchValue', num2str(100000));
    end
    for jj = 1: length(gbPara.ratio)-1
        str = ['Relay',num2str(jj)];
        id2 = ismember(hName,str);
        set(h(id2), 'OffSwitchValue', num2str(Vdown(jj+1)));
        set(h(id2), 'OnSwitchValue', num2str(Vshift(jj)));
    end
    paramStruct.SaveState      = 'on';
    paramStruct.StateSaveName  = 'xout';
    paramStruct.SaveOutput     = 'on';
    paramStruct.OutputSaveName = 'yout';
    paramStruct.SolverType     = 'Fixed-step';
    paramStruct.Solver         = 'FixedStepDiscrete';
    paramStruct.FixedStep      = '1';
    paramStruct.StopTime       = 'length(cycPara.time)';
    paramStruct.LimitDataPoints = 'off';
%     set_param('gearTest','SolverType','Fixed-step','Solver','FixedStepDiscrete','FixedStep','1');
    simout = sim('gearTest17',paramStruct);
    simt = get(simout, 'tout');
    simt = simt(2:end);
    simy = get(simout, 'yout');
    simy = simy(2:end);
    bdclose('gearTest17')
end