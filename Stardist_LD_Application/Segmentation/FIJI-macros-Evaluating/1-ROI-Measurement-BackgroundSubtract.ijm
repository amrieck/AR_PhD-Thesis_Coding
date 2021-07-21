//This macro creates measurements and tries to save them in a comprehendable form
//Input:	Is the ROI with the same name, but different endpart
//Output: 	Measurement in an csv that can be used with csvsorter.py

//Run through the subfolder and process everyimage

Roisuffix="_rois.zip";
Imagesuffix="BS.tif";
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
			}	
		}
}

//measuring function
function measureLD(img){
	
	open(img);

	//get title and remove the ending //GetFilewithoutextension is bugged
	title=substring(img,0,(lengthOf(img)-7));
	//add here the suffix for ROIs This where the ROis will be looked for
	roititle=title+Roisuffix;
	print(roititle);
	singleroititle=substring(roititle,0,(lengthOf(img)-4));
	singleroititle=singleroititle+".roi";
	//savetitle and folder
	savetitle=File.getName(img);
	Folder=File.getParent(img);
	savetitle=substring(savetitle,0,(lengthOf(savetitle)-4));
	
	//print(savetitle);

	//this tries to split the savetitle, only use when there is information in imagetitle
	if(infotitle==true){
	
		savetitle=split(savetitle,'-');
		savetitle=Folder+File.separator+savetitle[0]+"-"+savetitle[1]+"-"+savetitle[2]+"-"+savetitle[3];
	}

	else{
		savetitle=Folder+File.separator+savetitle;
		
	}
	//Create a savename this will be savelocation
	csvtitle=savetitle+"_Results.csv";
	//print(csvtitle);

	//Acutal Measurements are taken herer and saved in csvtitle
	if(File.exists(roititle)){

		Measure_ROIset(roititle);
	
	}
	if(File.exists(singleroititle)){
		
		Measure_ROIset(singleroititle);
	}
	
	//Cleanup and make ready for next iteration
	
	saveAs("Results",csvtitle);
	run("Clear Results");
	run("Close All");
	
}

function Measure_ROIset(roititle){
		roiManager("reset");
		roiManager("open",roititle);	
		roiManager("measure");
}


//Run program:

run("Close All");
location=getDirectory("Titleimage");
setBatchMode(true);

processFolder(location, Imagesuffix);

print("Done");