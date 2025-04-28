import numpy as np
x1 = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
x2 = np.array([ [10, 11, 12], [14, 15, 16], [17, 18, 19]])
X = np.stack([x1, x2], axis=2)
print(X)
print(x1)