%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               VehilceOperateMode.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               23-April-2019 
 % @brief              Implementation in different modes
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
 % @brief  Implementation in different modes
 % @param mode: Auto mode
 %        @arg auto.mode.STOP,EV,SHEV,CHEV,ICE,BHEV,RGB,RGBMech,MB
 %        wh_1st_rrc: (滚阻系数)
 %        @arg Scalar
 %        count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure  
 %        
 % @retval whPow         Wheel power demand  Kw
 %         whTt          Torque demand wheel  Nm
 %         whRotaSpd     Wheel speed  rpm
%}
function cycCount = VehilceOperateMode(mode,count,cycCount,auto)
    switch mode
        case auto.mode.STOP
            cycCount = ModePark(count,cycCount,auto);
        case auto.mode.EV
            cycCount = ModeEV(count,cycCount,auto);
        case auto.mode.SHEV
            cycCount = ModeSHEV(count,cycCount,auto);
        case auto.mode.CHEV
            cycCount = ModeCHEV(count,cycCount,auto);
        case auto.mode.ICE
            cycCount = ModeICE(count,cycCount,auto);
        case auto.mode.BHEV
            cycCount = ModeBHEV(count,cycCount,auto);
        case auto.mode.RGB
            cycCount = ModeRegBrake(count,cycCount,auto);
        case auto.mode.RGBMech
            cycCount = ModeRegMechBrake(count,cycCount,auto);
        case auto.mode.MB
            cycCount = ModeMechBrake(count,cycCount,auto);
        otherwise
            error('mode function VehilceOperateMode error');
    end
end
%{
 % @brief  Parking mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModePark(count,cycCount,auto)
    %Engine status  update
    engTe = 0;
    engSpd = 0;
    engBe = 0;
    engB = 0;
    %Motor status  update
    motorSpd = 0;
    motorTm = 0;
    motorEff = 0;  
    %Generator status  update
    genTgc = 0;
    genSpd = 0;
    genEff = 0;  
    %Battery status  update
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff);
    %operation mode update
    modeUpdate = auto.mode.STOP;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
 end
%{
 % @brief  ICE mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModeICE(count,cycCount,auto)
    %Engine status  update
    engPow = auto.cycPara.whPow(count)/auto.motorPara.eff/auto.genPara.eff;
%     if FCPwrReq>60
%         disp(['FCPwrReq is too large is ',num2str(FCPwrReq)]);
%     end

    engSpd = auto.cycPara.whRotaSpd(count)*auto.gbPara.fdRatio ;
    
    engTe = auto.cycPara.whTt(count)/auto.gbPara.fdRatio/auto.gbPara.fdEff;
    
    engBe = min(250,max(0,interp2(auto.engPara.xi,auto.engPara.yi,auto.engPara.zi,max(1200,engSpd),abs(engTe),'line'))); %max(max(zi))=245.32
    engB = engBe*engSpd*engTe/9549/1000/auto.engPara.fuelDen;  
    %Motor status  update
    motorSpd = 0;
    motorTm = 0;
    motorEff = 0;  
    motorPow = motorSpd*motorTm/9549;
    %Generator status  update
    genTgc = 0;
    genSpd = 0;
    genEff = 0;  
    %Battery status  update
    batPow = 0;
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff,batPow);
    %operation mode update
    modeUpdate = auto.mode.ICE;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
end
%{
 % @brief  EV mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModeEV(count,cycCount,auto)
    %Engine status  update
    engTe = 0;
    engSpd = 0;
    engBe = 0;
    engB = 0;
    %Motor status  update
    motorSpd = min(auto.cycPara.motorSpd(count),auto.motorPara.maxSpd);
    motorTm = min(auto.cycPara.motorTrq(count),auto.cycPara.motorMaxTrq(count));
    motorEff = auto.motorPara.eff;  
    %Generator status  update
    genTgc = 0;
    genSpd = 0;
    genEff = 0;
    %Battery status  update
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff);
    %operation mode update
    modeUpdate = auto.mode.EV;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
