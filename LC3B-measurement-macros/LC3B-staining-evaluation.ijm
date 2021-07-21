threshold="IJ_IsoData";
setBatchMode(true);
endOfFile="LC3B.tif"
LC3BROI="_LC3B_rois.zip"
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
			CountLC3B(input+list[i]);
			
			}	
		}	
}

function CountLC3B(ID){
	
	open(input+list[i]);
	ID=getImageID();
	
	path=createSavepath(ID);
	
	run("Duplicate...", " ");
	maskID=getImageID();
	run("32-bit");
	run("Gaussian Blur...", "sigma=1");
	setAutoThreshold("Li dark no-reset");
	run("Convert to Mask");
	run("Divide...", "value=255.000");
	
	imageCalculator("Multiply create 32-bit", ID, maskID);

	setAutoThreshold(threshold+" dark no-reset");
	run("Convert to Mask");
	run("Watershed");
	saveAs("Tiff", path+"-LC3B-segment.tif");

	run("Clear Results");
	run("Analyze Particles...", "size=0-Infinity display clear add");
	
	roiManager("save", path+LC3BROI);
	roiManager("Measure");

	saveAs("Results",path+"-LC3B-segment.csv");
	
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