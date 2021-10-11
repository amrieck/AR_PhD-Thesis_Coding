preimageslices=5; // How many slices are pre-FRAP
Doublefrap=false; // two/multi channel FRAP
threshold="RenyiEntropy dark"; //Threshold used to detect bleach area
roinames=newArray("-bleach","-referencexor","-reference","-background"); //names for the different files created


function processFolder(input, end){
	//processes folder
	//image=false;
	list=getFileList(input);
	//gets all files
	for(i=0; i<list.length; i++){
		//parses for folders
		if(File.isDirectory(input+list[i])){
			processFolder(input+list[i], end);
			}
		//parses for lif files
		if(endsWith(list[i], end)){
			print(input+list[i]);
			//starts the import dialog. User selects ALL images
			createConcatImg(input, list[i]);
			}	
		}
}

function createConcatImg(input, file){

	fpath=input+file;
	open(fpath);

	fname=File.nameWithoutExtension;
	print(fname);
	savepath=input+fname+File.separator;
	
		if (File.isDirectory(savepath)==false){
			File.makeDirectory(savepath);//creates a new folder
		}	

		//remove all climateGraphs
		imgArray=removeClimateGraph();
		//set a counter for images
		
		j=1;

		//iterate over imgArray
		for(i=0; i<imgArray.length;i=i+2){
				//create image specific savepath
				selectImage(imgArray[i]);
				//title=getTitle();
				//delim="+";
				//title=replace(title,"/", delim);
				//title=split(title,delim);
				subpath=savepath+File.separator;
				
				if (File.isDirectory(subpath)==false){
					File.makeDirectory(subpath);//creates a new folder
				}	

				//counter for postFrap
				k=i+1;
				FRAPno="FRAP0"+j;

				////find the FRAP area of image i and postfrapimage K
				
				findFRAP(imgArray[i], imgArray[k], subpath, FRAPno);
				
				run("Concatenate...", "  title=FRAP0"+j+" open image1=[imgArray[i] image2=[imgArray[k] image3=[-- None --]");
				selectWindow(FRAPno);	
				saveAs("Tiff", subpath+FRAPno+".tif");

				PrepFrapMeasure(subpath, FRAPno, Doublefrap);
				j++;
		}
}

function removeClimateGraph(){
	
		//get an array ofl all image ids
		pimgArray=newArray(nImages);
		//iterate all image ids and put them in an array
		for (i=0; i<nImages;i++){
				selectImage(i+1);
				pimgArray[i] = getImageID();
		}

		//close all images called climate graph
		for (i=0;i<pimgArray.length;i++){
			selectImage(pimgArray[i]);
			title=getTitle();
			if(endsWith(title, "Graph")){
				close();
			}
		}

		//create a new array for image ids with open images
		imgArray=newArray(nImages);

		//fill the new array with imaged ids
		for (i=0; i<nImages;i++){
				selectImage(i+1);
				imgArray[i] = getImageID();
		}
		//return clean imgArray
		return imgArray;
}


function PrepFrapMeasure(path,counter,doublechnl){
	window= counter+".tif";

	selectWindow(window);
	if(doublechnl==true){
		channel=newArray("C1-","C2-");
		run("Split Channels");
	
		for(i=0; i<2; i++){
			selectWindow(channel[i]+window);
			measureFRAP(path,counter,channel[i]);
			}
	}
	
	else{
		measureFRAP(path,counter,"Ch01");
	}
}

function findFRAP(image1, image2, path, counter){

	//print(image2);
	name1="PreFRAP";
	name2="PostFRAP";
	FRAPname=path+counter;
	//print(name1);
	//print(name2);

	//duplicate last prefrap image
	selectImage(image1);
	setSlice(preimageslices);
	run("Duplicate...", "title="+name1);

	//duplicate first postfrap image
	selectImage(image2);
	run("Duplicate...", "title="+name2);

	//divide pre by post to get FRAP area
	imageCalculator("Divide create 32-bit", name1, name2);
	selectWindow("Result of "+name1);

	//consolidate  with median filter make mask
	run("Mean...","radius=4");
	setAutoThreshold(threshold);
	run("Convert to Mask");

	//remove artifacts
	run("Erode");
	run("Dilate");

	//get ROI and save
	run("Analyze Particles...", "size=2-Infinity display exclude clear include add");
	filename=roinames[0];
	roiManager("save",FRAPname+filename+".roi");
	saveAs("Tiff",FRAPname+filename+".tif");
	roiManager("measure");
	saveAs("Results",FRAPname+filename+"-Roisize.csv");
	close();
	
	//get reference around the FRAP
	roiManager("Select", 0);
	run("Scale... ", "x=3 y=3 centered");
	roiManager("Add");
	roiManager("Select", newArray(0,1));
	roiManager("XOR");
	roiManager("reset");
	roiManager("Add");
	roiManager("select",0);
	filename=roinames[1];
	roiManager("save",FRAPname+filename+".roi");

	//get reference of the cell
	selectWindow(name1);
	run("Duplicate...", "title=PreFRAP-reference");
	selectWindow("PreFRAP-reference");
	run("Gaussian Blur...", "sigma=5");
	setAutoThreshold("Mean dark");
	run("Convert to Mask");
	run("Analyze Particles...", "size=30-Infinity display clear include add");

	//union of all Particles
	count=roiManager("count");
	if (count>1){
		selection=Array.getSequence(count);
		roiManager("select", selection);
		roiManager("Combine");
		roiManager("reset");
		roiManager("Add");
		roiManager("select",0);
	}
	
	filename=roinames[2];
	roiManager("save",FRAPname+filename+".roi");
	saveAs("Tiff", FRAPname+filename+".tif");
	
	//invert for Background
	roiManager("reset");
	roiManager("open",FRAPname+filename+".roi"); 
	roiManager("select",0);
	run("Make Inverse");
	roiManager("add");
	roiManager("select",1);
	filename=roinames[3];
	roiManager("save",FRAPname+filename+".roi");

	close();
	
	selectWindow(name1);
	close();
	selectWindow(name2);
	close();	

}


function measureFRAP(path, counter,channel){
	
		for (i=0;i<4;i++){
			Roipath= path+counter;
			roiManager("deselect")
			roiManager("delete")
			filename=roinames[i];
			roiManager("open", Roipath+filename+".roi");
			roiManager("select", 0);
			run("Plot Z-axis Profile");
			Plot.getValues(xpoints, ypoints);
			run("Clear Results");
			
				for(j=0;j<xpoints.length;j++){
					setResult("X", j, xpoints[j]);
					setResult("Y", j, ypoints[j]);
				}
			
			updateResults();
			saveAs("Measurements", Roipath+channel+roinames[i]+".csv");
			close();
		}
		close();
}
	


run("Close All");
location=getDirectory("Titleimage");
setBatchMode(true);

print("Ia! Ia! Shub-Nigurath");
//print(location);


processFolder(location, ".lif");
print("Done");