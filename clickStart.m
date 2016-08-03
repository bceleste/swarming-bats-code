function clickStart(object,eventdata,fs,hObject,fDir,totSamp,dB,handles)

move=0; %sets flag to say that mouse hasn't moved since the mouse button was last clicked
click=1; %sets flag that says the mouse button is held down
C=get(gca,'CurrentPoint'); %gets current mouse position
%Save variable values
set(handles.dBText,'UserData',C);
set(handles.freqText,'UserData',move);
set(handles.timeText,'UserData',click);
set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, fDir,totSamp,dB,handles));
guidata(hObject, eventdata);
