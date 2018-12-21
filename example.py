import numpy as np
from scipy import ndimage as ndi
from skimage.measure import regionprops


frame = np.zeros((1000, 1000))
frame[50:500, 50:400] = 1
frame[550: 980, 550:980] = 1
img_label, _ = ndi.label(frame, structure=ndi.generate_binary_structure(2, 1))
regions = regionprops(img_label)
