%{
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % @file               ParaInitOne.m
 % @author             New Energy Automobile Team
 % @version            V1.0  
 % @data               11-June-2019 
 % @brief              Initialize parameters changing during cycle 
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
%%
clear;clc;close all;
%% User control interface
user.ver = 'V2.0';
user.vehConfig = 'OneWeiChai';
user.switchRGB = 1;                                                  % RGB is ON
user.switchOutXlsData = 0;
user.switchOutXlsFig = 0;
%% engine property parameter 
fcData = xlsread('engine2.0T.xls','sheet1','A2:C171');
[maxSpd,maxTrq] = EngMaxCharact(fcData(:,1),fcData(:,2));
[xi,yi,zi] = EngEquFuelCurPlt(fcData(:,1),fcData(:,2),fcData(:,3));
finalMap = EngOptCur(fcData(:,1),fcData(:,2),fcData(:,3));
engPara.optMap = finalMap;
engPara.spdData = fcData(:,1);engPara.trqData = fcData(:,2);engPara.bData = fcData(:,3);
engPara.maxSpd = maxSpd;engPara.maxTrq = maxTrq;
engPara.xi = xi;engPara.yi = yi;engPara.zi = zi;
engPara.fuelDen = 0.725;                                                            % kg/L #92 汽油
engPara.fuelIdle = 1.2;                                                             % L/h
engPara.fuelClori = 44;                                                           % kJ/g according to GBT 2589—2008
engPara.engIdleSpd = 800;                                                           % rpm
p = polyfit(maxSpd,maxTrq,6);                                                       %六次多项式拟合
maxxi = maxSpd(1):0.1:maxSpd(end);
trqSmooth = polyval(p,maxxi);

engPara.spdOpt = linspace(1200,4000,30);
p = polyfit(finalMap(1:end,2),finalMap(1:end,3),6);                     % Sixth degree polynomial fitting
trqSmooth = polyval(p,engPara.spdOpt);
plot(engPara.spdOpt,trqSmooth, 'b--','linewidth',2);
powOpt = trqSmooth.*engPara.spdOpt/9549;
engPara.powOpt = powOpt;
engPara.trqOpt = trqSmooth;
% plot(maxxi,trqSmooth, 'r--','linewidth',2);
clear maxSpd maxTrq xi yi zi p maxxi trqSmooth powOpt;
%% battery property parameter 
batPara.SOCIni = 0.3;
batPara.E = 40.5;                                                                   % kwh
batPara.C = 105;                                                                     % Ah
batPara.U = 384;                                                                    % V
batPara.disChargeRate = 8;                                                          % 8C
batPara.maxCurOut = batPara.C*batPara.disChargeRate;
batPara.maxCurIn = batPara.C*batPara.disChargeRate;
batPara.eff = 0.90;                                                                 % Average battery efficiency
batPara.Roh = 0.08;                                                                 %Ohm Battery internal resistance
batPara.mapSOC = 0:0.1:1;                       
batPara.mapUidle = [305.136	350.48	366.912	372.944	378.56	383.864	389.48	396.864	406.848	417.768	427.366];
%% vehicle property parameter 
vehPara.delta = 1.15;
vehPara.gravity = 9.81;                                                             % m/s^2
vehPara.Cd = 0.335;                                                                  % 
vehPara.Fa = 2.5;                                                                 % (m^2) 
vehPara.mass = 2270;                                                                % kg 
%% clutch property parameter 
% clPara.eff = 1;                                                                     % clutch efficiency
%% grarbox & Final drive property parameter 
gbPara.fdRatio = 4.111;
gbPara.fdEff = 0.96;
% gbPara.gear = 1:12;
% gbPara.ratio = [12.10 9.41 7.31 5.71 4.46 3.48 2.71 2.11 1.64 1.28 1.00 0.78];      % transmisson gear ratios
% gbPara.eff = 0.96*ones(1,12);cycPara.gbEff(12) = 0.97;
%% generator property parameter 
genPara.eff = 0.92;
genData = xlsread('Motor.xls','sheet1','A2:C64');
[xi,yi,zi] = MotorEquEffCurPlt(genData(:,1),genData(:,2),genData(:,3));
%% motor property parameter 
[bestSpd,gentrq] = APUOptCurPlt(fcData(:,1),fcData(:,2),fcData(:,3),genData(:,1),genData(:,2),genData(:,3));
engPara.spdOpt = bestSpd(2:end-1);
tempPwr = gentrq.*bestSpd/9549;
engPara.powOpt = tempPwr(2:end-1);

engPara.spdOpt = bestSpd;
engPara.powOpt = tempPwr;
% motorData = load('MotorDATA_250KW.mat');
% motorPara.spdData =  motorData.mc_xi;
% motorPara.trqData =  motorData.mc_yi;
% motorPara.effData =  motorData.mc_zi;
% motorPara.ratio = 3;
% motorPara.mapSpd = [0.3;60;120;180;240;300;600;750;1200;1500;1800;2100;2400;2700;3000];
% motorPara.mapTrq = [2000;2000;2000;2000;2000;2000;2000;2000;1317.4;1053.8;878.1;752.8;658.5;585.5;526.8];
motorPara.RGBPowerLim = 160;                                                        % kW Regenerative braking power limit
% clear motorData 
peakTrq = 300;              %Nm
% turnSpd = 4800;             % rpm
maxSpd = 12000;             % rpm
peakPow = 120;              % kw
[spd,trq] = MotorConstruction(peakTrq,maxSpd,peakPow);
motorPara.mapSpd = spd;
motorPara.mapTrq = trq;
motorPara.eff = 0.90;
motorPara.ratio = 2.2;
motorPara.maxSpd = maxSpd;
clear peakTrq maxSpd peakPow spd trq


%% Brake property parameter     
brkPara.PreMax = 20*10^6;                                                           % pa 10MPa
brkPara.pistonSurface = 3166.92*0.1^6;                                              % m^2
brkPara.brakeFactor = 1.0;          
brkPara.effRadius = 205*0.1^3;                                                      %m
brkPara.eff = 0.97;
brkPara.frictCoeff = 0.35;
brkPara.trqMax = brkPara.PreMax*brkPara.pistonSurface*brkPara.brakeFactor*brkPara.effRadius*2*brkPara.eff*brkPara.frictCoeff*4;% 车轮处总制动转矩（4个制动器）
%% aerodynamics property parameter 
aerodyPara.airDensity = 1.2258;                                                     % kg/m^3
%% wheel property parameter 
wheelPara.radius = 0.35;                                                           % m
wheelPara.rrc1 = 0.008;                                                             %

%% cycle property parameter 

% 
% % cycleData=xlsread('实车工况.xlsx','A2:C88121');
% % cycleData = load('c_wtvc_data.mat');
% cycPara.time = cycleData(1:10:end,1);                                               % s
% cycPara.ve = cycleData(1:10:end,2);                                                 % km/h
% cycPara.v = cycleData(:,2)/3.6;                                                     % m/s
% 
cycT = 10;
load CYC_ECE.mat
cyc_mph_ece=cyc_mph;
load CYC_EUDC.mat
cyc_mph=[cyc_mph_ece;...
      cyc_mph_ece;...
      cyc_mph_ece;...
      cyc_mph_ece;...
      cyc_mph]/0.62;
cyc_mph(:,1)=[0:length(cyc_mph)-1]';
figure;
plot(cyc_mph(:,1),cyc_mph(:,2));
cycPara.time = (0:cycT*length(cyc_mph(:,1))-1)';                                                    % s
cycPara.ve = repmat(cyc_mph(:,2),cycT,1);                                                  % km/h
cycPara.v = cycPara.ve/3.6;                                                   % m/s
% cycleData = load('WLTCCyc.mat');
% cycPara.time = cycleData.CycData(:,1);                                               % s
% cycPara.ve = cycleData.CycData(:,2);                                                 % km/h
% cycPara.v = cycPara.ve/3.6;    
% figure;
% plot(cycPara.time,cycPara.ve,'LineWidth',3);xlabel('time/s');ylabel('velocity/km/h');title('WLTC Velocity-Time');

% cycPara.gear = cycleData(:,3);
% [~,cycPara.gear] = GearShiftLogic(wheelPara,gbPara,1000,1400);                      %
cycPara.dis = trapz(cycPara.time,cycPara.ve./3.6)/1000;                             % km
cycPara.glope = zeros(length(cycPara.time),1);                                      %
cycPara.acc = [0;(cycPara.ve(2:end)-cycPara.ve(1:end-1))./(cycPara.time(2:end)-cycPara.time(1:end-1))];%m/s/s
% cycPara.gearRatio = interp1(gbPara.gear,gbPara.ratio,cycPara.gear ,'linear');       % cycle gear Corresponding ratio
% cycPara.gearEff = interp1(gbPara.gear,gbPara.eff,cycPara.gear,'linear');            %cycle gear Corresponding efficiency
[whPow,whTt,whRotaSpd] = VehicleModel(vehPara,cycPara,aerodyPara,wheelPara);
powDriveReq = (whTt>0).*whTt.*whRotaSpd/9549;
powBrakeReq = (whTt<0).*whTt.*whRotaSpd/9549;

energyDriveReq = trapz(cycPara.time,powDriveReq*1000)/1000;  
energyBrakeReq = trapz(cycPara.time,powBrakeReq*1000)/1000;  
k = (28.35*3600*0.95*0.95)/(energyDriveReq+energyBrakeReq*0.3);
kk = energyBrakeReq/energyDriveReq;
cycPara.whPow = whPow;
cycPara.whTt = whTt;
cycPara.whRotaSpd = whRotaSpd;
cycPara.motorSpd = cycPara.whRotaSpd*motorPara.ratio*gbPara.fdRatio;
cycPara.motorTrq = cycPara.whTt/motorPara.ratio/gbPara.fdRatio/gbPara.fdEff;
cycPara.motorMaxTrq = interp1(motorPara.mapSpd,motorPara.mapTrq,cycPara.motorSpd);
cycPara.mcRGBTLim = motorPara.RGBPowerLim*9549./(cycPara.motorSpd+eps);                % Regenerative braking  eps is used for preventing inf
% cycPara.mcRGBTLim = min(cycPara.mcTmax,cycPara.mcRGBTLim);
cycPara.brkPedal = -(cycPara.whTt<0).*cycPara.whTt/brkPara.trqMax;
clear whPow whTt whRotaSpd cycleData m finalMap;
%% mode property parameter 
mode.STOP=1;                                           % Parking mode        
mode.EV=2;                                             % Pure electric mode
mode.SHEV=3;                                           % rpm generator speed
mode.CHEV=4;                                           % rpm generator speed
mode.ICE=5;                                            % Engine direct drive mode
mode.BHEV=6;                                           % rpm generator speed
mode.RGB=7;                                            % Brake energy recovery mode
mode.MB=8;                                             % Mechanical brake mode
mode.RGBMech = 9;
mode.End = 10;                                         % Prohibit modification
%% Collection of component
auto.user = user;
auto.engPara = engPara;
auto.batPara = batPara;
auto.vehPara = vehPara;
% auto.clPara = clPara;
auto.gbPara = gbPara;
auto.motorPara = motorPara;
auto.genPara = genPara;
auto.brkPara = brkPara;
auto.aerodyPara = aerodyPara;
auto.wheelPara = wheelPara;
auto.cycPara = cycPara;
auto.mode = mode; 
clear user engPara batPara vehPara clPara gbPara motorPara brkPara aerodyPara wheelPara cycPara mode
%% 

initLength = length(auto.cycPara.time);
%% battery status initialize
bat.curr = zeros(initLength,1);                       % A current
bat.SOC = zeros(initLength,1);                        %
bat.SOC(1) = auto.batPara.SOCIni; 
bat.volt = zeros(initLength,1);                       % V voltage
bat.pow = zeros(initLength,1);                        % W power 
bat.energyIn = zeros(initLength,1);                   % kJ  Total Input Energy of Battery
bat.energyOut = zeros(initLength,1);                  % kJ  Total Output Energy of Battery 
bat.effIn = zeros(initLength,1);                      %  Charging efficiency
bat.effOut = zeros(initLength,1);                     %  Discharging efficiency
bat.be = zeros(initLength,1);                         % g/kwh   fuel consumption rate
bat.B = zeros(initLength,1);                          % L/h  Fuel consumption
%
%% engine status initialize
eng.te = zeros(initLength,1);                         % Nm engine torque
eng.spd = zeros(initLength,1);                        % rpm engine speed
eng.be = zeros(initLength,1);                         % g/kwh   fuel consumption rate
eng.B = zeros(initLength,1);                          % L/h  Fuel consumption
%% motor status initialize
motor.tmc = zeros(initLength,1);                      % Nm motor torque
motor.spd = zeros(initLength,1);                      % rpm motor speed
motor.eff = zeros(initLength,1);                      % motor efficiency
%% generator status initialize
generator.tgc = zeros(initLength,1);                  % Nm generator torque
generator.spd = zeros(initLength,1);                  % rpm generator speed
generator.eff = zeros(initLength,1);                  % generator efficiency
%% operation mode status initialize    

mode = zeros(initLength,1);                           % initial operating mode
%% Collection of parts
cycCount.bat = bat;                                   % 
cycCount.eng = eng;                                   %
cycCount.motor = motor;                               % 
cycCount.generator = generator;                       % 
cycCount.mode = mode;                                 % 
clear bat eng motor generator mode 
clear initLength