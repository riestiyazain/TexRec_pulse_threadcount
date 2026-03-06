function blurredImage = BlurImage(I, windowWidth)
   % windowWidth Whatever you want.  More blur for larger numbers.
    kernel = ones(windowWidth) / windowWidth ^ 2;
    blurredImage = imfilter(I, kernel); % Blur the image.
%     figure, imshow(blurredImage); % Display it.
%     title("Blurred image result")
end