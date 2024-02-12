%% Grading of Diabetic Retinopathy using Deep Learning - TESTING

clear all
close all
clc

%% Read Test Image

[filename,pathname] = uigetfile('*.jpg;*.tif;*.png;*.jpeg;*.bmp;*.pgm;*.gif','pick an imgae');
file = fullfile(pathname,filename);

   Img = imread(file);
figure,
imshow(Img);
title('Test Image');

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

figure,imshow(N)
title('Noise Removal using Median Filter')

% Contrast Enhancement

R1=adapthisteq(N(:,:,1),'clipLimit',0.002);
G1=adapthisteq(N(:,:,2),'clipLimit',0.002);
B1=adapthisteq(N(:,:,3),'clipLimit',0.002);

ER=cat(3,R1,G1,B1);

figure,imshow(ER)
title('Image Quality Enhancement using CLAHE')

% Resizing

inputSize=[227 227 3];

Img1 = imresize(ER,inputSize(1:2));
figure,imshow(Img1);
title('Resized Image');

%% DR Grading Using CNN

% Load Trained Model

load DR_Train

msgbox('Trained Network Model Was Loaded');

% Classification

[YPred,scores] = classify(netTransfer,Img1);

figure,
imshow(Img1);
title('DR Grading Result Using CNN Model');

text(10,30,YPred,'Color','b','fontname','Harlow Solid','FontWeight','bold','FontSize',16);

predicted_score=max(scores);

pause(1);

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

