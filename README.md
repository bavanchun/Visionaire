# Visionaire - Hệ Thống Quản Lý Cửa Hàng Kính Mắt

## 📋 Giới Thiệu

Visionaire là hệ thống quản lý toàn diện cho cửa hàng kính mắt, được xây dựng trên nền tảng .NET 10 với kiến trúc MVC. Hệ thống cung cấp các chức năng quản lý bán hàng, tồn kho, đơn hàng và khách hàng một cách hiệu quả.

## 🚀 Công Nghệ Sử Dụng

- **Framework:** .NET 10
- **Kiến trúc:** MVC (Model-View-Controller)
- **Database:** SQL Server
- **ORM:** Entity Framework Core

## 👥 Phân Quyền Hệ Thống

### 1. **Customer (Khách hàng)**
- Duyệt danh mục, lọc, tìm kiếm sản phẩm kính, lens và các dịch vụ khác
- Xem chi tiết sản phẩm (kính gọng, size, màu, giá, ...), hình ảnh sản phẩm 2D, 3D
- Đặt mua kính theo các loại đơn hàng:
  - Cơ sản (sản phẩm có sẵn)
  - Pre-order (đặt trước)
  - Prescription order (mua kính + làm tròng theo đơn kính)
- Quản lý giỏ hàng, checkout & thanh toán
- Quản lý tài khoản, lịch sử đơn hàng, yêu cầu đổi/trả
- **Tính năng đặc biệt:** Virtual Glasses Try On - Thử kính ảo với các màu kính, size kính phù hợp với khuôn mặt

### 2. **Sales/Support Staff**
- Tiếp nhận và xử lý đơn hàng
- Kiểm tra các thông số prescription và liên hệ hỗ trợ khách hàng điều chỉnh
- Xác nhận đơn, chuyển cho bộ phận Operations Staff
- Thực hiện giao vận, gia công/làm kính
- Xử lý đơn pre-order
- Xử lý khiếu nại: đổi trả, bảo hành, hoàn tiền

### 3. **Operations Staff**
- Đóng gói sản phẩm, tạo vận đơn, cập nhật tracking
- Vận đơn pre-order: nhận hàng về, cập nhật kho, thực hiện quy trình gói và vận chuyển
- Vận đơn prescription: gia công lắp tròng, làm kính
- Cập nhận trạng thái xử lý các đơn hàng theo từng loại đơn

### 4. **Manager**
- Quản lý các quy định nghiệp vụ, chính sách mua/đổi trả/bảo hành
- Quản lý sản phẩm: cấu hình các biến thể thuộc tính sản phẩm
- Quản lý giá bán gống/tròng/dịch vụ, combo (gọng + tròng), khuyến mãi
- Quản lý người dùng, phân sự vận hành nghiệp vụ
- Quản lý doanh thu

### 5. **System Admin**
- Cấu hình và quản trị chức năng hệ thống

## 🗄️ Database

Script khởi tạo database được lưu trong thư mục `scriptDB/`:
- `GlassStoreDB_Complete_Fixed_v2.sql` - Script tạo database đầy đủ

## 📦 Cài Đặt

### Yêu Cầu Hệ Thống
- .NET 10 SDK
- SQL Server 2019 trở lên
- Visual Studio 2022 hoặc VS Code
- Node.js (cho các dependencies frontend)

### Các Bước Cài Đặt

1. **Clone repository**
```bash
git clone <repository-url>
cd Visionaire
```

2. **Khởi tạo Database**
```bash
# Kết nối SQL Server và chạy script
sqlcmd -S <server-name> -i scriptDB/GlassStoreDB_Complete_Fixed_v2.sql
```

3. **Cấu hình Connection String**
```json
// appsettings.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=<server-name>;Database=GlassStoreDB;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

4. **Restore Dependencies**
```bash
dotnet restore
```

5. **Build & Run**
```bash
dotnet build
dotnet run
```

## 🏗️ Cấu Trúc Dự Án

```
Visionaire/
├── Controllers/          # MVC Controllers
├── Models/              # Domain Models & ViewModels
├── Views/               # Razor Views
├── Services/            # Business Logic Layer
├── Repositories/        # Data Access Layer
├── wwwroot/            # Static files (CSS, JS, Images)
├── scriptDB/           # Database Scripts
└── appsettings.json    # Configuration
```

## 🎯 Tính Năng Chính

### Quản Lý Sản Phẩm
- Danh mục sản phẩm kính gọng (2D/3D)
- Quản lý tròng kính và các dịch vụ kèm theo
- Cấu hình biến thể: màu sắc, size, chất liệu
- Quản lý giá và combo

### Quản Lý Đơn Hàng
- **Đơn cơ sản**: Sản phẩm có sẵn
- **Pre-order**: Đặt trước sản phẩm
- **Prescription**: Đơn kính theo toa

### Virtual Try-On
- Thử kính ảo với camera
- Gợi ý màu kính và size phù hợp với khuôn mặt
- Tương tác 3D với sản phẩm

### Quản Lý Khách Hàng
- Lịch sử mua hàng
- Quản lý đổi/trả/bảo hành
- Chăm sóc khách hàng

## 🔐 Bảo Mật
- Authentication & Authorization
- Role-based Access Control (RBAC)
- Secure payment integration
- Data encryption

## 📱 API Endpoints
_(Sẽ cập nhật sau khi phát triển)_

## 🧪 Testing
```bash
dotnet test
```

## 📝 Coding Standards
- Tuân thủ C# Coding Conventions
- Clean Code principles
- SOLID principles
- Repository Pattern & Unit of Work

## 🤝 Đóng Góp

1. Fork dự án
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 License
_(Thêm license nếu có)_

## 👨‍💻 Tác Giả
_(Thêm thông tin tác giả)_

## 📞 Liên Hệ
_(Thêm thông tin liên hệ)_

## 🗺️ Roadmap

### Phase 1: Core Features
- [x] Setup Database
- [ ] Authentication & Authorization
- [ ] Product Management
- [ ] Order Management (Basic)

### Phase 2: Advanced Features
- [ ] Virtual Try-On Integration
- [ ] Prescription Order Processing
- [ ] Payment Gateway Integration
- [ ] Inventory Management

### Phase 3: Enhancement
- [ ] Mobile App
- [ ] Analytics & Reporting
- [ ] AI-based Recommendations
- [ ] Multi-language Support

---

**⚠️ Lưu ý:** Dự án đang trong giai đoạn phát triển. Một số tính năng có thể chưa hoàn thiện.
