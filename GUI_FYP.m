function varargout = GUI_FYP(varargin)
% GUI_FYP MATLAB code for GUI_FYP.fig
%      GUI_FYP, by itself, creates a new GUI_FYP or raises the existing
%      singleton*.
%
%      H = GUI_FYP returns the handle to a new GUI_FYP or the handle to
%      the existing singleton*.
%
%      GUI_FYP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FYP.M with the given input arguments.
%
%      GUI_FYP('Property','Value',...) creates a new GUI_FYP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_FYP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_FYP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_FYP

% Last Modified by GUIDE v2.5 06-Jan-2021 16:34:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_FYP_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_FYP_OutputFcn, ...
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


% --- Executes just before GUI_FYP is made visible.
function GUI_FYP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_FYP (see VARARGIN)

% Choose default command line output for GUI_FYP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_FYP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_FYP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadDataOne.
function LoadDataOne_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDataOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% LOAD DATA - BEGINNING OF SCRIPT

SampleName1 = input('Enter the data file to load in (remember to use quotation marks): ');
handles.SampleName1 = SampleName1;
guidata(hObject, handles);

msgbox('The data has now been selected and ready to be used.')

%% LOAD DATA - END OF SCRIPT


% --- Executes on button press in QUSButtonOne.
function QUSButtonOne_Callback(hObject, eventdata, handles)
% hObject    handle to QUSButtonOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% QUS IMAGE ACQUISITION - BEGINNING OF SCRIPT

%% Section 1 - Select the ROI
        
addpath("\Users" + "\adamj" + "\OneDrive" + "\Documents" + "\QUSGUI" + "\MatlabSolvingEquations")
addpath("\Users" + "\adamj" + "\OneDrive" + "\Documents" + "\QUSGUI" + "\Adam" + "\Data4Nov")
addpath("\Users" + "\adamj" + "\OneDrive" + "\Documents" + "\QUSGUI" + "\Adam" + "\Data5Nov(16.1V)" + "\Liver")
addpath("\Users" + "\adamj" + "\OneDrive" + "\Documents" + "\QUSGUI" + "\Adam" + "\Data5Nov(16.1V)" + "\Gizzard")
        
SampleName1 = handles.SampleName1;
tis_in = SampleName1 + ".mat";
tis_load = load(tis_in);
tis_data = tis_load.RcvData{1};
 
for i = input('Enter the number of frames to average over (*Max = 100): ')
    if i <= 0
        error('Number of frames must be between 1-100')
        return
    elseif i > 100
        error('Number of frames must be between 1-100')
        return
    else
        f_num = i;
    end
end        % NB: More frames will improve image quality, but increase formation time!

tic

for f = 1:f_num % f_num is the number of frames selected by the user
        DataTIS(:,:,f) = tis_data(:,40:90,f); % Isolate the 50 elements and stores the results for every frame  
        comp_liv(:,:,f) = hilbert(DataTIS(:,:,f)); % Hilbert transform (NB: result is complex)
        env_liv = abs(comp_liv);
        env_db_liv = 20*log10(env_liv); % Log compression
        env_db_liv = env_db_liv-max(max(env_db_liv));   % Normalize    11    
end

env_db_liv_avg = mean(env_db_liv,3); % Averaging over the frames reduces the noise. The 3 means it will average over the 3rd dimension

tis_in_csv = SampleName1 + ".csv";
csvwrite(tis_in_csv, env_db_liv_avg)
env_db_liv_avg_csv = xlsread(tis_in_csv);
  
% A lot of the rows in the data from the 5th of November are all zeros, as data acquisition only
% runs for a certain period of time. Want to find where this occurs and
% discard this data when eventually plotting

row_has_all_zeros = ~any(DataTIS, 2);
indices = find(row_has_all_zeros);
first_index = indices(1); 
 
ref_name = SampleName1 + "REF";
ref_load = load(ref_name + ".mat");
ref_data = double(ref_load.RcvData{1});
       
for f = 1%:length(tis_data(1,1,:)) % for loop will iterate over every frame of data 
    ref(:,:,f) = double(tis_data(:,40:90,f)); % Isolate the 50 elements and stores the results for every frame  
%     comp_liv1(:,:,f1) = hilbert(DataTIS1(:,:,f1));
%     env_liv1 = abs(comp_liv1); % Hilbert transform (NB: result is complex) 
%     env_db_liv1 = 20*log10(env_liv1); % Log compression
%     env_db_liv1 = env_db_liv1-max(max(env_db_liv1));   % Normalize    
end
          
%W_save = dlmread('W_comp' + tis_in); 

