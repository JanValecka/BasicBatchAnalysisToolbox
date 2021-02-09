macro "Montage Action Tool - Cf00 F0077 C0f0 F9077 C00f F0977 C888 F9977" {
	/* Inspired by Magic Montage toolset
	 * For creating montage of all images in a folder with up to 4 channels
	 * With 4 channels, there are 4 channels on the left, 2 composite channels on the right
	 * With 2 or 3 channels, all channels are in a row with one composite on the right
	 * This macro changes levels of all channels and creates a montage with a scale bar and saves them
	 * You can add white spaces between channels
	 */
	saveSettings();
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timeString=""+year+"-"+substring("0"+month+1,lengthOf("0"+month+1)-2)+"-"+substring("0"+dayOfMonth,lengthOf("0"+dayOfMonth)-2)+" "+substring("0"+hour,lengthOf("0"+hour)-2)+"."+substring("0"+minute,lengthOf("0"+minute)-2);
	override=false;
	// manual settings, if you prefer typing in macro editor to dialogue windows
	// only used if manuall override is checked
	// still must set filetype and which channels should be in the montage by dialogue
	min1=10
	max1=255
	min2=20
	max2=255
	min3=10
	max3=255
	min4=20
	max4=255
	LUT1="Green";
	LUT2="Grays";
	LUT3="Blue";
	LUT4="Red";
	channelOrder="1234"
	barWidth=20 // how long the scalebar is
	barHeight=12 // how thick the bar is
	barFont=42 // what font does the bar label have
	Dialog.create("Levels and LUT settings");
	LUT = newArray("Red", "Green", "Blue", "Grays", "Cyan", "Magenta", "Yellow");
	//Dialog.addCheckbox("Manual override", false); // To activate manual override option, delete "//" at the beginning of this line
	Dialog.addMessage("");
	Dialog.addMessage("Channel 1");
	Dialog.addRadioButtonGroup("Channel colour:", LUT, 1, 7, "Red");
	Dialog.addSlider ("min:", 0, 255, 0);
	Dialog.addToSameRow();
	Dialog.addSlider ("max:", 0, 255, 255);
	Dialog.addMessage("");
	Dialog.addMessage("Channel 2");
	Dialog.addRadioButtonGroup("Channel colour:", LUT, 1, 7, "Green");
	Dialog.addSlider ("min:", 0, 255, 0);
	Dialog.addToSameRow();
	Dialog.addSlider ("max:", 0, 255, 255);
	Dialog.addMessage("");
	Dialog.addMessage("Channel 3");
	Dialog.addRadioButtonGroup("Channel colour:", LUT, 1, 7, "Blue");
	Dialog.addSlider ("min:", 0, 255, 0);
	Dialog.addToSameRow();
	Dialog.addSlider ("max:", 0, 255, 255);
	Dialog.addMessage("");
	Dialog.addMessage("Channel 4");
	Dialog.addRadioButtonGroup("Channel colour:", LUT, 1, 7, "Grays");
	Dialog.addSlider ("min:", 0, 255, 0);
	Dialog.addToSameRow();
	Dialog.addSlider ("max:", 0, 255, 255);
	Dialog.addMessage("");
	Dialog.addMessage("Next, select folder with raw images");
	Dialog.show;
	// reading data from the first dialogue
	override = Dialog.getCheckbox();
	if (override) {
		}
	else {
		LUT1 = Dialog.getRadioButton();
		min1 = Dialog.getNumber();
		max1 = Dialog.getNumber();
		LUT2 = Dialog.getRadioButton();
		min2 = Dialog.getNumber();
		max2 = Dialog.getNumber();
		LUT3 = Dialog.getRadioButton();
		min3 = Dialog.getNumber();
		max3 = Dialog.getNumber();
		LUT4 = Dialog.getRadioButton();
		min4 = Dialog.getNumber();
		max4 = Dialog.getNumber();
	}
	sourceDir=getDirectory("Choose a folder with images");
	Dialog.create("Other parameters");
	items = newArray("A", "B", "D", "E");
	items2 = newArray(".tif", ".czi", ".lsm", "Other:");
	Dialog.addRadioButtonGroup("Source images filetype", items2, 1, 4, ".tif")
	Dialog.addString("Other filetype", "");
	Dialog.addMessage("");
	Dialog.addString("Order of single channels", "1234");
	Dialog.addMessage("");
	Dialog.addMessage("Channels in top composite panel (after reordering the channels)"); // currently very unintuitive
	Dialog.addCheckboxGroup(1, 4, items, items);
	Dialog.addMessage("");
	Dialog.addMessage("Channels in bottom composite panel (after reordering the channels)"); // currently very unintuitive
	Dialog.addCheckboxGroup(1, 4, items, items);
	Dialog.addMessage("");
	Dialog.addMessage("Space between panels of montage");
	Dialog.addSlider ("space (px):", 0, 20, 1);
	Dialog.addMessage("");
	Dialog.addMessage("");
	Dialog.addMessage("Scale bar");
	Dialog.addMessage("");
	Dialog.addSlider ("length (um):", 0, 100, 20); //check empirically, if I'm providing reasonable values here
	Dialog.addSlider ("bar thickness (px):", 0, 30, 8);
	Dialog.addSlider ("font size:", 0, 100, 28);
	Dialog.addMessage("");	
	Dialog.addMessage("Next, select folder to save the montages");
	Dialog.show;
	//reading data from the second dialogue
	filetype=Dialog.getRadioButton();
	if(filetype=="Other:") {
		filetypeOther = Dialog.getString();
		filetype=filetypeOther;
		if(filetype=="") {
			restoreSettings;
			exit("When you select Other filetype, you have to specify which.");
		}
	}
	else {
		discard = Dialog.getString();
	}
	if (override) {
		}
	else {
		channelOrder = Dialog.getString();
	}
	a1=Dialog.getCheckbox();
	a2=Dialog.getCheckbox();
	a3=Dialog.getCheckbox();
	a4=Dialog.getCheckbox();
	b1=Dialog.getCheckbox();
	b2=Dialog.getCheckbox();
	b3=Dialog.getCheckbox();
	b4=Dialog.getCheckbox();
	space=Dialog.getNumber();
	if (override) {
		}
	else {
		barWidth = Dialog.getNumber();
		barHeight = Dialog.getNumber();
		barFont = Dialog.getNumber();
	}
	saveDir=getDirectory("Select a folder to save your montages");
	print("\\Clear");
	setBatchMode(true);
	setBackgroundColor(0,0,0); // background has to be set to black, otherwise montages are white, because white borders between panles rely on making white rectangles and then clearing selected spaces to the background colour
	logValues(); //prints log of values used for edits
	list = getFileList(sourceDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], filetype)) { //to only open pictures of specified type
			open(sourceDir + list[i]);
			tit=getTitle();
			getDimensions(width, height, channels, slices, frames);
			AllEditsInOne();
			if(channels==2) {
				montage2();
			}
			if(channels==3) {
				montage3();
			}
			if(channels==4) {
				montage4();
			}
			print(tit); // adds name of a processed image to the log
			saveAs("Tiff", saveDir+"/Montage of MAX_"+tit);
			close();
    		close();
    	}
    }
    selectWindow("Log");
	saveAs("Text", saveDir+timeString+" Log of montage making"+filetype+" files.txt"); //saves log
	run("Close"); //closes log
	restoreSettings;
	setBatchMode(false);
	showMessage("Finished!", "Montage making is finished.\n \nYour montages are in:\n"+saveDir);
}

