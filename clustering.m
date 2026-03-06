clear;clc;
%% % 
% load all the images and extract thread count
imagefiles = dir('images/Puzzled/082/patches_082/*.png');      
nfiles = length(imagefiles);    % Number of files found
% horizontal_threads_bw_082 = {};
% vertical_threads_bw_082 = {};
% horizontal_threads_Gy_082 = {};
%  vertical_threads_Gx_082 = {};
for i=1:nfiles
   currentfilename = imagefiles(i).name;
   disp("counting threads in image "+ currentfilename)
    images_082{i} = imread(currentfilename);
    [horizontal_threads_bw_082{i}, vertical_threads_bw_082{i},horizontal_threads_Gy_082{i}, vertical_threads_Gx_082{i}]=CountThreadFromImage(currentfilename,120);
    close all;
end

%%
% load all the images and extract thread count
imagefiles = dir('images/Puzzled/130/*.png');      
nfiles = length(imagefiles);    % Number of files found

for i=1:nfiles
   currentfilename = imagefiles(i).name;
   disp("counting threads in image "+ currentfilename)
    images_130{i} = imread(currentfilename);
    [horizontal_threads_bw_130{i}, vertical_threads_bw_130{i},horizontal_threads_Gy_130{i}, vertical_threads_Gx_130{i}]=CountThreadFromImage(currentfilename,120);
    close all;
end
%% concatenate vertical and horizontal thread
feature_082_bw = [];
mean_082_bw = [];
feature_130_bw = [];
mean_130_bw = [];
for i=1:size(horizontal_threads_bw_082,2)
    feature_082_bw(i,:) = [reshape(horizontal_threads_bw_082{i},1,[]),reshape(vertical_threads_bw_082{i},1,[])];
    mean_082_bw(i,:) = [mean(horizontal_threads_bw_082{i},"all"),mean(vertical_threads_bw_082{i},"all")];
end
for i=1:size(horizontal_threads_bw_130,2)
    feature_130_bw(i,:) = [reshape(horizontal_threads_bw_130{i},1,[]),reshape(vertical_threads_bw_130{i},1,[])];
    mean_130_bw(i,:) = [mean(horizontal_threads_bw_130{i},"all"),mean(vertical_threads_bw_130{i},"all")];
end


feature_all = [feature_082_bw;feature_130_bw];
mean_all = [mean_082_bw; mean_130_bw];
gt = [ones(size(horizontal_threads_bw_082,2),1);ones(size(horizontal_threads_bw_130,2),1)*2];

rng(1); % For reproducibility
opts = statset('Display','final');
[idx,C] = kmeans(feature_all,2,'Distance','cityblock',...
    'Replicates',5,'Options',opts);
% [idx,C] = kmeans(feature_all,2);
C_x = [mean(C(1,1:36)),mean(C(1,37:72))];
C_y = [mean(C(2,1:36)),mean(C(2,37:72))];
%% plot the clustering using mean thread count vertical and horizontal
gscatter(mean_all(:,1), mean_all(:,2),idx,"bgr",'.',20);   % plot clusters with different colors
colormap("parula")
hold on;
plot(C_x,C_y, 'kx');% plot centroids
legend('cluster 1', 'cluster 2','centroids')
title('K-Means Clustering Results',FontSize=20); 
xlabel('mean horizontal thread density')
ylabel('mean vertical thread density')

%% plot the ground truth using mean 
gscatter(mean_all(:,1), mean_all(:,2),gt,"bgr",'.',20);   % plot clusters with different colors
colormap("parula")
legend('cluster 1', 'cluster 2')
title('Ground truth class',FontSize=20); 
xlabel('mean horizontal thread density')
ylabel('mean vertical thread density')
%% clustering data using pca
% perform pca
[standard_data, mu, sigma] = zscore(feature_all);     % standardize data so that the mean is 0 and the variance is 1 for each variable
[coeff, score, ~]  = pca(standard_data);     % perform PCA
new_C = (C-mu)./sigma*coeff;     % apply the PCA transformation to the centroid data
%% plot using 2 axis of pca 
gscatter(score(:, 1), score(:, 2), idx, "bgr",".",20)     % plot 2 principal components of the cluster data (three clusters are shown in different colors)
hold on
plot(new_C(:, 1), new_C(:, 2), 'kx', MarkerSize=15)     % plot 2 principal components of the centroid data
title('K-Means Clustering Results - Plotted using PCA',FontSize=20); 
legend('cluster 1', 'cluster 2','centroids')

