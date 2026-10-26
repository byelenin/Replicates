/*******************************************************************************

Do-file "6. Cr23_ik_css_mod.do"

Replication code for 
Joan Hamory, Marieke Kleemans, Nicholas Y. Li, and Edward Miguel
Reevaluating Agricultural Productivity Gaps with Longitudinal Microdata
Created Aug 2020 using Stata version 14.2

This is an auxiliary do-file used to create Appendix Table 16 “Alternative 
Coefficient Standard Error Estimation.”  It is a lightly modified version 
of cr23_ik_css.do found in the replication package for the paper "A 
Practitioner's Guide to Cluster-Robust Inference", by A. Colin Cameron and 
Douglas L. Miller, published in the Journal of Human Resources, 2015.  The 
original version of this do file can be downloaded here:
http://faculty.econ.ucdavis.edu/faculty/cameron/research/papers.html 

*******************************************************************************/


#delimit ;

/* this file implements the CR2 & CR3 residual corrections, as well as the 
Imbens-Kolesar and Carter-Schnepel-Steigerwald calculations.
 it is implemented as program, which needs to be loaded by running the .do file */

cap prog drop CR23_IK_CSS ;
prog def CR23_IK_CSS , rclass ;
syntax  , [lhs(varlist) rhs(varlist) betavec(namelist) key_rhs(varlist) 
	noconstant(integer 0) main_data(string) cluster(string)] ;

