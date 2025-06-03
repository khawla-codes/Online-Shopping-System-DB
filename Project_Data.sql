-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Apr 29, 2025 at 08:23 PM
-- Server version: 8.0.17
-- PHP Version: 7.3.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `poject`
create Database project;
USE project;
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddProduct` (IN `p_name` VARCHAR(255), IN `p_description` TEXT, IN `p_price` DECIMAL(10,2), IN `p_stock` INT, IN `p_category_id` INT, IN `p_supplier_id` INT, OUT `p_product_id` INT)  BEGIN
    INSERT INTO Product (product_name, description, price, stock_quantity, category_id, supplier_id)
    VALUES (p_name, p_description, p_price, p_stock, p_category_id, p_supplier_id);
    
    SET p_product_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateOrder` (IN `p_customer_id` INT, IN `p_payment_method` VARCHAR(50), OUT `p_order_id` INT)  BEGIN
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_cart_id INT;
    
    -- الحصول على السلة النشطة للعميل
    SELECT cart_id INTO v_cart_id FROM Cart 
    WHERE customer_id = p_customer_id
    ORDER BY created_at DESC LIMIT 1;
    
    -- حساب المجموع من عناصر السلة
    SELECT SUM(p.price * ci.quantity) INTO v_total
    FROM CartItem ci
    JOIN Product p ON ci.product_id = p.product_id
    WHERE ci.cart_id = v_cart_id;
    
    -- إنشاء الطلب
    INSERT INTO Orders (customer_id, order_amount, payment_status)
    VALUES (p_customer_id, v_total, 'unpaid');
    
    SET p_order_id = LAST_INSERT_ID();
    
    -- نقل العناصر من السلة إلى تفاصيل الطلب
    INSERT INTO OrderItem (order_id, product_id, quantity, price, size)
    SELECT p_order_id, ci.product_id, ci.quantity, p.price, ci.size
    FROM CartItem ci
    JOIN Product p ON ci.product_id = p.product_id
    WHERE ci.cart_id = v_cart_id;
    
    -- تحديث المخزون
    UPDATE Product p
    JOIN CartItem ci ON p.product_id = ci.product_id
    SET p.stock_quantity = p.stock_quantity - ci.quantity
    WHERE ci.cart_id = v_cart_id;
    
    -- حذف عناصر السلة
    DELETE FROM CartItem WHERE cart_id = v_cart_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `admin_id` int(11) NOT NULL,
  `fname` varchar(50) COLLATE utf32_german2_ci NOT NULL,
  `lname` varchar(50) COLLATE utf32_german2_ci NOT NULL,
  `email` varchar(100) COLLATE utf32_german2_ci NOT NULL,
  `password` varchar(255) COLLATE utf32_german2_ci NOT NULL,
  `role` varchar(50) COLLATE utf32_german2_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `fname`, `lname`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'محمد', 'السهلي', 'm.alsuhaili@example.com', '$2y$10$examplehash', 'super_admin', '2025-04-29 20:20:30'),
(2, 'سارة', 'العتيبي', 's.alotaibi@example.com', '$2y$10$examplehash', 'inventory_manager', '2025-04-29 20:20:30'),
(3, 'خالد', 'الغامدي', 'k.alghamdi@example.com', '$2y$10$examplehash', 'sales_manager', '2025-04-29 20:20:30'),
(4, 'نورة', 'القرني', 'n.alqarni@example.com', '$2y$10$examplehash', 'customer_support', '2025-04-29 20:20:30'),
(5, 'عبدالله', 'الحارثي', 'a.alharthi@example.com', '$2y$10$examplehash', 'marketing_manager', '2025-04-29 20:20:30'),
(6, 'لمى', 'الزهراني', 'l.alzahrani@example.com', '$2y$10$examplehash', 'data_analyst', '2025-04-29 20:20:30'),
(7, 'فيصل', 'العمري', 'f.alomari@example.com', '$2y$10$examplehash', 'logistics_manager', '2025-04-29 20:20:30'),
(8, 'هناء', 'الشهري', 'h.alshahri@example.com', '$2y$10$examplehash', 'hr_manager', '2025-04-29 20:20:30'),
(9, 'تركي', 'البلوي', 't.albalawi@example.com', '$2y$10$examplehash', 'it_specialist', '2025-04-29 20:20:30'),
(10, 'أمل', 'الجبرين', 'a.aljabrin@example.com', '$2y$10$examplehash', 'finance_manager', '2025-04-29 20:20:30');

