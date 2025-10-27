CREATE DATABASE WareHouseManagement;
USE WareHouseManagement;

CREATE TABLE Products (
	product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    supplier_id INT,
    ReorderLevel INT,
    FOREIGN KEY (supplier_id) REFERENCES  Suppliers(supplier_id)
);
SELECT * FROM Products;
CREATE TABLE Suppliers(
	supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(15) UNIQUE NOT NULL
);
SELECT * FROM Suppliers;
CREATE TABLE WareHouse(
	warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(100),
    location VARCHAR(150),
    capacity INT
);
SELECT * FROM WareHouse;
CREATE TABLE Stock (
	stock_id INT AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL,
	product_id INT,
	warehouse_id INT,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES WareHouse(warehouse_id)
);
SELECT * FROM Stock;
INSERT INTO Suppliers (supplier_name, contact_number) VALUES
('Global Electronics', '9748375207'),
('Fresh  Foods', '8746679320'),
('Croma' , '8874666209'),
('IKEA', '9998884443');

INSERT INTO  Products  (product_name, supplier_id, ReorderLevel) VALUES
('LED TV 42 inch', 1, 28),
('Smart phone',1, 21),
('Basmati Rice 5kg', 2, 29),
('Apple 1kg' , 2, 5),
('Laptop x5 pro', 3, 6),
('Dining table set', 4, 20),
('Cotton Bedsheet', 4, 19);

INSERT INTO WareHouse (warehouse_name, location, capacity ) VALUES
('Central Warehouse', 'Hyderabad' , 5000),
('North Zone Storage', 'Delhi', 4000),
('South Zone Storage', 'Chennai', 3000);

INSERT INTO Stock (quantity, product_id, warehouse_id) VALUES
(120, 1, 1),
(75, 2, 1),
(200, 3, 1),
(50, 4, 2),
(4, 5, 2),
(40, 6, 3),
(150, 7, 3);
-- Query to check low stock alert
SELECT p.product_name, 
SUM(s.quantity) AS total_quantity
FROM Stock s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC;

-- Query to record alert
SELECT p.Product_name, w.warehouse_name, p.ReorderLevel,
	CASE
    WHEN s.quantity <= p.ReorderLevel 
    THEN 'Reorder Needed'
    ELSE 'sufficient stock'
    END AS status
FROM Stock s
	JOIN Products p ON s.product_id = p.product_id
    JOIN WareHouse w ON s.warehouse_id = w.warehouse_id;
    

-- First create an alerts table to store notifications
CREATE TABLE LowStockAlerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    warehouse_id INT,
    alert_message VARCHAR(255),
    alert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger
DELIMITER //
CREATE TRIGGER check_low_stock
AFTER UPDATE ON Stock
FOR EACH ROW
BEGIN
    IF NEW.quantity < 10 THEN
        INSERT INTO LowStockAlerts (product_id, warehouse_id, alert_message)
        VALUES (NEW.product_id, NEW.warehouse_id,
		CONCAT('Low stock alert: Product ID ', NEW.product_id,
                       ' in Warehouse ID ', NEW.warehouse_id,
                       ' has only ', NEW.quantity, ' units left.'));
    END IF;
END //
DELIMITER ;

-- Create procedure to transfer stock
DELIMITER //
CREATE PROCEDURE transfer_stock(
    IN p_product_id INT,
    IN p_from_warehouse INT,
    IN p_to_warehouse INT,
    IN p_quantity INT
)
BEGIN 
    DECLARE available_qnty INT;

    SELECT quantity INTO available_qnty
    FROM Stock
    WHERE product_id = p_product_id 
      AND warehouse_id = p_from_warehouse;

  
    IF available_qnty >= p_quantity THEN
        UPDATE Stock 
        SET quantity = quantity - p_quantity
        WHERE product_id = p_product_id 
          AND warehouse_id = p_from_warehouse;

        UPDATE Stock
        SET quantity = quantity + p_quantity
        WHERE product_id = p_product_id 
          AND warehouse_id = p_to_warehouse;

        SELECT CONCAT(p_quantity, ' units of Product ID ', p_product_id,
                      ' transferred from Warehouse ', p_from_warehouse,
                      ' to Warehouse ', p_to_warehouse) AS Message;
    ELSE
        SELECT CONCAT('Transfer failed: only ', available_qnty,
                      ' units available in Warehouse ', p_from_warehouse) AS Message;
    END IF;
END //
DELIMITER ;

CALL transfer_stock(5, 2, 3, 2);

SELECT * FROM Stock WHERE product_id = 1;

