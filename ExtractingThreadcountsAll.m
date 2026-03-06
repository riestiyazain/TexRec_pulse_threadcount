%% EXTRACTING THREAD COUNTS AND KMEANS BASED ON THREAD DENSITY 
% dont forget to add path to the whole project
% run from inside patches/ folder or stress_patches/
% need matlab parallel computing toolbox

clear;clc;close all;

%% THREAD COUNTING PARAMETERS
% the parameters for threadcounting
blur = 1; % add the 0.6 gaussian blur prior thread counting, 0 if no blur is applied;
double_thread = 1; % single threaded mechanism = 0, double threaded mechanism = 2;

folder =dir("*");

%% THREAD DENSITY/COUNTING FOR EACH PATCH IN THE FOLDER
% Extracting threadcounts from all image in the folder, which each folder
% stores 1x1 cm patches of the corresponding fragment, identified with
% number id.

% thread density using tresholding data
horizontal_threads_bw = {};
vertical_threads_bw = {};
% thread density using gradient data
horizontal_threads_Gy = {};
vertical_threads_Gx = {};

% mean of thread densities
mean_horizontal_threads_bw = [];
mean_vertical_threads_bw = [];
mean_horizontal_threads_Gy = [];
mean_vertical_threads_Gx = [];

% counting the threads
texrec_name = {};
% depending on the OS, the starting index i of the folder might different.
% check on the folder variable. 
for i=4:length(folder)
    index = i-3;
    if folder(i).isdir 
        currentfolder = folder(i).name
        texrec_name{index} = currentfolder;
        path = currentfolder +"/*.png"
        [horizontal_threads_bw{index}, vertical_threads_bw{index},horizontal_threads_Gy{index}, vertical_threads_Gx{index}] = CountThreadFromPatchesDir(path,blur,double_thread);

        mean_horizontal_threads_bw(index) = mean(cell2mat(horizontal_threads_bw(index)));
        mean_vertical_threads_bw(index) =  mean(cell2mat(vertical_threads_bw(index)));
        mean_horizontal_threads_Gy(index) =  mean(cell2mat(horizontal_threads_Gy(index)));
        mean_vertical_threads_Gx(index) =  mean(cell2mat(vertical_threads_Gx(index)));
    end
end

%% CLUSTERING DATA PREPROCESS
% concatenating thread density
bw_features = [horizontal_threads_bw',vertical_threads_bw'];
gradient_features = [horizontal_threads_Gy',vertical_threads_Gx'];

% concatenating the mean thread density
bw_features_mean = [mean_horizontal_threads_bw',mean_vertical_threads_bw'];
gradient_features_mean = [mean_horizontal_threads_Gy',mean_vertical_threads_Gx'];

% CHANGE FEATURE for clustering here - bw_features_mean OR gradient_features_mean
features = gradient_features_mean;

%% KMEANS CLUSTERING
% change the k based on the need. Archaeologists clusters k=5 
k = 5;
[idx,C] =  ClusterFragments(features,k)

%% CLUSTERING RESULT VISUALIZATION
% ground truth cluster from archaeologists
    gt_1 = ["008-1", "008"];
    gt_2 = ["010","012","090","016","053","055-1","055-2","131","056","066","082","083","087","088","086"];
    gt_3 = ["029","001","057"];
    gt_4 = ["067","068","071","072"];
    gt_5 = ["102","103","104"];
    gt_all = [gt_1,gt_2,gt_3,gt_4,gt_5];
    gt_idx = [];
    gt_label = [ones(length(gt_1),1);ones(length(gt_2),1)*2;ones(length(gt_3),1)*3;ones(length(gt_4),1)*4;ones(length(gt_5),1)*5];

    for i=1:length(gt_all)
        gt_idx(i)=find(texrec_name == gt_all(i));
    end

% plot the result, for the matched cluster need to manually inspect
ScatterPlotResult(features,C,idx,texrec_name,gt_idx,gt_label,gt_all)