-- --------------------------------------------------------

--
-- Stand-in structure for view `availableproducts`
-- (See below for the actual view)
--
CREATE TABLE `availableproducts` (
`product_id` int(11)
,`product_name` varchar(255)
,`price` decimal(10,2)
,`stock_quantity` int(11)
,`category_name` varchar(100)
,`supp_name` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `cart_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`cart_id`, `customer_id`, `created_at`) VALUES
(1, 1, '2025-04-29 20:20:30'),
(2, 2, '2025-04-29 20:20:30'),
(3, 3, '2025-04-29 20:20:30'),
(4, 4, '2025-04-29 20:20:30'),
(5, 5, '2025-04-29 20:20:30'),
(6, 6, '2025-04-29 20:20:30'),
(7, 7, '2025-04-29 20:20:30'),
(8, 8, '2025-04-29 20:20:30'),
(9, 9, '2025-04-29 20:20:30'),
(10, 10, '2025-04-29 20:20:30');

-- --------------------------------------------------------

--
-- Table structure for table `cartitem`
--

CREATE TABLE `cartitem` (
  `cart_item_id` int(11) NOT NULL,
  `cart_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT '1',
  `size` varchar(20) COLLATE utf32_german2_ci DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `cartitem`
--

INSERT INTO `cartitem` (`cart_item_id`, `cart_id`, `product_id`, `quantity`, `size`, `added_at`) VALUES
(1, 1, 1, 1, NULL, '2025-04-29 20:20:30'),
(2, 1, 3, 2, 'XL', '2025-04-29 20:20:30'),
(3, 2, 2, 1, NULL, '2025-04-29 20:20:30'),
(4, 2, 5, 3, NULL, '2025-04-29 20:20:30'),
(5, 3, 4, 1, 'L', '2025-04-29 20:20:30'),
(6, 4, 6, 1, NULL, '2025-04-29 20:20:30'),
(7, 5, 7, 1, NULL, '2025-04-29 20:20:30'),
(8, 6, 8, 2, NULL, '2025-04-29 20:20:30'),
(9, 7, 9, 1, NULL, '2025-04-29 20:20:30'),
(10, 8, 10, 1, NULL, '2025-04-29 20:20:30');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `fname` varchar(50) COLLATE utf32_german2_ci NOT NULL,
  `lname` varchar(50) COLLATE utf32_german2_ci NOT NULL,
  `email` varchar(100) COLLATE utf32_german2_ci NOT NULL,
  `password` varchar(255) COLLATE utf32_german2_ci NOT NULL,
  `city` varchar(50) COLLATE utf32_german2_ci NOT NULL,
  `state` varchar(50) COLLATE utf32_german2_ci NOT NULL,
  `pin_code` varchar(20) COLLATE utf32_german2_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customer_id`, `fname`, `lname`, `email`, `password`, `city`, `state`, `pin_code`, `created_at`) VALUES
(1, 'أحمد', 'الغنيم', 'a.alghunaim@example.com', '$2y$10$examplehash', 'الرياض', 'الرياض', '12345', '2025-04-29 20:20:30'),
(2, 'نوف', 'القحطاني', 'n.alqahtani@example.com', '$2y$10$examplehash', 'جدة', 'مكة المكرمة', '23456', '2025-04-29 20:20:30'),
(3, 'تركي', 'الشمراني', 't.alshammari@example.com', '$2y$10$examplehash', 'الدمام', 'الشرقية', '34567', '2025-04-29 20:20:30'),
(4, 'لولوه', 'الحربي', 'l.alharbi@example.com', '$2y$10$examplehash', 'الخبر', 'الشرقية', '45678', '2025-04-29 20:20:30'),
(5, 'فهد', 'الزهراني', 'f.alzahrani@example.com', '$2y$10$examplehash', 'بريدة', 'القصيم', '56789', '2025-04-29 20:20:30'),
(6, 'هند', 'العنزي', 'h.alanzi@example.com', '$2y$10$examplehash', 'تبوك', 'تبوك', '67890', '2025-04-29 20:20:30'),
(7, 'بدر', 'السليم', 'b.alsulaim@example.com', '$2y$10$examplehash', 'حائل', 'حائل', '78901', '2025-04-29 20:20:30'),
(8, 'شهد', 'الغامدي', 's.alghamdi@example.com', '$2y$10$examplehash', 'أبها', 'عسير', '89012', '2025-04-29 20:20:30'),
(9, 'عمر', 'الحارثي', 'o.alharthi@example.com', '$2y$10$examplehash', 'نجران', 'نجران', '90123', '2025-04-29 20:20:30'),
(10, 'لمى', 'السهلي', 'l.alsuhaili@example.com', '$2y$10$examplehash', 'الجوف', 'الجوف', '01234', '2025-04-29 20:20:30');

-- --------------------------------------------------------

--
-- Stand-in structure for view `customerorderdetails`
-- (See below for the actual view)
--
CREATE TABLE `customerorderdetails` (
`order_id` int(11)
,`order_date` timestamp
,`order_amount` decimal(10,2)
,`status` enum('pending','processing','shipped','delivered','cancelled')
,`fname` varchar(50)
,`lname` varchar(50)
,`email` varchar(100)
,`items` varchar(256)
,`payment_method` enum('credit_card','debit_card','paypal','bank_transfer')
,`paid_amount` decimal(10,2)
,`courier_name` varchar(100)
,`tracking_number` varchar(100)
,`shipping_status` enum('processing','shipped','in_transit','out_for_delivery','delivered')
);

-- --------------------------------------------------------

--
-- Table structure for table `customerphone`
--

CREATE TABLE `customerphone` (
  `phone_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `phone_number` varchar(20) COLLATE utf32_german2_ci NOT NULL,
  `is_primary` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `customerphone`
--

INSERT INTO `customerphone` (`phone_id`, `customer_id`, `phone_number`, `is_primary`) VALUES
(1, 1, '+966501234567', 1),
(2, 1, '+966502345678', 0),
(3, 2, '+966503456789', 1),
(4, 3, '+966504567890', 1),
(5, 4, '+966505678901', 1),
(6, 5, '+966506789012', 1),
(7, 6, '+966507890123', 1),
(8, 7, '+966508901234', 1),
(9, 8, '+966509012345', 1),
(10, 9, '+966500123456', 1);

-- --------------------------------------------------------

--
-- Table structure for table `orderitem`
--

CREATE TABLE `orderitem` (
  `order_item_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `size` varchar(20) COLLATE utf32_german2_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `orderitem`
--

INSERT INTO `orderitem` (`order_item_id`, `order_id`, `product_id`, `quantity`, `price`, `size`) VALUES
(1, 1, 1, 1, '5499.99', NULL),
(2, 1, 3, 2, '299.99', 'XL'),
(3, 2, 2, 1, '3999.99', NULL),
(4, 2, 5, 3, '59.99', NULL),
(5, 3, 4, 1, '499.99', 'L'),
(6, 4, 6, 1, '129.99', NULL),
(7, 5, 7, 1, '4599.99', NULL),
(8, 6, 8, 2, '399.99', NULL),
(9, 7, 9, 1, '199.99', NULL),
(10, 8, 10, 1, '15999.99', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `order_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `order_amount` decimal(10,2) NOT NULL,
  `status` enum('pending','processing','shipped','delivered','cancelled') COLLATE utf32_german2_ci DEFAULT 'pending',
  `payment_status` enum('paid','unpaid','refunded') COLLATE utf32_german2_ci DEFAULT 'unpaid'
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `customer_id`, `order_date`, `order_amount`, `status`, `payment_status`) VALUES
(1, 1, '2025-04-29 20:20:30', '6099.97', 'delivered', 'paid'),
(2, 2, '2025-04-29 20:20:30', '4139.96', 'processing', 'paid'),
(3, 3, '2025-04-29 20:20:30', '499.99', 'shipped', 'paid'),
(4, 4, '2025-04-29 20:20:30', '129.99', 'processing', 'paid'),
(5, 5, '2025-04-29 20:20:30', '4599.99', 'delivered', 'paid'),
(6, 6, '2025-04-29 20:20:30', '799.98', 'shipped', 'paid'),
(7, 7, '2025-04-29 20:20:30', '199.99', 'delivered', 'paid'),
(8, 8, '2025-04-29 20:20:30', '399.99', 'processing', 'paid'),
(9, 9, '2025-04-29 20:20:30', '15999.99', 'pending', ''),
(10, 10, '2025-04-29 20:20:30', '299.99', 'delivered', 'paid');

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `payment_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `payment_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_method` enum('credit_card','debit_card','paypal','bank_transfer') COLLATE utf32_german2_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `transaction_id` varchar(100) COLLATE utf32_german2_ci DEFAULT NULL,
  `status` enum('success','failed','pending') COLLATE utf32_german2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`payment_id`, `order_id`, `payment_date`, `payment_method`, `amount`, `transaction_id`, `status`) VALUES
(1, 1, '2025-04-29 20:20:30', 'credit_card', '6099.97', 'TXN123456', 'success'),
(2, 2, '2025-04-29 20:20:30', '', '4139.96', 'TXN789012', 'success'),
(3, 3, '2025-04-29 20:20:30', '', '499.99', 'TXN345678', 'success'),
(4, 4, '2025-04-29 20:20:30', 'credit_card', '129.99', 'TXN901234', 'success'),
(5, 5, '2025-04-29 20:20:30', 'bank_transfer', '4599.99', 'TXN567890', 'success'),
(6, 6, '2025-04-29 20:20:30', '', '799.98', 'TXN123789', 'success'),
(7, 7, '2025-04-29 20:20:30', '', '199.99', 'TXN456123', 'success'),
(8, 8, '2025-04-29 20:20:30', 'credit_card', '399.99', 'TXN789456', 'success'),
(9, 9, '2025-04-29 20:20:30', 'bank_transfer', '15999.99', 'TXN234567', 'pending'),
(10, 10, '2025-04-29 20:20:30', '', '299.99', 'TXN890123', 'success');

-- --------------------------------------------------------

--
-- Table structure for table `pricechangelog`
--

CREATE TABLE `pricechangelog` (
  `log_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `old_price` decimal(10,2) DEFAULT NULL,
  `new_price` decimal(10,2) DEFAULT NULL,
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `changed_by` varchar(100) COLLATE utf32_german2_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) COLLATE utf32_german2_ci NOT NULL,
  `description` text COLLATE utf32_german2_ci,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT '0',
  `status` enum('available','out_of_stock','discontinued') COLLATE utf32_german2_ci DEFAULT 'available',
  `category_id` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`product_id`, `product_name`, `description`, `price`, `stock_quantity`, `status`, `category_id`, `supplier_id`, `created_at`) VALUES
