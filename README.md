# Visionaire - Eyewear Store Management System

## 📋 Introduction

Visionaire is a comprehensive management system for eyewear stores, built on .NET 10 platform with MVC architecture. The system provides efficient functionality for sales management, inventory, orders, and customer management.

## 🚀 Technology Stack

- **Framework:** .NET 10
- **Architecture:** MVC (Model-View-Controller)
- **Database:** SQL Server
- **ORM:** Entity Framework Core

## 👥 System Roles

### 1. **Customer**
- Browse catalog, filter, and search for eyewear products, lenses, and other services
- View product details (frames, size, color, price, etc.), 2D and 3D product images
- Place orders for different order types:
  - Standard (available products)
  - Pre-order (advance booking)
  - Prescription order (purchase glasses + lens fabrication according to prescription)
- Manage shopping cart, checkout & payment
- Manage account, order history, return/exchange requests
- **Special Feature:** Virtual Glasses Try On - Try glasses virtually with different colors and sizes that fit your face

### 2. **Sales/Support Staff**
- Receive and process orders
- Verify prescription parameters and contact customers for adjustments
- Confirm orders, forward to Operations Staff
- Handle shipping, lens processing and fabrication
- Process pre-orders
- Handle complaints: returns, warranty, refunds

### 3. **Operations Staff**
- Package products, create shipping labels, update tracking
- Pre-order shipments: receive inventory, update stock, perform packaging and shipping
- Prescription shipments: lens fabrication and assembly
- Update processing status for orders by type

### 4. **Manager**
- Manage business rules, purchase/return/warranty policies
- Manage products: configure product variant attributes
- Manage pricing for frames/lenses/services, combos (frame + lens), promotions
- Manage users, assign operational responsibilities
- Manage revenue

### 5. **System Admin**
- Configure and administer system functionality

## 🗄️ Database

Database initialization script is stored in `scriptDB/` folder:
- `GlassStoreDB_Complete_Fixed_v2.sql` - Complete database creation script

## �� Installation

### System Requirements
- .NET 10 SDK
- SQL Server 2019 or higher
- Visual Studio 2022 or VS Code
- Node.js (for frontend dependencies)

### Installation Steps

1. **Clone repository**
```bash
git clone <repository-url>
cd Visionaire
```

2. **Initialize Database**
```bash
# Connect to SQL Server and run script
sqlcmd -S <server-name> -i scriptDB/GlassStoreDB_Complete_Fixed_v2.sql
```

3. **Configure Connection String**
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

## 🏗️ Project Structure

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

## 🎯 Key Features

### Product Management
- Eyewear frame catalog (2D/3D)
- Manage lenses and related services
- Configure variants: colors, sizes, materials
- Manage pricing and combos

### Order Management
- **Standard Orders**: Available products
- **Pre-orders**: Advance booking
- **Prescription Orders**: Prescription-based glasses

### Virtual Try-On
- Try glasses virtually with camera
- Suggest colors and sizes suitable for face shape
- 3D product interaction

### Customer Management
- Purchase history
- Manage returns/exchanges/warranty
- Customer care

## 🔐 Security
- Authentication & Authorization
- Role-based Access Control (RBAC)
- Secure payment integration
- Data encryption

## 📱 API Endpoints
_(Will be updated after development)_

## 🧪 Testing
```bash
dotnet test
```

## 📝 Coding Standards
- Follow C# Coding Conventions
- Clean Code principles
- SOLID principles
- Repository Pattern & Unit of Work

## 📝 Commit Convention

This project follows **Conventional Commits** standard to ensure clear and trackable commit history.

### Commit Message Structure

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types

| Type | Description | Example |
|------|-------|-------|
| `feat` | Add new feature | `feat(product): add virtual try-on feature` |
| `fix` | Bug fix | `fix(order): resolve payment gateway timeout` |
| `docs` | Documentation update | `docs(readme): update installation guide` |
| `style` | Code format changes (no logic changes) | `style(controller): format code with prettier` |
| `refactor` | Code refactoring | `refactor(service): optimize product query logic` |
| `perf` | Performance improvement | `perf(database): add index for faster queries` |
| `test` | Add or modify tests | `test(order): add unit tests for order service` |
| `build` | Build system or dependency changes | `build(deps): update Entity Framework to 10.0.1` |
| `ci` | CI/CD configuration changes | `ci(github): add automated testing workflow` |
| `chore` | Other changes not affecting code | `chore(gitignore): ignore log files` |
| `revert` | Revert previous commit | `revert: revert feat(product): add virtual try-on` |

### Scope

Scope refers to the affected module/feature:

- `product` - Product management
- `order` - Order management
- `customer` - Customer management
- `auth` - Authentication & authorization
- `cart` - Shopping cart
- `payment` - Payment
- `prescription` - Prescription orders
- `inventory` - Inventory management
- `database` - Database scripts/migrations
- `api` - API endpoints
- `ui` - User interface

### Subject

- Use imperative mood, present tense: "add" not "added" or "adds"
- Don't capitalize first letter
- No period (.) at the end
- Maximum 50 characters
- Write in English

### Body (Optional)

- Explain **why** this change, not **what**
- Use present tense
- Wrap at 72 characters

### Footer (Optional)

- Reference issue/ticket: `Refs: #123`
- Breaking changes: `BREAKING CHANGE: description`
- Close issue: `Closes #123`

### Examples

#### 1. Simple commit
```bash
feat(product): add 3D model viewer for glasses
```

#### 2. Commit with body
```bash
fix(order): resolve duplicate order creation bug

When user clicked submit button multiple times quickly,
the system created multiple orders. Added debounce logic
to prevent duplicate submissions.

Refs: #245
```

#### 3. Breaking change commit
```bash
refactor(api)!: change product API response structure

BREAKING CHANGE: Product API now returns nested object
structure instead of flat structure. Frontend needs to be
updated accordingly.

Before: { id, name, price, color, size }
After: { id, name, price, variants: [{ color, size }] }

Refs: #567
```

#### 4. Commit with multiple changes
```bash
feat(prescription): implement prescription order workflow

- Add prescription form validation
- Create prescription processing service
- Integrate with lens manufacturing API
- Add order tracking for prescription orders

Closes #123, #124
```

### Useful Commands

```bash
# Commit with short message
git commit -m "feat(product): add search filter"

# Commit with body
git commit -m "feat(product): add search filter" -m "Allow users to filter by brand, price, and color"

# Amend last commit message
git commit --amend

# View pretty commit history
git log --oneline --graph --decorate
```

### Branch Naming Convention

Branch names should follow similar rules:

```
<type>/<scope>-<short-description>
```

**Examples:**
- `feat/product-virtual-tryon`
- `fix/order-payment-timeout`
- `docs/update-readme`
- `refactor/optimize-database-queries`

### Pre-Commit Checklist

- [ ] Code tested and runs successfully
- [ ] Code follows coding standards
- [ ] Removed unnecessary comments and debug code
- [ ] Commit message follows convention
- [ ] Reviewed changed files
- [ ] Don't commit sensitive files (appsettings.json, .env)

## 🤝 Contributing

1. Fork the project
2. Create new branch following convention (`git checkout -b feat/amazing-feature`)
3. Commit changes following rules (`git commit -m 'feat(product): add amazing feature'`)
4. Push to branch (`git push origin feat/amazing-feature`)
5. Create Pull Request with detailed description

## 📄 License
_(Add license if applicable)_

## 👨‍💻 Authors
_(Add author information)_

## 📞 Contact
_(Add contact information)_

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

**⚠️ Note:** Project is under development. Some features may not be fully completed.