%Step 2: Preparing B-mode image
ROIFlag = 0; %=0 if no ROI index data, =1 If index data is saved
ROI_size = 3000E-6;
L = 1000E-6;
num_params = 9;
samples = 1:length(tis_data(:,1,1));
lambda = 1540/7.6E6;
time = samples*lambda/(4*1540);
time_T = transpose(time);
res_dB = 80;                % Dynamic range in final image, i.e. how many dB of resolution to display
ftsize = 12;                % Set fontsize for plot in final image
SoS = 1540;                 %Speed of Sound
elmt_width = 0.27E-3;        %Size of verasonics array element
x_axis = (length(DataTIS(1,:,1))-1)*elmt_width*1000;          % x axis is the number of elements * element size
y_axis = (time(1,end)-time(1,1))*SoS/2*1000;     %Y axis is full length of sample
x_plot = [0 x_axis];                %define x,y vectors for use in imagesc
y_plot = [0 y_axis];  
depth = (y_axis / length(DataTIS(:,1,1))) * first_index;  %first index can be commented out if not stated above
width = (x_axis / length(DataTIS(1,:,1))) * 50;

% Either use index's already made or ask user to
if ROIFlag ==1
    ROI_in = SampleName1 +num2str(m) +"ROI.csv";
    ROI = readmatrix(ROI_in);
    ind_start = floor(ROI(2));
    ind_end = floor(ROI(2) + ROI(4));
else
    %figure
    axes(handles.axes1);
    imagesc(env_db_liv_avg_csv,[-res_dB 0]);
    colormap('gray');
    c=colorbar;
    title('B-mode Image')
    ylabel('Index Number')
    xlabel('Element Number')
    ylim([0 first_index])
    xticks(0:5:50)
    yticks(0:300:first_index)
    
    set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')

    set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))
    %xlim([0 depth])
    toc
    
    ROI = getrect();
    ind_start = floor(ROI(2));
    ind_end = floor(ROI(2) + ROI(4));
    fileROI = SampleName1 +"ROI.csv";
    dlmwrite(fileROI,ROI)
end 

%Step 3 now we have the information for the Entire ROI size
% we want to window the data into 3mm by 3mm sections and calculate
% parameters

ROItime = time_T(ind_start:ind_end,1);   %should use time index instead
ROIdata = double(env_db_liv_avg_csv(ind_start:ind_end,1:end)); %should I use env_db_liv instead
ROIDATASAVE = env_db_liv_avg_csv(ind_start:ind_end,1:end);
file_out = SampleName1 +"ROIDATA.csv";
dlmwrite(file_out,ROIDATASAVE)        
        
tic
%Get all params function
Results = get_all_params(ROItime,ROIdata,ref,num_params);
comp_time = toc;
ROIsize = (ROItime(end)-ROItime(1))*1540/2*1000;

% file_out = 'PrelimResults' + tis_in_csv;
% dlmwrite(file_out,Results)
%        
%         
% % res_in = 'PrelimResults' + tis_in_csv;
% Results = load(file_out);
% Results = reshape(Results,[length(Results(:,1,1)),10,num_params]);
t_max = length(Results(:,1,1))+2;
x_max = length(Results(1,:,1))+2;
new_Results = ones(t_max,x_max,num_params+4);
  