(1, 'آيفون 15 برو', 'أحدث جوال من آبل بمواصفات عالية', '5499.99', 50, 'available', 1, 1, '2025-04-29 20:20:30'),
(2, 'سامسونج جالكسي S23', 'جوال ذكي بشاشة ديناميكية AMOLED', '3999.99', 75, 'available', 1, 1, '2025-04-29 20:20:30'),
(3, 'ثوب رجالي', 'ثوب سعودي قطني عالي الجودة', '299.99', 200, 'available', 2, 2, '2025-04-29 20:20:30'),
(4, 'عباية سوداء', 'عباية نسائية مطرزة', '499.99', 150, 'available', 2, 2, '2025-04-29 20:20:30'),
(5, 'أرز بسمتي', 'أرز هندي عالي الجودة 5 كجم', '59.99', 300, 'available', 3, 3, '2025-04-29 20:20:30'),
(6, 'تعلم البرمجة بلغة بايثون', 'كتاب شامل لتعليم لغة بايثون', '129.99', 80, 'available', 4, 4, '2025-04-29 20:20:30'),
(7, 'كنبة جلد طبيعي', 'كنبة 3 مقاعد جلد طبيعي', '4599.99', 20, 'available', 5, 5, '2025-04-29 20:20:30'),
(8, 'عطر أميري', 'عطر رجالي من إنتاج سعودي', '399.99', 100, 'available', 6, 6, '2025-04-29 20:20:30'),
(9, 'كرة قدم نايك', 'كرة قدم رسمية بحجم 5', '199.99', 120, 'available', 8, 8, '2025-04-29 20:20:30'),
(10, 'ساعة رولكس', 'ساعة رجالية فاخرة', '15999.99', 10, 'available', 9, 9, '2025-04-29 20:20:30');

