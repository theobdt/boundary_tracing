"""Compare a python and a cython version of the boundary tracing algorithm
    $ python setup.py build_ext --inplace
"""
from distutils.core import setup
from Cython.Build import cythonize
import numpy

setup(ext_modules=cythonize('bt_cy.pyx'),
      include_dirs=[numpy.get_include()])
