function varargout = swarming_bats_tfa(varargin)

%SWARMING_BATS_TFA MATLAB code file for swarming_bats_tfa.fig
%      SWARMING_BATS_TFA, by itself, creates a new SWARMING_BATS_TFA or raises the existing
%      singleton*.
%
%      H = SWARMING_BATS_TFA returns the handle to a new SWARMING_BATS_TFA or the handle to
%      the existing singleton*.
%
%      SWARMING_BATS_TFA('Property','Value',...) creates a new SWARMING_BATS_TFA using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to swarming_bats_tfa_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SWARMING_BATS_TFA('CALLBACK') and SWARMING_BATS_TFA('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SWARMING_BATS_TFA.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help swarming_bats_tfa

% Last Modified by GUIDE v2.5 03-Aug-2016 23:04:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @swarming_bats_tfa_OpeningFcn, ...
                   'gui_OutputFcn',  @swarming_bats_tfa_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before swarming_bats_tfa is made visible.
function swarming_bats_tfa_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)


% Choose default command line output for swarming_bats_tfa
 [totSamp,fs,fDir]=loadFiles();
 handles.output = hObject;
 %if data==0;
     %return;
 %end
tStart=1; move=0; click=0; srow=0; tfa=[]; named=0;
set(handles.xEdit, 'UserData', fDir);
set(handles.morePush, 'UserData', totSamp);
set(handles.secEdit,'UserData', fs);
set(handles.freqText,'UserData',move);
set(handles.timeText,'UserData',click);
set(handles.yEdit,'UserData',srow);
set(handles.resetPush,'UserData',tfa);
set(handles.pointCheck,'UserData',named);
sampRate=fs;
set(handles.regAxes,'UserData',[tStart,handles.xSlider.Value,handles.ySlider.Value,0,0,0,0,0,0,0,0,0,]);
handles.dB=[];
set(gcf, 'units', 'normalized', 'position', [0.05 0.15 0.9 0.8]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes swarming_bats_tfa wait for user response (see UIRESUME)
% uiwait(handles.figure1);
dB=plotSpect(fDir,totSamp,tStart,sampRate,hObject,handles);
set (gcf, 'WindowButtonDownFcn', @(object,eventdata) clickStart(object,eventdata,fs,hObject,fDir,totSamp,dB,handles));
set (gcf, 'WindowButtonMotionFcn', @(object,eventdata) mouseMove(object,eventdata,hObject,fs,dB,tStart,fDir,totSamp,handles));
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir,totSamp, dB, handles));
% --- Outputs from this function are returned to the command line.
function varargout = swarming_bats_tfa_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function xSlider_Callback(hObject, eventdata, handles)
% hObject    handle to xSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sampRate=get(handles.secEdit,'UserData');
tStart=sampRate*str2num(handles.secEdit.String);
handles.xEdit.String=num2str(-handles.xSlider.Value);
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);

% --- Executes during object creation, after setting all properties.
function xSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function xEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xEdit as text
%        str2double(get(hObject,'String')) returns contents of xEdit as a double
sampRate=get(handles.secEdit,'UserData');
tStart=sampRate*str2num(handles.secEdit.String);
handles.xSlider.Value=-str2num(handles.xEdit.String);
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);

% --- Executes during object creation, after setting all properties.
function xEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in filePush.
function filePush_Callback(hObject, eventdata, handles)
% hObject    handle to filePush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;
swarming_bats_tfa();


% --- Executes on button press in undoPush.
function undoPush_Callback(hObject, eventdata, handles)
% hObject    handle to undoPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mem=get(handles.regAxes,'UserData');
if mem(4)~=0
w=msgbox('Please wait');
mem=[mem(4),mem(5),mem(6),mem(7),mem(8),mem(9),mem(10),mem(11),mem(12),0,0,0];
set(handles.regAxes,'UserData',mem);
%display(mem);
tStart=mem(1);
handles.xSlider.Value=mem(2);
handles.xEdit.String=num2str(-handles.xSlider.Value);
handles.ySlider.Value=mem(3);
handles.yEdit.String=num2str(-handles.ySlider.Value);
fDir=get(handles.xEdit,'UserData');
sampRate=get(handles.secEdit,'UserData');
totSamp=get(handles.morePush,'UserData');
fs=sampRate;
handles.secEdit.String=num2str(tStart/fs);
plotSpect(fDir,totSamp,tStart,sampRate,hObject,handles,w);
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir,totSamp,dB,  handles));
set(gca, 'XLim', [str2num(handles.secEdit.String)*1000 (str2num(handles.secEdit.String))*1000-handles.xSlider.Value]);
else
    fprintf('Cannot undo\n');
