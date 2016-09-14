%% skew_arima
% Eddie Shim
% 7/5/16

clear

%load data

filename = 'CBOE_SKEW_INDEX_raw.csv';
data = load(filename);

y = log(data);
ydiff = diff(y);
T = length(data);

%Stationarity/Unit Root Tests
[h,pValue1] = adftest(y,'lags',1);
%[h2,pValue2] = kpsstest(ydiff,'lags',1, 'trend', false);
%[h3,pValue3] = lmctest(ydiff,'lags',1,'test','var2', 'trend', false);

%% ACF and PACF plots

figure
autocorr(ydiff)
title('ACF of log SKEW diff')
figure
parcorr(ydiff)
title('PACF of log SKEW diff')
hold off


%% Model Selection, BIC

for p = 1:4
    for q = 1:4
        mod = arima(p,1,q);
        [fit,~,logL] = estimate(mod,y,'print',false);
        LOGL(p,q) = logL;
        PQ(p,q) = p+q;
    end
end

LOGL = reshape (LOGL, 16,1);
PQ = reshape(PQ,16,1);
[~,bic] = aicbic(LOGL,PQ+1,100);
BIC = reshape(bic,4,4);
minBIC = min(BIC(:));
[p,q] = find(BIC == minBIC);    %finds row,column (p,q) of minimum loglikelihood value in matrix



%% create ARIMA model

Mdl = arima('ARLags',p,'D',1,'MALags', q, 'Variance', garch(1,1));
EstMdl = estimate(Mdl,y);

%plot

[yF,yMSE] = forecast(EstMdl,60,'Y0',y);
upper = yF + 1.96*sqrt(yMSE);
lower = yF - 1.96*sqrt(yMSE);

figure
plot(y,'Color',[.75,.75,.75])
hold on
h1 = plot(T+1:T+60,yF,'r','LineWidth',2);
h2 = plot(T+1:T+60,upper,'k--','LineWidth',1.5);
plot(T+1:T+60,lower,'k--','LineWidth',1.5)
xlim([0,T+60])
title('Forecast and 95% Forecast Interval')
legend([h1,h2],'Forecast','95% Interval','Location','NorthWest')
hold off



%% qqplot for ARIMA
% res = infer(EstMdl, y);
% stres = res/sqrt(EstMdl.Variance);
% figure
% plot(res)
% title('Standardized Residuals')
% 
% 
% figure
% subplot(1,2,1)
% qqplot(stres)
% 
% x = -4:.05:4;
% [f,xi] = ksdensity(stres);
% subplot(1,2,2)
% plot(xi,f,'k','LineWidth',2);
% hold on
% plot(x,normpdf(x),'r--','LineWidth',2)
% legend('Residuals','Standard Normal')
% hold off



%% qqplot for ARIMA-GARCH
[res,v,logL] = infer(EstMdl,y);

figure
subplot(2,1,1)
plot(v)
xlim([0,T])
title('Conditional Variance')

subplot(2,1,2)
stres = res./sqrt(v);
plot(res./sqrt(v))
xlim([0,T])
title('Standardized Residuals')
hold off


figure
subplot(1,2,1)
qqplot(stres)

x = -4:.05:4;
[f,xi] = ksdensity(stres);
subplot(1,2,2)
plot(xi,f,'k','LineWidth',2);
hold on
plot(x,normpdf(x),'r--','LineWidth',2)
legend('Residuals','Standard Normal')
hold off

figure
plot(1:T,res+y,':', 1:T,y,'m')

%% Check residuals for autocorrelation
% 
% figure
% subplot(2,1,1)
% autocorr(stres)
% subplot(2,1,2)
% parcorr(stres)
% 
% [h,p] = lbqtest(stres,'lags',[5,10,15],'dof',[3,8,13])

%% 