for i=1:num_params
    for t = 1:t_max
        if t==1
            for x = 1:x_max
                if x==1
                    new_Results(t,x,i)=Results(t,x,i);
                elseif x==2
                    new_Results(t,x,i) = (Results(t,x,i)+Results(t,x-1,i))/2;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t,x-2,i)+Results(t,x-1,i))/2;
                elseif x==x_max
                    new_Results(t,x,i) = Results(t,x-2,i);
                else
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t,x-2,i)+Results(t,x-1,i))/3;
                end
            end
          elseif t==2
            for x= 1:x_max
                if x==1
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t-1,x,i))/2;
                elseif x==2
                    new_Results(t,x,i) = (Results(t,x,i)+Results(t,x-1,i)+Results(t-1,x,i)+Results(t-1,x-1,i))/4;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t,x-2,i)+Results(t,x-1,i)+Results(t-1,x-2,i)+Results(t-1,x-1,i))/4;
                elseif x==x_max
                    new_Results(t,x,i) = (Results(t-1,x-2,i)+Results(t,x-2,i))/2;
                else
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t,x-2,i)+Results(t,x-1,i)+Results(t-1,x,i)+Results(t-1,x-2,i)+Results(t-1,x-1,i))/6;
                end
            end
          elseif t==t_max
            for x= 1:x_max
                if x==1
                    new_Results(t,x,i)=Results(t-2,x,i);
                elseif x==2
                    new_Results(t,x,i) = (Results(t-2,x,i)+Results(t-2,x-1,i))/2;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t-2,x-2,i)+Results(t-2,x-1,i))/2;
                elseif x==x_max
                    new_Results(t,x,i) = Results(t-2,x-2,i);
                else
                    new_Results(t,x,i)=(Results(t-2,x,i)+Results(t-2,x-2,i)+Results(t-2,x-1,i))/3;
                end
            end

        elseif t==t_max-1
            for x= 1:x_max
                if x==1
                    new_Results(t,x,i)=(Results(t-2,x,i)+Results(t-1,x,i))/2;
                elseif x==2
                    new_Results(t,x,i) = (Results(t-2,x,i)+Results(t-2,x-1,i)+Results(t-1,x,i)+Results(t-1,x-1,i))/4;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t-2,x-2,i)+Results(t-2,x-1,i)+Results(t-1,x-2,i)+Results(t-1,x-1,i))/4;
                elseif x==x_max
                    new_Results(t,x,i) = (Results(t-2,x-2,i)+Results(t-1,x-2,i))/2;
                else
                    new_Results(t,x,i)=(Results(t-2,x,i)+Results(t-2,x-2,i)+Results(t-2,x-1,i)+Results(t-1,x,i)+Results(t-1,x-2,i)+Results(t-1,x-1,i))/6;
                end
            end

        else
            for x= 1:x_max
                if x==1
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t-1,x,i)+Results(t-2,x,i))/3;
                elseif x==2
                    new_Results(t,x,i) = (Results(t,x,i)+Results(t-1,x,i)+Results(t-2,x,i)+Results(t,x-1,i)+Results(t-1,x-1,i)+Results(t-2,x-1,i))/6;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t,x-2,i)+Results(t-1,x-2,i)+Results(t-2,x-2,i)+Results(t,x-1,i)+Results(t-1,x-1,i)+Results(t-2,x-1,i))/6;
                elseif x==x_max
                    new_Results(t,x,i) = (Results(t-2,x-2,i)+Results(t-1,x-2,i)+Results(t,x-2,i))/3;
                else
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t-1,x,i)+Results(t-2,x,i)+Results(t,x-1,i)+Results(t-1,x-1,i)+Results(t-2,x-1,i)+Results(t,x-2,i)+Results(t-1,x-2,i)+Results(t-2,x-2,i))/9;
                end
            end
        end
    end
end
   
%     for t=1:t_max
%         for x=1:x_max
%             [new_Results(t,x,10),new_Results(t,x,11),new_Results(t,x,12)] = find_parameters(new_Results(t,x,6),new_Results(t,x,7),new_Results(t,x,1));
%             new_Results(t,x,13) = new_Results(t,x,10)/(new_Results(t,x,11)*sqrt(new_Results(t,x,12)));
%         end
%     end

% res_out = 'FinalResults' + tis_in;
% dlmwrite(res_out,new_Results)

%% Section 2 - Obtain the QUS images

addpath(pwd)
ROI = load(fileROI);
        
% res_out = 'FinalResults' + tis_in;
% new_Results = load(res_out);
new_Results = reshape(new_Results,length(new_Results(:,1,1)),12,[]);
py_axis = length(new_Results(:,1,1)); 
py_shift = ((time_T(end,1)-ROItime(end))*SoS)/2*1000;
py_start = y_axis - py_shift - py_axis;     
     
pix_x = x_axis/(length(new_Results(1,:,1))+1);
pix_y = py_axis/(length(new_Results(:,1,1))+1);
x_pix = [0.5*pix_x x_axis-0.5*pix_x];
y_pix = [py_start+0.5*pix_y py_axis+py_start-0.5*pix_x];
y_disp = [0 (y_axis*SoS/2*1000)];

SampleName_string = string({SampleName1,SampleName1,SampleName1,SampleName1,SampleName1,...
                     SampleName1,SampleName1,SampleName1,SampleName1,...
                     SampleName1,SampleName1,SampleName1,SampleName1});

param_names =["Mean","Standard Deviation","Skewness","Kurtosis","6th Moment",...
              "X-Stat", "U-Stat","Scatterer Diameter","Acoustic Concentration",...
              "Epsilon","Sigma","Alpha (Scatter Clustering Parameter)","k (Ratio of Diffuse to Coherent Power)"];

col_vals = {[0,4000],[0,3],[-1.5,1],[2,7],[0,20000],...
            [0, 0.5],[-0.5, 0],[15,60],[-150,50],...
            [0,20],[20,5000],[0.05,0.8],[0,0.03]};

