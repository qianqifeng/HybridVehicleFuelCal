%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               EngEquFuelCurPlt.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               18-July-2019 
 % @brief              Drawing APU Optimal working curve
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
 %  Tip: engspd:   [800 800 800 800 900 900 900 1000 1000]             Increment vector
         engtrq:   [298.2 497.9 697.1 1294.3 1496.3 502.2 705.1 905.6] vector
%}

%{
 % @brief Drawing engine fuel consumption curve   
 % @param engSpd: (Engine speed vector)                    rpm
 %        @arg vector n*1 or 1*n
 %        engTorq: (Engine torque vector)                  Nm
 %        @arg vector n*1 or 1*n
 %        engB(Engine minimum fuel consumption rate)       g/kwh
 %        @arg vector n*1 or 1*n
 
 %        motorSpd: (Motor speed vector)                   rpm
 %        @arg vector n*1 or 1*n
 %        motorTorq(Motor torque vector)                   Nm
 %        @arg vector n*1 or 1*n
 %        motorEff(Motor efficience)                       Nan
 %        @arg vector n*1 or 1*n
 % @retval None
%}
function [bestSpd,gentrq] = APUOptCurPlt(engSpd,engTrq,engB,motorSpd,motorTrq,motorEff,varargin)
    [engMaxSpd,engMaxTrq] = EngMaxCharact(engSpd,engTrq);
    engMapSpd = engSpd;
    engMapTrq = engTrq;
    engMapB = engB;
    [gcMapSpd,gcMaxTrq] = MotorMaxCharact(motorSpd,motorTrq);
    gcMapTrq = motorTrq;
    gcMapEff = motorEff;  % (--)
%     figure;
%     plot(gcMapSpd,gcMaxTrq,'color','r','linewidth',4);
    temp1 = min(max(engMapTrq),max(gcMapTrq));
    temp2 = max(min(engMapTrq),min(gcMapTrq));
    % The overlap between the generator and the engine torque is
    % the torque map of the genset.
    gensetMapTrq = linspace(temp2,temp1,11);
    temp1 = min(max(engMapSpd),max(gcMapSpd));
    temp2 = max(min(engMapSpd),min(gcMapSpd));
    % The overlap between the generator and the engine speed is
    % the speed map of the genset.
    gensetMapSpd = linspace(temp2,temp1,11);
    temp1 = interp1(engMaxSpd,engMaxTrq,gensetMapSpd);
    temp2 = interp1(gcMapSpd,gcMaxTrq,gensetMapSpd);
    %Maximum torque of genset at different speeds
    gensetMaxTrq = min([temp1;temp2]);  %vector 2Xlength(gensetMapSpd)
    [genxi,genyi] = meshgrid(gensetMapSpd,gensetMapTrq);
    gczi = griddata(motorSpd,gcMapTrq,gcMapEff,genxi,genyi,'cubic'); 
    gczi2 = griddata(motorSpd,gcMapTrq,gcMapEff,genxi,genyi,'nearest');
    tem = isnan(gczi); id = find(tem==1); gczi(id) = gczi2(id);   % Use the cubic interpolation to appear Nan, replace with nearest
    clear id tem 
    engzi = griddata(engMapSpd,engMapTrq,engMapB,genxi,genyi,'cubic'); engzi2 = griddata(engMapSpd,engMapTrq,engMapB,genxi,genyi,'nearest');
    tem = isnan(engzi); id = find(tem==1); engzi(id) = engzi2(id);   % Use the cubic interpolation to appear Nan, replace with nearest
