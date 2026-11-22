
-- Create Database
CREATE DATABASE BidNile;
GO

USE BidNile;
GO

-- Create Schemas
CREATE SCHEMA Core;
GO

CREATE SCHEMA Operations;
GO

CREATE SCHEMA Catalog;
GO

CREATE SCHEMA Auctions;
GO

USE BidNile;
GO

CREATE TABLE Core.Country
(
    CountryCode CHAR(2) NOT NULL,
    NameEn NVARCHAR(100) NOT NULL,
    NameAr NVARCHAR(100) NOT NULL,
    PhoneCode VARCHAR(5) NOT NULL,

    CONSTRAINT PK_Country
        PRIMARY KEY (CountryCode)
);
GO
CREATE TABLE Core.City
(
    CityID INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(60) NOT NULL,
    CountryCode CHAR(2) NOT NULL,

    CONSTRAINT PK_City
        PRIMARY KEY (CityID),

    CONSTRAINT UQ_City_Name_CountryCode
        UNIQUE (Name, CountryCode)
);
GO
CREATE TABLE Core.Member
(
    MemberID UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT DF_Member_MemberID DEFAULT NEWID(),

    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(254) NOT NULL,
    Mobile VARCHAR(16) NOT NULL,
    NationalID VARCHAR(20) NOT NULL,
    BirthDate DATE NOT NULL,

    IsVerified BIT NOT NULL
        CONSTRAINT DF_Member_IsVerified DEFAULT 0,

    RegisteredAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Member_RegisteredAt DEFAULT SYSDATETIME(),

    CityID INT NOT NULL,
    InvitedByMemberID UNIQUEIDENTIFIER NULL,

    CONSTRAINT PK_Member
        PRIMARY KEY (MemberID),

    CONSTRAINT UQ_Member_Email
        UNIQUE (Email),

    CONSTRAINT UQ_Member_NationalID
        UNIQUE (NationalID)
);
GO
CREATE TABLE Core.Wallet
(
    WalletID INT IDENTITY(1,1) NOT NULL,
    MemberID UNIQUEIDENTIFIER NOT NULL,

    Balance DECIMAL(12,2) NOT NULL,
    HeldAmount DECIMAL(12,2) NOT NULL,

    Currency CHAR(3) NOT NULL
        CONSTRAINT DF_Wallet_Currency DEFAULT 'EGP',

    LastUpdatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Wallet_LastUpdatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Wallet
        PRIMARY KEY (WalletID),

    CONSTRAINT UQ_Wallet_MemberID
        UNIQUE (MemberID),

    CONSTRAINT CK_Wallet_Balance
        CHECK (Balance >= 0),

    CONSTRAINT CK_Wallet_HeldAmount
        CHECK (HeldAmount >= 0),

    CONSTRAINT CK_Wallet_HeldAmount_Balance
        CHECK (HeldAmount <= Balance)
);
GO
CREATE TABLE Operations.Warehouse
(
    WarehouseID INT IDENTITY(1,1) NOT NULL,
    WarehouseName NVARCHAR(80) NOT NULL,
    Capacity INT NOT NULL,
    CityID INT NOT NULL,

    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,

    ManagerEmployeeID UNIQUEIDENTIFIER NOT NULL,
    ManagementStartDate DATE NOT NULL,

    CONSTRAINT PK_Warehouse
        PRIMARY KEY (WarehouseID),

    CONSTRAINT UQ_Warehouse_WarehouseName
        UNIQUE (WarehouseName),

    CONSTRAINT UQ_Warehouse_ManagerEmployeeID
        UNIQUE (ManagerEmployeeID),

    CONSTRAINT CK_Warehouse_Capacity
        CHECK (Capacity > 0),

    CONSTRAINT CK_Warehouse_Latitude
        CHECK (Latitude BETWEEN -90 AND 90),

    CONSTRAINT CK_Warehouse_Longitude
        CHECK (Longitude BETWEEN -180 AND 180)
);
GO
CREATE TABLE Operations.Employee
(
    EmployeeID UNIQUEIDENTIFIER NOT NULL,
    WarehouseID INT NOT NULL,

    CONSTRAINT PK_Employee
        PRIMARY KEY (EmployeeID)
);
GO
CREATE TABLE Catalog.Category
(
    CategoryID INT NOT NULL,
    ParentCategoryID INT NULL,

    NameEn NVARCHAR(100) NOT NULL,
    NameAr NVARCHAR(50) NULL,

    CommissionRate DECIMAL(5,2) NOT NULL,

    CONSTRAINT PK_Category
        PRIMARY KEY (CategoryID),

    CONSTRAINT UQ_Category_NameEn
        UNIQUE (NameEn),

    CONSTRAINT CK_Category_CommissionRate
        CHECK (CommissionRate BETWEEN 0 AND 30)
);
GO
CREATE TABLE Catalog.Item
(
    ItemID INT IDENTITY(1,1) NOT NULL,

    SellerMemberID UNIQUEIDENTIFIER NOT NULL,
    InspectorEmployeeID UNIQUEIDENTIFIER NOT NULL,

    CategoryID INT NOT NULL,
    WarehouseID INT NULL,

    Title NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX) NULL,

    ConditionScore TINYINT NOT NULL,
    Specifications NVARCHAR(MAX) NOT NULL,

    ListedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Item_ListedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Item
        PRIMARY KEY (ItemID),

    CONSTRAINT CK_Item_ConditionScore
        CHECK (ConditionScore BETWEEN 1 AND 10),

    CONSTRAINT CK_Item_Specifications
        CHECK (ISJSON(Specifications) = 1),

    CONSTRAINT CK_Item_Seller_Inspector
        CHECK (SellerMemberID <> InspectorEmployeeID)
);
GO
CREATE TABLE Catalog.ItemPhoto
(
    ItemID INT NOT NULL,
    PhotoPosition TINYINT NOT NULL,

    PhotoURL VARCHAR(500) NOT NULL,

    IsMain BIT NOT NULL
        CONSTRAINT DF_ItemPhoto_IsMain DEFAULT 0,

    CONSTRAINT PK_ItemPhoto
        PRIMARY KEY (ItemID, PhotoPosition),

    CONSTRAINT CK_ItemPhoto_PhotoPosition
        CHECK (PhotoPosition BETWEEN 1 AND 20)
);
GO
CREATE TABLE Auctions.Auction
(
    AuctionID INT IDENTITY(1,1) NOT NULL,
    ItemID INT NOT NULL,

    StartingPrice DECIMAL(12,2) NOT NULL,
    ReservePrice DECIMAL(12,2) NULL,

    BidIncrement DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Auction_BidIncrement DEFAULT 50.00,

    StartAt DATETIMEOFFSET NOT NULL,
    EndAt DATETIMEOFFSET NOT NULL,

    Status VARCHAR(20) NOT NULL
        CONSTRAINT DF_Auction_Status DEFAULT 'Draft',

    CONSTRAINT PK_Auction
        PRIMARY KEY (AuctionID),

    CONSTRAINT CK_Auction_StartingPrice
        CHECK (StartingPrice > 0),

    CONSTRAINT CK_Auction_ReservePrice
        CHECK (ReservePrice IS NULL OR ReservePrice >= StartingPrice),

    CONSTRAINT CK_Auction_BidIncrement
        CHECK (BidIncrement > 0),

    CONSTRAINT CK_Auction_EndAt
        CHECK (EndAt > StartAt),

    CONSTRAINT CK_Auction_Status
        CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled'))
);
GO
CREATE TABLE Auctions.Bid
(
    BidID BIGINT IDENTITY(1,1) NOT NULL,

    AuctionID INT NOT NULL,
    MemberID UNIQUEIDENTIFIER NOT NULL,

    Amount DECIMAL(12,2) NOT NULL,

    PlacedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Bid_PlacedAt DEFAULT SYSDATETIME(),

    IP VARCHAR(45) NOT NULL,

    CONSTRAINT PK_Bid
        PRIMARY KEY (BidID),

    CONSTRAINT UQ_Bid_AuctionID_Amount
        UNIQUE (AuctionID, Amount),

    CONSTRAINT CK_Bid_Amount
        CHECK (Amount > 0)
);
GO
CREATE TABLE Auctions.AuctionFollow
(
    MemberID UNIQUEIDENTIFIER NOT NULL,
    AuctionID INT NOT NULL,

    FollowedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_AuctionFollow_FollowedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_AuctionFollow
        PRIMARY KEY (MemberID, AuctionID)
);
GO
ALTER TABLE Core.City
ADD CONSTRAINT FK_City_Country
FOREIGN KEY (CountryCode)
REFERENCES Core.Country (CountryCode);
GO
ALTER TABLE Core.Member
ADD CONSTRAINT FK_Member_City
FOREIGN KEY (CityID)
REFERENCES Core.City (CityID);
GO
ALTER TABLE Core.Member
ADD CONSTRAINT FK_Member_InvitedByMember
FOREIGN KEY (InvitedByMemberID)
REFERENCES Core.Member (MemberID);
GO
ALTER TABLE Core.Wallet
ADD CONSTRAINT FK_Wallet_Member
FOREIGN KEY (MemberID)
REFERENCES Core.Member (MemberID);
GO
ALTER TABLE Operations.Warehouse
ADD CONSTRAINT FK_Warehouse_City
FOREIGN KEY (CityID)
REFERENCES Core.City (CityID);
GO
ALTER TABLE Operations.Employee
ADD CONSTRAINT FK_Employee_Member
FOREIGN KEY (EmployeeID)
REFERENCES Core.Member (MemberID);
GO
ALTER TABLE Operations.Employee
ADD CONSTRAINT FK_Employee_Warehouse
FOREIGN KEY (WarehouseID)
REFERENCES Operations.Warehouse (WarehouseID);
GO
ALTER TABLE Operations.Warehouse
ADD CONSTRAINT FK_Warehouse_ManagerEmployee
FOREIGN KEY (ManagerEmployeeID)
REFERENCES Operations.Employee (EmployeeID);
GO
ALTER TABLE Catalog.Category
ADD CONSTRAINT FK_Category_ParentCategory
FOREIGN KEY (ParentCategoryID)
REFERENCES Catalog.Category (CategoryID);
GO
ALTER TABLE Catalog.Item
ADD CONSTRAINT FK_Item_SellerMember
FOREIGN KEY (SellerMemberID)
REFERENCES Core.Member (MemberID);
GO
ALTER TABLE Catalog.Item
ADD CONSTRAINT FK_Item_InspectorEmployee
FOREIGN KEY (InspectorEmployeeID)
REFERENCES Operations.Employee (EmployeeID);
GO
ALTER TABLE Catalog.Item
ADD CONSTRAINT FK_Item_Category
FOREIGN KEY (CategoryID)
REFERENCES Catalog.Category (CategoryID);
GO
ALTER TABLE Catalog.Item
ADD CONSTRAINT FK_Item_Warehouse
FOREIGN KEY (WarehouseID)
REFERENCES Operations.Warehouse (WarehouseID);
GO
ALTER TABLE Catalog.ItemPhoto
ADD CONSTRAINT FK_ItemPhoto_Item
FOREIGN KEY (ItemID)
REFERENCES Catalog.Item (ItemID)
ON DELETE CASCADE;
GO
ALTER TABLE Auctions.Auction
ADD CONSTRAINT FK_Auction_Item
FOREIGN KEY (ItemID)
REFERENCES Catalog.Item (ItemID);
GO
ALTER TABLE Auctions.Bid
ADD CONSTRAINT FK_Bid_Auction
FOREIGN KEY (AuctionID)
REFERENCES Auctions.Auction (AuctionID);
GO
ALTER TABLE Auctions.Bid
ADD CONSTRAINT FK_Bid_Member
FOREIGN KEY (MemberID)
REFERENCES Core.Member (MemberID);
GO
ALTER TABLE Auctions.AuctionFollow
ADD CONSTRAINT FK_AuctionFollow_Member
FOREIGN KEY (MemberID)
REFERENCES Core.Member (MemberID);
GO
ALTER TABLE Auctions.AuctionFollow
ADD CONSTRAINT FK_AuctionFollow_Auction
FOREIGN KEY (AuctionID)
REFERENCES Auctions.Auction (AuctionID);
GO
ALTER TABLE Core.Member
ADD AppLanguage CHAR(2) NOT NULL
    CONSTRAINT DF_Member_AppLanguage DEFAULT 'ar'
    CONSTRAINT CK_Member_AppLanguage CHECK (AppLanguage IN ('ar', 'en'));
