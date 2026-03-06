function BW = GrayThresholding(blurredImage)
    level = graythresh(blurredImage);
    BW = imbinarize(blurredImage,level);
%     figure, imshowpair(blurredImage,BW,'montage')
end