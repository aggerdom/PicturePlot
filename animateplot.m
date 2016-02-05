settings = 2;
if settings == 1
    
    box off
    h_starting = 65;
    h_ending = 170;
    h_current = h_starting;
    direction = 1;
    change_amount = 1;
    pause_per_degree = .05;
    number_of_rotations = 1;
    max_rotations = 2;
    
    v_starting = 30;
elseif settings == 2
    
    box on
    direction = 1;%used to make return
    change_amount = 1;%degrees per step (constant)
    max_rotations = 2;
    pause_per_degree = .05;%how long to wait on each frame
        
    h_starting = 0;
    h_ending = 360;
    h_totaldistance = abs(h_ending - h_starting);%how far will the camera rotate
    h_current = h_starting; %camera position that changes
    
    camera_rotation_mode = 1
    v_starting = 0;%starting vertical angle
    v_max = 30;%peak vertical angle
    
end


%%


number_of_rotations = 1;
while number_of_rotations ~= max_rotations
    if camera_rotation_mode == 1
        view(h_current, new_camera_degree(h_current,h_starting,h_ending,v_starting,v_max));%move the camera
        
    else
        view(current_degree, v_starting); %
    end
    %view(current_degree, camera_vertical_angle + abs(sin(current_degree/240))); %
    %view(current_degree, new_position(current_degree)); %
    
    if direction == 1
        h_current = h_current + change_amount;
        if h_current == h_ending
            direction = -1;%reverse
        end
    else
        h_current = h_current - change_amount;
        if h_current == h_starting
            direction = 1;
            pause(pause_per_degree*3);
            number_of_rotations  = number_of_rotations + 1
        end
    end
    pause(pause_per_degree);
end

%Figure out how to get this to work for all function handles