for f=1:13
    min_arr2(f) = min(min(new_Results(:,:,f)));
    max_arr2(f) = max(max(new_Results(:,:,f)));
        
    figure
        
    ax1 = axes;

    imagesc(x_plot,y_plot,env_db_liv_avg_csv,'Parent',ax1,[-res_dB 0]);
    set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')
    
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))
    axis('image')
    colormap(ax1,'gray');
    c=colorbar;
    c.Visible = 'off';
    ax2 = axes;
    if f==5
        imagesc(x_pix,y_pix,log(new_Results(:,:,f)),'Parent',ax2,'alphadata',0.5,col_vals{f});
        set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')
    
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))

    else
        imagesc(x_pix,y_pix,new_Results(:,:,f),'Parent',ax2,'alphadata',0.5,col_vals{f});
        set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')
    
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))

    end
    if f==8
        colormap(ax2,jet);
    elseif f==12
        colormap(ax2,jet);
    else
        colormap(ax2,flipud(jet));
    end
    ax2.Visible = 'off';
      
    linkaxes([ax1 ax2]);
        
    colorbar;
    %for m = 1:13
    savestring = append(param_names{f},'(data1).png');     %" Tumor Phantom";
    titlestring = append(param_names{f});
    title(ax1,titlestring)    %SampleName + ' ' + 
    ylabel(ax1,'Depth (mm)')
    xlabel(ax1,'Width (mm)')
    xlim([0 width])
    ylim([0 depth])
    a1 = get(gca,'XTickLabel');
    axis('image')
    %set(gca,'XTickLabel',a1,'FontName','Times','fontsize',20)

    set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')
    
    set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))

    saveas(gcf,savestring)
%     destination_folder = 'C:/Users/adamj/OneDrive/Documents/QUSGUI/QUS images';
%     movefile(titlestring,destination_folder);
end

clear all

msgbox('The QUS images have now been generated. Use the drop down menu to access the images.')

%% QUS IMAGE ACQUISITION - END OF SCRIPT


% --- Executes on button press in LoadDataTwo.
function LoadDataTwo_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDataTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% LOAD DATA - BEGINNING OF SCRIPT

SampleName2 = input('Enter the data file to load in (remember to use quotation marks): ');
handles.SampleName2 = SampleName2;
guidata(hObject, handles);

msgbox('The data has now been selected and ready to be used.')

%% LOAD DATA - END OF SCRIPT


% --- Executes on button press in QUSButtonTwo.
function QUSButtonTwo_Callback(hObject, eventdata, handles)
% hObject    handle to QUSButtonTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% QUS IMAGE ACQUISITION - BEGINNING OF SCRIPT

%% Section 1 - Select the ROI

%clear all   % this needs to go at the end of the code to make it GUI compatible
        
addpath("\Users" + "\adamj" + "\OneDrive" + "\Documents" + "\QUSGUI" + "\MatlabSolvingEquations")
addpath("\Users" + "\adamj" + "\OneDrive" + "\Documents" + "\QUSGUI" + "\Adam" + "\Data4Nov")
addpath("\Users" + "\adamj" + "\OneDrive" + "\Documents" + "\QUSGUI" + "\Adam" + "\Data5Nov(16.1V)" + "\Liver")
addpath("\Users" + "\adamj" + "\OneDrive" + "\Documents" + "\QUSGUI" + "\Adam" + "\Data5Nov(16.1V)" + "\Gizzard")
        
%SampleName = input('Enter the data file to load in (mind to use quotation marks): ');
SampleName2 = handles.SampleName2;
%SampleName1 = 'Liver_1';
tis_in = SampleName2 + ".mat";
tis_load = load(tis_in);
tis_data = tis_load.RcvData{1};
 
for i = input('Enter the number of frames to average over (*Max = 100): ')
    if i <= 0
        error('Number of frames must be between 1-100')
        return
    elseif i > 100
        error('Number of frames must be between 1-100')
        return
    else
        f_num = i;
    end
end        % NB: More frames will improve image quality, but increase formation time!

tic

for f = 1:f_num
        DataTIS(:,:,f) = tis_data(:,40:90,f); % Isolate the 50 elements and stores the results for every frame  
        comp_liv(:,:,f) = hilbert(DataTIS(:,:,f));
        env_liv = abs(comp_liv); % Hilbert transform (NB: result is complex) 
        env_db_liv = 20*log10(env_liv); % Log compression
        env_db_liv = env_db_liv-max(max(env_db_liv));   % Normalize    11    
end

env_db_liv_avg = mean(env_db_liv,3); % Averaging over the frames reduces the noise. The 3 means it will average over the 3rd dimension

tis_in_csv = SampleName2 + ".csv";
csvwrite(tis_in_csv, env_db_liv_avg)
env_db_liv_avg_csv = xlsread(tis_in_csv);

   
% A lot of the rows in the data from the 5th of November are all zeros, as data acquisition only
% runs for a certain period of time. Want to find where this occurs and
% discard this data when eventually plotting

