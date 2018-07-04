# Introduction of this project

## Why do this project?

The glomeruli, a group of small vessels, work as a filter in the kidneys which is one of the most important organs purifying the blood. Currently, the Bristol Reanl Team is doing a research and in this research, this team needs to generate plots of how glomerular volume changes against time. As a result, they need to find the glomeruli and measure the volume of them frame by frame. To save time, this team seeks help from [Dr.Neill](http://www.bristol.ac.uk/engineering/people/neill-w-campbell/index.html) in University of Bristol and I am doing this project under the supervision of Dr.Neill.

This image shows the glomeruli.
![image](https://github.com/ChenxiiGuo/glomDetector/blob/master/Introduction/bigGlom.png)

## What is the added value of this project?

This image shows the difference between current method and improved method(The aim of this project).
![image](https://github.com/ChenxiiGuo/glomDetector/blob/master/Introduction/addedValue.png)

## Current progress

Gabor filters and K-means have been used and the result is exciting.

This image shows the original image.
![image](https://github.com/ChenxiiGuo/glomDetector/blob/master/Introduction/gabor_orig.png)

This image shows the image after gabor filters.
![image](https://github.com/ChenxiiGuo/glomDetector/blob/master/Introduction/gabor_mid.png)

This image shows the segmentation result.
![image](https://github.com/ChenxiiGuo/glomDetector/blob/master/Introduction/gabor_rusult.png)

## Future plan

The combination of gabor filters and k-means shows exciting result, but it still has lots of problems.

Firstly, it is too slow, generally in Matlab doing the segmentation for one image needs 15 seconds.

Secondly, for some low quality images, it works not well.

In the future, their are still at least these things to do.

1. Using CNNs to generate beter filters which can be robust enough to noises and also could quickly do image segmentation.

2. Comparing the human engineering methods and machine learning methods.