function AllEditsInOne() {
	run("Arrange Channels...", "new=1234"); // to avoid bug where channles aren't recognised (though could be counted)
	Stack.setChannel(1);
	run(LUT1);
	if (channels>1) {
		Stack.setChannel(2);
		run(LUT2);
	}
	if (channels>2) {
		Stack.setChannel(3);
		run(LUT3);
	}
	if (channels>3) {
		Stack.setChannel(4);
		run(LUT4);
	}
	if (channels>4) {
		showMessage("Too many channels", "This macro is intended for images with maximum of 5 channels.");
		restoreSettings;
		exit;
	}
	if (slices>1) { // makes Z-projection, if an image is a stack
		stack = getTitle();
		run("Z Project...", "projection=[Max Intensity]");
		selectWindow(stack);
		close();
	}	
	title=getTitle();
	run("Split Channels");
	ch1="C1-"+title ;
	ch2="C2-"+title ;
	ch3="C3-"+title ;
	ch4="C4-"+title ;	
	selectWindow(ch1);
	setMinAndMax(min1, max1);
	ApplyLUT();
	rename("to_be_merged-C1");
	if (channels>1) {
		selectWindow(ch2);
		setMinAndMax(min2, max2);
		ApplyLUT();
		rename("to_be_merged-C2");
	}
	if (channels>2) {
		selectWindow(ch3);
		setMinAndMax(min3, max3);
		ApplyLUT();
		rename("to_be_merged-C3");
	}
	if (channels>3) {
		selectWindow(ch4);
		setMinAndMax(min4, max4);
		ApplyLUT();
		rename("to_be_merged-C4");
	}
	if (channels==1) {
		rename("Composite");
	}
	if (channels==2) {
		run("Merge Channels...", "c1=to_be_merged-C1 c2=to_be_merged-C2 create");
	}
	if (channels==3) {
		run("Merge Channels...", "c1=to_be_merged-C1 c2=to_be_merged-C2 c3=to_be_merged-C3 create");
	}
	if (channels==4) {
		run("Merge Channels...", "c1=to_be_merged-C1 c2=to_be_merged-C2 c3=to_be_merged-C3 c4=to_be_merged-C4 create");
	}
	selectWindow("Composite");
	rename(title);
	run("Arrange Channels...", "new="+channelOrder+"");
}

/* Apply LUT doesn't work if set for (0, 255), 
hence the if condition and GetMinAndMax */
function ApplyLUT() {
	getMinAndMax(min,max);
	if (min != 0 || max != 255) {
    	run("Apply LUT", "stack");
    	}
	}

