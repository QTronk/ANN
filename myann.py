import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from mpl_toolkits.mplot3d import Axes3D  # Dùng để vẽ đồ thị 3D

# ==============================
# 1. Sinh dữ liệu:
# Sinh N_total mẫu ngẫu nhiên cho x1 và x2 từ [-10, 10],
# Sau đó lọc để chỉ giữ lại các mẫu hợp lệ (x1 > 0 và x2 > 0)
np.random.seed(42)
N_total = 5000  # Sinh 5000 mẫu để đảm bảo sau lọc vẫn có >1000 mẫu
x1_all = np.random.uniform(-10, 10, N_total)
x2_all = np.random.uniform(-10, 10, N_total)

# Điều kiện yêu cầu để hàm sau có nghĩa:
#   - ln(x1*x2) có nghĩa khi x1*x2 > 0  => (với x1 > 0 và x2 > 0, tự nhiên thỏa)
#   - sqrt(x2) có nghĩa khi x2 > 0.
mask = (x1_all > 0) & (x2_all > 0)
x1 = x1_all[mask]
x2 = x2_all[mask]
print("Số mẫu hợp lệ:", len(x1))  # Thông thường khoảng 1250 mẫu

# Tập dữ liệu đầu vào và giá trị mục tiêu theo công thức:
#    y = x1^2 + ln(x1*x2) + sqrt(x2)
X = np.stack([x1, x2], axis=1)
y = x1**2 + np.log(x1 * x2) + np.sqrt(x2)

# ==============================
# 2. Xây dựng mạng Neural Network:
# Yêu cầu:
# - Nhận 2 đầu vào
# - 7 lớp ẩn, mỗi lớp 10 nơ-ron, với hàm kích hoạt: 1/(1+e^(-2f))
# - 1 lớp ra với hàm kích hoạt tuyến tính
class NeuralNetwork:
    def __init__(self, layer_sizes):
        """
        layer_sizes: danh sách số nơ-ron của các lớp từ input đến output.
                     Ví dụ: [2, 10,10,10,10,10,10,10, 1]
        """
        self.layer_sizes = layer_sizes
        self.num_layers = len(layer_sizes) - 1  # Các lớp có trọng số (không tính lớp input)
        self.weights = []
        self.biases = []
        for i in range(self.num_layers):
            # Khởi tạo trọng số và bias ngẫu nhiên
            W = np.random.uniform(-1, 1, (layer_sizes[i], layer_sizes[i+1]))
            b = np.random.uniform(-1, 1, (1, layer_sizes[i+1]))
            self.weights.append(W)
            self.biases.append(b)
    
    def activation_hidden(self, z):
        """Hàm kích hoạt lớp ẩn: 1 / (1 + exp(-2z))"""
        return 1 / (1 + np.exp(-2 * z))
    
    def d_activation_hidden(self, z):
        """Đạo hàm của hàm kích hoạt lớp ẩn:
           Nếu a = 1/(1+exp(-2z)) thì a' = 2*a*(1-a)"""
        a = self.activation_hidden(z)
        return 2 * a * (1 - a)
    
    def activation_output(self, z):
        """Hàm kích hoạt lớp ra: tuyến tính f(z)=z"""
        return z
    
    def d_activation_output(self, z):
        """Đạo hàm của hàm kích hoạt lớp ra: = 1"""
        return np.ones_like(z)
    
    def forward(self, x):
        """
        Lan truyền tiến: tính toán đầu ra ở mỗi lớp.
        x: đầu vào có kích thước (m, input_dim) hoặc (1, input_dim).
        Trả về:
          - a_list: danh sách đầu ra tại mỗi lớp, bao gồm input.
          - z_list: danh sách giá trị tuyến tính (trước kích hoạt) của mỗi lớp.
        """
        a_list = [x]
        z_list = []
        for i in range(self.num_layers):
            z = np.dot(a_list[-1], self.weights[i]) + self.biases[i]
            z_list.append(z)
            if i == self.num_layers - 1:  # lớp ra
                a = self.activation_output(z)
            else:
                a = self.activation_hidden(z)
            a_list.append(a)
        return a_list, z_list
    
    def backward(self, a_list, z_list, y_true):
        """
        Tính lan truyền ngược sử dụng loss L = 0.5*(a_last - y_true)^2.
        Trả về:
          - delta_list: danh sách sai số (delta) cho các lớp.
        """
        delta_list = [None] * self.num_layers
        # Lớp ra: với hàm kích hoạt tuyến tính nên delta = (a_last - y_true)
        aL = a_list[-1]
        delta = (aL - y_true) * self.d_activation_output(z_list[-1])
        delta_list[-1] = delta
        # Lan truyền ngược qua các lớp ẩn
        for i in reversed(range(self.num_layers - 1)):
            delta = np.dot(delta_list[i+1], self.weights[i+1].T) * self.d_activation_hidden(z_list[i])
            delta_list[i] = delta
        return delta_list
    
    def update(self, a_list, delta_list, learning_rate):
        """
        Cập nhật trọng số và bias theo:
          W = W - learning_rate * (a_pre.T dot delta)
          b = b - learning_rate * delta
        """
        for i in range(self.num_layers):
            dW = np.dot(a_list[i].T, delta_list[i])
            db = delta_list[i]
            self.weights[i] -= learning_rate * dW
            self.biases[i]  -= learning_rate * db
    
    def train(self, X, y, epochs, learning_rate):
        """
        Huấn luyện mạng dùng SGD (mỗi mẫu cập nhật riêng).
        Trả về danh sách lỗi tích lũy (cumulative error) qua mỗi epoch.
        """
        errors = []
        n_samples = X.shape[0]
        for epoch in range(epochs):
            cumulative_error = 0.0
            for i in range(n_samples):
                x_sample = X[i:i+1, :]       # kích thước (1, 2)
                y_sample = np.array([[y[i]]])  # kích thước (1, 1)
                a_list, z_list = self.forward(x_sample)
                prediction = a_list[-1]
                sample_error = 0.5 * np.sum((prediction - y_sample)**2)
                cumulative_error += sample_error
                delta_list = self.backward(a_list, z_list, y_sample)
                self.update(a_list, delta_list, learning_rate)
            errors.append(cumulative_error)
            print(f"Epoch {epoch+1}/{epochs} - Cumulative Error: {cumulative_error:.4f}")
        return errors

