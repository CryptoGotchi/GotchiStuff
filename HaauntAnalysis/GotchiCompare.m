% This MATLAB script models BRS values for H1 and H2 values
% in order to determine if there is a systematic difference
% that would cause one of the Haaunts to have have a higher
% likelyhood of creating high BRS Gotchis.

% With numIterations = 10000, this script takes ~4h on a 2.5 GHz thead.
% For a quick check, 1000 iterations might be enough.

%% Parameters
%clear all;
numIterations = 10000;
numGotchis = 10000;
numGotchisInPortal = 10;
numTraits = 6;
numTop = 10;

%% H1-like

% Collaterals
collTraitArr=[1 2 3 4 2 3 3 3 4];
collModsArr=[1 1 1 1 -1 -1 -1 -1 1];

meanTop = zeros(numIterations,1);
top = zeros(numIterations, numTop);
gotchisInPortal = zeros(numGotchisInPortal, 1);
brsVals = zeros(numGotchis,1);
for i = 1:numIterations
   for j = 1:numGotchis
       for k=1:numGotchisInPortal
           brs = 0;
           coll = randi(length(collTraitArr));
           collTrait = collTraitArr(coll);
           for l=1:numTraits
                randomVal = uint8(randi(256)-1); % random number between 0 and 255
                if randomVal > 99
                    randomVal = randomVal / 2;
                    if randomVal > 99
                        randomVal = uint8(randi(100)-1); % random number between 0 and 99
                    end
                end
                randomVal = int16(randomVal);
                if collTrait == l
                    randomVal = randomVal + collModsArr(coll);
                end
                if randomVal < 50
                    brs = brs + 100 - randomVal;
                else
                    brs = brs + randomVal + 1;
                end
           end
           gotchisInPortal(k) = brs;
       end
       % Always choose the highest BRS from a portal
       brsVals(j) = max(gotchisInPortal);
   end
   brsVals = sort(brsVals, 'descend');
   top(i,:)=brsVals(1:numTop);
   meanTop(i) = mean(top(i,:));
end
disp(mean(meanTop))
disp(std(meanTop))
h1top = top;
h1meanTop = meanTop;


%% H2-like
numGotchis = 10000;
%Collaterals
collTraitArr=[1 2 3 2 3 2 4];
collModsArr=[1 1 1 -1 -1 1 1];
meanTop = zeros(numIterations,1);
top = zeros(numIterations, numTop);
gotchisInPortal = zeros(numGotchisInPortal, 1);
brsVals = zeros(numGotchis,1);
for i = 1:numIterations
   for j = 1:numGotchis
       for k=1:numGotchisInPortal
           brs = 0;
           coll = randi(length(collTraitArr));
           collTrait = collTraitArr(coll);
           for l=1:numTraits
                randomVal = uint8(randi(256)-1);
                if randomVal > 99
                    randomVal = randomVal / 2;
                    if randomVal > 99
                        randomVal = uint8(randi(100)-1);
                    end
                end
                randomVal = int16(randomVal);
                if collTrait == l
                    randomVal = randomVal + collModsArr(coll);
                end
                if randomVal < 50
                    brs = brs + 100 - randomVal;
                else
                    brs = brs + randomVal + 1;
                end
           end
           gotchisInPortal(k) = brs;
       end
       brsVals(j) = max(gotchisInPortal);
   end
   brsVals = sort(brsVals, 'descend');
   top(i,:)=brsVals(1:numTop);
   meanTop(i) = mean(top(i,:));
end
disp(mean(meanTop))
disp(std(meanTop))
h2top = top;
h2meanTop = meanTop;


h1top=h1top(:);
h2top=h2top(:);

%% Plots

% Probability distributions
figure()
[yH1,xH1]=hist(h1top, min(h1top):1:min(h1top)+(max(h1top(:))-min(h1top(:))));
[yH2,xH2]=hist(h2top, min(h2top):1:min(h2top)+(max(h2top(:))-min(h2top(:))));
barHandle =  bar(xH1,yH1,'hist');
set(barHandle,'FaceAlpha',0.5,'EdgeColor','none','FaceColor',[170    45    232]./255.0);
hold on;
barHandle =  bar(xH2,yH2,'hist');
set(barHandle,'FaceAlpha',0.5,'EdgeColor','none','FaceColor',[45    232    230]./255.0);
legend('top 10 BRS distribution generated with H1 formula and collaterals', 'top 10 BRS distribution generated with H2 formula and collaterals');
title('Probability distribution of top 10 BRS Gotchis based on trait generation formula')
ylabel('Count')
xlabel('BRS')

