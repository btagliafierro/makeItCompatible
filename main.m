clear; fclose all;clc; close
%%% make sure you download the needed archive from my drive

dataSpectrum=load ('archiveSpectra_D003.mat');
dataAccelerogram=load("archive.mat","Earthquake");
data=dataSpectrum.Earthquake.data;
spectrumData=dataSpectrum.Earthquake;
clear dataSpectrum
%% I suggest you run this section to skip the loading time
close all


g=9.81;

%%%% you can set several parameters to restrict the ground motion variability
maxDistance=50;     %%% epicentral distance
maxDuration=80;    %%% just if you care about the runtime
%%%% target spectrum

type='Type_1'; %%% or 'Type_1'
soil='B';
target=elasticSpectrum(type,soil); %%% you need to download it from the other repository
%%% https://github.com/btagliafierro/EC8Spectra/blob/master/elasticSpectrum.m
%%%% parameters for the computation of the reference spectrum


damping=0.03;
ag=0.25*g;

%%% set parameters for the EC8 target spectrum

target.damping=damping;
target.ag=ag;
targetSpectrum=target.pseudoAcc;
targetPeriod=target.time;

% default interval for computing the agreement
intervalComp=find(targetPeriod>0.10 & targetPeriod<4.0);


folderOut=['set_' soil '_type_' type '_damping_' num2str(damping) ];
[~, ~] = rmdir(folderOut, 's');
mkdir (folderOut)

tolerance=0.2;
mod=1.10; %%% it can be useful to adjust the mean value on the plateaux
count=0;
meanSpectrum=0; %% matlab will cast this as soon as we perform the first operation.

for i=1:numel(dataAccelerogram.Earthquake)
    direction=spectrumData(i).data.direction;
    dist=spectrumData(i).data.edicentral_d;
    
    duration=spectrumData(i).data.duration;
    if ~contains(direction,'Z') && dist<maxDistance && duration<maxDuration %% automatically excludes vertical components
        period=spectrumData(1).period;
        spectrum=spectrumData(i).spectrum;
        
        period(isnan(spectrum))=[];
        spectrum(isnan(spectrum))=[];
        
        soilTemp=spectrumData(i).data.site;
        if ~isempty(spectrum) &&  contains(soilTemp,soil)
            
            spectrum=interp1(period, spectrum,targetPeriod);
            spectrum(1)=spectrumData(i).spectrum(1);
            
            fun = @(x) sseval(x,targetSpectrum(intervalComp)*mod,spectrum(intervalComp));
            
            k=fminsearch(fun,1);
            
            goodness=sqrt(sseval(k,targetSpectrum(intervalComp)*mod,spectrum(intervalComp)))/norm(targetSpectrum(intervalComp),2);
            
            if goodness<tolerance
                count=count+1;
                meanSpectrum=meanSpectrum+k*spectrum;
                figure(1); hold on; box on
                legend('AutoUpdate','off')
                plot(targetPeriod,k*spectrum/g,'Color',[1 1 1]*0.8)
                
                drawnow

                %%%% make folder with file you like
                temp=dataAccelerogram.Earthquake(i);
                temp.dataAccelerogram.Amplification2Comp=k;
%                 save([folderOut '/acc_' num2str(i) '.mat'],'data')
                save([folderOut '/Acc_' num2str(count) '.mat'],'temp')    
                figure(2); hold on; box on
                acceleration=temp.acceleration;
                time=0:0.005:numel(acceleration)*0.005-0.005;
                plot(time,acceleration/g)
            end
        end
    end
end

meanSpectrum=meanSpectrum/count;

figure(1);
leg=legend('AutoUpdate','on');
plot(targetPeriod,targetSpectrum/g,'r','Linewidth',2,'DisplayName','target')
plot(targetPeriod,meanSpectrum/g,'b','Linewidth',2,'DisplayName','mean')
plot(targetPeriod,0.9*targetSpectrum/g,'r--','Linewidth',2,'DisplayName','0.9*target')
plot(targetPeriod,1.2*targetSpectrum/g,'r--','Linewidth',2,'DisplayName','1.2*target')
leg.FontSize=8;
xlabel('Period [s]','FontSize',7)
ylabel('S_{da} [g]','FontSize',7)
set(gcf,'units','centimeters' ,'position',[1,1,10,6])
ax=gca;
ax.FontSize=8;

disp(['I found ' num2str(count) ' accelerograms'])

axis([0 4 0 inf])
print -dpng spectra.png

%%% functions
function sse=sseval(k,S1,S2)
  sse=sum((S1-k*S2).^2);
end
