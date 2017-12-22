function varargout = video_extractor_app(varargin)
% VIDEO_EXTRACTOR_APP MATLAB code for video_extractor_app.fig
%      VIDEO_EXTRACTOR_APP, by itself, creates a new VIDEO_EXTRACTOR_APP or raises the existing
%      singleton*.
%
%      H = VIDEO_EXTRACTOR_APP returns the handle to a new VIDEO_EXTRACTOR_APP or the handle to
%      the existing singleton*.
%
%      VIDEO_EXTRACTOR_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEO_EXTRACTOR_APP.M with the given input arguments.
%
%      VIDEO_EXTRACTOR_APP('Property','Value',...) creates a new VIDEO_EXTRACTOR_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before video_extractor_app_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to video_extractor_app_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help video_extractor_app

% Last Modified by GUIDE v2.5 22-Sep-2017 12:35:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @video_extractor_app_OpeningFcn, ...
                   'gui_OutputFcn',  @video_extractor_app_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before video_extractor_app is made visible.
function video_extractor_app_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to video_extractor_app (see VARARGIN)

% Choose default command line output for video_extractor_app
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes video_extractor_app wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = video_extractor_app_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%Get UserData for pushbutton1 and slider1
data = get(handles.pushbutton1, 'UserData');
data1 = get(hObject, 'UserData');

%Get range for slider
min = get(hObject,'Min');
max = get(hObject, 'Max');
range = max-min;

%Make sure slider value of 0 does not do anything
if(get(hObject, 'Value') > 0)
    
    %Get the current frame user wants to be on
    frame = (get(hObject,'Value')/range) * data.number_of_frames;
    data1.current_frame = round(frame);
    
    %Display desired frame and update current frame text box
    imshow(data.video(:,:,:,round(frame)));
    set(handles.text5, 'String', data1.current_frame);
    
    %Find closest previous annotation
    min_d = 1000000000000000000;
    figure_file = data1.current_frame;
    for index = 1:size(data.number,2)
        if ((data1.current_frame - data.number(index)) < min_d )&& (data1.current_frame >= data.number(index))
            min_d = data1.current_frame - data.number(index);
            figure_file = data.number(index);
        end
    end
    
    %Open and display chosen annotations
    file_number = num2str(figure_file);
    file_name = strcat(strcat(strcat(data.path,'\'),file_number),'.mat');

    if (exist(file_name, 'file'))
        load(file_name);
        
        if(~isempty(C))
            for index = 1:size(C,2)
                impoly(gca, C{index});
            end
        end
    end
end

%Set UserData pushbutton1
set(hObject,'UserData', data1);



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%Load button
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get UserData for pushbutton1 anf slider1
data = get(hObject, 'UserData');
data1 = get(handles.slider1, 'UserData');

%Prompt user to choose file
[file, data.path] = uigetfile({'*.mp4; *.avi; *.wma; *.mov;'});

%Only proceeds if file exists
if(file ~= 0)
    %Get file name to title accompanying mask and image files
    name_split = strsplit(file, '.');
    data.name = name_split(1);
    
    %Create VideoReader object
    data.v = VideoReader(file);

    %Create array containing all frames
    data.video = read(data.v,[1,Inf]);
    
    %Get number of frames
    data.number_of_frames = size(data.video,4);
    
    %Display first frame of video
    imshow(data.video(:,:,:,1));
    
    %Set number of frames text box
    set(handles.text7, 'String', data.number_of_frames);
    
    %%Load all .mat files in chosen directory for annotations
    data.files = dir(strcat(data.path,'\*.mat'));
    data.number = zeros(1,size(data.files,1));
    for index = 1:size(data.files, 1)
        data.number(index) = str2num(strrep(data.files(index).name,'.mat',''));
    end
    
    %Set number of annotation files to number of .mat files found
    data.counter = size(data.files, 1);
    
    %Display annotations for frame 1 if they exist
    file_number = num2str(1);
    file_name = strcat(strcat(strcat(data.path,'\'),file_number),'.mat');

    if (exist(file_name, 'file'))
        load(file_name);
        
        if(~isempty(C))
            for index = 1:size(C,2)
                impoly(gca, C{index});
            end
        end
    end
    
    %Set slider1 to positon 1
    set(handles.slider1, 'Value', 1/data.number_of_frames);
    
    %Set current frame = 1
    data1.current_frame = 1;
end

%Set UserData for pushbutton1 and slider1
set(hObject,'UserData', data);
set(handles.slider1, 'UserData', data1);

%Annotate button
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Create annotation object
impoly;

%Save button
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% save button
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get UserData for pushbutton 1 and slider1
data1 = get(handles.pushbutton1, 'UserData');
data2 = get(handles.slider1, 'UserData');

%Get all impoly objects on current frame and creat empty cell array
h = findall(gca,'Tag', 'impoly');
C = cell(size(h,2), 1);

%Get coordinates of each annotation and assign to a position in cell array
for index = 1:size(h,1)
    api = iptgetapi(h(index));
    points = api.getPosition();
    C{index} = points;
end

%Save cell array in .mat file using frame number for name
filename = strcat(data1.path,num2str(data2.current_frame));
filename = strcat(filename, '.mat');
save(filename, 'C');

%Create name for .png files using video file name and frame number
png_name = strcat(data1.path,data1.name{1});
png_name = strcat(png_name, '_');
png_name = strcat(png_name,num2str(data2.current_frame));

% Create a mask out of all annotions for current frame
x = size(data1.video,1);
y = size(data1.video,2);
BW = false(x,y);

for i = 1:size(C,2)
    b = C{i};
    BW = BW | poly2mask(b(:,1), b(:,2), x, y);
end

%Create name for image and mask file
image_name = strcat(png_name,'_image');
image_name = strcat(image_name, '.png');
mask_name = strcat(png_name,'_mask');
mask_name = strcat(mask_name, '.png');

%Write image and mask files
imwrite(data1.video(:,:,:,data2.current_frame),image_name);
imwrite(BW,mask_name);

%Increment count of .mat files
data1.counter = data1.counter + 1;

%Add current frame to list of frames with annotations
data1.number(data1.counter) = data2.current_frame;

%Set UserData for pushbutton1
set(handles.pushbutton1, 'UserData', data1);

%Clear button
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Find all impoly objects on axes and delete them
h = findall(gca, 'Tag', 'impoly');
delete(h);

%Update button
% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get UserData for pushbutton1
data = get(handles.pushbutton1, 'UserData');

%Get desired frame from text box and set slider to proper position
frame = str2double(get(handles.edit2,'String'));
position = frame/data.number_of_frames;
set(handles.slider1, 'Value', position);

%Call slider1 callback to update image
slider1_Callback(handles.slider1,eventdata, handles);

%Update text box
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
