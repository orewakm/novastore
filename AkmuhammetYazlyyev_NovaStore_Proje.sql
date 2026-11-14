-- NovaStore E-Ticaret Veri Yönetim Sistemi (SQL Server)
-- Hazırlayan: Akmuhammet Yazlyyev

-- BÖLÜM 1 - 1. Veri tabanı oluşturma (varsa önce silinir, dosya tekrar çalıştırılabilir)
USE master;
GO
IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO
CREATE DATABASE NovaStoreDB COLLATE Turkish_CI_AS;
GO
USE NovaStoreDB;
GO

-- BÖLÜM 1 - 2-A. Categories tablosu
CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) CONSTRAINT PK_Categories PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

-- BÖLÜM 1 - 2-C. Customers tablosu (e-posta benzersiz)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
    FullName   VARCHAR(50),
    City       VARCHAR(20),
    Email      VARCHAR(100) CONSTRAINT UQ_Customers_Email UNIQUE
);

-- BÖLÜM 1 - 2-B. Products tablosu (stok varsayılanı 0)
CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) CONSTRAINT PK_Products PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2),
    Stock       INT CONSTRAINT DF_Products_Stock DEFAULT 0,
    CategoryID  INT CONSTRAINT FK_Products_Categories REFERENCES Categories(CategoryID)
);

-- BÖLÜM 1 - 2-D. Orders tablosu (tarih varsayılanı GETDATE())
CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerID  INT CONSTRAINT FK_Orders_Customers REFERENCES Customers(CustomerID),
    OrderDate   DATETIME CONSTRAINT DF_Orders_OrderDate DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);

-- BÖLÜM 1 - 2-E. OrderDetails ara tablosu
CREATE TABLE OrderDetails (
    DetailID  INT IDENTITY(1,1) CONSTRAINT PK_OrderDetails PRIMARY KEY,
    OrderID   INT CONSTRAINT FK_OrderDetails_Orders REFERENCES Orders(OrderID),
    ProductID INT CONSTRAINT FK_OrderDetails_Products REFERENCES Products(ProductID),
    Quantity  INT
);
GO

-- BÖLÜM 2 - Görev 1: 5 kategori
INSERT INTO Categories (CategoryName) VALUES
('Elektronik'),
('Giyim'),
('Kitap'),
('Kozmetik'),
('Ev ve Yaşam');

-- BÖLÜM 2 - Görev 2: her kategoriden ürün, toplam 12 ürün
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Kablosuz Kulaklık',   1299.90, 35, 1),
('Akıllı Saat',         3499.00, 12, 1),
('Bluetooth Hoparlör',   899.50,  8, 1),
('Erkek Kot Pantolon',   749.90, 40, 2),
('Kadın Mont',          1899.00, 15, 2),
('Suç ve Ceza',          185.00, 60, 3),
('Simyacı',              120.00, 18, 3),
('Sapiens',              245.00, 25, 3),
('Nemlendirici Krem',    349.90, 50, 4),
('Parfüm 100 ml',       1250.00,  6, 4),
('Kahve Makinesi',      2799.00, 10, 5),
('Nevresim Takımı',      899.00, 22, 5);

-- BÖLÜM 2 - Görev 3: 6 müşteri (Elif Arslan henüz sipariş vermedi)
INSERT INTO Customers (FullName, City, Email) VALUES
('Ahmet Yılmaz',  'İstanbul',  'ahmet.yilmaz@example.com'),
('Ayşe Kaya',     'Ankara',    'ayse.kaya@example.com'),
('Mehmet Demir',  'İzmir',     'mehmet.demir@example.com'),
('Zeynep Çelik',  'Bursa',     'zeynep.celik@example.com'),
('Emre Şahin',    'Antalya',   'emre.sahin@example.com'),
('Elif Arslan',   'Eskişehir', 'elif.arslan@example.com');

-- BÖLÜM 2 - Görev 4: farklı tarihlerde 10 sipariş (sonuncusu varsayılan GETDATE() ile)
INSERT INTO Orders (CustomerID, OrderDate) VALUES
(1, '2026-03-12 10:15'),
(2, '2026-04-05 16:40'),
(3, '2026-05-21 09:05'),
(1, '2026-06-18 20:30'),
(4, '2026-07-02 13:10'),
(5, '2026-08-09 11:45'),
(2, '2026-09-14 18:20'),
(3, '2026-10-01 08:55'),
(1, '2026-10-27 22:05');
INSERT INTO Orders (CustomerID) VALUES (4);