% Draw 1 million samples of top 10 H1-like Gotchis and mean them.
topLen = length(h1top);
numSamples = 1000000;
h1Dist = zeros(numSamples,1);
for i=1:numSamples
    h1Index = randi(topLen,numTop,1);
    h1Dist(i) =  mean(h1top(h1Index));
end

% Draw 1 million samples of top 10 H2-like Gotchis and mean them.
topLen = length(h1top);
numSamples = 1000000;
h2Dist = zeros(numSamples,1);
for i=1:numSamples
    h2Index = randi(topLen,numTop,1);
    h2Dist(i) = mean(h2top(h2Index));
end

% Plot means
figure()
[yH1,xH1]=hist(h1Dist+rand(numSamples,1)*0.1-0.05, min(h1Dist):0.1:min(h1Dist)+(max(h1Dist(:))-min(h1Dist(:))));
[yH2,xH2]=hist(h2Dist+rand(numSamples,1)*0.1-0.05, min(h2Dist):0.1:min(h2Dist)+(max(h2Dist(:))-min(h2Dist(:))));

barHandle =  bar(xH1,yH1,'hist');
set(barHandle,'FaceAlpha',0.5,'EdgeColor','none','FaceColor',[170    45    232]./255.0);
% alpha(0.5);
hold on;
barHandle =  bar(xH2,yH2,'hist');
set(barHandle,'FaceAlpha',0.5,'EdgeColor','none','FaceColor',[45    232    230]./255.0);
% alpha(0.5);
legend('Distribution of the mean of the top 10 BRS Gotchis generated with H1 formula and collaterals', 'Distribution of the mean of the top 10 BRS Gotchis generated with H2 formula and collaterals');
title('Probability distribution of the mean of the top 10 BRS Gotchis based on trait generation formula')
ylabel('Count')
xlabel('Mean top 10 BRS')

% Plot probabilities of BRS differences
topLen = length(h1top);
numSamples = 1000000;
h2BiggerH1Dist = zeros(numSamples,1);
for i=1:numSamples
    h1Index = randi(topLen,numTop,1);
    h2Index = randi(topLen,numTop,1);
    h2BiggerH1Dist(i) = mean(h2top(h2Index)) - mean(h1top(h1Index));
end
figure()
hist(h2BiggerH1Dist+rand(numSamples,1)*0.1,length(unique(h2BiggerH1Dist))+1)
hold on;
plot([mean(h2BiggerH1Dist) mean(h2BiggerH1Dist)],[0 1.25*1e4],'r', 'LineWidth', 2)
plot([4.4 4.4],[0 1200],'g', 'LineWidth', 2)
title('Difference in BRS mean of the top 0.1% between H1 and H2 formula')
ylabel('Count')
xlabel('BRS difference (H2 formula - H1 formula [including collaterals])')

%% Tests

% MWU test if h1 and h2 top 10 are from the same distribution
[p,h,stats] = ranksum(h1top(:),h2top(:))
disp(['H1 mode: ', num2str(mode(h1top(:)))])
disp(['H2 mode: ', num2str(mode(h2top(:)))])
disp(['H1 median: ', num2str(median(h1top(:)))])
disp(['H2 median: ', num2str(median(h2top(:)))])
disp(['H1 mean: ', num2str(mean(h1top(:)))])
disp(['H2 mean: ', num2str(mean(h2top(:)))])

% KS is like MWU but in this case I would stick with MWU
% [p,stats] = kstest2(h1top(:),h2top(:))


% Likelyhood of seeing a 4.4 BRS difference of either direction:
(sum(h2BiggerH1Dist >= 4.4) + sum(h2BiggerH1Dist <= -4.4)) / length(h2BiggerH1Dist)


% Are actual h1 and h2 top 10 values likely from the simulated distribtuion?
% Got the BRS from the subgraph (baseRarityScore).
% However, these seem to include the BRS bonus from XP. One should rather use the original BRS.
h1ActualTop10 = [576, 573, 573, 571, 570, 570, 570, 569, 569, 569];
h2ActualTop10 = [579, 578, 578, 577, 576, 575, 575, 572, 572, 572];
[p,h,stats] = ranksum(h1ActualTop10,h1top(:))
[p,h,stats] = ranksum(h2ActualTop10,h2top(:))


