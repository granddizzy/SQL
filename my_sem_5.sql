DROP DATABASE IF EXISTS lesson_5;
CREATE DATABASE lesson_5;
USE lesson_5;


/* СТЕ (Common Table Expressions)

Что это такое?

До версии 8.0:
Производные таблицы (Derived Tables)
SELECT ... FROM (subquery) AS derived, t1, …

Начиная с 8.0, также доступны:
Обобщенные табличные выражения (Common Table Expressions)
WITH cte AS (subquery) SELECT ... FROM cte, t1 ... */

/*
Производные таблицы:
SELECT dt.a
FROM t1 LEFT JOIN
		((SELECT ... FROM ...) AS dt JOIN t2 ON ...) ON ...
● ... сначала видим dt.a
● ... что такое dt ?
● ... приходится искать вглубь


Обобщенные табличные выражения:
WITH dt AS (SELECT ... FROM ...)
SELECT dt.a
FROM t1 LEFT JOIN (dt JOIN t2 ON ... ) ON ...
*/ 


/*
ЗАДАНИЕ 1
Собрать дэшборд, в котором содержится
информация о максимальной задолженности в
каждом банке, а также средний размер процентной
ставки в каждом банке в зависимости от сегмента и
количество договоров всего по всем банкам */

DROP TABLE IF EXISTS `T`;
CREATE TABLE `T` (
  `TB` varchar(1) NOT NULL,
  `ID_CLIENT` int unsigned NOT NULL,
  `ID_DOG` int unsigned NOT NULL,
  `OSZ` int unsigned NOT NULL,
  `PROCENT_RATE` int unsigned NOT NULL,
  `RATING` int unsigned NOT NULL,
  `SEGMENT` varchar(45) NOT NULL,
  UNIQUE KEY `ID_DOG_UNIQUE` (`ID_DOG`)
);

INSERT INTO `T` VALUES ('A',1,111,100,6,10,'SREDN'),('A',1,222,150,6,10,'SREDN'),('A',2,333,50,9,15,'MMB'),('B',1,444,200,7,10,'SREDN'),('B',3,555,1000,5,16,'CIB'),('B',4,666,500,10,20,'CIB'),('B',4,777,10,12,17,'MMB'),('C',5,888,20,11,21,'MMB'),('C',5,999,200,9,13,'SREDN');


SELECT * FROM T;


/*
ЗАДАНИЕ 1
Собрать дэшборд, в котором содержится
информация о максимальной задолженности в
каждом банке, а также средний размер процентной
ставки в каждом банке в зависимости от сегмента и
количество договоров всего по всем банкам */


SELECT DISTINCT
  *,
  SEGMENT,
  MAX(OSZ) OVER (PARTITION BY TB) AS "Максимальная задолженность в разбивке по банкам",
  AVG(PROCENT_RATE) OVER (PARTITION BY TB, SEGMENT) AS "Средняя процентная ставка в разрезе банка и сегмента",
  COUNT(1) OVER() AS "Всего договоров во всех банках",
  COUNT(1) OVER (PARTITION BY TB) AS "Всего договоров в разбивке по банкам"
FROM T;


/*
ЗАДАНИЕ 2
Проранжируем таблицу по убываанию количества ревизий
*/
USE lesson_5;
DROP TABLE IF EXISTS `Table_Rev`;
CREATE TABLE `Table_Rev` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT, 
  `TB` varchar(1) NOT NULL, # Код банка
  `DEP` varchar(45) NOT NULL, # Код отдела
  `Count_Revisions` int unsigned NOT NULL,  # Количество ревизий
  PRIMARY KEY (`ID`),
  UNIQUE KEY `ID_UNIQUE` (`ID`)
);

INSERT INTO `Table_Rev` VALUES (1,'A','Corp',100),(2,'A','Rozn',47),(3,'A','IT',86),(4,'B','Corp',70),(5,'B','Rozn',65),(6,'B','IT',58),(7,'C','Corp',42),(8,'C','Rozn',40),(9,'C','IT',63),(10,'D','Corp',95),(11,'D','Rozn',120),(12,'D','IT',85),(13,'E','Corp',70),(14,'E','Rozn',72),(15,'E','IT',80),(16,'F','Corp',66),(17,'F','Rozn',111),(18,'F','IT',33);

SELECT * FROM Table_Rev;

SELECT *, 
  ROW_NUMBER() OVER (ORDER BY Count_Revisions DESC) AS ROW_NUMBER_REV,
  RANK() OVER (ORDER BY Count_Revisions DESC) AS RANK_REV,
  DENSE_RANK() OVER (ORDER BY Count_Revisions DESC) AS DENSE_RANK_REV,
  NTILE(7) OVER (ORDER BY Count_Revisions DESC) AS NTILE_REV
