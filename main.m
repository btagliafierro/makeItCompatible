clear; fclose all;clc; close
%%% make sure you download the needed archive from my drive

load archiveSpectra.mat;
archive=load ('archive.mat');
target=elasticSpectrum; %%% you need to download it from the other repository
%%%% parameters for the computation of the reference spectrum

g=9.81;
%%%% target spectrum

type='horizontal';
site='B';
mod=1.15;
count=0;
damping=0.05;
ag=0.261*g

target.damping=damping;
target.ag=ag;


targetSpectrum=target.pseudoAcc;
targetPeriod=target.time;
meanSpectrum=zeros(numel(target),1);

intervalComp=find(targetPeriod>0.1 & targetPeriod<4);



folderOut=['typeB/'];
[~, ~] = rmdir(folderOut, 's');
mkdir (folderOut)

tolerance=0.23;

for i=1:numel(Earthquake)
    direction=Earthquake(i).data.direction;
    dist=Earthquake(i).data.edicentral_d;
    duration=Earthquake(i).data.duration;
    if ~contains(direction,'Z') && dist<maxDistance && duration<maxDuration %% automatically excludes vertical components
        period=Earthquake(1).period;
        spectrum=Earthquake(i).spectrum;
        
        period(isnan(spectrum))=[];
        spectrum(isnan(spectrum))=[];
        
        soil=Earthquake(i).data.site;
        if ~isempty(spectrum) &&  contains(soil,site)
            
            spectrum=interp1(period, spectrum,targetPeriod);
            spectrum(1)=Earthquake(i).spectrum(1);
            
            fun = @(x) sseval(x,targetSpectrum(intervalComp)*mod,spectrum(intervalComp));
            
            k=fminsearch(fun,1);
            
            goodness=sqrt(sseval(k,targetSpectrum(intervalComp)*mod,spectrum(intervalComp)))/norm(targetSpectrum(intervalComp),2);
            
            if goodness<tolerance
                count=count+1;
                meanSpectrum=meanSpectrum+k*spectrum;
               figure(1); hold on
                plot(targetPeriod,k*spectrum/g)
                drawnow

                %%%% make folder with file you like
                data=archive.Earthquake(i);
                data.data.Amplification2Comp=k;
%                 save([folderOut 'acc_' num2str(i) '.mat'],'data')
                save([folderOut 'Acc_' num2str(count) '.mat'],'data')    
                figure(2); hold on
                acceleration=data.acceleration;
                time=0:0.005:numel(acceleration)*0.005-0.005;
                plot(time,acceleration)
            end
        end
    end
end

meanSpectrum=meanSpectrum/count;

Earthquake=rmfield(Earthquake,'period');

figure(1);
plot(targetPeriod,targetSpectrum/g,'r','Linewidth',2)
plot(targetPeriod,meanSpectrum/g,'b','Linewidth',2)
plot(targetPeriod,0.9*targetSpectrum/g,'r--','Linewidth',2)
plot(targetPeriod,1.2*targetSpectrum/g,'r--','Linewidth',2)


disp(['I found ' num2str(count) ' accelerograms'])

axis([0 4 0 inf])
function sse=sseval(k,S1,S2)
  sse=sum((S1-k*S2).^2);
end