end
%{
 % @brief  CHEV mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModeCHEV(count,cycCount,auto)
    %Engine status  update
    engTe = auto.cycPara.engTopt(count);
    engSpd = auto.cycPara.engSpd(count);
    %Motor status  update
    motorSpd = min(auto.cycPara.motorSpd(count),auto.motorPara.maxSpd);
    motorTm = -min(max(auto.motorPara.mapTrq),(engTe-auto.cycPara.whTt(count)/auto.gbPara.fdRatio/auto.gbPara.fdEff)/auto.motorPara.ratio);
    motorEff = 0.90;
    engTe = (auto.cycPara.whTt(count)/auto.gbPara.fdRatio/auto.gbPara.fdEff-motorTm*auto.motorPara.ratio)/auto.cycPara.gearEff(count)/auto.cycPara.gearRatio(count);
    engBe = min(240,max(0,interp2(auto.engPara.xi,auto.engPara.yi,auto.engPara.zi,max(800,engSpd),abs(engTe),'spline')));
    engB = engBe*engSpd*engTe/9549/1000/auto.engPara.fuelDen;  
    %Generator status  update
    genTgc = 0;
    genSpd = 0;
    genEff = 0;
    %Battery status  update
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff);
    %operation mode update
    modeUpdate = auto.mode.CHEV;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
end

%{
 % @brief  SHEV mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModeSHEV(count,cycCount,auto)
    global recBatPow flagCS
    engPow = auto.cycPara.whPow(count)/auto.motorPara.eff/auto.genPara.eff;
    if flagCS
        HighSOC = 0.4;LowSOC = 0.2;csChargePwr = 100;%kw
        temp = (0.3-cycCount.bat.SOC(count-1))/0.5*(HighSOC-LowSOC);
        tempLim = Constrain(temp,0,1);
        FCPwrReq = engPow+tempLim*csChargePwr;
        FCPwrReq = Constrain(FCPwrReq,auto.engPara.powOpt);
    else
        FCPwrReq = 40;
    end
%     if FCPwrReq>60
%         disp(['FCPwrReq is too large is ',num2str(FCPwrReq)]);
%     end

    engSpd = interp1(auto.engPara.powOpt,auto.engPara.spdOpt,FCPwrReq,'line');
    
    engTe = FCPwrReq*9549/engSpd;
    
    engBe = min(250,max(0,interp2(auto.engPara.xi,auto.engPara.yi,auto.engPara.zi,max(1200,engSpd),abs(engTe),'line'))); %max(max(zi))=245.32
    engB = engBe*engSpd*engTe/9549/1000/auto.engPara.fuelDen;  
    %Motor status  update
    motorSpd = min(auto.cycPara.motorSpd(count),auto.motorPara.maxSpd);
    motorTm = min(auto.cycPara.motorTrq(count),auto.cycPara.motorMaxTrq(count));
    motorEff = auto.motorPara.eff;  
    motorPow = motorSpd*motorTm/9549;
    motorPow = min(engPow*auto.motorPara.eff*auto.genPara.eff,motorPow);
    motorTm = motorPow*9549/motorSpd;
    %Generator status  update
    genTgc = engTe;
    genSpd = engSpd;
    genEff = auto.genPara.eff;  
    %Battery status  update
    batPow = (FCPwrReq-engPow);
    recBatPow(count) = batPow;
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff,batPow);
    %operation mode update
    modeUpdate = auto.mode.SHEV;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
end
%{
 % @brief  BHEV mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModeBHEV(count,cycCount,auto)
    %Engine status  update
    engTe = auto.cycPara.engTopt(count);
    engSpd = auto.cycPara.engSpd(count);
    %Motor status  update
    motorSpd = min(auto.cycPara.motorSpd(count),auto.motorPara.maxSpd);
    motorTm = min(160*9549/auto.cycPara.mcSpd (count),abs(auto.cycPara.whTt(count)/auto.gbPara.fdRatio/auto.gbPara.fdEff-engTe*auto.cycPara.gearEff(count)*auto.cycPara.gearRatio(count))/auto.motorPara.ratio);
    motorEff = interp2(auto.motorPara.spdData,auto.motorPara.trqData,auto.motorPara.effData,auto.cycPara.mcSpd(count),motorTm,'spline');
    engTe = (auto.cycPara.whTt(count)/auto.gbPara.fdRatio/auto.gbPara.fdEff-motorTm*auto.motorPara.ratio)/auto.cycPara.gearEff(count)/auto.cycPara.gearRatio(count);
    engBe = min(245.65,max(0,interp2(auto.engPara.xi,auto.engPara.yi,auto.engPara.zi,max(800,engSpd),abs(engTe),'spline')));
    engB = engBe*engSpd*engTe/9549/1000/auto.engPara.fuelDen;  
    if engTe>3000
        disp('BHEV mode engTe very large');
    end
    %Generator status  update
    genTgc = 0;
    genSpd = 0;
    genEff = 0;
    %Battery status  update
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff);
    %operation mode update
    modeUpdate = auto.mode.BHEV;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
