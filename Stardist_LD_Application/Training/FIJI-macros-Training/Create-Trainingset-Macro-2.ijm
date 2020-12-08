///This macro creates a mask for training with the stardist script
// Prerequesit: 	Images in tif format at least 250X250
// 					ROIs in the same folder with the same name, but suffix to identify them
// Output:			Is an image with 1 Value => 1 ROI

//whow does the ROIname differ from image name
ROIsuffix="-RoiSet.zip";


function processFolder(input, end){
	//Task: Process folder for images
	
	//1) Get a list of everything and iterate
	list=getFileList(input);
	for(i=0; i<list.length; i++){

		//if it ends with tif get path and pass to process
		if(endsWith(list[i], end)){
			img=input+list[i];			
			//print(img); //debugging point
			
			processImages(img);
			}	
		}
}


function processImages(imagepath){

	//open image and get ID
	open(imagepath);
	ImID=getImageID();

	//derive the path for ROIs
	name=File.getName(imagepath);
	name=substring(name, 0, lengthOf(name)-4);
	name=name+ROIsuffix;

	//get parent directory
	dir=File.getParent(imagepath);

	Roipath=dir+File.separator+name;
	
	//print(name);		//debugging
	//print(dir);		//debugging
	//print(Roipath);	//debugging

	//with the ROIpath and the ImageID create the masks and clean up
	MakeMaskForStardis(Roipath, ImID);
	run("Close All");
}

function MakeMaskForStardis(path, imageID){
	
	//Create a place to save masks if it doesn't exist yet
	maskpath=File.getParent(path);
	maskpath=File.getParent(maskpath);
	maskpath=maskpath+File.separator+"mask";	
	
	if (File.isDirectory(maskpath)==false){
		File.makeDirectory(maskpath);//creates a new folder
		}
	
	
	//get image title duplicate and save id of duplicate for mask
	selectImage(imageID);
	imageTitle=getTitle();
	name=substring(imageTitle, 0, lengthOf(imageTitle)-4);
	run("Select None");
	run("Duplicate...", "title="+name);
	selectWindow(name);
	maskId=getImageID();

	//create filename in path we created earlier
	maskpath=maskpath+File.separator+name+".tif";
	
	//make every pixel 0 and 16-bit in 
	selectImage(maskId);
	run("Multiply...", "value=0");
	run("16-bit");

	//open Roimanager and count the number of rois
	roiManager("reset");
	roiManager("open", path);
	kcount=roiManager("count");
	kmax=kcount-1;
	print(kmax);
	
	//run through all Rois select each one 
	//make selection a running number value mask by overwriting previous values
		for (k=0;k<kmax;k++){
			roiManager("select", k);
			run("Multiply...", "value=0");
			run("Add...", "value="+k+1);
		}
	
	//save masked image
	saveAs("Tiff", maskpath);
}

///Start of actual script///
//remove everything that might be open
run("Close All");

//get the target directory
location=getDirectory("Titleimage");
setBatchMode(true);



//print("Ia! Ia! Shub-Nigurath");
//print(location); //debugging print

//starts the macro
processFolder(location, ".tif");

//Finish statement
print("Done");