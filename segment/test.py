import time

import cv2
import os
import threading

import gaborSegment as gb
from shoot import makeNewFolder


def makefilteredAndSegFolder(imgFolders):
    for folder in imgFolders:
        segPath = "segmentedImg/" + folder
        filterPath = "filteredImg/" + folder
        makeNewFolder(segPath)
        makeNewFolder(filterPath)

def executeGabor(imgPath):
    groundTruthImgPath = imgPath.replace("srcImage", "groundTruthImage")
    filteredImgPath = imgPath.replace("srcImage", "filteredImg")
    segmentedImgPath = imgPath.replace("srcImage", "segmentedImg")

    img = cv2.imread(imgPath)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # result: orig, filtered, segmented
    resultsArray = gb.getResults(img)
    area = gb.areaCalculator(resultsArray[2])
    difRate = gb.compareGroundTruth(area, groundTruthImgPath)

    cv2.imwrite(filteredImgPath, resultsArray[1])
    cv2.imwrite(segmentedImgPath, resultsArray[2])

    return difRate

def imageRanges(difRateMap, imageArray, start, end):
    for i in range(start, end, 1):
        difRate = executeGabor(imageArray[i])
        difRateMap[imageArray[i]] = difRate

'''
def compareAll():
    difRateMap = {}
    imgFolders = []
    imgsArray = []
    path = "srcImage"
    for f in os.listdir(path):
        if f[0] == '.':
            continue
        imgFolders.append(f)

    makefilteredAndSegFolder(imgFolders)

    for folder in imgFolders:
        imgFolderPath = path + "/" + folder
        for imgPath in os.listdir(imgFolderPath):
            if imgPath[0] == '.':
                continue
            imgFullPath = imgFolderPath + "/" + imgPath
            imgsArray.append(imgFullPath)

    mid = int(len(imgsArray) / 2)
    threads = []
    t1 = threading.Thread(target=imageRanges, args=(difRateMap, imgsArray, 0, mid))
    threads.append(t1)
    t2 = threading.Thread(target=imageRanges, args=(difRateMap, imgsArray, mid, len(imgsArray)))
    threads.append(t2)

    for t in threads:
        #t.setDaemon(True)
        t.start()
    t.join()

    return difRateMap

'''
def compareAll():
    difRateMap = {}
    imgFolders = []
    path = "srcImage"
    for f in os.listdir(path):
        if f[0] == '.':
            continue
        imgFolders.append(f)

    makefilteredAndSegFolder(imgFolders)

    for folder in imgFolders:
        imgFolderPath = path + "/" + folder
        for imgPath in os.listdir(imgFolderPath):
            if imgPath[0] == '.':
                continue
            print(imgFolderPath + "/" + imgPath)
            difRate = executeGabor(imgFolderPath + "/" + imgPath)
            difRateMap[imgFolderPath + "/" + imgPath] = difRate

    return difRateMap


start = time.clock()
testResultsMap = compareAll()
end = time.clock()
spend = end - start

for key in testResultsMap:
    print(key + "'s difference rate is")
    print(testResultsMap[key])

print(spend)