function montage2() {
	w = getWidth;
	h = getHeight;
	title=getTitle();
	//following part creates montage
	getVoxelSize(xp,yp,zp,unit);
	saveSettings();
	run("Duplicate...", "duplicate");
	rename("channel");
	run("Stack to Images");
	newImage("Montage of "+title, "RGB white", w*3+2*space, h, 1);
	selectWindow("channel-0001");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(0, 0, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	selectWindow("channel-0002");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(w+space, 0, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	makeRectangle(w*2+2*space, 0, w, h);
	run("Clear", "slice"); //making the background for the montage black, background of the whole image is white to enable white spaces between panels
	setVoxelSize(xp,yp,zp,unit);
	// Montage is now created
	setPasteMode("copy"); //copy panel 1
	makeRectangle(0, 0, w, h);
	run("Copy");
    setPasteMode("add");
    if(a1==1) {
    	makeRectangle(w*2+2*space, 0, w, h);
		run("Paste");
    }
    setPasteMode("copy"); //copy panel 2
	makeRectangle(w+space, 0, w, h);
	run("Copy");
    setPasteMode("add");
	if(a2==1) {
    	makeRectangle(w*2+2*space, 0, w, h);
		run("Paste");
    }
    run("Select None");
	run("Scale Bar...", "width="+barWidth+" height="+barHeight+" font="+barFont+" color=White background=None location=[Lower Right] bold");
    restoreSettings();
    //*/
}

function montage3() { //at the moment makes montage with 4 images in a row. Can be easily switched to 2x2. Make it an option?
	w = getWidth;
	h = getHeight;
	title=getTitle();
	//following part creates montage
	getVoxelSize(xp,yp,zp,unit);
	saveSettings();
	run("Duplicate...", "duplicate");
	rename("channel");
	run("Stack to Images");
	newImage("Montage of "+title, "RGB white", w*4+3*space, h, 1);
	selectWindow("channel-0001");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(0, 0, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	selectWindow("channel-0002");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(w+space, 0, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	selectWindow("channel-0003");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(w*2+2*space, 0, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	makeRectangle(w*3+3*space, 0, w, h);
	run("Clear", "slice"); //making the background for the montage black, background of the whole image is white to enable white spaces between panels
	setVoxelSize(xp,yp,zp,unit);
	// Montage is now created
	setPasteMode("copy"); //copy panel 1
	makeRectangle(0, 0, w, h);
	run("Copy");
    setPasteMode("add");
    if(a1==1) {
    	makeRectangle(w*3+3*space, 0, w, h);
		run("Paste");
    }
    setPasteMode("copy"); //copy panel 2
	makeRectangle(w+space, 0, w, h);
	run("Copy");
    setPasteMode("add");
	if(a2==1) {
    	makeRectangle(w*3+3*space, 0, w, h);
		run("Paste");
    }
    setPasteMode("copy"); //copy panel 3
	makeRectangle(w*2+2*space, 0, w, h);
	run("Copy");
    setPasteMode("add");
	if(a3==1) {
    	makeRectangle(w*3+3*space, 0, w, h);
		run("Paste");
    }
	run("Select None");
	run("Scale Bar...", "width="+barWidth+" height="+barHeight+" font="+barFont+" color=White background=None location=[Lower Right] bold");
    restoreSettings();
    //*/
}

function montage4() {
	w = getWidth;
	h = getHeight;
	title=getTitle();
	//following part creates montage
	getVoxelSize(xp,yp,zp,unit);
	saveSettings();
	run("Duplicate...", "duplicate");
	rename("channel");
	run("Stack to Images");
	newImage("Montage of "+title, "RGB white", w*3+2*space, h*2+1*space, 1);
	selectWindow("channel-0001");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(0, 0, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	selectWindow("channel-0002");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(w+space, 0, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	selectWindow("channel-0003");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(0, h+space, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	selectWindow("channel-0004");
	setPasteMode("copy");
	run("Select All");
	run("Copy");
	close();
	selectWindow("Montage of "+title);
	makeRectangle(w+space, h+space, w, h);
	run("Clear", "slice");
    setPasteMode("add");
	run("Paste");
	makeRectangle(w*2+2*space, 0, w, h);
	run("Clear", "slice");
	makeRectangle(w*2+2*space, h+space, w, h);
	run("Clear", "slice");
	setVoxelSize(xp,yp,zp,unit);
	// Montage is now created
	setPasteMode("copy"); //copy quadrant 1 (top left)
	makeRectangle(0, 0, w, h);
	run("Copy");
    setPasteMode("add");
    if(a1==1) {
    	makeRectangle(w*2+2*space, 0, w, h);
		run("Paste");
    }
	if(b1==1) {
    	makeRectangle(w*2+2*space, h+space, w, h);
		run("Paste");
    }
    setPasteMode("copy"); //copy quadrant 2 (top right)
	makeRectangle(w+space, 0, w, h);
	run("Copy");
    setPasteMode("add");
	if(a2==1) {
    	makeRectangle(w*2+2*space, 0, w, h);
		run("Paste");
    }
	if(b2==1) {
    	makeRectangle(w*2+2*space, h+space, w, h);
		run("Paste");
    }
    setPasteMode("copy"); //copy quadrant 3 (bottom left)
	makeRectangle(0, h+space, w, h);
	run("Copy");
    setPasteMode("add");
	if(a3==1) {
    	makeRectangle(w*2+2*space, 0, w, h);
		run("Paste");
    }
	if(b3==1) {
    	makeRectangle(w*2+2*space, h+space, w, h);
		run("Paste");
    }
    setPasteMode("copy"); //copy quadrant 4 (bottom right)
	makeRectangle(w+space, h+space, w, h);
	run("Copy");
    setPasteMode("add");
	if(a4==1) {
    	makeRectangle(w*2+2*space, 0, w, h);
		run("Paste");
    }
	if(b4==1) {
    	makeRectangle(w*2+2*space, h+space, w, h);
		run("Paste");
    }
	run("Select None");
	run("Scale Bar...", "width="+barWidth+" height="+barHeight+" font="+barFont+" color=White background=None location=[Lower Right] bold");
    restoreSettings();
    //*/
}

function logValues() {
	print("\\Clear");
	print("MontageHelperBatch macro was initiated at "+timeString);
	print(""+filetype+" images from "+sourceDir+" were processed.");
	print("");
	print("Channel 1:\nLUT: "+LUT1);
	print("min: "+min1+"\nmax: "+max1);
	print("");
	print("Channel 2:\nLUT: "+LUT2);
	print("min: "+min2+"\nmax: "+max2);
	print("");
	print("Channel 3:\nLUT: "+LUT3);
	print("min: "+min3+"\nmax: "+max3);
	print("");
	print("Channel 4:\nLUT: "+LUT4);
	print("min: "+min4+"\nmax: "+max4);
	print("");
	print("Single channels in the montage are in the following order: "+channelOrder);
	topPanelChannels=" ";
	if(a1==1) {topPanelChannels=topPanelChannels+"1";}
	if(a2==1) {topPanelChannels=topPanelChannels+"2";}
	if(a3==1) {topPanelChannels=topPanelChannels+"3";}
	if(a4==1) {topPanelChannels=topPanelChannels+"4";}
	print("Top composite panel contains channels:"+topPanelChannels);
	bottomPanelChannels=" ";
	if(b1==1) {bottomPanelChannels=bottomPanelChannels+"1";}
	if(b2==1) {bottomPanelChannels=bottomPanelChannels+"2";}
	if(b3==1) {bottomPanelChannels=bottomPanelChannels+"3";}
	if(b4==1) {bottomPanelChannels=bottomPanelChannels+"4";}
	print("Bottom composite panel contains channels:"+bottomPanelChannels);
	print("");
	print("Following images were processed:");
}

macro "Isolate Cells Action Tool - N22 C555 V2276 Vc776 V4c67 Ce00 R00a9" {
	/* First, select all your cells as ROIs in ROI manager
	 * (best done on duplicate with Z-project)
	 * shortcut to do that is Ctrl+t. Actually, you can just press T
	 */
	title=getTitle();
	run("Colors...", "foreground=black background=black selection=yellow");
	directory=getDirectory("Choose a directory to save single cells");
	cells=roiManager("count");
	for (i=0; i<cells; i++) { // duplicating single cells
		selectWindow(title);
		roiManager("Select", i);
		roiManager("Rename", title+"-"+i+1); // renaming ROI to match name of isolated cell file name
		run("Duplicate...", "duplicate");
		if (selectionType()!=-1) { // checking if only part of the image is selected
			run("Clear Outside", "stack"); // deletes part of the picture outside the selection
		}
	}
	selectWindow(title);
	close();
	for (i=0; i<cells; i++) { // saving and closing
		title2=getTitle();
		run("Save", "save=["+directory+title2+"]");
		close();
	}
	roiManager("Save", directory+"ROIs_"+title+".zip"); // saving ROIs for future reference
	
	waitForUser("Delete ROIs?\n(press Esc to keep them)");
	roiManager("deselect");
	roiManager("delete");
	// duplicating and saving can't be done in one step, as all the duplicates get the same name and overwrithe each other while saving
	// for some reason, batch mode causes an error
}

macro "Colocalisation Action Tool - N11 Cf00 F00ee C0f0 F44ee Cff0 F44aa" {
	// This macro uses JACoP plugin to get Pearson's coefficient of colocalisation between all of 4 channels of an image
	// Enables setting manual threshold, abything below becomes black (black isn't used for colocalisation calculation)
	// Threshold is selected in one channel and applied to all channels. The idea is to define a cell and exclude
	// the outside of the cell, which can otherwise increase colocalisation.
	// If not measuring a stack, it's better to use Coloc2 and ROI.
	setBatchMode(true);
	saveSettings();
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timeString=""+year+"-"+substring("0"+month+1,lengthOf("0"+month+1)-2)+"-"+substring("0"+dayOfMonth,lengthOf("0"+dayOfMonth)-2)+" "+substring("0"+hour,lengthOf("0"+hour)-2)+"."+substring("0"+minute,lengthOf("0"+minute)-2);
	Dialog.create ("Parameters");
	Dialog.addMessage ("Only measure the cell, don't include outside of the cell!");
	Dialog.addMessage ("");
	types = newArray(".tif", ".czi", ".lsm", "Other:");
	Dialog.addRadioButtonGroup("Source images filetype", types, 1, 4, ".tif")
	Dialog.addString("Other filetype", "");
	Dialog.addMessage ("");
	Dialog.addCheckbox ("Apply manual background (removes signal below threshold)", false);
	items = newArray("1", "2", "3", "4");
	Dialog.addRadioButtonGroup("Channel to define threshold", items, 1, 4, "1");
	Dialog.addSlider ("Threshold:", 0, 255, 30);
	Dialog.addMessage ("");
	Dialog.addMessage ("Choose noisy channels (Gaussian blur will be applied on them)");
	Dialog.addMessage ("WARNING! This increases colocalisation!");
	Dialog.addCheckbox ("Channel 1", false);
	Dialog.addCheckbox ("Channel 2", false);
	Dialog.addCheckbox ("Channel 3", false);
	Dialog.addCheckbox ("Channel 4", false);
	Dialog.show;
	filetype=Dialog.getRadioButton();
	if(filetype=="Other:") {
		filetypeOther = Dialog.getString();
		filetype=filetypeOther;
		if(filetype=="") {
			restoreSettings;
			exit("When you select Other filetype, you have to specify which.");
		}
	}
	else {
		discard = Dialog.getString();
	}
	manBcg = Dialog.getCheckbox();
	chBcg = Dialog.getRadioButton();
	bcg = Dialog.getNumber();
	GB1 = Dialog.getCheckbox();
	GB2 = Dialog.getCheckbox();
	GB3 = Dialog.getCheckbox();
	GB4 = Dialog.getCheckbox();	
	directory=getDirectory("Choose a folder with images");
	list = getFileList(directory);
	print("\\Clear");
	run("Clear Results");
	/*for (k=0; k<list.length; k++) { // ensures ignoring subfolders
		if (endsWith(list[k], "/")) {
			list=Array.trim(list, k);
		}
	}*/
	k=0; //counter of actually open images for setting results
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], filetype)) { //to only open pictures of specified type
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
				setResult("Image", k, tit);
				if (manBcg) {
					setResult("Channel for removing background", k, chBcg);
					setResult("Threshold value", k, bcg);
				}
				else {
					setResult("Channel for removing background", k, "none");
					setResult("Threshold value", k, "N/A");
				}
				blurredCh="";
				if(GB1==1) {blurredCh=blurredCh+"1";}
				if(GB2==1) {blurredCh=blurredCh+"2";}
				if(GB3==1) {blurredCh=blurredCh+"3";}
				if(GB4==1) {blurredCh=blurredCh+"4";}
				setResult("Channels with Gaussian blur", k, blurredCh);
				setResult("Coloc "+ch1+" "+ch2, k, r);
				//*/
				/*/
				//To show images as columns and coloc values as rows (doesn't log values - old code)
				setResult("Channels", j, ch1+" "+ch2);
				setResult(tit, j, r);
				//*/
			}
			k++;
		}
	}
	updateResults;
	// following section saves results in a folder called "quantification" located in a parent directory to the analysed directory
	/*/
	dirArr = split( directory, "\\" );
	condition = dirArr[dirArr.length-1];
	String.resetBuffer
	for (n=0; n<dirArr.length-1; n++) {
		String.append(dirArr[n]);
		String.append("\\");
		dirParent = String.buffer;	
	}
	File.makeDirectory(dirParent+"quantification");
	savePath=dirParent+"quantification\\";
	saveName=condition+" "+filetype+" files.csv";
	//saveAs("Results", dirParent+"quantification\\"+timeString+" Colocalisation "+condition+" "+filetype+" files.csv");
	/*/
	savePath=directory;
	saveName=filetype+" files.csv";
	//saveAs("Results", directory+timeString+" Colocalisation "+filetype+" files.csv");
	//*/
	saveAs("Results", savePath+timeString+" Colocalisation "+saveName);
	close("Log");
	restoreSettings;
	setBatchMode(false);
	showMessageWithCancel("Finished!", "Colocalisation analysis is finished.\n \nYour results are in:\n"+savePath+"\n \nClose results?");
	selectWindow("Results");
	run("Close" );
}	

function coloc() {	
	title=getTitle();
	getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
	bits=bitDepth();
	print("\\Clear");
	if(channels>4) {
		showMessage("Too many channels", "This macro is intended for up to 4 channel images only.")
	}
	if(channels==2) { // changes 2-channel images to 4-channel by adding 2 black channels
		newImage("C3-"+title, bits+"-bit black", width, height, slices);
		newImage("C4-"+title, bits+"-bit black", width, height, slices);
		selectWindow(title);
		run("Split Channels");
		run("Merge Channels...", "c1=[C1-"+title+"] c2=[C2-"+title+"] c3=[C3-"+title+"] c4=[C4-"+title+"] create");
		rename(title);
	}
	if(channels==3) { // changes 3-channel images to 4-channel by adding 1 black channel
		newImage("C4-"+title, bits+"-bit black", width, height, slices);
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
			close(ch4); //closing the extra channel created previously
		}
	}
	else {
		run("Merge Channels...", "c1=C1 c2=C2 create");
		close(ch3); //closing the extra channels created previously
		close(ch4);
		
	}
	selectWindow("Composite");
	rename(title); //returning to the original state, since splitting channels closes original image
	close();
}

macro "Analyze Intensity Action Tool- N11 C555 V0076 Caaa V2a67 C000 O0076 Oa576 O2a67 " {
	/* Measures intensity of fluorescence in all the images of selected type in selected folder in selected channel.
	 * Measures only in area determined by threshold performed after Gaussian blur.
	 * Thus doesn't include background in the measurement.
	 * Minimum may be below threshold because of the Gaussian blur.
	 * Results saved as .csv file in a parent folder, where a directory called quantification is created.
	 */
	saveSettings();
	run("Clear Results");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timeString=""+year+"-"+substring("0"+month+1,lengthOf("0"+month+1)-2)+"-"+substring("0"+dayOfMonth,lengthOf("0"+dayOfMonth)-2)+" "+substring("0"+hour,lengthOf("0"+hour)-2)+"."+substring("0"+minute,lengthOf("0"+minute)-2);
	//run("Set Measurements...", "area mean min redirect=None decimal=3"); //make sure your measurements are set correctly
	Dialog.create("Parameters");
	Dialog.addMessage("Image file type")
	types = newArray(".tif", ".czi", ".lsm", "Other:");
	Dialog.addRadioButtonGroup("Source images filetype", types, 1, 4, ".tif")
	Dialog.addString("Other filetype", "");
	Dialog.addMessage("")
	items = newArray("1", "2", "3", "4");
	Dialog.addRadioButtonGroup("Channel to analyze", items, 1, 4, "1");
	Dialog.addMessage("")
	Dialog.addMessage("Threshold values")
	Dialog.addSlider("Minimum:", 1, 255, 10);
	Dialog.addSlider("Maximum:", 1, 255, 255);
	Dialog.addMessage("")
	Dialog.addMessage("Gaussian blur diameter")
	Dialog.addSlider(" ", 0.0, 3.5, 1.0);
	Dialog.show();
	filetype=Dialog.getRadioButton();
	if(filetype=="Other:") {
		filetypeOther = Dialog.getString();
		filetype=filetypeOther;
		if(filetype=="") {
			restoreSettings;
			exit("When you select Other filetype, you have to specify which.");
		}
	}
	else {
		discard = Dialog.getString();
	}
	channel = Dialog.getRadioButton();
	min=Dialog.getNumber();
	max=Dialog.getNumber();
	blurDiameter=Dialog.getNumber();
	setBatchMode(true);
	directory=getDirectory("Choose a folder with images");
	list = getFileList(directory);
	j=0; //counter of actually open images for stting results
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i],filetype)) { // to ignore other than desired image type files
			open(directory + list[i]);
			tit=getTitle();
			resetMinAndMax();
			getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
			if (slices>1) {
				run("Z Project...", "projection=[Max Intensity]");
				selectWindow(tit);
				close();
			}
			if (channels<channel) {
				Dialog.create("Not enough channels");
				Dialog.addMessage(tit+" doesn't have "+channel+" channels.")
				Dialog.addMessage("It only has "+channels+" channels.")
				Dialog.addMessage("It will be skipped.")
				Dialog.show();
				close();
			}
			else {
				analyzeIntensity();
				setResult("Image", j, tit);
				setResult("Channel", j, channel);
				setResult("Threshold min", j, min);
				setResult("Threshold max", j, max);
				setResult("Gaussian blur diameter", j, blurDiameter);
				updateResults;
				j++;
			}
		}
	}
	// following section saves results in a folder called "quantification" located in a parent directory to the analysed directory
	/*/
	dirArr = split( directory, "\\" );
	condition = dirArr[dirArr.length-1];
	String.resetBuffer
	for (n=0; n<dirArr.length-1; n++) {
		String.append(dirArr[n]);
		String.append("\\");
		dirParent = String.buffer;	
	}
	File.makeDirectory(dirParent+"quantification");
	savePath=dirParent+"quantification\\";
	saveName=channel+" "+condition+" "+filetype+" files.csv";
	/*/
	savePath=directory;
	saveName=channel+" "+filetype+" files.csv";
	//*/
	
	saveAs("Results", savePath+timeString+" Intensity C"+saveName);
	restoreSettings;
	setBatchMode(false);
	showMessageWithCancel("Finished!", "Intensity analysis is finished.\n \nYour results are in:\n"+savePath+"\n \nClose results?");
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

