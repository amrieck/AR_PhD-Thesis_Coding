Imagesuffix="_Max_project.tif";
Imagename="Composit";

function processFolder(input, end){
	//processes folder
	imagesopen=false;
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
			imagesopen=true;
			filedat=input+list[i];
			//print(filedat);
			
			//opens the image and measures LDs
			open(filedat);
			}	
		}

	if(imagesopen==true){
		MakeComposite();
	}
}


function MakeComposite(){
	 
	ImageArray= getIDArray();
	path=createSavepath(ImageArray[0]);

	selectImage(ImageArray[0]);
	phluorin= getTitle();

	selectImage(ImageArray[1]);
	LC3B= getTitle();

	selectImage(ImageArray[2]);
	CARS= getTitle();

	run("Merge Channels...", "c5="+phluorin+" c6="+LC3B+" c7="+CARS+" create");
	

	
	saveAs("Tiff...", path+Imagename);
	run("Close All");
	
	
}

function getIDArray(){
	imgArray = newArray(nImages); 
	
	for (i=0; i<nImages; i++) {    
		selectImage(i+1);     
		imgArray[i] = getImageID(); 
	}
	
	return imgArray;
}
	

function createSavepath(ID){

	path=File.directory;
	savepath=path+File.separator;
	
	return savepath;
}

//Run program:

run("Close All");
location=getDirectory("Titleimage");
setBatchMode(true);

processFolder(location, Imagesuffix);

print("Done");