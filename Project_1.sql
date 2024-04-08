-- --------------------------------------------------------------------------------------------------------------
-- Project 1 Kristy Luk
-- --------------------------------------------------------------------------------------------------------------

# CREATING DATA DIMENTSIONS: dim_purchase_order_detail, dim_products, dim_date, and fact_orders

# creating dim_purchase_order_detail
# DROP database `adventureworks_dw`;
CREATE DATABASE adventureworks_dw;

USE adventureworks_dw;

# DROP TABLE `dim_purchase_order_detail`;
CREATE TABLE `dim_purchase_order_detail` (
	`PurchaseOrderDetailID` int NOT NULL AUTO_INCREMENT,
    `DueDate` DATETIME,
    `OrderQty` SMALLINT, 
    `ProductID` INT,
    `UnitPrice` DOUBLE, 
    `ReceivedQty` DECIMAL(8,2),
    `RejectedQty` DECIMAL(8,2),
    `StockedQty` DECIMAL(9,2),
    `ModifiedDate` TIMESTAMP,
    PRIMARY KEY (`PurchaseOrderDetailID`)
) 	ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4;

INSERT INTO `adventureworks_dw`.`dim_purchase_order_detail`
(`PurchaseOrderDetailID`,
`DueDate`,
`OrderQty`,
`ProductID`,
`UnitPrice`,
`ReceivedQty`,
`RejectedQty`,
`StockedQty`,
`ModifiedDate`)
SELECT `PurchaseOrderDetailID`,
	`DueDate`,
	`OrderQty`,
    `ProductID`,
    `UnitPrice`,
    `ReceivedQty`,
    `RejectedQty`,
    `StockedQty`,
    `ModifiedDate`
FROM adventureworks.purchaseorderdetail;

SELECT `purchaseorderdetail`.`PurchaseOrderDetailID`,
    `purchaseorderdetail`.`DueDate`,
    `purchaseorderdetail`.`OrderQty`,
    `purchaseorderdetail`.`ProductID`,
    `purchaseorderdetail`.`UnitPrice`,
    `purchaseorderdetail`.`ReceivedQty`,
    `purchaseorderdetail`.`RejectedQty`,
	`purchaseorderdetail`.`StockedQty`,
    `purchaseorderdetail`.`ModifiedDate`
FROM `adventureworks`.`purchaseorderdetail`;

# validating data was inserted 
SELECT * FROM adventureworks_dw.dim_purchase_order_detail;

# creating dim_products
# DROP TABLE `dim_products`;
CREATE TABLE `dim_products` (
	`ProductKey` int NOT NULL AUTO_INCREMENT,
    `ProductID` INT, 
	`Name` VARCHAR(50) DEFAULT NULL, 
	`ProductNumber` VARCHAR(25) DEFAULT NULL, 
	`StandardCost` DOUBLE, 
    `ListPrice` DOUBLE, 
    `Size` VARCHAR(5) DEFAULT NULL, 
    `Weight` DECIMAL(8,2),
    `DaysToManufacture` INT, 
    `SellStartDate` DATETIME, 
    `SellEndDate` DATETIME, 
    PRIMARY KEY (`ProductKey`),
	KEY `ProductID` (`ProductID`)
) 	ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4;

INSERT INTO `adventureworks_dw`.`dim_products`
(`ProductID`,
`Name`,
`ProductNumber`,
`StandardCost`, 
`ListPrice`,
`Size`, 
`Weight`,
`DaysToManufacture`,
`SellStartDate`,
`SellEndDate`)
SELECT `ProductID`,
	`Name`,
	`ProductNumber`,
	`StandardCost`, 
	`ListPrice`,
	`Size`, 
	`Weight`,
	`DaysToManufacture`,
	`SellStartDate`,
	`SellEndDate`
FROM adventureworks.product;

SELECT `product`.`ProductID`,
    `product`.`Name`,
    `product`.`ProductNumber`,
    `product`.`StandardCost`, 
    `product`.`ListPrice`,
    `product`.`Size`,
    `product`.`Weight`,
    `product`.`DaysToManufacture`,
    `product`.`SellStartDate`,
    `product`.`SellEndDate`
FROM `adventureworks`.`product`;
    
# validating data was inserted 
SELECT * FROM adventureworks_dw.dim_products;