macro "Intensity in Compartments Action Tool - C0f0 V00he C777 O00gd C06f V3376" {
	/*  Macro for measuring intensity of fluorescence in different part of the cell
	 *  (model case is nucleus and cytolasm) 1 channel can be used to define whole cell, another to define compartment
	 *  Another channel can be used for the measurement
	 *  Made to work on RGB images, but measureCompartments function should work for 2-4 channel images
	 *  If manual check of selected areas are required, activate waitForUser (line 99) and inactivate batch mode (line 9)
	 */
	setBatchMode(true);
	saveSettings();
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timeString=""+year+"-"+substring("0"+month+1,lengthOf("0"+month+1)-2)+"-"+substring("0"+dayOfMonth,lengthOf("0"+dayOfMonth)-2)+" "+substring("0"+hour,lengthOf("0"+hour)-2)+"."+substring("0"+minute,lengthOf("0"+minute)-2);
	//run("Set Measurements...", "area mean standard min integrated median redirect=None decimal=3");
	Dialog.create ("Parameters");
	items = newArray("1", "2", "3", "4");
	items2 = newArray(".tif", ".czi", ".lsm", "Other:");
	Dialog.addRadioButtonGroup("Source images filetype", items2, 1, 4, ".tif")
	Dialog.addString("Other filetype", "");
	Dialog.addMessage ("");
	Dialog.addRadioButtonGroup("Channel defining cell outline", items, 1, 4, "1");
	Dialog.addSlider ("Background:", 0, 255, 10);
	Dialog.addSlider("Gaussian blur diameter", 0, 4.5, 2);
	Dialog.addMessage ("");
	Dialog.addRadioButtonGroup("Channel defining nucleus outline", items, 1, 4, "2");
	Dialog.addSlider ("Background:", 0, 255, 10);
	Dialog.addSlider("Gaussian blur diameter", 0, 4.5, 2);
	Dialog.addMessage ("");
	Dialog.addRadioButtonGroup("Channel to measure", items, 1, 4, "3");
	Dialog.addMessage("");
	Dialog.addMessage("Next, select folder with raw images");
	Dialog.show;
	filetype=Dialog.getRadioButton();
	if(filetype=="Other:") {
		filetypeOther = Dialog.getString();
		filetype=filetypeOther;
		if(filetype=="") {
			restoreSettings;
			exit("When you select Other filetype, you have to specify which.");
		}
	}
	else {
		discard = Dialog.getString();
	}
	chCell = Dialog.getRadioButton();
	bcgCell = Dialog.getNumber();
	GBCell = Dialog.getNumber();
	chNuc = Dialog.getRadioButton();
	bcgNuc = Dialog.getNumber();
	GBNuc = Dialog.getNumber();
	chMes = Dialog.getRadioButton();

	sourceDir=getDirectory("Choose a folder with images");

	list = getFileList(sourceDir);
	k=0; //counter of actually open images for stting results
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
			if (channels<chCell) {
				Dialog.create("Not enough channels");
				Dialog.addMessage("You chose channel "+chCell+" as channel defining cell.");
				Dialog.addMessage(title+" doesn't have "+chCell+" channels.")
				Dialog.addMessage("It only has "+channels+" channels.")
				Dialog.show();
				restoreSettings;
				exit()
			}
			if (channels<chNuc) {
				Dialog.create("Not enough channels");
				Dialog.addMessage("You chose channel "+chNuc+" as channel defining nucleus.");
				Dialog.addMessage(title+" doesn't have "+chNuc+" channels.")
				Dialog.addMessage("It only has "+channels+" channels.")
				Dialog.show();
				restoreSettings;
				exit()
			}
			if (channels<chMes) {
				Dialog.create("Not enough channels");
				Dialog.addMessage("You chose channel "+chMes+" as channel to measure.");
				Dialog.addMessage(title+" doesn't have "+chMes+" channels.")
				Dialog.addMessage("It only has "+channels+" channels.")
				Dialog.show();
				restoreSettings;
				exit()
			}
			measureCompartments();
			setResult("Image", 2*k, title);
			setResult("Image", 2*k+1, title);
			setResult("Compartment", 2*k, "cytoplasm");
			setResult("Compartment", 2*k+1, "nucleus");
			setResult("Channel defining cell", 2*k, chCell);
			setResult("Channel defining cell", 2*k+1, chCell);
			setResult("Cell background", 2*k, bcgCell);
			setResult("Cell background", 2*k+1, bcgCell);
			setResult("Cell gaussian blur diameter", 2*k, GBCell);
			setResult("Cell gaussian blur diameter", 2*k+1, GBCell);
			setResult("Channel defining nucleus", 2*k, chNuc);
			setResult("Channel defining nucleus", 2*k+1, chNuc);
			setResult("Nucleus background", 2*k, bcgNuc);
			setResult("Nucleus background", 2*k+1, bcgNuc);
			setResult("Nucleus gaussian blur diameter", 2*k, GBNuc);
			setResult("Nucleus gaussian blur diameter", 2*k+1, GBNuc);
			setResult("Measured channel", 2*k, chMes);
			setResult("Measured channel", 2*k+1, chMes);
			updateResults();
			k++;
		}
	}
	
	selectWindow("Results");
	// following section saves results in a folder called "quantification" located in a parent directory to the analysed directory
	/*/
	dirArr = split( sourceDir, "\\" );
	condition = dirArr[dirArr.length-1];
	String.resetBuffer
	for (n=0; n<dirArr.length-1; n++) {
		String.append(dirArr[n]);
		String.append("\\");
		dirParent = String.buffer;	
	}
	File.makeDirectory(dirParent+"quantification");
	saveDir=dirParent+"quantification\\";
	saveName=chMes+" "+condition+" "+filetype+" files.csv";
	/*/
	saveDir=sourceDir;
	saveName=chMes+" "+filetype+" files.csv";
	//*/
	saveAs("Results", saveDir+timeString+" Intensity in compartments C"+saveName);
	restoreSettings;
	setBatchMode("exit and display");
	showMessageWithCancel("Finished!", "Intensity in compartments analysis is finished.\n \nYour results are in:\n"+saveDir+"\n \nClose results?");
	selectWindow("Results");
	run("Close" );
}

