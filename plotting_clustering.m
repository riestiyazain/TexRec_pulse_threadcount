% original
[horizontal_threads_bw_082, vertical_threads_bw_082,horizontal_threads_Gy_082, vertical_threads_Gx_082] = CountThreadFromDir("082/*.png");
[horizontal_threads_bw_130, vertical_threads_bw_130,horizontal_threads_Gy_130, vertical_threads_Gx_130] = CountThreadFromDir("008/*.png");

% stress
% [horizontal_threads_bw_082_stress, vertical_threads_bw_082_stress,horizontal_threads_Gy_082_stress, vertical_threads_Gx_082_stress] = CountThreadFromDir("patches_STRESS/082/*.png");
% [horizontal_threads_bw_130_stress, vertical_threads_bw_130_stress,horizontal_threads_Gy_130_stress, vertical_threads_Gx_130_stress] = CountThreadFromDir("patches_STRESS/083/*.png");
%%
gt = [ones(size(horizontal_threads_bw_082,2),1);ones(size(horizontal_threads_bw_130,2),1)*2];
feature_all_thresold = [horizontal_threads_bw_082',vertical_threads_bw_082';horizontal_threads_bw_130',vertical_threads_bw_130';];
feature_all_gradient = [horizontal_threads_Gy_082',vertical_threads_Gx_082';horizontal_threads_Gy_130',vertical_threads_Gx_130';];
images_130 = ReadImageFromDir("130/*.png");
images_082 = ReadImageFromDir("008/*.png");
%%
% ClusterFragments(feature_all_thresold,2,gt,images_130,images_082)
ClusterFragments(feature_all_gradient,2,gt,images_130,images_082)



%% 
function [horizontal_threads_bw, vertical_threads_bw,horizontal_threads_Gy, vertical_threads_Gx] = CountThreadFromDir(path)
    imagefiles = dir(path);  
    folder = split(path,'/');
    folder = folder{1};
    disp(folder)
    nfiles = length(imagefiles);    % Number of files found
    horizontal_threads_bw = [];
    vertical_threads_bw = [];
    horizontal_threads_Gy = [];
     vertical_threads_Gx = [];
    for i=1:nfiles
       currentfilename = string(folder)+'/'+imagefiles(i).name;
       disp("counting threads in image "+ currentfilename)
        % images{i} = imread(currentfilename);
        [horizontal_threads_bw(i), vertical_threads_bw(i),horizontal_threads_Gy(i), vertical_threads_Gx(i)]=CountThreadFromPatch(currentfilename,0,1,1);
        close all;
    end
end


function images = ReadImageFromDir(path)
    imagefiles = dir(path);  
    folder = split(path,'/');
    folder = folder{1};
    nfiles = length(imagefiles);    % Number of files found
    for i=1:nfiles
       currentfilename = string(folder)+'/'+imagefiles(i).name;
        images{i} = imread(currentfilename);
    end
end

function ClusterFragments(feature_all_thresold,k,gt,images_130,images_082)
    rng(1); % For reproducibility
    opts = statset('Display','final');
    [idx,C] = kmeans(feature_all_thresold,k,'Distance','cityblock',...
        'Replicates',8,'Options',opts);
    figure, ScatterPlotResult(feature_all_thresold,C,idx,gt)
    figure, ScatterPlotWithImage(images_130,images_082,feature_all_thresold,gt)
    % confusion matrix
    C = confusionmat(gt,idx);
    figure, confusionchart(C);
end

function ScatterPlotResult(feature_all_thresold,C,idx,gt)
    subplot(1,2,1)
    gscatter(feature_all_thresold(:,1), feature_all_thresold(:,2),idx,"rg",'.',20);   % plot clusters with different colors
    colormap("parula")
    hold on;
    plot(C(:, 1), C(:, 2), 'kx');% plot centroids
    legend('cluster 1', 'cluster 2','centroids')
    title('K-Means Clustering Results'); 
    xlabel('horizontal thread density')
    ylabel('vertical thread density')
    
    subplot(1,2,2)
    gscatter(feature_all_thresold(:,1), feature_all_thresold(:,2),gt,"rg",'.',20);   % plot clusters with different colors
    colormap("parula")
    hold on;
    % plot(C(:, 1), C(:, 2), 'kx');% plot centroids
    legend('cluster 1', 'cluster 2')
    title('Ground truth class'); 
    xlabel('horizontal thread density')
    ylabel('vertical thread density')
end

function ScatterPlotWithImage(images_130,images_082,feature_all_thresold,gt)
    hold on;
    
    for i=1:length(images_082)
        image(repmat(images_082{i},[1,1,3]),XData = [feature_all_thresold(i,1)-0.5,feature_all_thresold(i,1)+0.5],YData=[feature_all_thresold(i,2)-0.5,feature_all_thresold(i,2)+0.5])
    end
    
    for i=1:length(images_130)
        image(repmat(images_130{i},[1,1,3]),XData = [feature_all_thresold(i+length(images_082),1)-0.5,feature_all_thresold(i+length(images_082),1)+0.5],YData=[feature_all_thresold(i+length(images_082),2)-0.5,feature_all_thresold(i+length(images_082),2)+0.5])
    end
    
    gscatter(feature_all_thresold(:,1), feature_all_thresold(:,2),gt,"bgr",'.',20);
    % imagesc([.5 .5], [.6 .6], images_130{1});
    axis equal% plot clusters with different colors
    legend('cluster 1', 'cluster 2')
    title('Ground truth class',FontSize=20); 
    xlabel('mean horizontal thread density',FontSize=18)
    ylabel('mean vertical thread density',FontSize=18)
    hold off;
end