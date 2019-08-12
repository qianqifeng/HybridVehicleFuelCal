%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               EngEquFuelCurPlt.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               19-April-2019 
 % @brief              Drawing motor equal efficiency curve  
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
 %  Tip: spd:   [800 800 800 800 900 900 900 1000 1000]             Increment vector
         trq:   [298.2 497.9 697.1 1294.3 1496.3 502.2 705.1 905.6] vector
%}

%{
 % @brief Drawing motor equal efficience curve   
 % @param spd: (Engine speed vector)                    rpm
 %        @arg vector n*1 or 1*n
 %        torq: (Engine torque vector)                  Nm
 %        @arg vector n*1 or 1*n
 %        eff(Motor efficiency)       efficicnce
 %        @arg vector n*1 or 1*n
 % @retval None
%}
function [xi,yi,zi] = MotorEquEffCurPlt(spd,trq,eff,varargin)
    if nargin == 3
        dx = 10;
    else
        dx = varargin{1};
    end
    if size(spd,1)>size(spd,2)
        x = spd; y = trq; z = eff;
    else
        x = spd'; y = trq'; z = eff';
    end
    xi1 = min(x):dx:max(x);
    yi1 = linspace(min(y),max(y),2*length(xi1));
    [xi,yi] = meshgrid(xi1,yi1);                            % Subdivision speed: xi-two-dimensional xi1-1 dimension; subdivision torque yi-two-dimensional yi1-1 dimension
    zi = griddata(x,y,z,xi,yi,'cubic'); zi2 = griddata(x,y,z,xi,yi,'nearest');
    tem = isnan(zi); id = find(tem==1); zi(id) = zi2(id);   % Use the cubic interpolation to appear Nan, replace with nearest
    % Adjust the number of contour lines
    v = [80:1:100];        % Contour line showing the fuel consumption number
%     v = [120:10:220 220:20:300 300:10:400 400:30:600];
    hf = figure; set(hf,'color',[1 1 1]);
    [c,~] = contour(xi,yi,zi,v);
    xlabel('Motor speed£¨r/min£©');ylabel('Motor torque£¨Nm£©');title('Motor map');
    hold on; clabel(c);
    % Maximum engine operating curve
    [fcMaxSpd,fcMaxTrq] = EngMaxCharact(x,y);
    fcMapSpdin = fcMaxSpd(1):10:fcMaxSpd(end);
    fcMapTrqin = spline(fcMaxSpd,fcMaxTrq,fcMapSpdin);
    hold on;grid on;
    plot(fcMapSpdin,fcMapTrqin,'b-','LineWidth',3);
end

%{
 % @brief Calculate Engine maximum characteristic curve   
 % @param spd: (Engine speed vector)rpm
 %        @arg vector n*1
 %        torq: (Engine torque vector) Nm
 %        @arg vector n*1
 % @retval fcMaxSpd: Engine external characteristic speed vector  /rpm
           fcMaxTrq: Engine external characteristic torque vector /Nm
%}
function [fcMaxSpd,fcMaxTrq] = EngMaxCharact(spd,trq)
     spd = round(spd)-rem(round(spd),100);
     diff = spd(2:end)-spd(1:end-1);        % Calculate the speed difference to find the speed jump point
     diffindex = find(diff >= 100);
     fcMaxSpdPart = spd(diffindex);
     fcMaxSpd = [fcMaxSpdPart;spd(end)];     % Attach the last speed
     fcMaxTrqPart = trq(diffindex);
     fcMaxTrq = [fcMaxTrqPart;trq(end)];     % Attach the last torque
end
