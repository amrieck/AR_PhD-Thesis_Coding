# -*- coding: utf-8 -*-
"""
Created on Tue Jan  9 12:41:18 2018


Code is largely based on Matt Hancock's code to be found at:
    
https://notmatthancock.github.io/2017/10/09/region-growing-wrapping-c.html

Please cite original source.
"""
from PIL import Image
import pandas as pd
from tkinter import Tk
from tkinter.filedialog import askdirectory
from tkinter import ttk
from tkinter import messagebox
import time
import Segmentation2D as rgp
import numpy as np
import os.path

class Entrymask:
    
    def __init__(self, master):
        self.master= master
        master.title("Experiment Entry") #Starts Window
        
        self.entry_button= ttk.Button(master, text = "Enter", command=self.update) #Fires Enter Button
        self.quit_button= ttk.Button(master, text= "Quit", command= self.master.destroy) #Fires Quit Button
        
        #Layout
        self.entry_button.grid(row=3, column=1, columnspan=2)
        self.quit_button.grid(row=3, column= 3)
    
    def filewalker(self, path):  
        
        #Declaration of two lists 
        # A: Maxima .csv
        # B: source images
        
        self.path=path
        Entrymask.lmaxima = []
        Entrymask.lsourceImg =[]

        #Ideally there should be as many Images as maxima coordinates
        #Simple filewalker 
        for root, dirs, files in os.walk(self.path): 
        
            for name in files:
                
                if name.endswith("maxima.csv"):
                    
                    Entrymask.lmaxima.append(os.path.join(root,name))
    
            for name in files:
                
                if name.endswith("Matrix.tif"):
                    
                    Entrymask.lsourceImg.append(os.path.join(root,name))


    
    def update(self):
        
        #Just a reminder what should be select....
        messagebox.showinfo("Please", "Select Experimental Directory")
        
        #Ask for the path for the filewalker
        self.filewalkerpath=askdirectory()
        self.filewalker(self.filewalkerpath)
        
        #Call instance of imagesegmentation class see end of Script
        regentgrow=imagesegmentation(seed_table) 
        
        
    
        
class imagesegmentation(Entrymask):
    
    def __init__(self, Entrymask):
        
        #Just for time measuring. First iteration needed 5 hours...
        self.start=time.time()
        
        #Main Loop for every image and maxima coordinates
        for i in range(len(Entrymask.lmaxima)):
            self.loading(i) #Loads the lists obtained in the filewalker
            print(Entrymask.lmaxima[i])
            print(Entrymask.lsourceImg[i])
            self.regiongrowing() #actual Regiongrowing => Array of region growing
            self.finim = Image.fromarray(self.segim) #Transform array in image

            
            self.save_path=os.path.splitext(Entrymask.lmaxima[i])[0]
            self.finim.save(self.save_path+"grow.tif") #Save Tiff
            
            self.stop=time.time() #eta 300-500 sec per experiment
        
        print("Elapsed time: %.3f seconds."% (self.stop-self.start)) #last debug
        
            
    def loading (self, itera):
        
        #loads the csv of iteration a in dataframe df
        #Loads the image of iteration a in image im
     
        self.itera = itera
        self.df = pd.read_csv(Entrymask.lmaxima[self.itera])
        self.im = Image.open(Entrymask.lsourceImg[self.itera])
        
        #print(Entrymask.lmaxima)
        #print(Entrymask.lsourceImg) #first print debugging checkpoint
        
    def regiongrowing(self):
        
        #Declaration of counter Boolean array und mask precoursor segim 
        self.rowcounter=0           
        self.imarray = np.array(self.im)
        self.segim= self.imarray*0
        
        #print(self.segim) #Just check if image is really empty and running #second debug point
    
        for row in self.df.itertuples():
           
           self.seed=(getattr(row,"Y"), getattr(row,"X"))
           
           if self.imarray[self.seed]== 0: #weeds out maxima without value
               continue
           
           self.seg= rgp.grow(self.imarray,self.seed, 2) #this is the actual region growing
           
           self.segim= self.segim + self.seg #adds the region obtained by the growing to a bigger array
           self.rowcounter= self.rowcounter+1
           #print("Rowcounter: "+repr(self.rowcounter)) #third debug point
           
           
root = Tk() #invokes instance of TK
seed_table = Entrymask(root) # starts user interface in that instance of TK
root.mainloop() #maintains user interface until destroys
   
        
