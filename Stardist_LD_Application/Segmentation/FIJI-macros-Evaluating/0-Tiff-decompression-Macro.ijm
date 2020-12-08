//This macro decompresses the jpeg compresse leica export pictures
//it opens them and saves them under the same name


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
			filedat=input+list[i];
			print(filedat);

			open(filedat);
			saveAs("Tiff", filedat);
			close();
			//starts the import dialog. User selects ALL images
			
			}	
		}
}

//Clean up before script starts
run("Close All");

//get directory and set batchmode
location=getDirectory("Titleimage");
setBatchMode(true);

//All hail the elder gods
//print("Ia! Ia! Shub-Nigurath");
//print(location); // debug

//acutal program starts here
processFolder(location, ".tif");
print("Done");