macro "flattenOverlay" {
	// Flattens overlay into RGB image, replacing the original image by the new one
	// Designed for including scalebars to montages from Magic Montage
	title=getTitle();
	run("Flatten");
	wait(300); // time to flatten
	selectWindow(title);
	close();
	rename(title);
}