function measureCompartments() {
	selectWindow(title);
	rename("Image");
	run("Split Channels");
	// selecting cell outline:
	selectWindow("C"+chCell+"-Image");
	run("Duplicate...", "duplicate");
	run("Gaussian Blur...", "sigma="+GBCell);
	setThreshold(bcgCell, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark calculate black");
	run("Create Selection");
	roiManager("Add");
	close();
	// selecting nucleus outline:
	selectWindow("C"+chNuc+"-Image");
	run("Duplicate...", "duplicate");
	run("Gaussian Blur...", "sigma="+GBNuc);
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

macro "Analyze Particles Action Tool- C555 O00gd Cd00 Va733 V4822 V4333 Va322" {
	/*
	 * causes bug if the first image doesn't have enough particles for some reason
	 */
	saveSettings();
	run("Clear Results");
	setBatchMode(true);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timeString=""+year+"-"+substring("0"+month+1,lengthOf("0"+month+1)-2)+"-"+substring("0"+dayOfMonth,lengthOf("0"+dayOfMonth)-2)+" "+substring("0"+hour,lengthOf("0"+hour)-2)+"."+substring("0"+minute,lengthOf("0"+minute)-2);
	Dialog.create("Parameters");
	types = newArray(".tif", ".czi", ".lsm", "Other:");
	Dialog.addRadioButtonGroup("Source images filetype", types, 1, 4, ".tif")
	Dialog.addString("Other filetype", "");
	Dialog.addMessage ("");
	items = newArray("1", "2", "3", "4");
	Dialog.addRadioButtonGroup("Channel to analyze", items, 1, 4, "1");
	Dialog.addMessage("")
	Dialog.addMessage("Threshold values")
	Dialog.addSlider("Minimum:", 1, 255, 40);
	Dialog.addSlider("Maximum:", 1, 255, 255);
	Dialog.addCheckbox("Watershed", false);
	Dialog.addMessage("")
	Dialog.addSlider("Gaussian blur diameter:", 0.0, 2.0, 1.2);
	Dialog.addMessage("");
	Dialog.addMessage("Minimal size to measure (um2)")
	Dialog.addSlider("Minimum:", 0.0, 5.0, 0.2);
	Dialog.addMessage("");
	Dialog.show;
	filetype=Dialog.getRadioButton();
	if(filetype=="Other:") {
		filetypeOther = Dialog.getString();
		filetype=filetypeOther;
		if(filetype=="") {
			restoreSettings;
			exit("When you select Other filetype, you have to specify which.");
		}
	}
	else {
		discard = Dialog.getString();
	}
	channel = Dialog.getRadioButton();
	min=Dialog.getNumber();
	max=Dialog.getNumber();
	watershed=Dialog.getCheckbox();
	GBDiam=Dialog.getNumber();
	minSize=Dialog.getNumber();
	directory=getDirectory("Choose a folder with images");
	list = getFileList(directory);
	namesString="";
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], filetype)) { //to only open pictures of specified type
			open(directory + list[i]);
			tit=getTitle();
			getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
			if (slices>1) { // Maximum intensity projection for stacks
				run("Z Project...", "projection=[Max Intensity]");
				selectWindow(tit);
				close();
			}
			if (channels<channel) {
				Dialog.create("Not enough channels");
				Dialog.addMessage(tit+" doesn't have "+channel+" channels.")
				Dialog.addMessage("It only has "+channels+" channels.")
				Dialog.addMessage("It will be skipped.")
				Dialog.show();
				close();
			}
			else {
				n=nResults;
				AnalPart ();
				n2=nResults;
				for(k=0; k<n2-n; k++) { // logging set values in full results
					setResult("Image", n+k, tit);
					setResult("Particles in cell", n+k, n2-n);
					setResult("Channel", n+k, channel);
					setResult("Minimum size", n+k, minSize);
					setResult("Threshold min", n+k, min);
					setResult("Threshold max", n+k, max);
					if (watershed) {
						setResult("Watershedded", n+k, "yes");
					}
					else {
						setResult("Watershedded", n+k, "no");
					}
					setResult("Gaussian blur diameter", n+k, GBDiam);
				}
				setResult("Image", n, tit); // Prints names of images without particles. Too many of these cause errors, just skip this line until I fix it.
				updateResults;
				//close();
				namesString=namesString+tit+","; //making a list of original image names
			}
		}
	}
	
	// following section saves results in a folder called "quantification" located in a parent directory to the analysed directory
	/*/
	dirArr = split( directory, "\\" );
	condition = dirArr[dirArr.length-1];
	String.resetBuffer
	for (n=0; n<dirArr.length-1; n++) {
		String.append(dirArr[n]);
		String.append("\\");
		dirParent = String.buffer;	
	}
	File.makeDirectory(dirParent+"quantification");
	savePath=dirParent+"quantification\\";
	saveName=channel+" "+condition+" "+filetype+" files.csv";
	/*/
	savePath=directory;
	saveName=channel+" "+filetype+" files.csv";
	//*/

	saveAs("Results", savePath+timeString+" Particles C"+saveName);
	
	selectWindow("Summary");
	IJ.renameResults("Results");
	//imgNo=nResults;
	namesArray=split(namesString, ","); // adding original image names in the summary
	Table.setColumn("Image", namesArray);
	temp=newArray(channel);
	temp2=newArray(channel);
	for (m = 0; m < nResults-1; m++) {
		temp2=Array.concat(temp2,temp);
	}
	for (j = 0; j < nResults-1; j++) { // logging set values in summary
		setResult("Channel", j, channel);
		setResult("Minimum size", j, minSize);
		setResult("Threshold min", j, min);
		setResult("Threshold max", j, max);
		if (watershed) {
			setResult("Watershedded", j, "yes");
		}
		else {
			setResult("Watershedded", j, "no");
		}
		setResult("Gaussian blur diameter", j, GBDiam);
	}
	Table.deleteRows(nResults-1, nResults) // for some reason, extra empty line is added automatically

	saveAs("Results", savePath+timeString+" Summary of particles C"+saveName);
	
	restoreSettings;
	setBatchMode(false);
	showMessageWithCancel("Finished!", "Particles analysis is finished.\n \nYour results and summary are in: \n"+savePath+"\n \nClose summary?");
	selectWindow("Results");
	run("Close" ); 

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
	run("Analyze Particles...", "size="+minSize+"-Infinity exclude add summarize");
	close(); // closing visualisation of ROIs
	selectWindow(title2);
	roiManager("deselect");
	roiManager("measure");
	selectWindow(title2);
	close();
}