--
-- Triggers `product`
--
DELIMITER $$
CREATE TRIGGER `LogPriceChange` AFTER UPDATE ON `product` FOR EACH ROW BEGIN
    IF OLD.price != NEW.price THEN
        INSERT INTO PriceChangeLog (product_id, old_price, new_price, changed_by)
        VALUES (NEW.product_id, OLD.price, NEW.price, CURRENT_USER());
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `UpdateProductStatus` AFTER UPDATE ON `product` FOR EACH ROW BEGIN
    IF NEW.stock_quantity <= 0 AND NEW.status != 'out_of_stock' THEN
        UPDATE Product SET status = 'out_of_stock' WHERE product_id = NEW.product_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `productcategory`
--

CREATE TABLE `productcategory` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) COLLATE utf32_german2_ci NOT NULL,
  `description` text COLLATE utf32_german2_ci,
  `app_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `productcategory`
--

INSERT INTO `productcategory` (`category_id`, `category_name`, `description`, `app_id`) VALUES
(1, 'إلكترونيات', 'أجهزة إلكترونية وجوالات', 1),
(2, 'ملابس', 'ملابس رجالية ونسائية', 1),
(3, 'بقالة', 'مواد غذائية ومنزلية', 1),
(4, 'كتب', 'كتب تعليمية وترفيهية', 1),
(5, 'أثاث', 'أثاث منزلي ومكتبي', 2),
(6, 'عطور', 'عطور ومستحضرات تجميل', 3),
(7, 'ألعاب', 'ألعاب أطفال وإلكترونية', 4),
(8, 'رياضة', 'معدات رياضية ولياقة', 5),
(9, 'ساعات', 'ساعات رجالية ونسائية', 6),
(10, 'مجوهرات', 'ذهب ومجوهرات', 7);

-- --------------------------------------------------------

--
-- Table structure for table `shoppingapp`
--

CREATE TABLE `shoppingapp` (
  `app_id` int(11) NOT NULL,
  `app_name` varchar(100) COLLATE utf32_german2_ci NOT NULL,
  `app_version` varchar(20) COLLATE utf32_german2_ci NOT NULL,
  `contact_no` varchar(20) COLLATE utf32_german2_ci NOT NULL,
  `admin_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `shoppingapp`
