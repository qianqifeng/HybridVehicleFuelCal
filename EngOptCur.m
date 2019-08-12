%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               EngOptCur.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               19-April-2019 
 % @brief              Calculate the optimal curve of engine operation 
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
 % @brief Calculate the optimal curve of engine operation 
 % @param spd: (Engine speed vector)                        rpm
 %        @arg vector n*1 or vector 1*n
 %        torq: (Engine torque vector)                      Nm
 %        @arg vector n*1 or vector 1*n
 %        b(Engine minimum fuel consumption rate)           g/kwh
 %        @arg vector n*1 or vector 1*n
 % @retval finalMap         First column number, second column optimal speed, third column optimal torque, fourth column optimal power, fifth column optimal fuel consumption rate
%}
function finalMap = EngOptCur(spd,trq,b)
    if size(spd,1)>size(spd,2)
        x = spd; y = trq; z = b;
    else
        x = spd'; y = trq'; z = b';
    end
    dx = 5;
    pow = linspace(min(x.*y*pi/30/1000),max(x.*y*pi/30/1000),20);
    finalMap =zeros(length(pow),5);                         % Initialization result table
    [fcMaxSpd,fcMaxTrq] = EngMaxCharact(x,y);               % Find the maximum external characteristic curve
    % Regularize the speed xi1, torque yi1, and interpolate to obtain the fuel consumption law at each torque speed
    xi1 = min(x):dx:max(x);
%     x = spd; y = trq; z = b;
    spdOptMin = zeros(length(pow),1);
    trqOptMin = zeros(length(pow),1);
    for k = 1:length(pow)                                   % Traverse the optimal engine torque and speed at each power
        finalMap(k,1) = k;
        spdXi = xi1;
        trqXi = pow(k)*1000./spdXi/(pi/30);                 % Traversing each torque under certain power
        trqXi = round(trqXi);                               % Calculate the torque by equal power curve and speed up the calculation
        trqOutline = interp1(fcMaxSpd, fcMaxTrq,spdXi);     % Remove excess engine torque
        OverID = find(trqXi > trqOutline);              
        spdXi(OverID) = [];
        trqXi(OverID) = [];
        spdXiXi = linspace(spdXi(1),spdXi(end),500);        % After the removal, the speed and torque are re-arranged, and 500 points are found within the determined range under the determined power for comparison.
        trqXiXi = pow(k)*1000./spdXiXi/(pi/30);
        FuelXi = griddata(x,y,z,spdXiXi,trqXiXi,'cubic');   % The fuel consumption rate of 500 points is interpolated under equal power.
        tem = isnan(FuelXi); id1 = tem==1; FuelXi(id1) = 1000;
        [FuelValueMin, ID] = min(FuelXi);                   % Find the minimum fuel consumption rate and index for these 500 points  
        finalMap(k,5) = FuelValueMin;
        spdOptMin(k) = spdXiXi(ID);             
        trqOptMin(k) = trqXiXi(ID);                     
        plot(spdXi,trqXi,'r--');                            % Plot Equal power curve
    end
    finalMap(:,2)=spdOptMin;
    finalMap(:,3)=trqOptMin;
    finalMap(:,4)=pow;
    spdOptPart = fcMaxSpd(spdOptMin(end)<fcMaxSpd); trqOptPart = fcMaxTrq(spdOptMin(end)<fcMaxSpd);
    spdOpt = [spdOptMin',spdOptPart']'; trqOpt = [trqOptMin',trqOptPart']';
    %     ID = find((spdOpt(2:end)-spdOpt(1:end-1)) == 0);
    %     spdOpt(ID+1) = spdOpt(ID+1)+1;
    %     trqSmooth = spline(spdOpt,trqOpt,xi1);
    %     trqSmooth = spcrv([[spdOpt(1) spdOpt spdOpt(end)];[trqOpt(1) trqOpt trqOpt(end)]],2);
        p = polyfit(spdOpt,trqOpt,6);                     % Sixth degree polynomial fitting
        trqSmooth = polyval(p,xi1);
        plot(xi1,trqSmooth, 'b--','linewidth',2);
    plot(spdOpt,trqOpt,'g--o','linewidth',2);
end

%{
 % @brief Calculate Engine maximum characteristic curve   
 % @param spd: (Engine speed vector)                                    rpm
 %        @arg vector n*1
 %        torq: (Engine torque vector)                                  Nm
 %        @arg vector n*1
 % @retval fcMaxSpd: Engine external characteristic speed vector        rpm
           fcMaxTrq: Engine external characteristic torque vector       Nm
%}
function [fcMaxSpd,fcMaxTrq] = EngMaxCharact(spd,trq)
     spd = round(spd)-rem(round(spd),100);
     diff = spd(2:end)-spd(1:end-1);                        % Calculate the speed difference to find the speed jump point
     diffindex = find(diff >= 100);
     fcMaxSpdPart = spd(diffindex);
     fcMaxSpd = [fcMaxSpdPart;spd(end)];                    % Attach the last speed
     fcMaxTrqPart = trq(diffindex);
     fcMaxTrq = [fcMaxTrqPart;trq(end)];                    % Attach the last torque
end
