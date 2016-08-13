function dB=plotSpect(fDir,totSamp,tStart,sampRate,hObject, handles,w)

%% configurable parameters

fs = sampRate;             % hardcode sampling rate

% spectrogram options
nOver = 1;              % sliding window increment for TFR
wlen = 127;             % window length for STFT; must be odd for TFTB
wind = hanning(wlen);   % window for STFT

% block processing options
bSize = fs*.04;           % block length [samples]
bIncr = 1344;           % block skip length [samples]
tZoom = 0.3;            % time zoom window size [relative scaling]
fZoom = 0.3;            % frequency zoom window size [relative scaling]

% plot options
cRange = 21;            % color depth
fMin = 10;              % minimum frequency [kHz]
fMax = 60;              % maximum frequency [kHz]
winSize = [0 0 1 1];    % figure size
markerOpts = '+g';      % set options for data points
markerSize = 25;        % set size of data points

        clear ts % Ensures there are no entries in sturcture ts
        bStart = tStart; % makes an array where the
        %first entry is 1, the next entry is 1343 more, and so on until the
        %point when adding another 1343 would exceed the current number of
        %elements in the data entry of ts
        if bStart>(totSamp-bSize)
            bStart=(totSamp-bSize);
            handles.secEdit.String=num2str(bStart/fs);
            %ensures that it will never try to display past the end of the
            %file
        end
        if bStart<=0
                bStart=1;
            %ensures that it will never try to display before the beginning
            %of the file
        end
        if totSamp<bStart+bSize %ensures that if the file is shorter than 40 milliseconds it will load right
            bStop=totSamp;
        else
            bStop=bStart+bSize; %determines last data entry to be displayed 
        end
        lim=[bStart bStop]; %array with limits on what data entries will be displayed
        data=audioread(fDir,lim); %reads in the necessary data from the choses file
        [~,fName]=fileparts(fDir); %gets name of chosen file
        ts.data = data;      %%%%%%%%%%%%
        % The "data" entry in the structure ts is set to
        % the nth variable in the data array which should also be an array
        % determine block start/stop indices
        %This next part determines where to divide the wav file into blocks
        
        %determines which data entry will be the last one displayed
        totSec=totSamp/fs;
        % makes an array where the first element is 1920, the next entry is
        % 1343 more, and so on until adding another 1343 would exceed one
        % less than the current number of elements in the array.  The last
        % entry is then the current number of elements in the array to
        % ensure that the last block ends at the end of the data.
        %nBlocks = numel(bStart); % Sets the number of blocks equal to the 
        %number of values on which a block starts.  This could also be done
        %with the number of values in bStop.
        
        nfftPick=handles.nfftList.Value;
        switch nfftPick %gets number of fft points from menu on gui
            case 1
                nfft=128;
            case 2
                nfft=256;
            case 3
                nfft=512;
            case 4
                nfft=1024;
        end

        ff = (0:nfft/2-1).*fs/nfft;          % frequency index
        % makes an array from 0 to 255, then multiplies every value in the
        % array by 375 (192000/512)
        % init time/frequency array
        tfa = []; %makes an empty array called tfa to be filled later; this
        % will be the output of the function
        
        % iterate over each time block
            
            % extract next block of signals
            
            xx = ts.data; %array xx is now all the
            %values in the data entry of ts starting at one of the block
            %start values and ending at the corresponding block end value.
            %This line divided the data from the file into smaller blocks.
            ss = (1:nOver:bSize);             % sample index
            % makes an array from one to the number of entries in a block,
            % counting by 3s
            tt = (bStart:nOver:bStop)./fs;        % time index
            % makes an array of every 3rd entry in the block, then divides
            % every entry by 192000
            
            % compute both, spectrogram and reassigned spectrogram using TFTB
            
            xx = hilbert(xx);            % tftb requires analytic signals
            % performs a hilbert transform on the block
            % use parallel computing toolbox
