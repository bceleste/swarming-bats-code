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
if ~exist('cwd','var')
    cwd = uigetdir('.','Select a folder to process data');
end

% locate mat data files
files = findfiles(cwd,'sample\.mat$');  
%files = findfiles(cwd,'\.wav$');

% iterate over each file found
for fNum = 1:numel(files)
    [pname,fname,~] = fileparts(files{fNum});
    fprintf('Found file "%s" in directory:\n\t%s\n\n',fname,pname);
   
    fprintf('Loading data...')
    data = load(fname); %%%%%%%%% read in blocks at a time for WAV files
    fprintf(' Done!\n\n')
   
    data_names = fieldnames(data);
    fprintf('Found %d variables in file.  Assuming all are time series\n\n',numel(data_names))
    
    for vNum = 1:numel(data_names)
        clear ts
        ts.data = data.(data_names{vNum});      %%%%%%%%%%%%

        % determine block start/stop indices
        bStart = (1 : bIncr-1 : numel(ts.data));
        bStop = [(bSize : bIncr-1 : numel(ts.data)-1) numel(ts.data)];
        nBlocks = numel(bStart);

        ff = (0:nfft/2-1).*fs/nfft;          % frequency index

        % init time/frequency array
        tfa = [];

        % initialize window
        fh = figure('color','w');
        set(fh,'units','norm');
        set(fh,'pos',winSize);
        
        % iterate over each time block
        for bNum = 1:nBlocks
            % [ts.data,ts.fs] = audioread(fname,[bStart(bNum):bStop(bNum)]);
            
            % extract next block of signals
            xx = ts.data(bStart(bNum):bStop(bNum));
            ss = (1:nOver:bSize);             % sample index
            tt = (bStart(bNum):nOver:bStop(bNum))./fs;        % time index

            % compute both, spectrogram and reassigned spectrogram using TFTB
            xx = hilbert(xx);            % tftb requires analytic signals
            % use parallel computing toolbox
%            job = batch('tfrrsp',2,{xx,ss,nfft,wind,1});
            [TFR,RTFR] = tfrrsp(xx,ss,nfft,wind,1);

            % remove analytic/imaginary parts
            TFR = TFR(1:end/2,:);
            RTFR = RTFR(1:end/2,:);

            % plot reassigned spectrogram
            if exist('ah1','var'), delete(ah1), end
            ah1 = subplot(2,1,1);
            imagesc(tt*1e3,ff*1e-3,10*log10(abs(RTFR)));
            hold on
            axis xy; axis tight; view(0,90)
            colorbar
            colormap(hot)
            cLim = get(gca,'clim');
            set(gca, 'cLim', [cLim(2)-cRange cLim(2)]);
            ylabel('Frequency (kHz)','fontsize',16)
            title(sprintf('%s - Block %d of %d',fname,bNum,nBlocks),'fontsize',16,'interpreter','none')

            % plot vertical line showing overlap
            %TBD
            
            % plot traditional spectrogram
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
            
            % repeat until no more points selected
            while 1
                
                % zoom to extent
                axes(ah1)
                set(ah1, 'xLim', [tt(1) tt(end)]*1e3);
                set(ah1, 'yLim', [fMin fMax]);
                if(numel(tfa))
                    %if exist('mhand1','var'), delete(mhand1), end
                    mhand1 = plot([tfa(:).time],[tfa(:).freq],markerOpts,'MarkerSize',markerSize);
                end
                axes(ah2)
                set(ah2, 'xLim', [tt(1) tt(end)]*1e3);
                set(ah2, 'yLim', [fMin fMax]);
                if(numel(tfa))
%                    if exist('mhand2','var'), delete(mhand2), end
                    mhand2 = plot([tfa(:).time],[tfa(:).freq],markerOpts,'MarkerSize',markerSize);
                end
                
                % repeat until user selects point
                while 1

                    % process user input
                    [tNext,fNext,button] = ginput(1);
                    
                    if ~isscalar(button)
                        warning('Unknown user input')
                        break
                    end

                    % zoom until spacebar pressed
                    switch button
                    case 1          % left mouse button selects points

                        % get current window boundaries
                        tWin = get(ah1, 'xLim');
                        fWin = get(ah1, 'yLim');

                        % check if within boundaries
                        if tNext < tWin(1) || tNext > tWin(end) || fNext < fWin(1) || fNext > fWin(end)
                            warning('Cursor out of bounds, select another point.')
                            continue
                        end

                        % accept new points
                        tPos = tNext;
                        fPos = fNext;

                        % set new window boundaries
                        tDel = diff(tWin)*tZoom;
                        fDel = diff(fWin)*fZoom;
                        set(ah1, 'xLim', [tPos-tDel/2 tPos+tDel/2]);
                        set(ah2, 'xLim', [tPos-tDel/2 tPos+tDel/2]);
                        set(ah1, 'yLim', [fPos-fDel/2 fPos+fDel/2]);
                        set(ah2, 'yLim', [fPos-fDel/2 fPos+fDel/2]);

                        % add marker to point
                        if exist('mh1','var') && ishandle(mh1), delete(mh1), end
                        axes(ah1)
                        mh1 = plot(tPos,fPos,markerOpts,'MarkerSize',markerSize);
                        if exist('mh2','var') && ishandle(mh2), delete(mh2), end
                        axes(ah2)
                        mh2 = plot(tPos,fPos,markerOpts,'MarkerSize',markerSize);

                    case 3      % right mouse button zooms out
                        
                        % get current window boundaries
                        tWin = get(ah1, 'xLim');
                        fWin = get(ah1, 'yLim');
                        
                        % set larger window boundaries
                        tDel = diff(tWin)/tZoom;
                        fDel = diff(fWin)/fZoom;
                        set(ah1, 'xLim', [tPos-tDel/2 tPos+tDel/2]);
                        set(ah2, 'xLim', [tPos-tDel/2 tPos+tDel/2]);
                        set(ah1, 'yLim', [fPos-fDel/2 fPos+fDel/2]);
                        set(ah2, 'yLim', [fPos-fDel/2 fPos+fDel/2]);
                        
                    case 32         % spacebar moves on to next point
                        % record last position entered
                        if exist('tPos','var')
                            fprintf('(%g ms, %g kHz)\n',tPos,fPos)
                            tfa(end+1).time = tPos;
                            tfa(end).freq = fPos;
                            tfa(end).ampl = NaN;      % TBD
                        end
                        break               % exit loop

                    case 8         % backspace deletes last point
                        tfa(end) = [];
                        break
                        
                    case 27         % escape moves to the next block
                        nextBlock = true;
                        break
                        
                    otherwise
                        warning('Unknown command key used - key code "%d"', button)
                    
                    end
                end
                
                % exit loop and go to next block
                if nextBlock
                    break
                end

            end
            
            % reset variables for next iteration
            clear tPos fPos mh1 mh2
            hold off
            
            % save data to file in current directory
            tfa_file = sprintf('tfa-block%.4d-%s', bNum, datestr(now,'yyyymmdd'));
            fprintf('Saving data points to "%s"\n\n',tfa_file)
            save(fullfile('.',tfa_file),'tfa','fname');

        end
    end
end
