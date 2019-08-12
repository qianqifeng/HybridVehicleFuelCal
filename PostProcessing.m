%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               VehilceOperateMode.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               23-April-2019 
 % @brief              Post-processing of calculation results
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
 % @brief  Post-processing of calculation results
 % @param cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure  
 %        
 % @retval no retval
%}
function PostProcessing(cycCount,auto)
    %% Engine fuel consumption
    fuelTotalVolume = trapz(auto.cycPara.time,cycCount.eng.B/3600);        % L
    fuel100kmConsum = fuelTotalVolume/auto.cycPara.dis*100;                % L 100 km fuel consumption
    % Be=Me/1000/fuel_den;                                           % Fuel consumption per hour  L/h
    Me = cycCount.eng.B*1000*auto.engPara.fuelDen;                   % g/h 
    % Engine average fuel consumption rate
    %beAvg = mean(cycCount.eng.be(cycCount.eng.be>0 & cycCount.eng.be<1000));
    powIdle = auto.engPara.fuelIdle*auto.engPara.fuelDen*1000*auto.engPara.fuelClori/3600*0.1;              % kw Fuel output energy when the engine is idling
                                                                     % Assume that the energy conversion efficiency is 10%
    powMech = sum(cycCount.eng.spd.*cycCount.eng.te/9549.*(cycCount.eng.spd>0).*(cycCount.eng.te>0));% g/kwh The sum does not mean integral,it just add together
    powTotal = sum(powIdle.*(auto.cycPara.ve<=0))+powMech;       % g/kwh The sum does not mean integral,it just add together
    beAvgAbsolute = sum(Me)/powMech;                                % g/kwh The sum does not mean integral,it just add together
    engONTime = length(find(cycCount.eng.te>0));                     % s Engine working time
    engAvgPow = powTotal/engONTime;
    %% Battery average charge and discharge efficiency
    %batAvgChrgEff = mean(cycCount.bat.effIn(cycCount.bat.effIn ~= 0));
    %batAvgDischrgEff = mean(cycCount.bat.effOut(cycCount.bat.effOut ~= 0));
    %% Motor average efficiency
    % Motor average efficiency of power generation
    idMotorDischarge = find(cycCount.motor.eff>0 & cycCount.motor.eff<1 & cycCount.motor.tmc>0);             % Discharge
    idMotorCharge = find(cycCount.motor.eff>0 & cycCount.motor.eff<1 & cycCount.motor.tmc<0);           %Charge
    motorAvgChrgEff = sum(cycCount.motor.spd(idMotorCharge).*cycCount.motor.tmc(idMotorCharge).*cycCount.motor.eff(idMotorCharge))/sum(cycCount.motor.spd(idMotorCharge).*cycCount.motor.tmc(idMotorCharge));  
    % Motor average efficiency of electric power
    motorAvgDischrgEff = sum(cycCount.motor.spd(idMotorDischarge).*cycCount.motor.tmc(idMotorDischarge))/sum(cycCount.motor.spd(idMotorDischarge).*cycCount.motor.tmc(idMotorDischarge)./cycCount.motor.eff(idMotorDischarge)); % 电动平均效率
    idMotorRGB = cycCount.motor.tmc<0 & cycCount.motor.eff>0;
    motorAvgRGBEff = mean(cycCount.motor.eff(idMotorRGB));
    %% Regenerative braking energy statistics
    regEnergy = zeros(length(auto.cycPara.time),1);
    for i=2:length(auto.cycPara.whTt)
        if auto.cycPara.whTt(i)<0
            regEnergy(i)=regEnergy(i-1)+cycCount.bat.energyIn(i)-cycCount.bat.energyIn(i-1);
        else
            regEnergy(i)=regEnergy(i-1);
        end
    end
    %% Theoretical cycle total drive energy
    powDriveReq = (auto.cycPara.whTt>0).*auto.cycPara.whTt.*auto.cycPara.whRotaSpd/9549;                % kw Drive power at the wheel
    energyDriveReq = trapz(auto.cycPara.time,powDriveReq*1000)/1000;                                    % kJ Total drive energy