end
%{
 % @brief  RegBrake mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModeRegBrake(count,cycCount,auto)
    %Engine status  update
    engTe = 0;
    engSpd = 0;
    engBe = 0;
    engB = 0;
    %Motor status  update
    motorSpd = min(auto.cycPara.motorSpd(count),auto.motorPara.maxSpd);
    motorTm = 0.3*max(auto.cycPara.motorTrq(count),-auto.cycPara.motorMaxTrq(count));
    motorEff = auto.motorPara.eff;  
    %Generator status  update
    genTgc = 0;
    genSpd = 0;
    genEff = 0;
    %Battery status  update
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff);
    %operation mode update
    modeUpdate = auto.mode.RGB;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
end
%{
 % @brief  RegMechBrake mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModeRegMechBrake(count,cycCount,auto)
    %Engine status  update
    engTe = 0;
    engSpd = 0;
    engBe = 0;
    engB = 0;
%     motorTmReq = min(0,(auto.cycPara.whTt(count)+auto.brkPara.trqMax *interp1([0 0.25 1],[0 0 1],);    
    %Motor status  update   
    %insufficient torque is compensated by the motor
    motorSpd = min(auto.cycPara.motorSpd(count),auto.motorPara.maxSpd);
%     motorTm = min(auto.cycPara.motorTrq(count),-auto.cycPara.motorMaxTrq(count));
    motorTm = -min(auto.cycPara.mcRGBTLim(count),abs(auto.cycPara.motorTrq(count)));
    motorEff = auto.motorPara.eff;  
    %Generator status  update
    genTgc = 0;
    genSpd = 0;
    genEff = 0;
    %Battery status  update
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff);
    %operation mode update  
    modeUpdate = auto.mode.RGBMech;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
end
%{
 % @brief  MechBrake mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        auto    :  Automobile inherent parameter structure     
 % @retval cycCount:  Vehicle working condition variable structure
%}
function cycCount = ModeMechBrake(count,cycCount,auto)
    %Engine status  update
    engTe = 0;
    engSpd = 0;
    if engSpd>800
        engBe = 0;
        engB = 0;
    else
        engBe = 0;% 
        engB = 0;
    end
    %Motor status  update   
    %insufficient torque is compensated by the motor
    motorTm = 0;
    motorSpd = 0;
    motorEff = 0;
    %Generator status  update
    genTgc = 0;
    genSpd = 0;
    genEff = 0;
    %Battery status  update
    batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff);
    %operation mode update  
    modeUpdate = auto.mode.MB;
    %all update
    engUpdate = [engTe,engSpd,engBe,engB];
    motorUpdate = [motorTm,motorSpd,motorEff];
    genUpdate = [genTgc,genSpd,genEff];
    cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate);
