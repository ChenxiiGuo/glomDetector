# This is used to test the filter bank
# g_kernel = cv2.getGaborKernel((33, 33), 6, np.pi/4, 6, 3, 0, ktype=cv2.CV_32F)
# g_kernel = cv2.getGaborKernel((33, 33), 6, np.pi/4, 9, 3, 0, ktype=cv2.CV_32F)
# g_kernel = cv2.getGaborKernel((33, 33), 8, np.pi/4, 10, 3, 0, ktype=cv2.CV_32F)
# g_kernel = cv2.getGaborKernel((65, 65), 8, np.pi/4, 8, 3, 0, ktype=cv2.CV_32F)
from sklearn.cluster import KMeans
import cv2
import numpy as np
import pylab as pl
import os

from shoot import makeNewFolder


def areaCalculator(img):

    imgShape = img.shape
    #label which pixel have been detected
    hashLable = [[0 for col in range(imgShape[1])] for row in range(imgShape[0])]
    areaArrays = []
    for i in range(imgShape[0]):
        for j in range(imgShape[1]):
            if img[i][j] < 10 and hashLable[i][j] == 0:
                area = 0
                stack = []
                stack.append((i, j))
                while len(stack) != 0:
                    area += 1
                    cor = stack.pop()
                    y = cor[0]
                    x = cor[1]
                    hashLable[y][x] = 1
                    if y + 1 < imgShape[0] and img[y + 1][x] < 10 and hashLable[y + 1][x] != 1:
                        hashLable[y + 1][x] = 1
                        stack.append((y + 1, x))
                    if y - 1 >= 0 and img[y - 1][x] < 10 and hashLable[y - 1][x] != 1:
                        hashLable[y - 1][x] = 1
                        stack.append((y - 1, x))
                    if x + 1 < imgShape[1] and img[y][x + 1] < 10 and hashLable[y][x + 1] != 1:
                        hashLable[y][x + 1] = 1
                        stack.append((y, x + 1))
                    if x - 1 >= 0 and img[y][x - 1] < 10 and hashLable[y][x - 1] != 1:
                        hashLable[y][x - 1] = 1
                        stack.append((y, x - 1))
                areaArrays.append(area)
    return max(areaArrays)


def generate_filters(angle):
    filters = []
    filters.append(cv2.getGaborKernel((33, 33), 5, angle, 5, 3, 0, ktype=cv2.CV_32F))
    filters.append(cv2.getGaborKernel((33, 33), 6, angle, 9, 3, 0, ktype=cv2.CV_32F))
    filters.append(cv2.getGaborKernel((93, 93), 8, angle, 10, 3, 0, ktype=cv2.CV_32F))
    filters.append(cv2.getGaborKernel((103, 103), 13, angle, 13, 3, 0, ktype=cv2.CV_32F))

    return filters

def excuteFilter(srcImg, filterBank):
    fileredImgsArray = []
    waveLengths = [6, 9, 10, 13]
    for i in range(len(filterBank)):
        filteredImg = cv2.filter2D(srcImg, cv2.CV_8UC3, filterBank[i])
        filteredImg = cv2.GaussianBlur(filteredImg, (71, 71), 1 * waveLengths[i])
        fileredImgsArray.append(filteredImg)

    return fileredImgsArray

def offsetSmoothCell(srcImg, toBeOffset):
    g_kernel = cv2.getGaborKernel((103, 103), 10, np.pi, 12, 3, 0, ktype=cv2.CV_32F)
    filteredImg = cv2.filter2D(srcImg, cv2.CV_8UC3, g_kernel)
    filteredImg = cv2.GaussianBlur(filteredImg, (71, 71), 18)



def myKmean(img):
    temp = img.reshape((-1, 3))
    temp = np.float32(temp)
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0)
    K = 2
    ret, label, center = cv2.kmeans(temp, K, None, criteria, 10, cv2.KMEANS_RANDOM_CENTERS)
    center = np.uint8(center)
    colorA = center[0][0]
    colorB = center[1][0]
    colorA = 255 if colorA < colorB else 0
    colorB = 0 if colorA == 255 else 255
    center[0] = [colorA, colorA, colorA]
    center[1] = [colorB, colorB, colorB]
    res = center[label.flatten()]
    res2 = res.reshape(img.shape)

    return res2


def drawPlot(imgs, cols, rows):
    pl.figure(2, figsize=(54, 36))
    for i in range(len(imgs)):
        pl.subplot(cols, rows, i + 1)
        pl.imshow(imgs[i], cmap='gray')
    pl.savefig('report/showGabor.png')

def combineImagesAdd(imgsA, imgsB):
    res = np.zeros_like(imgsA[0])
    for i in range(len(imgsA)):
        np.maximum(res, imgsA[i], res)
        np.maximum(res, imgsB[i], res)
    return res

def combineImagesMin(imgsA, imgsB):
    res = np.zeros_like(imgsA[0])
    for i in range(len(imgsA)):
        temp = np.zeros_like(imgsA[0])
        np.maximum(temp, imgsA[i], temp)
        np.minimum(temp, imgsB[i], temp)
        np.maximum(res, temp, res)
    return res

#threeImgs: orig, filtered, segmented
def getResults(img):
    threeImgs = []

    filteredImgs0 = excuteFilter(img, generate_filters(0))
    filteredImgs90 = excuteFilter(img, generate_filters(np.pi / 2))
    filteredImgs45 = excuteFilter(img, generate_filters(np.pi / 4))
    filteredImgs135 = excuteFilter(img, generate_filters(np.pi / 4 * 3))

    combine0_90 = combineImagesMin(filteredImgs0, filteredImgs90)
    combine45_135 = combineImagesMin(filteredImgs45, filteredImgs135)
    filteredImg = combineImagesMin([combine0_90], [combine45_135])

    segmentedImg = myKmean(filteredImg)

    threeImgs.append(img)
    threeImgs.append(filteredImg)
    threeImgs.append(segmentedImg)
    return threeImgs

def compareGroundTruth(segArea, path):
    img = cv2.imread(path)
    try:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    except:
        return -1
    else:
        trueArea = 0
        for i in range(len(img)):
            for j in range(len(img[0])):
                if img[i][j] < 10:
                    trueArea += 1
        dif = abs(trueArea - segArea)
        difRate = dif / segArea
        return difRate



# srcImage/00106/line.jpg
# srcImage/00416/frame310.jpg
if __name__ =='__main__':
    folderName = "00371"
    fileName = "frame200.png"

    img = cv2.imread("srcImage/%s/%s" %(folderName, fileName))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    groundTruth = cv2.imread("groundTruthImage/%s/%s" % (folderName, fileName))
    #groundTruth = cv2.imread(groundTruth, cv2.COLOR_BGR2GRAY)

    #result: orig, filtered, segmented
    resultsArray = getResults(img)

    area = areaCalculator(resultsArray[2])
    print(area)

    difRate = compareGroundTruth(area, "groundTruthImage/" + folderName +"/"+ fileName)
    print(difRate)

    cv2.imwrite("filteredImg/%s/%s" %(folderName, fileName), resultsArray[1])
    cv2.imwrite("segmentedImg/%s/%s" %(folderName, fileName), resultsArray[2])

    resultsArray.append(groundTruth)
    drawPlot(resultsArray, 1, 4)


    #cv2.imshow('original retina', combineAlladd)
    #cv2.waitKey(0)
    #cv2.destroyAllWindows()






