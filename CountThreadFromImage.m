function [horizontal_threads_bw, vertical_threads_bw,horizontal_threads_Gy, vertical_threads_Gx]=CountThreadFromImage(path, patch_size)
% cropping images to patch
img = im2double(im2gray(imread(path)));
% for 1x1 cm patch size is 120
% patch_size = 120;

% create a looper, contains coordinates for each patch, lagged
% 0.5*patch_size for overlaps
horizontal_looper = 1:patch_size/2:size(img,2)-(patch_size);
vertical_looper = 1:patch_size/2:size(img,1)-(patch_size);
coordinates = combvec(horizontal_looper,vertical_looper);

% for storing the thread count result
horizontal_threads_Gy = [];
vertical_threads_Gx = [];
horizontal_threads_bw = [];
vertical_threads_bw =[];

parfor i=1:length(coordinates)
    patch = img(coordinates(2,i):coordinates(2,i)+patch_size-1,coordinates(1,i):coordinates(1,i)+patch_size-1);
%     imwrite(patch, "Puzzled/"+string(i)+"_"+path);
    % blur the image to reduce noise
%     blurredImage = BlurImage(patch,3);
    
%     % threshold the image
    gray_thresholding = GrayThresholding(patch);
    
    % obtain gradient x and y from the blurred image
    [Gx,Gy] = ImageGradientXY(patch);

    Gx_thresholded = GrayThresholding(Gx);
    Gy_thresholded = GrayThresholding(Gy);

%     thread count based on image only
    horizontal_threads_bw(i)= CountThread(gray_thresholding,"horizontal");
    vertical_threads_bw(i)= CountThread(gray_thresholding,"vertical");

%     thread count based on image gradient 
    horizontal_threads_Gy(i)= CountThread(Gy_thresholded,"horizontal");
    vertical_threads_Gx(i)= CountThread(Gx_thresholded,"vertical");

%     checking the patch and counted threads
%     imshow(patch)
%     title("hor: "+string(horizontal_threads_bw(i))+" ver: "+string(vertical_threads_bw(i)));
end
% reshape back to 2d
horizontal_threads_bw = reshape(horizontal_threads_bw,length(vertical_looper),[]);
vertical_threads_bw = reshape(vertical_threads_bw,length(vertical_looper),[]);
horizontal_threads_Gy = reshape(horizontal_threads_Gy,length(vertical_looper),[]);
vertical_threads_Gx = reshape(vertical_threads_Gx,length(vertical_looper),[]);

Heatmap(img, GrayThresholding(img), horizontal_threads_bw, vertical_threads_bw);
Heatmap(img, ImageGradientXY(img), horizontal_threads_Gy, vertical_threads_Gx);

end