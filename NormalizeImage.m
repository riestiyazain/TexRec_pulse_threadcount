function image = NormalizeImage(image)
    image = (image - min(image,[],"all"))/(max(image,[],"all")-min(image,[],"all"));
%     figure, imshow(image)
%     title("Normalized image")
end