GO
ALTER TABLE Catalog.Item
ADD IsFeatured BIT NOT NULL
    CONSTRAINT DF_Item_IsFeatured DEFAULT 0;
GO
EXEC sp_rename
    'Auctions.Bid.IP',
    'DeviceIp',
    'COLUMN';
GO
EXEC sp_rename
    'Operations.Warehouse.Capacity',
    'MaxItems',
    'COLUMN';
GO
ALTER TABLE Operations.Warehouse
DROP CONSTRAINT CK_Warehouse_Capacity;
GO

EXEC sp_rename
    'Operations.Warehouse.Capacity',
    'MaxItems',
    'COLUMN';
GO

ALTER TABLE Operations.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);
GO
ALTER TABLE Core.Member
ALTER COLUMN FullName NVARCHAR(150) NOT NULL;
GO
ALTER TABLE Operations.Warehouse
ALTER COLUMN MaxItems SMALLINT NOT NULL;
GO
ALTER TABLE Operations.Warehouse
DROP CONSTRAINT CK_Warehouse_MaxItems;
GO

ALTER TABLE Operations.Warehouse
ALTER COLUMN MaxItems SMALLINT NOT NULL;
GO

ALTER TABLE Operations.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);
GO
ALTER TABLE Catalog.Category
DROP CONSTRAINT CK_Category_CommissionRate;
GO

