%% Clear workspace
clc; clearvars; close all;

%% Data That can be downladed from neptus that are relevant
% AbsoluteWind,Depth,DesiredHeading,DesiredPath,DesiredSpeed,DesiredZ,GpsFix,RelativeWind,RemoteSensorInfo,EstimatedState,EulerAngles
% GpsFix,RelativeWind,EulerAngles



% Data to be saved for plots
cog_data = [];
sog_data = [];
wind_data = [];
waveDir_data = [];
ForecastWaveSize_data = [];
messuredRelWindDir_data = [];
messuredRelWindSpeed_data = [];
psi_data = [];
ForecastWindDir_data = [];
relWaveDir_data = [];
relWindDir_data = [];
relWaveDirToCog_data = [];
relWindDirToCog_data = [];
ForecastWaveFreq_data = [];
ForcastWindSpeed_data = [];
NorthCurrent_data = [];
EastCurrent_data = [];
CurrentDir_data = [];
CurrentSpeed_data = [];


avrager = 1*60; % average over x min
for i = 1: 5
    %% load data
    if i == 1
        path = './Trondheim082546/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-2-20_2020-2-20.mat')
        load('currentweatherData_2020-2-20_2020-2-20.mat')
        disp('Done loading data')
    end
    if i == 2
        path = './Trondheim111728/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        disp('Done loading data')
    end
    if i == 3
        path = './Trondheum094058/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        disp('Done loading data')
    end
    if i == 4
        path = './Trondheum101916/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        disp('Done loading data')
    end
    if i == 5
        path = './Nordfjord082813/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-5-28_2020-5-28.mat')
        load('currentweatherData_2020-5-28_2020-5-29.mat')
        disp('Done loading data')
    end
    
    %% Format and interpolations
    gps_data = gpsFix.GpsFix;
    windData = RelativeWind.RelativeWind;
    EulerAngles = EulerAngles.EulerAngles;
    EulerAngles.psi = ssa(EulerAngles.psi,'deg');
    messuredRelWindDir = interp1(windData.timestamp, ssa(windData.angle,'deg' ),gps_data.timestamp);
    messuredRelWindSpeed = interp1(windData.timestamp, windData.speed,gps_data.timestamp);
    [latSize,longSize] = size(latitudeMapWave);
    [curlatSize,curlongSize] = size(latitudeCurrentMap);
    first = true;
    x = 0;
    y = 0;
    disp('Done formating')
    disp('Start running through data')
    %% run
    for m = (2*avrager) : length(gps_data.sog) - (2*avrager)
        if ~mod(gps_data.utc_time(m),avrager)
            curr_hour = floor(double(gps_data.utc_time(m))/3600) ...
                + 24*(double(gps_data.utc_day(m)-gps_data.utc_day(1)));

            lat = mean(rad2deg(gps_data.lat(m-avrager:m+avrager)));
            lon = mean(rad2deg(gps_data.lon(m-avrager:m+avrager)));

            % Find closest
            error_map = sqrt((latitudeMapWave - lat).^2 + (longitudeMapWave - lon).^2);
            [x,y] = find(error_map == min(error_map, [], 'all'));
            
            error_map = sqrt((latitudeCurrentMap - lat).^2 + (longitudeCurrentMap - lon).^2);
            [xcurrent,ycurrent] = find(error_map == min(error_map, [], 'all'));

            cog = rad2deg(mean(gps_data.cog(m-avrager:m+avrager)));
            psi = rad2deg(mean(EulerAngles.psi(m-avrager:m+avrager)));
            sog = mean(gps_data.sog(m-avrager:m+avrager));
            curWaveDir = ssa(waveDir(x,y,curr_hour+1),'deg');
            curWindDir = ssa(windDir(x,y,curr_hour+1),'deg');
            
            curNorthCur = currentNorth(xcurrent,ycurrent,curr_hour+1);
            curEastCur = currentEast(xcurrent,ycurrent,curr_hour+1);
            a = [1 ;0];
            b = [curNorthCur;curEastCur];
            curdir = sign(b(2))*rad2deg(acos(dot(a,b)/(norm(a)*norm(b))));
            curSpeed = norm(b);
            
            
            ForcastWindSpeed = windSpeed(x,y,curr_hour + 1);
            curMessuredRelWindDir = mean(messuredRelWindDir(m-avrager:m+avrager));
            curMessuredRelWindSpeed = mean(messuredRelWindSpeed(m-avrager:m+avrager));
            if waveSize(x, y, curr_hour + 1) < 0.001
                ForecastWaveSize_data = cat(1, ForecastWaveSize_data, ForecastWaveSize_data(end));
            else
                ForecastWaveSize_data = cat(1, ForecastWaveSize_data, waveSize(x, y, curr_hour + 1));
            end
            
            ForecastWaveFreq_data = cat(1,ForecastWaveFreq_data, waveHZ(x,y,curr_hour+1));

            % Save current data
            cog_data = cat(1, cog_data,cog);
            psi_data = cat(1, psi_data,psi);
            sog_data = cat(1, sog_data,sog);
            waveDir_data = cat(1, waveDir_data, ssa(psi+curWaveDir, 'deg'));
            NorthCurrent_data = cat(1, NorthCurrent_data, curNorthCur);
            EastCurrent_data = cat(1, EastCurrent_data, curEastCur);
            relWaveDir_data = cat(1, relWaveDir_data, ssa(ssa(curWaveDir + 180,'deg') - psi , 'deg'));
            relWindDir_data = cat(1, relWindDir_data, ssa(ssa(curWindDir + 180,'deg') - psi , 'deg'));
            relWaveDirToCog_data = cat(1, relWaveDirToCog_data, ssa(ssa(curWaveDir + 180,'deg') - cog , 'deg'));
            relWindDirToCog_data = cat(1, relWindDirToCog_data, ssa(ssa(curWindDir + 180,'deg') - cog , 'deg'));
            ForecastWindDir_data = cat(1, ForecastWindDir_data, curWindDir);
            messuredRelWindDir_data = cat(1, messuredRelWindDir_data, curMessuredRelWindDir);
            messuredRelWindSpeed_data = cat(1, messuredRelWindSpeed_data, curMessuredRelWindSpeed);
            ForcastWindSpeed_data = cat(1, ForcastWindSpeed_data, ForcastWindSpeed);
            CurrentDir_data = cat(1, CurrentDir_data, ssa(ssa(curdir + 180,'deg') - cog , 'deg'));
            CurrentSpeed_data = cat(1, CurrentSpeed_data, curSpeed);
            
            if ~mod(gps_data.utc_time(m),3600) || first
                str = sprintf('| Day: %d  | Hour: %d \t|', ...
                    (floor(curr_hour/24)+1) + gps_data.utc_day(1)-1, (mod(curr_hour,24)));
                disp(str)
                first = false;
            end
        end

    end
    disp('Run Success')
