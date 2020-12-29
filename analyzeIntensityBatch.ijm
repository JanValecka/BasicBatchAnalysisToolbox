macro "analyzeIntensityBatch" {
	/*
	 * Measures intensity of fluorescence in all the images in selected folder in selected channel.
	 * Measures only in area determined by threshold performed after Gaussian blur.
	 * Thus doesn't include background in the measurement.
	 * Minimum may be below threshold because of the Gaussian blur.
	 * Results saved as .csv file in a parent folder, where a directory calle quantification is created.
	 */
	run("Clear Results");
	//run("Set Measurements...", "area mean min redirect=None decimal=3"); //make sure your measurements are set correctly
	directory=getDirectory("Choose a Directory");
	Dialog.create("Choose channel");
	items = newArray("1", "2", "3", "4");
	Dialog.addRadioButtonGroup("Channel to analyze", items, 1, 4, "1");
	Dialog.addMessage("")
	Dialog.addMessage("Threshold values")
	Dialog.addSlider("Minimum:", 1, 255, 10);
	Dialog.addSlider("Maximum:", 1, 255, 255);
	Dialog.addMessage("")
	Dialog.addMessage("Gaussian blur diameter")
	Dialog.addSlider("Minimum:", 0.0, 3.5, 1.0);
	Dialog.addMessage("")
	Dialog.addMessage("Image file type")
	types = newArray(".czi", ".lsm", ".tif");
	Dialog.addRadioButtonGroup("Source images filetype", types, 1, 3, ".czi");
	Dialog.show();
	channel = Dialog.getRadioButton();
	min=Dialog.getNumber();
	max=Dialog.getNumber();
	blurDiameter=Dialog.getNumber();
	filetype=Dialog.getRadioButton();
	setBatchMode(true);
	list = getFileList(directory);
	j=0
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i],filetype)) { // to ignore other than desired image type files
			open(directory + list[i]);
			tit=getTitle();
			resetMinAndMax();
			getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
			run("Z Project...", "projection=[Max Intensity]");
			if (channels<channel) {
				Dialog.create("Not enough channels");
				Dialog.addMessage(tit+" doesn't have "+channel+" channels.")
				Dialog.addMessage("It only has "+channels+" channels.")
				Dialog.show();
				exit()
			}
			selectWindow(tit);
			close();
			analyzeIntensity();
			setResult("Image", i-j, tit);
			setResult("Channel", i-j, channel);
			setResult("Threshold min", i-j, min);
			setResult("Threshold max", i-j, max);
			setResult("Gaussian blur diameter", i-j, blurDiameter);
			updateResults;
		}
		else {
			j++;
		}
	}
	// following section saves results in a folder called "quantification" located in a parent directory to the analysed directory
	//*/
	dirArr = split( directory, "\\" );
	condition = dirArr[dirArr.length-1];
	String.resetBuffer
	for (n=0; n<dirArr.length-1; n++) {
		String.append(dirArr[n]);
		String.append("\\");
		dirParent = String.buffer;	
	}
	File.makeDirectory(dirParent+"quantification");
	saveAs("Results", dirParent+"quantification\\intensity ch"+channel+" "+condition+".csv");
	setBatchMode(false);
	showMessageWithCancel("Analysis finished!", "Results were saved in:\n"+dirParent+"quantification\n \nClose results?");
	selectWindow("Results");
	run("Close" );
	//*/
}

function analyzeIntensity() {
	title=getTitle();
	selectWindow(title);
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
	} // Only analyzed, duplicated channel remains open
	selectWindow(title2);
	roi=roiManager("count"); //cleaning up ROI manager, it needs to be empty
	if(roi>0) {
		roiManager("deselect");
		roiManager("delete");
	}
	selectWindow(title2);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma="+blurDiameter); // 0.8 for big stuff, 1.2 for more diffuse stuff
	//run("Threshold...");
	setThreshold(min, max);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark calculate");
	run("Create Selection");
	
	if (selectionType()==-1) { //in case there is no selection, it makes a point selection in top left corner. Othrewise produces an error.
		close();
	}
	else {
		roiManager("Add");
		close();
		roiManager("Select", 0);
		roiManager("Measure");
	}
	selectWindow(title2);
	close();
}