%% plot using pca
gscatter(score(:, 1), score(:, 2), gt, "bgr",".",20)     % plot 2 principal components of the cluster data (three clusters are shown in different colors)
hold on
plot(new_C(:, 1), new_C(:, 2), 'kx', MarkerSize=15)     % plot 2 principal components of the centroid data
title('Ground truth - Plotted using PCA',FontSize=20); 
legend('cluster 1', 'cluster 2','centroids')
hold off
%%  Use "silhouette" function to measure the goodness of the clustering:
silhouette(feature_all, idx);
title('Silhouette for texrec 082 and 130 K-means Clustering',FontSize=20)
%% confusion matrix
confmat = confusionmat(gt,idx);
confusionchart(confmat,FontSize=20,Title="Confusion matrix for texrec 082 and 130");
% title("Confusion matrix for texrec 082 and 130",FontSize=20)
%% add image to scatterplot for the ground truth
hold on;
for i=1:length(images_130)
    image(repmat(images_130{i},[1,1,3]),XData = [mean_130_bw(i,1)-0.5,mean_130_bw(i,1)+0.5],YData=[mean_130_bw(i,2)-0.5,mean_130_bw(i,2)+0.5])
end

for i=1:length(images_082)
    image(repmat(images_082{i},[1,1,3]),XData = [mean_082_bw(i,1)-0.5,mean_082_bw(i,1)+0.5],YData=[mean_082_bw(i,2)-0.5,mean_082_bw(i,2)+0.5])
end
gscatter(mean_all(:,1), mean_all(:,2),gt,"bgr",'.',20);
% imagesc([.5 .5], [.6 .6], images_130{1});
axis equal% plot clusters with different colors
legend('cluster 1', 'cluster 2')
title('Ground truth class',FontSize=20); 
xlabel('mean horizontal thread density',FontSize=18)
ylabel('mean vertical thread density',FontSize=18)
hold off;
%% plot ground truth using pca and image
hold on;
for i=1:length(images_130)
    image(repmat(images_130{i},[1,1,3]),XData = [score(i,1)-1,score(i,1)+1],YData=[score(i,2)-1,score(i,2)+1])
end

for i=length(images_130)+1:length(gt)
    image(repmat(images_082{i-length(images_130)},[1,1,3]),XData = [score(i,1)-1,score(i,1)+1],YData=[score(i,2)-1,score(i,2)+1])
end
gscatter(score(:,1), score(:,2),gt,"bgr",'.',20);
% imagesc([.5 .5], [.6 .6], images_130{1});
axis equal% plot clusters with different colors
legend('cluster 1', 'cluster 2')
title('Ground truth - Plotted using PCA',FontSize=20); 
hold off;


%% add image to scatterplot for the clustering data
hold on;
for i=1:length(images_130)
    image(repmat(images_130{i},[1,1,3]),XData = [mean_130_bw(i,1)-0.5,mean_130_bw(i,1)+0.5],YData=[mean_130_bw(i,2)-0.5,mean_130_bw(i,2)+0.5])
end

for i=1:length(images_082)
    image(repmat(images_082{i},[1,1,3]),XData = [mean_082_bw(i,1)-0.5,mean_082_bw(i,1)+0.5],YData=[mean_082_bw(i,2)-0.5,mean_082_bw(i,2)+0.5])
end
gscatter(mean_all(:,1), mean_all(:,2),idx,"bgr",'.',20);
% imagesc([.5 .5], [.6 .6], images_130{1});
axis equal% plot clusters with different colors
legend('cluster 1', 'cluster 2')
title('K-Means Clustering Results',FontSize=20); 
xlabel('mean horizontal thread density',FontSize=18)
ylabel('mean vertical thread density',FontSize=18)
hold off;

%% plot clustering using pca and image 
hold on;
for i=1:length(images_130)
    image(repmat(images_130{i},[1,1,3]),XData = [score(i,1)-1,score(i,1)+1],YData=[score(i,2)-1,score(i,2)+1])
end

for i=length(images_130)+1:length(gt)
    image(repmat(images_082{i-length(images_130)},[1,1,3]),XData = [score(i,1)-1,score(i,1)+1],YData=[score(i,2)-1,score(i,2)+1])
end
gscatter(score(:,1), score(:,2),idx,"bgr",'.',20);
% imagesc([.5 .5], [.6 .6], images_130{1});
axis equal% plot clusters with different colors
legend('cluster 1', 'cluster 2')
title('K-Means Clustering Results - Plotted using PCA',FontSize=20); 
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