end
%%
CorrData = [sog_data, relWaveDir_data relWindDir_data  ForcastWindSpeed_data ...
    CurrentDir_data CurrentSpeed_data ForecastWaveFreq_data ForecastWaveSize_data];
corrCoefs = corrcoef(CorrData, 'Rows','pairwise');
    
nninputs = [ForecastWaveSize_data relWaveDir_data relWindDir_data ...
    ForcastWindSpeed_data ForecastWaveFreq_data];
%%
disp('Plotting Data')
figure(1)
%scatter3(relWaveDir_data,ForecastWaveSize_data,sog_data)
for i = 1:length(relWaveDir_data)
    if (ForecastWaveFreq_data(i) < 6)
        scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'b')
    elseif (ForecastWaveFreq_data(i) < 7)
        scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'r')
    elseif (ForecastWaveFreq_data(i) < 8)
        scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'g')
    else
        scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'k')
    end
    hold on
end
xlabel 'Relative wave direction',ylabel 'Wave Size',zlabel 'SOG';
hold off
figure(4)
scatter3(relWaveDir_data,ForecastWaveFreq_data,sog_data)
xlabel 'Relative wave direction',ylabel 'Wave period',zlabel 'SOG';
figure(2)
scatter3(relWaveDir_data,relWindDir_data, sog_data)
xlabel 'Relative wave direction',ylabel 'Relative Wind Angle',zlabel 'SOG';
figure(3)
scatter3(messuredRelWindSpeed_data,messuredRelWindDir_data, sog_data)
xlabel 'Wind Speed',ylabel 'Relative Wind Angle',zlabel 'SOG';
figure(5)
scatter3(ForecastWaveSize_data,ForecastWaveFreq_data, sog_data)
xlabel 'Wave Size',ylabel 'Wave period',zlabel 'SOG';
figure(6)
scatter3(CurrentDir_data,CurrentSpeed_data, sog_data)
xlabel 'curDir',ylabel 'CurSpeed',zlabel 'SOG';
figure(7)
heatmap(corrCoefs)
disp('Done')
