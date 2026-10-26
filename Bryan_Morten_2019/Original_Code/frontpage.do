*! This page lets you replicate all the analysis in Bryan and Morten
*! MM, 4/27/2018

// 1. Set file paths
global dropbox "/Users/memorten/Dropbox/Research/Collaborative_Projects/Indonesia_Migration_July2015/Replication_Files_Bryan_Morten" //change to local computer//
global outpath $dropbox/Outpath
global secdata $dropbox/Data

adopath + $dropbox/Do_files


// 2. Construct datasets
* To access the microdata, purchase from BPS as described in the readme doc. The following files will convert the raw microdata to intermediary datasets.
setupRawData

* Run the IV and bootstrap for the estimation of theta
run_theta_IV, nrep(100)

// 3. Reproduce figures
Figure1_Table1
* Figure 2: Not needed
Figure3
Figure4
Figure5
Figure6
Figure7
Figure8_9
Figure8_9, multreduction(0.3)

// 4. Reproduce tables
* Note: Table1 is made by file Figure1_Table1
Table2_3
Table4
Table5











