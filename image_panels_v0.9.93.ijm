//unresolved: close all windows that are not the Log window

macro "ImagePanel from image files [q]" {

var versions;
var version_index = 1;
var bioformats_name = "bio-formats";
var version_toggle = "";
var required_ij_ver = "1.53f";
	var type = "stuff";
	var form_ = "some";
	var oritype_ = "16bit";
	var max_ = 16383;
	var j = 0;
	var dir1 = "";
	var dir2 = "";
	var list = "";
	var scaleratio = 1;
	var stretch_ = "no";
	var winame = "";
	var cnr = "";
	var columns_ = "";

/*
 * checking minimum requirements for the program
 */

// Check if FIJI or ImageJ is installed and which version (for FIJI, getVersion command will get 2 entries, in ImageJ just one (at this point, this is a guess...)
imagejVersion=getVersion();
//save version numbers as seperate enteties
versions = split(imagejVersion, "/");
//assume that if there is less than 2 version entries, only ImageJ is installed
if (versions.length < 2) {print("you might want to install FIJI instead of ImageJ to  make things easier"); version_index = 0}
//exit macro and show message to update if the minimum version requirements are not met
//if (versions[version_index] >= "1.53f"){print("minimum ImageJ version is installed");}
if (versions[version_index] < required_ij_ver){exit("Please update your ImageJ version to 1.53f. If you are using FIJI, the FIJI and ImageJ versions can be updated seperately. Please make sure that the ImageJ version is updated too.")}
else {print("Suitable ImageJ/(FIJI) version found...");}
//if the version number is ok, check that the BioFormats plugin is installed
//version_toggle=0;
//get plugins folder path
installed_plugins = getFileList(getDirectory("plugins"));
//show entries matching the bioformats plugin name (in preparation for name changes as variable)
bioformats_version=Array.filter(installed_plugins, bioformats_name);
//bioformats_version=Array.filter(installed_plugins, "startrek");
//exit with prompt to install bio-formats plugin if it is not installed yet
if (bioformats_version.length < 1){exit("Please install the Bio-Formats plugin.");}
//if (bioformats_version.length != 0){print("bio-formats plugin version: " + bioformats_version[0] + " is present");}
else {print("Bio-Formats plugin found...");}
//print(imagejVersion);

/*
 *  starting main functions and program
 */

function scalerat() {
	scaleratio = 65536 / (max_+1);
	run("Multiply...", "value=&scaleratio");
	}

//close all open image windows
	run("Close All");
/*
//ask for original bit format of the image
	Dialog.create("Original image format");
	Dialog.addChoice("Original image format:", newArray("8bit", "10bit", "12bit - MR5m (left)", "14bit - 506m (right)", "16bit"), "8bit");
	Dialog.show();
	oritype_ = Dialog.getChoice();
//ask which bit format to convert to
	Dialog.create("image export");
	Dialog.addChoice("Export target format:", newArray("save as 16bit tiff", "convert to 8bit"), "convert to 8bit" );
	Dialog.show();
	type = Dialog.getChoice();
//if 16bit was chosen, ask if bit range should be stretched to 16 or left as is (raw data)
	if (type=="save as 16bit tiff") {
	Dialog.create("Stretch pixel values to fill 16bit range?");
	Dialog.addChoice("Stretch pixel values to fill 16bit range?", newArray("yes", "no"), "yes");
	Dialog.show();
	stretch_ = Dialog.getChoice();}
//ask which file format to save in
	Dialog.create("file format");
	Dialog.addChoice("Export file type:", newArray("jpeg", "tiff"), "tiff");
	Dialog.show();
	form_ = Dialog.getChoice();
	Dialog.create("subfolders");
	Dialog.addChoice("Include subfolders?:", newArray("yes", "no"), "yes");
	Dialog.show();
	subf_ = Dialog.getChoice();
*/
	
	Dialog.create("Panel generation - define parameters");
	Dialog.addChoice("Original image format:", newArray("8bit", "10bit", "12bit - MR5m (left)", "14bit - 506m (right)", "16bit"), "8bit");
	Dialog.addChoice("Export target format:", newArray("save as 16bit tiff", "convert to 8bit"), "convert to 8bit" );
	Dialog.addChoice("Export file type:", newArray("jpeg", "tiff", "gif"), "tiff");
	Dialog.addChoice("Include subfolders?:", newArray("yes", "no"), "yes");
	Dialog.show();
	oritype_ = Dialog.getChoice();
	type = Dialog.getChoice();
	form_ = Dialog.getChoice();
	subf_ = Dialog.getChoice();
	
	if (type=="save as 16bit tiff") {
	Dialog.create("Stretch pixel values to fill 16bit range?");
	Dialog.addChoice("Stretch pixel values to fill 16bit range?", newArray("yes", "no"), "yes");
	Dialog.show();
	stretch_ = Dialog.getChoice();}
	
	dir1 = getDirectory("Choose Input Directory ");
	dir2 = getDirectory("Choose Output Directory ");
	list = getFileList(dir1);
	Array.sort(list); //crucials as fiji doesn't autosort anymore
	folder = File.getName(dir1);
	if (oritype_=="8bit") {max_=255;}
	else if (oritype_=="10bit") {max_=1023;}
	else if (oritype_=="12bit - MR5m (left)") {max_=4095;}
	else if (oritype_=="14bit - 506m (right)") {max_=16383;}
	else if (oritype_=="16bit") {max_=65535;}
	else {print("unkown bit value - you should not have been able to set that value!"}
	setBatchMode(true);
	run("Input/Output...", "jpeg="+100);
	color_=getValue("color.foreground");
	run("Colors...", "foreground=white");
	l_length=list.length;
	cnr=l_length/6;
	columns_=-floor(-cnr);
	print(columns_);
	print("creating panels from images in folder " + dir1);
	print("loading images: ");

if (subf_=="yes") {

	//needs to be done as a for loop as there is no batch opening for bio-formats
	for (i=0; i< list.length; i++) {
		if(File.isDirectory(dir1+list[i])) //if it's a directory, go to subfolder
		{sublist=getFileList(dir1+list[i]);
		tmpdir=dir1+list[i];
		indir=replace(tmpdir, "/", "\\");
		for (ii=0; ii< sublist.length; ii++){
			infile=sublist[ii];
			//check if file suffix fits, then load
			if (endsWith(infile, ".tif") || endsWith(infile, ".tiff") || endsWith(infile, ".jpg") || endsWith(infile, ".jpeg")|| endsWith(infile, ".czi") || endsWith(infile, ".TIFF") || endsWith(infile, ".TIF") || endsWith(infile, ".JPEG") || endsWith(infile, ".JPG") || endsWith(infile, ".CZI") || endsWith(infile, ".lsm") || endsWith(infile, ".LSM"))
			{importimage(indir, infile, max_);}
			else {print("following file not loaded, not an image: "+infile);}
		}}
		else {
			indir=dir1;
			infile=list[i];
			if (endsWith(infile, ".tif") || endsWith(infile, ".tiff") || endsWith(infile, ".jpg") || endsWith(infile, ".jpeg")|| endsWith(infile, ".czi") || endsWith(infile, ".TIFF") || endsWith(infile, ".TIF") || endsWith(infile, ".JPEG") || endsWith(infile, ".JPG") || endsWith(infile, ".CZI") || endsWith(infile, ".lsm") || endsWith(infile, ".LSM"))
			{importimage(indir, infile, max_);}
			else {print("following file not loaded, not an image: "+infile);}
		}
	}
function importimage(indir, infile, max_) {print(indir + infile);
	run("Bio-Formats Importer", "open=[" + indir + infile + "] color_mode=Default view=Hyperstack stack_order=XYCZT");
	p=nSlices;
		for (i=0; i<p; i++) {
   			setSlice(i+1);
   			setMinAndMax(0, max_);
			}
		}
}
else {for (i=0; i< list.length; i++) {
			indir=dir1;
			infile=list[i];
			if (endsWith(infile, ".tif") || endsWith(infile, ".tiff") || endsWith(infile, ".jpg") || endsWith(infile, ".jpeg")|| endsWith(infile, ".czi") || endsWith(infile, ".TIFF") || endsWith(infile, ".TIF") || endsWith(infile, ".JPEG") || endsWith(infile, ".JPG") || endsWith(infile, ".CZI") || endsWith(infile, ".lsm") || endsWith(infile, ".LSM"))
			{importimage(indir, infile, max_);}
			else {print("following file not loaded, not an image: "+infile);}
			}
	}	


//Concatenate images into one hyperstack
	run("Concatenate...", "all_open title=[Concatenated Stacks] open");
	selectWindow("Concatenated Stacks");
	setMinAndMax(0, max_);
//up to here it's fine but Make Montage creates 8bit/channel images
	run("Make Montage...", "columns=6 rows=&columns_ scale=1 border=10 use");
	selectWindow("Montage");
	labels = newArray("Red", "Green", "Blue");
	k=nSlices;
		for (i=0; i<k; i++) {
   			setSlice(i+1);
   			setMetadata("label", labels[i]);
}

//get number of channels
	getDimensions(width, height, channels, slices, frames);
	
	if (form_ == "tiff" && type == "save as 16bit tiff" && stretch_ == "yes") {
		scalerat();
		saveAs("tiff", dir2+folder+"_16bit_stretched_panel.tif"); print("file has been saved as: ["+ dir2 + folder +"]_16bit_stretched_panel.tif");}
	else if (form_ == "tiff" && type == "save as 16bit tiff" && stretch_ == "no") {
		saveAs("tiff", dir2+folder+"_16bit_original_panel.tif"); print("file has been saved as: ["+ dir2 + folder +"]_16bit_original_panel.tif");}
	else if (form_ == "jpeg" && type == "save as 16bit tiff" && stretch_ == "yes") { 
		scalerat();
		saveAs("tiff", dir2+folder+"_16bit_stretched_panel.tif");
		print("16bit/channel images can not be saved in jpeg format, the file has been saved as [" + dir2 + folder +"]_16bit_stretched_panel.tif");}
	else if (form_ == "jpeg" && type == "save as 16bit tiff" && stretch_ == "no") { 
		saveAs("tiff", dir2+folder+"_16bit_original_panel.tif");
		print("16bit/channel images can not be saved in jpeg format, the file has been saved as [" + dir2 + folder +"]_16bit_original_panel.tif");}
//for 8bit conversion, stretch_ flag is ignored as this is not compatible
	else if (form_ == "jpeg" && type=="convert to 8bit") {
	if (channels > 1)	{run("Stack to RGB");}
	saveAs("jpeg", dir2+folder+"_8bit_panel.jpg"); print("file has been saved as: [" + dir2 + folder +"]_8bit_panel.jpg to 8bit");}
	else if (form_ == "tiff" && type=="convert to 8bit") {
	if (channels > 1)	{run("Stack to RGB");}
	saveAs("tiff", dir2+folder+"_8bit_panel.tif"); print("file has been saved as: [" + dir2 + folder +"]_8bit_panel.tif to 8bit");}
	else if (form_ == "gif" && type=="convert to 8bit") {
	if (channels > 1)	{run("Stack to RGB");run("8-bit Color", "number=256");}
	saveAs("gif", dir2+folder+"_8bit_panel.gif"); print("file has been saved as: [" + dir2 + folder +"]_8bit_panel.gif to 8bit");}
	else {print("unknown function called")}

	run("Close All");
//idea: while window name unequal Log, get the window name, run close
/*	do {
	winame = getInfo("window.name");
	if (winame != "Log" {
	selectWindow(winame);
     	run("Close");
	print("window " + winame + " closed");
	}} while (winame != "Log");
*/
/*
//winlist seems to have a problem
	winlist = getList("window.titles");
//for testing only - what is in the winlist
	winlist2 = Array.print(winlist);
	print("this is the list: " +winlist2 );
//result is 0 - meaning winlist2 / winlist is empty
     	k=0;
	for (k=0; k<winlist.length; k++){
     	winame = winlist[k];
	if (winame != "Log") {
	selectWindow(winame);
     	run("Close");
	print("window " + winame + " closed");
    	}
	}
*/
	print("macro is done");
	setBatchMode(false);
	run("Colors...", "foreground=&color_");
	run("Collect Garbage");
	}
	