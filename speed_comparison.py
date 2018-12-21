import timeit
import bt_cy


N_TEST = 100
CONNECTIVITY = 2

print(f'CONNECTIVITY : {CONNECTIVITY}')
print(f'N_TEST : {N_TEST}')

setup_py = '''
import bt
import example'''

# boundary_tracing = profile(bt_cy.boundary_tracing)

setup_cy = '''
import example
from bt_cy import boundary_tracing
'''

# import both_bt_cy as bt

cy = timeit.timeit(f'boundary_tracing(example.regions[0], {CONNECTIVITY})',
                   setup=setup_cy,
                   number=N_TEST)

py = timeit.timeit('bt.boundary_tracing(example.regions[0])',
                   setup=setup_py,
                   number=N_TEST)

py *= 1000
cy *= 1000

print(f'python : {round(py/N_TEST, 3)}ms/test')
print(f'cython : {round(cy/N_TEST, 3)}ms/test')
print(f'cython is {round(py/cy, 3)}x faster than python')
