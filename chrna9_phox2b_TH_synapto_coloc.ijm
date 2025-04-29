// Duplicate all image files. Select and work with duplicates directory to perserve raw datas
// Make sure split channels on the initial pop up (import configuration window) is not checked

//to count number of images in original folder and set folders directories
OrigDir=getDirectory("Select folder with deconvolved images to quantify.");
print("Working folder is: ", OrigDir);
MergedSaveDir=getDirectory("Select folder for saved images and results.");
print("Merged folder is: ", MergedSaveDir);
olist=getFileList(OrigDir);
m=lengthOf(olist);
print("The number of images to quantify is: "+m);

// start of analysis loop
for(i = 0; i < m; i++){
    open(OrigDir+olist[i]);
    close("\\Others");
Name = getTitle();
// CleanName = replace(Name, "\ -\ Deconvolved\ 20\ iterations,\ Type\ Blind.nd2", "");
run("Duplicate...", "title=NM duplicate hyperstack"); 
    
// create variables and pre-process channels
run("Split Channels");
selectWindow("C0-NM");
dapi = getTitle();
close( dapi );

selectWindow("C1-NM");
phox2b_st = getTitle();
run("Subtract Background...", "rolling=50 stack"); // 50 rolling ball manually selected so background pixels become roughly 0
run("Z Project...", "projection=[Max Intensity]");
phox2b_m_ori = getTitle();
run("Duplicate");
phox2b_m_dup = getTitle();
run("Grays");
run("Median...", "radius=2");

selectWindow("C2-NM");
synapto_st = getTitle();
run("Subtract Background...", "rolling=50 stack"); // 50 rolling ball manually selected so background pixels become roughly 0
run("Z Project...", "projection=[Max Intensity]");
synapto_m_ori = getTitle();
run("Duplicate");
synapto_m_dup = getTitle();
run("Grays");
run("Median...", "radius=2");

selectWindow("C3-NM");
TH_st = getTitle();
run("Subtract Background...", "rolling=50 stack"); // 50 rolling ball manually selected so background pixels become roughly 0
run("Z Project...", "projection=[Max Intensity]");
TH_m_ori = getTitle();
run("Duplicate");
TH_m_dup = getTitle();
run("Grays");
run("Median...", "radius=2");
// saveAs("tiff", MergedSaveDir + File.separator + "phox2b_puncta_" + CleanName + ".tif");

close( phox2b_st );
close( synapto_st );
close( TH_st );


// threshold images
// idea from BV is to use MH method of 7x the mean int of image
// need to set measurements twice? or find a way to select info off results excel
// need to understand how to adjust threshold parameters manually instead of using the auto threshold
set

selectWindow(Synapto_MAX_sub);
run("View 100%");
setAutoThreshold("IsoData dark");
call("ij.plugin.frame.ThresholdAdjuster.setMode", "B&W");
setOption("BlackBackground", true);
getThreshold(lower, upper);
print("The IsoData threshold is " + lower + ", " + upper + ".");
run("Set Measurements...", "area mean min bounding integrated median limit redirect=None decimal=3");

getNumber("prompt", defaultValue)
Displays a dialog box and returns the number entered by the user. The first argument is the prompting message and the second is the value initially displayed in the dialog. Exits the macro if the user clicks on "Cancel" in the dialog. Returns defaultValue if the user enters an invalid number. See also: Dialog.create. 


// create ROI overlays
run("Create Selection");
roiManager("Add");

// use ROI manager to collect NM shape based on vglut3 image
	if (i >= 1){
	open(ResultsDir + File.separator + "NMRoiSet.zip");
	roiManager("Show None"); // to prevent roiManager from applying all ROI in list at start of every loop
	}else {
		run("ROI Manager...");
	}
setTool("freehand");
waitForUser("Draw ROI around NM");
roiManager("Add");
roiName = call("ij.plugin.frame.RoiManager.getName", i); // gets the name of the last drawn NM roi
roiManager("Select", i);
roiManager("rename", CleanName); // names the ROI with the image title
roiNewName = call("ij.plugin.frame.RoiManager.getName", i);
print("ROI name changed from " + roiName + " to " + roiNewName);
roiManager("Save", ResultsDir + File.separator + "NMRoiSet.zip");
close("ROI Manager");

// process chrna9 channel
selectWindow("C2-NM");
chrna9 = getTitle();
run("Z Project...", "projection=[Max Intensity]");
run("Subtract Background...", "rolling=75 stack");
saveAs("tiff", chrna9SaveDir + File.separator + "chrna9_puncta_" + CleanName + ".tif");

close( Name );
close( chrna9 );
close( vglut3 );

/*

close("*");

// alt idea for processing where all roi are collected and subsequently applied to images we sequentially open
// applies the previously drawn roi onto open images (vlgut3 and chrna9)
slist=getFileList(SaveDir);
p=lengthOf(slist);
print("The number of images to quantify is: "+p);
for (j = 0; j < p; j++) {
	open(SaveDir+slist[j]);
	close("\\Others");
	openimage=getTitle();
	openimage.matches(s2)
	if (matches(title, ".*40x.*")) {
	roiManager.selectByName(name); 
	roiManager("Select", j);
	for (i = 0; i < Fpoints.length; i++) {
    print(Fpoints[i]);
}
	index(CleanNameArray) //not real code lol
}

*/

// applies ROI drawn earlier onto both vglut3 and chrna9 images sequentially and quantifies puncta counts to csv
imgs = getList("image.titles");
print("Number of images open:" + imgs.length);
for (j = 0; j < imgs.length; j++) {
print("Open image: "+imgs[j]);
selectImage( imgs[j] );
imgsjname = getTitle();
imgsjname2 = replace(imgsjname, ".tif", "");
open(ResultsDir + File.separator + "NMRoiSet.zip");
roiManager("Show None"); // important to have otherwise imagej will ask if you want to save an overlay of all the roi's on top of the image
roicount  = roiManager("count");
	if (roicount == 1) {
		roiManager("select", 0);
	}else {
		roiManager("select", roicount -1); // selects the last roi in list because total length of list minus 1. 0 is first image
		}
	close("ROI Manager");
	run("Clear Outside");
	run("8-bit");
	run("adaptiveThr ", "using=[Weighted mean] from=3 then=-4"); // chosen based on manual testing of vglut3
	run("Watershed");
	run("Analyze Particles...", "size=0.025 circularity=0.1-1 display clear summarize overlay add"); // chosen based on Kindt publications
	// setResult("Fish", i, CleanName);
	// setResult("HC", i+1, part);
	// saveAs("results", ResultsDir + File.separator + imgsjname2 + "_intensity_results.xls");
	// run("Clear Results");
	roiManager("reset");
	
	}
close("*");
}
Table.rename("Summary", "Results");
saveAs("results", ResultsDir + File.separator + "_puncta_results.csv");

// getValue("results.count")
// Returns the number of lines in the current results table. Unlike nResults, works with tables that are not named "Results".
// look at print(string) function in imagej ref
// look at setResults function


// all done! now just save log and close everything
waitForUser("Save the Log file to maintain record of image processing/quantification.");
run("Close All");


