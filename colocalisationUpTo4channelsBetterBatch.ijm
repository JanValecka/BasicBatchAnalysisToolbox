macro "colocalisationUpTo4channelsBetterBatch" {
	// This macro uses JACoP plugin to get Pearson's coefficient of colocalisation between all of 4 channels of an image
	// Enables setting manual threshold, abything below becomes black (black isn't used for colocalisation calculation)
	// Threshold is selected in one channel and applied to all channels. The idea is to define a cell and exclude
	// the outside of the cell, which can otherwise increase colocalisation.
	// If not measuring a stack, it's better to use Coloc2 and ROI.
	directory=getDirectory("Choose a Directory");
	setBatchMode(true);
	Dialog.create ("Settings");
	Dialog.addMessage ("Only measure the cell, don't include outside of the cell!");
	Dialog.addMessage ("If not measuring a stack, it's better to use Coloc2 and ROI.");
	Dialog.addMessage ("");
	Dialog.addCheckbox ("Apply manual background", false);items = newArray("1", "2", "3", "4");
	Dialog.addRadioButtonGroup("Channel to define cells", items, 1, 4, "1");
	Dialog.addSlider ("Background:", 0, 255, 30);
	Dialog.addMessage ("");
	Dialog.addMessage ("Choose noisy channels (Gaussian blur will be applied on them)");
	Dialog.addMessage ("WARNING! This increases colocalisation!");
	Dialog.addCheckbox ("Channel 1", false);
	Dialog.addCheckbox ("Channel 2", false);
	Dialog.addCheckbox ("Channel 3", false);
	Dialog.addCheckbox ("Channel 4", false);
	Dialog.show;
	manBcg = Dialog.getCheckbox();
	chBcg = Dialog.getRadioButton();
	bcg = Dialog.getNumber();
	GB1 = Dialog.getCheckbox();
	GB2 = Dialog.getCheckbox();
	GB3 = Dialog.getCheckbox();
	GB4 = Dialog.getCheckbox();
	list = getFileList(directory);
	print("\\Clear");
	run("Clear Results");
	for (k=0; k<list.length; k++) { // ensures ignoring subfolders
		if (endsWith(list[k], "/")) {
			list=Array.trim(list, k);
		}
	}
	for (i=0; i<list.length; i++) {
		open(directory + list[i]);
		tit=getTitle();
		getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
		if(channels>1) {
			measurements=1;
			if(channels>2) {
				measurements=3;
				if(channels>3) {
					measurements=6;
				}
			}
		}
		coloc();
		for (j=0; j<measurements; j++) {
			dataStr = split( getInfo("log"), "\n" );
			ch1 = substring( dataStr[6*j+1], indexOf( dataStr[6*j+1], ":" ) + 2, lengthOf( dataStr[6*j+1] ) );
			ch2 = substring( dataStr[6*j+2], indexOf( dataStr[6*j+2], ":" ) + 2, lengthOf( dataStr[6*j+2] ) );
			r = substring( dataStr[6*j+5], indexOf( dataStr[6*j+5], "=" ) + 1, lengthOf( dataStr[6*j+5] ) );
			//To show coloc values as columns and images as rows:
			setResult("Image", i, tit);
			setResult("Coloc "+ch1+" "+ch2, i, r);
			//*/
			/*/
			//To show images as columns and coloc values as rows
			setResult("Channels", j, ch1+" "+ch2);
			setResult(tit, j, r);
			//*/
		}
	}
	updateResults;
	dirArr = split( directory, "\\" );
	condition = dirArr[dirArr.length-1];
	String.resetBuffer
	for (n=0; n<dirArr.length-1; n++) {
		String.append(dirArr[n]);
		String.append("\\");
		dirParent = String.buffer;	
	}
	//File.makeDirectory(dirParent+"quantification");
	//saveAs("Results", dirParent+"quantification\\colocalisation "+condition+".csv");
	//close("Log");
	setBatchMode(false);
}	