--

INSERT INTO `shoppingapp` (`app_id`, `app_name`, `app_version`, `contact_no`, `admin_id`) VALUES
(1, 'متجر السعودية', '1.0.0', '+966500123456', 1),
(2, 'سوق نجد', '1.2.1', '+966501234567', 2),
(3, 'حجاز مارت', '2.0.3', '+966502345678', 3),
(4, 'شرقاوي شوب', '1.5.0', '+966503456789', 4),
(5, 'جنوبية', '1.1.4', '+966504567890', 5),
(6, 'عسير ستور', '3.0.1', '+966505678901', 6),
(7, 'قحطان مول', '2.2.0', '+966506789012', 7),
(8, 'طيبة ماركت', '1.0.5', '+966507890123', 8),
(9, 'الرياض ستور', '1.3.2', '+966508901234', 9),
(10, 'الدمام شوب', '2.1.0', '+966509012345', 10);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `supplier_id` int(11) NOT NULL,
  `supp_name` varchar(100) COLLATE utf32_german2_ci NOT NULL,
  `supp_address` text COLLATE utf32_german2_ci NOT NULL,
  `email` varchar(100) COLLATE utf32_german2_ci NOT NULL,
  `phone` varchar(20) COLLATE utf32_german2_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`supplier_id`, `supp_name`, `supp_address`, `email`, `phone`, `created_at`) VALUES
