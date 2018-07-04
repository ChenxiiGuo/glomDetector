import numpy as np
import copy
import cv2

# srcImg should be COLOR_BGR2GRAY
def areaCalculator(img):

    imgShape = img.shape
    #label which pixel have been detected
    hashLable = [[0 for col in range(imgShape[1])] for row in range(imgShape[0])]
    areaArrays = []
    for i in range(imgShape[0]):
        for j in range(imgShape[1]):
            if img[i][j] > 200 and hashLable[i][j] == 0:
                area = 0
                stack = []
                stack.append((i, j))
                while len(stack) != 0:
                    area += 1
                    cor = stack.pop()
                    y = cor[0]
                    x = cor[1]
                    hashLable[y][x] = 1
                    if y + 1 < imgShape[0] and img[y + 1][x] > 200 and hashLable[y + 1][x] != 1:
                        stack.append((y + 1, x))
                        hashLable[y + 1][x] = 1
                    if y - 1 >= 0 and img[y - 1][x] > 200 and hashLable[y - 1][x] != 1:
                        stack.append((y - 1, x))
                        hashLable[y - 1][x] = 1
                    if x + 1 < imgShape[1] and img[y][x + 1] > 200 and hashLable[y][x + 1] != 1:
                        stack.append((y, x + 1))
                        hashLable[y][x + 1] = 1
                    if x - 1 >= 0 and img[y][x - 1] > 200 and hashLable[y][x - 1] != 1:
                        stack.append((y, x - 1))
                        hashLable[y][x - 1] = 1
                areaArrays.append(area)
    print(areaArrays)
    return max(areaArrays)


img = cv2.imread('segmentedImg/standard.png')
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

area = areaCalculator(img)
print(area)

