# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 09:43:47 2017


based on largely on code originally created by Matt Hancock found at:
    
https://notmatthancock.github.io/2017/10/09/region-growing-wrapping-c.html

"""
import numpy as np

def grow(img, seed, t):
    
    """
    img: ndarray, ndim=3
        An image volume
        
    seed: tuple,len=3
        Region growing starts from this point.
        
    t: int
        The image neighborhood radius for the inclusion criteria
    """
    
    #Creates an array filled with zeros and a copy
    #seg is an array for the segmented cells
    #checked is an array to note pixels already taken into account for region growing
    seg= np.zeros(img.shape, dtype=np.bool)
    checked= np.zeros_like(seg)

    #Create a start point & mark it as checked
    seg[seed]=True
    checked[seed] = True

    #gets the coordinates of the neighborhood and returns a to check array
    needs_check = get_nbhd(seed, checked, img.shape)

    while len(needs_check)>0: #do as long there are neighberhoods to check
        
        pt=needs_check.pop()
        
        if checked[pt]: continue
    
        checked[pt] = True
        
        #Define boarders for checking the image values
        imin = max(pt[0]-t, 0)
        imax = min(pt[0]+t, img.shape[0]-1)
        jmin = max(pt[1]-t,0)
        jmax = min(pt[1]+t, img.shape[1]-1)
        
        if img[pt] >= img[imin:imax+1, jmin:jmax+1].mean():
            
            #if the value of the pixel is larger than the mean of the region
            #include the pixel in the segmentation and add its neighbors to be checked
            
            seg[pt]=True
            needs_check += get_nbhd(pt, checked, img.shape)
            
    return seg

def get_nbhd(pt,checked,dims):
    nbhd=[]
    
    if (pt[0] > 0) and not checked[pt[0]-1, pt[1]]:
        nbhd.append((pt[0]-1, pt[1]))
    if (pt[1] > 0) and not checked[pt[0], pt[1]]:
        nbhd.append((pt[0], pt[1]-1))
    #if (pt[2] > 0) and not checked[pt[0], pt[1], pt[2]-1]:
    #    nbhd.append((pt[0], pt[1], pt[2]-1))

    if (pt[0] < dims[0]-1) and not checked[pt[0]+1, pt[1]]:
        nbhd.append((pt[0]+1, pt[1]))
    if (pt[1] < dims[1]-1) and not checked[pt[0], pt[1]+1]:
        nbhd.append((pt[0], pt[1]+1))
    #if (pt[2] < dims[2]-1) and not checked[pt[0], pt[1], pt[2]+1]:
    #    nbhd.append((pt[0], pt[1], pt[2]+1))

    return nbhd