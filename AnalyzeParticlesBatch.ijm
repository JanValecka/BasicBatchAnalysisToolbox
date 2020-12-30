macro "AnalyzeParticlesBatch" {
	/*
	 * causes bug if the first image doesn't have enough particles for some reason
	 */
	run("Clear Results");
	directory=getDirectory("Choose a Directory");
	setBatchMode(true);
	Dialog.create("Choose channel");
	items = newArray("1", "2", "3", "4");
	Dialog.addRadioButtonGroup("Channel to analyze", items, 1, 4, "1");
	Dialog.addMessage("")
	Dialog.addMessage("Threshold values")
	Dialog.addSlider("Minimum:", 1, 255, 40);
	Dialog.addSlider("Maximum:", 1, 255, 255);
	Dialog.addCheckbox("Watershed", false);
	Dialog.addMessage("")
	Dialog.addSlider("Gaussian blur diameter:", 0.0, 2.0, 1.2);
	Dialog.show;
	channel = Dialog.getRadioButton();
	min=Dialog.getNumber();
	max=Dialog.getNumber();
	watershed=Dialog.getCheckbox();
	GBDiam=Dialog.getNumber();
	list = getFileList(directory);
	/*for (j=0; j<list.length; j++) { // ensures ignoring subfolders, if they are last alphabetically
		if (endsWith(list[j], "/")) {
			list=Array.trim(list, j);
		}
	}*/
	for (i=0; i<list.length; i++) {
		open(directory + list[i]);
		//run("Z Project...", "projection=[Max Intensity]"); // works only on single slice images
		tit=getTitle();
		getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
		if (channels<channel) {
			Dialog.create("Not enough channels");
			Dialog.addMessage(tit+" doesn't have "+channel+" channels.")
			Dialog.addMessage("It only has "+channels+" channels.")
			Dialog.show();
			exit()
		}
		n=nResults;
		AnalPart ();
		n2=nResults;
		for(k=0; k<n2-n; k++) {
			setResult("Image", n+k, tit);
			setResult("Particles in cell", n+k, n2-n);
			setResult("Threshold min", n+k, min);
			setResult("Threshold max", n+k, max);
			setResult("Channel", n+k, channel);
		}
		setResult("Image", n, tit); // Prints names of images without particles. Too many of these cause errors, just skip this line until I fix it.
		updateResults;
		//close();
	}
	dirArr = split( directory, "\\" );
	condition = dirArr[dirArr.length-1];
	String.resetBuffer
	for (n=0; n<dirArr.length-1; n++) {
		String.append(dirArr[n]);
		String.append("\\");
		dirParent = String.buffer;	
	}
	File.makeDirectory(dirParent+"quantification");
	saveAs("Results", dirParent+"quantification\\particles ch"+channel+" "+condition+".csv");
	setBatchMode(false);
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
	roi=roiManager("count");
	if(roi>0) {
		roiManager("deselect");
		roiManager("delete");
	}
	selectWindow(title2);
	run("Duplicate...", "duplicate");
	run("Gaussian Blur...", "sigma="+GBDiam); // ##### Set blur diameter (sigma) HERE #### 0.8 for big stuff, 1.2 for more diffuse stuff
	setThreshold(min, max);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	if(watershed==1) {
		run("Watershed");
	}
	run("Analyze Particles...", "exclude add summarize");
	close(); // closing visualisation of ROIs
	selectWindow(title2);
	roiManager("deselect");
	roiManager("measure");
	selectWindow(title2);
	close();
}
		
