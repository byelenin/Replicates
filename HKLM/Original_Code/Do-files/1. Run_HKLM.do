log using "Log_HKLM.log", replace
/*******************************************************************************

Master do-file "1. Run_HKLM.do"

Replication code for 
Joan Hamory, Marieke Kleemans, Nicholas Y. Li, and Edward Miguel
Reevaluating Agricultural Productivity Gaps with Longitudinal Microdata
Created Aug 2020 using Stata version 14.2

Please save all data and do-files provided in the replication package in 
a single folder and run this do-file to obtain the figures and tables in 
the paper and accompanying appendix

Please contact Marieke Kleemans at kleemans@illinois.edu for questions

*******************************************************************************/

clear mata 																		
clear all																		
program drop _all			
set more off
set mem 250m
set matsize 800
													


*** Install packages if needed (these are not default in Stata version 14.2)
ssc install labutil
ssc install estout
ssc install matmap
ssc install reghdfe
ssc install ftools


*** Create Indonesian replication data from the Indonesian Family Life Survey
do "2. Creation of IFLS replication data.do"

*** Indonesian Analysis using the IFLS
set seed 123	
do "3. Replication analysis IFLS.do"


*** Create Kenyan replication data from the Kenya Life Panel Survey
do "4. Creation of KLPS replication data.do"

*** Kenyan Analysis using the KLPS
set seed 123
do "5. Replication analysis KLPS.do"


log close
exit
