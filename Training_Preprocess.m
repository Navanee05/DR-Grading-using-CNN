%% Database Preprocessing 

clear all
close all
clc

d1=1;
addpath('Database\4');
srcFiles = dir('Database\4\*.jpg');  
for i = 1 : length(srcFiles)
   filename = strcat('Database\4\',srcFiles(i).name)
   TI = imread(filename);

   if size(TI,3) == 3
  
       TI=TI;
   else
       TI=cat(3,TI,TI,TI);
   end
%% Preprocessing

% Noise Removal

N1=medfilt2(TI(:,:,1));
N2=medfilt2(TI(:,:,2));
N3=medfilt2(TI(:,:,3));

N=cat(3,N1,N2,N3);

% Contrast Enhancement

R1=adapthisteq(N(:,:,1),'clipLimit',0.002);
G1=adapthisteq(N(:,:,2),'clipLimit',0.002);
B1=adapthisteq(N(:,:,3),'clipLimit',0.002);

ER=cat(3,R1,G1,B1);

R=imresize(ER,[224 224]);

imwrite(R,['Dataset\Grade 4\G4',num2str(d1),'.jpg']);

d1=d1+1;
end

msgbox('Completed');