%     [meshgcMapTrq,meshgcMapSpd] = meshgrid(gcMapTrq,gcMapSpd);
%     temp1=interp2(meshgcMapTrq,meshgcMapSpd,gcMapEff,gensetMapTrq,gensetMapSpd');
%     [meshengMapTrq,meshengMapSpd] = meshgrid(engMapTrq,engMapSpd);
%     temp2=interp2(meshengMapTrq,meshengMapSpd,engMapB,gensetMapTrq,gensetMapSpd');
    gensetBSFCMap = engzi./(gczi+eps);
    gensetMinPwr = min(gensetMapSpd)*min(gensetMapTrq)/9549;
    gensetMaxPwr = max(gensetMapSpd.*(min([gensetMaxTrq;ones(size(gensetMaxTrq))*max(gensetMapTrq)])))/9549;
    gensetPwr = linspace(gensetMinPwr,gensetMaxPwr,11);
    for IndexPwr = 2:length(gensetPwr-1)
        spds = ceil(min(gensetMapSpd)):floor(max(gensetMapSpd));
        trqs1 = gensetPwr(IndexPwr)./(spds+eps)*9549;
        trqs2 = min(trqs1,max(gensetMapTrq));
        trqs2 = max(trqs2,min(gensetMapTrq));
        BSFCs = interp2(gensetMapSpd,gensetMapTrq,gensetBSFCMap,spds,trqs2);
        BSFCs = BSFCs + (trqs1 > interp1(engMaxSpd,engMaxTrq,spds))*10000 ...
            + (trqs1 > interp1(gcMapSpd,gcMaxTrq,spds))*10000;
        if any(isnan(BSFCs))
            error('Error in PTC_SERFO: couldn''t compute genset eff. map')
        end
        bestIndex = find(min(BSFCs)==BSFCs, 1 );
        bestSpd(IndexPwr) = spds(bestIndex);
    end
    
    gensetPwr(length(gensetPwr)) = gensetMaxPwr;
    if gensetMaxPwr == max(gensetMapSpd.*gensetMaxTrq/9549)
        bestSpd(length(gensetPwr)) = gensetMapSpd(find((gensetMapSpd.*gensetMaxTrq/9549)==gensetMaxPwr));
    else
        bestSpd(length(gensetPwr))=max(gensetMapSpd);
    end
    gensetPwr(1)=min(gensetMapSpd)*min(gensetMapTrq)/9549;
    bestSpd(1)=min(gensetMapSpd);
    gentrq = gensetPwr./bestSpd*9549;
    % put the figure together
    EngEquFuelCurPlt(engSpd,engTrq,engB);
    EngOptCur(engSpd,engTrq,engB);
    MotorEquEffCurPlt(motorSpd,motorTrq,motorEff);
    xlabel('Speed£¨r/min£©');ylabel('Torque£¨Nm£©');title('Engine&&Motor Map');
    temp1 = max(max(engMapSpd),max(gcMapSpd));
    temp2 = min(min(engMapSpd),min(gcMapSpd));
    temp3 = max(max(engMapTrq),max(gcMapTrq));
    temp4 = min(min(engMapTrq),min(gcMapTrq));
    axis([temp2,temp1,0,temp3])
    plot(bestSpd,gentrq,'lineWidth',3,'color','k');
end


%{
 % @brief Drawing motor fuel consumption curve   
 % @param spd: (Engine speed vector)                    rpm
 %        @arg vector n*1 or 1*n
 %        torq: (Engine torque vector)                  Nm
 %        @arg vector n*1 or 1*n
 %        eff(Motor efficiency)       g/kwh
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
%     hf = figure; set(hf,'color',[1 1 1]);
    [c,~] = contour(xi,yi,zi,v);
    xlabel('Motor speed£¨r/min£©');ylabel('Motor torque£¨Nm£©');title('Motor map');
    hold on; clabel(c);
    % Maximum engine operating curve
    [fcMaxSpd,fcMaxTrq] = EngMaxCharact(x,y);
    fcMapSpdin = fcMaxSpd(1):10:fcMaxSpd(end);
    fcMapTrqin = spline(fcMaxSpd,fcMaxTrq,fcMapSpdin);
    hold on;grid on;
    plot(fcMapSpdin,fcMapTrqin,'r-','LineWidth',3);
end


    
    
    
    
    