%     for i=1:length(Pdrive_req)
%         Edirve_req(i)=sum(Pdrive_req(1:i)*1000)*(t_cyc(2)-t_cyc(1))/1000;% kJ
%     end
    %% Theoretical cycle total brake energy
    powBrakeReq = (auto.cycPara.whTt<0).*auto.cycPara.whTt.*auto.cycPara.whRotaSpd/9549;                % kw Drive power at the wheel
    energyBrakeReq = trapz(auto.cycPara.time,powBrakeReq*1000)/1000;                                    % kJ Total drive energy

    engEffCyc = 1./(beAvgAbsolute.*auto.engPara.fuelClori/3600);                                        % Engine efficiency
    %fuelTotalEnergy = fuelTotalVolume*auto.engPara.fuelDen*1000*auto.engPara.fuelClori;                                   % kJ The total energy of the actual fuel
    engTotalFuelOutEnergy = fuelTotalVolume*auto.engPara.fuelDen*1000./beAvgAbsolute*3600;                                 % The actual energy provided by the engine
    %engTotalMechOutEnergy =  trapz(auto.cycPara.time,cycCount.eng.te.*cycCount.eng.spd/9549.*(cycCount.eng.te>0).*(cycCount.eng.spd>0));% Engine actual output mechanical power statistics engine 
    % Calculate battery energy changes
    batVoltIni = interp1(auto.batPara.mapSOC,auto.batPara.mapUidle,cycCount.bat.SOC(1),'linear');% voltaage V
    batVoltEnd = interp1(auto.batPara.mapSOC,auto.batPara.mapUidle,cycCount.bat.SOC(end),'linear');% voltaage V
    batEnergyChange = (auto.batPara.SOCIni*batVoltIni-cycCount.bat.SOC(end)*batVoltEnd)*auto.batPara.C*3600/1000;% KJ 
    allCycEnergy = engTotalFuelOutEnergy+batEnergyChange+regEnergy(end)*(auto.user.switchRGB==1);
    transEffCyc = energyDriveReq/allCycEnergy;                                                             % Transmission system efficiency
    vehEffCyc = engEffCyc*transEffCyc;                                                                        % Vehicle system efficiency
    modeNameStr = fieldnames(auto.mode);
    hEngPoint = figure;
    hold on;
    plot(auto.engPara.maxSpd,auto.engPara.maxTrq,'b-','LineWidth',3);
    title('Engine working point');
    xlabel('Engine Speed(r/min)');ylabel('Engine Torque(Nm)');
    hMotPoint = figure;
    hold on;
    plot(auto.motorPara.mapSpd,auto.motorPara.mapTrq,'b-','LineWidth',3);
    title('Motor working point');
    xlabel('Motor Speed(r/min)');ylabel('Motor Torque(Nm)');
    legendStr(1) = {'Charac'};
    temp = 2;
    xlsTitle = {'propTime','mtDisEff','mtChgEff','engBe  ','engEff  ','fuelVol ','reqEngy ','engPow  ','batEngy ','avgEff  '};
    modeStatistics = zeros(length(fieldnames(auto.mode)),10);
    for mode = 1:(auto.mode.End)-1
        modeStatistics(mode,:) = EveryModeCount(cycCount,auto,mode,hEngPoint,hMotPoint);
        if ~isempty(find(mode == cycCount.mode, 1))
            legendStr(temp) = modeNameStr(mode);
            % excel utput
            xlsAllData(temp,1)  = legendStr(temp);
            xlsAllData(temp,2:length(xlsTitle)+1) = num2cell(modeStatistics(mode,:));
            temp = temp+1;
        end
    end
    xlsAllData(1,2:length(xlsTitle)+1)  = xlsTitle;
    if auto.user.switchOutXlsData == 1
        xlswrite(['SimResults',auto.user.vehConfig,'.xls'],xlsAllData);
    end
    % Output key parameters
    KeyPara = {fuel100kmConsum,vehEffCyc,transEffCyc,engEffCyc,beAvgAbsolute,motorAvgDischrgEff,motorAvgChrgEff,motorAvgRGBEff,energyDriveReq,regEnergy(end),engONTime,engAvgPow};
    KeyParaStr = {'fuel100kmConsum','vehEffCyc','transEffCyc','engEffCyc','beAvgAbsolute','motorAvgDischrgEff','motorAvgChrgEff','motorAvgRGBEff','energyDriveReq','regEnergy(end)','engONTime','engAvgPow'};
    if auto.user.switchOutXlsData == 1
        for i = 1:length(KeyPara)
            xlswrite(['SimResults',auto.user.vehConfig,'.xls'],KeyParaStr(i),1,['A',num2str(temp+1+i)]);
            xlswrite(['SimResults',auto.user.vehConfig,'.xls'],(KeyPara(i)),1,['B',num2str(temp+1+i)]);
        end
    end
    figure(hEngPoint);
    legend(legendStr);
    figure(hMotPoint);
    legend(legendStr);
    hSOC = KeyFigure(cycCount,auto);
    hEngWorPer = WorkPercentStat(auto.cycPara.time,cycCount.eng.spd,cycCount.eng.te);
    % Automatic screenshot to excel file
    hArray = [hEngPoint,hMotPoint,hSOC,hEngWorPer];
    if auto.user.switchOutXlsFig == 1
        SimResOut(hArray,auto);
    end
    %% Post processing disp
    dispInterval = '  ';
    for i = 1:10            % 10 indicators,include propTime,mtDisEff,mtChgEff,engBe,engEff....
        if i == 1
            fprintf(['       ','propTime']);
        else
            fprintf([dispInterval,char(xlsTitle(i))]);
        end
        if i == 10
            fprintf('\n');
        end
    end
