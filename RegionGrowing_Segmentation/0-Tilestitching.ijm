function processFolder(input, end){
	list=getFileList(input);
	for(i=0; i<list.length; i++){
		if(File.isDirectory(input+list[i])){
			processFolder(input+list[i], end);}
		
		if(endsWith(list[i], end)){
			
				lilo(input, list[i]);			
		}	
	}
}

function lilo(path, location){
	
	open(path+location);

	direc= File.directory();
	title = getTitle();
	name = substring(title, 0, lengthOf(title)-2);
	namewoex= File.nameWithoutExtension(); 
	savedir= direc +"Stitching/";
	
		if (File.isDirectory(savedir)==false){
			File.makeDirectory(savedir);//creates a new folder
			}	

	print(savedir);
	print(name);


	for (i=1; i<26; i++) {
	
		if(i<10)
		{
			j= "0";
			selectWindow(name+j+i);
			saveAs("Tiff", savedir+namewoex+" #"+j+i+".tif");
		}
	
		else
		{
			selectWindow(name+i);
			saveAs("Tiff", savedir+namewoex+" #"+i+".tif");
		}
	}
	
	run("Grid/Collection stitching", "type=[Grid: row-by-row] order=[Right & Down                ]"+ 
	"grid_size_x=5 grid_size_y=5 tile_overlap=10 first_file_index_i=1 directory=["+savedir+
	"] file_names=["+namewoex+" #{ii}.tif] output_textfile_name=TileConfiguration.txt" +
	"fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50"+
	" absolute_displacement_threshold=3.50 compute_overlap "+
	"computation_parameters=[Save computation time (but use more RAM)] "+
	"image_output=[Fuse and display]");
	saveAs("Tiff", savedir+namewoex+"stitched.tif");
	run("Close All");
}


run("Close All");
location=getDirectory("Titleimage");
setBatchMode(true);
print("Sacrificing for Yog-Sototh");
print(location);
processFolder(location, ".czi");
