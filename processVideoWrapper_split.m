function processVideoWrapper_split(appData,outpath,nSplits)
% Run the processVideoWrapper function in a parallel loop to split a video
% into multiple segments.
% Called from videoPreprocessApp.mlapp, which is what the "app" input
% contains.

% Calculate the durations and start times of the resulting videos.
frames_total = floor(appData.VR.FrameRate * appData.VR.Duration);
frames_total = frames_total - appData.TrimFrames;
split_frames = linspace(appData.TrimFrames,...
    frames_total,nSplits+1);
start_frames = round(split_frames(1:end-1)) - 1;
end_frames   = round(split_frames(2:end));
start_frames(start_frames < 0) = 0; % No negative times allowed!
% start_sec = seconds(start_frames / appData.VR.FrameRate);
% start_times = arrayfun(@(x) datestr(x,'HH:MM:SS.FFF'),...
%     start_sec,'UniformOutput',false);
duration_sec = seconds((end_frames - start_frames) / appData.VR.FrameRate);
% Change the duration to account for playback speed
duration_sec = duration_sec / appData.Setpts;
duration_times = arrayfun(@(x) datestr(x,'HH:MM:SS.FFF'),...
    duration_sec,'UniformOutput',false);

parfor i = 1:nSplits
    disp("Processing split video no. " + string(i));
    appDataTemp = appData;
    appDataTemp.TrimFrames = start_frames(i);
    appendStr = ['_',num2str(i)];
    processVideoWrapper(appDataTemp,...
        duration_times{i},...
        outpath,appendStr)
    
    
end
disp('Done splitting videos!');