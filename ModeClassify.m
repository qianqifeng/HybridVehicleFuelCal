function ModeClassify(cycCount,auto,mode)
    hEngPoint = figure;
    hMotPoint = figure;
    color={'gx','yx','cx','mx','rx','kx','g.','r.','c.'};    
    modeId = find(mode == cycCount.mode);                                                               % Count time point of mode
    propTime = length(modeId)/length(auto.cycPara.time);                                                % Mode time proportion
    if ~isempty(modeId)
        figure(hEngPoint);
        plot(cycCount.eng.spd(modeId),cycCount.eng.te(modeId),color{mode},'markersize',6);
        figure(hMotPoint);
        plot(cycCount.motor.spd(modeId),cycCount.motor.tmc(modeId),color{mode},'markersize',6);
    end
end