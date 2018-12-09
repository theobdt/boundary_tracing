import numpy as np
from scipy import ndimage as ndi
from skimage.measure import regionprops
import matplotlib.pyplot as plt


frame = np.zeros((1000, 1000))
frame[50:400, 50:500] = 1
frame[550: 980, 550:980] = 1
img_label, _ = ndi.label(frame, structure=ndi.generate_binary_structure(2, 1))
regions = regionprops(img_label)
# plt.imshow(img_label)
# plt.show()
