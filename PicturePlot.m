classdef PicturePlot
    properties
        picture_size % (float) How large each image should be
        imageHandles % (array) Handles for the object handles corresponding to each image
        uielements = struct() % A public field for storing user interface elements
        % Functions to create rotation matrix to rotate a homogenized point (x,y,z,1) by some amount specified in radians about X-Axis.
        Rx = @(rotationAroundX)[1,0,0,0
            0,cos(rotationAroundX),-sin(rotationAroundX),0
            0,sin(rotationAroundX),cos(rotationAroundX),0
            0,0,0,1];
        % Functions to create rotation matrix to rotate a homogenized point (x,y,z,1) by some amount specified in radians about Y-Axis.
        Ry = @(rotationAroundY)[cos(rotationAroundY),0,sin(rotationAroundY),0
            0,1,0,0
            -sin(rotationAroundY),0,cos(rotationAroundY),0
            0,0,0,1];
        % Functions to create rotation matrix to rotate a homogenized point (x,y,z,1) by some amount specified in radians about Z-Axis.
        Rz = @(rotationAroundZ)[cos(rotationAroundZ),-sin(rotationAroundZ),0,0
            sin(rotationAroundZ),cos(rotationAroundZ),0,0
            0,0,1,0
            0,0,0,1];
    end
    methods
        function [myPlotInstance] = PicturePlot(X,Y,Z,picturePaths,picture_size,varargin)
            % PicturePlot: Constructor Function
            % If the constructor function is overloaded, it follows close
            % to the matlab convention, alternating between the property
            % name to set and an array containing the value to set for that
            % property for each image.
            %
            %  [Example: Setting the edge colors for images] 
            %  X = [1:3]
            %  Y = [1:3]
            %  Z = [1:3]
            %  picturesize = 2
            %  picturePaths = {'./imgs/someimage1.png',
            %                  './imgs/someimage2.png',
            %                  './imgs/someimage3.png'}
            %  edgecolors = {'red', 'blue','green'}
            %  myPlotInstance = PicturePlot(X,Y,Z,...
            %                               picturePaths,...
            %                               picture_size,...
            %                               'EdgeColor',edgecolors)
            % 
            
            for dataindex = 1:length(X)
                myPlotInstance.imageHandles(dataindex) = myPlotInstance.addimg(...
                    X(dataindex),Y(dataindex),Z(dataindex),picture_size,picturePaths{dataindex});
                hold on
            end
            axis equal
            view([45,45])
            
            % Parse extra arguments if the construction function is
            % overloaded
            i = 1;
            argfound = false; % Flag for parsing extra arguments
            while i <= length(varargin)
                % if the constructor function is overloaded, then it should
                % take the matlab convention of alternating between the
                % propertyname to be set (ex: 'edgecolor') and an array that
                % of the values that the property names should be set to.
                switch (mod(i,2)==1) && ischar(class(varargin{i}))
                    case true
                        valuetoset = varargin{i};
                        argfound = true;
                    case false
                        if argfound
                            for j = 1:length(myPlotInstance.imageHandles)
                                valuetosetto = varargin{i}{j};
                                h_ = myPlotInstance.imageHandles(j);
                                set(h_,valuetoset,valuetosetto);
                            end
                            argfound = false;
                        end
                end
                i = i + 1;
            end
        end
        

        function [picture_handle] = addimg(obj,x,y,z,picture_size,imagename)
            % addimg: Adds an image to the plot.
            %     x = <scalar>
            %     y = <scalar>
            %     z = <scalar>
            %     picturesize = <scalar>
            %     imagename = <Path to the image>
            
            % The x data for the image corners
            xImage = [-picture_size, picture_size;...
                      -picture_size, picture_size];
            % The y data for the image corners
            yImage = [picture_size, picture_size;...
                     -picture_size -picture_size];
            % The z data for the image corners
            zImage = [0 0;
                      0 0];
            try
                img = imread(imagename);
                picture_handle = surf(xImage,yImage,zImage,'CData',img,'FaceColor','texturemap');
            catch me
                % In the case of an error, make the error message global,
                % and print the name of the image that caused either the
                % imread subroutine or the surf subroutine to fail
                global fup;
                fup = me
                fprintf('There was a problem reading file "%s"\n',imagename);
                keyboard
                rethrow(me)
            end
            clear img
            % 2. Add metadata for use in rotation of the image
            % a. add the homogenized coordinate vector for each of the image corners
            addprop(picture_handle,'corners');
            for i = 1:4
                picture_handle.corners(i).centeredv = [xImage(i)
                    yImage(i)
                    zImage(i)
                    1        ];
            end
            %    b. add property to store the xyz offset from the origin
            addprop(picture_handle, 'xyzoffset');
            picture_handle.xyzoffset.x = x;
            picture_handle.xyzoffset.y = y;
            picture_handle.xyzoffset.z = z;
            addprop(picture_handle, 'cornertranslationmatrices');
            picture_handle.cornertranslationmatrices.X = ones(2,2)*x;
            picture_handle.cornertranslationmatrices.Y = ones(2,2)*y;
            picture_handle.cornertranslationmatrices.Z = ones(2,2)*z;
            view([45,45])
            obj.rotatetocamera(picture_handle)
        end
        
        function rotatetocamera(obj, h)
            % rotatetocamera: Rotates the image frame to face the camera
            % Pull the data from the handle to get the homogenized vectors for each corner
            
            for i = 1:4
                d(i).v = h.corners(i).centeredv;
            end
            % Get the azimuth and elevation of camera in radians
            [az,el] = view;
            az = deg2rad(az);
            el = deg2rad(el);
            % Calculate the new cordinates of each corner
            newx = zeros(2,2);
            newy = zeros(2,2);
            newz = zeros(2,2);
            for i = 1:4
                switch i
                    case 1
                        r = 1;
                        c = 1;
                    case 2
                        r = 2;
                        c = 1;
                    case 3
                        r = 1;
                        c = 2;
                    case 4
                        r = 2;
                        c = 2;
                end
                % pivot about the x axis by the camera elevation
                h.corners(i).xrv  = obj.Rx((pi/2)-el)*d(i).v;
                % pivot about the z axis by the camera azimuth
                h.corners(i).xzrv = obj.Rz(az)*h.corners(i).xrv;
                % translate by the datacoordinate
                h.corners(i).afteroffset = h.corners(i).xzrv + [h.xyzoffset.x; h.xyzoffset.y; h.xyzoffset.z; 1];
                % refreshdata
                newx(r,c) = h.corners(i).afteroffset(1);
                newy(r,c) = h.corners(i).afteroffset(2);
                newz(r,c) = h.corners(i).afteroffset(3);
            end
            set(h,'XData',newx,'YData',newy,'ZData',newz)
        end
        function rotatealltocamera(obj,varargin)
            % ROTATEALLTOCAMERA: Loops over each image in the plot, and orient it to face the camera
            for i_ = 1:length(obj.imageHandles)
                tmphandle = handle(obj.imageHandles(i_));
                obj.rotatetocamera(tmphandle);
            end
        end
    end
end
