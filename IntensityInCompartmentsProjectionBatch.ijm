macro "IntensityInCompartmentsBatch" {
	/*
	 *  Macro for measuring intensity of fluorescence in different part of the cell
	 *  (model case is nucleus and cytolasm) 1 channel can be used to define whole cell, another to define compartment
	 *  Another channel can be used for the measurement
	 *  Made to work on RGB images, but measureCompartments function should work for 2-4 channel images
	 *  If manual check of selected areas are required, activate waitForUser (line 99) and inactivate batch mode (line 9)
	 */
	setBatchMode(true);
	//run("Set Measurements...", "area mean standard min integrated median redirect=None decimal=3");
	Dialog.create ("Settings");
	items = newArray("1", "2", "3", "4");
	items2 = newArray(".czi", ".lsm", ".tif");
	Dialog.addRadioButtonGroup("Source images filetype", items2, 1, 4, ".tif")
	Dialog.addMessage ("");
	Dialog.addRadioButtonGroup("Channel defining cell outline", items, 1, 4, "2");
	Dialog.addSlider ("Background:", 0, 255, 2);
	Dialog.addMessage ("");
	Dialog.addRadioButtonGroup("Channel defining nucleus outline", items, 1, 4, "3");
	Dialog.addSlider ("Background:", 0, 255, 8);
	Dialog.addMessage ("");
	Dialog.addRadioButtonGroup("Channel to measure", items, 1, 4, "2");
	Dialog.addMessage("");
	Dialog.addMessage("Next, select folder with raw images");
	Dialog.show;
	filetype=Dialog.getRadioButton();
	chCell = Dialog.getRadioButton();
	bcgCell = Dialog.getNumber();
	chNuc = Dialog.getRadioButton();
	bcgNuc = Dialog.getNumber();
	chMes = Dialog.getRadioButton();

	sourceDir=getDirectory("Choose a folder containing only source images. Results will be saved there.");

	list = getFileList(sourceDir);
	for (i=0; i<list.length; i++) {
		roi=roiManager("count"); //cleaning up ROI manager, it needs to be empty
		if(roi>0) {
			roiManager("deselect");
			roiManager("delete");
		}
		if (endsWith(list[i], filetype)) { //to only open pictures of specified type
			open(sourceDir + list[i]);
			run("Make Composite"); // converting RGB images into 3-channel images
			title=getTitle();
			getDimensions(width, height, channels, slices, frames);
			measureCompartments();
			setResult("Image", 2*i, title);
			setResult("Image", 2*i+1, title);
			setResult("Compartment", 2*i, "cytoplasm");
			setResult("Compartment", 2*i+1, "nucleus");
			updateResults();
		}
	}
	
	selectWindow("Results");
	saveAs("results", sourceDir+"Results.txt");
	//close("Results");
	Dialog.create ("Done!");
	Dialog.addMessage ("Results were saved in "+sourceDir);
	Dialog.show;
	setBatchMode(false);
}

function measureCompartments() {
	selectWindow(title);
	rename("Image");
	run("Split Channels");
	// selecting cell outline:
	selectWindow("C"+chCell+"-Image");
	run("Duplicate...", "duplicate");
	run("Gaussian Blur...", "sigma=2");
	setThreshold(bcgCell, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark calculate black");
	run("Create Selection");
	roiManager("Add");
	close();
	// selecting nucleus outline:
	selectWindow("C"+chNuc+"-Image");
	run("Duplicate...", "duplicate");
	run("Gaussian Blur...", "sigma=2");
	setThreshold(bcgNuc, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark calculate black");
	run("Create Selection");
	roiManager("Add");
	close();
	// making an "outside the nucleus" selection
	//print("start");
	roiManager("Select", newArray(0,1));
	roiManager("Combine");
	roiManager("Add");
	//print("cell+nuc added");
	roiManager("Select", newArray(1,2));
	roiManager("XOR");
	roiManager("Add");
	//print("cell-nuc added");
	//waitForUser("Now you can check and edit ROI"); // to check if gating is good
	/*
	there are now 4 selections in the ROI manager:
	0 - cell outline
	1 - nucleus
	2 - cell + nucleus
	3 - cell outside of nucleus
	*/
	selectWindow("C"+chMes+"-Image");
	roiManager("Select", 3);
	run("Measure");
	roiManager("Select", 1);
	run("Measure");	
	selectWindow("C1-Image");
	close();
	selectWindow("C2-Image");
	close();
	if(channels>2) {
		selectWindow("C3-Image");
		close();
		if(channels>3) {
			selectWindow("C4-Image");
			close();
		}
	}
}
