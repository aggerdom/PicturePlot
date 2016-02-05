close all
clear all
demoimages = {'coins.png',...
    'coloredChips.png',...
    'concordaerial.png',...
    'concordorthophoto.png',...
    'fabric.png',...
    'gantrycrane.png',...
    'glass.png',...
    'hestain.png',...
    'liftingbody.png',...
    'onion.png', ...
    'pears.png',...
    'pillsetc.png',...
    'rice.png',... 
    'saturn.png', ...
    'snowflakes.png', ...
    'tape.png', ...
    'testpat1.png', ...
    'tissue.png', ...
    'toyobjects.png', ...
    'toysflash.png', ...
    'toysnoflash.png', ...
    'westconcordaerial.png', ...
    'westconcordorthophoto.png'}

d = randi([-10,10],[length(demoimages),3]);
imagecoords.X = d(:,1);
imagecoords.Y = d(:,2);
imagecoords.Z = d(:,3);

myplotinstance = PicturePlot(imagecoords.X,imagecoords.Y,imagecoords.Z,demoimages',2)

%% Add some UI elements to make it more easy to work with and do some other
% stuff ot the plot
axis('vis3d') % enable rigid rotations, and disable auto scaling of axes




%% Add a button to rotate the images to face the camera
% the function  add_rotate_to_camera_button('myplotinstance') also works 
% but the position needs to be fixed in that function definition
rotateAllButton = uicontrol(...,
     'Style','pushbutton',...
     'String','RotateToCamera',...
     'Position',[200 0 200 20],...
     'Callback','myplotinstance.rotatealltocamera()');

%% View Control Buttons: Buttons that move the camera to face the xyplane, xzplane, and yz plane
xzViewButton = uicontrol(...,
    'Style','pushbutton',...
    'String','view XZ',...
    'Position',[0 0 60 20],...
    'Callback','view([0,0])');
yzViewButton = uicontrol(...,
    'Style','pushbutton',...
    'String','view YZ',...
    'Position',[0 20 60 20],...
    'Callback','view([90,0])');
xyViewButton = uicontrol(...,
    'Style','pushbutton',...
    'String','view XY',...
    'Position',[0 40 60 20],...
    'Callback','view([0,90])');


%% Radio Button to Toggle The Display of Axes On and Off.
% A potentially good extension of this would be the use quiver3 to draw the
% axes in using arrows
axistoggle = uicontrol(...
    'Style','radiobutton',...
    'String','Show Axes',... % Label for the button
    'Value',1,...            % Default to checked
    'Position',[80 0 100 20],... % [xoffset,yoffset,xwidth,ywidth] relative to the bottomleft corner
    'Callback',...
    ['if axistoggle.Value==1;',...
    'axis on;',...
    'else;',...
    'axis off;',...
    'end']); % note that I'm just joining joining these statements and matlab is calling eval on the result

%% Toggle to control whether rotation events caused by the user also
% cause the images to pivot after the camera has stopped moving.
% Ideally I would have it so that the images pivot continuously as the plot
% is moving but the code in the myplotclass file needs to be cleaned up to
% make the operations more efficient.Things could also be sped up by using 
% smaller image files. Right now the image files are rather large,
% which may slow things since matlab is handling lighting as its working. 
% Other approaches might be to change the camera mode and rendering.
% Some kind of shift is needed when the step comes to export the figure.
% (From zbuffer to painters? I'll have to check the export figure code that
% will be coming along shortly). 

quote=''''; % equivalent to a single quotation mark
rotationFollowToggleVar = rotate3d;
followRotationToggle = uicontrol(...
    'Style','radiobutton',...
    'String','followcamera',... % Label for the button
    'Value',0,...            % Default to checked
    'Position',[80 20 100 20],... % [xoffset,yoffset,xwidth,ywidth] relative to the bottomleft corner
    'Callback',...
    [...
     'if followRotationToggle.Value==1;',...
         ['rotationFollowToggleVar.ActionPostCallback = ',quote,'myplotinstance.rotatealltocamera()',quote,';'],...% rotationFollowToggleVar.ActionPostCallback = 'myplotinstance.rotatealltocamera()';
     'else;',...
         ['rotationFollowToggleVar.ActionPostCallback = ',quote,quote,';'],...                                      % rotationFollowToggleVar.ActionPostCallback = '';
     'end'...
    ]); % note that I'm just joining joining these statements and matlab is calling eval on the result