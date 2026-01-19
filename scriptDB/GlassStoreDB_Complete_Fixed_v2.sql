/* =========================================================
   GLASS STORE - SQL Server DDL (COMPLETE & FIXED VERSION v2)
   
   Author: Group Project - Glass E-Commerce System
   Date: January 2026
   
   FIX: Removed problematic filtered index that compared two columns
   
   KEY CHANGES FROM ORIGINAL:
   1. Renamed 'user' → 'customer' for clarity
   2. Fixed product_media_VanHB table (removed wrong columns)
   3. Added missing tables: combo, promotion, review, warranty, virtual_tryon
   4. Enhanced prescription with doctor info
   5. Added CHECK constraints & indexes
   6. Improved comments and documentation
   ========================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* =========================================================
   1) CREATE DATABASE
   ========================================================= */
IF DB_ID(N'GlassStoreDB') IS NULL
BEGIN
    CREATE DATABASE [GlassStoreDB];
END
GO

USE [GlassStoreDB];
GO

PRINT '=== Database GlassStoreDB selected ===';
GO

/* =========================================================
   2) ROLE TABLE - User Roles System
   ========================================================= */
IF OBJECT_ID(N'dbo.role', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.role (
        role_id         uniqueidentifier NOT NULL CONSTRAINT DF_role_role_id DEFAULT NEWSEQUENTIALID(),
        role_name       nvarchar(100)    NOT NULL,
        legacy_role_id  int              NULL,  -- Maps to System.UserAccount.RoleId
        description     nvarchar(300)    NULL,
        is_active       bit              NOT NULL CONSTRAINT DF_role_is_active DEFAULT (1),
        created_at      datetime2(0)     NOT NULL CONSTRAINT DF_role_created_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_role PRIMARY KEY CLUSTERED (role_id),
        CONSTRAINT UQ_role_legacy_role_id UNIQUE (legacy_role_id),
        CONSTRAINT UQ_role_role_name UNIQUE (role_name)
    );
    
    PRINT '✓ Created table: role';
END
GO

/* =========================================================
   3) SYSTEM.USERACCOUNT - Teacher Provided Table
   For: Operations Staff, Sales/Support Staff, Manager, System Admin
   ========================================================= */
IF OBJECT_ID(N'[dbo].[System.UserAccount]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[System.UserAccount](
        [UserAccountID]     uniqueidentifier NOT NULL CONSTRAINT DF_SystemUserAccount_UserAccountID DEFAULT NEWSEQUENTIALID(),
        [UserName]          nvarchar(50)     NOT NULL,
        [Password]          nvarchar(100)    NOT NULL,
        [FullName]          nvarchar(100)    NOT NULL,
        [Email]             nvarchar(150)    NOT NULL,
        [Phone]             nvarchar(50)     NOT NULL,
        [EmployeeCode]      nvarchar(50)     NOT NULL,
        [RoleId]            int              NOT NULL,  -- Maps to role.legacy_role_id
        [RequestCode]       nvarchar(50)     NULL,
        [CreatedDate]       datetime2(0)     NULL,
        [ApplicationCode]   nvarchar(50)     NULL,
        [CreatedBy]         nvarchar(50)     NULL,
        [ModifiedDate]      datetime2(0)     NULL,
        [ModifiedBy]        nvarchar(50)     NULL,
        [IsActive]          bit              NOT NULL CONSTRAINT DF_SystemUserAccount_IsActive DEFAULT (1),
        
        CONSTRAINT [PK_System.UserAccount] PRIMARY KEY CLUSTERED ([UserAccountID]),
        CONSTRAINT UQ_SystemUserAccount_UserName UNIQUE ([UserName]),
        CONSTRAINT UQ_SystemUserAccount_Email UNIQUE ([Email]),
        CONSTRAINT UQ_SystemUserAccount_EmployeeCode UNIQUE ([EmployeeCode])
    );
    
    -- FK to role table using legacy_role_id
    ALTER TABLE [dbo].[System.UserAccount] WITH CHECK
    ADD CONSTRAINT FK_SystemUserAccount_Role_Legacy
        FOREIGN KEY ([RoleId]) REFERENCES dbo.role(legacy_role_id);
    
    PRINT '✓ Created table: System.UserAccount (Staff/Admin)';
END
GO

/* =========================================================
   4) CUSTOMER TABLE (renamed from 'user')
   For: Online shopping customers
   ========================================================= */
IF OBJECT_ID(N'dbo.customer', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.customer(
        customer_id     uniqueidentifier NOT NULL CONSTRAINT DF_customer_customer_id DEFAULT NEWSEQUENTIALID(),
        user_name       nvarchar(50)     NOT NULL,
        email           nvarchar(150)    NOT NULL,
        [password]      nvarchar(200)    NOT NULL,  -- Should be hashed (bcrypt/argon2)
        full_name       nvarchar(150)    NOT NULL,
        phone_number    nvarchar(50)     NULL,
        [address]       nvarchar(300)    NULL,
        date_of_birth   date             NULL,
        gender          nvarchar(10)     NULL,      -- 'Male', 'Female', 'Other'
        [status]        nvarchar(50)     NOT NULL DEFAULT 'Active',  -- 'Active', 'Inactive', 'Banned'
        email_verified  bit              NOT NULL DEFAULT (0),
        phone_verified  bit              NOT NULL DEFAULT (0),
        loyalty_points  int              NOT NULL DEFAULT (0),
        created_at      datetime2(0)     NOT NULL CONSTRAINT DF_customer_created_at DEFAULT SYSUTCDATETIME(),
        updated_at      datetime2(0)     NOT NULL CONSTRAINT DF_customer_updated_at DEFAULT SYSUTCDATETIME(),
        last_login_at   datetime2(0)     NULL,
        
        CONSTRAINT PK_customer PRIMARY KEY CLUSTERED (customer_id),
        CONSTRAINT UQ_customer_user_name UNIQUE (user_name),
        CONSTRAINT UQ_customer_email UNIQUE (email),
        CONSTRAINT CK_customer_status CHECK ([status] IN ('Active', 'Inactive', 'Banned')),
        CONSTRAINT CK_customer_gender CHECK (gender IN ('Male', 'Female', 'Other', NULL)),
        CONSTRAINT CK_customer_loyalty_points CHECK (loyalty_points >= 0)
    );
    
    PRINT '✓ Created table: customer (Shopping users)';
END
GO

/* =========================================================
   5) PRODUCT CATALOG TABLES
   ========================================================= */

-- 5.1) Categories
IF OBJECT_ID(N'dbo.Categories_TamTM', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categories_TamTM(
        category_id     uniqueidentifier NOT NULL CONSTRAINT DF_Categories_category_id DEFAULT NEWSEQUENTIALID(),
        [name]          nvarchar(200)    NOT NULL,
        [description]   nvarchar(max)    NULL,
        parent_category_id uniqueidentifier NULL,  -- For nested categories
        slug            nvarchar(200)    NULL,
        display_order   int              NULL,
        is_active       bit              NOT NULL CONSTRAINT DF_Categories_is_active DEFAULT (1),
        created_at      datetime2(0)     NOT NULL CONSTRAINT DF_Categories_created_at DEFAULT SYSUTCDATETIME(),
        updated_at      datetime2(0)     NOT NULL CONSTRAINT DF_Categories_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED (category_id),
        CONSTRAINT UQ_Categories_name UNIQUE ([name]),
        CONSTRAINT FK_Categories_parent FOREIGN KEY (parent_category_id) REFERENCES dbo.Categories_TamTM(category_id)
    );
    
    PRINT '✓ Created table: Categories_TamTM';
END
GO

-- 5.2) Brands
IF OBJECT_ID(N'dbo.Brand_TamTM', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Brand_TamTM(
        brand_id        uniqueidentifier NOT NULL CONSTRAINT DF_Brand_brand_id DEFAULT NEWSEQUENTIALID(),
        [name]          nvarchar(200)    NOT NULL,
        [description]   nvarchar(max)    NULL,
        country         nvarchar(100)    NULL,
        logo_url        nvarchar(500)    NULL,
        website_url     nvarchar(500)    NULL,
        slug            nvarchar(200)    NULL,
        is_active       bit              NOT NULL CONSTRAINT DF_Brand_is_active DEFAULT (1),
        created_at      datetime2(0)     NOT NULL CONSTRAINT DF_Brand_created_at DEFAULT SYSUTCDATETIME(),
        updated_at      datetime2(0)     NOT NULL CONSTRAINT DF_Brand_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_Brand PRIMARY KEY CLUSTERED (brand_id),
        CONSTRAINT UQ_Brand_name UNIQUE ([name])
    );
    
    PRINT '✓ Created table: Brand_TamTM';
END
GO

-- 5.3) Products (MAIN TABLE - 16 attributes, 6 datatypes)
IF OBJECT_ID(N'dbo.products_TamTM', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.products_TamTM(
        product_id          uniqueidentifier NOT NULL CONSTRAINT DF_products_product_id DEFAULT NEWSEQUENTIALID(),
        category_id         uniqueidentifier NOT NULL,
        brand_id            uniqueidentifier NOT NULL,
        [name]              nvarchar(250)    NOT NULL,
        product_code        nvarchar(50)     NOT NULL,
        product_type        nvarchar(50)     NOT NULL,  -- 'Frame', 'Lens', 'Sunglasses', 'Accessories'
        short_description   nvarchar(500)    NULL,
        [description]       nvarchar(max)    NULL,
        base_price          decimal(18,2)    NOT NULL,
        is_active           bit              NOT NULL CONSTRAINT DF_products_is_active DEFAULT (1),
        is_featured         bit              NOT NULL CONSTRAINT DF_products_is_featured DEFAULT (0),
        rating_avg          decimal(3,2)     NULL,     -- Calculated from reviews
        review_count        int              NOT NULL DEFAULT (0),
        view_count          int              NOT NULL DEFAULT (0),
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_products_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_products_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_products PRIMARY KEY CLUSTERED (product_id),
        CONSTRAINT UQ_products_product_code UNIQUE (product_code),
        CONSTRAINT FK_products_category FOREIGN KEY (category_id) REFERENCES dbo.Categories_TamTM(category_id),
        CONSTRAINT FK_products_brand FOREIGN KEY (brand_id) REFERENCES dbo.Brand_TamTM(brand_id),
        CONSTRAINT CK_products_base_price CHECK (base_price >= 0),
        CONSTRAINT CK_products_rating_avg CHECK (rating_avg BETWEEN 0 AND 5 OR rating_avg IS NULL),
        CONSTRAINT CK_products_review_count CHECK (review_count >= 0),
        CONSTRAINT CK_products_product_type CHECK (product_type IN ('Frame', 'Lens', 'Sunglasses', 'Accessories'))
    );
    
    PRINT '✓ Created table: products_TamTM (MAIN TABLE - 16 attrs, 6 datatypes)';
END
GO

-- 5.4) Product Variants
IF OBJECT_ID(N'dbo.product_variants_VanHB', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.product_variants_VanHB(
        variant_id           uniqueidentifier NOT NULL CONSTRAINT DF_variants_variant_id DEFAULT NEWSEQUENTIALID(),
        product_id           uniqueidentifier NOT NULL,
        variant_sku          nvarchar(80)     NOT NULL,
        color                nvarchar(80)     NULL,
        size_label           nvarchar(30)     NULL,     -- 'S', 'M', 'L' for frames
        material             nvarchar(80)     NULL,     -- 'Acetate', 'Metal', 'Titanium'
        gender_fit           nvarchar(30)     NULL,     -- 'Unisex', 'Men', 'Women'
        lens_type            nvarchar(50)     NULL,     -- 'Single Vision', 'Progressive', 'Bifocal'
        unit_price           decimal(18,2)    NOT NULL,
        weight_grams         int              NULL,
        is_preorder          bit              NOT NULL CONSTRAINT DF_variants_is_preorder DEFAULT (0),
        preorder_eta_date    date             NULL,
        is_active            bit              NOT NULL CONSTRAINT DF_variants_is_active DEFAULT (1),
        created_at           datetime2(0)     NOT NULL CONSTRAINT DF_variants_created_at DEFAULT SYSUTCDATETIME(),
        updated_at           datetime2(0)     NOT NULL CONSTRAINT DF_variants_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_variants PRIMARY KEY CLUSTERED (variant_id),
        CONSTRAINT UQ_variants_variant_sku UNIQUE (variant_sku),
        CONSTRAINT FK_variants_product FOREIGN KEY (product_id) REFERENCES dbo.products_TamTM(product_id) ON DELETE CASCADE,
        CONSTRAINT CK_variants_unit_price CHECK (unit_price >= 0),
        CONSTRAINT CK_variants_preorder CHECK (
            (is_preorder = 0 AND preorder_eta_date IS NULL) OR
            (is_preorder = 1 AND preorder_eta_date IS NOT NULL)
        )
    );
    
    PRINT '✓ Created table: product_variants_VanHB';
END
GO

-- 5.5) Inventory
IF OBJECT_ID(N'dbo.inventory_VanHB', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.inventory_VanHB(
        inventory_id        uniqueidentifier NOT NULL CONSTRAINT DF_inventory_inventory_id DEFAULT NEWSEQUENTIALID(),
        variant_id          uniqueidentifier NOT NULL,
        on_hand             int              NOT NULL CONSTRAINT DF_inventory_on_hand DEFAULT (0),
        reserved            int              NOT NULL CONSTRAINT DF_inventory_reserved DEFAULT (0),
        available           AS (on_hand - reserved) PERSISTED,  -- Computed column
        reorder_level       int              NULL,
        reorder_quantity    int              NULL,
        warehouse_location  nvarchar(100)    NULL,
        bin_location        nvarchar(50)     NULL,
        last_restock_date   datetime2(0)     NULL,
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_inventory_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_inventory_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_inventory PRIMARY KEY CLUSTERED (inventory_id),
        CONSTRAINT UQ_inventory_variant UNIQUE (variant_id),
        CONSTRAINT FK_inventory_variant FOREIGN KEY (variant_id) REFERENCES dbo.product_variants_VanHB(variant_id) ON DELETE CASCADE,
        CONSTRAINT CK_inventory_on_hand CHECK (on_hand >= 0),
        CONSTRAINT CK_inventory_reserved CHECK (reserved >= 0),
        CONSTRAINT CK_inventory_reserved_not_exceed CHECK (reserved <= on_hand)
    );
    
    PRINT '✓ Created table: inventory_VanHB';
END
GO

-- 5.6) Product Media (FIXED - removed wrong columns)
IF OBJECT_ID(N'dbo.product_media_VanHB', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.product_media_VanHB(
        media_id            uniqueidentifier NOT NULL CONSTRAINT DF_media_media_id DEFAULT NEWSEQUENTIALID(),
        product_id          uniqueidentifier NOT NULL,
        variant_id          uniqueidentifier NULL,  -- NULL = applies to all variants
        media_type          nvarchar(30)     NOT NULL,  -- 'image', 'video', '360_view'
        media_url           nvarchar(500)    NOT NULL,  -- URL or file path
        thumbnail_url       nvarchar(500)    NULL,
        alt_text            nvarchar(200)    NULL,      -- For SEO
        sort_order          int              NULL,
        is_primary          bit              NOT NULL DEFAULT (0),  -- Primary image
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_media_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_media_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_media PRIMARY KEY CLUSTERED (media_id),
        CONSTRAINT FK_media_product FOREIGN KEY (product_id) REFERENCES dbo.products_TamTM(product_id) ON DELETE CASCADE,
        CONSTRAINT FK_media_variant FOREIGN KEY (variant_id) REFERENCES dbo.product_variants_VanHB(variant_id),
        CONSTRAINT CK_media_type CHECK (media_type IN ('image', 'video', '360_view'))
    );
    
    PRINT '✓ Created table: product_media_VanHB (FIXED)';
END
GO

-- 5.7) Product Combo (gọng + tròng) - NEW TABLE
IF OBJECT_ID(N'dbo.product_combo', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.product_combo(
        combo_id            uniqueidentifier NOT NULL CONSTRAINT DF_combo_combo_id DEFAULT NEWSEQUENTIALID(),
        combo_name          nvarchar(200)    NOT NULL,
        combo_code          nvarchar(50)     NOT NULL,
        frame_variant_id    uniqueidentifier NOT NULL,  -- Gọng kính
        lens_variant_id     uniqueidentifier NOT NULL,  -- Tròng kính
        combo_price         decimal(18,2)    NOT NULL,  -- Giá combo (thấp hơn mua lẻ)
        discount_amount     decimal(18,2)    NULL,      -- Số tiền giảm
        discount_percent    decimal(5,2)     NULL,      -- % giảm giá
        [description]       nvarchar(500)    NULL,
        is_active           bit              NOT NULL DEFAULT (1),
        valid_from          datetime2(0)     NULL,
        valid_until         datetime2(0)     NULL,
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_combo_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_combo_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_combo PRIMARY KEY CLUSTERED (combo_id),
        CONSTRAINT UQ_combo_code UNIQUE (combo_code),
        CONSTRAINT FK_combo_frame FOREIGN KEY (frame_variant_id) REFERENCES dbo.product_variants_VanHB(variant_id),
        CONSTRAINT FK_combo_lens FOREIGN KEY (lens_variant_id) REFERENCES dbo.product_variants_VanHB(variant_id),
        CONSTRAINT CK_combo_price CHECK (combo_price >= 0),
        CONSTRAINT CK_combo_discount_percent CHECK (discount_percent BETWEEN 0 AND 100 OR discount_percent IS NULL),
        CONSTRAINT CK_combo_variants_different CHECK (frame_variant_id <> lens_variant_id)
    );
    
    PRINT '✓ Created table: product_combo (NEW)';
END
GO

-- 5.8) Promotions/Discounts - NEW TABLE
IF OBJECT_ID(N'dbo.promotion', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.promotion(
        promotion_id        uniqueidentifier NOT NULL CONSTRAINT DF_promotion_promotion_id DEFAULT NEWSEQUENTIALID(),
        promotion_code      nvarchar(50)     NOT NULL,
        promotion_name      nvarchar(200)    NOT NULL,
        [description]       nvarchar(500)    NULL,
        discount_type       nvarchar(20)     NOT NULL,  -- 'percentage', 'fixed_amount', 'free_shipping'
        discount_value      decimal(18,2)    NOT NULL,  -- % or amount
        min_order_value     decimal(18,2)    NULL,      -- Minimum order to apply
        max_discount_amount decimal(18,2)    NULL,      -- Cap for percentage discount
        start_date          datetime2(0)     NOT NULL,
        end_date            datetime2(0)     NOT NULL,
        max_usage_total     int              NULL,      -- Total times can be used
        max_usage_per_user  int              NULL,      -- Per customer limit
        current_usage       int              NOT NULL DEFAULT (0),
        is_active           bit              NOT NULL DEFAULT (1),
        created_by_staff_id uniqueidentifier NULL,
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_promotion_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_promotion_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_promotion PRIMARY KEY CLUSTERED (promotion_id),
        CONSTRAINT UQ_promotion_code UNIQUE (promotion_code),
        CONSTRAINT FK_promotion_staff FOREIGN KEY (created_by_staff_id) REFERENCES [dbo].[System.UserAccount]([UserAccountID]),
        CONSTRAINT CK_promotion_discount_type CHECK (discount_type IN ('percentage', 'fixed_amount', 'free_shipping')),
        CONSTRAINT CK_promotion_dates CHECK (end_date >= start_date),
        CONSTRAINT CK_promotion_discount_value CHECK (discount_value >= 0),
        CONSTRAINT CK_promotion_usage CHECK (current_usage <= max_usage_total OR max_usage_total IS NULL)
    );
    
    PRINT '✓ Created table: promotion (NEW)';
END
GO

-- 5.9) Product Reviews - NEW TABLE
IF OBJECT_ID(N'dbo.product_review', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.product_review(
        review_id           uniqueidentifier NOT NULL CONSTRAINT DF_review_review_id DEFAULT NEWSEQUENTIALID(),
        product_id          uniqueidentifier NOT NULL,
        customer_id         uniqueidentifier NOT NULL,
        order_id            uniqueidentifier NOT NULL,  -- Must purchase to review
        rating              tinyint          NOT NULL,  -- 1-5 stars
        title               nvarchar(200)    NULL,
        comment             nvarchar(1000)   NULL,
        pros                nvarchar(500)    NULL,
        cons                nvarchar(500)    NULL,
        is_verified         bit              NOT NULL DEFAULT (0),  -- Verified purchase
        is_approved         bit              NOT NULL DEFAULT (0),  -- Staff approval
        approved_by_staff_id uniqueidentifier NULL,
        approved_at         datetime2(0)     NULL,
        helpful_count       int              NOT NULL DEFAULT (0),
        unhelpful_count     int              NOT NULL DEFAULT (0),
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_review_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_review_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_review PRIMARY KEY CLUSTERED (review_id),
        CONSTRAINT FK_review_product FOREIGN KEY (product_id) REFERENCES dbo.products_TamTM(product_id),
        CONSTRAINT FK_review_customer FOREIGN KEY (customer_id) REFERENCES dbo.customer(customer_id),
        CONSTRAINT FK_review_staff FOREIGN KEY (approved_by_staff_id) REFERENCES [dbo].[System.UserAccount]([UserAccountID]),
        CONSTRAINT CK_review_rating CHECK (rating BETWEEN 1 AND 5),
        CONSTRAINT CK_review_helpful_count CHECK (helpful_count >= 0),
        CONSTRAINT CK_review_unhelpful_count CHECK (unhelpful_count >= 0)
    );
    
    -- Note: FK to order_id added after Orders table is created
    
    PRINT '✓ Created table: product_review (NEW)';
END
GO

/* =========================================================
   6) SHOPPING CART
   ========================================================= */

-- 6.1) Cart
IF OBJECT_ID(N'dbo.cart_MinhLK', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.cart_MinhLK(
        cart_id         uniqueidentifier NOT NULL CONSTRAINT DF_cart_cart_id DEFAULT NEWSEQUENTIALID(),
        customer_id     uniqueidentifier NOT NULL,
        [status]        nvarchar(50)     NOT NULL DEFAULT 'Active',  -- 'Active', 'Abandoned', 'Converted'
        session_id      nvarchar(100)    NULL,
        note            nvarchar(500)    NULL,
        created_at      datetime2(0)     NOT NULL CONSTRAINT DF_cart_created_at DEFAULT SYSUTCDATETIME(),
        updated_at      datetime2(0)     NOT NULL CONSTRAINT DF_cart_updated_at DEFAULT SYSUTCDATETIME(),
        expires_at      datetime2(0)     NULL,
        
        CONSTRAINT PK_cart PRIMARY KEY CLUSTERED (cart_id),
        CONSTRAINT FK_cart_customer FOREIGN KEY (customer_id) REFERENCES dbo.customer(customer_id),
        CONSTRAINT CK_cart_status CHECK ([status] IN ('Active', 'Abandoned', 'Converted'))
    );
    
    PRINT '✓ Created table: cart_MinhLK';
END
GO

-- 6.2) Cart Items
IF OBJECT_ID(N'dbo.cart_item_MinhLK', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.cart_item_MinhLK(
        cart_item_id         uniqueidentifier NOT NULL CONSTRAINT DF_cart_item_id DEFAULT NEWSEQUENTIALID(),
        cart_id              uniqueidentifier NOT NULL,
        variant_id           uniqueidentifier NOT NULL,
        combo_id             uniqueidentifier NULL,      -- If buying combo
        quantity             int              NOT NULL,
        unit_price_snapshot  decimal(18,2)    NOT NULL,  -- Price at time of adding
        line_total           AS (quantity * unit_price_snapshot) PERSISTED,
        note                 nvarchar(500)    NULL,
        added_at             datetime2(0)     NOT NULL CONSTRAINT DF_cart_item_added_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_cart_item PRIMARY KEY CLUSTERED (cart_item_id),
        CONSTRAINT FK_cart_item_cart FOREIGN KEY (cart_id) REFERENCES dbo.cart_MinhLK(cart_id) ON DELETE CASCADE,
        CONSTRAINT FK_cart_item_variant FOREIGN KEY (variant_id) REFERENCES dbo.product_variants_VanHB(variant_id),
        CONSTRAINT FK_cart_item_combo FOREIGN KEY (combo_id) REFERENCES dbo.product_combo(combo_id),
        CONSTRAINT CK_cart_item_quantity CHECK (quantity > 0),
        CONSTRAINT CK_cart_item_unit_price CHECK (unit_price_snapshot >= 0)
    );
    
    PRINT '✓ Created table: cart_item_MinhLK';
END
GO

/* =========================================================
   7) ORDERS & PAYMENT
   ========================================================= */

-- 7.1) Orders
IF OBJECT_ID(N'dbo.Orders_NamNH', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders_NamNH(
        order_id            uniqueidentifier NOT NULL CONSTRAINT DF_orders_order_id DEFAULT NEWSEQUENTIALID(),
        customer_id         uniqueidentifier NOT NULL,
        order_code          nvarchar(50)     NOT NULL,
        order_type          nvarchar(50)     NOT NULL,  -- 'Regular', 'Prescription', 'Preorder'
        [status]            nvarchar(50)     NOT NULL,  -- 'Pending', 'Confirmed', 'Processing', 'Shipped', 'Completed', 'Cancelled'
        
        -- Customer info snapshot
        receiver_name       nvarchar(150)    NULL,
        receiver_phone      nvarchar(50)     NULL,
        receiver_email      nvarchar(150)    NULL,
        shipping_address    nvarchar(500)    NULL,
        
        -- Financial breakdown
        subtotal            decimal(18,2)    NOT NULL,
        discount_total      decimal(18,2)    NOT NULL DEFAULT (0),
        tax_total           decimal(18,2)    NOT NULL DEFAULT (0),
        shipping_fee        decimal(18,2)    NOT NULL DEFAULT (0),
        grand_total         decimal(18,2)    NOT NULL,
        
        -- Payment
        payment_method      nvarchar(50)     NULL,  -- 'COD', 'VNPay', 'MoMo', 'BankTransfer'
        payment_status      nvarchar(50)     NOT NULL DEFAULT 'Unpaid',  -- 'Unpaid', 'Paid', 'Refunded'
        
        -- Promotion
        promotion_code      nvarchar(50)     NULL,
        promotion_id        uniqueidentifier NULL,
        
        -- Notes
        customer_note       nvarchar(500)    NULL,
        staff_note          nvarchar(500)    NULL,
        
        -- Timestamps
        order_date          datetime2(0)     NOT NULL CONSTRAINT DF_orders_order_date DEFAULT SYSUTCDATETIME(),
        confirmed_at        datetime2(0)     NULL,
        cancelled_at        datetime2(0)     NULL,
        cancelled_reason    nvarchar(500)    NULL,
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_orders_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_orders_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_orders PRIMARY KEY CLUSTERED (order_id),
        CONSTRAINT UQ_orders_order_code UNIQUE (order_code),
        CONSTRAINT FK_orders_customer FOREIGN KEY (customer_id) REFERENCES dbo.customer(customer_id),
        CONSTRAINT FK_orders_promotion FOREIGN KEY (promotion_id) REFERENCES dbo.promotion(promotion_id),
        CONSTRAINT CK_orders_grand_total CHECK (grand_total >= 0),
        CONSTRAINT CK_orders_subtotal CHECK (subtotal >= 0),
        CONSTRAINT CK_orders_discount_total CHECK (discount_total >= 0),
        CONSTRAINT CK_orders_order_type CHECK (order_type IN ('Regular', 'Prescription', 'Preorder')),
        CONSTRAINT CK_orders_status CHECK ([status] IN ('Pending', 'Confirmed', 'Processing', 'Shipped', 'Completed', 'Cancelled')),
        CONSTRAINT CK_orders_payment_status CHECK (payment_status IN ('Unpaid', 'Paid', 'Refunded'))
    );
    
    PRINT '✓ Created table: Orders_NamNH';
END
GO

-- Add FK from product_review to Orders
IF OBJECT_ID('FK_review_order', 'F') IS NULL
BEGIN
    ALTER TABLE dbo.product_review
    ADD CONSTRAINT FK_review_order FOREIGN KEY (order_id) REFERENCES dbo.Orders_NamNH(order_id);
    
    PRINT '✓ Added FK: product_review -> Orders';
END
GO

-- 7.2) Order Details
IF OBJECT_ID(N'dbo.order_detail_NamNH', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.order_detail_NamNH(
        od_id                   uniqueidentifier NOT NULL CONSTRAINT DF_orderdetail_od_id DEFAULT NEWSEQUENTIALID(),
        order_id                uniqueidentifier NOT NULL,
        variant_id              uniqueidentifier NOT NULL,
        combo_id                uniqueidentifier NULL,
        quantity                int              NOT NULL,
        
        -- Snapshot data (for historical accuracy)
        product_name_snap       nvarchar(250)    NULL,
        variant_desc_snap       nvarchar(250)    NULL,
        unit_price_at_purchased decimal(18,2)    NOT NULL,
        line_total              decimal(18,2)    NOT NULL,
        
        -- Prescription reference
        requires_prescription   bit              NOT NULL DEFAULT (0),
        
        created_at              datetime2(0)     NOT NULL CONSTRAINT DF_orderdetail_created_at DEFAULT SYSUTCDATETIME(),
        updated_at              datetime2(0)     NOT NULL CONSTRAINT DF_orderdetail_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_order_detail PRIMARY KEY CLUSTERED (od_id),
        CONSTRAINT FK_orderdetail_order FOREIGN KEY (order_id) REFERENCES dbo.Orders_NamNH(order_id) ON DELETE CASCADE,
        CONSTRAINT FK_orderdetail_variant FOREIGN KEY (variant_id) REFERENCES dbo.product_variants_VanHB(variant_id),
        CONSTRAINT FK_orderdetail_combo FOREIGN KEY (combo_id) REFERENCES dbo.product_combo(combo_id),
        CONSTRAINT CK_orderdetail_quantity CHECK (quantity > 0),
        CONSTRAINT CK_orderdetail_unit_price CHECK (unit_price_at_purchased >= 0),
        CONSTRAINT CK_orderdetail_line_total CHECK (line_total >= 0)
    );
    
    PRINT '✓ Created table: order_detail_NamNH';
END
GO

-- 7.3) Payments
IF OBJECT_ID(N'dbo.Payments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Payments(
        payment_id              uniqueidentifier NOT NULL CONSTRAINT DF_payments_payment_id DEFAULT NEWSEQUENTIALID(),
        order_id                uniqueidentifier NOT NULL,
        payment_method          nvarchar(50)     NOT NULL,  -- 'COD', 'VNPay', 'MoMo', 'BankTransfer'
        amount                  decimal(18,2)    NOT NULL,
        transaction_code        nvarchar(100)    NULL,
        gateway_transaction_id  nvarchar(150)    NULL,
        bank_code               nvarchar(50)     NULL,
        card_type               nvarchar(30)     NULL,
        [status]                nvarchar(50)     NOT NULL,  -- 'Pending', 'Success', 'Failed', 'Refunded'
        paid_at                 datetime2(0)     NULL,
        refunded_at             datetime2(0)     NULL,
        refund_reason           nvarchar(500)    NULL,
        gateway_response        nvarchar(max)    NULL,      -- JSON response from gateway
        created_at              datetime2(0)     NOT NULL CONSTRAINT DF_payments_created_at DEFAULT SYSUTCDATETIME(),
        updated_at              datetime2(0)     NOT NULL CONSTRAINT DF_payments_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_payments PRIMARY KEY CLUSTERED (payment_id),
        CONSTRAINT FK_payments_order FOREIGN KEY (order_id) REFERENCES dbo.Orders_NamNH(order_id) ON DELETE CASCADE,
        CONSTRAINT CK_payments_amount CHECK (amount >= 0),
        CONSTRAINT CK_payments_status CHECK ([status] IN ('Pending', 'Success', 'Failed', 'Refunded'))
    );
    
    PRINT '✓ Created table: Payments';
END
GO

/* =========================================================
   8) SHIPPING & TRACKING
   ========================================================= */

-- 8.1) Shipping
IF OBJECT_ID(N'dbo.Shipping_NhatHM', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Shipping_NhatHM(
        shipping_id         uniqueidentifier NOT NULL CONSTRAINT DF_shipping_shipping_id DEFAULT NEWSEQUENTIALID(),
        order_id            uniqueidentifier NOT NULL,
        shipping_address    nvarchar(500)    NOT NULL,
        shipping_fee        decimal(18,2)    NULL,
        [status]            nvarchar(50)     NOT NULL,  -- 'Pending', 'Preparing', 'Shipped', 'In Transit', 'Delivered', 'Failed'
        
        -- Carrier info
        tracking_number     nvarchar(100)    NULL,
        carrier             nvarchar(80)     NULL,      -- 'GHN', 'GHTK', 'VNPost', 'J&T'
        service_type        nvarchar(50)     NULL,      -- 'Standard', 'Express'
        
        -- Dates
        estimated_delivery  datetime2(0)     NULL,
        actual_delivery     datetime2(0)     NULL,
        delivered_at        datetime2(0)     NULL,
        
        -- Notes
        shipping_note       nvarchar(500)    NULL,
        delivery_note       nvarchar(500)    NULL,      -- Note from delivery person
        
        -- Receiver info
        received_by         nvarchar(150)    NULL,      -- Who received the package
        
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_shipping_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_shipping_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_shipping PRIMARY KEY CLUSTERED (shipping_id),
        CONSTRAINT FK_shipping_order FOREIGN KEY (order_id) REFERENCES dbo.Orders_NamNH(order_id) ON DELETE CASCADE,
        CONSTRAINT CK_shipping_fee CHECK (shipping_fee >= 0),
        CONSTRAINT CK_shipping_status CHECK ([status] IN ('Pending', 'Preparing', 'Shipped', 'In Transit', 'Delivered', 'Failed'))
    );
    
    PRINT '✓ Created table: Shipping_NhatHM';
END
GO

-- 8.2) Tracking Events
IF OBJECT_ID(N'dbo.tracking_event_NhatHM', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.tracking_event_NhatHM(
        tracking_event_id   uniqueidentifier NOT NULL CONSTRAINT DF_tracking_event_id DEFAULT NEWSEQUENTIALID(),
        shipment_id         uniqueidentifier NOT NULL,
        event_time          datetime2(0)     NOT NULL,
        event_status        nvarchar(50)     NOT NULL,  -- 'Picked Up', 'In Transit', 'Out for Delivery', 'Delivered'
        location            nvarchar(200)    NULL,
        [description]       nvarchar(500)    NULL,
        raw_data            nvarchar(max)    NULL,      -- JSON from carrier API
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_tracking_event_created_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_tracking_event PRIMARY KEY CLUSTERED (tracking_event_id),
        CONSTRAINT FK_tracking_shipment FOREIGN KEY (shipment_id) REFERENCES dbo.Shipping_NhatHM(shipping_id) ON DELETE CASCADE
    );
    
    PRINT '✓ Created table: tracking_event_NhatHM';
END
GO

/* =========================================================
   9) PRESCRIPTION MANAGEMENT
   ========================================================= */

-- 9.1) Prescription
IF OBJECT_ID(N'dbo.prescription_TamBN', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.prescription_TamBN(
        prescription_id         uniqueidentifier NOT NULL CONSTRAINT DF_prescription_id DEFAULT NEWSEQUENTIALID(),
        order_id                uniqueidentifier NOT NULL,
        
        -- PD (Pupillary Distance)
        pd_mm                   int              NULL,      -- Single PD
        pd_right_mm             int              NULL,      -- Right eye PD
        pd_left_mm              int              NULL,      -- Left eye PD
        
        -- Doctor/Clinic info (ENHANCED)
        doctor_name             nvarchar(150)    NULL,
        doctor_license_number   nvarchar(50)     NULL,
        clinic_name             nvarchar(200)    NULL,
        clinic_address          nvarchar(300)    NULL,
        prescription_date       date             NULL,
        prescription_expiry     date             NULL,
        
        -- Upload info
        uploaded_file_url       nvarchar(500)    NULL,
        file_type               nvarchar(30)     NULL,      -- 'PDF', 'Image'
        
        -- Verification
        verify_status           nvarchar(50)     NOT NULL,  -- 'Pending', 'Approved', 'Rejected', 'Clarification_Needed'
        verified_by_staff_id    uniqueidentifier NULL,
        verified_at             datetime2(0)     NULL,
        rejection_reason        nvarchar(500)    NULL,
        
        -- Processing
        note                    nvarchar(500)    NULL,
        started_at              datetime2(0)     NULL,
        completed_at            datetime2(0)     NULL,
        
        created_at              datetime2(0)     NOT NULL CONSTRAINT DF_prescription_created_at DEFAULT SYSUTCDATETIME(),
        updated_at              datetime2(0)     NOT NULL CONSTRAINT DF_prescription_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_prescription PRIMARY KEY CLUSTERED (prescription_id),
        CONSTRAINT FK_prescription_order FOREIGN KEY (order_id) REFERENCES dbo.Orders_NamNH(order_id) ON DELETE CASCADE,
        CONSTRAINT FK_prescription_staff FOREIGN KEY (verified_by_staff_id) REFERENCES [dbo].[System.UserAccount]([UserAccountID]),
        CONSTRAINT CK_prescription_verify_status CHECK (verify_status IN ('Pending', 'Approved', 'Rejected', 'Clarification_Needed')),
        CONSTRAINT CK_prescription_pd CHECK (
            (pd_mm IS NOT NULL AND pd_right_mm IS NULL AND pd_left_mm IS NULL) OR
            (pd_mm IS NULL AND pd_right_mm IS NOT NULL AND pd_left_mm IS NOT NULL)
        )
    );
    
    PRINT '✓ Created table: prescription_TamBN (ENHANCED)';
END
GO

-- 9.2) Prescription Eye Details
IF OBJECT_ID(N'dbo.prescription_eye_details_TamBN', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.prescription_eye_details_TamBN(
        detail_id           uniqueidentifier NOT NULL CONSTRAINT DF_pres_eye_detail_id DEFAULT NEWSEQUENTIALID(),
        prescription_id     uniqueidentifier NOT NULL,
        eye_side            nvarchar(10)     NOT NULL,   -- 'Left', 'Right'
        
        -- Prescription values
        sph                 decimal(6,2)     NULL,       -- Sphere
        cyl                 decimal(6,2)     NULL,       -- Cylinder
        axis                smallint         NULL,       -- Axis (0-180)
        prism               decimal(6,2)     NULL,       -- Prism
        base_direction      nvarchar(20)     NULL,       -- 'In', 'Out', 'Up', 'Down'
        add_power           decimal(6,2)     NULL,       -- Addition (for bifocals/progressives)
        
        -- Visual acuity
        visual_acuity       nvarchar(20)     NULL,       -- e.g., '20/20', '6/6'
        
        note                nvarchar(500)    NULL,
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_pres_eye_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_pres_eye_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_prescription_eye PRIMARY KEY CLUSTERED (detail_id),
        CONSTRAINT FK_pres_eye_prescription FOREIGN KEY (prescription_id) REFERENCES dbo.prescription_TamBN(prescription_id) ON DELETE CASCADE,
        CONSTRAINT CK_pres_eye_side CHECK (eye_side IN ('Left', 'Right')),
        CONSTRAINT CK_pres_eye_axis CHECK (axis BETWEEN 0 AND 180 OR axis IS NULL),
        CONSTRAINT UQ_pres_eye_prescription_side UNIQUE (prescription_id, eye_side)
    );
    
    PRINT '✓ Created table: prescription_eye_details_TamBN';
END
GO

/* =========================================================
   10) WARRANTY MANAGEMENT - NEW TABLE
   ========================================================= */
IF OBJECT_ID(N'dbo.warranty', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.warranty(
        warranty_id         uniqueidentifier NOT NULL CONSTRAINT DF_warranty_id DEFAULT NEWSEQUENTIALID(),
        order_id            uniqueidentifier NOT NULL,
        order_detail_id     uniqueidentifier NOT NULL,
        variant_id          uniqueidentifier NOT NULL,
        
        -- Warranty info
        warranty_type       nvarchar(50)     NOT NULL,  -- 'Manufacturer', 'Extended', 'Frame', 'Lens'
        warranty_period_months int           NOT NULL,  -- Duration in months
        start_date          date             NOT NULL,
        end_date            date             NOT NULL,
        warranty_code       nvarchar(50)     NULL,
        
        -- Status
        [status]            nvarchar(30)     NOT NULL DEFAULT 'Active',  -- 'Active', 'Expired', 'Claimed', 'Void'
        
        -- Claim info
        claim_date          datetime2(0)     NULL,
        claim_description   nvarchar(500)    NULL,
        claim_status        nvarchar(30)     NULL,      -- 'Pending', 'Approved', 'Rejected', 'Completed'
        handled_by_staff_id uniqueidentifier NULL,
        resolution_note     nvarchar(500)    NULL,
        resolved_at         datetime2(0)     NULL,
        
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_warranty_created_at DEFAULT SYSUTCDATETIME(),
        updated_at          datetime2(0)     NOT NULL CONSTRAINT DF_warranty_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_warranty PRIMARY KEY CLUSTERED (warranty_id),
        CONSTRAINT FK_warranty_order FOREIGN KEY (order_id) REFERENCES dbo.Orders_NamNH(order_id),
        CONSTRAINT FK_warranty_order_detail FOREIGN KEY (order_detail_id) REFERENCES dbo.order_detail_NamNH(od_id),
        CONSTRAINT FK_warranty_variant FOREIGN KEY (variant_id) REFERENCES dbo.product_variants_VanHB(variant_id),
        CONSTRAINT FK_warranty_staff FOREIGN KEY (handled_by_staff_id) REFERENCES [dbo].[System.UserAccount]([UserAccountID]),
        CONSTRAINT CK_warranty_dates CHECK (end_date >= start_date),
        CONSTRAINT CK_warranty_status CHECK ([status] IN ('Active', 'Expired', 'Claimed', 'Void')),
        CONSTRAINT CK_warranty_type CHECK (warranty_type IN ('Manufacturer', 'Extended', 'Frame', 'Lens'))
    );
    
    PRINT '✓ Created table: warranty (NEW)';
END
GO

/* =========================================================
   11) RETURN REQUEST
   ========================================================= */
IF OBJECT_ID(N'dbo.return_request', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.return_request(
        return_id               uniqueidentifier NOT NULL CONSTRAINT DF_return_id DEFAULT NEWSEQUENTIALID(),
        order_id                uniqueidentifier NOT NULL,
        customer_id             uniqueidentifier NOT NULL,
        return_code             nvarchar(50)     NOT NULL,
        
        -- Return info
        [status]                nvarchar(50)     NOT NULL,  -- 'Requested', 'Approved', 'Rejected', 'Received', 'Refunded', 'Closed'
        return_type             nvarchar(30)     NOT NULL,  -- 'Refund', 'Exchange'
        reason_code             nvarchar(50)     NULL,      -- 'Defective', 'Wrong_Item', 'Not_As_Described', 'Changed_Mind'
        [description]           nvarchar(500)    NULL,
        
        -- Images/proof
        evidence_image_urls     nvarchar(max)    NULL,      -- JSON array of image URLs
        
        -- Financial
        refund_amount           decimal(18,2)    NULL,
        refund_method           nvarchar(50)     NULL,
        
        -- Dates
        requested_at            datetime2(0)     NOT NULL CONSTRAINT DF_return_requested_at DEFAULT SYSUTCDATETIME(),
        approved_by_staff_id    uniqueidentifier NULL,
        approved_at             datetime2(0)     NULL,
        rejected_reason         nvarchar(500)    NULL,
        received_at             datetime2(0)     NULL,      -- When warehouse receives returned items
        refunded_at             datetime2(0)     NULL,
        closed_at               datetime2(0)     NULL,
        
        created_at              datetime2(0)     NOT NULL CONSTRAINT DF_return_created_at DEFAULT SYSUTCDATETIME(),
        updated_at              datetime2(0)     NOT NULL CONSTRAINT DF_return_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_return PRIMARY KEY CLUSTERED (return_id),
        CONSTRAINT UQ_return_code UNIQUE (return_code),
        CONSTRAINT FK_return_order FOREIGN KEY (order_id) REFERENCES dbo.Orders_NamNH(order_id),
        CONSTRAINT FK_return_customer FOREIGN KEY (customer_id) REFERENCES dbo.customer(customer_id),
        CONSTRAINT FK_return_staff FOREIGN KEY (approved_by_staff_id) REFERENCES [dbo].[System.UserAccount]([UserAccountID]),
        CONSTRAINT CK_return_status CHECK ([status] IN ('Requested', 'Approved', 'Rejected', 'Received', 'Refunded', 'Closed')),
        CONSTRAINT CK_return_type CHECK (return_type IN ('Refund', 'Exchange')),
        CONSTRAINT CK_return_refund_amount CHECK (refund_amount >= 0 OR refund_amount IS NULL)
    );
    
    PRINT '✓ Created table: return_request';
END
GO

-- Return Request Items (detail which items are being returned)
IF OBJECT_ID(N'dbo.return_request_item', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.return_request_item(
        return_item_id      uniqueidentifier NOT NULL CONSTRAINT DF_return_item_id DEFAULT NEWSEQUENTIALID(),
        return_id           uniqueidentifier NOT NULL,
        order_detail_id     uniqueidentifier NOT NULL,
        quantity            int              NOT NULL,
        reason              nvarchar(300)    NULL,
        condition           nvarchar(50)     NULL,      -- 'Unopened', 'Used', 'Damaged'
        
        CONSTRAINT PK_return_item PRIMARY KEY CLUSTERED (return_item_id),
        CONSTRAINT FK_return_item_return FOREIGN KEY (return_id) REFERENCES dbo.return_request(return_id) ON DELETE CASCADE,
        CONSTRAINT FK_return_item_order_detail FOREIGN KEY (order_detail_id) REFERENCES dbo.order_detail_NamNH(od_id),
        CONSTRAINT CK_return_item_quantity CHECK (quantity > 0)
    );
    
    PRINT '✓ Created table: return_request_item';
END
GO

/* =========================================================
   12) PREORDER MANAGEMENT
   ========================================================= */

-- 12.1) Preorder
IF OBJECT_ID(N'dbo.preorder', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.preorder(
        preorder_id             uniqueidentifier NOT NULL CONSTRAINT DF_preorder_id DEFAULT NEWSEQUENTIALID(),
        order_id                uniqueidentifier NOT NULL,
        deposit_amount          decimal(18,2)    NULL,
        deposit_percentage      decimal(5,2)     NULL,      -- % of total
        remaining_amount        decimal(18,2)    NULL,
        expected_arrival_date   date             NULL,
        actual_arrival_date     date             NULL,
        supplier_name           nvarchar(200)    NULL,
        supplier_note           nvarchar(500)    NULL,
        [status]                nvarchar(50)     NOT NULL,  -- 'Pending', 'Deposit_Paid', 'Arrived', 'Ready_For_Pickup', 'Completed', 'Cancelled'
        created_at              datetime2(0)     NOT NULL CONSTRAINT DF_preorder_created_at DEFAULT SYSUTCDATETIME(),
        updated_at              datetime2(0)     NOT NULL CONSTRAINT DF_preorder_updated_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_preorder PRIMARY KEY CLUSTERED (preorder_id),
        CONSTRAINT FK_preorder_order FOREIGN KEY (order_id) REFERENCES dbo.Orders_NamNH(order_id) ON DELETE CASCADE,
        CONSTRAINT CK_preorder_deposit_amount CHECK (deposit_amount >= 0 OR deposit_amount IS NULL),
        CONSTRAINT CK_preorder_status CHECK ([status] IN ('Pending', 'Deposit_Paid', 'Arrived', 'Ready_For_Pickup', 'Completed', 'Cancelled'))
    );
    
    PRINT '✓ Created table: preorder';
END
GO

-- 12.2) Preorder Events
IF OBJECT_ID(N'dbo.preorder_event', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.preorder_event(
        event_id        uniqueidentifier NOT NULL CONSTRAINT DF_preorder_event_id DEFAULT NEWSEQUENTIALID(),
        preorder_id     uniqueidentifier NOT NULL,
        event_type      nvarchar(50)     NOT NULL,  -- 'Status_Change', 'Customer_Notified', 'Delay_Reported'
        [status]        nvarchar(50)     NOT NULL,
        note            nvarchar(500)    NULL,
        created_by_staff_id uniqueidentifier NULL,
        occurred_at     datetime2(0)     NOT NULL CONSTRAINT DF_preorder_event_occurred_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_preorder_event PRIMARY KEY CLUSTERED (event_id),
        CONSTRAINT FK_preorder_event_preorder FOREIGN KEY (preorder_id) REFERENCES dbo.preorder(preorder_id) ON DELETE CASCADE,
        CONSTRAINT FK_preorder_event_staff FOREIGN KEY (created_by_staff_id) REFERENCES [dbo].[System.UserAccount]([UserAccountID])
    );
    
    PRINT '✓ Created table: preorder_event';
END
GO

/* =========================================================
   13) VIRTUAL TRY-ON - NEW TABLE
   ========================================================= */
IF OBJECT_ID(N'dbo.virtual_tryon_session', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.virtual_tryon_session(
        session_id          uniqueidentifier NOT NULL CONSTRAINT DF_tryon_session_id DEFAULT NEWSEQUENTIALID(),
        customer_id         uniqueidentifier NULL,      -- NULL for guest users
        session_token       nvarchar(100)    NULL,      -- For guest tracking
        product_id          uniqueidentifier NOT NULL,
        variant_id          uniqueidentifier NULL,
        
        -- User uploaded face image
        face_image_url      nvarchar(500)    NOT NULL,
        face_measurements   nvarchar(max)    NULL,      -- JSON: face width, IPD, etc.
        
        -- Result
        result_image_url    nvarchar(500)    NULL,
        processing_status   nvarchar(30)     NOT NULL DEFAULT 'Processing',  -- 'Processing', 'Completed', 'Failed'
        
        -- Interaction
        saved_to_favorites  bit              NOT NULL DEFAULT (0),
        added_to_cart       bit              NOT NULL DEFAULT (0),
        
        -- Metadata
        device_type         nvarchar(50)     NULL,      -- 'Mobile', 'Desktop', 'Tablet'
        browser_info        nvarchar(200)    NULL,
        
        created_at          datetime2(0)     NOT NULL CONSTRAINT DF_tryon_created_at DEFAULT SYSUTCDATETIME(),
        expires_at          datetime2(0)     NULL,      -- Auto-delete old sessions
        
        CONSTRAINT PK_tryon_session PRIMARY KEY CLUSTERED (session_id),
        CONSTRAINT FK_tryon_customer FOREIGN KEY (customer_id) REFERENCES dbo.customer(customer_id),
        CONSTRAINT FK_tryon_product FOREIGN KEY (product_id) REFERENCES dbo.products_TamTM(product_id),
        CONSTRAINT FK_tryon_variant FOREIGN KEY (variant_id) REFERENCES dbo.product_variants_VanHB(variant_id),
        CONSTRAINT CK_tryon_status CHECK (processing_status IN ('Processing', 'Completed', 'Failed'))
    );
    
    PRINT '✓ Created table: virtual_tryon_session (NEW)';
END
GO

/* =========================================================
   14) CUSTOMER WISHLIST - BONUS TABLE
   ========================================================= */
IF OBJECT_ID(N'dbo.wishlist', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.wishlist(
        wishlist_id     uniqueidentifier NOT NULL CONSTRAINT DF_wishlist_id DEFAULT NEWSEQUENTIALID(),
        customer_id     uniqueidentifier NOT NULL,
        product_id      uniqueidentifier NOT NULL,
        variant_id      uniqueidentifier NULL,
        note            nvarchar(300)    NULL,
        added_at        datetime2(0)     NOT NULL CONSTRAINT DF_wishlist_added_at DEFAULT SYSUTCDATETIME(),
        
        CONSTRAINT PK_wishlist PRIMARY KEY CLUSTERED (wishlist_id),
        CONSTRAINT FK_wishlist_customer FOREIGN KEY (customer_id) REFERENCES dbo.customer(customer_id) ON DELETE CASCADE,
        CONSTRAINT FK_wishlist_product FOREIGN KEY (product_id) REFERENCES dbo.products_TamTM(product_id),
        CONSTRAINT FK_wishlist_variant FOREIGN KEY (variant_id) REFERENCES dbo.product_variants_VanHB(variant_id),
        CONSTRAINT UQ_wishlist_customer_product UNIQUE (customer_id, product_id, variant_id)
    );
    
    PRINT '✓ Created table: wishlist (BONUS)';
END
GO

/* =========================================================
   15) INDEXES FOR PERFORMANCE - FIXED VERSION
   ========================================================= */

-- Products search
CREATE INDEX IX_products_category_active ON dbo.products_TamTM(category_id, is_active) INCLUDE ([name], base_price);
CREATE INDEX IX_products_brand_active ON dbo.products_TamTM(brand_id, is_active) INCLUDE ([name], base_price);
CREATE INDEX IX_products_featured ON dbo.products_TamTM(is_featured, is_active) WHERE is_featured = 1;
CREATE INDEX IX_products_product_type ON dbo.products_TamTM(product_type, is_active);

-- Orders lookup
CREATE INDEX IX_orders_customer_status ON dbo.Orders_NamNH(customer_id, [status]) INCLUDE (order_code, grand_total, order_date);
CREATE INDEX IX_orders_created_at ON dbo.Orders_NamNH(created_at DESC);
CREATE INDEX IX_orders_status ON dbo.Orders_NamNH([status]) INCLUDE (order_code, customer_id);

-- Inventory tracking
CREATE INDEX IX_inventory_variant ON dbo.inventory_VanHB(variant_id) INCLUDE (on_hand, reserved);
-- REMOVED problematic filtered index: IX_inventory_low_stock
-- Reason: Cannot compare two columns in filtered index WHERE clause
-- Alternative: Use regular index or query with WHERE on_hand <= reorder_level

-- Customer lookup
CREATE INDEX IX_customer_email ON dbo.customer(email);
CREATE INDEX IX_customer_phone ON dbo.customer(phone_number);

-- Reviews
CREATE INDEX IX_review_product_approved ON dbo.product_review(product_id, is_approved) WHERE is_approved = 1;
CREATE INDEX IX_review_customer ON dbo.product_review(customer_id);

-- Cart
CREATE INDEX IX_cart_customer_status ON dbo.cart_MinhLK(customer_id, [status]);

-- Shipping
CREATE INDEX IX_shipping_status ON dbo.Shipping_NhatHM([status]) INCLUDE (tracking_number, order_id);
CREATE INDEX IX_shipping_tracking ON dbo.Shipping_NhatHM(tracking_number);

-- Prescription
CREATE INDEX IX_prescription_order ON dbo.prescription_TamBN(order_id);
CREATE INDEX IX_prescription_verify_status ON dbo.prescription_TamBN(verify_status) WHERE verify_status IN ('Pending', 'Clarification_Needed');

PRINT '✓ Created performance indexes (FIXED)';
GO

/* =========================================================
   16) SEED DATA FOR ROLES
   ========================================================= */

-- Insert default roles
IF NOT EXISTS (SELECT 1 FROM dbo.role WHERE role_name = 'Customer')
BEGIN
    INSERT INTO dbo.role (role_name, legacy_role_id, description)
    VALUES 
        ('Customer', NULL, 'Regular customer shopping on website'),
        ('System Admin', 1, 'Full system access'),
        ('Manager', 2, 'Store manager with management capabilities'),
        ('Sales/Support Staff', 3, 'Handle customer support and sales'),
        ('Operations Staff', 4, 'Handle inventory, orders, shipping');
    
    PRINT '✓ Inserted default roles';
END
GO

/* =========================================================
   17) SUMMARY & STATISTICS
   ========================================================= */

PRINT '';
PRINT '================================================================';
PRINT '  DATABASE CREATION COMPLETED SUCCESSFULLY! (v2 - FIXED)';
PRINT '================================================================';
PRINT '';
PRINT 'Database: GlassStoreDB';
PRINT '';
PRINT '--- FIXES IN v2 ---';
PRINT '✓ Removed problematic filtered index IX_inventory_low_stock';
PRINT '  (Cannot compare two columns in WHERE clause)';
PRINT '';
PRINT '--- KEY IMPROVEMENTS ---';
PRINT '1. Renamed "user" → "customer" for clarity';
PRINT '2. Fixed product_media_VanHB (removed incorrect columns)';
PRINT '3. Added 6 NEW tables: combo, promotion, review, warranty, virtual_tryon, wishlist';
PRINT '4. Enhanced prescription with doctor info';
PRINT '5. Added comprehensive CHECK constraints';
PRINT '6. Created 14+ performance indexes (1 removed)';
PRINT '7. Improved comments and documentation';
PRINT '';
PRINT '--- TABLE COUNT ---';
SELECT 
    'Total Tables' AS [Metric],
    COUNT(*) AS [Count]
FROM sys.tables
WHERE schema_name(schema_id) = 'dbo'
UNION ALL
SELECT 
    'Total Indexes',
    COUNT(*)
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE schema_name(t.schema_id) = 'dbo' AND i.type > 0
UNION ALL
SELECT 
    'Total Foreign Keys',
    COUNT(*)
FROM sys.foreign_keys
WHERE schema_name(schema_id) = 'dbo';

PRINT '';
PRINT '--- MAIN TABLES (10+ attributes) ---';
SELECT 
    t.name AS TableName,
    COUNT(c.column_id) AS AttributeCount,
    COUNT(DISTINCT ty.name) AS DataTypeCount
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE t.schema_id = SCHEMA_ID('dbo')
    AND t.name IN ('products_TamTM', 'Orders_NamNH', 'customer')
GROUP BY t.name
HAVING COUNT(c.column_id) >= 10;

PRINT '';
PRINT '✓ Ready for use!';
PRINT '================================================================';
GO
