#This program is used to choose paramaters
import cv2
import numpy as np
import pylab as pl

def generate_filters():
    filters = []
    for sigma in range(2, 20, 1):
        for waveLength in range(2, 20, 1):
            kern = cv2.getGaborKernel((401, 401), sigma, np.pi, waveLength, 3, 0, ktype=cv2.CV_32F)
            filters.append(kern)
    return filters

def excuteFilter(srcImg, filterBank):
    fileredImgs = []
    for kern in filterBank:
        fileredImgs.append(cv2.filter2D(srcImg, cv2.CV_8UC3, kern))
    return fileredImgs

img = cv2.imread('srcImage/00416/frame310.jpg')
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

filteredImgs = excuteFilter(img, generate_filters())

pl.figure(2, figsize=(48, 36))
for i in range(len(filteredImgs)):
    pl.subplot(18, 18, i + 1)
    pl.imshow(filteredImgs[i], cmap='gray')
    pl.savefig('report/plotchoose.png')
