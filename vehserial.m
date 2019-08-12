
    
%%

gcMapTrq = 0:5:200;
gcMapSpd = [0:250:7000]*(2*pi)/60;
gcMaxTrq=200*ones(size(gcMapSpd));
gcMapEff = ones(length(gcMapSpd),length(gcMapTrq))*0.95;  % (--)
figure;
plot(gcMapSpd,gcMaxTrq,'color','r','linewidth',4);

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
temp1 = interp1(engMapSpd,engMaxTrq,gensetMapSpd);
temp2 = interp1(gcMapSpd,gcMaxTrq,gensetMapSpd);
%Maximum torque of genset at different speeds
gensetMaxTrq = min([temp1;temp2]);  %vector 2Xlength(gensetMapSpd)
[meshgcMapTrq,meshgcMapSpd] = meshgrid(gcMapTrq,gcMapSpd);
temp1=interp2(meshgcMapTrq,meshgcMapSpd,gcMapEff,gensetMapTrq,gensetMapSpd');
[meshengMapTrq,meshengMapSpd] = meshgrid(engMapTrq,engMapSpd);
temp2=interp2(meshengMapTrq,meshengMapSpd,engMapB,gensetMapTrq,gensetMapSpd');
gensetBSFCMap = temp2./(temp1+eps);
gensetMinPwr = min(gensetMapSpd)*min(gensetMapTrq);
gensetMaxPwr = max(gensetMapSpd.*(min([gensetMaxTrq;ones(size(gensetMaxTrq))*max(gensetMapTrq)])));
gensetPwr = linspace(gensetMinPwr,gensetMaxPwr,11);
for IndexPwr = 2:length(gensetPwr-1)
    spds = ceil(min(gensetMapSpd)):floor(max(gensetMapSpd));
    trqs1 = gensetPwr(IndexPwr)./(spds+eps);
    trqs2 = min(trqs1,max(gensetMapTrq));
    trqs2 = max(trqs2,min(gensetMapTrq));
    BSFCs = interp2(gensetMapSpd,gensetMapTrq,gensetBSFCMap',spds,trqs2);
    BSFCs = BSFCs + (trqs1 > interp1(engMapSpd,engMaxTrq,spds))*10000 ...
      + (trqs1 > interp1(gcMapSpd,gcMaxTrq,spds))*10000;
   if any(isnan(BSFCs))
      error('Error in PTC_SERFO: couldn''t compute genset eff. map')
   end
    bestIndex = find(min(BSFCs)==BSFCs, 1 );
    bestSpd(IndexPwr) = spds(bestIndex);
end

gensetPwr(length(gensetPwr)) = gensetMaxPwr;
if gensetMaxPwr == max(gensetMapSpd.*gensetMaxTrq)
   bestSpd(length(gensetPwr)) = gensetMapSpd(find((gensetMapSpd.*gensetMaxTrq)==gensetMaxPwr));
else
   bestSpd(length(gensetPwr))=max(gensetMapSpd);
end

gensetPwr(1)=min(gensetMapSpd)*min(gensetMapTrq);
bestSpd(1)=min(gensetMapSpd);
gentrq = gensetPwr./bestSpd;
plot(bestSpd,gentrq,'lineWidth',3);


%%
 %pow=linspace(20,max(fc_map_spd.*fc_max_trq*pi/30000),20);
    if size(spd,1)>size(spd,2)
        x = spd; y = trq; z = b;
    else
        x = spd'; y = trq'; z = b';
    end
    dx = 5;
    pow = linspace(min(x.*y*pi/30/1000),max(x.*y*pi/30/1000),20);
    finalMap =zeros(length(pow),5);                 %��ʼ�������񣬵�һ�� ��ţ��ڶ��� ת�٣������� ת�أ������� ���ʣ������� ȼ��������
    fcMaxSpd = engMapSpd;
    fcMaxTrq = engMaxTrq;
    %����ת��xi1��ת��yi1������ֵ�õ�ÿ��ת��ת���µ�ȼ��������zi
    xi1 = min(x):dx:max(x);
%     x = spd; y = trq; z = b;
    spdOptMin = zeros(length(pow),1);
    trqOptMin = zeros(length(pow),1);
    for k = 1:length(pow)                           %����ÿ�����������ŵķ�����ת�غ�ת��
        finalMap(k,1) = k;
        spdXi = xi1;
        trqXi = pow(k)*1000./spdXi/(pi/30);             %ȷ�������±���ÿ��ת��
        trqXi = round(trqXi);                           %�ȹ������߼���ת������,�ӿ�����ٶ�
        trqOutline = interp1(fcMaxSpd, fcMaxTrq,spdXi); %�Գ�������󷢶���ת�صĽ���ȥ��
        OverID = find(trqXi > trqOutline);              
        spdXi(OverID) = [];
        trqXi(OverID) = [];
        if length(spdXi)~=0
        spdXiXi = linspace(spdXi(1),spdXi(end),500);    %ȥ�������¶�ת�ٺ�ת�ؽ����Ų�����ȷ�������µ�ȷ����Χ���ҳ�500������бȽ�scatteredintterpolant
        end
        trqXiXi = pow(k)*1000./spdXiXi/(pi/30);
        FuelXi = griddata(x,y,z,spdXiXi,trqXiXi,'cubic');%�ȹ����²�ֵ��500�����ȼ��������
        tem = isnan(FuelXi); id1 = tem==1; FuelXi(id1) = 1000;%��cubic��ֵ����Nan��,��nearest�������
        [FuelValueMin, ID] = min(FuelXi);                 %�ҳ���500�������С��ȼ�������ʺ�����  
        finalMap(k,5) = FuelValueMin;
        spdOptMin(k) = spdXiXi(ID);             
        trqOptMin(k) = trqXiXi(ID);                     
%         plot(spdXi,trqXi,'r--');                         %�ȹ�������ͼ
    end

    spdOptPart = fcMaxSpd(spdOptMin(end)<fcMaxSpd); trqOptPart = fcMaxTrq(spdOptMin(end)<fcMaxSpd);
    spdOpt = [spdOptMin',spdOptPart']'; trqOpt = [trqOptMin',trqOptPart']';
    %     ID = find((spdOpt(2:end)-spdOpt(1:end-1)) == 0);
    %     spdOpt(ID+1) = spdOpt(ID+1)+1;
    %     trqSmooth = spline(spdOpt,trqOpt,xi1);
    %     trqSmooth = spcrv([[spdOpt(1) spdOpt spdOpt(end)];[trqOpt(1) trqOpt trqOpt(end)]],2);
    %     p = polyfit(spdOpt,trqOpt,6);                  %���ζ���ʽ���
    %     trqSmooth = polyval(p,xi1);
    %     plot(xi1,trqSmooth, 'b--','linewidth',2);
    plot(spdOptMin,trqOptMin,'g--o','linewidth',2);
    