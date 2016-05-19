function tfa = swarming_bats_tfa(cwd)
% SWARMING_TFA  Displays time-frequency representations of time series data
% and interactively selects data points.

%% configurable parameters

fs = 192e3;             % hardcode sampling rate

% spectrogram options
nOver = 3;              % sliding window increment for TFR
nfft = 512;             % FFT points
wlen = 127;             % window length for STFT; must be odd for TFTB
wind = hanning(wlen);   % window for STFT

% block processing options
bSize = 1920;           % block length [samples]
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


%% load data files

% specify the current working directory

if ~exist('cwd','var') %Checks if a variable named "cwd" does not exist
    cwd = uigetdir('.','Select a folder to process data'); %Prompts user to select a directory; this directory is saved as the string "cwd"
end

% locate mat data files

files = findfiles(cwd,'sample\.mat$');  %There are several functions on the exchange called findfiles,
% but none of the ones I checked take arguments like this so we may need to
% change this line.  It should check the directory specified by cwd and
% find all files with the given extension. "files" is an array containing
% a string for the title of each file found in each entry.
%files = findfiles(cwd,'\.wav$');

% iterate over each file found

for fNum = 1:numel(files)
    [pname,fname,~] = fileparts(files{fNum});
    fprintf('Found file "%s" in directory:\n\t%s\n\n',fname,pname);
    % Prints the path and name of the nth file found in the directory cwd with
    % the desired extension, which for us is .wav, to the command window
    fprintf('Loading data...')
    data = load(fname); %%%%%%%%% read in blocks at a time for WAV files
    % fills an array with the data from the current wav file
    fprintf(' Done!\n\n')
    % Prints "Done" and skips two lines
    data_names = fieldnames(data); % List of names for each variable listed in data array
    % I don't know what this will return for a wav file since the
    % fieldnames function seems to be for .mat files
    fprintf('Found %d variables in file.  Assuming all are time series\n\n',numel(data_names))
    % takes number of names to determine number of variables in the wav file
    % and prints this number
    for vNum = 1:numel(data_names) % Sets up for loop to go through each entry in the wav file
        clear ts % Ensures there are no entries in sturcture ts
        ts.data = data.(data_names{vNum});      %%%%%%%%%%%%
        % The "data" entry in the structure ts is set to
        % the nth variable in the data array which should also be an array
        % determine block start/stop indices
        %This next part determines where to divide the wav file into blocks
        bStart = (1 : bIncr-1 : numel(ts.data)); % makes an array where the
        %first entry is 1, the next entry is 1343 more, and so on until the
        %point when adding another 1343 would exceed the current number of
        %elements in the data entry of ts
        bStop = [(bSize : bIncr-1 : numel(ts.data)-1) numel(ts.data)];
        % makes an array where the first element is 1920, the next entry is
        % 1343 more, and so on until adding another 1343 would exceed one
        % less than the current number of elements in the array.  The last
        % entry is then the current number of elements in the array to
        % ensure that the last block ends at the end of the data.
        nBlocks = numel(bStart); % Sets the number of blocks equal to the 
        %number of values on which a block starts.  This could also be done
        %with the number of values in bStop.

        ff = (0:nfft/2-1).*fs/nfft;          % frequency index
        % makes an array from 0 to 255, then multiplies every value in the
        % array by 375 (192000/512)
        % init time/frequency array
        tfa = []; %makes an empty array called tfa to be filled later; this
        % will be the output of the function

        % initialize window
        
        fh = figure('color','w'); %opens a white figure window
        set(fh,'units','norm'); %changes units from pixels to normalized
        set(fh,'pos',winSize); %sets figure size to the window size
        
        % iterate over each time block
        
        for bNum = 1:nBlocks
            % [ts.data,ts.fs] = audioread(fname,[bStart(bNum):bStop(bNum)]);
            
            % extract next block of signals
            
            xx = ts.data(bStart(bNum):bStop(bNum)); %array xx is now all the
            %values in the data entry of ts starting at one of the block
            %start values and ending at the corresponding block end value.
            %This line divided the data from the file into smaller blocks.
            ss = (1:nOver:bSize);             % sample index
            % makes an array from one to the number of entries in a block,
            % counting by 3s
            tt = (bStart(bNum):nOver:bStop(bNum))./fs;        % time index
            % makes an array of every 3rd entry in the block, then divides
            % every entry by 192000
            
            % compute both, spectrogram and reassigned spectrogram using TFTB
            
            xx = hilbert(xx);            % tftb requires analytic signals
            % performs a hilbert transform on the block
            % use parallel computing toolbox
