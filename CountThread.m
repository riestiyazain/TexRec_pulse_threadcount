function thread_count= CountThread(thresholded_image,direction,double_thread)
% count horizontal thread count by counting the number of pulse in vertical
% direction from the thresholded image (binary)
% requires square image 
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
    thread_count = mode(number_of_pulse/2);
    if double_thread==0
        thread_count = mode(number_of_pulse);
    end
%     vote for the majority pulse that agrees on each other the most
%     disp("majority number of pulse "+ string(horizontal_thread_count))
end