


BeGrad = 0;                                                 % ������ƽ��ȼ�������ʱ仯�ݶ�               
deltaEnergyRGB = 0;                                         % �����ƶ��������ձ仯��
TransEffGrad = 0;                                           % �ۺϴ���Ч�ʱ仯�ݶ�
EnergyRGB = 0;                                              % �����ƶ���������
FuelSaveRate = (1+BeGrad).*TransEffGrad./(1+TransEffGrad)+(deltaEnergyRGB+BeGrad.*EnergyRGB)./Ewh*IntTransEff(1)-BeGrad;
PartRate1 = TransEffGrad./(1+TransEffGrad);                 % ƽ���ۺϴ���Ч�ʱ仯�����Ľ�����
PartRate2 = deltaEnergyRGB/Ewh*IntTransEff(1);              % �����ƶ��������ձ仯�����Ľ�����
PartRate3 = -BeGrad;                                        % ������Ч�ʱ仯�����Ľ�����
PartRate4 = BeGrad.*TransEffGrad./(1+TransEffGrad);         % ƽ���ۺϴ���Ч���뷢����Ч�ʱ仯�����
PartRate5 = BeGrad.*EnergyRGB./Ewh*IntTransEff(1);          % ������Ч�ʱ仯�����Ľ������������ƶ��������


%% ��ͼ��ֱ��չʾռ�ȴ�С������
if htswitch==1  % ����ͼ1�����������Ա�
   plot(RGB_eff*100,xigema_simu*100,'r--','linewidth',2);hold on;
   plot(RGB_eff*100,xigema_lilun*100,'b','linewidth',2);hold on;
   % plot(RGB_eff,xigema_jianhua*100,'b','linewidth',2);hold on;

   % plot(RGB_eff,xigema_jianhua*100,'k','linewidth',2);hold on;
   legend('���������','���۽�����');
   % legend('���������','���۽�����','�򻯽�����');

else  % ����ͼ2���������Ա�    
   plot(RGB_eff*100,xigema_simu*100,'r--','linewidth',3);hold on;
   % plot(RGB_eff,xigema_lilun*100,'k','linewidth',2);hold on;
   plot(RGB_eff*100,xigema_jianhua*100,'k','linewidth',2);hold on;
   legend('���������','�򻯽�����'); 

end

xlabel('�����ƶ����������ʣ�%��');ylabel('���͹����ʣ�%��');
% title('P2���ͽ�����');
set(get(gca,'XLabel'),'FontSize',F_fontsize); % ,'Vertical','top'
set(get(gca,'YLabel'),'FontSize',F_fontsize); % ,'Vertical','middle'
set(get(gca,'title'),'FontSize',F_fontsize);
% set(findobj('FontSize',12),'FontSize',F_fontsize);
set(gca, 'Fontname', 'Times newman', 'Fontsize', 14);
% axis([0.2 0.4 15 37]);

subplot(2,1,2)
if htswitch==1  % ����ͼ1�����������Ա�
   % plot(RGB_eff,error_xigema,'b','linewidth',2);hold on;
   plot(RGB_eff*100,error_xigema_ini,'b','linewidth',2);hold on;
   % plot(RGB_eff,error_xigema,'r--','linewidth',2);hold on;
   % legend('���ۼ������','�򻯼������');

else  % ����ͼ2���������Ա� 
   plot(RGB_eff*100,error_xigema,'b','linewidth',3);hold on;
   % plot(RGB_eff,error_xigema_ini,'b','linewidth',2);hold on;
   % legend('�����ʼ������');
end

xlabel('�����ƶ����������ʣ�%��');ylabel('��%��');
set(get(gca,'XLabel'),'FontSize',F_fontsize); % ,'Vertical','top'
set(get(gca,'YLabel'),'FontSize',F_fontsize); % ,'Vertical','middle'
% set(findobj('FontSize',12),'FontSize',F_fontsize);
set(gca, 'Fontname', 'Times newman', 'Fontsize', 14);





