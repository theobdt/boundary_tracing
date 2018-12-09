import numpy as np
import pytest
from scipy import ndimage as ndi
from skimage.measure import regionprops
import matplotlib.pyplot as plt
from numpy.testing import assert_array_equal
import bt as bt_py
import bt_cy


BOUNDARY = np.array([[1, 1],
                     [2, 2],
                     [2, 3],
                     [1, 4],
                     [2, 3],
                     [3, 3],
                     [4, 4],
                     [4, 3],
                     [4, 2],
                     [4, 1],
                     [3, 1],
                     [2, 1]])


@pytest.fixture
def fake_region():
    frame = np.zeros((6, 6))
    frame[1:-1, 1:-1] = 1
    frame[1, 2:4] = 0
    frame[2:4, 4] = 0
    print(frame)
    img_label, _ = ndi.label(frame,
                             structure=ndi.generate_binary_structure(2, 2))
    regions = regionprops(img_label)
    # plt.imshow(img_label)
    # plt.show()

    return regions[0]


def test_py(fake_region):
    boundary = bt_py.boundary_tracing(fake_region)
    assert_array_equal(boundary, BOUNDARY)


def test_cy(fake_region):
    boundary = bt_cy.boundary_tracing(fake_region)
    print(boundary)
    assert_array_equal(boundary, BOUNDARY)
