import timeit

n_test = 100

setup_py = '''
import bt
import example'''

setup_cy = '''
import bt_cy as bt
import example'''

cy = timeit.timeit('bt.boundary_tracing(example.regions[0])',
                   setup=setup_cy,
                   number=n_test)

py = timeit.timeit('bt.boundary_tracing(example.regions[0])',
                   setup=setup_py,
                   number=n_test)

py *= 1000
cy *= 1000

print(f'n_test : {n_test}')
print(f'python : {round(py/n_test, 3)}ms/test')
print(f'cython : {round(cy/n_test, 3)}ms/test')
print(f'cython is {round(py/cy, 3)}x faster than python')