row_has_all_zeros = ~any(DataTIS, 2);
indices = find(row_has_all_zeros);
first_index = indices(1); 
 
ref_name = SampleName2 + "REF";
ref_load = load(ref_name + ".mat");
ref_data = double(ref_load.RcvData{1});
       
for f = 1%:length(tis_data(1,1,:)) % for loop will iterate over every frame of data 
    ref(:,:,f) = double(tis_data(:,40:90,f)); % Isolate the 50 elements and stores the results for every frame  
%     comp_liv1(:,:,f1) = hilbert(DataTIS1(:,:,f1));
%     env_liv1 = abs(comp_liv1); % Hilbert transform (NB: result is complex) 
%     env_db_liv1 = 20*log10(env_liv1); % Log compression
%     env_db_liv1 = env_db_liv1-max(max(env_db_liv1));   % Normalize    
end
          
%W_save = dlmread('W_comp' + tis_in); 

%Step 2: Preparing B-mode image
ROIFlag = 0; %=0 if no ROI index data, =1 If index data is saved
ROI_size = 3000E-6;
L = 1000E-6;
num_params = 9;
samples = 1:length(tis_data(:,1,1));
lambda = 1540/7.6E6;
time = samples*lambda/(4*1540);
time_T = transpose(time);
res_dB = 80;                % Dynamic range in final image, i.e. how many dB of resolution to display
ftsize = 12;                % Set fontsize for plot in final image
SoS = 1540;                 %Speed of Sound
elmt_width = 0.27E-3;        %Size of verasonics array element
x_axis = (length(DataTIS(1,:,1))-1)*elmt_width*1000;          % x axis is the number of elements * element size
y_axis = (time(1,end)-time(1,1))*SoS/2*1000;     %Y axis is full length of sample
x_plot = [0 x_axis];                %define x,y vectors for use in imagesc
y_plot = [0 y_axis];  
depth = (y_axis / length(DataTIS(:,1,1))) * first_index;  %first index can be commented out if not stated above
width = (x_axis / length(DataTIS(1,:,1))) * 50;

% Either use index's already made or ask user to
if ROIFlag ==1
    ROI_in = SampleName2 +num2str(m) +"ROI.csv";
    ROI = readmatrix(ROI_in);
    ind_start = floor(ROI(2));
    ind_end = floor(ROI(2) + ROI(4));
else
    %figure
    imagesc(env_db_liv_avg_csv,[-res_dB 0]);
    axes(handles.axes2);
    colormap('gray');
    %axis('image');
    c=colorbar;
    title('B-mode Image')
    ylabel('Index Number')
    xlabel('Element Number')
    ylim([0 first_index])
    xticks(0:5:50)
    yticks(0:300:first_index)
    
    set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')

    set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))
    %xlim([0 depth])
    toc
    
    ROI = getrect();
    ind_start = floor(ROI(2));
    ind_end = floor(ROI(2) + ROI(4));
    fileROI = SampleName2 +"ROI.csv";
    dlmwrite(fileROI,ROI)
end 

%Step 3 now we have the information for the Entire ROI size
% we want to window the data into 3mm by 3mm sections and calculate
% parameters

ROItime = time_T(ind_start:ind_end,1);   %should use time index instead
ROIdata = double(env_db_liv_avg_csv(ind_start:ind_end,1:end)); %should I use env_db_liv instead
ROIDATASAVE = env_db_liv_avg_csv(ind_start:ind_end,1:end);
file_out = SampleName2 +"ROIDATA.csv";
dlmwrite(file_out,ROIDATASAVE)        
        
tic
%Get all params function
Results = get_all_params(ROItime,ROIdata,ref,num_params);
comp_time = toc;
ROIsize = (ROItime(end)-ROItime(1))*1540/2*1000;

% file_out = 'PrelimResults' + tis_in_csv;
% dlmwrite(file_out,Results)
%        
%         
% % res_in = 'PrelimResults' + tis_in_csv;
% Results = load(file_out);
% Results = reshape(Results,[length(Results(:,1,1)),10,num_params]);
t_max = length(Results(:,1,1))+2;
x_max = length(Results(1,:,1))+2;
new_Results = ones(t_max,x_max,num_params+4);
  
