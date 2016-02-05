function new_v_degree = new_camera_degree(h_current,h_starting,h_ending,...
                            v_starting,v_max)
%% constants
h_current = h_current;
h_starting = h_starting;
h_ending = h_ending;
h_totaldistance = abs(h_ending - h_starting);
h_distance = abs(h_ending - h_current);
h_percent_completed = h_distance/h_totaldistance;

v_totaldistance = v_max - v_starting
new_v_degree = v_starting + v_totaldistance * abs(sin(h_percent_completed * pi))
%new_v_degree = v_starting + v_totaldistance * .5*abs(sin(h_percent_completed * pi))



end