# ==============================
# 3. Huấn luyện mạng:
layer_sizes = [2] + [10]*7 + [1]  # Cấu trúc: 2 đầu vào, 7 lớp ẩn (10 nơ-ron mỗi lớp), 1 đầu ra
nn = NeuralNetwork(layer_sizes)
epochs = 100
learning_rate = 0.001
errors = nn.train(X, y, epochs, learning_rate)

# Vẽ đồ thị lỗi tích lũy qua từng epoch (sử dụng Matplotlib 2D):
plt.figure()
plt.plot(range(epochs), errors, marker='o')
plt.xlabel("Epoch")
plt.ylabel("Cumulative Error")
plt.title("Training Error over Epochs")
plt.show()

# ==============================
# 4. Vẽ đồ thị 3D so sánh hàm phi tuyến gốc và kết quả của mạng:
# Tạo lưới điểm cho x1 và x2 trong miền hợp lệ (0.1 đến 10)
x1_grid = np.linspace(0.1, 10, 50)
x2_grid = np.linspace(0.1, 10, 50)
X1, X2 = np.meshgrid(x1_grid, x2_grid)
grid_points = np.column_stack((X1.flatten(), X2.flatten()))

# Tính giá trị hàm phi tuyến gốc theo công thức:
Y_true = grid_points[:,0]**2 + np.log(grid_points[:,0] * grid_points[:,1]) + np.sqrt(grid_points[:,1])
Y_true = Y_true.reshape(X1.shape)

# Dự đoán của mạng cho các điểm trên lưới:
a_list, _ = nn.forward(grid_points)
Y_pred = a_list[-1].reshape(X1.shape)

# Vẽ đồ thị 3D:
fig = plt.figure(figsize=(14, 6))

# Đồ thị hàm phi tuyến gốc:
ax1 = fig.add_subplot(121, projection='3d')
surf1 = ax1.plot_surface(X1, X2, Y_true, cmap='viridis', edgecolor='none')
ax1.set_title("Hàm phi tuyến gốc")
ax1.set_xlabel("x1")
ax1.set_ylabel("x2")
ax1.set_zlabel("y")
fig.colorbar(surf1, ax=ax1, shrink=0.5, aspect=5)

# Đồ thị dự đoán của mạng:
ax2 = fig.add_subplot(122, projection='3d')
surf2 = ax2.plot_surface(X1, X2, Y_pred, cmap='viridis', edgecolor='none')
ax2.set_title("Dự đoán của mạng")
ax2.set_xlabel("x1")
ax2.set_ylabel("x2")
ax2.set_zlabel("y")
fig.colorbar(surf2, ax=ax2, shrink=0.5, aspect=5)

plt.suptitle("So sánh Hàm phi tuyến gốc và Dự đoán mạng (3D)")
plt.show()

# ==============================
# 5. Vẽ đồ thị 2D so sánh:
# Ở đây ta cố định x2 = 5, vẽ hàm phi tuyến gốc và dự đoán của mạng theo biến x1

x1_line = np.linspace(0.1, 10, 100)
x2_line = 5 * np.ones_like(x1_line)
X_line = np.column_stack((x1_line, x2_line))

# Hàm phi tuyến gốc:
y_true_line = x1_line**2 + np.log(x1_line * 5) + np.sqrt(5)

# Dự đoán của mạng:
pred_line = []
for i in range(len(x1_line)):
    a_list, _ = nn.forward(X_line[i:i+1, :])
    pred_line.append(a_list[-1][0,0])

# Tạo DataFrame với Pandas:
df_line = pd.DataFrame({
    "x1": x1_line,
    "Hàm phi tuyến gốc": y_true_line,
    "Dự đoán mạng": pred_line
})

# Vẽ biểu đồ 2D so sánh:
ax = df_line.plot(x="x1", y=["Hàm phi tuyến gốc", "Dự đoán mạng"],
                  title="So sánh Hàm phi tuyến gốc và Dự đoán mạng (2D)",
                  marker="o", figsize=(8, 5))
ax.set_xlabel("x1")
ax.set_ylabel("y")
plt.show()
