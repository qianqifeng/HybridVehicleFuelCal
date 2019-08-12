clear;clc;close all;
ParaInitOne;
RunProgress = 0;
tic
global EngOnPower flagCS flag
global recBatPow relayMode
EngOnPower = 40; relayMode = 1; recBatPow = 0;flagCS = 1;flag = 0;
for count = 2:length(auto.cycPara.time)
    cycMode = ModeSwitchRule(count,cycCount,auto);
    switch cycMode
        case auto.mode.STOP
            cycCount = VehilceOperateMode(auto.mode.STOP,count,cycCount,auto);
        case auto.mode.EV
            cycCount = VehilceOperateMode(auto.mode.EV,count,cycCount,auto);
        case auto.mode.SHEV
            cycCount = VehilceOperateMode(auto.mode.SHEV,count,cycCount,auto);
        case auto.mode.CHEV
            cycCount = VehilceOperateMode(auto.mode.CHEV,count,cycCount,auto);
        case auto.mode.ICE
            cycCount = VehilceOperateMode(auto.mode.ICE,count,cycCount,auto);
        case auto.mode.BHEV
            cycCount = VehilceOperateMode(auto.mode.BHEV,count,cycCount,auto);
        case auto.mode.RGB
            cycCount = VehilceOperateMode(auto.mode.RGB,count,cycCount,auto);
        case auto.mode.MB
            cycCount = VehilceOperateMode(auto.mode.MB,count,cycCount,auto);
        case auto.mode.RGBMech
            cycCount = VehilceOperateMode(auto.mode.RGBMech,count,cycCount,auto);
        otherwise
            error('mode select error');
    end
    clc;
    RunProgress = RunProgress+1;%counting the progress
    RunPer = RunProgress/length(auto.cycPara.time)*100;
    disp([num2str(RunPer),'%']);
end
toc
clear cycMode count RunProgress RunPer;
[~] = EngEquFuelCurPlt(auto.engPara.spdData,auto.engPara.trqData,auto.engPara.bData);
plot(auto.engPara.maxSpd,auto.engPara.maxTrq, 'b','linewidth',2);
plot(auto.engPara.optMap(:,2),auto.engPara.optMap(:,3),'g--o','linewidth',2);
plot(cycCount.eng.spd,cycCount.eng.te,'rx','markersize',6);hold on;    % Plot engine working point
PostProcessing(cycCount,auto);






