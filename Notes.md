# Notes

## 1. Database Schemas

The database is divided into four main schemas to organize tables based on their responsibilities:

- **Core:** Contains `Country`, `City`, `Member`, and `Wallet`. It stores the main member and location information.
- **Operations:** Contains `Warehouse` and `Employee`. It manages warehouse and employee information.
- **Catalog:** Contains `Category`, `Item`, and `ItemPhoto`. It manages listed items, their categories, and photos.
- **Auctions:** Contains `Auction` and `Bid`. It handles auctions and bidding operations.

`AuctionFollow` was later moved to a separate `Marketing` schema to keep auction-following functionality separate.

## 2. Relationship Types

- **One-to-One (1:1):** `Member` and `Wallet`. Implemented using a foreign key in `Wallet` referencing `Member`, with a `UNIQUE` constraint on `MemberID`.
- **One-to-Many (1:N):** `Country` and `City`. Implemented using `CountryCode` as a foreign key in `City`.
- **Many-to-Many (M:N):** `Member` and `Auction`. Implemented using the junction table `AuctionFollow`, which contains foreign keys to both tables and a composite primary key.
- **Recursive Relationship:** `Member` can invite another member through `InvitedByMemberID`, which references `MemberID` in the same table. `Category` also has a recursive relationship through `ParentCategoryID`.
- **Circular Relationship:** `Warehouse` and `Employee`. `Warehouse.ManagerEmployeeID` references `Employee.EmployeeID`, while `Employee.WarehouseID` references `Warehouse.WarehouseID`.
- **Weak Entity:** `ItemPhoto` depends on `Item`. It uses a composite primary key (`ItemID`, `PhotoPosition`) and a foreign key referencing `Item`.

## 3. Data Type Choices

- **UNIQUEIDENTIFIER for MemberID:** Provides globally unique identifiers for members.
- **BIGINT for BidID:** Supports a large number of bid records.
- **FLOAT for GPS coordinates:** Suitable for approximate geographic coordinates.
- **DECIMAL(12,2) for monetary values:** Provides exact decimal precision, avoiding floating-point rounding issues.
- **DATETIMEOFFSET for auction dates:** Stores date and time together with the UTC offset.

## 4. Circular Relationship Creation

A circular relationship cannot be created directly when both tables are being created because each table references the other before the referenced table exists.

To solve this, both tables are created first without the circular foreign keys. Then, the foreign keys are added using `ALTER TABLE` after both tables exist.

## 5. Errors and Fixes

### Task 3.6 – Modify MaxItems

The `MaxItems` column was associated with a `CHECK` constraint named `CK_Warehouse_MaxItems`.

SQL Server prevented changing the column's data type while the constraint was dependent on it.

**Fix:** Drop the constraint temporarily, modify the column's data type, then recreate the constraint.

### Task 3.11 – Replace IsVerified with VerifiedAt

The `IsVerified` column had a `DEFAULT` constraint named `DF_Member_IsVerified`.

SQL Server prevented dropping the column while its default constraint was still attached.

**Fix:** Drop `DF_Member_IsVerified` first, then drop the `IsVerified` column after adding the nullable `VerifiedAt` column.

## 6. Task 5 – Product of Array Except Self

**Input:**
`[1, 2, 3, 4]`

**Prefix Array:**
`[1, 1, 2, 6]`

**Suffix Array:**
`[24, 12, 4, 1]`

**Output:**
`[24, 12, 8, 6]`

Each output element is calculated by multiplying the product of all elements to its left by the product of all elements to its right.

- **Time Complexity:** O(n)
- **Space Complexity:** O(n) for the prefix/suffix solution.
- **Optimized Space Complexity:** O(1) extra space, excluding the output array.