for i=1:num_params
    for t = 1:t_max
        if t==1
            for x = 1:x_max
                if x==1
                    new_Results(t,x,i)=Results(t,x,i);
                elseif x==2
                    new_Results(t,x,i) = (Results(t,x,i)+Results(t,x-1,i))/2;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t,x-2,i)+Results(t,x-1,i))/2;
                elseif x==x_max
                    new_Results(t,x,i) = Results(t,x-2,i);
                else
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t,x-2,i)+Results(t,x-1,i))/3;
                end
            end
          elseif t==2
            for x= 1:x_max
                if x==1
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t-1,x,i))/2;
                elseif x==2
                    new_Results(t,x,i) = (Results(t,x,i)+Results(t,x-1,i)+Results(t-1,x,i)+Results(t-1,x-1,i))/4;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t,x-2,i)+Results(t,x-1,i)+Results(t-1,x-2,i)+Results(t-1,x-1,i))/4;
                elseif x==x_max
                    new_Results(t,x,i) = (Results(t-1,x-2,i)+Results(t,x-2,i))/2;
                else
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t,x-2,i)+Results(t,x-1,i)+Results(t-1,x,i)+Results(t-1,x-2,i)+Results(t-1,x-1,i))/6;
                end
            end
          elseif t==t_max
            for x= 1:x_max
                if x==1
                    new_Results(t,x,i)=Results(t-2,x,i);
                elseif x==2
                    new_Results(t,x,i) = (Results(t-2,x,i)+Results(t-2,x-1,i))/2;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t-2,x-2,i)+Results(t-2,x-1,i))/2;
                elseif x==x_max
                    new_Results(t,x,i) = Results(t-2,x-2,i);
                else
                    new_Results(t,x,i)=(Results(t-2,x,i)+Results(t-2,x-2,i)+Results(t-2,x-1,i))/3;
                end
            end

        elseif t==t_max-1
            for x= 1:x_max
                if x==1
                    new_Results(t,x,i)=(Results(t-2,x,i)+Results(t-1,x,i))/2;
                elseif x==2
                    new_Results(t,x,i) = (Results(t-2,x,i)+Results(t-2,x-1,i)+Results(t-1,x,i)+Results(t-1,x-1,i))/4;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t-2,x-2,i)+Results(t-2,x-1,i)+Results(t-1,x-2,i)+Results(t-1,x-1,i))/4;
                elseif x==x_max
                    new_Results(t,x,i) = (Results(t-2,x-2,i)+Results(t-1,x-2,i))/2;
                else
                    new_Results(t,x,i)=(Results(t-2,x,i)+Results(t-2,x-2,i)+Results(t-2,x-1,i)+Results(t-1,x,i)+Results(t-1,x-2,i)+Results(t-1,x-1,i))/6;
                end
            end

        else
            for x= 1:x_max
                if x==1
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t-1,x,i)+Results(t-2,x,i))/3;
                elseif x==2
                    new_Results(t,x,i) = (Results(t,x,i)+Results(t-1,x,i)+Results(t-2,x,i)+Results(t,x-1,i)+Results(t-1,x-1,i)+Results(t-2,x-1,i))/6;
                elseif x==x_max-1
                    new_Results(t,x,i) = (Results(t,x-2,i)+Results(t-1,x-2,i)+Results(t-2,x-2,i)+Results(t,x-1,i)+Results(t-1,x-1,i)+Results(t-2,x-1,i))/6;
                elseif x==x_max
                    new_Results(t,x,i) = (Results(t-2,x-2,i)+Results(t-1,x-2,i)+Results(t,x-2,i))/3;
                else
                    new_Results(t,x,i)=(Results(t,x,i)+Results(t-1,x,i)+Results(t-2,x,i)+Results(t,x-1,i)+Results(t-1,x-1,i)+Results(t-2,x-1,i)+Results(t,x-2,i)+Results(t-1,x-2,i)+Results(t-2,x-2,i))/9;
                end
            end
        end
    end
end
   
%     for t=1:t_max
%         for x=1:x_max
%             [new_Results(t,x,10),new_Results(t,x,11),new_Results(t,x,12)] = find_parameters(new_Results(t,x,6),new_Results(t,x,7),new_Results(t,x,1));
%             new_Results(t,x,13) = new_Results(t,x,10)/(new_Results(t,x,11)*sqrt(new_Results(t,x,12)));
%         end
%     end

% res_out = 'FinalResults' + tis_in;
% dlmwrite(res_out,new_Results)


%% Section 2 - Obtain the QUS images

addpath(pwd)
ROI = load(fileROI);
        
% res_out = 'FinalResults' + tis_in;
% new_Results = load(res_out);
new_Results = reshape(new_Results,length(new_Results(:,1,1)),12,[]);
py_axis = length(new_Results(:,1,1)); 
py_shift = ((time_T(end,1)-ROItime(end))*SoS)/2*1000;
py_start = y_axis - py_shift - py_axis;     
     