(1, 'شركة التقنية السعودية', 'الرياض، المملكة العربية السعودية', 'info@tech.sa', '+966112345678', '2025-04-29 20:20:30'),
(2, 'أزياء الرياض', 'الرياض، المملكة العربية السعودية', 'contact@riyadhfashion.com', '+966112345679', '2025-04-29 20:20:30'),
(3, 'التموينات الخليجية', 'الدمام، المملكة العربية السعودية', 'sales@gulfgroceries.com', '+966112345680', '2025-04-29 20:20:30'),
(4, 'دار النشر العربية', 'جدة، المملكة العربية السعودية', 'info@arabicpublishing.com', '+966112345681', '2025-04-29 20:20:30'),
(5, 'الأثاث الحديث', 'الخبر، المملكة العربية السعودية', 'sales@modernfurniture.sa', '+966112345682', '2025-04-29 20:20:30'),
(6, 'عطور الشرق', 'الظهران، المملكة العربية السعودية', 'info@eastperfumes.com', '+966112345683', '2025-04-29 20:20:30'),
(7, 'ألعاب المستقبل', 'الجبيل، المملكة العربية السعودية', 'contact@futuretoys.sa', '+966112345684', '2025-04-29 20:20:30'),
(8, 'المستلزمات الرياضية', 'بريدة، المملكة العربية السعودية', 'sales@sportsgear.sa', '+966112345685', '2025-04-29 20:20:30'),
(9, 'ساعات الرفاهية', 'الطائف، المملكة العربية السعودية', 'info@luxurywatches.sa', '+966112345686', '2025-04-29 20:20:30'),
(10, 'مجوهرات الذهب', 'حائل، المملكة العربية السعودية', 'contact@goldjewelry.sa', '+966112345687', '2025-04-29 20:20:30');

-- --------------------------------------------------------

--
-- Table structure for table `trackingdetail`
--

