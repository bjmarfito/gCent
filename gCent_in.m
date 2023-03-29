% gCent_in.m
% Input script for driving gCent

%Event parameters
eventID             = 'Afghanistan_20220621';      % An event ID for identifying the event
eventLoc            = [69.464 33.02, 4];       %Lon, lat, depth of the event
eventSDR            = [204 87 -11];                %Event Strike, dip, rake of focal mechanism you wish to test
eventMag            = 6.0;                           %Event magnitude, for scaling dimensions

% Datafiles, split between InSAR, GPS, and optical sensors. 
% Include all data files that you wish to include in the inversion, even if they've already been resampled.
% Give full paths to processed directories
%
% InSAR data files: give path to filt_topophase.unw.geo and los.rdr.geo
% files
%
% Optical data: give full path to EW and NS displacements files
% (displacements in meters)
%
% GPS data: give full path to a .mat file

insarDataFiles      = {'/Volumes/BJM_EOS-RS/Afghanistan_2022/modelling/gcent/Afghanistan_20220621/RESAMP/p30/210308-220627'};
opticalDataFilesEW  = {};
opticalDataFilesNS  = {};
gpsDataFiles        = {''};
gpsTimeSeriesDir = {};


WORKDIR             = ['/Volumes/BJM_EOS-RS/Afghanistan_2022/modelling/gcent/' eventID];

%Elevation of water in dem.crop file. Used to crop out water areas. To skip
%water masking, set waterElev = [];
corThresh           = 0.6;
waterElev           = [-30]; %Leave this empty if there's no water to mask