macro "Analyze Particles by Slice Action Tool- N51 C555 G51m1ib1b00 Pm4ie1e2c Pm7ih1h2f Cd00 Ve722 V8822 V9433 Vd422 C222 O42e8" {
	/* This macro runs Analyse particles on all the images in the chosen folder in batch.
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
	saveSettings();
	run("Clear Results");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timeString=""+year+"-"+substring("0"+month+1,lengthOf("0"+month+1)-2)+"-"+substring("0"+dayOfMonth,lengthOf("0"+dayOfMonth)-2)+" "+substring("0"+hour,lengthOf("0"+hour)-2)+"."+substring("0"+minute,lengthOf("0"+minute)-2);
	Dialog.create("Parameters");
	types = newArray(".tif", ".czi", ".lsm", "Other:");
	Dialog.addRadioButtonGroup("Source images filetype", types, 1, 4, ".tif")
	Dialog.addString("Other filetype", "");
	Dialog.addMessage("");
	items = newArray("1", "2", "3", "4");
	Dialog.addRadioButtonGroup("Channel to analyze", items, 1, 4, "1");
	Dialog.addMessage("");
	Dialog.addCheckbox("Watershed", false);
	Dialog.addMessage("");
	Dialog.addMessage("Gaussian blur diameter");
	Dialog.addSlider(" ", 0.0, 2.0, 1.2);
	Dialog.addMessage("");
	Dialog.addMessage("Minimal size to measure (um2)")
	Dialog.addSlider(" ", 0.0, 5.0, 0.2);
	Dialog.addMessage("");
	
	Dialog.addMessage("Threshold value");
	Dialog.addCheckbox("Automatic", true);
	Dialog.addSlider("Min", 0, 255, 30);
	Dialog.addSlider("Max", 0, 255, 255);
	Dialog.addMessage("");
	
	options = newArray("Nothing", "Outlines", "[Bare Outlines]", "Ellipses", "[Count Masks]");
	Dialog.addChoice("Display:", options);
	Dialog.addCheckbox("Show threshold", false);
	Dialog.addCheckbox("Show analysed image", false);
	Dialog.addMessage("");
	Dialog.addSlider("Slice for threshold:", 1, 10, 1);
	Dialog.addCheckbox("Select slice for each image", false);
	Dialog.addMessage("");
	Dialog.addCheckbox("Close results after finishing", true);
	Dialog.show;
	filetype=Dialog.getRadioButton();
	if(filetype=="Other:") {
		filetypeOther = Dialog.getString();
		filetype=filetypeOther;
		if(filetype=="") {
			restoreSettings;
			exit("When you select Other filetype, you have to specify which.");
		}
	}
	else {
		discard = Dialog.getString();
	}
	channel = Dialog.getRadioButton();
	watershed=Dialog.getCheckbox();
	GBDiam=Dialog.getNumber();	
	minSize=Dialog.getNumber();
	autoThreshold=Dialog.getCheckbox();
	thresholdMin=Dialog.getNumber();
	thresholdMax=Dialog.getNumber();
	display=Dialog.getChoice();	
	if(display=="Nothing") {
		displaySomething=false;
	}
	else {
		displaySomething=true;
	}
	showThreshold=Dialog.getCheckbox();
	showImage=Dialog.getCheckbox();
	thresholdSlice=Dialog.getNumber();
	chooseSlice=Dialog.getCheckbox();
	closeResults=Dialog.getCheckbox();
	directory=getDirectory("Choose a folder with images");
	list = getFileList(directory);

	/*/
	dirArr = split( directory, "\\" );
	condition = dirArr[dirArr.length-1];
	String.resetBuffer
	for (n=0; n<dirArr.length-1; n++) {
		String.append(dirArr[n]);
		String.append("\\");
		dirParent = String.buffer;	
	}
	File.makeDirectory(dirParent+"quantification");
	savePath=dirParent+"quantification\\";
	saveName=channel+" "+condition+" "+filetype+" files.txt";
	/*/
	savePath=directory;
	saveName=channel+" "+filetype+" files.txt";
	//*/
	print("\\Clear");
	print("Images processed:");
	for (i=0; i<list.length; i++) {
		setBatchMode(true);
		if (endsWith(list[i], filetype)) { //to only open pictures of specified type
			open(directory + list[i]);
			tit=getTitle();
			getDimensions(width, height, channels, slices, frames); // To get nubmer of channels to analyze
			if (channels<channel) {
				Dialog.create("Not enough channels");
				Dialog.addMessage(tit+" doesn't have "+channel+" channels.");
				Dialog.addMessage("It only has "+channels+" channels.");
				Dialog.addMessage("It will be skipped.");
				Dialog.show();
				close();
			}
			else {

				//n=nResults; //I think this wasn't used anywhere
				print(tit);
				AnalPartSlice();
			
				windows = getList("window.titles");
				//Array.show(windows);
				a=windows.length;
				selectWindow(windows[a-1]);
				saveAs("Results", savePath+timeString+" Particles in C"+channel+"-"+tit+".csv");
 	        	if(closeResults) {
 	        		run("Close" );
	 	        }
				setBatchMode("exit and display");
				//waitForUser("Proceed to the next image? \n(Press Escape to abort)"); //unnecessary
				if(nImages>0) {
					if(getBoolean("Would you like to close analyses of the last image?")) {
						for (j = 0; j < showImage+showThreshold+displaySomething; j++) {
							close();
							//ideally, somewhere here would be a way to reset measurements in case user presses Cancel
							//****************************************************************************************
						}
					}
				}
			}
		}
	}
	print(" ");
	print("Filetype processed: "+filetype);
	print("Analysed channel: "+channel);
	if(watershed) {
		print("Watershedded: yes");
	}
	else {
		print("Watershedded: no");
	}
	print("Gaussian blur diameter: "+GBDiam);	
	print("Minimal particle size (um2): "+minSize);
	if(autoThreshold) {
		print("Threshold:");
		print("   automatic");
	}
	else {
		print("Threshold minimum: "+thresholdMin);
		print("Threshold maximum: "+thresholdMax);
	}
	selectWindow("Log");
	saveAs("Text", savePath+timeString+" Log of Analyze particles by slice C"+saveName); //saves log
	run("Close"); //closes log
	restoreSettings;
	showMessage("Finished!", "Particles analysis by slice is finished.\n \nYour results are in: \n"+savePath);
}

