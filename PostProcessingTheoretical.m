function cycCount = PostProcessingTheoretical(auto,cycCount)
    %% Theoretical cycle total drive energy
    powDriveReq = (auto.cycPara.whTt>0).*auto.cycPara.whTt.*auto.cycPara.whRotaSpd/9549;                % kw Drive power at the wheel
    energyDriveReq = trapz(auto.cycPara.time,powDriveReq*1000)/1000;                                    % kJ Total drive energy
    %% Theoretical cycle total brake energy
    powBrakeReq = (auto.cycPara.whTt<0).*auto.cycPara.whTt.*auto.cycPara.whRotaSpd/9549;                % kw Drive power at the wheel
    energyBrakeReq = trapz(auto.cycPara.time,powBrakeReq*1000)/1000;                                    % kJ Total drive energy
    %% Battery Charge and Discharge mean Efficiency
    batChrgAvgEff = mean(cycCount.bat.effIn(cycCount.bat.effIn~=0));
    batDischrgAvgEff = mean(cycCount.bat.effOut(cycCount.bat.effOut~=0));
    %% Regenerative braking energy statistics
    regEnergy = zeros(length(auto.cycPara.time),1);
    for i=2:length(auto.cycPara.whTt)
        if auto.cycPara.whTt(i)<0
            regEnergy(i)=regEnergy(i-1)+cycCount.bat.energyIn(i)-cycCount.bat.energyIn(i-1);
        else
            regEnergy(i)=regEnergy(i-1);
        end
    end
    if cycCount.bat.SOC(1)>cycCount.bat.SOC(end)
       netChrgEnergy = 0;
       netDisChrgEnergy = max(0,cycCount.post.batEnergyChange);                     % disChrg +    Chrg  -
    else 
       netChrgEnergy =  min(0,cycCount.post.batEnergyChange);
       netDisChrgEnergy =0;
    end
    EnergyDriveSysInput = post.engTotalFuelOutEnergy+post.regEnergy*batChrgAvgEff*batDischrgAvgEff+netDisChrgEnergy*batDischrgAvgEff;
    if cycCount.bat.SOC(1)<cycCount.bat.SOC(end)
        % EnergyDriveSysOutput =
        % energyDriveReq-netChrgEnergy/batChrgAvgEff/IntTransEff
        f = @(x)[(energyDriveReq-netChrgEnergy/batChrgAvgEff/x)/EnergyDriveSysInput-x];
        IntTransEff = fsolve(f,1);
    else
        EnergyDriveSysOutput = energyDriveReq;
        IntTransEff = EnergyDriveSysOutput/EnergyDriveSysInput;
    end
    %% Corrected fuel consumption calculation according to SOC
    if cycCount.bat.SOC(1)>cycCount.bat.SOC(end)
        fuelEcoUnify = cycCount.post.fuel100kmConsum+netDisChrgEnergy*cycCount.post.beAvgAbsolute*(1/1000/auto.engPara.fuelDen/3600/auto.cycPara.dis*100);
    else
        fuelEcoUnify = -netChrgEnergy/IntTransEff/IntTransEff*cycCount.post.beAvgAbsolute*(1/1000/auto.engPara.fuelDen/3600/auto.cycPara.dis*100);
    end
end

