# this is used to take screen shots
import cv2
import os

def makeNewFolder(url):
    if not os.path.exists(url):
        os.makedirs(url)


# freq is the sample rate of a video
def takeScreenShot(freq, name):
    cap = cv2.VideoCapture(name)
    if (cap.isOpened() == False):
        print("Error opening video stream or file")
    str = name.split('/')
    folderName = str[1].split('.')[0]
    success, image = cap.read()
    count = 0
    success = True

    makeNewFolder("srcImage/%s" %(folderName))
    while success:
        if count % freq == 0:
            image = cv2.resize(image, dsize=(800, 450))
            cv2.imwrite("srcImage/%s/frame%d.png" %(folderName, count), image)
            # save frame as JPEG file
        success, image = cap.read()
        print('Read a new frame: ', success)
        count += 1

if __name__ =='__main__':
    takeScreenShot(10, "videos/00411.mpg")
    takeScreenShot(10, "videos/00416.mpg")
    takeScreenShot(10, "videos/00436.mpg")
    takeScreenShot(10, "videos/00453.mpg")
