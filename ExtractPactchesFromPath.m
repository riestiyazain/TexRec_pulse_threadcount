function ExtractPactchesFromPath(path,patch_size)

    % cropping images to patch
    img = im2double(im2gray(imread(path)));
    % for 1x1 cm patch size is 120
    % patch_size = 120;
    
    % create a looper, contains coordinates for each patch, lagged
    % 0.5*patch_size for overlaps
    horizontal_looper = 1:patch_size/2:size(img,2)-(patch_size);
    vertical_looper = 1:patch_size/2:size(img,1)-(patch_size);
    coordinates = combvec(horizontal_looper,vertical_looper);
    
    parfor i=1:length(coordinates)
        patch = img(coordinates(2,i):coordinates(2,i)+patch_size-1,coordinates(1,i):coordinates(1,i)+patch_size-1);
        imwrite(patch, "images/Puzzled/"+string(i)+"_"+path);
    end
end