% The above code has the same effect as the following code
%         disp(['       ','propTime',dispInterval,'mtDisEff',dispInterval,'mtChgEff',...
%         dispInterval,'engBe  ',dispInterval,'engEff  ',dispInterval,'fuelVol ',dispInterval,...
%         'reqEngy ',dispInterval,'engPow  ',dispInterval,'batEngy ',dispInterval,'avgEff  ']);
    FixedLength = 7;
    for i = 1:(auto.mode.End)-1
        mode = i;
        if ~isempty(find(mode == cycCount.mode, 1))
            singleInterval = ' ';
            interval = singleInterval(1,ones(1,FixedLength-length(char(modeNameStr(i)))));
            fprintf([char(modeNameStr(i)),interval]);
            for j = 1:10            % 10 indicators,include propTime,mtDisEff,mtChgEff,engBe,engEff....
                roundValue = floor(modeStatistics(i,j)*10000)/10000;
                interval = singleInterval(1,ones(1,10-length(num2str(roundValue))));
                fprintf([num2str(roundValue),interval]);
                if j == 10
                    fprintf('\n');
                end
            end
        end
    end
    post.fuel100kmConsum = fuel100kmConsum;
    post.vehEffCyc = vehEffCyc;
    post.transEffCyc = transEffCyc;
    post.engEffCyc = engEffCyc;
    post.beAvgAbsolute = beAvgAbsolute;
    post.motorAvgDischrgEff = motorAvgDischrgEff;
    post.motorAvgChrgEff = motorAvgChrgEff;
    post.motorAvgRGBEff = motorAvgRGBEff;
    post.energyDriveReq = energyDriveReq;
    post.regEnergy =regEnergy(end);
    post.engONTime = engONTime;
    post.engAvgPow = engAvgPow;
    post.engTotalFuelOutEnergy = engTotalFuelOutEnergy;
    pose.batEnergyChange = batEnergyChange;
    OutCommandWindow(cycCount,post);
    cycCount.post = post;%
