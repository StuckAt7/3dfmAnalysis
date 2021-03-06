Description

   Multi-File Report generates a comprehensive report on the data contained in an arbitrary number of 3DFM data files. The report includes an HTML file showing plots, fits, and model parameter data for each of the sequences/beads/files, as well as an Excel spreadsheet that summarizes the model parameter data and provides a numerical analysis. The program includes the option to remove data from the analysis on the individual sequence, bead, and file level.

Requirements

   MFR requires at least one pair of *.vrpn.mat and *.vfd.mat files (or some variation thereof). These files must reside in the same directory, and must have the same root file name (eg, 'vid1.vrpn.evt.mat' and 'vid1.vfd.mat'). Each directory of files must contain a 'poleloc.txt' file detailing the x,y coordinates of the pole tip. In order to run the program in calibrated mode, each directory of files must also contain a single *.vfc.mat calibration file. Files that use different poleloc or calibration files must be stored in separate directories.

Execution

   At the MATLAB command line, enter the following:

dmbr_multi_file_report(<analysis_name>)

with analysis_name replaced by the name you wish to give your analysis. A filepicker GUI will appear. By default, the filepicker will display only *.vfd.mat files and directories. To change this, add a second parameter to your function call, in the form of a new filtering string ( will show all files, *.txt will show all text files). Navigate to a directory that contains files you wish to analyze, select the files, and click 'Add ->'. If you wish to analyze an entire directory of files, simply select and add the directory. Repeat this process until you have selected all of the files that you wish to analyze. Click 'Done'.

   After a few moments, a figure entitled 'Plot Selector' will appear. This dialog allows you to select a variety of options for your plot:

	1) Plot Displacement: plot each bead's radial displacement.
	2) Plot Compliance: plot each bead's calculated compliance.
	3) Plot Compliance Fit: plot each bead's modeled compliance.
	4) Check for Breakpoints: check each file for a sequence breakpoint before 	beginning analysis. Adds a nontrivial amount of time to analysis. Deselect this 	option if you have already set breakpoints for the selected files.
	5) 'Jeffrey' dropdown: the mechanical model to be used in the analysis. 	Defaults to the Jeffrey model. Also includes Fabry's modified power law model.
	6) Generate Excel Spreadsheet: generate the Excel spreadsheet portion of the 	analysis.
	7) Set FPS: set the frames per second stored in the *.vfd.mat files to the 	given value. Only adds FPS data; does not overwrite original data.

   Select your desired options and click 'Compute'. If you selected option 4, MFR will iterate through the file list and check for sequence breakpoints. If the program encounters any files that lack breakpoints, you will be prompted to choose one. Once breakpoints have been found for all the files, the program will begin the analysis. Depending on the amount of data you are analyzing, this could take several minutes. If you did not select option 4, the program will prompt you for missing breakpoints as it encounters them.

   Once the report is finished, the HTML file will open in your default browser. The Excel file can be found in the main output directory (see Output). In addition, the program will open a GUI entitled 'Sequence Selector.' This GUI allows you to deselect individual sequences from the analysis. Scroll through the HTML report, taking note of any data that you would like to remove from the analysis, and deselecting the corresponding checkboxes in the Sequence Selector GUI. Deselecting a checkbox will remove that sequence as well as all the following sequences (eg, deselecting '3' will also cause 4-7 to be ignored). When you have finished making your selections, enter a new analysis name into the GUI (reusing the original name will cause the program to overwrite the original analysis). Click 'Compute'.  After completing the new analysis, the program will again display the Plot Selector GUI as the report process repeats itself. Each ensuing report will remove the sequences, beads, and files that you deselect in the previous iterations.

Uncalibrated Mode

   MFR can be run without a calibration file, but will show only the radial displacement plots of each bead. To run MRF in uncalibrated mode, simply disable options 2, 3, and 6 in the Plot Selector GUI.

Adjust Mode

   The MFR process can be started from the Sequence Selector GUI as well. This requires an <analysis_name>.seqdat.txt file, which is generated by completing a report to the Sequence Selector stage. To run the program in adjust mode, set the MATLAB current directory to the main output directory of the report that you wish to analyze, and enter the following into the command line:

dmbr_adjust_report(<previous_analysis_name>)

   The Sequence Selector GUI will appear, along with the HTML report. The program sequence will now continue normally.

Output

   Once you have selected all of your data files in the filepicker GUI, MFR sorts their parent directories alphabetically and chooses the first of that list as the main output directory. The following output files will appear in this main output directory:
	* <analysis_name>.html: The HTML portion of the report. Includes all plots: displacement, compliance, and compliance fit. Also includes a chart detailing the model parameters for each bead sequence.
	* <analysis_name>.xlsx: The Excel portion of the plot. Displays all model parameters and provides analytical data such as mean, standard deviation, parameter ratios, etc.
	* <analysis_name>_html_images\: A directory that contains all of the generated plot images that are used in the HTML report.
	* <analysis_name>.seqdat.txt: A system file that contains information detailing the deselection of individual sequences. Necessary to generate adjusted reports.

Portability

   The Excel file can be treated as a standalone file and moved accordingly. The HTML file, however, relies on the plots contained in the *_html_images folder. To copy the HTML report to another computer, it is necessary to also copy this folder and its contents and keep the two items in the same directory.

Support Files

	poleloc.txt: required. Details the pole tip location in x, y.
%%%%%%% file start %%%%%%%
143, 281
%%%%%%% file end %%%%%%%

	*.vfc.mat: required for calibrated mode. 3DFM calibration file.

	expdata.txt: optional. Adds a header to the Excel file detailing relevant experimental parameters. MFR will concatenate the data from all expdata.txt files in the parent directories of the data files you select.
Include all eight rows, leaving the second column empty if desired. These eight parameter types are hard-coded into dmbr_multi_file_analysis.m.
%%%%%%% file start %%%%%%%
Date of experiment: 07/04/1776
Description: sucrose control data
Substrate: glass
Sub coating: 
Bead Diameter: 4 microns
Bead Coat: 
Microscope: 
Magnification: 5000
%%%%%%% file end %%%%%%%