FROM Table_Rev;


SELECT *, 
  ROW_NUMBER() OVER w_Count AS ROW_NUMBER_REV,
  RANK() OVER w_Count AS RANK_REV,
  DENSE_RANK() OVER w_Count AS DENSE_RANK_REV,
  NTILE(7) OVER w_Count AS NTILE_REV
FROM Table_Rev
WINDOW w_Count AS (ORDER BY Count_Revisions DESC);


SELECT * FROM Table_Rev;

/* 
ЗАДАНИЕ 3
Найти второй отдел во всех банках по количеству ревизий. */

SELECT MAX(count_revisions) FROM Table_Rev;

SELECT MAX(count_revisions) ms
FROM Table_Rev
WHERE count_revisions != (SELECT MAX(count_revisions) FROM Table_Rev);

/* Но если речь идет не про второй отдел, а про третий?
Уже сложнее. Именно поэтому, попробуйте воспользоваться
оконной функцией */

	SELECT 
	  * , 
      DENSE_RANK() OVER(PARTITION BY tb ORDER BY count_revisions DESC) ds
	FROM Table_Rev;


With T_R AS
(
	SELECT 
	  * , 
      DENSE_RANK() OVER(PARTITION BY tb ORDER BY count_revisions DESC) ds
	FROM Table_Rev
)
SELECT tb, dep,count_revisions, ds
FROM T_R
WHERE ds = 3;


/*
LAG — смещение назад.

LEAD — смещение вперед.

FIRST_VALUE — найти первое значение
набора данных.

LAST_VALUE — найти последнее
значение набора данных.

LAG и LEAD имеют следующие
аргументы:
	● Столбец, значение которого
	необходимо вернуть
	
    ● На сколько строк выполнить
	смешение (дефолт =1)
	
    ● Что вставить, если вернулся
	NULL
*/

DROP TABLE IF EXISTS `Table_Task`;
CREATE TABLE `Table_Task` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_task` int unsigned NOT NULL,
  `event` varchar(45) NOT NULL,
  `date_event` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
);

INSERT INTO `Table_Task` VALUES (1,1,'Open','2020-02-01'),(2,1,'To_1_Line','2020-02-02'),(3,1,'To_2_Line','2020-02-03'),(4,1,'Successful','2020-02-04'),(5,1,'Close','2020-02-05'),(6,2,'Open','2020-03-01'),(7,2,'To_1_Line','2020-03-02'),(8,2,'Denied','2020-03-03'),(9,3,'Open','2020-04-01'),(10,3,'To_1_Line','2020-04-02'),(11,3,'To_2_Line','2020-04-03');


SELECT * FROM Table_Task;


SELECT
  *,
  LEAD (Event, 1, 'end') OVER (PARTITION BY ID_Task ORDER BY Date_Event) AS Next_Event,
  LEAD (Date_Event, 1, '2099-01-01') OVER(PARTITION BY ID_Task ORDER BY Date_Event) AS Next_Date,
  LAG (Date_Event, 1, NULL) OVER(PARTITION BY ID_Task ORDER BY Date_Event) AS Prev_Date,
  FIRST_VALUE(Event) OVER (PARTITION BY ID_Task ORDER BY Date_Event) AS First_Event,
  LAST_VALUE(Event) OVER (PARTITION BY ID_Task ORDER BY Date_Event RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS Last_Event
FROM Table_Task;


SELECT
  *,
  LEAD (Event, 1, 'end') OVER w_date AS Next_Event,
  LEAD (Date_Event, 1, '2099-01-01') OVER w_date AS Next_Date,
  LAG (Date_Event, 1, NULL) OVER w_date AS Prev_Date,
  FIRST_VALUE(Event) OVER w_date AS First_Event,
  LAST_VALUE(Event) OVER (PARTITION BY ID_Task ORDER BY Date_Event RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS Last_Event
FROM Table_Task

WINDOW w_date AS (PARTITION BY ID_Task ORDER BY Date_Event);



/* Создайте представление, которое выводит название name товарной позиции 
из таблицы products и соответствующее название каталога name из таблицы catalogs. */

-- Создаём необходимую структуру и заполняем её данным в БД 
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');


DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);
  


SELECT * FROM catalogs;
SELECT * FROM products;

-- Создаём запрос для проверки
SELECT products.name, catalogs.name 
  FROM products
    JOIN catalogs
      ON products.catalog_id = catalogs.id;

-- Преобразуем запрос в представление
DROP VIEW IF EXISTS product_name;
CREATE VIEW product_name (name, type)
  AS SELECT products.name, catalogs.name 
	  FROM products
		JOIN catalogs
		  ON products.catalog_id = catalogs.id;

-- Обращаемся к представлению
SELECT * FROM product_name;