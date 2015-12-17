function varargout = DrawCellEdges(varargin)
% DRAWCELLEDGES MATLAB code for DrawCellEdges.fig
%      DRAWCELLEDGES, by itself, creates a new DRAWCELLEDGES or raises the existing
%      singleton*.
%
%      H = DRAWCELLEDGES returns the handle to a new DRAWCELLEDGES or the handle to
%      the existing singleton*.
%
%      DRAWCELLEDGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAWCELLEDGES.M with the given input arguments.
%
%      DRAWCELLEDGES('Property','Value',...) creates a new DRAWCELLEDGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DrawCellEdges_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DrawCellEdges_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DrawCellEdges

% Last Modified by GUIDE v2.5 06-Aug-2015 12:22:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DrawCellEdges_OpeningFcn, ...
                   'gui_OutputFcn',  @DrawCellEdges_OutputFcn, ...
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


% --- Executes just before DrawCellEdges is made visible.
function DrawCellEdges_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DrawCellEdges (see VARARGIN)

% Choose default command line output for DrawCellEdges
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DrawCellEdges wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DrawCellEdges_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in analyze.
function analyze_Callback(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  cvname cvpath  k 

%%load parameters
bits=str2num(get(handles.bits,'string'));
rbits=2^bits;
mkdir([cvpath,'analysed']);
jj=str2num(get(handles.repeats,'string'));
j=str2num(get(handles.snr,'string'));
rsnrv=str2num(get(handles.rsnr,'string'));
len=str2num(get(handles.masksize,'string'));
bc=str2num(get(handles.Bframe,'string'));
fc=str2num(get(handles.Flframe,'string'));
allcn=str2num(get(handles.cn,'string'));
n=str2num(get(handles.bychannel,'string'));
isstackss=str2num(get(handles.stack,'string'));
sfluorescenceintensity=str2num(get(handles.sfi,'string'));
sfluoc=str2num(get(handles.sf,'string'));
sbc=str2num(get(handles.sb,'string'));
sallpara=str2num(get(handles.sallp,'string'));
noc=str2num(get(handles.sallp,'string'));

%%check the file format
format=strfind(cvname,'tif');
format=size(format);
if format ==0
    cvname3=strrep(cvname, 'lsm','xlsx');
else
    cvname3=strrep(cvname, 'tif','xlsx');
end

%%analysing 
if isstackss ==0
for k=1:jj
    num=['0' num2str(k)];
    if k==1
        numm=['0' num2str(k)];
        cvname1=cvname; 
    else
        numm=['0' num2str(k-1)];
        cvname1=strrep(cvname1, numm,num); 
    end
    

cvname2=strrep(cvname1, 'lsm','tif');
FileName=strcat(cvpath,cvname1);

testf=exist(FileName,'file');

if testf ==0
    set(handles.para,'string','Wrong: Files less than expected by parameter');
else
II=imread(FileName); 

I=II(:,:,n);

haha=figure(1);
subplot(2,3,1), subimage(I);axis off;title('original image');

%%detect the cell by a given threshold
[~, threshold] = edge(I, 'sobel');
fudgeFactor = rsnrv;
BWs = edge(I,'sobel', threshold * fudgeFactor);
subplot(2,3,2), subimage(BWs);axis off;title('binary image');

%%dilate the image
se90 = strel('line', len, 90);
se0 = strel('line', len, 0);
BWsdil = imdilate(BWs, [se90 se0]);
subplot(2,3,3), subimage(BWsdil);axis off;title('dilated image');

BWimgdfill = imfill(BWsdil, 'holes');
subplot(2,3,4), subimage(BWimgdfill);axis off;title('binary image with filled gaps');

seD = strel('diamond',1);
BWimgFinal = imerode(BWimgdfill,seD);
BWimgFinal = imerode(BWimgFinal,seD);
subplot(2,3,5), subimage(BWimgFinal);axis off;title('primary segmentation');


%%smooth the image
for i=1:j
BWimgFinal = imerode(BWimgFinal,seD);
end

subplot(2,3,6), subimage(BWimgFinal);axis off;title('deep segmented image');
%figure, imshow(BWimgFinal), title('segmented image');

saveas(gcf,[cvpath,'analysed\a',cvname2]);
gcfs=imread([cvpath,'analysed\a',cvname2]);
close(haha);
BWoutline = bwperim(BWimgFinal);
    num=find(BWimgFinal==1);
    num2=find(BWimgFinal==0);
if bc == 0
    SegoutB = zeros(size(II(:,:,1))); 
    vae=0;
else    
    SegoutB = II(:,:,bc);

    vae(k,1)=mean(SegoutB(num));
    vae(k,2)=mean(SegoutB(num2));
    vae(k,3)=vae(k,1)-vae(k,2);
end
if fc == 0
    Fimag = zeros(size(II(:,:,1))); 
    va=0;
else
    Fimag=II(:,:,fc);

    va(k,1)=mean(Fimag(num));
    va(k,2)=mean(Fimag(num2));
    va(k,3)=va(k,1)-va(k,2);
end


Fimag(BWoutline) =rbits;
SegoutB(BWoutline) =rbits;

axes(handles.axes1);
imshow(gcfs);
hh=getframe(figure(DrawCellEdges));

if sallpara == 1
    imwrite(hh.cdata,[cvpath,'analysed\ana',cvname2]);
end

if sbc==1
    imwrite(SegoutB,[cvpath,'analysed\bw',cvname2]);
end

figure(2*k);
imshow(SegoutB,'DisplayRange',[0 rbits],'Border','tight');


figure(2*k+1);
imshow(Fimag,'DisplayRange',[0 rbits],'Border','tight');
colormap('hot'); 

if sfluoc==1
ll=getframe(figure(2*k+1));
imwrite(ll.cdata,[cvpath,'analysed\fs',cvname2]);
end

end
end

if sfluorescenceintensity==1
xlswrite([cvpath,'analysed\Intensity',cvname3],{'Fluorescence','Background','SubtractedFluorescence'},1,'A1');
xlswrite([cvpath,'analysed\Intensity',cvname3],va,1,'A2');
end

else
   for k=1:jj
    
    

    cvname2=strrep(cvname, 'lsm','tif');
    FileName=strcat(cvpath,cvname);

    testf=exist(FileName,'file');

    if testf ==0
        set(handles.para,'string','Wrong: Files less than expected by parameter');
    else
    %=imread(FileName,1); 

    II=imread(FileName,allcn*(k-1)+fc);
    size(II)
    I=II(:,:,n);

    haha=figure(1);
    subplot(2,3,1), subimage(I);axis off;title('original image');
    %figure, imshow(I), title('original image');


    %text(size(I,2),size(I,1)+15, ...
    %    'Image courtesy of Alan Partin', ...
    %   'FontSize',7,'HorizontalAlignment','right');
    %text(size(I,2),size(I,1)+25, ....
    %    'University of Liverpool', ...
    %    'FontSize',7,'HorizontalAlignment','right');
    [~, threshold] = edge(I, 'sobel');
    fudgeFactor = rsnrv;
    BWs = edge(I,'sobel', threshold * fudgeFactor);
    subplot(2,3,2), subimage(BWs);axis off;title('binary image');
    %figure, imshow(BWs), title('binary gradient mask');


    se90 = strel('line', len, 90);
    se0 = strel('line', len, 0);

    BWsdil = imdilate(BWs, [se90 se0]);
    subplot(2,3,3), subimage(BWsdil);axis off;title('dilated image');
    %figure, imshow(BWsdil), title('dilated gradient mask');

    BWimgdfill = imfill(BWsdil, 'holes');
    subplot(2,3,4), subimage(BWimgdfill);axis off;title('binary image with filled gaps');
    %figure, imshow(BWimgdfill);   title('binary image with filled holes');


    %BWnobord = imclearborder(BWimgdfill, 4);
    %figure, imshow(BWnobord), title('cleared border image');
    seD = strel('diamond',1);
    %BWimgFinal = imerode(BWnobord,seD);

    BWimgFinal = imerode(BWimgdfill,seD);
    BWimgFinal = imerode(BWimgFinal,seD);
    subplot(2,3,5), subimage(BWimgFinal);axis off;title('primary segmentation');
    %figure, imshow(BWimgFinal), title('segmented image');


    for i=1:j
    BWimgFinal = imerode(BWimgFinal,seD);
    end

    subplot(2,3,6), subimage(BWimgFinal);axis off;title('deep segmented image');
    %figure, imshow(BWimgFinal), title('segmented image');
    if k ==1
    saveas(gcf,[cvpath,'analysed\a',cvname2]);
    gcfs=imread([cvpath,'analysed\a',cvname2]);
    
    
    BWoutline = bwperim(BWimgFinal);
    
    num=find(BWimgFinal==1);
    num2=find(BWimgFinal==0);
    end
    
    close(haha);
    if bc == 0
        SegoutB = zeros(I); 
        vae=0;
    else    
        SegoutB = II(:,:,bc);%imread(FileName,(noc*(k-1)+bc));
        vae(k,1)=mean(SegoutB(num));
        vae(k,2)=mean(SegoutB(num2));
        vae(k,3)=vae(k,1)-vae(k,2);
    end
    if fc == 0
        Fimag = zeros(size(II(:,:,1))); 
        va=0;
    else
        Fimag=II(:,:,fc);
        
        va(k,1)=mean(Fimag(num));
        va(k,2)=mean(Fimag(num2));
        va(k,3)=va(k,1)-va(k,2);
    end

    Fimag(BWoutline) =rbits;
    SegoutB(BWoutline) =rbits;

    %figure, imshow(Segout,'DisplayRange',[0 65536],'Border','tight');
    axes(handles.axes1);
    %imshow(SegoutB);
    imshow(gcfs);
    %hh=getframe(figure(DrawCellEdges),[48 60 800 620]);
    hh=getframe(figure(DrawCellEdges));

    if sallpara == 1 && k==1
        imwrite(hh.cdata,[cvpath,'analysed\ana',cvname2]);
    end

    if sbc==1 && k==1
        imwrite(SegoutB,[cvpath,'analysed\bw',cvname2]);
    elseif sbc==1
        imwrite(SegoutB,[cvpath,'analysed\bw',cvname2],'WriteMode','append');
    end
    
    if k==1 || k==jj
    figure(2*k);
    imshow(SegoutB,'Border','tight');
    end
    % title('outlined original image');
    
    
    figure(2*k+1);
    imshow(Fimag,'DisplayRange',[0 rbits],'Border','tight');
    colormap('hot'); 

    ll=getframe(figure(2*k+1));
    
    if sfluoc==1 && k==1
        imwrite(ll.cdata,[cvpath,'analysed\fs',cvname2]);
    elseif sfluoc==1 
        imwrite(ll.cdata,[cvpath,'analysed\fs',cvname2],'WriteMode','append');
    end

    end
    end

    if sfluorescenceintensity==1
    xlswrite([cvpath,'analysed\Intensity',cvname3],{'Fluorescence','Background','SubtractedFluorescence'},1,'A1');
    xlswrite([cvpath,'analysed\Intensity',cvname3],va,1,'A2');
    end 
    figure(100)
    plot(va(:,3))
end
%
%xlswrite([cvpath,'Intensity',cvname3],va,1,'C1');


function repeats_Callback(hObject, eventdata, handles)
% hObject    handle to repeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repeats as text
%        str2double(get(hObject,'String')) returns contents of repeats as a double


% --- Executes during object creation, after setting all properties.
function repeats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function snr_Callback(hObject, eventdata, handles)
% hObject    handle to snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of snr as text
%        str2double(get(hObject,'String')) returns contents of snr as a double


% --- Executes during object creation, after setting all properties.
function snr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bychannel_Callback(hObject, eventdata, handles)
% hObject    handle to bychannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bychannel as text
%        str2double(get(hObject,'String')) returns contents of bychannel as a double


% --- Executes during object creation, after setting all properties.
function bychannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bychannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%clc;
%clear;
%close all;
global cvname cvpath 
isstackss=str2num(get(handles.stack,'string'));
bc=str2num(get(handles.Bframe,'string'));
fc=str2num(get(handles.Flframe,'string'));
bits=str2num(get(handles.bits,'string'));
rbits=2^bits;
[cvname cvpath] = uigetfile({'*.lsm';'*.tif'},'File Selector');
FileName=strcat(cvpath,cvname);
img=imread(FileName);

siimg=size(img);
axes(handles.axes1);
imshow(img(:,:,1),'DisplayRange',[0 rbits],'Border','tight');



function Flframe_Callback(hObject, eventdata, handles)
% hObject    handle to Flframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Flframe as text
%        str2double(get(hObject,'String')) returns contents of Flframe as a double


% --- Executes during object creation, after setting all properties.
function Flframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Flframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Bframe_Callback(hObject, eventdata, handles)
% hObject    handle to Bframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bframe as text
%        str2double(get(hObject,'String')) returns contents of Bframe as a double


% --- Executes during object creation, after setting all properties.
function Bframe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function masksize_Callback(hObject, eventdata, handles)
% hObject    handle to masksize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of masksize as text
%        str2double(get(hObject,'String')) returns contents of masksize as a double


% --- Executes during object creation, after setting all properties.
function masksize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to masksize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bits_Callback(hObject, eventdata, handles)
% hObject    handle to bits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bits as text
%        str2double(get(hObject,'String')) returns contents of bits as a double


% --- Executes during object creation, after setting all properties.
function bits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rsnr_Callback(hObject, eventdata, handles)
% hObject    handle to rsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rsnr as text
%        str2double(get(hObject,'String')) returns contents of rsnr as a double


% --- Executes during object creation, after setting all properties.
function rsnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closefig.
function closefig_Callback(hObject, eventdata, handles)
% hObject    handle to closefig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
%global k
%for i=2:(2*k+1)
%close(figure(i))
%end
close all



function para_Callback(hObject, eventdata, handles)
% hObject    handle to para (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of para as text
%        str2double(get(hObject,'String')) returns contents of para as a double


% --- Executes during object creation, after setting all properties.
function para_CreateFcn(hObject, eventdata, handles)
% hObject    handle to para (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function allpara_Callback(hObject, eventdata, handles)
% hObject    handle to allpara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of allpara as text
%        str2double(get(hObject,'String')) returns contents of allpara as a double


% --- Executes during object creation, after setting all properties.
function allpara_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allpara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sf_Callback(hObject, eventdata, handles)
% hObject    handle to sf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sf as text
%        str2double(get(hObject,'String')) returns contents of sf as a double


% --- Executes during object creation, after setting all properties.
function sf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sb_Callback(hObject, eventdata, handles)
% hObject    handle to sb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sb as text
%        str2double(get(hObject,'String')) returns contents of sb as a double


% --- Executes during object creation, after setting all properties.
function sb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sallp_Callback(hObject, eventdata, handles)
% hObject    handle to sallp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sallp as text
%        str2double(get(hObject,'String')) returns contents of sallp as a double


% --- Executes during object creation, after setting all properties.
function sallp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sallp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sfi_Callback(hObject, eventdata, handles)
% hObject    handle to sfi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sfi as text
%        str2double(get(hObject,'String')) returns contents of sfi as a double


% --- Executes during object creation, after setting all properties.
function sfi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sfi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stack_Callback(hObject, eventdata, handles)
% hObject    handle to stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stack as text
%        str2double(get(hObject,'String')) returns contents of stack as a double


% --- Executes during object creation, after setting all properties.
function stack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cn_Callback(hObject, eventdata, handles)
% hObject    handle to cn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cn as text
%        str2double(get(hObject,'String')) returns contents of cn as a double


% --- Executes during object creation, after setting all properties.
function cn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
