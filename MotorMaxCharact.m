%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               MotorMaxCharact.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               19-April-2019 
 % @brief              Calculate Motor maximum characteristic curve   
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
 % @brief Calculate Motor maximum characteristic curve   
 % @param spd: (Motor speed vector)                                rpm
 %        @arg vector n*1 or vector 1*n
 %        torq: (Motor torque vector)                              Nm
 %        @arg vector n*1 or vector 1*n
 % @retval motorMaxSpd: Motor external characteristic speed vector    rpm
           motorMaxTrq: Motor external characteristic torque vector   Nm
%}
function [motorMaxSpd,motorMaxTrq] = MotorMaxCharact(spd,trq)
    if size(spd,1)<size(spd,2)
        spd = spd'; trq = trq';
    end
    spd = round(spd)-rem(round(spd),100);
    diff = spd(2:end)-spd(1:end-1);        % Calculate the speed difference to find the speed jump point
    diffindex = find(diff >= 100);
    motorMaxSpdPart = spd(diffindex);
    motorMaxSpd = [motorMaxSpdPart;spd(end)];     % Attach the last speed
    motorMaxTrqPart = trq(diffindex);
    motorMaxTrq = [motorMaxTrqPart;trq(end)];     % Attach the last torque
end
