import numpy as np


# for test
current = np.array([10, 10])
back = np.array([10, 9])

OPERATIONS = np.array([[-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1],
                       [0, -1], [-1, -1]])



def boundary_tracing(region):
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
    coords = region.coords
    maxs = np.amax(coords, axis=0)
    binary = np.zeros((maxs[0] + 2, maxs[1] + 2))
    x = coords[:, 1]
    y = coords[:, 0]
    binary[tuple([y, x])] = 1

    # initilization
    # starting point is the most upper left point
    idx_start = 0
    while True:  # asserting that the starting point is not isolated
        start = [y[idx_start], x[idx_start]]
        focus_start = binary[start[0]-1: start[0]+2,
                             start[1]-1: start[1]+2]
        if np.sum(focus_start) > 1:
            break
        idx_start += 1

    # Determining backtrack pixel for the first element
    if (binary[start[0]+1, start[1]] == 0 and
            binary[start[0]+1, start[1]-1] == 0):
        backtrack_start = [start[0]+1, start[1]]
    else:
        backtrack_start = [start[0], start[1]-1]

    current = start
    backtrack = backtrack_start
    boundary = [start]
    counter_glob = 0
    neighbors = [[0, 0]]*8

    while True:
        i = 0
        for op in OPERATIONS:
            pix = current + op
            neighbors[i] = pix
            if np.all(pix == backtrack):
                idx_start = i
            i += 1

        i = 0
        while True:
            pix = neighbors[(idx_start+i) % 8]
            if binary[pix[0], pix[1]] == 1:
                current = pix
                backtrack = neighbors[(idx_start+i-1) % 8]
                break
            i += 1
            if i > 7:
                print(f'ERROR : no neighbor found around pixel {current}')
                return 1

        counter_glob += 1

        if np.all(current == start):
            if np.all(backtrack == backtrack_start):
                break

        boundary.append(current)

    return np.array(boundary)  # y, x
