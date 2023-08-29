function com = createFFmpegCommand(vidIn,vidOut,varargin)
% processVid_ffmpeg(vidIn,vidOut,'Parameter','value')
% Generates an FFmpeg command as a character array, which can then be run
% through the connamd line with "system(com)"
% This is meant to be a user friendly way to process videos with commonly
% used commands
% WORK IN PROGRESS!
% 
% Requires that you have ffmpeg installed and callable with the name
% 'ffmpeg' directly from the command line

p = inputParser;
addRequired(p,'vidIn');
addRequired(p,'vidOut');
addParameter(p,'Quality',[]); % 2 is good for most, higher number = lower quality. Min is 1
addParameter(p,'Rotation',0,@(x) ismember(x,[0,90,180,270])) % Rotate by degrees clockwise in increments of 90
addParameter(p,'Reflect','none',@(x) ismember(x,{'none','horizontal','vertical'})) %Reflect the video along specified axis
addParameter(p,'Negate',false,@(x) isscalar(x) && islogical(x)); % Invert pixel values
addParameter(p,'Crop',[0 0; 0 0],@(x) isnumeric(x) && isequal(size(x),[2,2])); % Crop - [x0 y0; width,height]
addParameter(p,'Blur',0,@(x) isscalar(x) && isnumeric(x)); % Sigma value for gaussian blur
addParameter(p,'Contrast',1,@(x) isscalar(x) && isnumeric(x)); 
addParameter(p,'Brightness',0,@(x) isscalar(x) && isnumeric(x));
addParameter(p,'SeekTime','00:00:00'); % Time to start the video in hh:mm:ss
addParameter(p,'Duration','00:00:00'); % Total length of output video
addParameter(p,'Codec','default'); % Could be anything, but recommed using MPEG4 for whisker analysis
addParameter(p,'Preset','medium'); % See FFMPEG documentation. Slower presets = higher compression rate while maintaining quality
addParameter(p,'Setpts',1); % Change the speed of the video by multiplying the presentation timestamp (PTS) of each frame
addParameter(p,'PP_min',0); % Adjust contrast and brightness directly by specifying input/output max pixel values
addParameter(p,'PP_max',1);
parse(p,vidIn,vidOut,varargin{:});

% % If we are negating the video, we do so by flipping the PP min and max
% % values
% if p.Results.Negate
%     PP_min = p.Results.PP_max;
%     PP_max = p.Results.PP_min;
% else
%     PP_min = p.Results.PP_min;
%     PP_max = p.Results.PP_max;
% end


% Build command piecewise based on each of the above parameters
% com = ['ffmpeg -y -i "',vidIn,'" -ss ',p.Results.SeekTime];
com = ['ffmpeg -ss ',p.Results.SeekTime,' -y -i "',vidIn,'" '];
com = [com,' -vf "'];
 % Rotation
switch(p.Results.Rotation)
    case 90
        com = [com,'transpose=1,'];
    case 180
        com = [com,'transpose=2,transpose=2,'];
    case 270
        com = [com,'transpose=2,'];
end
% Reflection   
switch p.Results.Reflect
    case 'horizontal'
        com = [com,'hflip,'];
    case 'vertical'
        com = [com,'vflip,'];
end
% Negation
if p.Results.Negate
    com = [com,'negate,'];
end
% If we directly specified the pp min and max points, we ignore the
% brightness and contrast values. 
if ~any(ismember({'PP_min','PP_max'},p.UsingDefaults))
    com = [com,'curves=all=''',...
        num2str(p.Results.PP_min),'/0 ',...
        num2str(p.Results.PP_max),'/1'','];
elseif ~any(ismember('p.Results.Brightness',p.UsingDefaults))
    com = [com,'eq=brightness=',num2str(p.Results.Brightness),...
        ':contrast=',num2str(p.Results.Contrast),','];
end
if p.Results.Blur ~=0
    com = [com,'gblur=sigma=',num2str(p.Results.Blur),','];
end
if p.Results.Setpts ~=1
    com = [com,'setpts=',num2str(p.Results.Setpts),'*PTS,'];
end
% Cropping 
% - For some encoders the aspect ratio of the video needs to be even in
% both dimensions. We enforce that here by making the size of each crop
% values even and round.
if ~ isequal(p.Results.Crop,[0 0; 0 0])
    cropMat = round(p.Results.Crop);
    cropMat = floor(cropMat / 2) * 2;
    com = [com,'crop=',num2str(cropMat(2,1)),':',...
          num2str(cropMat(2,2)),':',...
          num2str(cropMat(1,1)),':',...
          num2str(cropMat(1,2)),','];
end

% Now check if the last character in the filter is a comma. If so,
% remove it to avoid an error
if strcmp(com(end),',')
    com(end) = [];
end

% End of filtering
com = [com,'"'];

% Video Length - 
if ~strcmp(p.Results.Duration,'00:00:00')
    com = [com,' -t ',p.Results.Duration];
end

% % Quality
if ~isempty(p.Results.Quality)
    com = [com,' -q ',num2str(p.Results.Quality)];
else
    com = [com, ' -preset ',p.Results.Preset];
end
% Video codec and output video name
if ~strcmp(p.Results.Codec,'default')
    com = [com,' -vcodec ',p.Results.Codec];
end

com = [com,' "',p.Results.vidOut,'"']; 