%            job = batch('tfrrsp',2,{xx,ss,nfft,wind,1});
            [TFR,RTFR] = tfrrsp(xx,ss,nfft,wind,1); %tfrrsp is a function from
            %the file exchange.  It outputs the time-frequency
            %representation (spectrogram) and reassigned time-frequency representation of
            %the signal from xx.

            % remove analytic/imaginary parts
            
            TFR = TFR(1:end/2,:); %The Hilbert transform introduces imaginary parts
            %we don't care about, so this line and the one below it remove
            %the imaginary parts.  Specifically they take only the top half
            %of the arrays.
            RTFR = RTFR(1:end/2,:);

            % plot reassigned spectrogram
            
            if exist('ah1','var'), delete(ah1), end %ensures the results of
            %previous loops are removed
            ah1 = subplot(2,1,1); %breaks the axes into two plots stacked 
            %on top of each other; prepares to plot in the top one
            imagesc(tt*1e3,ff*1e-3,10*log10(abs(RTFR))); %creates an image
            % for the reassigned spectrogram with dimensions specified by
            % the lengths of time index tt and frequency index ff
            hold on %ensures next commands don't reset the current graph
            axis xy; axis tight; view(0,90) %fixes the axes to show the first
            %quadrant, makes the axes the length of the data, and sets the
            %elevation for the 3D graph without rotating the plot.
            colorbar %adds a colorbar to the current axes
            colormap(hot) %selects the colors used to create the plot
            cLim = get(gca,'clim'); 
            set(gca, 'cLim', [cLim(2)-cRange cLim(2)]); %sets limits on colors used
            ylabel('Frequency (kHz)','fontsize',16) %labels y-axis
            title(sprintf('%s - Block %d of %d',fname,bNum,nBlocks),'fontsize',16,'interpreter','none')
            % labels the graph with file name, which block is currently
            % being displayed, and how many total blocks there are
            
            % plot vertical line showing overlap
            
            %TBD
            
            % plot traditional spectrogram
            
            % all of this is identical to the block above except it uses
            % the traditional spectrogram as a base, it plots in the bottom
            % subplot, and it labels the x-axis.
            if exist('ah2','var'), delete(ah2), end
            ah2 = subplot(2,1,2);
            imagesc(tt*1e3,ff*1e-3,10*log10(abs(TFR)));
            hold on
            axis xy; axis tight; view(0,90)
            colorbar
            colormap(hot)
            cLim = get(gca,'clim');
            set(gca, 'cLim', [cLim(2)-cRange cLim(2)]);
            xlabel('Time (ms)','fontsize',16)
            ylabel('Frequency (kHz)','fontsize',16)
            
            % plot vertical line showing overlap
            
            %TBD
            
            nextBlock = false;      % init flag for plotting next block
            %This will later be a condition used to know when to break out
            %of the while loop and move on to the next block; it has to be
            %set to false before the while loop starts each time to ensure
            %it doesn't break immediately
            
            % repeat until no more points selected
            
            while 1 %ensures the while loop will continue until a break 
                %command is used.
                
                % zoom to extent
                
                axes(ah1) %makes the axes for the reassigned spectrogram the
                %current axes.
                set(ah1, 'xLim', [tt(1) tt(end)]*1e3);
                set(ah1, 'yLim', [fMin fMax]); %These lines set the limits
                % of the x- and y-axes based on the limits of the time
                % index and the min and max frequencies listed at the start
                if(numel(tfa)) %checks if anything is in the array tfa; on
                    %the first time through the loop it should be empty
                    %if exist('mhand1','var'), delete(mhand1), end
                    mhand1 = plot([tfa(:).time],[tfa(:).freq],markerOpts,'MarkerSize',markerSize);
                    % if tfa is filled, plots frequency vs. time
                end
                axes(ah2) %same as above but for the bottom axes
                set(ah2, 'xLim', [tt(1) tt(end)]*1e3);
                set(ah2, 'yLim', [fMin fMax]);
                if(numel(tfa))
