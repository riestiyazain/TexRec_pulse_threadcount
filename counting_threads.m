
%% pulse width
%  pulse_fronts = find(abs(diff(Q))); 
%  disp("number of pulse "+string(length(pulse_fronts)/2))
%  pulse_lengths = diff(pulse_fronts);
%  plot(pulse_lengths);
% 
%  bar(histcounts(pulse_lengths,max(pulse_lengths)))

%% test case
% read the image
I = im2double(im2gray(imread("images/resized_texrec082_center.tiff")));
% blur the image to reduce noise
blurredImage = BlurImage(I,12);

% threshold the image
gray_thresholding = GrayThresholding(blurredImage);

% obtain gradient x and y from the blurred image
[Gx,Gy] = ImageGradientXY(blurredImage);

% threshold the gradient image

Gx_thresholded = GrayThresholding(Gx);
Gy_thresholded = GrayThresholding(Gy);
% normalized_gx = NormalizeImage(Gx);

clc;
close all;
% Horizontal threadcount
imshow(blurredImage);
disp("horizontal thread count using *only* thresholded image")
horizontal_thread_bw = CountThread(gray_thresholding,"horizontal");
disp("horizontal thread count using thresholded gradient image")
horizontal_thread_Gy = CountThread(Gy_thresholded,"horizontal");
disp("vertical thread count using *only* thresholded image")
vertical_thread_bw = CountThread(gray_thresholding,"vertical");
disp("vertical thread count using thresholded gradient image")
vertical_thread_Gx = CountThread(Gx_thresholded,"vertical");
%%
% cropping images to patch
img = im2double(im2gray(imread("images/cropped_texrec082.tiff")));
% for 1x1 cm patch size is 120
patch_size = 120;
horizontal_looper = 1:patch_size:size(img,2);
vertical_looper = 1:patch_size:size(img,1);
coordinates = combvec(horizontal_looper,vertical_looper);

horizontal_threads_Gy = [];
vertical_threads_Gx = [];
horizontal_threads_bw = [];
vertical_threads_bw =[];
% 
for i=1:length(coordinates)
    patch = img(coordinates(2,i):coordinates(2,i)+patch_size-1,coordinates(1,i):coordinates(1,i)+patch_size-1);
    % blur the image to reduce noise
%     blurredImage = BlurImage(patch,3);
    
%     % threshold the image
    gray_thresholding = GrayThresholding(patch);
    
    % obtain gradient x and y from the blurred image
    [Gx,Gy] = ImageGradientXY(patch);

    Gx_thresholded = GrayThresholding(Gx);
    Gy_thresholded = GrayThresholding(Gy);

    horizontal_threads_bw(i) = CountThread(gray_thresholding,"horizontal");
    horizontal_threads_Gy(i) = CountThread(Gy_thresholded,"horizontal");
    vertical_threads_bw(i) = CountThread(gray_thresholding,"vertical");
    vertical_threads_Gx(i) = CountThread(Gx_thresholded,"vertical");

end
%% 
figure,subplot(3,1,1)
imshow("images/cropped_texrec082.tiff")
subplot(3,1,2)
heatmap(reshape(horizontal_threads_bw,length(vertical_looper),[]),"Title","Horizontal threads /cm2")
% colormap("turbo")
subplot(3,1,3)
heatmap(reshape(vertical_threads_bw,length(vertical_looper),[]),"Title","Vertical threads /cm2")
% colormap("turbo")

%% 
figure,subplot(3,1,1)
imshow("images/cropped_texrec082.tiff")
subplot(3,1,2)
heatmap(reshape(horizontal_threads_Gy,length(vertical_looper),[]),"Title","Horizontal threads /cm2")
% colormap("turbo")
subplot(3,1,3)
heatmap(reshape(vertical_threads_Gx,length(vertical_looper),[]),"Title","Vertical threads /cm2")
% colormap("turbo")

%% 
% cropping images to patch
img = im2double(im2gray(imread("images/Plain Weave.jpg")));
% for 1x1 cm patch size is 120
patch_size = 120;
horizontal_looper = 1:patch_size/2:size(img,2)-(patch_size/2);
vertical_looper = 1:patch_size/2:size(img,1)-(patch_size/2);
coordinates = combvec(horizontal_looper,vertical_looper);

