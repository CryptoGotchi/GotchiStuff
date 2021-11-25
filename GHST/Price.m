clear all;

% Current values:
% https://wiki.aavegotchi.com/en/curve
rr=0.33;
% https://aavegotchi.com/curve
ctp = 3.011;
cts = 73934471.793;

% Formulas:
% https://billyrennekamp.medium.com/converting-between-bancor-and-bonding-curve-price-formulas-9c11309062f5
% https://yos.io/2018/11/10/bonding-curves/
cw = rr;
rtb = cts*ctp*rr;
mc = cts*ctp;
tokenSupply = mc / ctp;
collateral = cw * mc;
n = (1-rr)/rr;
m = collateral / (cw * tokenSupply ^ (1 / cw));

cts = 5:0.1:250;
cts = cts .* 1000000;
p = m.*(cts.^n);
x = cts.*p./1000000000;

% Cap at 5 billion
x = x(x <= 5);
p=p(1:length(x));

% Plot
plot(x,p)
title('GHST Price / Billion MarketCap')
xlabel('MarketCap [Billion USD]')
ylabel('GHST Price [USD]')