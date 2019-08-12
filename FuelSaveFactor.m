


BeGrad = 0;                                                 % 发动机平均燃油消耗率变化梯度               
deltaEnergyRGB = 0;                                         % 再生制动能量回收变化量
TransEffGrad = 0;                                           % 综合传动效率变化梯度
EnergyRGB = 0;                                              % 再生制动回收能量
FuelSaveRate = (1+BeGrad).*TransEffGrad./(1+TransEffGrad)+(deltaEnergyRGB+BeGrad.*EnergyRGB)./Ewh*IntTransEff(1)-BeGrad;
PartRate1 = TransEffGrad./(1+TransEffGrad);                 % 平均综合传动效率变化产生的节油率
PartRate2 = deltaEnergyRGB/Ewh*IntTransEff(1);              % 再生制动能量回收变化产生的节油率
PartRate3 = -BeGrad;                                        % 发动机效率变化产生的节油率
PartRate4 = BeGrad.*TransEffGrad./(1+TransEffGrad);         % 平均综合传动效率与发动机效率变化耦合项
PartRate5 = BeGrad.*EnergyRGB./Ewh*IntTransEff(1);          % 发动机效率变化产生的节油率与再生制动的耦合项


%% 绘图，直观展示占比大小，后处理
if htswitch==1  % 绘制图1，理论与仿真对比
   plot(RGB_eff*100,xigema_simu*100,'r--','linewidth',2);hold on;
   plot(RGB_eff*100,xigema_lilun*100,'b','linewidth',2);hold on;
   % plot(RGB_eff,xigema_jianhua*100,'b','linewidth',2);hold on;

   % plot(RGB_eff,xigema_jianhua*100,'k','linewidth',2);hold on;
   legend('仿真节油率','理论节油率');
   % legend('仿真节油率','理论节油率','简化节油率');

else  % 绘制图2，简化与仿真对比    
   plot(RGB_eff*100,xigema_simu*100,'r--','linewidth',3);hold on;
   % plot(RGB_eff,xigema_lilun*100,'k','linewidth',2);hold on;
   plot(RGB_eff*100,xigema_jianhua*100,'k','linewidth',2);hold on;
   legend('仿真节油率','简化节油率'); 

end

xlabel('再生制动能量回收率（%）');ylabel('节油贡献率（%）');
% title('P2构型节油率');
set(get(gca,'XLabel'),'FontSize',F_fontsize); % ,'Vertical','top'
set(get(gca,'YLabel'),'FontSize',F_fontsize); % ,'Vertical','middle'
set(get(gca,'title'),'FontSize',F_fontsize);
% set(findobj('FontSize',12),'FontSize',F_fontsize);
set(gca, 'Fontname', 'Times newman', 'Fontsize', 14);
% axis([0.2 0.4 15 37]);

subplot(2,1,2)
if htswitch==1  % 绘制图1，理论与仿真对比
   % plot(RGB_eff,error_xigema,'b','linewidth',2);hold on;
   plot(RGB_eff*100,error_xigema_ini,'b','linewidth',2);hold on;
   % plot(RGB_eff,error_xigema,'r--','linewidth',2);hold on;
   % legend('理论计算误差','简化计算误差');

else  % 绘制图2，简化与仿真对比 
   plot(RGB_eff*100,error_xigema,'b','linewidth',3);hold on;
   % plot(RGB_eff,error_xigema_ini,'b','linewidth',2);hold on;
   % legend('节油率计算误差');
end

xlabel('再生制动能量回收率（%）');ylabel('误差（%）');
set(get(gca,'XLabel'),'FontSize',F_fontsize); % ,'Vertical','top'
set(get(gca,'YLabel'),'FontSize',F_fontsize); % ,'Vertical','middle'
% set(findobj('FontSize',12),'FontSize',F_fontsize);
set(gca, 'Fontname', 'Times newman', 'Fontsize', 14);





