

function processFolder(input, end){
	list=getFileList(input);
	for(i=0; i<list.length; i++){
		if(File.isDirectory(input+list[i])){
			processFolder(input+list[i], end);}
		
		if(endsWith(list[i], end)){
			print(input+list[i]);
			findmax(input, list[i]);			
		}	
	}
}

function findmax(path, image){

	open(path+image);
	name=File.nameWithoutExtension();

	dir= File.directory();
	parent= File.getParent(dir);
	print(parent);
	
	savepath= parent+"/IM"+File.separator;
	
	if (File.isDirectory(savepath)==false){
		File.makeDirectory(savepath);//creates a new folder
		}

	imageTitle=getTitle(); //returns a string with the image title
	run("Split Channels"); 
	
	selectWindow("C3-"+imageTitle);
	run("Gaussian Blur...","sigma=5 ");
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("32-bit");
	run("Convert to Mask");
	setAutoThreshold("Huang dark");
	run("Convert to Mask");
	run("32-bit");
	setAutoThreshold("Huang dark");
	run("NaN Background");
	run("Divide...", "value=255.000");
	saveAs("Tiff", savepath+name+"RFP.tif");
	rmask=getTitle();
	
	selectWindow("C2-"+imageTitle);
	saveAs("Tiff", savepath+name+"source.tif"); //saves source image
	stitle=getTitle();
	//run("Median...","radius=1"); 		//make LDs homogenious

	run("Duplicate...", " ");
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("32-bit");
	run("Convert to Mask");
	setAutoThreshold("Huang dark");
	run("Convert to Mask");
	run("32-bit");
	setAutoThreshold("Huang dark");
	run("NaN Background");
	run("Divide...", "value=255.000");
	saveAs("Tiff", savepath+name+"sourcemask.tif");
	smask=getTitle();
	
	imageCalculator("Multiply create 32-bit", stitle,smask);
	matrix1= getTitle();
	
	imageCalculator("Multiply create 32-bit", matrix1, rmask);
	run("8-bit");
	saveAs("Tiff", savepath+name+"RGMatrix.tif");
	run("Find Maxima...", "noise=10 output=List exclude"); //finds maxima in Picture
	saveAs("Results", savepath+name+"maxima.csv"); //saves maxima in new folder
	

	selectWindow("C1-"+imageTitle);
	run("Median...","radius=2");
	setAutoThreshold("Li dark");	
	run("Convert to Mask");
	run("Fill Holes");
	run("Erode");
	run("Watershed");
	run("Dilate");
	run("Watershed");
	saveAs("Tiff", savepath+name+"Nuclei.tif");
	ntitle= getTitle();
	imageCalculator("Multiply create 32-bit", ntitle, rmask);
	run("8-bit");
	saveAs("Tiff", savepath+name+"masknuclei.tif");
	
	run("Analyze Particles...", "size=210-Infinity display clear add");
	saveAs("Results", savepath+name+"Nucleicount.csv");
	run("Close All");
	print (dir);
}

run("Close All");
location=getDirectory("Titleimage");
setBatchMode(true);
print("Ia! Ia! Shub-Nigurath");
//print(location);
processFolder(location, "stitched.tif");

