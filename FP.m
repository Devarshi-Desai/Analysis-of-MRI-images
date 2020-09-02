
%% Starting with a clean slate
clc
clear all
close all
%imtool

%% Specifying data file directory

filefolder=fullfile(pwd, 'Matlab_Project');
files=dir(fullfile(filefolder, '*.dcm'));
FileNames={files.name};

%% Examine file header (metadata from dicom stack)

info=dicominfo(fullfile(filefolder,FileNames{1}));

%Info on size extracted from metadata
voxel_size=[info.PixelSpacing;info.SliceThickness]';

% Get file information
I=dicominfo(fullfile(filefolder,FileNames{1}))
class_I=class(I);
size_I=size(I);
numImages=length(FileNames);

%% Reading images
hWaitBar=waitbar(0,'reading dicom files');

%create array
%mri=zeros(size_I(1),size_I(2), numImages, class_I);

for i=length(FileNames):-1:1
    fname=fullfile(filefolder,FileNames{i});
    mri(:,:,i)=uint16(dicomread(fname));
    waitbar((length(FileNames)-i+1)/length(FileNames))
end
delete(hWaitBar)
%% Montage
imtool close all
minMRI=min(mri(:));
maxMRI=max(mri(:));
montage(reshape(uint16(mri),[size(mri,1),size(mri,2),1,size(mri,3)]));
set(gca,'clim',[0,100]);

%% Selecting one slice
im=mri(:,:,30);
max_level=double(max(im(:)));
imt=imtool(im,[0,max_level]);
%% 
mriTemp=mri(:,:,30);
mriTemp(197:end,:)=0;
imshow(imadjust(mriTemp));
%% Thresholding
lb=80;          %lower threshold
ub=200;         %upper threshold
mriAdjust=mri;
mriAdjust(mriAdjust<=lb)=0;
mriAdjust(mriAdjust>=ub)=0;
mriAdjust(195:end,:,:)=0;
bw=logical(mriAdjust);
imshow(bw(:,:,30));
%% 
figure
nhood=ones([3 2 2]);
bw=imopen(bw,nhood);
imshow(bw(:,:,30));
%% Blob analysis
L=bwlabeln(bw);
stats=regionprops(L,'Area','Centroid');
LL=L(:,:,30)+1;
cmap=hsv(length(stats));cmap=[0 0 0;cmap];
LL=cmap(LL, :);LL=reshape(LL,[size_I, 3]);
figure
imshow(LL);
edit('brain scan')
%% selecting largest blob
A=[stats.Area];
biggest=find(A==max(A));
mriAdjust(L~=biggest)=0;
imA=imadjust(mriAdjust(:,:,30));
imshow(imA);
drawnow;
shg;
edit('brainscan')