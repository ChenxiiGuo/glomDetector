%This program is used to make videos.

%test('origs')
%varargin{1}: original video url
%varargin{2}: single video(not plot) url's destfolder
%varargin{3}: single video(withplot) url's destfolder
%varargin{4}: fps
% 
% function processImages(varargin)
%     clf;
%     areaArray = makeVideo(varargin{1}, varargin{2}, varargin{4});
%     clf;
%     combineVideo(areaArray, varargin{2}, varargin{3}, 24);
% end


% areaArray = makeVideo('data\videos\00363.mpg','data\segVideos\00363_test.avi', 50);
% 
% areaArray = cleanData(areaArray);
% combineVideo(areaArray, 'data\segVideos\00363_test.avi', 'data\segVideos\00363_test_combine.avi', 50);

%areaArray = getPureArray('data\videos\00400.mpg');
%saveArray(areaArray, 'test.txt');
%drawPlot(areaArray);

%model: 1: plot + txt; 2: plot + txt + pureVideo 3: plot + txt +
%pureVideo + combineVideo
%mainFunction('3','data\videos\00366.mpg','data\testMain\00366.avi', 'data\testMain\00366_combine.avi', 'data\testMain\area.txt', 'data\testMain\vol.txt', 'data\testMain\area.png', 'data\testMain\vol.png')
function outPut(varargin)
    mainFunction(varargin{1}, varargin{2}, varargin{3}, varargin{4},varargin{5}, varargin{6}, varargin{7}, varargin{8})
end



function mainFunction(model, sourceVideo, pureVideoPath,comVideoPath, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath) 
    warning('off', 'all');
    set(gcf, 'visible', 'off');
    if model == '1'
        generatePlotTxt(sourceVideo, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath);
    end
    
    if model == '2'
        clf;
        generatePureVideo(sourceVideo, pureVideoPath, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath);
    end
    
    if model == '3'
        clf;
        generateComVideo(sourceVideo, pureVideoPath,comVideoPath, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath);
    end

end

function generatePlotTxt(sourceVideo, txtAreaPath,txtVolPath,plotAreaPath, plotVolPath)
    areaArray = getPureArray(sourceVideo);
    printPlotTxt(areaArray, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath)
end

function generatePureVideo(sourceVideo, pureVideoPath, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath)
    areaArray = makeVideo(sourceVideo, pureVideoPath);
    printPlotTxt(areaArray, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath);
end
function generateComVideo(sourceVideo, pureVideoPath,comVideoPath, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath)
    areaArray = makeVideo(sourceVideo, pureVideoPath);
    combineVideo(areaArray, pureVideoPath, comVideoPath);
    printPlotTxt(areaArray, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath);
end

function printPlotTxt(areaArray, txtAreaPath,txtVolPath, plotAreaPath, plotVolPath)
    saveArray(areaArray, txtAreaPath);
    volumeArray = ((areaArray./3.1416).^(1.5)) * 4.18879;
    saveArray(volumeArray, txtVolPath);
    drawPlot(areaArray, plotAreaPath);
    drawPlot(volumeArray, plotVolPath);
end

function combineVideo(areaArray, glomVideoPath, resultPath)
    %read video
    clf;
    
    glomVideo = VideoReader(glomVideoPath);
    volumeArray = ((areaArray./3.1416).^(1.5)) * 4.18879;
    videoInfo = get(glomVideo );
    origFrameRate = videoInfo.FrameRate;
    
    %set plot
    h = animatedline;
    %axis([0,length(volumeArray),min(volumeArray)*0.9, max(volumeArray)*1.1]);
    
    %set video 
    outputVideo = VideoWriter(resultPath);
    outputVideo.FrameRate = origFrameRate;
    open(outputVideo);

    ii = 1;

    while hasFrame(glomVideo)
        glomImage = readFrame(glomVideo);
        glomImage = imresize(glomImage, [576, 1024]);
        addpoints(h,ii,volumeArray(ii));
        
        drawnow;
        
        curFrame = getframe(gcf);
        
        plotImage = curFrame.cdata;
        plotImage = imresize(plotImage, [576, 700]);
        
        combineImage = cat(2, glomImage, plotImage);
        
        %add text part
        blackImage = zeros(150, 1724, 3, 'uint8');
        textFps = 'Current fps:';
        testFpsVal = num2str(origFrameRate);
        
        textFrame = 'Frame:';
        textFrameVal = num2str(ii);
        
        textArea = 'Area:';
        textAreaVal = num2str(int32(areaArray(1 + (ii - mod(ii,origFrameRate)))));
        
        textVol = 'Volume:';
        textVolVal = num2str(int32(volumeArray(1 + (ii - mod(ii, origFrameRate)))));
        
        blackImage = insertText(blackImage, [100, 50], textFps, 'FontSize', 30, 'BoxColor', 'black','TextColor', 'Green');
        blackImage = insertText(blackImage, [280, 50], testFpsVal, 'FontSize', 30, 'BoxColor', 'black','TextColor', 'Green');

        blackImage = insertText(blackImage, [600, 50], textFrame, 'FontSize', 30, 'BoxColor', 'black','TextColor', 'Green');
        blackImage = insertText(blackImage, [710, 50], textFrameVal, 'FontSize', 30, 'BoxColor', 'black','TextColor', 'Green');

        blackImage = insertText(blackImage, [1000, 50], textArea, 'FontSize', 30, 'BoxColor', 'black','TextColor', 'Green');
        
        blackImage = insertText(blackImage, [1090, 50], textAreaVal, 'FontSize', 30, 'BoxColor', 'black','TextColor', 'Green');

        blackImage = insertText(blackImage, [1300, 50], textVol, 'FontSize', 30, 'BoxColor', 'black','TextColor', 'Green');
        blackImage = insertText(blackImage, [1430, 50], textVolVal, 'FontSize', 30, 'BoxColor', 'black','TextColor', 'Green');

        combineImage = cat(1, combineImage, blackImage);

        writeVideo(outputVideo, combineImage);

        if ii < length(areaArray)
            ii = ii + 1;
        end
    end

    
