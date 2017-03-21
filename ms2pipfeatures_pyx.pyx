import sys
import numpy as np
cimport numpy as np

cdef extern from "ms2pipfeatures_c.c":
	#uncomment for Omega
	#void init(char* amino_masses_fname, char* modifications_fname, char* modifications_fname_sptm)
	void init(char* amino_masses_fname)
	unsigned int* get_v(int peplen, unsigned short* peptide, unsigned short* modpeptide, int charge)
	unsigned int* get_v_bof_chem(int peplen, unsigned short* peptide, int charge)
	float* get_p(int peplen, unsigned short* peptide, unsigned short* modpeptide, int charge)
	float* get_t(int peplen, unsigned short* modpeptide, int numpeaks, float* msms, float* peaks, float nptm, float cptm)
	float* get_mz(int peplen, unsigned short* modpeptide, float nptm, float cptm)

#uncomment for Omega
#def ms2pip_init(amino_masses_fname, modifications_fname,modifications_fname_sptm):
#	init(amino_masses_fname, modifications_fname,modifications_fname_sptm)

def ms2pip_init(amino_masses_fname):
	init(amino_masses_fname)

def get_vector(np.ndarray[unsigned short, ndim=1, mode="c"] peptide,np.ndarray[unsigned short, ndim=1, mode="c"] modpeptide, charge):
	cdef unsigned int* result = get_v(len(peptide),&peptide[0],&modpeptide[0],charge)
	r = []
	offset = 0
	for i in range(len(peptide)-1):
		v = []
		for j in range(186):
			v.append(result[j+offset])
		offset+=186
		r.append(v)
	return r

def get_vector_bof_chem(np.ndarray[unsigned short, ndim=1, mode="c"] peptide, int charge):
	cdef unsigned int* result = get_v_bof_chem(len(peptide),&peptide[0],charge)
	r = []
	offset = 0
	for i in range(len(peptide)-1):
		v = []
		for j in range(128):
			v.append(result[j+offset])
		offset+=128
		r.append(v)
	return r

def get_mzs(np.ndarray[unsigned short, ndim=1, mode="c"] modpeptide,float nptm,float cptm):
	cdef int pos = 0
	cdef float* result = get_mz(len(modpeptide), &modpeptide[0], nptm, cptm)
	b = []
	for i in range(len(modpeptide)-1):
		b.append(result[pos])
		pos += 1
	y = []
	for i in range(len(modpeptide)-1):
		y.append(result[pos])
		pos+=1
	return(b,y)
	
def get_targets(np.ndarray[unsigned short, ndim=1, mode="c"] modpeptide, np.ndarray[float, ndim=1, mode="c"] msms, np.ndarray[float, ndim=1, mode="c"] peaks,float nptm,float cptm):
	cdef float* result = get_t(len(modpeptide),&modpeptide[0],len(peaks),&msms[0],&peaks[0],nptm,cptm)
	b = []
	for i in range(len(modpeptide)-1):
		b.append(result[i])
	y = []
	for i in range(len(modpeptide)-1):
		y.append(result[2*len(modpeptide)-3-i])
	return(b,y)

"""
def get_score(np.ndarray[unsigned short, ndim=1, mode="c"] peptide,np.ndarray[unsigned short, ndim=1, mode="c"] modpeptide, np.ndarray[float, ndim=1, mode="c"] msms, np.ndarray[float, ndim=1, mode="c"] peaks, charge):
	cdef float* targets = get_t(len(modpeptide),&modpeptide[0],len(peaks),&msms[0],&peaks[0])
	cdef float* predictions = get_p(len(peptide),&peptide[0],&modpeptide[0],charge)
	mae = 0.
	#for i in range(2*len(modpeptide)-2):
	for i in range(len(modpeptide)-1):
		sys.stdout.write("%f " % (predictions[len(modpeptide-1)+i]))
		mae += abs(targets[len(modpeptide)-1+i]-predictions[len(modpeptide)-1+i])
	sys.stdout.write("\n")
	#mae /= (2*len(modpeptide)-2)
	mae /= (len(modpeptide)-1)
	#print mae
	return mae
"""
def get_predictions(np.ndarray[unsigned short, ndim=1, mode="c"] peptide,np.ndarray[unsigned short, ndim=1, mode="c"] modpeptide, charge):
	cdef float* predictions = get_p(len(peptide),&peptide[0],&modpeptide[0],charge)
	resultB = []
	resultY = []
	for i in range(len(modpeptide)-1):
		resultB.append(predictions[i])
	for i in range(len(modpeptide)-1):
		resultY.append(predictions[len(modpeptide)+i])
	return (resultB,resultY)
