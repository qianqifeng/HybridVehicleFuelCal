csChargePwr = 0;gcMapSpd,gcMapTrq,gcOutPwrMap
csPwr = [];csSpd = [];
busPwrReq = Constrain(busPwrReq,csPwr);
gcSpd = interp1(csPwr,csSpd,busPwrReq);
gcTrq = busPwrReq/(gcSpd+eps)*9549;
gcOutPwr = interp2(gcMapSpd,gcMapTrq,gcOutPwrMap,gcSpd,gcTrq);
genEff = gcOutPwr/(busPwrReq+eps);
tempFCPwrReq = busPwrReq/(genEff+eps)*(busPwrReq>0);
% FC pwr command modified by SOC
temp = (0.5*(HighSOC+LowSOC)-SOC)/0.5*(HighSOC-LowSOC);
tempLim = Constrain(temp,-1,1);
FCPwrReq = tempFCPwrReq+tempLim*csChargePwr*tempLim;

csMinPwr=max(fcMaxTrq.*fcMapSpd)*.15;
% (W), maximum operating power for genset (exceeded only if SOC<cs_lo_soc)
csMaxPwr=max(fcMaxTrq.*fcMapSpd)*.55;

FCPwrReq = Constrain(FCPwrReq,csMinPwr,csMaxPwr);
FCPwrReq = Constrain(FCPwrReq,csPwr);
fcSpd = interp1(csPwr,csSpd,FCPwrReq);
fcTrq = FCPwrReq/(fcSpd+eps)*9549;