pix_x = x_axis/(length(new_Results(1,:,1))+1);
pix_y = py_axis/(length(new_Results(:,1,1))+1);
x_pix = [0.5*pix_x x_axis-0.5*pix_x];
y_pix = [py_start+0.5*pix_y py_axis+py_start-0.5*pix_x];
y_disp = [0 (y_axis*SoS/2*1000)];

SampleName_string = string({SampleName2,SampleName2,SampleName2,SampleName2,SampleName2,...
                     SampleName2,SampleName2,SampleName2,SampleName2,...
                     SampleName2,SampleName2,SampleName2,SampleName2});

param_names =["Mean","Standard Deviation","Skewness","Kurtosis","6th Moment",...
              "X-Stat", "U-Stat","Scatterer Diameter","Acoustic Concentration",...
              "Epsilon","Sigma","Alpha (Scatter Clustering Parameter)","k (Ratio of Diffuse to Coherent Power)"];

col_vals = {[0,4000],[0,3],[-1.5,1],[2,7],[0,20000],...
            [0, 0.5],[-0.5, 0],[15,60],[-150,50],...
            [0,20],[20,5000],[0.05,0.8],[0,0.03]};

for f=1:13
    min_arr2(f) = min(min(new_Results(:,:,f)));
    max_arr2(f) = max(max(new_Results(:,:,f)));
        
    figure
        
    ax1 = axes;

    imagesc(x_plot,y_plot,env_db_liv_avg_csv,'Parent',ax1,[-res_dB 0]);
    set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')
    
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))
    axis('image')
    colormap(ax1,'gray');
    c=colorbar;
    c.Visible = 'off';
    ax2 = axes;
    if f==5
        imagesc(x_pix,y_pix,log(new_Results(:,:,f)),'Parent',ax2,'alphadata',0.5,col_vals{f});
        set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')
    
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))
    else
        imagesc(x_pix,y_pix,new_Results(:,:,f),'Parent',ax2,'alphadata',0.5,col_vals{f});
        set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')
    
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))

    end
    if f==8
        colormap(ax2,jet);
    elseif f==12
        colormap(ax2,jet);
    else
        colormap(ax2,flipud(jet));
    end
    ax2.Visible = 'off';
      
    linkaxes([ax1 ax2]);
        
    colorbar;
    %for m = 1:13
    savestring = append(param_names{f},'(data2).png');     %" Tumor Phantom";
    titlestring = append(SampleName_string{f},' ', param_names{f});
    title(ax1,titlestring)    %SampleName + ' ' + 
    ylabel(ax1,'Depth (mm)')
    xlabel(ax1,'Width (mm)')
    xlim([0 width])
    ylim([0 depth])
    a1 = get(gca,'XTickLabel');
    axis('image')
    %set(gca,'XTickLabel',a1,'FontName','Times','fontsize',20)

    set(gca,...
    'FontName', 'Arial',...
    'FontSize', 11,...
    'FontWeight','bold')
    
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.1))

     saveas(gcf,savestring)    %SampleName + ' ' +
%     destination_folder = 'C:/Users/adamj/OneDrive/Documents/QUSGUI/QUS images';
%     movefile(savestring,destination_folder);  %SampleName + ' ' + 
    %end
end

clear all

msgbox('The QUS images have now been generated. Use the drop down menu to access the images.')

%% QUS IMAGE ACQUISITION - END OF SCRIPT

% --- Executes on selection change in DataMenuOne.
function DataMenuOne_Callback(hObject, eventdata, handles)
% hObject    handle to DataMenuOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% FIRST DATA MENU - BEGINNING OF SCRIPT

menu_value = get(handles.DataMenuOne,'value');

if menu_value == 1  % Nonec
    axes(handles.axes1);
    plot(0,0)
    set(gca,'XTick',[])
    set(gca,'YTick',[])

elseif menu_value == 2  % Mean
    
     file_in = "Mean(data1).png";
     axes(handles.axes1);
     imshow(file_in);

elseif menu_value == 3  % Standard Deviation

    file_in = "Standard Deviation(data1).png";
    axes(handles.axes1);
    imshow(file_in);

elseif menu_value == 4  % Skewness

    file_in = "Skewness(data1).png";
    axes(handles.axes1);
    imshow(file_in);

elseif menu_value == 5  % Kurtosis

    file_in = "Kurtosis(data1).png";
    axes(handles.axes1);
    imshow(file_in);
   
elseif menu_value == 6  % 6th Moment
    
    file_in = "6th Moment(data1).png";  
    axes(handles.axes1);
    imshow(file_in);

elseif menu_value == 7  % X-Stat
    
    file_in = "X-Stat(data1).png";
    axes(handles.axes1);
    imshow(file_in);

elseif menu_value == 8  % U-Stat
    
    file_in = "U-Stat(data1).png";
    axes(handles.axes1);
    imshow(file_in);

