function [toResample] = checkInSAR(gCentFile)

run(gCentFile);

numFiles        = length(insarDataFiles);
toResample      = [];

%% modified on 4 December 2022 to include ALOS data reading
if sensorName == "SENTINEL"

    for k=1:numFiles
        filename    = insarDataFiles{k};
        topsTest    = strfind(filename,'merged');
        tokens      = strsplit(filename,'/');
        if(isempty(topsTest))
            datePair     = tokens{end};
            path         = tokens{end-1};
        else
            datePair     = tokens{end-1};
            path         = tokens{end-2};
        end

        checkName       = [datePair '_' path '.mat'];

        if isfile([WORKDIR '/RESAMP/' checkName]);
            disp([WORKDIR '/RESAMP/' checkName ' exists, skipping']);
            pause(2);
        else
            disp([WORKDIR '/RESAMP/' checkName ' missing,...']);
            display(['Resampling ' filename '/' unwFileName]);
            pause(2);
            toResample = [toResample {filename}];
        end
    end

elseif sensorName == "ALOS"

    for k=1:numFiles
        filename    = insarDataFiles{k};
        topsTest    = strfind(filename,'insar');
        tokens      = strsplit(filename,'/');
        if(isempty(topsTest))
            datePair     = tokens{end};
            path         = tokens{end-1};
        else
            datePair     = tokens{end-1};
            path         = tokens{end-2};
        end

        checkName       = [datePair '_' path '.mat'];

        if isfile([WORKDIR '/RESAMP/' checkName]);
            disp([WORKDIR '/RESAMP/' checkName ' exists, skipping']);
            pause(2);
        else
            disp([WORKDIR '/RESAMP/' checkName ' missing,...']);
            display(['Resampling ' filename '/' unwFileName]);
            pause(2);
            toResample = [toResample {filename}];
        end
    end

end

end