gt_names = texrec_name(gt_idx);
feature_hor = features(:,1);
feature_ver = features(:,2);
name = texrec_name';
indexs = idx;
cluster_result = sortrows(table(feature_hor,feature_ver,name,idx));
feature_hor = features(gt_idx',1);
feature_ver = features(gt_idx',2);
name = gt_names';
ground_truth = sortrows(table(feature_hor,feature_ver,name));

%% Use "silhouette" function to measure the goodness of the clustering:
% silhouette(features, idx)
% title('Silhouette',FontSize=20)

%% ITERATIVE SILHOUETTE TO FIND INITIAL K 
S = silhouette(features, idx);
iterative_silhouette = [];
for k=2:length(features)
    [idx,C] =  ClusterFragments(features,k);
    iterative_silhouette(k) = mean(silhouette(features, idx));
end
%% 
figure,plot(iterative_silhouette,LineWidth=2)
title("Iterative silhouette",FontSize=20)

%% 
[idx,C] =  ClusterFragments(features,21)
ScatterCluster(features,idx,C,texrec_name)
%% Elbow
wcss = [];

for k=2:length(features)
    [idx,C] =  ClusterFragments(features,k);
    wcss(k) = sum((sum((features - C(idx, :)).^2, 2)));
end
%%
figure,plot(wcss,LineWidth=2)
title('Elbow method',FontSize=20)

%%
[idx,C] =  ClusterFragments(features,10)
ScatterCluster(features,idx,C,texrec_name)
%% chiu subtractive clustering

% C_chiu = subclust(features, 0.6)

%% 
function [horizontal_threads_bw, vertical_threads_bw,horizontal_threads_Gy, vertical_threads_Gx] = CountThreadFromPatchesDir(path,blur,double_thread)
    % load all the images and extract thread count
    imagefiles = dir(path);      
    nfiles = length(imagefiles);    % Number of files found
    horizontal_threads_bw = [];
    vertical_threads_bw = [];
    horizontal_threads_Gy = [];
     vertical_threads_Gx = [];

    parfor i=1:nfiles
       currentfilename = imagefiles(i).name;
       disp("counting threads in image "+ currentfilename)
        [horizontal_threads_bw(i), vertical_threads_bw(i),horizontal_threads_Gy(i), vertical_threads_Gx(i)]=CountThreadFromPatch(currentfilename,blur,double_thread);
        close all;
    end
end

function [idx,C] = ClusterFragments(features,k)
rng(1); % For reproducibility
opts = statset('Display','final');
[idx,C] = kmeans(features,k,'Distance','cityblock',...
    'Replicates',7,'Options',opts);
end

function ScatterPlotResult(feature_all_thresold,C,idx,texrec_name,gt_idx,gt_label,gt_all)
    figure,subplot(1,3,1)
    gscatter(feature_all_thresold(:,1), feature_all_thresold(:,2),idx,"mgcrb",'.',20);   % plot clusters with different colors
    text(feature_all_thresold(:,1), feature_all_thresold(:,2),texrec_name)
    hold on;
    plot(C(:, 1), C(:, 2), 'kx');% plot centroids
    legend('cluster 1', 'cluster 2','cluster 3','cluster 4', 'cluster 5','centroids')
    title('K-Means Clustering Results',FontSize=20); 
    xlabel('mean horizontal thread density')
    ylabel('mean vertical thread density')
    
    subplot(1,3,2)
    % gt_bw_features_mean = bw_features_mean()
    gscatter(feature_all_thresold(gt_idx',1),feature_all_thresold(gt_idx',2),gt_label,"rcgbm",'.',20);
    text(feature_all_thresold(gt_idx',1),feature_all_thresold(gt_idx',2),gt_all')
    title("Ground truth clustering by Archaeologists",FontSize=20)
    xlabel('mean horizontal thread density')
    ylabel('mean vertical thread density')
%     ylim([4,11])
    legend('cluster 1', 'cluster 2','cluster 3','cluster 4', 'cluster 5')

     subplot(1,3,3)
     gscatter(feature_all_thresold(:,1), feature_all_thresold(:,2),idx,"mgcrb",'.',20);   % plot clusters with different colors
    text(feature_all_thresold(:,1), feature_all_thresold(:,2),texrec_name)
    hold on;
    plot(C(:, 1), C(:, 2), 'kx');% plot centroids
    legend('cluster 1', 'cluster 2','cluster 3','cluster 4', 'cluster 5','centroids')
    title('Matched clusters',FontSize=20); 
    xlabel('mean horizontal thread density')
    ylabel('mean vertical thread density')
%     % gt_bw_features_mean = bw_features_mean()
%     scatter(intersection.feature_hor,intersection.feature_ver);
%     text(intersection.feature_hor,intersection.feature_ver,intersection.name)
%     title("Match cluster = "+string(length(intersection.name)),FontSize=20)
%     xlabel('mean horizontal thread density')
%     ylabel('mean vertical thread density')
% %     ylim([4,11])
% %     legend('cluster 1', 'cluster 2','cluster 3','cluster 4', 'cluster 5')
    

end

function ScatterCluster(feature_all_thresold,idx,C,texrec_name)
    numGroups = length(unique(idx));
    clr = hsv(numGroups);
    figure,gscatter(feature_all_thresold(:,1), feature_all_thresold(:,2),idx,clr,'.',20);   % plot clusters with different colors
    text(feature_all_thresold(:,1), feature_all_thresold(:,2),texrec_name)
    hold on;
    plot(C(:, 1), C(:, 2), 'kx');% plot centroids
%     legend('cluster 1', 'cluster 2','cluster 3','cluster 4', 'cluster 5','centroids')
    title('K-Means Clustering Results',FontSize=20); 
    xlabel('mean horizontal thread density')
    ylabel('mean vertical thread density')
end