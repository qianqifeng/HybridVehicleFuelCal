%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               MotorConstruction.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               22-April-2019 
 % @brief              Motor Construction according to the motor max
 character
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

%{
 % @brief  Calculate the vehicle Vertical dynamics
 % @param vehMass: (整车质量)kg
 %        @arg Scalar
 %        wh_1st_rrc: (滚阻系数)
 %        @arg Scalar
 %        AerodyPara 空气动力学参数
 %        @arg Scalar  airFA(迎风面积)m*m    @arg Scalar  veh_CD(Cd)   @arg Scalar
 %        airCD
 %       
 %        
 % @retval whPow         Wheel power demand  Kw
 %         whTt          Torque demand wheel  Nm
 %         whRotaSpd     Wheel speed  rpm
%}
function [spd,trq] = MotorConstruction(peakTrq,maxSpd,peakPow)
    % 
    turnSpd = peakPow*9549/peakTrq;
    spd1 = linspace(0,turnSpd-20,20);
    spd2 = linspace(turnSpd+20,maxSpd,20);
    trq1 = peakTrq*ones(1,length(spd1));
    trq2 = peakPow*9549./spd2;
    spd = [spd1,spd2];
    trq = [trq1,trq2];
    pow = spd.*trq/9549;
    figure;
    hold on;
    [AX,h1,h2] = plotyy(spd,trq,spd,pow);
    set(h1,'color','r','linewidth',2);set(h2,'color','b','linewidth',2);
    set(get(AX(1),'Ylabel'),'String','Trq/Nm'); 
    set(get(AX(2),'Ylabel'),'String','Pow/kW');
    set(AX(1),'YColor','r');set(AX(2),'YColor','b');
    xlabel('spd/rpm') 
%     set(h1,'marker','o');set(h2,'marker','+');
    hold off;
end