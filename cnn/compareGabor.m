% This one will not save any images, it will generate the segmented video
% directly
clc;
clf;
clear;
makeVideo('data\videos\00416.mpg','data\compareVideos\00416.avi', 'data\gaborResults\00416', 20);

%areaArray = cleanData(areaArray);

%generatePlotMakeVideo(areaArray, 'data\compareVideos\00371_plot.avi', 20);

function generatePlotMakeVideo(areaArray, resultPath, freq)
    clf
    h = animatedline;
    axis([0,length(areaArray),min(areaArray)*0.9, max(areaArray)*1.1]);
    %axis autoy
    %axis([0,4*pi,-1,1]) 
    
    %make a video
    outputVideo = VideoWriter(resultPath);
    outputVideo.FrameRate = freq;
    open(outputVideo);


    for k = 1:length(areaArray)
        %disp(k);
        addpoints(h,k,areaArray(k));
        drawnow
        curFrame = getframe(gcf);
        %imwrite(curFrame.cdata,'test2.png')
        writeVideo(outputVideo, curFrame.cdata);
    end
    close(outputVideo);

end

%This function is used to remove some weird(too small or too big) data in the areaArray.
function areaArray = cleanData(areaArray)
    for i = 3 : length(areaArray) - 2
        if (abs(areaArray(i) - areaArray(i - 2)) > 0.1 * areaArray(i - 2) && abs(areaArray(i) - areaArray(i + 2)) > 0.1 * areaArray(i + 2))
            areaArray(i) = (areaArray(i - 2) + areaArray(i + 2))*0.5;
        end
    end
end


function areaArray = makeVideo(videoPath, resultPath,gaborPath, freq) 
%genarate a video and also return an array which contains the area of glom
    clf;
    dirOutput=dir(fullfile(gaborPath,'*.png'));
    %imageNames={dirOutput.name}';
    limit = length(dirOutput);
    ii = 1;
 
    origVideo = VideoReader(videoPath);
    data = load('net.mat');
    net = data.net;
    
    %make a video
    outputVideo = VideoWriter(resultPath);
    outputVideo.FrameRate = freq;
    open(outputVideo);
    
    areaArray = [];

    while hasFrame(origVideo)
       disp (gaborPath);
       
       path = [gaborPath, '\frame', num2str(ii), '.png'];
       disp (ii);
       gaborImage = imread(path);
     
       rawImage = readFrame(origVideo);
       %resize and make it suitable for the CNN
       origImage = imresize(rawImage, [288, 512]);
       %segment image
       segRes = semanticseg(origImage, net);
       segImage = uint8(segRes);
       segImage = segImage.*60;
       %combine the orignal image and segmented image
       [frame , area] = getOneFrame(origImage, segImage, gaborImage, 1);
       areaArray = [areaArray, area];
       writeVideo(outputVideo,frame);

       if ii < limit - 1
            ii = ii+1;
       end
    end
    close(outputVideo);
end

function [frame, area] = getOneFrame(orig, segImage, gaborImage, hasOutline)
    glom = segImage;
    needle = segImage;
    
    gaborCompare = im2bw(gaborImage);
    gaborCompare = imresize(gaborCompare, [288, 512]);
    
    %glomPart = seg;
    glom(glom ~= 60) = 0;
    glom(glom == 60) = 255;
    
    needle(needle ~= 120) = 0;
    needle(needle == 120) = 255;
    
    
    
    %remove some small part
    glom = bwareaopen(glom, 400);
    needle = bwareaopen(needle, 400);
    
    area = bwarea(glom);

    
    [BofGlom, LofGlom] = bwboundaries(glom, 'noholes');
    [BofNeedle, LofNeedle] = bwboundaries(needle, 'noholes');
    [BofGabor, LofGabor] = bwboundaries(gaborCompare);
    
    figure('visible','off'), imshow(orig, 'Border','tight');
    %decide whether show the 
    if (hasOutline ~= 0)
        hold on
        for k = 1 : length(BofGlom)
        boundary = BofGlom{k};
        plot(boundary(:,2), boundary(:,1),"g", "LineWidth", 2);
        end
        
        for k = 1 : length(BofNeedle)
            boundary = BofNeedle{k};
            plot(boundary(:,2), boundary(:,1),"b", "LineWidth", 2);
        end
        
        for k = 1 : length(BofGabor)
            boundary = BofGabor{k};
            disp(boundary);
            if boundary(1) ~= 1 && boundary(1) ~= 288 && boundary(2) ~= 1 && boundary(2) ~= 512
                plot(boundary(:,2), boundary(:,1),"r", "LineWidth", 2);
            end    
        end
        %imshow(orig);
        hold off
        F=getframe(gcf);
        frame = F.cdata;
        %imwrite(F.cdata,'test1.png')
    else
        frame = orig;
    end
   
end