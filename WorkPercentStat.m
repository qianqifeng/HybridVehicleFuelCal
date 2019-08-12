%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               WorkPercentStat.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               06-May-2019 
 % @brief              Statistical work point ratio
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
 % @brief  Statistical work point ratio
 % @param cycTime:  cycle time
 %        cycV   :  cycle speed
 %        cycT   :  cycle torque
 %        
 % @retval hf    :  figure handle
%}
function hf = WorkPercentStat(cycTime,cycV,cycT)
    time = min(cycTime):1:max(cycTime);              % Normalized data        
    teNormal = interp1(cycTime,cycT,time);              % Interpolation of engine torque
    veNormal = interp1(cycTime,cycV,time);              % Interpolating engine speed
    allData = [time',veNormal',teNormal'];              % Integrated into a vector
    num = 6;
    veInter = floor((max(veNormal)-min(veNormal))/num);
    veInter = Rounding(10,veInter,0);
    teInter = floor((max(teNormal)-min(teNormal))/num);
    teInter = Rounding(10,teInter,0);
    veRange = Rounding(veInter,min(veNormal),0):veInter:Rounding(veInter,max(veNormal),1);
    teRange = Rounding(teInter,min(teNormal),0):teInter:Rounding(teInter,max(teNormal),1);
    count = zeros(length(teRange)-1,length(veRange)-1);
    for i = 1:1:size(allData,1)
        for n = 1:length(veRange)-1
            for m = 1:length(teRange)-1
                if (allData(i,2)>=veRange(n)&&allData(i,2)<veRange(n+1)) && (allData(i,3)>=teRange(m)&&allData(i,3)<teRange(m+1))
                    count(m,n) = count(m,n)+1;
                end
            end
        end
    end
    labelTrq = '';labelSpd = '';
    for i = 1:1:length(teRange)-1
        labelTrq{i} = [num2str(teRange(i)),'~',num2str(teRange(i+1))];
    end
    for i = 1:1:length(veRange)-1
        labelSpd{i} = [num2str(veRange(i)),'~',num2str(veRange(i+1))];
    end
    sumCounter = sum(sum(count));
    normalizationMatrx = round((count/sumCounter)*10000)/100;
    hf = figure;set(hf,'Color',[1 1 1]);
    bar3(normalizationMatrx );
    xlabel('Spd/(rpm)','fontsize',14);ylabel('Trq/(N*m)','fontsize',14);zlabel('timePercentage/%','fontsize',12);
    colormap autumn;
    set(gca, 'xticklabel', labelSpd);                   % Set the x-axis scale
    set(gca, 'yticklabel', labelTrq);                   % Set the y-axis scale
    title('Working point distribution ratio statistics','fontsize',16)
    for i = 1:size(normalizationMatrx ,1)
        for j = 1:size(normalizationMatrx ,2)
            text(j-0.2,i-0.1,normalizationMatrx (i,j)+1, num2str(normalizationMatrx (i,j)),'fontsize',8);
        end
    end
    % view([-50,-50,50]);
end
%{
 % @brief  Statistical work point ratio
 % @param IntMultiple:  interg num
 %        roundNum   :  round num
 %        updown   :  up or down round
 %        
 % @retval round      round result
%}
 % @example Rounding(34,10,1) = 40;Rounding(34,10,0) = 30;
function round = Rounding(IntMultiple,roundNum,updown)
    if updown == 1
        round = ceil(roundNum/IntMultiple)*IntMultiple;
    else
        round = floor(roundNum/IntMultiple)*IntMultiple;
    end
end