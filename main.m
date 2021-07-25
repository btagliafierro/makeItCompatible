clear; fclose all;clc; close
%%% make sure you download the needed archive from my drive

load archiveAll.mat;
data=archiveAll.data;
spectra=archiveAll.spectra;
clear archiveAll
%% I suggest you run this section to skip the loading time
close all
target=elasticSpectrum; %%% you need to download it from the other repository
%%%% parameters for the computation of the reference spectrum

g=9.81;

%%%% you can set several parameters to restrict the ground motion variability
maxDistance=50;     %%% epicentral distance
maxDuration=80;    %%% just if you care about the runtime
%%%% target spectrum

type='Type 1'; %%% or 'Type 2'
soil='B';
damping=0.05;
ag=0.261*g;

%%% set parameters for the EC8 target spectrum

target.damping=damping;
target.ag=ag;
target.soil=soil;
target.type=type;
targetSpectrum=target.pseudoAcc;
targetPeriod=target.time;

% default interval for computing the agreement
intervalComp=find(targetPeriod>0.1 & targetPeriod<4);


folderOut=['set_' soil '_' type ];
[~, ~] = rmdir(folderOut, 's');
mkdir (folderOut)

tolerance=0.23;
mod=1.15;
count=0;
meanSpectrum=zeros(numel(target),1);

for i=1:numel(spectra)
    direction=spectra(i).data.direction;
    dist=spectra(i).data.edicentral_d;
    
    duration=spectra(i).data.duration;
    if ~contains(direction,'Z') && dist<maxDistance && duration<maxDuration %% automatically excludes vertical components
        period=spectra(1).period;
        spectrum=spectra(i).spectrum;
        
        period(isnan(spectrum))=[];
        spectrum(isnan(spectrum))=[];
        
        soilTemp=spectra(i).data.site;
        if ~isempty(spectrum) &&  contains(soilTemp,soil)
            
            spectrum=interp1(period, spectrum,targetPeriod);
            spectrum(1)=spectra(i).spectrum(1);
            
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
                temp=data.Earthquake(i);
                temp.data.Amplification2Comp=k;
%                 save([folderOut 'acc_' num2str(i) '.mat'],'data')
                save([folderOut 'Acc_' num2str(count) '.mat'],'temp')    
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
legend('AutoUpdate','on')
plot(targetPeriod,targetSpectrum/g,'r','Linewidth',2,'DisplayName','target')
plot(targetPeriod,meanSpectrum/g,'b','Linewidth',2,'DisplayName','mean')
plot(targetPeriod,0.9*targetSpectrum/g,'r--','Linewidth',2,'DisplayName','0.9*target')
plot(targetPeriod,1.2*targetSpectrum/g,'r--','Linewidth',2,'DisplayName','1.2*target')
legend()
xlabel('Period [s]','FontSize',7)
ylabel('S_{da} [g]','FontSize',7)
set(gcf,'units','centimeters' ,'position',[1,1,10,6])
disp(['I found ' num2str(count) ' accelerograms'])

axis([0 4 0 inf])
print -dpng /spectra.png

%%% functions
function sse=sseval(k,S1,S2)
  sse=sum((S1-k*S2).^2);
end

