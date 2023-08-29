# QuickVid
An interactive MATLAB app for preprocessing videos using FFMPEG

QuickVid is a wrapper application for FFMPEG, a powerful open-source video and audio processing tool. 
FFMPEG is incredibly useful, but has a notoriously steep learning curve. This app allows the user to set various parameters interactively and then generates an FFMPEG command which is called from within MATLAB. It is designed for simple preprocessing of grayscale videos.

Requirements:
MATLAB 2021a or newer
FFMPEG 2021-04-09 or newer (not tested on all newer versions of FFMPEG)
QuickVid has so far only been tested on Windows 10.
Currently supports processing of mp4, avi, and mkv files. All outputs are formatted to mp4. 

Installation: 
After setting up FFMPEG, download all files in this repository and add them to your MATLAB path.

Getting Started:
Start QuickVid.app by typing QuickVid in the command line 
OR
Right-click QuickVid.mlapp in the file explorer and select "Run"

Once the app is running, click "Load Video" in the upper left corner. Use the file navigator to select a video file. 
The video will load and the first frame of the video will be drawn to the rightmost axis.
You can now use the various GUI elements to modify the video:

ROI:
Modify video size by cropping or split a video into two halves. 
The options are:
- None: The video will not be cropped, output video will have the same size as the input video. Clicking this will delete any extant ROI.
- Crop: Selecting Crop will draw a rectangular ROI onto the video frame. Anything outside of this ROI will be cropped from the final video. Drag the edges of the ROI to specify the area to crop.
- Vertical Split: This draws a vertical line ROI onto the video frame. The video will be split along this line, resulting in two output videos. These videos will have "left" and "right" appended to their names. Drag the ROI left and right to specify where to split.
- Horizontal Split: This draws a horizontal line ROI onto the video frame. The video will be split along this line, resulting in two output videos. These videos will have "top" and  "bottom" appended to their name. Drag the ROI up and down to specify where to split.

--- Cropping and rotation ---
Rotation:
Rotate the video in increments of 90 degrees clockwise. Note that selecting this will delete any cropping ROIs.

Navigate: 
Step through the video frame-by-frame, or specify a frame to jump to. 
Navigation does not impact the output video and is for testing parameters only. 

--- Frame Processing, Light/Dark Balance, and Trimming ---
Trim Frames:
Exclude the specified number of frames from the beginning of the video

Playback:
Modify the playback speed. 1=same frame rate as input video. 2= twice as fast as the input video. 0.5= half the speed of the input video, and so on.

Gaussian Blur:
Apply a Gaussian blur with a specified standard deviation in pixels. A Gaussian blur can help smooth out noise in the video which might otherwise impede analysis algorithms. Adding a Gaussian blur can dramatically increase processing time, however.

Negate:
Inverts the grayscale image

Adjust Contrast:
Drag the sliders to modify the upper and lower cutoffs for brightness. The video will be scaled such that any value below "min" will be pure black and any value above "max" will be pure white. 

Image Histogram:
Displays a histogram of the pixel values in the currently displayed frame. Use this to decide how to set the minimum and maximum cutoff sliders.

--- Exporting ---
Process Sample: 
Runs a snippet of the video through FFMPEG using the current parameters. The length of the snippet is determined by the "Duration" wheel, in seconds. This is useful for testing parameters before running the entire video, as processing videos can take a long time. 

Process Video:
Runs the entire video through FFMPEG with the current parameters.

Compression: 
Defines how much to compress the video, using the MPEG4 codec. The default value 1 is the lowest possible compression. The maximum is 32, which results in the smallest file size and the lowest quality.

Split Video:
Allows you to split a longer video into several shorter videos of equal length. For example, processing a 1-hour long video with Split Video set to 3 will result in 3 20-minute long videos. When possible, this will use parallel processing (through a parfor loop), which can be faster than running the entire video at once. 

Output Path:
Specify where to save the resulting video(s). Defaults to the same path as the original video.

Fix File Names:
Renames files by replacing hyphens and whitespace with underscores. This can make file names more compatible with various analysis algorithms/programs. 







