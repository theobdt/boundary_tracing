import numpy as np
cimport numpy as cnp

DTYPE = np.int32
# cdef cnp.int_t DTYPE_t

cdef list OPERATIONS = [[-1, 0], [-1, 1], [0, 1], [1, 1],
                        [1, 0], [1, -1], [0, -1], [-1, -1]]



cpdef cnp.ndarray boundary_tracing(region):
    """Coordinates of the region's boundary.
    The region must not have isolated points.

    Arguments
    ---------
        region (obj)

    Returns
    -------
        List of coordinates of pixels in the boundary
        The first element is the most upper left pixel of the region.
        The following coordinates are in clockwise order.
    """

    # creating the binary image
    cdef  cnp.ndarray coords, binary
    cdef cnp.ndarray maxs, x, y

    coords = np.array(region.coords, dtype=DTYPE)
    coords_y = coords[:, 0]
    coords_x = coords[:, 1]
    maxs = np.amax(coords, axis=0)
    binary = np.zeros((maxs[0] + 10, maxs[1] + 10), dtype=DTYPE)
    binary[coords_y, coords_x] = 1
    # for coord in coords:
        # binary[coord[0], coord[1]] = 1

    # initilization
    # starting point is the most upper left point
    cdef int idx_start = 0
    cdef list start
    cdef cnp.ndarray focus_start

    while True:  # asserting that the starting point is not isolated
        start = list(np.array([coords[idx_start][0], coords[idx_start][1]],
                              dtype=DTYPE))
        focus_start = binary[start[0]-1:start[0]+2, start[1]-1:start[1]+2]
        if np.sum(focus_start) > 1:
            break
        idx_start = idx_start + 1

    # Determining backtrack pixel for the first element
    cdef list backtrack_start

    if (binary[start[0]+1][start[1]] == 0 and
            binary[start[0]+1, start[1]-1] == 0):
        backtrack_start = list(np.array([start[0]+1, start[1]], dtype=DTYPE))
    else:
        backtrack_start = list(np.array([start[0], start[1]-1], dtype=DTYPE))

    cdef Py_ssize_t counter_glob, i, j
    cdef list current, backtrack, pix
    cdef list neighbors, binary_list

    binary_list = list(binary)

    current = start
    backtrack = backtrack_start
    boundary = [start]
    counter_glob = 0
    neighbors = [[0, 0] for i in range(8)]

    while True:

        for j in range(8):
            neighbors[j][0] = current[0] + OPERATIONS[j][0]
            neighbors[j][1] = current[1] + OPERATIONS[j][1]

            if neighbors[j] == backtrack:
                idx_start = j

        for i in range(8):
            pix = neighbors[(idx_start + i) % 8]
            if binary_list[pix[0]][pix[1]] == 1:
                current = pix[:]
                backtrack = neighbors[(idx_start + i - 1) % 8][:]
                break
        else:
            print(f'ERROR : no neighbor found around pixel {current}')
            return 1

        counter_glob = counter_glob + 1

        if current == start:
            if backtrack == backtrack_start:
                return np.asarray(boundary)  #y, x

        boundary.append(current)

        if counter_glob > 100000:
            print('ERROR : stuck in the loop')
            return 1
