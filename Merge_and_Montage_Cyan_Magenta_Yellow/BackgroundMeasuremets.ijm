threshold="IJ_IsoData";
setBatchMode(true);
endOfFile="0-BS.tif"
LC3BROI="1_LC3B_rois.zip"
function processFolder(input, end){
	
	//processes folder
	//image=false;
	list=getFileList(input);
	//gets all files
	
	for(i=0; i<list.length; i++){
		
		if(File.isDirectory(input+list[i])){
			processFolder(input+list[i], end);
			}
		//parses for tif files
		if(endsWith(list[i], end)){
			print(input+list[i]);
			//starts the import dialog. User selects ALL images
			MeasureCellBackground(input+list[i]);
			
			}	
		}	
}

function MeasureCellBackground(ID){
	
	open(input+list[i]);
	ID=getImageID();
	
	path=createSavepath(ID);
	
	run("Duplicate...", " ");
	maskID=getImageID();
	run("32-bit");
	run("Median...", "sigma=1");
	setAutoThreshold(threshold+" dark no-reset");
	run("NaN Background");

	imageCalculator("Multiply create 32-bit", ID, maskID);
	saveAs("Tiff", path+"-Phluorin-segment.tif");

	run("Clear Results");
	roiManager("reset");
	roiManager("open", path+LC3BROI);
	roiManager("Measure");

	saveAs("Results",path+"-Phluorin-segment.csv");
	
}

function createSavepath(ID){
	imname=getTitlewoExtension(ID);
	path=File.directory;
	savepath=path+File.separator+imname;
	
	return savepath;
}


function getTitlewoExtension(ID){

	selectImage(ID);
	name=getTitle();
	name=substring(name,0,lengthOf(name)-8);
	print(name);

	return name;
	
}

run("Close All");
location=getDirectory("Titleimage");
processFolder(location, endOfFile);
print("Done");