horizontal_threads_Gy = [];
vertical_threads_Gx = [];
horizontal_threads_bw = [];
vertical_threads_bw =[];
% 
for i=1:length(coordinates)
    patch = img(coordinates(2,i):coordinates(2,i)+patch_size-1,coordinates(1,i):coordinates(1,i)+patch_size-1);
    % blur the image to reduce noise
%     blurredImage = BlurImage(patch,3);
    
%     % threshold the image
    gray_thresholding = GrayThresholding(patch);
    
    % obtain gradient x and y from the blurred image
    [Gx,Gy] = ImageGradientXY(patch);

    Gx_thresholded = GrayThresholding(Gx);
    Gy_thresholded = GrayThresholding(Gy);

    horizontal_threads_bw(i) = CountThread(gray_thresholding,"horizontal");
    horizontal_threads_Gy(i) = CountThread(Gy_thresholded,"horizontal");
    vertical_threads_bw(i) = CountThread(gray_thresholding,"vertical");
    vertical_threads_Gx(i) = CountThread(Gx_thresholded,"vertical");
    imshow(patch)
    title("hor: "+string(horizontal_threads_bw(i))+" ver: "+string(vertical_threads_bw(i)));
end
%%

figure,subplot(3,1,1)
imshow("images/Plain Weave.jpg")
subplot(3,1,2)
heatmap(reshape(horizontal_threads_bw,length(vertical_looper),[]),"Title","Horizontal threads /cm2")
% colormap("turbo")
subplot(3,1,3)
heatmap(reshape(vertical_threads_bw,length(vertical_looper),[]),"Title","Vertical threads /cm2")
% colormap("turbo")

%% 
figure,subplot(3,1,1)
imshow("images/Plain Weave.jpg")
subplot(3,1,2)
heatmap(reshape(horizontal_threads_Gy,length(vertical_looper),[]),"Title","Horizontal threads /cm2")
% colormap("turbo")
subplot(3,1,3)
heatmap(reshape(vertical_threads_Gx,length(vertical_looper),[]),"Title","Vertical threads /cm2")
% colormap("turbo")
%%
 
function horizontal_thread_count = CountThread(thresholded_image,direction)
% count horizontal thread count by counting the number of pulse in vertical
% direction from the thresholded image (binary)
% requires square image size
    number_of_pulse = [];
%     loop over from left to the right patch 
    for i=1:size(thresholded_image,2)
%         get the column of the image
        if direction == "horizontal"
            Q = thresholded_image(:,i);
        elseif direction == "vertical"
            Q = thresholded_image(i,:);
        else 
            disp("direction is not implemented yet");
            break;
        end
%         find where the pulse located (either pulsing up and down)
        pulse_fronts = find(abs(diff(Q))); 
%         the number of pulse is half of the number both pulsing up and
%         down
        number_of_pulse(i) = (length(pulse_fronts)/2);
%         disp("number of pulse "+string(number_of_pulse(i)))
    end
    horizontal_thread_count = mode(number_of_pulse);
%     vote for the majority pulse that agrees on each other the most
%     disp("majority number of pulse "+ string(horizontal_thread_count))
end

function blurredImage = BlurImage(I, windowWidth)
   % windowWidth Whatever you want.  More blur for larger numbers.
    kernel = ones(windowWidth) / windowWidth ^ 2;
    blurredImage = imfilter(I, kernel); % Blur the image.
%     figure, imshow(blurredImage); % Display it.
%     title("Blurred image result")
end

function BW = GrayThresholding(blurredImage)
    level = graythresh(blurredImage);
    BW = imbinarize(blurredImage,level);
%     figure, imshowpair(blurredImage,BW,'montage')
end

function [Gx, Gy] = ImageGradientXY(blurredImage)
    [Gx,Gy] = imgradientxy(blurredImage);
%     figure, subplot(1,3,1);
%     title("blurred image")
%     imshow(blurredImage)
%     subplot(1,3,2)
%     title("Gradient in x direction")
%     imshow(Gx);
%     subplot(1,3,3);
%     title("Gradient in y direction")
%     imshow(Gy);
end

function image = NormalizeImage(image)
    image = (image - min(image,[],"all"))/(max(image,[],"all")-min(image,[],"all"));
%     figure, imshow(image)
%     title("Normalized image")
end