%                    if exist('mhand2','var'), delete(mhand2), end
                    mhand2 = plot([tfa(:).time],[tfa(:).freq],markerOpts,'MarkerSize',markerSize);
                end
                
                % repeat until user selects point
                
                while 1 %sets the while loop to continue until a break
               

                    % process user input
                    
                    [tNext,fNext,button] = ginput(1);
                    % takes the x- and y-coordinates of the mouse as the
                    % moment the mouse is clicked or a key on the keyboard
                    % is hit; also records which button was clicked/pressed
                    if ~isscalar(button) %In case the user somehow gives a
                        %button input that matlab reads as a vector, gives
                        %a warning message and breaks out of the loop
                        warning('Unknown user input')
                        break
                    end

                    % zoom until spacebar pressed
                    
                    switch button %a case statement which varies depending
                        %on which key was pressed
                    case 1          % left mouse button selects points

                        % get current window boundaries
                        
                        tWin = get(ah1, 'xLim');
                        fWin = get(ah1, 'yLim');

                        % check if within boundaries
                        
                        if tNext < tWin(1) || tNext > tWin(end) || fNext < fWin(1) || fNext > fWin(end)
                            warning('Cursor out of bounds, select another point.')
                            continue %skips past the rest of the while loop
                            %and starts the loop over
                        end

                        % accept new points
                        
                        tPos = tNext; %Sets time position to x-coordinate of click
                        fPos = fNext; %sets freq position to y-coordinate of click

                        % set new window boundaries
                        
                        tDel = diff(tWin)*tZoom; %tWin is currently holding
                        %the maximum and minimum values for the x-axis.
                        %This takes the difference and multiplies the
                        %factor specified at the start in order to zoom
                        fDel = diff(fWin)*fZoom; %same as above for y-axis
                        set(ah1, 'xLim', [tPos-tDel/2 tPos+tDel/2]);
                        set(ah2, 'xLim', [tPos-tDel/2 tPos+tDel/2]);
                        set(ah1, 'yLim', [fPos-fDel/2 fPos+fDel/2]);
                        set(ah2, 'yLim', [fPos-fDel/2 fPos+fDel/2]);
                        %These four lines set the maximum and minimum x-
                        %and y-values such that the display is centered at
                        %the clicked point and the scale is changed
                        %according to the factors tZoom and fZoom
   
                        % add marker to point
                        
                        if exist('mh1','var') && ishandle(mh1), delete(mh1), end
                        %removes previous marker for axes 1
                        axes(ah1) %sets axes 1 as the current axes
                        mh1 = plot(tPos,fPos,markerOpts,'MarkerSize',markerSize);
                        %plots clicked point on axes 1
                        if exist('mh2','var') && ishandle(mh2), delete(mh2), end
                        %removes previous marker for axes 2
                        axes(ah2) %sets axes 2 as the current axes
                        mh2 = plot(tPos,fPos,markerOpts,'MarkerSize',markerSize);
                        % plots clicked point on axes 2

                    case 3      % right mouse button zooms out
                        
                        % get current window boundaries
                        
                        tWin = get(ah1, 'xLim');
                        fWin = get(ah1, 'yLim');
                        
                        % set larger window boundaries
                        
                        tDel = diff(tWin)/tZoom;
                        fDel = diff(fWin)/fZoom;
                        %These two lines work the same as the similar lines
                        %for the left mouse click but instead of
                        %multiplying by the zoom factors they divide, and
                        %since the factors are less than one this zooms out
                        %instead of in
                        set(ah1, 'xLim', [tPos-tDel/2 tPos+tDel/2]);
                        set(ah2, 'xLim', [tPos-tDel/2 tPos+tDel/2]);
                        set(ah1, 'yLim', [fPos-fDel/2 fPos+fDel/2]);
                        set(ah2, 'yLim', [fPos-fDel/2 fPos+fDel/2]);
                        %Like for the mouse click, this centers the graphs
                        %around the clicked point but zooms out instead of
                        %in
                        
                    case 32         % spacebar moves on to next point
                        % record last position entered
                        if exist('tPos','var') %checks if there is a saved
                            %value for tPos; if not, this is the first
                            %button press of the block so there is no last
                            %position to enter
                            fprintf('(%g ms, %g kHz)\n',tPos,fPos)
                            % writes the time and frequency of the last
                            % button press to the command window
                            tfa(end+1).time = tPos; %extends the length of 
                            %the array tfa by one and makes the last time entry
                            %equal to the last click
                            tfa(end).freq = fPos; %sets last tfa freq entry 
                            %equal to last click
                            tfa(end).ampl = NaN;      % TBD
                        end
                        break               % exit loop

                    case 8         % backspace deletes last point
                        tfa(end) = []; %completely removes the last entry in
                        %the array tfa
                        break
                        
                    case 27         % escape moves to the next block
                        nextBlock = true; %This will later break out of the
                        %outside while loop and allow the program to move
                        %on to the next block
                        break
                        
                    otherwise
                        warning('Unknown command key used - key code "%d"', button)
                        %covers all other key possibilities
                    end
                end
                
                % exit loop and go to next block
                
                if nextBlock
                    break %nextBlock is only true if escape was hit, so it
                    %will move on to the next block
                end

            end
            
            % reset variables for next iteration
            
            clear tPos fPos mh1 mh2 %ensures variables changed on this iteration
            %of the loop do not affect future iterations
            hold off %allows for the axes to be reset
            
            % save data to file in current directory
            
            tfa_file = sprintf('tfa-block%.4d-%s', bNum, datestr(now,'yyyymmdd'));
            %creates a string with the block number and current date
            fprintf('Saving data points to "%s"\n\n',tfa_file) %Prints this message
            %to the command window
            save(fullfile('.',tfa_file),'tfa','fname'); %creates a file in 
            %the current directory named with the string determined above
            %and saves the array tfa along with name of the wav file to
            %that file

        end
    end
end

