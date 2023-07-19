function datastruct = cropWater(datastruct,waterElev,resampInFile)

run(resampInFile);

if processor == "ISCE"
    dem     = loadISCE(demfilename);
elseif processor == "ISCEMINTPY"
    demfilename
    dem     = loadMINTPYISCE(demfilename);
end
% id      = find([dem.data]<=waterElev);
data    = [datastruct.data];
demMask = ones(size(data));
demMask([dem.data]<=waterElev|isnan([dem.data]))=NaN;
data = data.*demMask;
datastruct.data = data;
end
