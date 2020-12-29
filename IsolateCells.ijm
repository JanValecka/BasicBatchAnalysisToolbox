macro "IsolateCells" {
	/* Jan Valecka, CIML, 2020-02-04
	 * 
	 * First, select all your cells as ROIs in ROI manager
	 * (best done on duplicate with Z-project)
	 * shortcut to do that is Ctrl+t. Actually, you can just press T
	 */
	title=getTitle();
	run("Colors...", "foreground=black background=black selection=yellow");
	directory=getDirectory("Choose a Directory");
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