CREATE TABLE `trackingdetail` (
  `tracking_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `courier_name` varchar(100) COLLATE utf32_german2_ci NOT NULL,
  `tracking_number` varchar(100) COLLATE utf32_german2_ci NOT NULL,
  `estimated_delivery` date DEFAULT NULL,
  `actual_delivery` date DEFAULT NULL,
  `status` enum('processing','shipped','in_transit','out_for_delivery','delivered') COLLATE utf32_german2_ci DEFAULT 'processing'
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_german2_ci;

--
-- Dumping data for table `trackingdetail`
--

INSERT INTO `trackingdetail` (`tracking_id`, `order_id`, `courier_name`, `tracking_number`, `estimated_delivery`, `actual_delivery`, `status`) VALUES
(1, 1, 'ساعي', 'SA123456789', '2023-06-15', NULL, 'delivered'),
(2, 2, 'أرامكس', 'SA987654321', '2023-06-20', NULL, 'processing'),
(3, 3, 'دي إتش إل', 'SA456123789', '2023-06-18', NULL, 'shipped'),
(4, 4, 'سابل', 'SA789456123', '2023-06-22', NULL, 'processing'),
(5, 5, 'ساعي', 'SA321654987', '2023-06-16', NULL, 'delivered'),
(6, 6, 'أرامكس', 'SA654987321', '2023-06-19', NULL, 'shipped'),
(7, 7, 'دي إتش إل', 'SA987321654', '2023-06-17', NULL, 'delivered'),
(8, 8, 'سابل', 'SA147258369', '2023-06-21', NULL, 'processing'),
(9, 9, 'فيديكس', 'SA369258147', '2023-06-25', NULL, ''),
(10, 10, 'ساعي', 'SA258147369', '2023-06-15', NULL, 'delivered');

-- --------------------------------------------------------

--
-- Structure for view `availableproducts`
--
DROP TABLE IF EXISTS `availableproducts`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `availableproducts`  AS  select `p`.`product_id` AS `product_id`,`p`.`product_name` AS `product_name`,`p`.`price` AS `price`,`p`.`stock_quantity` AS `stock_quantity`,`c`.`category_name` AS `category_name`,`s`.`supp_name` AS `supp_name` from ((`product` `p` join `productcategory` `c` on((`p`.`category_id` = `c`.`category_id`))) join `supplier` `s` on((`p`.`supplier_id` = `s`.`supplier_id`))) where ((`p`.`status` = 'available') and (`p`.`stock_quantity` > 0)) ;

-- --------------------------------------------------------

--
-- Structure for view `customerorderdetails`
--
DROP TABLE IF EXISTS `customerorderdetails`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `customerorderdetails`  AS  select `o`.`order_id` AS `order_id`,`o`.`order_date` AS `order_date`,`o`.`order_amount` AS `order_amount`,`o`.`status` AS `status`,`c`.`fname` AS `fname`,`c`.`lname` AS `lname`,`c`.`email` AS `email`,group_concat(convert(`oi`.`quantity` using utf32),' x ',`p`.`product_name` separator ', ') AS `items`,`pymt`.`payment_method` AS `payment_method`,`pymt`.`amount` AS `paid_amount`,`td`.`courier_name` AS `courier_name`,`td`.`tracking_number` AS `tracking_number`,`td`.`status` AS `shipping_status` from (((((`orders` `o` join `customer` `c` on((`o`.`customer_id` = `c`.`customer_id`))) join `orderitem` `oi` on((`o`.`order_id` = `oi`.`order_id`))) join `product` `p` on((`oi`.`product_id` = `p`.`product_id`))) left join `payment` `pymt` on((`o`.`order_id` = `pymt`.`order_id`))) left join `trackingdetail` `td` on((`o`.`order_id` = `td`.`order_id`))) group by `o`.`order_id`,`o`.`order_date`,`o`.`order_amount`,`o`.`status`,`c`.`fname`,`c`.`lname`,`c`.`email`,`pymt`.`payment_method`,`pymt`.`amount`,`td`.`courier_name`,`td`.`tracking_number`,`td`.`status` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `cartitem`
--
ALTER TABLE `cartitem`
  ADD PRIMARY KEY (`cart_item_id`),
  ADD KEY `cart_id` (`cart_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `customerphone`
--
ALTER TABLE `customerphone`
  ADD PRIMARY KEY (`phone_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `orderitem`
--
ALTER TABLE `orderitem`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `pricechangelog`
--
ALTER TABLE `pricechangelog`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `productcategory`
--
ALTER TABLE `productcategory`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `app_id` (`app_id`);

--
-- Indexes for table `shoppingapp`
--
ALTER TABLE `shoppingapp`
  ADD PRIMARY KEY (`app_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`supplier_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `trackingdetail`
--
ALTER TABLE `trackingdetail`
  ADD PRIMARY KEY (`tracking_id`),
  ADD KEY `order_id` (`order_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `cartitem`
--
ALTER TABLE `cartitem`
  MODIFY `cart_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `customerphone`
--
ALTER TABLE `customerphone`
  MODIFY `phone_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `orderitem`
--
ALTER TABLE `orderitem`
  MODIFY `order_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `pricechangelog`
--
ALTER TABLE `pricechangelog`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `productcategory`
--
ALTER TABLE `productcategory`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `shoppingapp`
--
ALTER TABLE `shoppingapp`
  MODIFY `app_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `supplier_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `trackingdetail`
--
ALTER TABLE `trackingdetail`
  MODIFY `tracking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `cartitem`
--
ALTER TABLE `cartitem`
  ADD CONSTRAINT `cartitem_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`cart_id`),
  ADD CONSTRAINT `cartitem_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`);

--
-- Constraints for table `customerphone`
--
ALTER TABLE `customerphone`
  ADD CONSTRAINT `customerphone_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `orderitem`
--
ALTER TABLE `orderitem`
  ADD CONSTRAINT `orderitem_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  ADD CONSTRAINT `orderitem_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`);

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `productcategory` (`category_id`),
  ADD CONSTRAINT `product_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`supplier_id`);

--
-- Constraints for table `productcategory`
--
ALTER TABLE `productcategory`
  ADD CONSTRAINT `productcategory_ibfk_1` FOREIGN KEY (`app_id`) REFERENCES `shoppingapp` (`app_id`);

--
-- Constraints for table `shoppingapp`
--
ALTER TABLE `shoppingapp`
  ADD CONSTRAINT `shoppingapp_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`);