end




function areaArray = makeVideo(videoPath, resultPath) 
%genarate a video and also return an array which contains the area of glom
    clf;
    origVideo = VideoReader(videoPath);
    videoInfo = get(origVideo);
    origFrameRate = videoInfo.FrameRate;
    ii = 1;
    data = load(['myNets\segTest53\', 'net.mat']);
    net = data.net;
    
    %make a video
    outputVideo = VideoWriter(resultPath);
    outputVideo.FrameRate = origFrameRate;
    open(outputVideo);
    
    areaArray = [];

    while hasFrame(origVideo)
       clf;
       rawImage = readFrame(origVideo);
       %resize and make it suitable for the CNN
       origImage = imresize(rawImage, [288, 512]);
       %segment image
       segRes = semanticseg(origImage, net);
       segImage = uint8(segRes);
       segImage = segImage.*60;
       %combine the orignal image and segmented image
       [frame, area] = getOneFrame(origImage, segImage, 1);
       
       areaArray = [areaArray, area];
       if size(frame) == [288 512 3]
           writeVideo(outputVideo,frame);
       end


       ii = ii+1;
    end
    close(outputVideo);
end

function [frame, area] = getOneFrame(orig, segImage, hasOutline)
    glom = segImage;
    needle = segImage;
    
    %glomPart = seg;
    glom(glom ~= 60) = 0;
    glom(glom == 60) = 255;
    
    needle(needle ~= 120) = 0;
    needle(needle == 120) = 255;
    
    thresholdGlom = bwarea(glom) * 0.5;
    thresholdNeedle = bwarea(needle) * 0.5;
    %remove some small part
    glom = bwareaopen(glom, round(thresholdGlom));
    needle = bwareaopen(needle, round(thresholdNeedle) );
    
    area = bwarea(glom);

    
    [BofGlom, LofGlom] = bwboundaries(glom, 'noholes');
    [BofNeedle, LofNeedle] = bwboundaries(needle, 'noholes');
    
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
        %imshow(orig);
        hold off
        F=getframe(gcf);
        frame = F.cdata;
        
        %imwrite(F.cdata,'test1.png')
    else
        frame = orig;
    end
   
end

function areaArray =  getPureArray(videoPath)
    origVideo = VideoReader(videoPath);
    areaArray = [];
    data = load(['myNets\segTest53\', 'net.mat']);
    net = data.net;
    while hasFrame(origVideo)
        
        rawImage = readFrame(origVideo);
        origImage = imresize(rawImage, [288, 512]);
        %segment image
        segRes = semanticseg(origImage, net);
        segImage = uint8(segRes);
        segImage = segImage.*60;
        glom = segImage;
        glom(glom ~= 60) = 0;
        glom(glom == 60) = 255;
        
        thresholdGlom = bwarea(glom) * 0.5;
        %remove some small part
        glom = bwareaopen(glom, round(thresholdGlom));
        area = bwarea(glom);
        areaArray = [areaArray, area];
    end
end

function areaArray = cleanData(areaArray)
    for i = 5 : length(areaArray) - 4
        if (abs(areaArray(i) - areaArray(i - 4)) > 0.1 * areaArray(i - 4) && abs(areaArray(i) - areaArray(i + 4)) > 0.1 * areaArray(i + 4))
            areaArray(i) = (areaArray(i - 4) + areaArray(i + 4))*0.5;
        end
    end
end

function drawPlot(array, path)
    p = plot(array);
    saveas(p, path);
    
end
function saveArray(areaArray, path)
    index = 1:1:length(areaArray);
    time = index./50;
    A = [index; time; areaArray];
    fileID = fopen(path,'w');
    fprintf(fileID, '%u, %.2f, %.0f\r\n', A);
    fclose(fileID);
end
