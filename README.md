# Boundary tracing with Cython

## Current results
```
CONNECTIVITY : 2
N_TEST : 100
python : 77.137ms/test
cython : 5.331ms/test
cython is 14.468x faster than python
```

## Compiling bt_cy.pyx
`$ python setup.py build_ext --inplace`


## Testing
`$ python -m pytest`


## Speed comparison
`$ python speed_comparison.py`
