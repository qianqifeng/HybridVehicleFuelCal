%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               ModeSwitchRuleTrad.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               23-April-2019 
 % @brief              Mode switching rule division
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
 % @brief  Traditional vehicle Mode switching rule division
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure  
 %        
 % @retval cycMode   different mode 
%}
function cycMode = ModeSwitchRuleTrad(count,cycCount,auto)
    if auto.cycPara.ve(count)/3.6 == 0                  % Parking condition
        cycMode = auto.mode.STOP;
    elseif auto.cycPara.whPow(count)<0                  % Brake condition
        cycMode = auto.mode.MB;
    else
        cycMode = auto.mode.ICE;
    end
end