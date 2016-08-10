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
        elseif bStart<=0
                bStart=1;
            %ensures that it will never try to display before the beginning
            %of the file
        end
        bStop=bStart+bSize;
        lim=[bStart bStop];
        data=audioread(fDir,lim);
        [~,fName]=fileparts(fDir);
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
        switch nfftPick
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
                close(w);
            end
            
            if exist('handles.regAxes','var'), delete(handles.reAxes), end %clears axes
            ah = gca; %sets ah to the current axes
            dB=10*log10(abs(TFR)); %figures out decibel value for each frequency at each time
            set (gcf, 'WindowButtonMotionFcn', @(object,eventdata) mouseMove(object,eventdata,hObject,fs,dB,tStart,fDir,totSamp,handles));
            editCheck=get(handles.xSlider,'UserData');
            if editCheck
                maxdB=str2double(handles.colorEdit.String);
                start=0;
            else
                set(ah, 'xLim', [ str2double(handles.secEdit.String)*1000 str2double(handles.secEdit.String)*1000-handles.xSlider.Value]);
                xl=xlim;
                yl=ylim;
                if yl(2)==1
                    start=1;
                    yl=[fMin fMax];
                else
                    start=0;
                end
                usefuldB=dB';
                rowsize=size(xx);
                botRow=round(rowsize(1)*(yl(1)*1000/(fs/nfft)-1))+1;
                if botRow<1
                    botRow=1;
                end
                topRow=round(rowsize(1)*yl(2)*1000/(fs/nfft));
                usefuldB=usefuldB(botRow:topRow);
                colsize=size(usefuldB);
                rightcol=round(-handles.xSlider.Value/40*colsize(2));
                usefuldB=usefuldB';
                usefuldB=usefuldB(1:rightcol);
                maxdB=max(usefuldB);
                handles.colorEdit.String=num2str(maxdB);
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
            set (gcf, 'WindowButtonMotionFcn', @(object,eventdata) mouseMove(object,eventdata,hObject,fs,dB,tStart,fDir,totSamp,handles));
            if start
                set(ah, 'yLim', [fMin fMax]); %sets the y-limits of the plot equal to the max and min frequencies found in the file
            else
                set(ah, 'yLim', yl);
            end
