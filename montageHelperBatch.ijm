macro "montageHelperBatch" {
	/* Inspired by Magic Montage toolset
	 * for creating montage of a 4 channel picture, 4 channels on the left, 2 coposite channels on the right
	 * This macro changes levels of all channels and creates a montage with a scale bar and saves them
	 * works only on 4-channel images!
	 * You can add white spaces between channels
	 */
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
	Dialog.create("Levels settings");
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
	sourceDir=getDirectory("Choose a folder containing only source images");
	Dialog.create("Choose channels for composite panels");
	items = newArray("A", "B", "D", "E");
	items2 = newArray(".czi", ".lsm", ".tif");
	Dialog.addRadioButtonGroup("Source images filetype", items2, 1, 4, ".czi")
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
	saveDir=getDirectory("Choose a folder to save your montages");
	setBatchMode(true);
	setBackgroundColor(0,0,0); // background has to be set to black, otherwise montages are white, because white borders between panles rely on making white rectangles and then clearing selected spaces to the background colour
	logValues(); //prints log of values used for edits
	list = getFileList(sourceDir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], filetype)) { //to only open pictures of specified type
			open(sourceDir + list[i]);
			tit=getTitle();
			AllEditsInOne();
			montage();
			print(tit); // adds name of a processed image to the log
			saveAs("Tiff", saveDir+"/Montage of MAX_"+tit);
			close();
    		close();
    	}
    }
    selectWindow("Log");
	saveAs("Text", saveDir+"/Log "+timeString+".txt"); //saves log
	run("Close"); //closes log
	setBatchMode(false);
	showMessage("Done!", "Montage making is finished.\n \nMontages are in:\n"+saveDir);
}

function AllEditsInOne() {
	run("Arrange Channels...", "new=1234"); // to avoid bug where channles aren't recognised (though could be counted)
	Stack.setChannel(1)
	run(LUT1);
	Stack.setChannel(2)
	run(LUT2);
	Stack.setChannel(3)
	run(LUT3);
	Stack.setChannel(4)
	run(LUT4);	
	getDimensions(width, height, channels, slices, frames);
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
	selectWindow(ch2);
	setMinAndMax(min2, max2);
	ApplyLUT();
	rename("to_be_merged-C2");
	selectWindow(ch3);
	setMinAndMax(min3, max3);
	ApplyLUT();
	rename("to_be_merged-C3");
	selectWindow(ch4);
	setMinAndMax(min4, max4);
	ApplyLUT();
	rename("to_be_merged-C4");
	run("Merge Channels...", "c1=to_be_merged-C1 c2=to_be_merged-C2 c3=to_be_merged-C3 c4=to_be_merged-C4 create");
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

function montage() {
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