--
-- Constraints for table `trackingdetail`
--
ALTER TABLE `trackingdetail`
  ADD CONSTRAINT `trackingdetail_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

UPDATE `project`.`payment` SET `payment_method` = 'credit_card' WHERE (`payment_id` = '2');
UPDATE `project`.`payment` SET `payment_method` = 'credit_card' WHERE (`payment_id` = '10');
UPDATE `project`.`payment` SET `payment_method` = 'credit_card' WHERE (`payment_id` = '7');
UPDATE `project`.`payment` SET `payment_method` = 'bank_transfer' WHERE (`payment_id` = '6');
UPDATE `project`.`payment` SET `payment_method` = 'bank_transfer' WHERE (`payment_id` = '3');

INSERT INTO `project`.`pricechangelog` (`log_id`, `product_id`, `old_price`, `new_price`, `changed_at`, `changed_by`) VALUES ('1', '1', '499.99', '549.99', '2025-5-01 12:00:00', 'System');
INSERT INTO `project`.`pricechangelog` (`log_id`, `product_id`, `old_price`, `new_price`, `changed_at`, `changed_by`) VALUES ('2', '2', '658.97', '399.99', '2025-5-02 09:00:00', 'k.alwhibi');
INSERT INTO `project`.`pricechangelog` (`log_id`, `product_id`, `old_price`, `new_price`, `changed_at`, `changed_by`) VALUES ('3', '3', '994.97', '299.99', '2025-5-03 14:45:00', 's.alitaibi');
INSERT INTO `project`.`pricechangelog` (`log_id`, `product_id`, `old_price`, `new_price`, `changed_at`, `changed_by`) VALUES ('4', '4', '648.86', '499.99', '2025-5-04 11:10:00', 'System');
INSERT INTO `project`.`pricechangelog` (`log_id`, `product_id`, `old_price`, `new_price`, `changed_at`, `changed_by`) VALUES ('5', '10', '738.89', '637.76', '2025-5-05 16:00:00', 'System');

UPDATE `project`.`orderitem` SET `size` = 'M' WHERE (`order_item_id` = '1');
UPDATE `project`.`orderitem` SET `size` = 'M' WHERE (`order_item_id` = '7');
UPDATE `project`.`orderitem` SET `size` = 'S' WHERE (`order_item_id` = '8');
UPDATE `project`.`orderitem` SET `size` = 'L' WHERE (`order_item_id` = '9');
UPDATE `project`.`orderitem` SET `size` = 'XL' WHERE (`order_item_id` = '6');
UPDATE `project`.`orderitem` SET `size` = 'M' WHERE (`order_item_id` = '4');
UPDATE `project`.`orderitem` SET `size` = 'S' WHERE (`order_item_id` = '3');
UPDATE `project`.`orderitem` SET `size` = 'S' WHERE (`order_item_id` = '10');

UPDATE `project`.`cartitem` SET `size` = 'S' WHERE (`cart_item_id` = '1');
UPDATE `project`.`cartitem` SET `size` = 'M' WHERE (`cart_item_id` = '3');
UPDATE `project`.`cartitem` SET `size` = 'S' WHERE (`cart_item_id` = '4');
UPDATE `project`.`cartitem` SET `size` = 'M' WHERE (`cart_item_id` = '6');
UPDATE `project`.`cartitem` SET `size` = 'XL' WHERE (`cart_item_id` = '8');
UPDATE `project`.`cartitem` SET `size` = 'S' WHERE (`cart_item_id` = '9');
UPDATE `project`.`cartitem` SET `size` = 'M' WHERE (`cart_item_id` = '7');
UPDATE `project`.`cartitem` SET `size` = 'XL' WHERE (`cart_item_id` = '10');
