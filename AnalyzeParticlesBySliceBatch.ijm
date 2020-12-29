macro "AnalyzeParticlesBySliceBatch" {
	/*
	 * This macro runs Analyse particles on all the images in the chosen folder in batch.
	 * Image can have up to 4 channels, one of which will be analysed.
	 * Each image is analysed slice by slice, not as a stack. Count, area, perimeter, fitted ellipse and shape descriptors are measured.
	 * Output is one summary per image, containing average of the measurements for each each slice of the image
	 * Complete results are not displayed, as they typically contain thousands of results per image.
	 * Threshold is set automatically bu ImageJ based on one slice of each image. You can set using same slice for all images, or set slice number individually.
	 * You can display thresholded area, analysed channel, and/or fitted ellipses for quality control before proceeding to next image.
	 * You can set diameter of Gaussian blur used before thresholding.
	 * You can set minimum size of analysed particles.
	 * You can Watershed the thresholded particles before measurement.
	 * 
	 * potential further improvements:
	 * - save all results, not just summary (run("Analyze Particles...", "size=0.20-Infinity show=Ellipses display exclude summarize stack"); - DISPLAY is the choice to be included, while including CLEAR would delete previous results)
	 *   if I do this, a name of the image has to be added to the results table
	 * - if measuring results, measure actual values of grey - have to add the particles to ROI manager, then measure them again in the original image
	 *   I did all this in other macros
	 * - add choice of showing other outputs than ellipses. Would have to create an array of choices, add it to the dialog and use as argument. Should be easy. Sadly, only one can be shown (adding SHOW options multiple times only processes the first one and ignres the rest).
	 * - add choice of other measurements in Set measurements
	 * - is cleaning the ROI manager necessary, if I don't bother measuring real intensity in the particles?
	 * - show the actual image when selecting slice for each image individually
	 * 
	 */
	run("Clear Results");
	directory=getDirectory("Choose a Directory");
	Dialog.create("Choose channel");
	items = newArray("1", "2", "3", "4");
	Dialog.addRadioButtonGroup("Channel to analyze", items, 1, 4, "1");
	Dialog.addMessage("");
	Dialog.addCheckbox("Watershed", false);
	Dialog.addMessage("");
	Dialog.addSlider("Gaussian blur diameter:", 0.0, 2.0, 1.2);
	Dialog.addMessage("");
	Dialog.addMessage("Minimal size to measure (um2)")
	Dialog.addSlider("Minimum:", 0.0, 5.0, 0.2);
	Dialog.addMessage("");
	Dialog.addCheckbox("Show ellipses", true);
	Dialog.addCheckbox("Show threshold", true);
	Dialog.addCheckbox("Show analysed image", true);
	Dialog.addMessage("");
	Dialog.addSlider("Slice for threshold:", 1, 10, 2);
	Dialog.addCheckbox("Select slice for each image", false);
	Dialog.show;
	channel = Dialog.getRadioButton();
	watershed=Dialog.getCheckbox();
	GBDiam=Dialog.getNumber();	
	minSize=Dialog.getNumber();
	showEllipses=Dialog.getCheckbox();
	showThreshold=Dialog.getCheckbox();
	showImage=Dialog.getCheckbox();
	thresholdSlice=Dialog.getNumber();
	chooseSlice=Dialog.getCheckbox();
	list = getFileList(directory);
	/*for (j=0; j<list.length; j++) { // ensures ignoring subfolders, if they are last alphabetically
		if (endsWith(list[j], "/")) {
			list=Array.trim(list, j);
		}
	}*/
	for (i=0; i<list.length; i++) {
		setBatchMode(true);
		open(directory + list[i]);
		tit=getTitle();
		getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
		if (channels<channel) {
			Dialog.create("Not enough channels");
			Dialog.addMessage(tit+" doesn't have "+channel+" channels.");
			Dialog.addMessage("It only has "+channels+" channels.");
			Dialog.show();
			exit()
		}
		n=nResults;
		AnalPart ();
		setBatchMode("exit and display");
		waitForUser("Proceed to the next image? \n(Press Escape to abort)");
	}
	Dialog.create("Finished!");
	Dialog.addMessage("That was the last image.");
	Dialog.addMessage("Measurements are in Summay windows.");
	Dialog.show();
}

function AnalPart() {
	title=getTitle();
	run("Split Channels");
	selectWindow("C"+channel+"-"+title);
	run("Duplicate...", "duplicate"); // To enable analysis of selected channel and yet closing all others
	title2=getTitle();
	selectWindow("C1-"+title);
	close();
	if(channels>1) {
		selectWindow("C2-"+title);
		close();
		if(channels>2) {
			selectWindow("C3-"+title);
			close();
			if(channels>3) {
				selectWindow("C4-"+title);
				close();
			}
		}
	}
	roi=roiManager("count"); // to make sure there are no ROIs in ROI manager
	if(roi>0) {
		roiManager("deselect");
		roiManager("delete");
	}

	if (chooseSlice==1) {
		Dialog.create("Choose slice for threshold");
		Dialog.addSlider("Slice for threshold:", 1, slices, 2);
		Dialog.show();
		chooseSlice=Dialog.getCheckbox();
	}
	
	selectWindow(title2);
	imageID=getImageID();
	run("Duplicate...", "duplicate");
	run("Gaussian Blur...", "sigma="+GBDiam+" stack");
	
	setSlice(thresholdSlice);
	//setAutoThreshold("Default dark"); // set threshold automatically
	//*
	setThreshold(30, 255); // set threshold manually
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Default"); // creating thresholded binary image
	//*/
	if(watershed==1) {
		run("Watershed", "stack");
	}
	thresholdID=getImageID();
	run("Set Measurements...", "area mean standard min perimeter fit shape redirect=None decimal=3");
	run("Analyze Particles...", "size="+minSize+"-Infinity show=Ellipses exclude summarize stack");
	ellipsesID=getImageID();
	if(showEllipses==0) {
		selectImage(ellipsesID);
		close();
	}
	if(showThreshold==0) {
		selectImage(thresholdID);
		close();
	}
	if(showImage==0) {
		selectImage(imageID);
		close();
	}
}