-- BÖLÜM 2 - Görev 4: sipariş detayları (sipariş, ürün, adet)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1,  1, 1), (1,  7, 2),
(2,  5, 1),
(3,  2, 1), (3,  3, 1),
(4,  6, 1), (4,  8, 1),
(5,  9, 2), (5, 10, 1),
(6, 11, 1),
(7, 12, 2), (7,  4, 1),
(8,  8, 3),
(9,  2, 1), (9,  9, 1),
(10, 3, 2), (10, 7, 1);

-- BÖLÜM 2 - Görev 4: sipariş toplamları detaylardan hesaplanır (adet x fiyat)
UPDATE o
SET o.TotalAmount = t.Toplam
FROM Orders o
JOIN (
    SELECT od.OrderID, SUM(od.Quantity * p.Price) AS Toplam
    FROM OrderDetails od
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY od.OrderID
) t ON t.OrderID = o.OrderID;
GO

-- BÖLÜM 2 - Kontrol: eklenen veriler
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;
GO

-- BÖLÜM 3 - Soru 1: stoğu 20'den az olan ürünler, stoğa göre azalan
SELECT ProductName AS [Ürün Adı], Stock AS [Stok]
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;

-- BÖLÜM 3 - Soru 2: hangi müşteri hangi tarihte sipariş vermiş
SELECT c.FullName    AS [Müşteri Adı],
       c.City        AS [Şehir],
       o.OrderDate   AS [Sipariş Tarihi],
       o.TotalAmount AS [Toplam Tutar]
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate;

-- BÖLÜM 3 - Soru 3: Ahmet Yılmaz'ın aldığı ürünler, fiyatları ve kategorileri
SELECT p.ProductName    AS [Ürün Adı],
       p.Price          AS [Fiyat],
       cat.CategoryName AS [Kategori]
FROM Customers c
INNER JOIN Orders o        ON o.CustomerID   = c.CustomerID
INNER JOIN OrderDetails od ON od.OrderID     = o.OrderID
INNER JOIN Products p      ON p.ProductID    = od.ProductID
INNER JOIN Categories cat  ON cat.CategoryID = p.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz'
ORDER BY o.OrderDate;

-- BÖLÜM 3 - Soru 4: her kategoride kaç ürün var
SELECT cat.CategoryName   AS [Kategori],
       COUNT(p.ProductID) AS [Ürün Sayısı]
FROM Categories cat
LEFT JOIN Products p ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY [Ürün Sayısı] DESC, [Kategori];

-- BÖLÜM 3 - Soru 5: her müşterinin toplam cirosu, en çok harcayandan en aza
SELECT c.FullName                    AS [Müşteri Adı],
       COUNT(o.OrderID)              AS [Sipariş Sayısı],
       ISNULL(SUM(o.TotalAmount), 0) AS [Toplam Ciro]
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY [Toplam Ciro] DESC;

-- BÖLÜM 3 - Soru 6: siparişlerin üzerinden kaç gün geçti
SELECT OrderID                             AS [Sipariş No],
       OrderDate                           AS [Sipariş Tarihi],
       DATEDIFF(DAY, OrderDate, GETDATE()) AS [Geçen Gün]
FROM Orders
ORDER BY [Geçen Gün] DESC;
GO

-- BÖLÜM 4 - 1. View: müşteri adı, sipariş tarihi, ürün adı ve adet
CREATE OR ALTER VIEW vw_SiparisOzet AS
SELECT c.FullName    AS MusteriAdi,
       o.OrderDate   AS SiparisTarihi,
       p.ProductName AS UrunAdi,
       od.Quantity   AS Adet
FROM Customers c
INNER JOIN Orders o        ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON od.OrderID   = o.OrderID
INNER JOIN Products p      ON p.ProductID  = od.ProductID;
GO

-- BÖLÜM 4 - 1. View'in kullanımı
SELECT * FROM vw_SiparisOzet ORDER BY SiparisTarihi;
GO

-- BÖLÜM 4 - 2. Yedekleme: C:\Yedek\ klasörüne tam yedek
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH INIT, NAME = 'NovaStoreDB Tam Yedek';
GO
