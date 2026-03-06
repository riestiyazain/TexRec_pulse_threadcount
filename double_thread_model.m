i = imgaussfilt(im2gray(imread('Double threaded yarn - rotated.png')),7);
t = GrayThresholding(i);

%%
tiledlayout(3,2)
imshow(i)
title('example of double thread',FontSize=18)
nexttile 
imshow(i(350:450,:))
title('horizontal strip of double thread',FontSize=16)
nexttile
imshow(t(350:450,:))
title('horizontal strip of double thread - tresholded',FontSize=16)
nexttile
plot(t(375,:),LineWidth=2)
title('pulse from the middle of the horizontal strip',FontSize=16)
ylim([-1,2])
nexttile
Q = t(375,:);
plot(abs(diff(Q)),LineWidth=2)
ylim([-1,2])
pulsefront = find(abs(diff(Q)));
title("number of pulse: "+string(length(pulsefront)/2),FontSize=16)

%% 
subplot(3,2,1)
imshow(i)
title('example of double thread',FontSize=18)
subplot(3,2,2)  
imshow(i(350:450,:))
title('horizontal strip of double thread',FontSize=18)
subplot(3,2,3)
imshow(t(350:450,:))
title('horizontal strip of double thread - tresholded',FontSize=18)
subplot(3,2,4)
plot(t(375,:),LineWidth=2)
title('pulse extracted from the middle of the horizontal strip',FontSize=18)
ylim([-1,2])
subplot(3,2,5)
Q = t(375,:);
plot(abs(diff(Q)),LineWidth=2)
ylim([-1,2])
pulsefront = find(abs(diff(Q)));
title("number of pulse: "+string(length(pulsefront)/2))

%% 
Q = t(375,:);
plot(abs(diff(Q)))
ylim([-1,2])
%%
close all; clc;clear