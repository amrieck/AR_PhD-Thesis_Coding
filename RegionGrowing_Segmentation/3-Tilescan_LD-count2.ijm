
function processFolder(input,filend){

	list=getFileList(input);
	
	for(i=0; i<list.length; i++){
		
		if(File.isDirectory(input+list[i])){
			processFolder(""+input+list[i],filend);
			}
			
		if(endsWith (list[i], filend [0])){
					 
		open(input+list[i]);
			LDmask = getTitle();
			preparemask(input+list[i],LDmask);
		}

		if(endsWith (list[i], filend[1])){
			LDcount(input+list[i], LDmask);
		}

		if(endsWith (list[i], filend[2])){
			Nucleus(input+list[i]);
		}
	}
}

function preparemask(source, maskname){

	selectWindow(maskname);
	run("8-bit");
	setAutoThreshold("Huang dark");
	run("Convert to Mask");
	//run("Gaussian Blur...", "sigma=1");
	//setAutoThreshold("IJ_IsoData dark");
	//run("Convert to Mask");
	run("Watershed");
	setAutoThreshold("IJ_IsoData dark");

	run("Duplicate...", "title=count");
	selectWindow("count");
	
	path=File.getParent(source);
	print(File.nameWithoutExtension);
	saveAs("Tiff",path+"\\"+File.nameWithoutExtension+"LDcount.tif");

}

function LDcount(source, mask){

	//imageCalculator("Multiply create 32-bit", mask1, mask2);
	//cellSegment = getTitle();
	//run("8-bit");
	selectWindow(mask);
	run("Analyze Particles...", "clear add");
	
	open(source);
	sourceTitle=getTitle();
	selectWindow(sourceTitle);
	run("Set Scale...", "distance=2.4089 known=1 unit=micron");
	
	roiManager("Measure");
	savename=createSavepath(source);
	print(File.nameWithoutExtension);
	saveAs("Results", exportpath1+savename+".csv");
	run("Close All");
}

function createSavepath(input){
	parent=  File.getParent(input);			//IM
	gparent= File.getParent(parent);		//Condition
	ggparent= File.getParent(gparent);		//Experiment

	cell	= File.getName(input);
	cell = replace(cell, "source.tif", "") ;
	
	Condition=File.getName(gparent);
	Experiment= File.getName(ggparent);
	
	savename= Experiment+Condition+cell;
	return savename;
}
	
function Nucleus(input){

	open(input);
	savename=createSavepath(input);
	saveAs("Results", exportpath2+savename);
	
}
run("Close All");
counter= newArray("","","");
location=getDirectory("input");
setBatchMode(true);
filend = newArray("maximagrow.tif","source.tif", "Nucleicount.csv");
//print(filend[0]);

exportpath1= location+"/CSV"+File.separator;

if (File.isDirectory(exportpath1)==false){
		File.makeDirectory(exportpath1);//creates a new folder
		}

exportpath2= location+"/Nucleicount"+File.separator;

if (File.isDirectory(exportpath2)==false){
		File.makeDirectory(exportpath2);//creates a new folder
		}

processFolder(location,filend);


print("Finished");
