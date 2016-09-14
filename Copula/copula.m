%%
%Eddie Shim
%This program generates a t-copula with Tesla PnL and Toyota PnL, and then simulates a joint distribution from which a 99.97% VaR 
%and Expected Shortfall(defined in document) are calculated. Additionally, a sensitivity test on t-copula parameters rho and nu
%is conducted.
%8/31/2016

%% DATA LOAD
filename_toyota = 'toyota_raw.csv';
filename_tesla = 'tesla_raw.csv';

data_toyota = load(filename_toyota);
data_tesla = load(filename_tesla);
%% DATA PLOTS

to = diff(data_toyota); %toyota pnl
te = diff(data_tesla);  %tesla pnl

%figure
%scatterhist(diff_toyota, diff_tesla);
%hold off

[f,xi] = ksdensity(to);
figure
plot(xi,f);
title('Toyota Returns KDE')
hold off

[f2,xi2] = ksdensity(te);
figure
plot(xi2,f2);
title('Tesla Returns KDE')
hold off


%% FIT T-COPULA TO PNL DATA

u = ksdensity(to,to,'function','cdf');
v = ksdensity(te,te,'function','cdf');

figure
scatterhist(u,v)
xlabel('toyota')
ylabel('tesla')

[rho,nu] = copulafit('t',[u,v],'Method','ApproximateML');


%% GENERATE RANDOM SAMPLE FROM T-COPULA
dof = 6;
N = 10000;
r = copularnd('t',rho,dof,N);
u1 = r(:,1);
v1 = r(:,2);

figure
scatterhist(u1,v1)
xlabel('u')
ylabel('v')
set(get(gca,'children'),'marker','.')
hold off

%% TRANSFORM RANDOM SAMPLE BACK TO ORIGINAL SCALE OF DATA
x1 = ksdensity(to,u1,'function','icdf');
y1 = ksdensity(te,v1,'function','icdf');

figure
scatterhist(x1,y1)
set(get(gca,'children'),'marker','.')
hold off

figure
combined = x1+y1;
plot(ksdensity(combined));
hold off

%% CALCULATE VAR at 99.97%
sorted = sort(combined);
var_cutoff_index = int32(.0003*N);
var_combined = sorted(var_cutoff_index);

%% CALCULATE EXPECTED SHORTFALL (2% TAIL)
T = 0.02 * N;
sum=0;
for i = 1:T
    sum = sum + sorted(i);
end
ES_base = sum/T;


%% SENSITIVITY TEST
rho_array = [0 .4 .99];
nu_array = [4 6 10];

ES_array = [];
percent_dif_array =[];

 for i = 1:length(rho_array)
     for j = 1:length(nu_array)
        dof = nu_array(j);
        rho = rho_array(i);
        N = 10000;
        r = copularnd('t',rho,dof,N);
        u1 = r(:,1);
        v1 = r(:,2);
        x1 = ksdensity(to,u1,'function','icdf');
        y1 = ksdensity(te,v1,'function','icdf');
        combined = x1+y1;
        sorted = sort(combined);
        T = 0.02 * N;
        sum=0;
        for k = 1:T
            sum = sum + sorted(k);
        end
        ES = sum/T;
        percent_dif = (ES_base - ES) / ES_base;
        ES_array = [ES_array ES];
        percent_dif_array = [percent_dif_array percent_dif]; 
   
     end
 end
