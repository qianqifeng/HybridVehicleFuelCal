%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               VehicleModel.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               22-April-2019 
 % @brief              Calculate the vehicle Vertical dynamics
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
function [whPow,whTt,whRotaSpd] = VehicleModel(vehPara,cycPara,aerodyPara,wheelPara)
    %vehicle parameter
    vehGravity = vehPara.gravity;                           % m/s/s
    vehCd = vehPara.Cd;
    vehFA = vehPara.Fa;
    vehMass = vehPara.mass;                                 % kg
    vehDelta = vehPara.delta;
    %cycle parameter
    cycTime = cycPara.time;                                 % s
    cycGlope = cycPara.glope;
    cycAngle = atan(cycGlope/100);                          % Slope converted to angle
    cycVe = cycPara.ve;
    cycV = cycVe./3.6;                                      % velocity m/s
    k=1:length(cycTime)-1;                                  % 1:cycle length - 1 
    cycAcc = [0;(cycV(k+1)-cycV(k))./(cycTime(k+1)-cycTime(k))];%m/s/s
    %wheel parameter
    whRadius = wheelPara.radius;                            % m
    wh1stRrc = wheelPara.rrc1;
    % aerodynamics parameter
    airDensity = aerodyPara.airDensity;
    % Driving resistance equation
    Fr = vehMass*vehGravity*wh1stRrc.*cos(cycAngle);        % Rolling resistance N
    Fi = vehMass*vehGravity.*sin(cycAngle);                 % Slope resistance N
    Fa = 0.5*airDensity*vehFA*vehCd*(cycV.^2);              % air resistance N
    Fj = vehMass.*vehDelta.*cycAcc;                         % Acceleration resistance  N
    Ft = Fr+Fi+Fa+Fj;                                       % Wheel drive demand N
    %{
    figure;
    hold on;
    plot(cycTime,cycV,'r--','LineWidth',2);
    plot(cycTime,Fr,'r','LineWidth',2);
    plot(cycTime,Fi,'b','linewidth',2);
    plot(cycTime,Fa,'g','linewidth',2);
    plot(cycTime,Fj,'k','linewidth',2);
    plot(cycTime,Ft,'p','linewidth',2);
    hold off;
    %}
    whTt = Ft.*whRadius;                                    % Torque demand wheel  Nm
    whRotaSpd = cycV/whRadius*30/pi;                        % Wheel speed  rpm
    whPow = whTt.*whRotaSpd/9549;                             % Wheel power demand  Kw
end