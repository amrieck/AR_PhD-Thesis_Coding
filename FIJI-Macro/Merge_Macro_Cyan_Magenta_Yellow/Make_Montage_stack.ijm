threshold="Triangle dark";
savenames=newArray("-Mask.tif","-LD.tif","-Nuclei.tif");
setBatchMode(true);


function processFolder(input, end){
	
	//processes folder
	//image=false;
	list=getFileList(input);
	//gets all files
	
	for(i=0; i<list.length; i++){
		
		//parses for tif files
		if(endsWith(list[i], end)){
			print(input+list[i]);
			//starts the import dialog. User selects ALL images
			open(input+list[i]);
			}	
		}	
}



function makeidarray(){

	pimgArray=newArray(nImages);
		//iterate all image ids and put them in an array
	for (i=0; i<nImages;i++){
				selectImage(i+1);
				pimgArray[i] = getImageID();
		}
		
	return pimgArray;
}	 

function runImages(idarray){

	numberim=idarray.length;

	for (i=0; i < numberim;){
		
		CARS=i+1;
		Nuclei=i+2;
		Bodipy=i+3;
		Transfection=i+4;
		
		print(CARS,Nuclei,Bodipy,Transfection);
		StackID=CreateMontageStack(idarray[Nuclei],idarray[Bodipy],idarray[Transfection]);

		imagename=getTitlewoExtension(idarray[Nuclei]);
				
		saveImage(StackID[0], imagename, "Merged_Image");
		saveImage(StackID[1], imagename, "Stack");
		i=i+5;
		}
		
	//run("Close All");	
}

function CreateMontageStack(nucleus,LD,FR){

	
	selectImage(nucleus);
	NTitle=getTitle();
	run("Cyan");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");

	selectImage(LD);
	LDTitle=getTitle();
	run("Yellow");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");

	selectImage(FR);
	FRTitle=getTitle();
	run("Magenta");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");

	run("Merge Channels...", "c5="+NTitle+" c6="+FRTitle+ " c7="+ LDTitle+" create keep ignore");
	
	run("RGB Color");
	MergedID=getImageID();
	
	run("Concatenate...", "keep image1="+NTitle+ " image2="+LDTitle+" image3="+FRTitle);
	stackID=getImageID();
	
	results=newArray(MergedID,stackID);
	
	return results;

}

function saveImage(imID, name, sname){
	selectImage(imID);
	savepath=createSavepath("Montage-stacks", name);
	savename=savepath+sname;
	saveAs("Tiff", savename);
	print (savename);
}

function getTitlewoExtension(ID){

	selectImage(ID);
	name=getTitle();
	name=substring(name,0,lengthOf(name)-12);
	print(name);

	return name;
	
}
function createSavepath(FolderName, Filename){

	savepath=location+File.separator+FolderName;
	
	if (File.isDirectory(savepath)==false){
			File.makeDirectory(savepath);//creates a new folder
		}

	savename=savepath+File.separator+Filename;
	
	return savename;
}



run("Close All");
location=getDirectory("Titleimage");

print("Ia! Ia! Shub-Nigurath");
//print(location);


processFolder(location, ".tif");
imArray=makeidarray();
runImages(imArray);

print("Done");