end
%%
%{
 % @brief  Statistical parameters of different components in different modes
 % @param cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure  
 %        
 % @retval modeStatistics : the return value contain the following value :
%          propTime,motorAvgDischgEff,motorAvgChgEff,engAvgBe,engAvgEff,fuelVolume,reqAllEnergy,engAvgPow,batEnergy,avgEff
%}
function modeStatistics = EveryModeCount(cycCount,auto,mode,hEngPoint,hMotPoint)
    color={'gx','yx','cx','mx','rx','kx','g.','r.','c.'};    
    modeId = find(mode == cycCount.mode);                                                               % Count time point of mode
    propTime = length(modeId)/length(auto.cycPara.time);                                                % Mode time proportion
    %% Engine statistics
    Me = cycCount.eng.B(modeId)*1000*auto.engPara.fuelDen;                  % 
    fuelMass = (sum(Me)+eps);                                                                          % g/h    
    fuelVolume = sum(cycCount.eng.B(modeId)/3600);                                  % L   
    engEnergy = sum(cycCount.eng.te(modeId).*cycCount.eng.spd(modeId)/9549);       
    engAvgPow = engEnergy/length(modeId);              % engine average power
    engAvgBe = fuelMass/(engEnergy+eps);             % engine average fuel consumption rate
    engAvgEff = 1./(engAvgBe.*auto.engPara.fuelClori/3600+eps);

    % Motor drive average efficiency
    motorAvgDischgEff = sum(cycCount.motor.tmc(modeId).*cycCount.motor.spd(modeId))/sum(cycCount.motor.tmc(modeId).*cycCount.motor.spd(modeId)./cycCount.motor.eff(modeId));
    motorAvgChgEff=sum(cycCount.motor.tmc(modeId).*cycCount.motor.spd(modeId).*cycCount.motor.eff(modeId))/sum(cycCount.motor.tmc(modeId).*cycCount.motor.spd(modeId));
    %motorChargeEnergy = sum(cycCount.motor.tmc(modeId)).*cycCount.motor.spd(modeId)/9549.*cycCount.motor.eff(modeId);  % kWs Input electric power to the battery
    %peAvg = 
    %fuelAll = 
    powDriveReq = (auto.cycPara.whTt>0).*auto.cycPara.whTt.*auto.cycPara.whRotaSpd/9549;                % kw Drive power at the wheel
    reqAllEnergy = sum(powDriveReq(modeId));
    batEnergy = sum(cycCount.bat.volt(modeId).*cycCount.bat.curr(modeId))/1000;                                                %  Battery power  discharge negative ;charge positive
    % Efficiency in different modes
    switch mode
        case {auto.mode.EV,auto.mode.SHEV,auto.mode.ICE,auto.mode.BHEV,auto.mode.RGBMech}
            avgEff = reqAllEnergy/(engEnergy-batEnergy);                                                                 
        case auto.mode.CHEV 
            avgEff = (reqAllEnergy+batEnergy)/(engEnergy);   
        otherwise
            avgEff = 0;
    end
    modeStatistics = [propTime,motorAvgDischgEff,motorAvgChgEff,engAvgBe,engAvgEff,fuelVolume,reqAllEnergy,engAvgPow,batEnergy,avgEff]*(~isempty(modeId));
    modeStatistics = constrain(modeStatistics);
    if ~isempty(modeId)
        figure(hEngPoint);
        plot(cycCount.eng.spd(modeId),cycCount.eng.te(modeId),color{mode},'markersize',6);
        figure(hMotPoint);
        plot(cycCount.motor.spd(modeId),cycCount.motor.tmc(modeId),color{mode},'markersize',6);
    end
end
%%
%{
 % @brief  Take a fixed decimal place, limit the size range
 % @param array :  the input array
 %        
 % @retval conarray :  the value has been costrained
%}
function conarray = constrain(array)
    conarray = array;
    arrayabs = abs(array);
    id1 = arrayabs>1000;
    conarray(id1) = fix(array(id1));
    id2 = arrayabs>999999;
    conarray(id2) = inf;
    id3 = arrayabs<1000;
    conarray(id3) = fix(100*(array(id3)))/100;
    id4 = arrayabs<1;
    conarray(id4) = fix(10000*(array(id4)))/10000;
    id5 = isnan(array);
    conarray(id5) = 0;
