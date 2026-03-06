clear;clc;
%% % 
% load all the images and extract thread count
imagefiles = dir('082/*.png');      
nfiles = length(imagefiles);    % Number of files found
horizontal_threads_bw_082 = [];
vertical_threads_bw_082 = [];
horizontal_threads_Gy_082 = [];
 vertical_threads_Gx_082 = [];
for i=1:nfiles
   currentfilename = "082/"+imagefiles(i).name;
   disp("counting threads in image "+ currentfilename)
    images_082{i} = imread(currentfilename);
    [horizontal_threads_bw_082(i), vertical_threads_bw_082(i),horizontal_threads_Gy_082(i), vertical_threads_Gx_082(i)]=CountThreadFromPatch(currentfilename,0,1);
    close all;
end

%%
% load all the images and extract thread count
imagefiles = dir('008/*.png');      
nfiles = length(imagefiles);    % Number of files found
horizontal_threads_bw_130 = [];
vertical_threads_bw_130 = [];
horizontal_threads_Gy_130 = [];
 vertical_threads_Gx_130 = [];
for i=1:nfiles
   currentfilename = "008/"+imagefiles(i).name;
   disp("counting threads in image "+ currentfilename)
    images_130{i} = imread(currentfilename);
    [horizontal_threads_bw_130(i), vertical_threads_bw_130(i),horizontal_threads_Gy_130(i), vertical_threads_Gx_130(i)]=CountThreadFromPatch(currentfilename,0,1);
    close all;
end
%% concatenate vertical and horizontal thread
% feature_082_bw = [];
% mean_082_bw = [];
% feature_130_bw = [];
% mean_130_bw = [];
% for i=1:size(horizontal_threads_bw_082,2)
%     feature_082_bw(i,:) = [reshape(horizontal_threads_bw_082{i},1,[]),reshape(vertical_threads_bw_082{i},1,[])];
%     mean_082_bw(i,:) = [mean(horizontal_threads_bw_082{i},"all"),mean(vertical_threads_bw_082{i},"all")];
% end
% for i=1:size(horizontal_threads_bw_130,2)
%     feature_130_bw(i,:) = [reshape(horizontal_threads_bw_130{i},1,[]),reshape(vertical_threads_bw_130{i},1,[])];
%     mean_130_bw(i,:) = [mean(horizontal_threads_bw_130{i},"all"),mean(vertical_threads_bw_130{i},"all")];
% end

% 
% feature_all = [feature_082_bw;feature_130_bw];
% mean_all = [mean_082_bw; mean_130_bw];
gt = [ones(size(horizontal_threads_bw_082,2),1);ones(size(horizontal_threads_bw_130,2),1)*2];

feature_all = [horizontal_threads_bw_082',vertical_threads_bw_082';horizontal_threads_bw_130',vertical_threads_bw_130'];
% mean_all = [mean(horizontal_threads_bw_082),m]
%% 
rng(1); % For reproducibility
opts = statset('Display','final');
[idx,C] = kmeans(feature_all,2,'Distance','cityblock',...
    'Replicates',5,'Options',opts);

%% plot the high dimensional data using mean thread count vertical and horizontal
gscatter(feature_all(:,1), feature_all(:,2),idx,"bgr",'.',20);   % plot clusters with different colors
colormap("parula")
hold on;
plot(C(:, 1), C(:, 2), 'kx');% plot centroids
legend('cluster 1', 'cluster 2','centroids')
title('K-Means Clustering Results'); 
xlabel('mean horizontal thread density')
ylabel('mean vertical thread density')

%%
gscatter(feature_all(:,1), feature_all(:,2),gt,"bgr",'.',20);   % plot clusters with different colors
colormap("parula")
legend('cluster 1', 'cluster 2')
title('Ground truth class'); 
xlabel('mean horizontal thread density')
ylabel('mean vertical thread density')
%% plot using pca
% colormap("turbo")
[standard_data, mu, sigma] = zscore(feature_all);     % standardize data so that the mean is 0 and the variance is 1 for each variable
[coeff, score, ~]  = pca(standard_data);     % perform PCA
new_C = (C-mu)./sigma*coeff;     % apply the PCA transformation to the centroid data
gscatter(score(:, 1), score(:, 2), idx, "bgr",".",20)     % plot 2 principal components of the cluster data (three clusters are shown in different colors)
hold on
plot(new_C(:, 1), new_C(:, 2), 'kx', MarkerSize=15)     % plot 2 principal components of the centroid data
title('K-Means Clustering Results - Plotted using PCA'); 
legend('cluster 1', 'cluster 2','centroids')

%% plot using pca
% colormap("turbo")
[standard_data, mu, sigma] = zscore(feature_all);     % standardize data so that the mean is 0 and the variance is 1 for each variable
[coeff, score, ~]  = pca(standard_data);     % perform PCA
new_C = (C-mu)./sigma*coeff;     % apply the PCA transformation to the centroid data
gscatter(score(:, 1), score(:, 2), gt, "bgr",".",20)     % plot 2 principal components of the cluster data (three clusters are shown in different colors)
hold on
plot(new_C(:, 1), new_C(:, 2), 'kx', MarkerSize=15)     % plot 2 principal components of the centroid data
title('Ground truth - Plotted using PCA'); 
legend('cluster 1', 'cluster 2','centroids')
hold off
%%  Use "silhouette" function to measure the goodness of the clustering:
silhouette(feature_all, idx);
%% confusion matrix
C = confusionmat(gt,idx);
confusionchart(C);
%% add image to scatterplot
hold on;
for i=1:length(images_130)
    image(repmat(images_130{i},[1,1,3]),XData = [feature_all(i,1)-0.5,feature_all(i,1)+0.5],YData=[feature_all(i,2)-0.5,feature_all(i,2)+0.5])
end

for i=1:length(images_082)
    image(repmat(images_082{i},[1,1,3]),XData = [feature_all(i,1)-0.5,feature_all(i,1)+0.5],YData=[feature_all(i,2)-0.5,feature_all(i,2)+0.5])
end
gscatter(feature_all(:,1), feature_all(:,2),gt,"bgr",'.',20);
% imagesc([.5 .5], [.6 .6], images_130{1});
axis equal% plot clusters with different colors
legend('cluster 1', 'cluster 2')
title('Ground truth class',FontSize=20); 
xlabel('mean horizontal thread density',FontSize=18)
ylabel('mean vertical thread density',FontSize=18)
hold off;
%%
ScatterPlotWithImage(images_130,mean_130_bw,images_082,mean_082_bw, mean_all)

%% function to plotting

function ScatterPlotWithImage(images_130,mean_130_bw,images_082,mean_082_bw,mean_all)
    hold on;
    for i=1:length(images_130)
        image(repmat(images_130{i},[1,1,3]),XData = [mean_130_bw(i,1)-0.5,mean_130_bw(i,1)+0.5],YData=[mean_130_bw(i,2)-0.5,mean_130_bw(i,2)+0.5])
    end
    
    for i=1:length(images_082)
        image(repmat(images_082{i},[1,1,3]),XData = [mean_082_bw(i,1)-0.5,mean_082_bw(i,1)+0.5],YData=[mean_082_bw(i,2)-0.5,mean_082_bw(i,2)+0.5])
    end
    gscatter(mean_all(:,1), mean_all(:,2),gt,"bgr",'.',20);
    axis equal % plot clusters with different colors
    legend('cluster 1', 'cluster 2')
    title('Ground truth class',FontSize=20); 
    xlabel('mean horizontal thread density',FontSize=18)
    ylabel('mean vertical thread density',FontSize=18)
    hold off;

end