function AnalPartSlice() {
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
		setBatchMode("show");
		waitForUser("Choose slice for threshold", "Inspect the images and select, which slice to use for threshold.\nOpen your slice of choice and then click OK.");
		thresholdSlice=getSliceNumber();
	}
	print("   Slice used for thresholding: "+thresholdSlice);
	
	selectWindow(title2);
	imageID=getImageID();
	run("Duplicate...", "duplicate");
	run("Gaussian Blur...", "sigma="+GBDiam+" stack");

	if(slices>=thresholdSlice) {
		setSlice(thresholdSlice);
	}
	else {
		showMessage("Not enough slices", "You selected slice "+thresholdSlice+" as the slice for threshold, but there aren't this many. \nFirst slice will be used instead.");
		print("\\Update:   Slice used for thresholding: 1");
		setSlice(1);
	}
	if(autoThreshold) {
		setAutoThreshold("Default dark"); // set threshold automatically
	}
	else {
		setThreshold(thresholdMin, thresholdMax); // set threshold manually
	}
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Default"); // creating thresholded binary image
	if(watershed==1) {
		run("Watershed", "stack");
	}
	thresholdID=getImageID();
	run("Set Measurements...", "area mean standard min perimeter fit shape redirect=None decimal=3");
	if(display=="Nothing") {
		run("Analyze Particles...", "size="+minSize+"-Infinity exclude summarize stack");
	}
	else {
		run("Analyze Particles...", "size="+minSize+"-Infinity show="+display+" exclude summarize stack");
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

