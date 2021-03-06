function [cData] = wfe_get_cald_data(folder_path, data)

try 
    M = data.ChannelCount;
catch
    error('Data not recognized at data structure');
end

if (strcmp(data.WGCalFile, 'none'))
    wg_slopes = ones(1,M);
else
    %wg_cal_file = [folder_path '\Cal_files\WG\' data.WGCalFile];
    wg_cal_file = [folder_path '\' data.WGCalFile];
    % for now ignore intercepts and just subtract the mean
    cal = wfe_load_cal_file(wg_cal_file);
    wg_slopes = cal.Slopes;
end
n = 0;

cData = zeros(size(data.Data));

for m = 1:M
    if (strcmp(data.ChanNames{m}, 'Position'))
        if (strcmp(data.BodySetup, 'At'))
            pos_slope = 0.073; % read directly from cal files
        else
            pos_slope = 0.070;
        end
        cData(:,m) = 1/pos_slope*(data.Data(:,m) - mean(data.Data(:,m)));
    elseif (strcmp(data.ChanNames{m}, 'Force'))
        lc_slope = 0.633;   % read directly from cal files - Volt to N on Load Cell
        cdat = 1/lc_slope*(data.Data(:,m) - mean(data.Data(:,m)));
        if (strcmp(data.BodySetup, 'Fl'))
            arm = 0.625;          % load cell was located appox 0.625 m from hinge
        else
            arm = 0.25;          % load cell was located appox 0.25 m from hinge
        end
        cData(:,m) = arm*cdat;  % Torqe in Nm
    else
        n = n + 1;
        % not using intercept values for now bc produces weird results
        cData(:,m) = 1/wg_slopes(n)*(data.Data(:,m) - mean(data.Data(:,m)));
    end
end