function coloc() {	
	title=getTitle();
	getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
	print("\\Clear");
	if(channels>4) {
		showMessage("Too many channels", "This macro is intended for up to 4 channel images only.")
	}
	if(channels==2) { // changes 2-channel images to 4-channel by adding 2 black channels
		newImage("C3-"+title, "8-bit black", width, height, slices);
		newImage("C4-"+title, "8-bit black", width, height, slices);
		selectWindow(title);
		run("Split Channels");
		run("Merge Channels...", "c1=[C1-"+title+"] c2=[C2-"+title+"] c3=[C3-"+title+"] c4=[C4-"+title+"] create");
		rename(title);
	}
	if(channels==3) { // changes 3-channel images to 4-channel by adding 1 black channel
		newImage("C4-"+title, "8-bit black", width, height, slices);
		selectWindow(title);
		run("Split Channels");
		run("Merge Channels...", "c1=[C1-"+title+"] c2=[C2-"+title+"] c3=[C3-"+title+"] c4=[C4-"+title+"] create");
		rename(title);
	}
	if(GB1==1) {
		run("Split Channels");
		selectWindow("C1-"+title);
		run("Gaussian Blur...", "sigma=1 stack");
		run("Merge Channels...", "c1=[C1-"+title+"] c2=[C2-"+title+"] c3=[C3-"+title+"] c4=[C4-"+title+"] create");
		rename(title);
	}
	if(GB2==1) {
		run("Split Channels");
		selectWindow("C2-"+title+"");
		run("Gaussian Blur...", "sigma=1 stack");
		run("Merge Channels...", "c1=[C1-"+title+"] c2=[C2-"+title+"] c3=[C3-"+title+"] c4=[C4-"+title+"] create");
		rename(title);
	}
	if(GB3==1) {
		run("Split Channels");
		selectWindow("C3-"+title);
		run("Gaussian Blur...", "sigma=1 stack");
		run("Merge Channels...", "c1=[C1-"+title+"] c2=[C2-"+title+"] c3=[C3-"+title+"] c4=[C4-"+title+"] create");
		rename(title);
	}
	if(GB4==1) {
		run("Split Channels");
		selectWindow("C4-"+title);
		run("Gaussian Blur...", "sigma=1 stack");
		run("Merge Channels...", "c1=[C1-"+title+"] c2=[C2-"+title+"] c3=[C3-"+title+"] c4=[C4-"+title+"] create");
		rename(title);
	}
	if (manBcg==1) {
		/* turns background back (black isn't used for colocalisation calculation)
		based on channel selected in the first dialog
		uses gaussian blur to make edges smoother */
		run("Split Channels");
		selectWindow("C"+chBcg+"-"+title);
		run("Duplicate...", "duplicate");
		rename("mask_template");
		run("Gaussian Blur...", "sigma=1");
		setThreshold(bcg, 255);
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Default background=Dark calculate black");
		rename("mask");
		imageCalculator("AND create stack", "mask","C1-"+title);
		rename("C1");
		imageCalculator("AND create stack", "mask","C2-"+title);
		rename("C2");
		imageCalculator("AND create stack", "mask","C3-"+title);
		rename("C3");
		imageCalculator("AND create stack", "mask","C4-"+title);
		rename("C4");
		run("Merge Channels...", "c1=C1 c2=C2 c3=C3 c4=C4 create");
		rename(title);
		selectWindow("C1-"+title);
		close();
		selectWindow("C2-"+title);
		close();
		selectWindow("C3-"+title);
		close();
		selectWindow("C4-"+title);
		close();
		selectWindow("mask");
		close();
	}	
	run("Split Channels");
	ch1="C1-"+title ;
	ch2="C2-"+title ;
	ch3="C3-"+title ;
	ch4="C4-"+title ;
	selectWindow(ch1);
	rename("C1"); // I couldn't set variable as argument, so I need uniform names
	selectWindow(ch2);
	rename("C2");
	run("JACoP ", "imga=[C1] imgb=[C2] pearson");
	if(channels>2) {
		selectWindow(ch3);
		rename("C3");
		run("JACoP ", "imga=[C1] imgb=[C3] pearson");
		run("JACoP ", "imga=[C2] imgb=[C3] pearson");
		if(channels>3) {
			selectWindow(ch4);
			rename("C4");
			run("JACoP ", "imga=[C1] imgb=[C4] pearson");
			run("JACoP ", "imga=[C2] imgb=[C4] pearson");
			run("JACoP ", "imga=[C3] imgb=[C4] pearson");
			if(channels>4) {
				showMessage("Too many channels", "This macro is intended for up to 4 channel images only.")
			}
			run("Merge Channels...", "c1=C1 c2=C2 c3=C3 c4=C4 create");
		}
		else {
			run("Merge Channels...", "c1=C1 c2=C2 c3=C3 create");
		}
	}
	else {
		run("Merge Channels...", "c1=C1 c2=C2 create");
	}
	selectWindow("Composite");
	rename(title); //returning to the original state, since splitting channels closes original image
	close();
}