ALTER TABLE Catalog.Category
ADD CONSTRAINT CK_Category_CommissionRate
CHECK (CommissionRate BETWEEN 0 AND 25);
GO
ALTER TABLE Auctions.Auction
DROP CONSTRAINT CK_Auction_Status;
GO

ALTER TABLE Auctions.Auction
ADD CONSTRAINT CK_Auction_Status
CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled', 'PendingReview'));
GO

ALTER TABLE Auctions.Auction
DROP CONSTRAINT DF_Auction_Status;
GO

ALTER TABLE Auctions.Auction
ADD CONSTRAINT DF_Auction_Status
DEFAULT 'PendingReview' FOR Status;
GO
ALTER TABLE Auctions.Auction
ADD BuyNowPrice DECIMAL(12,2) NULL;
GO

ALTER TABLE Auctions.Auction
WITH CHECK
ADD CONSTRAINT CK_Auction_BuyNowPrice
CHECK (BuyNowPrice IS NULL OR BuyNowPrice > StartingPrice);
GO
ALTER TABLE Core.Member
ADD CONSTRAINT UQ_Member_Mobile
UNIQUE (Mobile);
GO
ALTER TABLE Core.Member
ADD VerifiedAt DATETIME2(3) NULL;
GO

ALTER TABLE Core.Member
DROP CONSTRAINT DF_Member_IsVerified;
GO

ALTER TABLE Core.Member
DROP COLUMN IsVerified;
GO
CREATE SCHEMA Marketing;
GO
ALTER SCHEMA Marketing
TRANSFER Auctions.AuctionFollow;
GO