end
% 
function batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff,varargin)
    if nargin == 5
        motorPow = -motorTm*auto.cycPara.motorSpd(count)/9549*1000;
        if motorPow>=0
            batPow = motorPow*motorEff*auto.batPara.eff;                             % battery power Charges +, Discharge -
        else
            batPow = -motorTm*auto.cycPara.motorSpd(count)/9549*1000/motorEff/auto.batPara.eff;                              % battery power Charges +, Discharge -
        end
    else
        if varargin{1}>0
            batPow = varargin{1}*auto.batPara.eff*1000;
        else
            batPow = varargin{1}/auto.batPara.eff*1000;
        end
    end
    
    batVolt = interp1(auto.batPara.mapSOC,auto.batPara.mapUidle,cycCount.bat.SOC(count-1),'linear');% voltaage V
    batCurr = (-batVolt+(batVolt^2+4*batPow*auto.batPara.Roh)^0.5)/2/auto.batPara.Roh;                                         % current A 
    batSOC = (cycCount.bat.SOC(count-1)*auto.batPara.C*3600+batCurr*1)/(auto.batPara.C*3600);
    batEnergyIn = max(0,(batSOC-cycCount.bat.SOC(count-1))*auto.batPara.C*batVolt*3.6)+cycCount.bat.energyIn(count-1); %Total_Input_Energy of Battery (kJ)
    batEnergyOut = min(0,(batSOC-cycCount.bat.SOC(count-1))*auto.batPara.C*batVolt*3.6)+cycCount.bat.energyOut(count-1); %Total_Output_Energy of Battery (kJ),negative
    batEffIn = (batEnergyIn-cycCount.bat.energyIn(count-1))/(batPow*1/1000)*(batCurr~=0);
    batEffOut = batPow*1/1000/(batEnergyOut-cycCount.bat.energyOut(count-1))*(batCurr~=0);
    batUpdate = [batSOC,batVolt,batCurr,batEnergyIn,batEnergyOut,batEffIn,batEffOut,batPow];
end

% function batUpdate = BatteryCycParaCal(count,cycCount,auto,motorTm,motorEff)
%     mexbatPara.eff = motorEff;
%     mexbatPara.mapSOC = auto.batPara.mapSOC;
%     mexbatPara.mapUidle = auto.batPara.mapUidle;
%     mexbatPara.Roh = auto.batPara.Roh;
%     mexbatPara.C = auto.batPara.C;
%     mexbat.SOC = cycCount.bat.SOC(count-1);
%     mexbat.energyIn = cycCount.bat.energyIn(count-1);
%     mexbat.energyOut = cycCount.bat.energyOut(count-1);
%     mexmotor.spd = auto.cycPara.mcSpd(count);
%     mexmotor.tm = motorTm;
%     mexmotor.eff = motorEff;
%     batUpdate = BatteryCycParaCal_mex(mexbatPara,mexbat,mexmotor);
% end


%{
 % @brief  Parking mode run function
 % @param count: Working point
 %        @arg Scalar Positive integer
 %        cycCount:  Vehicle working condition variable structure
 %        engUpdate    :  Automobile engine parameter update
 %        motorUpdate  :  Automobile motor parameter update
 %        genUpdate    :  Automobile generater parameter update
 %        batUpdate    :  Automobile battery parameter update
 %        modeUpdate   :  Automobile mode update
 % @retval cycCount:  Vehicle working condition variable structure
%}
%engTe,engSpd,engbe,engB,motorTmc,motorEff,generatorTgc,generatorSpd,generatorEff
function cycCount = StatusUpdate(count,cycCount,engUpdate,motorUpdate,genUpdate,batUpdate,modeUpdate)
    %Engine status  update
    cycCount.eng.te(count)          = engUpdate(1);
    cycCount.eng.spd(count)         = engUpdate(2);
    cycCount.eng.be(count)          = engUpdate(3);
    cycCount.eng.B(count)           = engUpdate(4);
    %Motor status  update
    cycCount.motor.tmc(count)       = motorUpdate(1);
    cycCount.motor.spd(count)       = motorUpdate(2);
    cycCount.motor.eff(count)       = motorUpdate(3);  
    %Generator status  update
    cycCount.generator.tgc(count)   = genUpdate(1);
    cycCount.generator.spd(count)   = genUpdate(2);
    cycCount.generator.eff(count)   = genUpdate(3);
    %Battery status  update
    cycCount.bat.SOC(count)         = batUpdate(1); 
    cycCount.bat.volt(count)        = batUpdate(2); 
    cycCount.bat.curr(count)        = batUpdate(3);
    cycCount.bat.energyIn(count)    = batUpdate(4);
    cycCount.bat.energyOut(count)   = batUpdate(5);
    cycCount.bat.effIn(count)       = batUpdate(6);
    cycCount.bat.effOut(count)      = batUpdate(7);
    cycCount.bat.pow(count)         = batUpdate(8); 
    %operation mode update
    cycCount.mode(count)            = modeUpdate;    
end

%更新了电池的充放电能量的正负号问题，其中向电池充电为负，电池向外放电为正