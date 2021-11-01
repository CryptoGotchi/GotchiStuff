% Generate Gotchiverse auction heatmaps from subgraph data
% Quick and dirty, please don't judge ^^'
% -CryptoGotchi

clear all;

bidMat = dlmread('bids.txt');
x=bidMat(:,1);
y=bidMat(:,2);
v=bidMat(:,3);
s=bidMat(:,4);
fp(1)=min(v(s==0));
fp(2)=min(v(s==1));
fp(3)=min(v(s==2));
% Convert GHST to 'percent of floor price' (with respect to parcel size)
v(s==0)= v(s==0) / fp(1) * 100;
v(s==1)= v(s==1) / fp(2) * 100;
v(s==2)= v(s==2) / fp(3) * 100;
% Cap data at 500% floor price (for improved color resolution)
v(v > 500) = 500;
% Log transform (again...better color resolution)
v=log(v);
% Fll = scatteredInterpolant(x,y,v,'linear','linear');
% Fln = scatteredInterpolant(x,y,v,'linear','nearest');
Fnn = scatteredInterpolant(x,y,v,'nearest','nearest');
Fan = scatteredInterpolant(x,y,v,'natural','nearest');

x=linspace(1,max(x),max(x));
y=linspace(1,max(y),max(y));
[X,Y]=meshgrid(x,y);
% Vll=Fll(X,Y);
% Vln=Fln(X,Y);
Vnn=Fnn(X,Y);
Van=Fan(X,Y);

gs = (Vnn - min(min(Vnn))) / (max(max(Vnn)) - min(min(Vnn)))*2047+1;
cmap = parula(2048);
cmap1=cmap(:,1);
cmap2=cmap(:,2);
cmap3=cmap(:,3);
im(:,:,1) = cmap1(int16(round(gs)));
im(:,:,2) = cmap2(int16(round(gs)));
im(:,:,3) = cmap3(int16(round(gs)));
imwrite(im, 'Mpnn.png')


gs = (Vnn - min(min(Vnn))) / (max(max(Vnn)) - min(min(Vnn)))*2047+1;
cmap = jet(2048);
cmap1=cmap(:,1);
cmap2=cmap(:,2);
cmap3=cmap(:,3);
im(:,:,1) = cmap1(int16(round(gs)));
im(:,:,2) = cmap2(int16(round(gs)));
im(:,:,3) = cmap3(int16(round(gs)));
imwrite(im, 'Mjnn.png')

gs = (Van - min(min(Van))) / (max(max(Van)) - min(min(Van)))*2047+1;
cmap = parula(2048);
cmap1=cmap(:,1);
cmap2=cmap(:,2);
cmap3=cmap(:,3);
im(:,:,1) = cmap1(int16(round(gs)));
im(:,:,2) = cmap2(int16(round(gs)));
im(:,:,3) = cmap3(int16(round(gs)));
imwrite(im, 'Mpan.png')

gs = (Van - min(min(Van))) / (max(max(Van)) - min(min(Van)))*2047+1;
cmap = jet(2048);
cmap1=cmap(:,1);
cmap2=cmap(:,2);
cmap3=cmap(:,3);
im(:,:,1) = cmap1(int16(round(gs)));
im(:,:,2) = cmap2(int16(round(gs)));
im(:,:,3) = cmap3(int16(round(gs)));
imwrite(im, 'Mjan.png')

