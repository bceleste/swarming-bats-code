function mouseMove(object,eventdata,hObject,fs,dB,tStart,data,fname,handles)

% Get current mouse position
C=get(gca,'CurrentPoint');
xl=xlim;
yl=ylim;

%Check if area is highlighted
r=get(handles.ySlider,'UserData');
delete(r); %removes any highlights on the plot

%Check if mouse is moving over plot
if C(1,1)>xl(1) && C(1,1)<xl(2) && C(1,2)>yl(1) && C(1,2)<yl(2) && C(1,1)>=0 && C(1,2)>=0 && round(C(1,1)*fs/1000-tStart)>=0;
    %display current time/frequency
    clear handles.freqText,'UserData';
    handles.timeText.String=num2str(C(1,1));
    handles.freqText.String=num2str(C(1,2));
    click=get(handles.timeText,'UserData'); %This should be 1 if the mouse button is held down and 0 otherwise
    if click
        clickPoint=get(handles.dBText,'UserData'); %mouse position when mouse was clicked
        %Draw translucent rectangle to highlight selected area
        r=patch([clickPoint(1,1) C(1,1) C(1,1) clickPoint(1,1)],[yl(1) yl(1) yl(2) yl(2)],'blue'); %gets rectangle boundries
        set(r,'FaceAlpha',.5); %sets transparency to .5
        set(handles.ySlider,'UserData',r); %saves this rectangle so it knows what to delete next time the mouse moves
        drawnow;
    end
    %display current decibel value
    handles.dBText.String=num2str(dB(round(C(1,2)*1000/(fs/512)),round(C(1,1)/1000*fs-tStart)));
    move=1; %flag to confirm that mouse moved since the mouse button was pressed
    set(handles.freqText,'UserData',move); %saves value of move to pass into drag
    set (gcf, 'WindowButtonUpFcn', @(object,eventdata)drag(object, eventdata, fs, hObject, data, dB, fname, handles));
    guidata(hObject,handles); %updates all handles
    drawnow;
else
    %Set all displays to 0
    handles.timeText.String=0;
    handles.freqText.String=0;
    handles.dBText.String=0;
    guidata(hObject,handles);
    drawnow;
end