%            job = batch('tfrrsp',2,{xx,ss,nfft,wind,1});
            [TFR] = tfrrsp(xx,ss,nfft,wind,1); %tfrrsp is a function from
            %the file exchange.  It outputs the time-frequency
            %representation (spectrogram) and reassigned time-frequency representation of
            %the signal from xx.
            
            % remove analytic/imaginary parts
            TFR = TFR(1:end/2,:); %The Hilbert transform introduces imaginary parts
            %we don't care about, so this line and the one below it remove
            %the imaginary parts.  Specifically they take only the top half
            %of the arrays.
            % plot spectrogram
            if exist('w','var');
                close(w); %if "please wait" message is open, closes it
            end
            
            if exist('handles.regAxes','var'), delete(handles.reAxes), end %clears axes
            ah = gca; %sets ah to the current axes
            dB=10*log10(abs(TFR)); %figures out decibel value for each frequency at each time
            set (gcf, 'WindowButtonMotionFcn', @(object,eventdata) mouseMove(object,eventdata,hObject,fs,dB,tStart,fDir,totSamp,handles));
            editCheck=get(handles.xSlider,'UserData');
            if editCheck %this flag is set if the user changes the maximum dB value displayed
                maxdB=str2double(handles.colorEdit.String); %sets user's max dB
                start=0; %flag to say that the program didn't just start
            else
                set(ah, 'xLim', [ str2double(handles.secEdit.String)*1000 str2double(handles.secEdit.String)*1000-handles.xSlider.Value]); %sets x-axis so it knows where to look for the max dB
                yl=ylim;
                if yl(2)==1 %this is only the case upon startup
                    start=1; %flag showing no axes have been set
                    yl=[fMin fMax]; %sets y-axis to defualt
                else
                    start=0; %resets flag
                end
                usefuldB=dB'; %since matlab goes down columns, then across rows, it's necessary to transpose it to eliminate rows
                rowsize=size(xx); %number of entries in each row of usefuldB
                botRow=round(rowsize(1)*(yl(1)*1000/(fs/nfft)-1))+1; %estimates the first data point actually displayed on the plot
                if botRow<1 %ensures it can never be less than 1, since that's impossible
                    botRow=1;
                end
                topRow=round(rowsize(1)*yl(2)*1000/(fs/nfft)); %estimates last data point actually displayed on the plot
                usefuldB=usefuldB(botRow:topRow); %makes an array of just points on the plot given the y-axis limits
                colsize=size(usefuldB); %total datapoints in array
                rightcol=round(-handles.xSlider.Value/40*colsize(2)); %estimates the last data point to appear on the plot given the x-axis limits.  It's crude but it seems to work
                usefuldB=usefuldB(1:rightcol); %further limits the matrix to only what will be displayed within the x- and y-limits
                maxdB=max(usefuldB); %determines the max dB value displayed on the plot
                handles.colorEdit.String=num2str(maxdB); %updates text box with the max value
                set(handles.nfftList,'UserData',usefuldB);
            end
            hold on %ensures next commands don't reset the current graph
            axis xy; axis tight; view(0,90) %fixes the axes to show the first
            %quadrant, makes the axes the length of the data, and sets the
            %elevation for the 3D graph without rotating the plot.
            colorbar %adds a colorbar to the current axes
            colormap(hot) %selects the colors used to create the plot
            %cLim = get(gca,'clim'); 
            set(gca, 'cLim', [-cRange+maxdB maxdB]); %sets limits on colors used
            set(gca, 'XTick',[]); %turns off the numbers on the x-axis
            ylabel('Frequency (kHz)','fontsize',16) %labels y-axis
            title(sprintf('%s- %d seconds long',fName,totSec),'fontsize',16,'interpreter','none')
            % labels the graph with file name, which block is currently
            % being displayed, and how many total blocks there are
            xlabel('Time','fontsize',16)
            %These lines set parameters for the plot, specifically the
            %color set, creating a color scale to display next to the plot,
            %and labeling x- and y-axes.
            imagesc(tt*1e3,ff*1e-3,dB);  %plots the spectrogram.  Don't question how it works, it just does
            guidata(hObject,handles);
            set (gcf, 'WindowButtonMotionFcn', @(object,eventdata) mouseMove(object,eventdata,hObject,fs,dB,tStart,fDir,totSamp,handles));
            if start %this flag is only set immediately upon startup
                set(ah, 'yLim', [fMin fMax]); %sets the y-limits of the plot equal to the max and min frequencies found in the file
            else
                set(ah, 'yLim', yl); %resets the y-zoom to whatever it was before plotspect was called
            end
