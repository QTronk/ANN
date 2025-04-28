import numpy as np

# Hàm kích hoạt cho lớp ẩn: 1 / (1 + exp(-2z))
def activation_hidden(z):
    return 1 / (1 + np.exp(-z))

# Đạo hàm của hàm kích hoạt cho lớp ẩn: 2 * a * (1 - a)
def d_activation_hidden(a):
    return a * (1 - a)

# 1. Dữ liệu đầu vào: 2 mẫu với cặp (x1, x2)
# Mẫu 1: [1, 0]
# Mẫu 2: [1, -1]
X = np.array([
    [1, 0],
    [1, -1]
], dtype=float)

# Mục tiêu tương ứng: d = [0.5, -0.32]
d_targets = np.array([
    [0.5],
    [-0.32]
], dtype=float)

# 2. Khởi tạo trọng số cố định:
# Ma trận V từ lớp đầu vào (2 nơ-ron) sang lớp ẩn (3 nơ-ron):
# Hàng 1: [0.3,  -0.5,  0.4]
# Hàng 2: [0.4,   0.8,  0.5]
V = np.array([
    [0.3, -0.5, 0.4],
    [0.4,  0.8, 0.5]
], dtype=float)

# Ma trận W từ lớp ẩn (3 nơ-ron) sang lớp ra (1 nơ-ron):
# W = [0.3, -0.7, 0.5] (dạng cột, kích thước 3x1)
W = np.array([
    [0.3],
    [-0.7],
    [0.5]
], dtype=float)

# 3. Tham số huấn luyện
learning_rate = 0.5
epochs = 1  # Chỉ thực hiện 1 epoch
loss = 0
# Huấn luyện dạng SGD (cập nhật từng mẫu)
for i in range(X.shape[0]):
    # Lấy mẫu và mục tiêu
    x_sample = X[i:i+1, :]      # Kích thước (1,2)
    target = d_targets[i:i+1, :]  # Kích thước (1,1)
    
    # --- Lan truyền xuôi (Forward Propagation) ---
    # Tính đầu vào của lớp ẩn: z_hidden = x_sample dot V
    z_hidden = np.dot(x_sample, V)         # shape (1, 3)
    # Tính đầu ra lớp ẩn qua hàm kích hoạt
    a_hidden = activation_hidden(z_hidden) # shape (1, 3)
    
    # Lớp ra: với hàm kích hoạt tuyến tính, đầu ra là:
    y_pred = np.dot(a_hidden, W)           # shape (1, 1)
    
    # Tính sai số và hàm mất mát (loss = 0.5*(y_pred - target)^2)
    error = y_pred - target                # delta cho lớp ra
    loss = loss + 0.5 * np.sum(error**2)
    
    print(f"Sample {i+1}:")
    print(" Input x =", x_sample)
    print(" z_hidden =", z_hidden)
    print(" a_hidden =", a_hidden)
    print(" Predicted y =", y_pred)
    print(" Error =", error)
    print(" Loss =", loss)
    
    # --- Lan truyền ngược (Backpropagation) ---
    # Lớp ra sử dụng hàm kích hoạt tuyến tính: delta_out = error
    delta_out = error  # shape (1,1)
    
    # Tính delta của lớp ẩn: delta_hidden = (delta_out dot W^T) * d_activation_hidden(a_hidden)
    delta_hidden = np.dot(delta_out, W.T) * d_activation_hidden(a_hidden)  # shape (1, 3)
    
    # --- Cập nhật trọng số ---
    # Cập nhật W: W = W - learning_rate * (a_hidden^T dot delta_out)
    W_update = np.dot(a_hidden.T, delta_out)
    W = W - learning_rate * W_update
    
    # Cập nhật V: V = V - learning_rate * (x_sample^T dot delta_hidden)
    V_update = np.dot(x_sample.T, delta_hidden)
    V = V - learning_rate * V_update
    
    print(" Updated W =", W)
    print(" Updated V =", V)
    print("-" * 40)

print("Final weights after 1 epoch:")
print("W =", W)
print("V =", V)