# creating dim_date
USE adventureworks_dw;

DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date(
 date_key int NOT NULL,
 full_date date NULL,
 date_name char(11) NOT NULL,
 date_name_us char(11) NOT NULL,
 date_name_eu char(11) NOT NULL,
 day_of_week tinyint NOT NULL,
 day_name_of_week char(10) NOT NULL,
 day_of_month tinyint NOT NULL,
 day_of_year smallint NOT NULL,
 weekday_weekend char(10) NOT NULL,
 week_of_year tinyint NOT NULL,
 month_name char(10) NOT NULL,
 month_of_year tinyint NOT NULL,
 is_last_day_of_month char(1) NOT NULL,
 calendar_quarter tinyint NOT NULL,
 calendar_year smallint NOT NULL,
 calendar_year_month char(10) NOT NULL,
 calendar_year_qtr char(10) NOT NULL,
 fiscal_month_of_year tinyint NOT NULL,
 fiscal_quarter tinyint NOT NULL,
 fiscal_year int NOT NULL,
 fiscal_year_month char(10) NOT NULL,
 fiscal_year_qtr char(10) NOT NULL,
  PRIMARY KEY (`date_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# the PopulateDateDimension Stored Procedure: 
delimiter //

DROP PROCEDURE IF EXISTS PopulateDateDimension//
CREATE PROCEDURE PopulateDateDimension(BeginDate DATETIME, EndDate DATETIME)
BEGIN

	DECLARE LastDayOfMon CHAR(1);

	DECLARE FiscalYearMonthsOffset INT;

	DECLARE DateCounter DATETIME;    
	DECLARE FiscalCounter DATETIME;  

	SET FiscalYearMonthsOffset = 6;

	SET DateCounter = BeginDate;

	WHILE DateCounter <= EndDate DO

		SET FiscalCounter = DATE_ADD(DateCounter, INTERVAL FiscalYearMonthsOffset MONTH);

		IF MONTH(DateCounter) = MONTH(DATE_ADD(DateCounter, INTERVAL 1 DAY)) THEN
			SET LastDayOfMon = 'N';
		ELSE
			SET LastDayOfMon = 'Y';
		END IF;

		INSERT INTO dim_date
			(date_key
			, full_date
			, date_name
			, date_name_us
			, date_name_eu
			, day_of_week
			, day_name_of_week
			, day_of_month
			, day_of_year
			, weekday_weekend
			, week_of_year
			, month_name
			, month_of_year
			, is_last_day_of_month
			, calendar_quarter
			, calendar_year
			, calendar_year_month
			, calendar_year_qtr
			, fiscal_month_of_year
			, fiscal_quarter
			, fiscal_year
			, fiscal_year_month
			, fiscal_year_qtr)
		VALUES  (
			( YEAR(DateCounter) * 10000 ) + ( MONTH(DateCounter) * 100 ) + DAY(DateCounter)  #DateKey
			, DateCounter #FullDate
			, CONCAT(CAST(YEAR(DateCounter) AS CHAR(4)),'/', DATE_FORMAT(DateCounter,'%m'),'/', DATE_FORMAT(DateCounter,'%d')) #DateName
			, CONCAT(DATE_FORMAT(DateCounter,'%m'),'/', DATE_FORMAT(DateCounter,'%d'),'/', CAST(YEAR(DateCounter) AS CHAR(4)))#DateNameUS
			, CONCAT(DATE_FORMAT(DateCounter,'%d'),'/', DATE_FORMAT(DateCounter,'%m'),'/', CAST(YEAR(DateCounter) AS CHAR(4)))#DateNameEU
			, DAYOFWEEK(DateCounter) #DayOfWeek
			, DAYNAME(DateCounter) #DayNameOfWeek
			, DAYOFMONTH(DateCounter) #DayOfMonth
			, DAYOFYEAR(DateCounter) #DayOfYear
			, CASE DAYNAME(DateCounter)
				WHEN 'Saturday' THEN 'Weekend'
				WHEN 'Sunday' THEN 'Weekend'
				ELSE 'Weekday'
			END #WeekdayWeekend
			, WEEKOFYEAR(DateCounter) #WeekOfYear
			, MONTHNAME(DateCounter) #MonthName
			, MONTH(DateCounter) #MonthOfYear
			, LastDayOfMon #IsLastDayOfMonth
			, QUARTER(DateCounter) #CalendarQuarter
			, YEAR(DateCounter) #CalendarYear
			, CONCAT(CAST(YEAR(DateCounter) AS CHAR(4)),'-',DATE_FORMAT(DateCounter,'%m')) #CalendarYearMonth
			, CONCAT(CAST(YEAR(DateCounter) AS CHAR(4)),'Q',QUARTER(DateCounter)) #CalendarYearQtr
			, MONTH(FiscalCounter) #[FiscalMonthOfYear]
			, QUARTER(FiscalCounter) #[FiscalQuarter]
			, YEAR(FiscalCounter) #[FiscalYear]
			, CONCAT(CAST(YEAR(FiscalCounter) AS CHAR(4)),'-',DATE_FORMAT(FiscalCounter,'%m')) #[FiscalYearMonth]
			, CONCAT(CAST(YEAR(FiscalCounter) AS CHAR(4)),'Q',QUARTER(FiscalCounter)) #[FiscalYearQtr]
		);

		SET DateCounter = DATE_ADD(DateCounter, INTERVAL 1 DAY);
	END WHILE;
END//

CALL PopulateDateDimension('1998/01/01', '2003/12/31');

SELECT MIN(full_date) AS BeginDate
	, MAX(full_date) AS EndDate
FROM dim_date;

# making fact_orders table 
USE adventureworks_dw;

# DROP TABLE `fact_orders`;

CREATE TABLE `fact_orders` (
  `PurchaseOrderDetailID` int NOT NULL AUTO_INCREMENT,
  `ProductID` int DEFAULT NULL,
  `Size` VARCHAR(5) DEFAULT NULL,
  `Weight` DECIMAL(8,2),
  `DueDate` DATETIME, 
  `OrderQty` SMALLINT, 
  `StandardCost` DOUBLE, 
  `ListPrice` DOUBLE, 
  `UnitPrice` DOUBLE, 
  `DaysToManufacture` INT, 
  `ReceivedQty` DECIMAL(8,2),
  `RejectedQty` DECIMAL(8,2),
  `StockedQty` DECIMAL(9,2),
  `ModifiedDate` TIMESTAMP,
  PRIMARY KEY (`PurchaseOrderDetailID`),
  KEY `ProductID` (`ProductID`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4;

INSERT INTO `adventureworks_dw`.`fact_orders`
(`PurchaseOrderDetailID`,
`ProductID`,
`Size`,
`Weight`,
`DueDate`,
`OrderQty`,
`StandardCost`,
`ListPrice`,
`UnitPrice`,
`DaysToManufacture`,
`ReceivedQty`,
`RejectedQty`,
`StockedQty`,
`ModifiedDate`)
SELECT 
    pod.PurchaseOrderDetailID,
    p.ProductID,
	p.Size,
    p.Weight,
    pod.DueDate, 
    pod.OrderQty,
    p.StandardCost,
    p.ListPrice,
    pod.UnitPrice,
    p.DaysToManufacture,
    pod.ReceivedQty, 
    pod.ReceivedQty,
    pod.StockedQty,
    pod.ModifiedDate
FROM adventureworks_dw.dim_products p
NATURAL JOIN adventureworks_dw.dim_purchase_order_detail pod;

# validating data was inserted 
SELECT * FROM adventureworks_dw.fact_orders;


# SELECT STATEMENTS TO VALIDATE FUNCTIONALITY

# dim_purchase_order_detail: counting the total order quantity depending on what the stocked quantity is of a particular project
SELECT StockedQty
	, SUM(OrderQty) as total_order_qty 
FROM adventureworks_dw.dim_purchase_order_detail 
GROUP BY StockedQty;


# dim_products: finding the average weight of products grouped by the days it took to manufacture the item 
SELECT DaysToManufacture 
	, AVG(Weight) as avg_weight
FROM adventureworks_dw.dim_products
GROUP BY DaysToManufacture;

# fact_orders: selecting all the different types of products and finding the total order quantity and the average price 
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    SUM(od.OrderQty) AS TotalOrderQty,
    AVG(od.UnitPrice) AS AverageUnitPrice
FROM 
    adventureworks_dw.dim_products p
JOIN 
    adventureworks_dw.dim_purchase_order_detail od ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductID, p.Name;

