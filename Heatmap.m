function Heatmap(img,gray_thresholding, horizontal_threads,vertical_threads)
% note that some of the background is having 0 thread count, we exclude
% this from the mean
mean_hor = sum(horizontal_threads,"all")/numel(find(horizontal_threads ~= 0));
mean_ver = sum(vertical_threads,"all")/numel(find(vertical_threads ~= 0));
deviation_hor = horizontal_threads - mean_hor;
deviation_ver = vertical_threads - mean_ver;
figure,subplot(3,2,1)
imshow(img)
subplot(3,2,2)
imshow(gray_thresholding)
subplot(3,2,3)
heatmap(horizontal_threads,"Title","Horizontal threads: "+ string(mean_hor)+" /cm2",FontSize=16)
subplot(3,2,4)
heatmap(vertical_threads,"Title","Vertical threads "+ string(mean_ver)+" /cm2", FontSize=16)
subplot(3,2,5)
heatmap(deviation_hor,"Title","Horizontal thread density deviation",FontSize=16)
subplot(3,2,6)
heatmap(deviation_ver,"Title","Vertical thread density deviation",FontSize=16)
end