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

## 📝 Quy Tắc Commit (Commit Convention)

Dự án tuân theo chuẩn **Conventional Commits** để đảm bảo lịch sử commit rõ ràng và dễ theo dõi.

### Cấu Trúc Commit Message

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Các Loại Type

| Type | Mô Tả | Ví Dụ |
|------|-------|-------|
| `feat` | Thêm tính năng mới | `feat(product): add virtual try-on feature` |
| `fix` | Sửa lỗi | `fix(order): resolve payment gateway timeout` |
| `docs` | Cập nhật tài liệu | `docs(readme): update installation guide` |
| `style` | Thay đổi format code (không ảnh hưởng logic) | `style(controller): format code with prettier` |
| `refactor` | Tái cấu trúc code | `refactor(service): optimize product query logic` |
| `perf` | Cải thiện hiệu suất | `perf(database): add index for faster queries` |
| `test` | Thêm hoặc sửa test | `test(order): add unit tests for order service` |
| `build` | Thay đổi build system hoặc dependencies | `build(deps): update Entity Framework to 10.0.1` |
| `ci` | Thay đổi CI/CD configuration | `ci(github): add automated testing workflow` |
| `chore` | Các thay đổi khác không ảnh hưởng code | `chore(gitignore): ignore log files` |
| `revert` | Hoàn tác commit trước đó | `revert: revert feat(product): add virtual try-on` |

### Scope (Phạm vi)

Scope là phần module/tính năng bị ảnh hưởng:

- `product` - Quản lý sản phẩm
- `order` - Quản lý đơn hàng
- `customer` - Quản lý khách hàng
- `auth` - Xác thực & phân quyền
- `cart` - Giỏ hàng
- `payment` - Thanh toán
- `prescription` - Đơn kính theo toa
- `inventory` - Quản lý kho
- `database` - Database scripts/migrations
- `api` - API endpoints
- `ui` - Giao diện người dùng

### Subject (Tiêu đề)

- Sử dụng câu mệnh lệnh, thì hiện tại: "add" không phải "added" hay "adds"
- Không viết hoa chữ cái đầu
- Không dùng dấu chấm (.) ở cuối
- Giới hạn tối đa 50 ký tự
- Viết bằng tiếng Anh

### Body (Nội dung - Optional)

- Giải thích **tại sao** thay đổi này, không phải **làm gì**
- Sử dụng thì hiện tại
- Ngắt dòng ở 72 ký tự

### Footer (Optional)

- Tham chiếu đến issue/ticket: `Refs: #123`
- Breaking changes: `BREAKING CHANGE: description`
- Đóng issue: `Closes #123`

### Ví Dụ Cụ Thể

#### 1. Commit đơn giản
```bash
feat(product): add 3D model viewer for glasses
```

#### 2. Commit với body
```bash
fix(order): resolve duplicate order creation bug

When user clicked submit button multiple times quickly,
the system created multiple orders. Added debounce logic
to prevent duplicate submissions.

Refs: #245
```

#### 3. Commit breaking change
```bash
refactor(api)!: change product API response structure

BREAKING CHANGE: Product API now returns nested object
structure instead of flat structure. Frontend needs to be
updated accordingly.

Before: { id, name, price, color, size }
After: { id, name, price, variants: [{ color, size }] }

Refs: #567
```

#### 4. Commit với nhiều thay đổi
```bash
feat(prescription): implement prescription order workflow

- Add prescription form validation
- Create prescription processing service
- Integrate with lens manufacturing API
- Add order tracking for prescription orders

Closes #123, #124
```

### Các Lệnh Hữu Ích

```bash
# Commit với message ngắn
git commit -m "feat(product): add search filter"

# Commit với body
git commit -m "feat(product): add search filter" -m "Allow users to filter by brand, price, and color"

# Sửa commit message gần nhất
git commit --amend

# Xem lịch sử commit đẹp
git log --oneline --graph --decorate
```

### Branch Naming Convention

Tên branch cũng nên tuân theo quy tắc tương tự:

```
<type>/<scope>-<short-description>
```

**Ví dụ:**
- `feat/product-virtual-tryon`
- `fix/order-payment-timeout`
- `docs/update-readme`
- `refactor/optimize-database-queries`

### Checklist Trước Khi Commit

- [ ] Code đã được test và chạy thành công
- [ ] Code tuân thủ coding standards
- [ ] Đã xóa các comment không cần thiết và debug code
- [ ] Commit message tuân thủ convention
- [ ] Đã review lại các file thay đổi
- [ ] Không commit các file sensitive (appsettings.json, .env)

## 🤝 Đóng Góp

1. Fork dự án
2. Tạo branch mới theo convention (`git checkout -b feat/amazing-feature`)
3. Commit changes theo quy tắc (`git commit -m 'feat(product): add amazing feature'`)
4. Push to branch (`git push origin feat/amazing-feature`)
5. Tạo Pull Request với mô tả chi tiết

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
