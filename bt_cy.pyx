#cython: cdivision=True
#cython: nonecheck=False
#cython: wraparound=False
#cython: boundscheck=False

import numpy as np
cimport numpy as cnp
from scipy import ndimage as ndi
from skimage.measure import regionprops


DTYPE = np.int32

OPERATIONS = np.array([[-1, 0], [-1, 1], [0, 1], [1, 1],
                       [1, 0], [1, -1], [0, -1], [-1, -1]], dtype=DTYPE)


def boundary_tracing(region, connectivity):

    assert connectivity in [1, 2], "Connectivity must be 1 or 2"

    bbox = region.bbox
    offset_x = bbox[1] - 1
    offset_y = bbox[0] - 1
    offsets = np.array([offset_y, offset_x])

    start = (region.coords[0] - offsets).astype(DTYPE)
    cdef int[:] start_view = start

    image = np.array(np.pad(region.image, (1, 1), 'constant'), dtype=DTYPE)
    cdef int[:,:] padded_view = image

    if connectivity == 1:
        boundary = boundary_tracing_1(padded_view, start_view)
    else:
        boundary = boundary_tracing_2(padded_view, start_view)
    boundary = boundary + offsets

    return boundary


cpdef cnp.ndarray boundary_tracing_1(int[:,:] padded, int[:] start):

    assert padded[start[0], start[1]] == 1, "Start pixel is not foreground"

    operations = OPERATIONS[::2]
    cdef int[:,:] OP_view = operations

    neighbors = start + operations
    neighbors_start = []


    if padded[neighbors[1][0], neighbors[1][1]] == 1:
        neighbors_start.append(neighbors[1])
    if padded[neighbors[2][0], neighbors[2][1]] == 1:
        neighbors_start.append(neighbors[2])

    assert len(neighbors_start) > 0, "First pixel isolated"

    neighbors_start = np.array(neighbors_start, dtype=DTYPE).reshape(-1, 2)
    cdef int[:,:] neighbors_start_view = neighbors_start[:]

    cdef Py_ssize_t n_neighbors_start = neighbors_start.shape[0]


    cdef int[:,:] neighbors_view = neighbors

    shape = padded.shape

    cdef int N = 2 * (shape[0] + shape[1])

    boundary = np.zeros((N, 2), dtype=DTYPE)
    cdef int[:,:] boundary_view = boundary
    boundary_view[0] = start[:]

    boundary_tot = None
    # Initialization

    current = np.copy(start)

    neighbor = np.zeros(2, dtype=DTYPE)

    cdef:
        int[:] current_view = current[:]
        Py_ssize_t idx_end = 2
        Py_ssize_t counter = 1
        Py_ssize_t max_iter = 10 * N
        Py_ssize_t idx_start, i
        int[:] neighbor_view = neighbor
        int[:] first


    while True:
        #print(f'COUNTER : {counter}')

        idx_start = (idx_end + 3) % 4

        for i in range(4):

            idx_neighbor = (idx_start + i)%4


            neighbor_view[0] = current_view[0] + OP_view[idx_neighbor][0]
            neighbor_view[1] = current_view[1] + OP_view[idx_neighbor][1]

            if padded[neighbor_view[0], neighbor_view[1]] == 1:

                idx_end = idx_neighbor

                current_view[0] = neighbor_view[0]
                current_view[1] = neighbor_view[1]
                break


        if current_view[0] == start[0] and current_view[1] == start[1]:

            if boundary_tot is None:
                first = boundary_view[1]
            else:
                first = boundary_tot[1]
            first_last = [first, boundary_view[(counter -1) % N]]

            if np.all(neighbors_start == np.unique(first_last, axis=0)):
                break


        boundary_view[counter % N][0] = current_view[0]
        boundary_view[counter % N][1] = current_view[1]
        counter += 1

        if counter % N == 0:
            # print('overflow')
            if boundary_tot is None:

                boundary_tot = np.copy(boundary)
            else:

                boundary_tot = np.concatenate((boundary_tot, boundary), axis=0)

        if counter > max_iter:
            print('Max iter reached')
            break

    if boundary_tot is None:
        output = np.copy(boundary[:counter % N])
    else:
        output = np.concatenate((boundary_tot, boundary[:counter % N]), axis=0)

    return output


cpdef cnp.ndarray boundary_tracing_2(int[:,:] padded, int[:] start):

    assert padded[start[0], start[1]] == 1, "Start pixel is not foreground"

    focus_start = padded[start[0]-1:start[0]+2, start[1]-1:start[1]+2]
    assert np.sum(focus_start) > 1, "First pixel isolated"

    cdef Py_ssize_t idx_end

    if (padded[start[0] + 1, start[1]] == 0 and
            padded[start[0]+1, start[1]-1] == 0):
        backtrack_start = np.array([start[0]+1, start[1]], dtype=DTYPE)
        idx_end = 7
    else:
        backtrack_start = np.array([start[0], start[1]-1], dtype=DTYPE)
        idx_end = 1

    cdef int[:] backtrack_start_view = backtrack_start

    backtrack = np.copy(backtrack_start)
    cdef int[:] backtrack_view = backtrack

    cdef int[:,:] OP_view = OPERATIONS

    shape = padded.shape
    cdef int N = 2 * (shape[0] + shape[1])
    cdef Py_ssize_t max_iter = 10 * N

    boundary = np.zeros((N, 2), dtype=DTYPE)
    cdef int[:,:] boundary_view = boundary
    boundary_view[0] = start[:]

    boundary_tot = None

    current = np.copy(np.asarray(start))
    cdef int[:] current_view = current

    cdef Py_ssize_t idx_neighbor, idx_start, idx_backtrack, i,j

    neighbor = np.zeros(2, dtype=DTYPE)
    cdef int[:] neighbor_view = neighbor

    cdef Py_ssize_t counter = 1

    while True:

        idx_start = (((idx_end + 6) // 2) * 2 ) % 8
        #print(f'COUNTER {counter}')

        for j in range(8):

            idx_neighbor = (idx_start + j) % 8
            neighbor_view[0] = current_view[0] + OP_view[idx_neighbor][0]
            neighbor_view[1] = current_view[1] + OP_view[idx_neighbor][1]

            if padded[neighbor_view[0], neighbor_view[1]] == 1:
                idx_end = idx_neighbor
                idx_backtrack = (idx_neighbor + 7) % 8
                backtrack_view[0] = current_view[0] + OP_view[idx_backtrack][0]
                backtrack_view[1] = current_view[1] + OP_view[idx_backtrack][1]
                current_view[0] = neighbor_view[0]
                current_view[1] =  neighbor_view[1]

                break


        if current_view[0] == start[0] and current_view[1] == start[1]:

            if np.all(np.asarray(backtrack_view) == backtrack_start):
                break

        boundary_view[counter % N][0] = current_view[0]
        boundary_view[counter % N][1] = current_view[1]
        counter += 1

        if counter % N == 0:
            # print('overflow')
            if boundary_tot is None:
                boundary_tot = np.copy(boundary)
            else:
                boundary_tot = np.concatenate((boundary_tot, boundary), axis=0)

        if counter > max_iter:
            print('Max iter reached')
            break

    if boundary_tot is None:
        output = np.copy(boundary[:counter % N])
    else:
        output = np.concatenate((boundary_tot, boundary[:counter % N]), axis=0)

    return output