end


function secEdit_Callback(hObject, eventdata, handles)
% hObject    handle to secEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of secEdit as text
%        str2double(get(hObject,'String')) returns contents of secEdit as a double
w=msgbox('Please wait');
fDir=get(handles.xEdit,'UserData');
handles.xSlider.Value=-40;
handles.xEdit.String=40;
fs=get(handles.secEdit,'UserData');
tStart=fs*str2num(handles.secEdit.String);
totSamp=get(handles.morePush,'UserData');
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir,totSamp, dB,  handles));
plotSpect(fDir,totSamp,tStart,fs,hObject,handles,w);
set(gca, 'XLim', [str2num(handles.secEdit.String)*1000 (str2num(handles.secEdit.String))*1000-handles.xSlider.Value]);

% --- Executes during object creation, after setting all properties.
function secEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pointCheck.
function pointCheck_Callback(hObject, eventdata, handles)
% hObject    handle to pointCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pointCheck


% --- Executes on slider movement.
function ySlider_Callback(hObject, eventdata, handles)
% hObject    handle to ySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sampRate=get(handles.secEdit,'UserData');
tStart=sampRate*str2num(handles.secEdit.String);
handles.yEdit.String=num2str(-handles.ySlider.Value);
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);

% --- Executes during object creation, after setting all properties.
function ySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function yEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yEdit as text
%        str2double(get(hObject,'String')) returns contents of yEdit as a double
sampRate=get(handles.secEdit,'UserData');
tStart=sampRate*str2num(handles.secEdit.String);
handles.ySlider.Value=-str2num(handles.yEdit.String);
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);

% --- Executes during object creation, after setting all properties.
function yEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in halfBackPush.
function halfBackPush_Callback(hObject, eventdata, handles)
% hObject    handle to halfBackPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=msgbox('Please wait');
fDir=get(handles.xEdit,'UserData');
sampRate=get(handles.secEdit,'UserData');
totSamp=get(handles.morePush,'UserData');
tStart=round(sampRate*str2num(handles.secEdit.String));
tStart=tStart+(.5*handles.xSlider.Value/1000*sampRate);
if tStart<1
    tStart=1;
end
handles.secEdit.String=num2str(tStart/sampRate);
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir, totSamp, dB,  handles));
plotSpect(fDir,totSamp,tStart,sampRate,hObject,handles,w);
set(gca, 'XLim', [str2num(handles.secEdit.String)*1000 (str2num(handles.secEdit.String))*1000-handles.xSlider.Value]);

% --- Executes on button press in fullBackPush.
function fullBackPush_Callback(hObject, eventdata, handles)
% hObject    handle to fullBackPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=msgbox('Please wait');
fDir=get(handles.xEdit,'UserData');
sampRate=get(handles.secEdit,'UserData');
totSamp=get(handles.morePush,'UserData');
tStart=round(sampRate*str2num(handles.secEdit.String));
tStart=tStart+(handles.xSlider.Value/1000*sampRate);
if tStart<1
    tStart=1;
end
handles.secEdit.String=num2str(tStart/sampRate);
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir, totSamp, dB,  handles));
plotSpect(fDir,totSamp,tStart,sampRate,hObject,handles,w);
set(gca, 'XLim', [str2num(handles.secEdit.String)*1000 (str2num(handles.secEdit.String))*1000-handles.xSlider.Value]);

