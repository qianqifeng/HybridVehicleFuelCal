% %% battery property parameter 
% batPara.SOCIni = 0.8;
% batPara.E = 19.2;                                                                   % kwh
% batPara.C = 50;                                                                     % Ah
% batPara.U = 384;                                                                    % V
% batPara.disChargeRate = 8;                                                          % 8C
% batPara.maxCurOut = batPara.C*batPara.disChargeRate;
% batPara.maxCurIn = batPara.C*batPara.disChargeRate;
% batPara.eff = 0.90;                                                                 % Average battery efficiency
% batPara.Roh = 0.08;                                                                 %Ohm Battery internal resistance
% batPara.mapSOC = 0:0.1:1;                       
% batPara.mapUidle = [305.136	350.48	366.912	372.944	378.56	383.864	389.48	396.864	406.848	417.768	427.366];

% bat.curr = zeros(initLength,1);                       % A current
% bat.SOC = zeros(initLength,1);                        %
% bat.SOC(1) = auto.batPara.SOCIni; 
% bat.volt = zeros(initLength,1);                       % V voltage
% bat.pow = zeros(initLength,1);                        % W power 
% bat.energyIn = zeros(initLength,1);                   % kJ  Total Input Energy of Battery
% bat.energyOut = zeros(initLength,1);                  % kJ  Total Output Energy of Battery 
% bat.effIn = zeros(initLength,1);                      %  Charging efficiency
% bat.effOut = zeros(initLength,1);                     %  Discharging efficiency
% bat.be = zeros(initLength,1);                         % g/kwh   fuel consumption rate
% bat.B = zeros(initLength,1);                          % L/h  Fuel consumption
% motor.spd
% motor.tm
% motor.eff
% bat.SOC
% bat.energyIn
% bat.energyOut

function batUpdate = BatteryCycParaCal(batPara,bat,motor)
    motorPow = -motor.tm*motor.spd/9549*1000;
    if motorPow>=0
        batPow = motorPow*motor.eff*batPara.eff;                             % battery power Charges +, Discharge -    
    else
       batPow = motorPow/motor.eff/batPara.eff;                              % battery power Charges +, Discharge -    
    end 
    batVolt = interp1(batPara.mapSOC,batPara.mapUidle,bat.SOC,'linear');% voltaage V
    batCurr = (-batVolt+(batVolt^2+4*batPow*batPara.Roh)^0.5)/2/batPara.Roh;                                         % current A 
    batSOC = (bat.SOC*batPara.C*3600+batCurr*1)/(batPara.C*3600);
    batEnergyIn = max(0,(batSOC-bat.SOC)*batPara.C*batVolt*3.6)+bat.energyIn; %Total_Input_Energy of Battery (kJ)
    batEnergyOut = min(0,(batSOC-bat.SOC)*batPara.C*batVolt*3.6)+bat.energyOut; %Total_Output_Energy of Battery (kJ),negative
    batEffIn = (batEnergyIn-bat.energyIn)/(batPow*1/1000)*(batCurr~=0);
    batEffOut = batPow*1/1000/(batEnergyOut-bat.energyOut)*(batCurr~=0);
    batUpdate = [batSOC,batVolt,batCurr,batEnergyIn,batEnergyOut,batEffIn,batEffOut,batPow];
end