import numpy as np
import pytest
from scipy import ndimage as ndi
from skimage.measure import regionprops
import matplotlib.pyplot as plt
from numpy.testing import assert_array_equal
import bt as bt_py
import bt_cy as bt_cy


BOUNDARY_CONNECTIVITY_2 = np.array([[1, 1],
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

BOUNDARY_CONNECTIVITY_1 = np.array([[1, 1],
                                    [2, 1],
                                    [2, 2],
                                    [2, 3],
                                    [3, 3],
                                    [4, 3],
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

    return regions[0]


def plot_region(fake_region):
    binary_image = fake_region.image
    plt.imshow(binary_image)
    plt.show()


def test_py(fake_region):
    # Connectivity 2 only
    boundary = bt_py.boundary_tracing(fake_region)
    assert_array_equal(boundary, BOUNDARY_CONNECTIVITY_2)


def test_cy_connectivity_1(fake_region):
    boundary = bt_cy.boundary_tracing(fake_region, connectivity=1)
    # print(boundary)
    assert_array_equal(boundary, BOUNDARY_CONNECTIVITY_1)


def test_cy_connectivity_2(fake_region):
    boundary = bt_cy.boundary_tracing(fake_region, connectivity=2)
    # print(boundary)
    assert_array_equal(boundary, BOUNDARY_CONNECTIVITY_2)
