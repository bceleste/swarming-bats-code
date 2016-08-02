function [totSamp,fs,fname,fDir]=loadFiles()

% specify the current working directory

if ~exist('cwd','var') %Checks if a variable named "cwd" does not exist
    cwd = uigetdir('.','Select a folder to process data'); %Prompts user to select a directory; this directory is saved as the string "cwd"
    %if no file is selected, fills function outputs with 0s and end function
    if cwd==0;
        data=0;
        fs=0;
        fname=0;
        return;
    end
end

%Locate all wav files in directory

files1 = findfiles('wav',cwd);  %This makes an array of the names of all files with the extension '.wav'
files2=findfiles('WAV',cwd);
files=[files1 files2];
%Initialize cells
data=cell(1,numel(files)); %These need to be cells to work in the dialogue box
fname=cell(1,numel(files));

%Create dialogue box to select file
[sel,ok]=listdlg('ListString',files,'SelectionMode','single','Name','Please select a file','listSize',[450 150]);
if ~ok
    data=0; %like above, fills outputs and cancels if user picks cancel
    fs=0;
    fname=0;
    return;
else
    data=audioinfo(files{sel});
    totSamp=data.TotalSamples;
    fs=data.SampleRate;
    fname=data.Title;
    fDir=files{sel};
end
