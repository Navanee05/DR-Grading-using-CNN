function varargout = Final(varargin)
% FINAL MATLAB code for Final.fig
%      FINAL, by itself, creates a new FINAL or raises the existing
%      singleton*.
%
%      H = FINAL returns the handle to a new FINAL or the handle to
%      the existing singleton*.
%
%      FINAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINAL.M with the given input arguments.
%
%      FINAL('Property','Value',...) creates a new FINAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Final_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Final_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Final

% Last Modified by GUIDE v2.5 23-Aug-2023 08:13:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Final_OpeningFcn, ...
                   'gui_OutputFcn',  @Final_OutputFcn, ...
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


% --- Executes just before Final is made visible.
function Final_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Final (see VARARGIN)

% Choose default command line output for Final
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Final wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Final_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1

%% Read Test Image

[filename,pathname] = uigetfile('*.jpg;*.tif;*.png;*.jpeg;*.bmp;*.pgm;*.gif','pick an imgae');
file = fullfile(pathname,filename);

   Img = imread(file);
axes(handles.axes1);
imshow(Img);
title('Test Image');

handles.Img = Img;


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

Img = handles.Img;

%% Preprocessing

if size(Img,3) == 3
    Img = Img;
else
    Img = cat(3,Img,Img,Img);
end

% Noise Removal

N1=medfilt2(Img(:,:,1));
N2=medfilt2(Img(:,:,2));
N3=medfilt2(Img(:,:,3));

N=cat(3,N1,N2,N3);

axes(handles.axes2);
imshow(N)
title('Noise Removal using Median Filter')

% Contrast Enhancement

R1=adapthisteq(N(:,:,1),'clipLimit',0.002);
G1=adapthisteq(N(:,:,2),'clipLimit',0.002);
B1=adapthisteq(N(:,:,3),'clipLimit',0.002);

ER=cat(3,R1,G1,B1);

axes(handles.axes3);imshow(ER)
title('Image Quality Enhancement using CLAHE')

% Resizing

inputSize=[227 227 3];

Img1 = imresize(ER,inputSize(1:2));

handles.Img1 = Img1;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3

Img = handles.Img;
Img1 = handles.Img1;

%% DR Grading Using CNN

% Load Trained Model

load DR_Train

msgbox('Trained Network Model Was Loaded');

% Classification

[YPred,scores] = classify(netTransfer,Img1);

axes(handles.axes4);
imshow(Img);
title('DR Grading Result Using CNN Model');

text(10,90,YPred,'Color','b','fontname','Harlow Solid','FontWeight','bold','FontSize',16);


% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4

%% Performance Analysis

imds = imageDatastore('PA', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
YTest = imds.Labels;

%% Load Trained Network Model

load DR_Train

L= netTransfer.Layers(1,1);
inputSize=L(1).InputSize;

augimdsValidation = augmentedImageDatastore(inputSize(1:2),imds);

%% Classification

[YPred,scores] = classify(netTransfer,augimdsValidation);

idx = randperm(numel(imds.Files));

figure('name','DR Grading Results with Predicred Score');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
for i = 1:12
    subplot(3,4,i)
    I = readimage(imds,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label) + ", " + num2str(100*max(scores(idx(i),:)),3) + "%");
    
end

figure,
plotconfusion(YTest,YPred)

pause(1);

[c_matrix,Result,RefereceResult]= confusionpre.getMatrix(uint8(YTest),uint8(YPred));

Accuracy=Result.Accuracy;
Error=Result.Error;
Precision=Result.Precision;
Specificity=Result.Specificity;
Sensitivity=Result.Sensitivity;
F_score=Result.F1_score;
MatthewsCorrelationCoefficient=Result.MatthewsCorrelationCoefficient;

PM=[Accuracy Error Precision Specificity Sensitivity F_score MatthewsCorrelationCoefficient];
f = figure('name','Performance Analysis - CNN','Position',[500 400 400 260]);
cnames = {'Performance in %'};
rnames={'Accuracy','Error','Precision','Specificity','Sensitivity','F1 Score','MCC'};
t = uitable('Parent',f,'Data',PM','ColumnName',cnames, 'RowName',rnames,... 
               'Position',[30 50 300 180]); 
pause(1);

msgbox('Completed');


% Update handles structure
guidata(hObject, handles);

