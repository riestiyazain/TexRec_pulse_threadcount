im_color = imread('resized_texrec082_center_1096.tiff');
im = im2gray(im_color(:,:,1:3));
stress_im = imread("stress image texrec_082_center.png");

%%
otsu_binary = GrayThresholding(im);
imshow(otsu_binary)

%%
[grad_X, grad_Y] = imgradientxy(im,"sobel");
subplot(1,2,1)
imshow(grad_X)
title('Gradient X',FontSize=20)
subplot(1,2,2)
imshow(grad_Y)
title('Gradient Y',FontSize=20)
%%
otsu_binary_stress = GrayThresholding(im2gray(stress_im));
subplot(3,1,1)
imshow(otsu_binary)
title('Direct thresholding using Otsu')
subplot(3,1,2)
imshow(otsu_binary_stress)
title('STRESS tresholding using Otsu')
subplot(3,1,3)
imshow(otsu_binary - otsu_binary_stress);
title('Difference image')

%% COUNTING THREAD FROM PATCH
imshow(otsu_binary_stress(1:295,1:295))
