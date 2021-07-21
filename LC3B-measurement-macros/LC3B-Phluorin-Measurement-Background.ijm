//This macro creates measurements and tries to save them in a comprehendable form
//Input:	Is the ROI with the same name, but different endpart
//Output: 	Measurement in an csv that can be used with csvsorter.py

//Run through the subfolder and process everyimage

Roisuffix="01_LC3B_rois.zip";
Imagesuffix="01.tif";
infotitle=false;

function processFolder(input, end){
	//processes folder
	
	//image=false;
	list=getFileList(input);
	//gets all files
	for(i=0; i<list.length; i++){
		
		//run subdir
		if(File.isDirectory(input+list[i])){
			processFolder(input+list[i], end);
			}
		
		//parses folder for tif files
		if(endsWith(list[i], end)){
			
			filedat=input+list[i];
			//print(filedat);
			
			//opens the image and measures LDs
			measureLD(filedat);

			//opens the image and measures cell background
			//Comented out when measuring the mKAte signal
			//measureCellBackground(filedat);
			}	
		}
}

//measuring function
function measureCellBackground(img){

	open(img);
	originalID=getImageID();

	//savetitle and folder
	savetitle=substring(img,0,(lengthOf(img)-4));

	run("Duplicate...", " ");
	
	run("Median...", "radius=2");
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Analyze Particles...", "size=20-Infinity display clear add");

	selectImage(originalID);
	n=roiManager("count");
	n=n-1;
	print(n);
	
	if(n>0){
		SelectionArray= newArray(0,n);
		roiManager("Select", SelectionArray);
		roiManager("combine");
		roiManager("add");
		combined= n+1;
		roiManager("Select", combined);
	}
	
	else{
		roiManager("Select",n);
	}
	
	run("Clear Results");
	
	roiManager("measure");
	csvtitle=savetitle+"_Background.csv";
	saveAs("Results",csvtitle);
	roiManager("reset");
	run("Clear Results");
	run("Close All");
}

function measureLD(img){
	
	open(img);
	//get title and remove the ending //GetFilewithoutextension is bugged
	title=substring(img,0,(lengthOf(img)-6));
	//add here the suffix for ROIs This where the ROis will be looked for
	roititle=title+Roisuffix;
	print(roititle);
	singleroititle=substring(roititle,0,(lengthOf(img)-4));
	singleroititle=singleroititle+".roi";
	
	//savetitle and folder
	savetitle=substring(img,0,(lengthOf(img)-4));
	
	
	//Create a savename this will be savelocation
	csvtitle=savetitle+"_Results.csv";
	print(csvtitle);
	
	run("Select None");
	run("Clear Results");

	//Acutal Measurements are taken herer and saved in csvtitle
	if(File.exists(roititle)){

		Measure_ROIset(roititle);
	
	}
	if(File.exists(singleroititle)){
		
		Measure_ROIset(singleroititle);
	}
	
	//Cleanup and make ready for next iteration
	print(csvtitle);
	saveAs("Results",csvtitle);
	run("Clear Results");
	run("Close All");
	
}

function Measure_ROIset(roititle){
	   
		roiManager("reset");
		roiManager("open", roititle);
		roiManager("measure");
}


//Run program:

run("Close All");
location=getDirectory("Titleimage");
setBatchMode(true);

processFolder(location, Imagesuffix);

print("Done");