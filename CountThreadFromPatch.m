function [horizontal_threads_bw,vertical_threads_bw,horizontal_threads_Gy,vertical_threads_Gx] = CountThreadFromPatch(path,blur,double_thread)
patch = im2double(im2gray(imread(path)));
if blur==1
    patch = imgaussfilt(patch,0.6);
end
% obtain gradient x and y from the image
[Gx,Gy] = ImageGradientXY(patch);
% if stress==1
%        % if stress image, no need to threshold the image
%        gray_thresholding = patch;
%        Gx_thresholded = Gx;
%        Gy_thresholded = Gy;
%    else
       gray_thresholding = GrayThresholding(patch);
       Gx_thresholded = GrayThresholding(Gx);
       Gy_thresholded = GrayThresholding(Gy);
% end
%     thread count based on image only
horizontal_threads_bw = CountThread(gray_thresholding,"horizontal",double_thread);
vertical_threads_bw = CountThread(gray_thresholding,"vertical",double_thread);
%     thread count based on image gradient
horizontal_threads_Gy= CountThread(Gy_thresholded,"horizontal",double_thread);
vertical_threads_Gx= CountThread(Gx_thresholded,"vertical",double_thread);
end
