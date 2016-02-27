function [axistoggle] = create_axis_toggle(togglecoordinates)
% togglecoordinates ::= [xoffset,yoffset,xwidth,ywidth] relative to the bottomleft corner
% [example]
%     myui([80, 0, 100, 20])
axistoggle = uicontrol('Style','radiobutton',...
                       'String','ShowAxes',...
                        'Value',1,...
                        'Position',togglecoordinates,...
                        'Callback',@toggleAxesVisibility)
end
function toggleAxesVisibility(hObject,callbackdata)
    if hObject.Value==1
        axis on
    else
        axis off
    end
end
