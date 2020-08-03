function resampInSARgCent(gCentFile);

run(gCentFile);
resampDir       = [WORKDIR '/RESAMP'];
resampInFile    = [resampDir '/resamp_in.m']

run(resampInFile);


datastruct = loadData(processor,datafilename,zone,limitny,azo,const_los,losfilename,nx,ny); 
 if exist(corrfilename)
%     corStruct   = loadData(processor,corrfilename,zone,[],[],[],[]);
    corStruct = loadISCE(corrfilename,zone,limitny,azo,0);
    cor         = corStruct.data;
    data        = datastruct.data;
    corId       = find(cor<=corThresh);
    data(corId)    = NaN;
    
    corId       = find(isnan(cor));
    data(corId)    = NaN;
%     id = find(data<-0.2 | data>0.2);
%     data(id)=NaN;
    datastruct.data = data;
 end
   
if(isempty(cropX)~=1)
    datastruct = cropDatastruct(datastruct,cropX,cropY);
end

if(waterElev)
    datastruct = cropWater(datastruct,waterElev,resampInFile);
end

% datastruct  = heightscale(datastruct,demfilename);
datastruct.hgt  = [];

%%% Do a water mask
%[lon,lat] = my_utm2ll([datastruct.X],[datastruct.Y],1,[datastruct.zone]);
%mask      = landmask(lat,lon);




%load fault
faultstruct=[];
load(faultfilename);
% for i=1:length(faultfilename)
%     tmp                      = load(faultfilename{i});
%     faultstruct              = [faultstruct tmp.faultstruct];
% end
% [patchstruct,totLp,Wp]   = ver2patchconnect(faultstruct,Lp,Wp,length(faultstruct));
patchstruct = [];
for i=1:length(faultstruct)
    p = ver2patchconnect(faultstruct(i),Lp,Wp,1);
    patchstruct = [patchstruct p];
end

totalLp                 = i*Lp;
xfault                   = [[patchstruct.xfault]']';
yfault                   = [[patchstruct.yfault]']';
zfault                   = [[patchstruct.zfault]']';
id                       = find(zfault(1,:)==min(zfault(1,:)));
xfaultsurf               = xfault(:,id);
yfaultsurf               = yfault(:,id);

disp('Beginning resampling')
[resampstruct,res,rhgt] = resampler_tri(datastruct,patchstruct,faultstruct, resampInFile);
Var                = var(res(isfinite(res)));
datastd            = Var./sqrt([resampstruct.count]);

disp('Calculating data covariance')
covstruct=struct('cov',[],'Var',Var,'tx',[],'ty',[],'Vxy',[],'allnxy',[],'els',[]);
covstruct2=covstruct;
close all

if(azo)
    disp('just using Var of non-NaN points - Azimuth offsets should have no spatial correlation');
    getcov=1;
end
switch getcov
    case 1
        covstruct.cov = diag(datastd);
    case 2
        plotflag    = 1;
        covstruct   = get_cov_quick(covstruct,plotflag,res);
        covstruct2  = covstruct;
        els=covstruct.els;
        a=mean(els(1:2));
        els(1:2)=a;
        covstruct2.els = els;
        disp('Calculating covariance averages for resampled patches')
        covstruct   = resampcov_tri(resampstruct,datastruct,covstruct);
        set(gcf,'name','Includes directional anisotropy in noise');
        covstruct2  = resampcov_tri(resampstruct,datastruct,covstruct2);
        set(gcf,'name','Isotropic noise');
end

% if(demfilename)
%     Varh       = var(rhgt(isfinite(rhgt)));
%     datastdh   = Varh./sqrt([resampstruct.count]);
%     covstructh = struct('cov',[],'Var',Varh,'tx',[],'ty',[],'Vxy',[],'allnxy',[],'els',[]);
%     switch getcov
%         case 1
%             covstructh.cov = diag(datastdh);
%         case 2
%             plotflag    = 1;
%             covstructh  = get_cov_quick(covstructh,plotflag,rhgt);
%             
%             disp('Calculating covariance averages for resampled patches')
%             covstructh  = resampcov_tri(resampstruct,datastruct,covstructh);
%             set(gcf,'name','Anisotropic noise minus elevation fit');
%     end
% end



if(savestructname)
    savestruct = struct('name',[],'data',[],'np',[],'covstruct',[],'zone',[]);
    savestruct.name       = datafilename;
    savestruct.data       = resampstruct;
    savestruct.np         = length(resampstruct);
    savestruct.covstruct  = covstruct;
    savestruct.covstruct2 = covstruct2;
    savestruct.zone       = zone;
   
%     if(demfilename)
%         savestruct.covstructh = covstructh;
%     end
    save(savestructname,'savestruct');
    disp('Saved data structure')

end
close all
