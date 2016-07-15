function drag(object, eventdata, sampRate, hObject, data, dB, fName, handles)
%% configurable parameters

fs = sampRate;             % hardcode sampling rate

% spectrogram options
nOver = 3;              % sliding window increment for TFR
nfft = 512;             % FFT points
wlen = 127;             % window length for STFT; must be odd for TFTB
wind = hanning(wlen);   % window for STFT

% block processing options
bSize = 7680;           % block length [samples]
bIncr = 1344;           % block skip length [samples]
tZoom = 0.3;            % time zoom window size [relative scaling]
fZoom = 0.3;            % frequency zoom window size [relative scaling]

% plot options
cRange = 26;            % color depth
fMin = 10;              % minimum frequency [kHz]
fMax = 60;              % maximum frequency [kHz]
winSize = [0 0 1 1];    % figure size
markerOpts = '+g';      % set options for data points
markerSize = 25;        % set size of data points

%Get mouse position and plot limits
C=get(gca,'CurrentPoint');
xl=xlim;
yl=ylim;

%Import saved variables
tfa=get(handles.resetPush,'UserData');
mem=get(handles.regAxes,'UserData');

%Check if click was within axes
if C(1,1)>xl(1) && C(1,1)<xl(2) && C(1,2)>yl(1) && C(1,2)<yl(2)
    clickPoint=get(handles.dBText,'UserData'); %gets position of cursor when mouse button was pressed
    move=get(handles.freqText,'UserData'); %Checks flag to see if mouse moved since button was pressed
    if ~move
        % zoom to extent
        
        ah=handles.regAxes;
        set(ah, 'yLim', [fMin fMax]); %Locks y-axis zoom.  Right now
        %it sets the y-axis zoom later but it probably could be
        %done here more efficiently
        
        
        
        % process user input
        
        tNext = C(1,1);
        fNext = C(1,2);
        
        % accept new points
        
        tPos = tNext; %Sets time position to x-coordinate of click
        fPos = fNext; %sets freq position to y-coordinate of click
        
        % set new window boundaries
        
        tDel = str2double(handles.xEdit.String); %gets the user-specified plot width
        fDel = str2double(handles.yEdit.String); %gets the user-specified plot height
        set(ah, 'xLim', [tPos-tDel/2 tPos+tDel/2]); %centers the plot around the clicked point
        tStart=round(handles.regAxes.XLim(1)*fs/1000); %Determines which data entry is the first to be plotted in the new zoom
        handles.secEdit.String=num2str(tStart/fs); %Sets the text box to display the correct starting time
        bStop=tStart+bSize;
        mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)]; %Updates memory array
        plotSpect(data,fName,tStart,sampRate,hObject, handles); %plots the spectrogram
        set(ah, 'xLim', [tPos-tDel/2 tPos+tDel/2]); %These two lines center the plot around the clicked point.  I know it happens twice, but it's necessary
        set(ah, 'YLim', [fPos-fDel/2 fPos+fDel/2]);
        set(handles.dBText,'UserData',C); %Saves position of cursor when mouse buton was released
        click=0; %Sets flag to show that the mouse button is not being held down
        set(handles.timeText,'UserData',click); %Saves value of click
        set(handles.regAxes,'UserData',mem); %Saves memory array
        guidata(hObject, eventdata); %Updates all handles
        set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, data,dB, fName, handles));
        set (gcf, 'WindowButtonMotionFcn', @(object,eventdata) mouseMove(object,eventdata,hObject,fs,dB,tStart,data,fName,handles));
        % save data to file in current directory
        if handles.pointCheck.Value
            % add marker to point
            
            if exist('mh1','var') && ishandle(mh1), delete(mh1), end
            %removes previous marker for axes 1
            %axes(ah1) %sets axes 1 as the current axes
            mh1 = plot(str2double(handles.timeText.String),str2double(handles.freqText.String),markerOpts,'MarkerSize',markerSize);
            srow=get(handles.yEdit,'UserData');
            srow=srow+1; %Moves down a row for every point the user saves
            set(handles.yEdit,'UserData',srow); %Updates which row it's currently on
            tfa(srow,1)=str2double(handles.timeText.String); %Saves x-value of clicked point
            tfa(srow,2)=str2double(handles.freqText.String); %Saves y-values of clicked point
            tfa(srow,3)=str2double(handles.dBText.String); %Saves z-value of clicked point
            set(handles.resetPush,'UserData',tfa); %Saves array containing the three above values
            guidata(hObject,eventdata); %Updated handles
            
            named=get(handles.pointCheck,'UserData'); %Checks flag to see if user has named the file
            if ~named
                defaultName = {sprintf('tfa-%s', datestr(now,'yyyymmdd'))}; %Makes the default name for the file
                tfa_file=inputdlg('Enter a name for this file:','Name File',1,defaultName); %Opens dialogue box for user to name file; cancelling uses the default name
                named=1; %Sets flag to show the file has been named
                set(handles.pointCheck,'UserData',named); %Saves "named" flag
                set(handles.filePush,'UserData',tfa_file); %Saves file name
                guidata(hObject,eventdata); %Updates handles
            else
                tfa_file=get(handles.filePush,'UserData'); %Gets the name the user chose for the file
            end
            
            directory=fullfile('.',tfa_file); %Gets the path to the new file
            directory=char(directory); %Converts from a cell to a character array
            save(directory,'fName','tfa'); %creates a file in
            %the current directory named with the string determined above
            %and saves the array tfa along with name of the wav file to
            %that file
        end
        % reset variables for next iteration
        
        clear tPos fPos mh1 mh2 %ensures variables changed on this iteration
        %of the loop do not affect future iterations
        hold off %allows for the axes to be reset
        
    else
        set(handles.dBText,'UserData',C);
        click=0; %Sets flag to show the mouse button is not being held down
        set(handles.timeText,'UserData',click); %Saves "click" flag
        guidata(hObject, eventdata); %Updates handles
        
        choice=questdlg('Write selected data to new .wav file?',... %Opens dialogue box with "Yes" as defualt response
            'User Confirmation',...
            'Yes',...
            'No',...
            'Yes');
        switch choice
            case 'Yes'
                newStart=fs*round(clickPoint(1,1)); %Determines which data entry is the first in the highlighted area
                newEnd=fs*round(C(1,1)); %Determines which data entry is the last in the highlighted area
                newFileData=data(newStart:newEnd); %Makes array of all data entries between those points
                newName=sprintf('audio_extract-%s.wav', datestr(now,'yyyymmdd')); %Names the new wav file
                audiowrite(newName,newFileData,fs); %Makes new wav file
            case 'No'
                return; %Just ends the function if user declines making a new file
        end
    end
end