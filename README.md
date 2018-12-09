# Boundary tracing with Cython

## Current results
```
n_test : 100
python : 79.794ms/test
cython : 21.098ms/test
cython is 3.782x faster than python
```

## Compiling bt_cy.pyx
`$ python setup.py build_ext --inplace`


## Testing
`$ python -m pytest`


## Speed comparison
`$ python speed_comparison.py`