foreach r in se_CR2 se_CR3 { ; // dof_CR2_IK dof_CSS { ;
	local `r' = . ; 
} ;


mata: cr2cr3("`betavec'","`cluster'","resid","`key_rhs'",`noconstant') ;

foreach r in se_CR2 se_CR3 { ; // dof_CR2_IK dof_CSS { ;
	return scalar `r' = `r' ;
} ;


end ;

cap mata: mata drop cr2cr3() ;

mata ;

void cr2cr3(betapointer,clusterid,residuals,key_rhs,noconstant) {

RHSvarnames = (st_matrixcolstripe(betapointer)[.,2])'

st_view(cluid=., .,tokens(clusterid)) 
st_view(resid=., .,tokens(residuals)) 

if (noconstant ~= 1) { 
st_view(X=., .,RHSvarnames[1,1..cols(RHSvarnames)-1]) 
X = (X,J(rows(X),1,1))				// add a constant
} 

if (noconstant == 1) { 
st_view(X=., .,RHSvarnames[1,1..cols(RHSvarnames)]) 
} 


// create a cluster-list, and determine the number of clusters 
clusteridlist = uniqrows(cluid)
numclusters = rows(clusteridlist)
cluster_index = J(rows(clusteridlist),2,0)
numobs = rows(X) 
ones = J(numobs,1,1)

obsid = runningsum(J(numobs,1,1))		// internal id for each dyadic observation

// take the X matrix, sort by cluster id.  Keep the original obsid, for sorting back later if needed
sorted = sort((obsid,cluid,resid,X),2)

newX = sorted[|1,4 \ .,.|]
newresid = sorted[|1,3 \ .,3|]

XpX = newX' * newX 
XpXinv = invsym(XpX) 

k = rows(XpX) 

// identify which column of the X matrix contains the key RHS variable
findKeyrhs = RHSvarnames :== key_rhs
keyRHScol = select(1::k,findKeyrhs')


CR2_middle = J(k,k,0)
CR3_middle = J(k,k,0)

CR3_constant = sqrt( ((numclusters - 1) / numclusters) )


/* for I-K correction , construct (I_N - P)*/
/*
projection = newX * XpXinv * newX' 
resid_maker = I(numobs) - projection
*/
/* construct vector to extract column corresponding to main variable 
	and pre-multiply by xpx_inv, for later computations in the loop*/
e_Lk = J(k,1,0)
e_Lk[1,keyRHScol] = 1
XpXinv_Lk = XpXinv * e_Lk

/* initialize matrix G with a leading column of zeros.  later we'll strip out those zeros */
G = J(numobs,1,0) ;


i_g = 1 
while(i_g<=numclusters) { 

	vec_this_cluid = ones*clusteridlist[i_g]  // clusteridlist[i] gives the cluster id we are considering.
	
	// build an index for each cluster, where does it start and where does it end,
	// 		in terms of the obsid in newX (which is sorted on cluid).  save this next to clusteridlist
	match_id =  (sorted[.,2] :== vec_this_cluid)
	obsrange = select(obsid,match_id) 
	min_g = min(obsrange)
	max_g = max(obsrange)
	cluster_index[i_g,.] = (min_g,max_g)
	
	X_g = newX[min_g..max_g,.] // takes newX, extracts match_id rows
	resid_g = newresid[min_g..max_g,.]

	
	Hgg = X_g * XpXinv * X_g'
	middle = I(rows(Hgg)) - Hgg
	middle_inv = invsym(middle)
	Asymsqrt_g = matpowersym(middle_inv,0.5) 
	
	
	CR2_resid = Asymsqrt_g * resid_g 
	addon_CR2 = X_g' CR2_resid * CR2_resid' * X_g
	CR2_middle = CR2_middle + addon_CR2
	
	CR3_resid = middle_inv * resid_g * CR3_constant
	addon_CR3 = X_g' CR3_resid * CR3_resid' * X_g
	CR3_middle = CR3_middle + addon_CR3

/*
	// this is for I-K dof correction
	Part1 = resid_maker[min_g..max_g, .] 	
	G_s = Part1' * Asymsqrt_g * X_g * XpXinv_Lk 
	G = (G,G_s) ;
*/

	i_g++ 
} 


VCV_CR2 = XpXinv * CR2_middle * XpXinv 
se_CR2 = sqrt(VCV_CR2[keyRHScol,keyRHScol]) 

VCV_CR3 = XpXinv * CR3_middle * XpXinv 
se_CR3 = sqrt(VCV_CR3[keyRHScol,keyRHScol]) 

/*
/* Imbens-Kolesar degrees of freedom computation.  This part uses I-K notation, which is different than rest of code
from I-K NBER working paper 18478, page 16, toward bottom of page:

Step 1: compute the G_s vectors
        This requires the following:
            (I_N -P)_s                N_s by N
            Asymsqrt_`gg' from above        N_s by N_s
            X_s                        N_s by L            (L = # regressors)
            (X'X)-1                    L by L
            e_L,k                    L by 1                a matrix of zeros, with one element =1, corrsponding to the beta of interest
           
        G_s = ((I_N -P)_s)' * Asymsqrt * X_s * (X'X)-1 * e_L,k
       
Step 2: Bring G_s together to make G, and "re-package" G to be a series of H matrices (H_s is dimension (N_s by S))
            Matrix G is S horozontally stacked column vectors, and H is S vertically stacked matrices
Step 3:  Compute the random effects parameters for within-group and individual error covariances
Step 4:  Combine to get G * OMEGA-hat * G ... this can be writeen as sum-over-s: H_s' * OMEGEA-hat_s * H_s
Step 5:  find the eigenvalues of G-OM-G; sum these up and square for numerator; sum up the squared eigenvalues for the denominator
         The ratio is estimated degrees of freedom
Step 6:  Save DOF-IK, and move on.

*/    

/* strip out leading column of G */
G = G[|1,2 \ .,.|] 



/* IK Step 3:  Compute the random effects parameters for within-group and individual error covariances */
running_sum = 0 
num_elements = 0 

i_g = 1 
while(i_g<=numclusters) { 
	
	min_g = cluster_index[i_g,1]
	max_g = cluster_index[i_g,2]
	resid_g = newresid[min_g..max_g,.]
	n_g = max_g - min_g + 1
	
	// the two lines below (commented out) are how we did it in R&R #1, code of October 2013
	//addon_sum = sum(resid_g * resid_g')
	//addon_elements = n_g * n_g

	// the two lines below are the right way to do it
	addon_sum = sum(resid_g * resid_g') - resid_g' * resid_g
	addon_elements = n_g * (n_g - 1)
	running_sum = running_sum + addon_sum
	num_elements = num_elements + addon_elements
		
i_g++ 
} 

group_covar = running_sum / num_elements 
s2 = newresid' * newresid / (numobs-1)
indiv_var = s2 - group_covar

// CSS step 1 - create a set of gamma_g's.  Here we set up the vector to store them in.
gammas_collection = J(numclusters,1,0)

/* IK Step 4:  Combine to get G * OMEGA-hat * G ... this can be writeen as sum-over-s: H_s' * OMEGEA-hat_s * H_s */
/* also: "re-package" G into a set of H matricies.  These matricies are each Ng by S in size ... */
G_OM_G = J(numclusters,numclusters,0) ;

i_g = 1 
while(i_g<=numclusters) { 

	min_g = cluster_index[i_g,1]
	max_g = cluster_index[i_g,2]
	n_g = max_g - min_g + 1
	
	OM_hat = J(n_g,n_g,group_covar) + ( I(n_g) * indiv_var)

	// IK step 4
	H_g = G[min_g..max_g, .]
	G_OM_G = G_OM_G + H_g' * OM_hat * H_g

	// CSS step 1
	X_g = newX[min_g..max_g,.] // takes newX, extracts match_id rows
	gamma_g_mat = XpXinv * X_g' * OM_hat * X_g * XpXinv 
	gamma_g = gamma_g_mat[keyRHScol,keyRHScol]
	gammas_collection[i_g,1] = gamma_g
	
i_g++ 
}


/*
IK Step 5:  find the eigenvalues of G-OM-G; sum these up and square for numerator; sum up the squared eigenvalues for the denominator
         The ratio is estimated degrees of freedom
IK Step 6:  Save DOF-IK, and move on.
*/

vlambda = symeigenvalues(G_OM_G)

num = (sum(vlambda))^2
denom = vlambda * vlambda'
dof_CR2_IK = num / denom 


/* Carter, Schnepel, and Steigerwald (2103) Effective number of clusters */
/*
CSS Step 1: create a set of gamma-g's.  These come from:

gamma_g = the kxk element of:  xpx_inv * X_g' * OM_g * X_g * xpx_inv

CSS Step 2:  make gamma-bar as average of gamma_g's.

CSS Step 3:  GAMMA = (1/G) sum((gamma_g - gamma-bar)^2) / (gamma-bar)^2
CSS Step 4:  Effective # clusters = G / (1+GAMMA)
*/

// CSS step 1 done above, stored in gammas_collection
// here are steps 2-4
gamma_bar = mean(gammas_collection)
gamma_dev_sq = (gammas_collection - J(numclusters,1,gamma_bar)) :* (gammas_collection - J(numclusters,1,gamma_bar))
avg_gam_dev_sq = mean(gamma_dev_sq)
GAMMA = avg_gam_dev_sq / ((gamma_bar)^2)
dof_CSS = numclusters / (1+GAMMA)
*/


// list out some things, to make sure I've read them in correctly 
//RHSvarnames 
//newX[1..3,.] 
//se_CR2 
//se_CR3 
//dof_CR2_IK
//dof_CSS

st_numscalar("se_CR2",se_CR2)
st_numscalar("se_CR3",se_CR3)
//st_numscalar("dof_CR2_IK",dof_CR2_IK)
//st_numscalar("dof_CSS",dof_CSS)

} 

end 

