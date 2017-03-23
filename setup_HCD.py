from distutils.core import setup
from Cython.Build import cythonize
import numpy

setup(
    ext_modules = cythonize("ms2pipfeatures_pyx_HCD.pyx"),
    include_dirs=[numpy.get_include()]
)