end
%%
%{
 % @brief  Output calculation results under the command window
 % @param cycCount :  Vehicle working condition variable structure
 %        post     :
 % @retval no retval
%}
function OutCommandWindow(cycCount,post)
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp(['100 km fuel consumption                            ~ fuel100kmConsum     = ',num2str(post.fuel100kmConsum),'L']); 
    disp(['SOC final value                                    ~ SOC(end)            = ',num2str(cycCount.bat.SOC(end)),' ']);
    disp(['Vehicle system efficiency                          ~ vehEffCyc           = ',num2str(post.vehEffCyc)]);
    disp(['Transmission system efficiency                     ~ transEffCyc         = ',num2str(post.transEffCyc)]);
    disp(['Engine efficiency                                  ~ engEffCyc           = ',num2str(post.engEffCyc)]);
    disp(['Average effective fuel consumption rate            ~ beAvgAbsolute       = ',num2str(post.beAvgAbsolute),'g/kWh']);
    disp(['Motor average discharge efficiency                 ~ motorAvgDischrgEff  = ',num2str(post.motorAvgDischrgEff)]);
    disp(['Motor average charge efficiency                    ~ motorAvgChrgEff     = ',num2str(post.motorAvgChrgEff)]);
    disp(['Regenerative braking motor efficiency              ~ motorAvgRGBEff      = ',num2str(post.motorAvgRGBEff)]);
    disp(['Total drive energy                                 ~ energyDriveReq      = ',num2str(post.energyDriveReq),'kJ']);
    disp(['Regenerative braking to recover energy             ~ regEnergy           = ',num2str(post.regEnergy),'kJ']);
    disp(['Engine working time                                ~ engONTime           = ',num2str(post.engONTime),'s']);
    disp(['Engine average power                               ~engAvgPow            = ',num2str(post.engAvgPow),'kW']);
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
end
%{
 % @brief  Key image of the calculation result
 % @param cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure  
 %        
 % @retval hf     :  Figure Handles
%}
function hf = KeyFigure(cycCount,auto)
    hSOC = figure;
    subplot(2,1,1)
    plot(auto.cycPara.time,cycCount.bat.SOC,'r','linewidth',2);hold on;
    xlabel('time(s)');ylabel('SOC');
    title('SOC changes and working modes change over time');
    subplot(2,1,2)
    plot(auto.cycPara.time,cycCount.mode,'r','linewidth',2);hold on;
    xlabel('time(s)');ylabel('mode');
    hVeAcc = figure;
    subplot(2,1,1)
    plot(auto.cycPara.time,auto.cycPara.ve,'b','linewidth',2);hold on;
    xlabel('time(s)');ylabel('vehSpd（km/h）');
    title('Cycle');
    subplot(2,1,2)
    plot(auto.cycPara.time,auto.cycPara.acc,'b','linewidth',2);hold on;
    xlabel('time(s)');ylabel('vehAcc（m/s^2）');
    hgear = figure;
%     plot(auto.cycPara.time,auto.cycPara.gear,'b','linewidth',2);
%     xlabel('time(s)');ylabel('gearPos');
%     title('Gearbox gear position');
    hSpdTrq = figure;
    subplot(2,1,1)
    plot(auto.cycPara.time,cycCount.eng.spd,'b','linewidth',2);hold on;
    xlabel('time(s)');ylabel('speed(rpm)');
    title('Engine speed and torque');
    subplot(2,1,2)
    plot(auto.cycPara.time,cycCount.eng.te,'b','linewidth',2);hold on;
    xlabel('time(s)');ylabel('torque(Nm)');
    hf = [hSOC,hVeAcc,hgear,hSpdTrq];
end