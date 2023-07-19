% Make and Save NA Plots


zone            = [savestruct.zone];
[blon,blat]     = my_utm2ll(boxx,boxy,1,zone);
[lon,lat]       = my_utm2ll(X,Y,1,zone);


%% Plot and Save Data, Synthetics, and Residuals
if Mw < 6
    rad = 10e3;%default is 25km
elseif Mw>=6&Mw<7
    rad = 100e3;
elseif Mw>=7
    rad = 500e3;
end

xc              = [out.x0]+rad*cos([0:.1:2*pi]);
yc              = [out.y0]+rad*sin([0:.1:2*pi]);

for k=1:length(allnp)
    tmp             = sum(allnp(1:k));
    tmp2            = tmp-allnp(k)+1;
    X1              = X(tmp2:tmp);
    Y1              = Y(tmp2:tmp);
    blon1           = blon(:,tmp2:tmp);
    blat1           = blat(:,tmp2:tmp);
    idIn            = find(inpolygon(X1,Y1,xc,yc));
    data1           = data(tmp2:tmp);
    synth1          = synth(tmp2:tmp);
    minn = -10;
    maxx = 10;
    
    tokens      = strsplit(datafiles{k},'/');
    token       = strsplit(tokens{end},'.');
    filename    = token{1};
    token       = strsplit(filename,'_');
    filename    = [token{1} '-' token{2}];
    h = figure(1);

    % calculate rms
    rmss = rms((data1(idIn)'-synth1(idIn))*100);
    fid = fopen([NADIR '/run_' num2str(pid) '/rms.txt'],'w');
    fprintf(fid,'%.5f\n',rmss);
    fclose(fid);
    
    subplot(1,3,1)
    patch(blon1(:,idIn),blat1(:,idIn),data1(idIn)*100);
    axis image
    shading flat
    %colormap jet
    crameri('vik')
    c=colorbar('southoutside');
    c.Label.String = 'dLOS (cm)';
    caxis([minn,maxx]);
    title('Displacements')
    %save for checking
    fid1 = fopen([NADIR '/run_' num2str(pid) '/datalos.txt'],'w');
    fid2 = fopen([NADIR '/run_' num2str(pid) '/lonlos.txt'],'w');
    fid3 = fopen([NADIR '/run_' num2str(pid) '/latlos.txt'],'w');
    fprintf(fid1,'%.5f\n',data1(idIn)*100);
    fprintf(fid2,'%.5f\n',lon(idIn));
    fprintf(fid3,'%.5f\n',lat(idIn));
    fclose(fid1);fclose(fid2);fclose(fid3);
    
    subplot(1,3,2)
    patch(blon1(:,idIn),blat1(:,idIn),synth1(idIn)*100);
    axis image
    shading flat
    %colormap jet
    crameri('vik')
    c=colorbar('southoutside');
    c.Label.String = 'dLOS (cm)';
    caxis([minn,maxx]);
    title('Predicted')
    %save for checking
    fid1 = fopen([NADIR '/run_' num2str(pid) '/syntlos.txt'],'w');
    fprintf(fid1,'%.5f\n',synth1(idIn)*100);
    fclose(fid1);
    
    subplot(1,3,3)
    patch(blon1(:,idIn),blat1(:,idIn),(data1(idIn)'-synth1(idIn))*100);
    axis image
    shading flat
    %colormap jet
    crameri('vik')
    c=colorbar('southoutside');
    c.Label.String = 'dLOS (cm)';
    caxis([minn,maxx]);
    title('Residual')
    %save for checking
    fid1 = fopen([NADIR '/run_' num2str(pid) '/residlos.txt'],'w');
    fprintf(fid1,'%.5f\n',(data1(idIn)'-synth1(idIn))*100);
    fclose(fid1);
    
    suptitle(filename)
    
    saveas(h,[NADIR '/run_' num2str(pid) '/' filename '.png']);
    saveas(h,[NADIR '/run_' num2str(pid) '/' filename '.pdf']);
    close(h)
end


%% Plot and Save NA Output scatter plots
[naPlotH] = plot_na(models,misfit,Npatch,xytype);
saveas(naPlotH,[NADIR '/run_' num2str(pid) '/NA_results.png']);
close(naPlotH);


%% Plot and Save the Slip Distribution
xref = mean([out.xfault(1:4)]);
yref = mean([out.yfault(1:4)]);

fboxx = ([out.xfault]-xref)/1e3;
fboxy = ([out.yfault]-yref)/1e3;

h = figure(1);
patch(fboxx,fboxy,[out.zfault]/1e3,slip(1));
set(gca,'zdir','reverse');

axis image
view(90-out(1).strike,70-out(1).dip)
a=axis;
axis([a(1:4) 0 a(end)])
grid on

c=colorbar('southoutside');
c.Label.String = 'Slip (m)';
xlabel('East (km)');
ylabel('North (km)');
zlabel('Depth (km)');

title('Single Patch Slip Model')
saveas(h,[NADIR '/run_' num2str(pid) '/slipModel.png']);
close(h)


