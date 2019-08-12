%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               ModeSwitchRule.m
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
 % @brief  Mode switching rule division
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure  
 %        
 % @retval cycMode   different mode 
%}
function cycMode = ModeSwitchRule(count,cycCount,auto)
    global EngOnPower relayMode flag
    if auto.cycPara.ve(count)/3.6 == 0                  % Parking condition
        cycMode = auto.mode.STOP;
    elseif auto.cycPara.whPow(count)<0                  % Brake condition
        if auto.user.switchRGB == 1
            if(cycCount.bat.SOC(count-1)<1 && auto.cycPara.ve(count)>=3/3.6)
                if auto.cycPara.brkPedal(count)<=0.2
                    cycMode = auto.mode.RGB;
                else
                    cycMode = auto.mode.RGBMech;
                end
            else
                cycMode = auto.mode.MB;
            end
        else
            cycMode = auto.mode.MB;
        end
%     elseif auto.cycPara.ve(count)<auto.engPara.engIdleSpd *pi/30/4.1*auto.wheelPara.radius||cycPara.whPow(count)<70
%         if auto.cycPara.whPow(count)<EngOnPower  && cycCount.bat.SOC(count-1)>EngON_SOClim
%             cycMode = auto.mode.EV;
%         else
%             cycMode = auto.mode.SHEV;
%         end
%     elseif auto.cycPara.whTt(count)/4.1/0.98<=100 && cycCount.bat.SOC(count-1)<=0.8
%         cycMode = auto.mode.CHEV;
%     elseif auto.cycPara.whTt(count)/4.1/0.98>100 && cycCount.bat.SOC(count-1)>0.6||auto.cycPara.whTt(count)/4.1/0.98>200
%         cycMode = auto.mode.BHEV;
    elseif cycCount.bat.SOC(count-1)>0.3&& flag == 0&&auto.cycPara.ve(count)<=80
        cycMode = auto.mode.EV;
%     elseif auto.cycPara.ve(count)>80
%         cycMode = auto.mode.ICE;
    else
        if cycCount.bat.SOC(count-1)>0.32
            relayMode = 1;
        else
            if cycCount.bat.SOC(count-1)<0.28
                relayMode = 0;
            end
        end
        if relayMode
            cycMode = auto.mode.EV;
        else
            cycMode = auto.mode.SHEV;
        end
        flag = 1;
    end
end
    

    