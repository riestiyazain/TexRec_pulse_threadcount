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