elseif menu_value == 9  % Scatterer Diameter
    
    file_in = "Scatterer Diameter(data1).png";
    axes(handles.axes1);
    imshow(file_in);
 
elseif menu_value == 10 % Acoustic Concentration
    
    file_in = "Acoustic Concentration(data1).png";
    axes(handles.axes1);
    imshow(file_in);
  
elseif menu_value == 11 % Epsilon
    
    file_in = "epsilon(data1).png";
    axes(handles.axes1);
    imshow(file_in);

elseif menu_value == 12 % Sigma
    
    file_in = "sigma(data1).png";
    axes(handles.axes1);
    imshow(file_in);
   
elseif menu_value == 13 % Alpha
    
    file_in = "alpha(Scatter Clustering Parameter)(data1).png";
    axes(handles.axes1);
    imshow(file_in);
   
elseif menu_value == 14 % k
    
    file_in = "k (ratio of diffuse to coherent power)(data1).png";
    axes(handles.axes1);
    imshow(file_in);

end

%% FIRST DATA MENU - END OF SCRIPT

% Hints: contents = cellstr(get(hObject,'String')) returns DataMenuOne contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DataMenuOne


% --- Executes during object creation, after setting all properties.
function DataMenuOne_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataMenuOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in DataMenuTwo.
function DataMenuTwo_Callback(hObject, eventdata, handles)
% hObject    handle to DataMenuTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DataMenuTwo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DataMenuTwo

%% FIRST DATA MENU - BEGINNING OF SCRIPT

menu_value = get(handles.DataMenuTwo,'value');

if menu_value == 1  % None
    axes(handles.axes2);
    plot(0,0)
    set(gca,'XTick',[])
    set(gca,'YTick',[])

elseif menu_value == 2  % Mean
    
     file_in = "Mean(data2).png";
     axes(handles.axes2);
     imshow(file_in);

elseif menu_value == 3  % Standard Deviation

    file_in = "Standard Deviation(data2).png";
    axes(handles.axes2);
    imshow(file_in);

elseif menu_value == 4  % Skewness

    file_in = "Skewness(data2).png";
    axes(handles.axes2);
    imshow(file_in);

elseif menu_value == 5  % Kurtosis

    file_in = "Kurtosis(data2).png";
    axes(handles.axes2);
    imshow(file_in);
   
elseif menu_value == 6  % 6th Moment
    
    file_in = "6th Moment(data2).png";  
    axes(handles.axes2);
    imshow(file_in);

elseif menu_value == 7  % X-Stat
    
    file_in = "X-Stat(data2).png";
    axes(handles.axes2);
    imshow(file_in);

elseif menu_value == 8  % U-Stat
    
    file_in = "U-Stat(data2).png";
    axes(handles.axes2);
    imshow(file_in);

elseif menu_value == 9  % Scatterer Diameter
    
    file_in = "Scatterer Diameter(data2).png";
    axes(handles.axes2);
    imshow(file_in);
 
elseif menu_value == 10 % Acoustic Concentration
    
    file_in = "Acoustic Concentration(data2).png";
    axes(handles.axes2);
    imshow(file_in);
  
elseif menu_value == 11 % Epsilon
    
    file_in = "epsilon(data2).png";
    axes(handles.axes2);
    imshow(file_in);

elseif menu_value == 12 % Sigma
    
    file_in = "sigma(data2).png";
    axes(handles.axes2);
    imshow(file_in);
   
elseif menu_value == 13 % Alpha
    
    file_in = "alpha(Scatter Clustering Parameter)(data2).png";
    axes(handles.axes2);
    imshow(file_in);
   
elseif menu_value == 14 % k
    
    file_in = "k (ratio of diffuse to coherent power)(data2).png";
    axes(handles.axes2);
    imshow(file_in);

end

%% FIRST DATA MENU - END OF SCRIPT

% --- Executes during object creation, after setting all properties.
function DataMenuTwo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataMenuTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% CLEAR AXES AND DATA - BEGINNING OF SCRIPT

axes(handles.axes1);
plot(0,0);
%ax1 = gca;
%ax1.XColor = 'w';
%ax1.YColor = 'w';
set(gca,'XTick',[])
set(gca,'YTick',[])

axes(handles.axes2);
plot(0,0);
%ax2 = gca;
%ax2.XColor = 'w';
%ax2.YColor = 'w';
set(gca,'XTick',[])
set(gca,'YTick',[])

clear all

%% CLEAR AXES - END OF SCRIPT


% --- Executes on button press in ExitGUIButton.
function ExitGUIButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExitGUIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% EXIT GUI - BEGINNING OF SCRIPT

clear all
close all

%% EXIT GUI - END OF SCRIPT