% --- Executes on button press in halfForwardPush.
function halfForwardPush_Callback(hObject, eventdata, handles)
% hObject    handle to halfForwardPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.secEdit.Text=num2str(str2num(handles.secEdit.String)+.5*str2num
w=msgbox('Please wait');
fDir=get(handles.xEdit,'UserData');
sampRate=get(handles.secEdit,'UserData');
totSamp=get(handles.morePush,'UserData');
tStart=round(sampRate*str2num(handles.secEdit.String));
tStart=tStart-(.5*handles.xSlider.Value/1000*sampRate);
if tStart>(totSamp-.04*sampRate)
    tStart=totSamp-.04*sampRate;
end
handles.secEdit.String=num2str(tStart/sampRate);
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir, totSamp, dB,  handles));
plotSpect(fDir,totSamp,tStart,sampRate,hObject,handles,w);
set(gca, 'XLim', [str2num(handles.secEdit.String)*1000 (str2num(handles.secEdit.String))*1000-handles.xSlider.Value]);
% --- Executes on button press in fullForwardPush.
function fullForwardPush_Callback(hObject, eventdata, handles)
% hObject    handle to fullForwardPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=msgbox('Please wait');
fDir=get(handles.xEdit,'UserData');
sampRate=get(handles.secEdit,'UserData');
totSamp=get(handles.morePush,'UserData');
tStart=round(sampRate*str2num(handles.secEdit.String));
tStart=tStart-(handles.xSlider.Value/1000*sampRate);
if tStart>(totSamp-.04*sampRate)
    tStart=totSamp-.04*sampRate;
end
handles.secEdit.String=num2str(tStart/sampRate);
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir, totSamp, dB,  handles));
plotSpect(fDir,totSamp,tStart,sampRate,hObject,handles,w);
set(gca, 'XLim', [str2num(handles.secEdit.String)*1000 (str2num(handles.secEdit.String))*1000-handles.xSlider.Value]);

% --- Executes on button press in resetPush.
function resetPush_Callback(hObject, eventdata, handles)
% hObject    handle to resetPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w=msgbox('Please wait');
handles.yEdit.String=50;
handles.ySlider.Value=-50;
fDir=get(handles.xEdit,'UserData');
sampRate=get(handles.secEdit,'UserData');
totSamp=get(handles.morePush,'UserData');
tStart=round(sampRate*str2double(handles.secEdit.String));
mem=get(handles.regAxes,'UserData');
mem=[tStart,handles.xSlider.Value,handles.ySlider.Value,mem(1),mem(2),mem(3),mem(4),mem(5),mem(6),mem(7),mem(8),mem(9)];
set(handles.regAxes,'UserData',mem);
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir, totSamp, dB,  handles));
plotSpect(fDir,totSamp,tStart,sampRate,hObject,handles,w);
set(gca, 'XLim', [str2num(handles.secEdit.String)*1000 (str2num(handles.secEdit.String))*1000-handles.xSlider.Value]);


% --- Executes on button press in morePush.
function morePush_Callback(hObject, eventdata, handles)
% hObject    handle to morePush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%To add a function to the "More Options" list, first write the function and save it to this
%program's directory.  Below are the available inputs for the function.


fs=get(handles.secEdit,'UserData'); %sample rate of original .wav file
tStart=round(fs*str2double(handles.secEdit.String)); %time of the leftmost edge of the plot when the button was clicked, in seconds
plotWidth=-handles.xSlider.Value; %width of the plot when the button was clicked, in milliseconds
plotHeight=-handles.ySlider.Value; %height of the plot when the button was clicked, in kilohertz
fDir=get(handles.xEdit,'UserData'); %Vector containing all data entries from the original .wav file
plotData=audioread(fDir,round(gcf.XLim.*(fs*1000))); %vector containing data entries from the original .wav file for the times displayed
                                                     %on the plot when the button was clicked

%Now add the function to funcList.  Put the name in single quotes and
%separate entries with a comma
%ex. funcList={'exampleFunc','otherFunc'};
funcList={};
[sel,ok]=listdlg('PromptString','Select a function','SelectionMode','single','ListString',funcList);
choice=char(funcList(sel));
if ok==0;
    return;
%Finally write a case for the function which calls it.  After the line
%"swith choice" and before its corresponding "end", write
%"case 'functionName'", then on the next line call that function with all
%its inputs
else
    switch choice
        %case 'exampleFunc'
            %exampleFunc(fs,plotData);
    end 
end



function colorEdit_Callback(hObject, eventdata, handles)
% hObject    handle to colorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colorEdit as text
%        str2double(get(hObject,'String')) returns contents of colorEdit as a double
w=msgbox('Please wait');
handles.yEdit.String=50;
handles.ySlider.Value=-50;
fDir=get(handles.xEdit,'UserData');
sampRate=get(handles.secEdit,'UserData');
totSamp=get(handles.morePush,'UserData');
tStart=round(sampRate*str2double(handles.secEdit.String));
plotSpect(fDir,totSamp,tStart,sampRate,hObject,handles,w);

% --- Executes during object creation, after setting all properties.
function colorEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
