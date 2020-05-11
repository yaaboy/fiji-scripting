//select a folder/directory of images you want to process 
input_path = getDirectory("Choose image folder"); 
fileList = getFileList(input_path); 

//select a threshold value for channel 1,2,4
selectthreshold1 = getNumber("Set threshold1 value", 50);
selectthreshold2 = getNumber("Set threshold2 value", 50);
selectthreshold4 = getNumber("Set threshold3 value", 50);

for (f=0; f<fileList.length; f++){ //loops over all images in the given directory


	//clean-up to prepare for analysis
	roiManager("reset");	
	run("Close All");
	run("Clear Results");

	//open file
	open(input_path + fileList[f]);
	print(input_path + fileList[f]); //displays file that is processed
	
	//runs z projection
	run("Z Project...", "projection=[Max Intensity]");
   
  	//splits channels and deals with channel titles 
  	title = getTitle();
    run("Split Channels");
    selectWindow("C1-"+title);
    rename("C1-"+title);
    selectWindow("C2-"+title);
    rename("C2-"+title);
	selectWindow("C3-"+title);
	rename("C3-"+title);
	selectWindow("C4-"+title);
	rename("C4-"+title);

    //preprocessing of the grayscale channel 3
    selectWindow("C3-"+title);
    //need an if/else analyse here. run some sort of analysis if below certain level the set auto threshold to be something, else set it to something else. include set background to dark true 
    
    //runs a median filter that preserves the edges of the DRG cell 
    run("Median...", "radius=25");
    //thresholds channel 3 using the Mean setting 
setAutoThreshold("Triangle dark");
setOption("BlackBackground", true);

    //binarizes channel 3 
    run("Convert to Mask");
    run("Watershed");

    //Step3: Retrieve the DRG's boundaries
    num2 = 10;
    
	//finds the ROI of from the binarized channel 3 
    selectWindow("C3-"+title);
    run("Analyze Particles...", "size=150-Infinity" + num2 + "-Infinity add"); //add to ROI-Manager by running analyze particles

    
    //Step4: Retrieve the DRG's boundaries and save them in the ROI-Manager. Can handle images with multiple DRG cells!
    numDRG = roiManager("count");
	
	for(i=0; i<numDRG; i++){
        roiManager("Select", i);
  		roiManager("Update"); //original drg cell-ROI is replaced by nuclear envelope ROI
  		

    }

	
    //count particles for Channel 1
    selectWindow("C1-"+title);
	setThreshold(selectthreshold1, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
  	for(n=0; n<roiManager("Count"); n++) {
	roiManager("Select", n);
	
run("Analyze Particles...", "size=0.05-Infinity clear summarize"); //define the measurements
 } 	
  	//count particles for Channel 2
  	selectWindow("C2-"+title);
	setThreshold(selectthreshold2, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
  	for(n=0; n<roiManager("Count"); n++) {
	roiManager("Select", n);
	
	run("Analyze Particles...", "size=0.05-Infinity clear summarize"); //define the measurements
}
	//count particles for Channel 4	
  	selectWindow("C4-"+title);
	setThreshold(selectthreshold4, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
  	for(n=0; n<roiManager("Count"); n++) {
	roiManager("Select", n);
	
	run("Analyze Particles...", "size=0.05-Infinity clear summarize"); //define the measurements
  	
  }

}


  	
