DROP DATABASE IF EXISTS lesson_6;
CREATE DATABASE lesson_6;
USE lesson_6;


/*
Транзакции

# ЗАДАНИЕ 1
1. Убедиться, что остаток на счете клиента больше 2000 рублей.
2. Вычесть 2000 рублей со счета клиента.
3. Добавить 2000 к счету интернет-магазина.

*/


--  Для начала создадим таблицу accounts:
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  user_id INT,
  total DECIMAL (11,2) COMMENT 'Счет',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Счета пользователей и интернет магазина';

INSERT INTO accounts (user_id, total) VALUES
  (4, 5000.00),
  (3, 0.00),
  (2, 200.00),
  (NULL, 25000.00);

SELECT * FROM accounts;


-- Начинаем транзакцию командой START TRANSACTION:  
START TRANSACTION;
-- Далее выполняем команды, входящие в транзакцию:
SELECT total FROM accounts WHERE user_id = 4;

UPDATE accounts SET total = total - 2000 WHERE user_id = 4;
UPDATE accounts SET total = total + 2000 WHERE user_id IS NULL;

SELECT * FROM accounts;

COMMIT;



-- ЗАДАНИЕ 2
-- Мы можем и самостоятельно отменять транзакции.
START TRANSACTION;

SELECT total FROM accounts WHERE user_id = 4;
UPDATE accounts SET total = total - 2000 WHERE user_id = 4;
UPDATE accounts SET total = total + 2000 WHERE user_id IS NULL;

ROLLBACK;

SELECT * FROM accounts;


/* Для некоторых операторов нельзя выполнить откат при помощи оператора ROLLBACK. 
К их числу относят следующие команды:
CREATE INDEX
DROP INDEX
CREATE TABLE
DROP TABLE
TRUNCATE TABLE
ALTER TABLE
RENAME TABLE
CREATE DATABASE
DROP DATABASE
ALTER DATABASE */


/* 
Кроме того, существует ряд операторов, которые неявно завершают транзакцию, 
как если бы был вызван оператор COMMIT:
ALTER TABLE
BEGIN
CREATE INDEX
CREATE TABLE
CREATE DATABASE
DROP DATABASE
DROP INDEX
DROP TABLE
DROP DATABASE
LOAD MASTER DATA
LOCK TABLES
RENAME
SET AUTOCOMMIT=1
START TRANSACTION
TRUNCATE TABLE
*/


# ЗАДАНИЕ 3 
# SAVEPOINT

START TRANSACTION;
SELECT total FROM accounts WHERE user_id = 4;
SAVEPOINT accounts_4;
UPDATE accounts SET total = total - 2000 WHERE user_id = 4;

ROLLBACK TO SAVEPOINT accounts_4;


# ЗАДАНИЕ 4
# Режим автозавершения транзакций


SET AUTOCOMMIT=0;

SELECT total FROM accounts WHERE user_id = 4;
UPDATE accounts SET total = total - 2000 WHERE user_id = 4;
UPDATE accounts SET total = total + 2000 WHERE user_id IS NULL;
SELECT * FROM accounts;

ROLLBACK;
SELECT * FROM accounts;

SET AUTOCOMMIT=1;


/*
Транзакций недостаточно, если система не удовлетворяет принципу ACID. 
Аббревиатура ACID расшифровывается как атомарность, согласованность, изолированность и сохраняемость). 
Atomicy — атомарность.
Consistency — согласованность.
Isolation — изолированность.
Durability — сохраняемость.

# Уровни изоляции
READ UNCOMMITTED
Транзакция читает данные, записанные параллельной незавершённой транзакцией.

READ COMMITTED
Теперь Т2 видит все, что сделала Т1. 
Это так называемые феномен неповторяющегося чтения, 
когда мы видим обновленные и удаленные строки (UPDATE, DELETE), 
и феномен чтения фантомов, когда мы видим добавленные записи (INSERT).

REPEATABLE READ
Уровень, позволяющий предотвратить феномен неповторяющегося чтения. 
Т.е. мы не видим в исполняющейся транзакции измененные и удаленные 
записи другой транзакцией. Но все еще видим вставленные записи
из другой транзакции. Чтение фантомов никуда не уходит.

SERIALIZABLE
Самый высокий уровень изоляции, SERIALIZABLE, решает проблему фантомного чтения, 
заставляя транзакции выполняться в таком порядке, чтобы исключить возможность конфликта. 
Уровень SERIALIZABLE блокирует каждую строку, которую транзакция читает.

На этом уровне может возникать множество задержек и конфликтов при блокировках. 
На практике данный уровень изоляции применяется достаточно редко. 
*/

-- Изменить уровень изоляции можно при помощи команды SET TRANSACTION:

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;



-- Временная таблица
CREATE TEMPORARY TABLE temp (id INT, name VARCHAR(255));
SHOW TABLES;
DESCRIBE temp;



-- Динамические запросы
PREPARE ver FROM 'SELECT VERSION()';
EXECUTE ver;


# СОЗДАДИМ ТАБЛИЦЫ И ЗАПОЛНИМ ДАННЫМИ
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

SELECT id, name, price FROM products WHERE catalog_id = 1;

/* Запросы можно параметризовать, используя для этого символ вопросительного знака. */
PREPARE prd FROM 'SELECT id, name, price FROM products WHERE catalog_id = ?';

-- Как видно, вместо значения внешнего ключа catalog_id используется знак вопроса. 

-- Давайте зададим идентификатор раздела при помощи переменной:
SET @catalog_id = 2;

-- При вызове запроса при помощи оператора EXECUTE передать 
-- значение параметра можно при помощи конструкции USING.
EXECUTE prd USING @catalog_id;

/* Динамический запрос может иметь более одного параметра, 
в этом случае они перечисляются после ключевого слова 
USING через запятую в том порядке, в котором они встречаются в динамическом запросе. 

Динамические запросы имеют ряд ограничений: не допускается использование вложенных динамических запросов, 
а также нескольких сразу. Т.е., динамический запрос всегда представляет лишь один запрос. 
Параметр всегда передаёт строку, т.е., динамически задать имя таблицы или столбца не получится.
*/


-- Хранимые процедуры и функции

DELIMITER //;
SELECT VERSION()//

DELIMITER ;
SELECT VERSION();


DROP PROCEDURE IF EXISTS my_version;
DELIMITER //
CREATE PROCEDURE my_version ()
BEGIN
  SELECT VERSION();
END //

CALL my_version()//
DROP PROCEDURE my_version//


-- Функции
DROP FUNCTION IF EXISTS get_version//
CREATE FUNCTION get_version ()
RETURNS TEXT DETERMINISTIC -- при каждом вызове будет возвращаться одно и то же значение 
BEGIN -- Тело функции
  RETURN VERSION();
END //

SELECT get_version()//


/* Параметры:
* IN
* OUT
* INTOUT
Атрибуты IN, OUT и INOUT доступны лишь для хранимой процедуры, 
в хранимой функции все параметры всегда имеют атрибут IN. 

Использование ключевого слова IN не обязательно — если ни один из атрибут не указан, 
СУБД MySQL считает, что параметр объявлен с атрибутом IN.
*/

DROP PROCEDURE IF EXISTS set_x//
CREATE PROCEDURE set_x (IN value INT)
BEGIN
  SET @x = value;
END//

CALL set_x(123456)//

SELECT @x//


DROP PROCEDURE IF EXISTS set_x//
CREATE PROCEDURE set_x (IN value INT)
BEGIN
  SET @x = value;
  SET value = 1000;
END//

SET @y = 11234//
SELECT @y//
CALL set_x(@y)//
SELECT @x, @y//


/*При использовании модификатора OUT любые изменения 
параметра внутри процедуры отражаются на аргументе. */

DROP PROCEDURE IF EXISTS set_x//
CREATE PROCEDURE set_x (OUT value INT)
BEGIN
  SET @x = value;
  SET value = 1000;
END//

SET @y = 12456//
CALL set_x(@y)//
SELECT @x, @y//


/*Чтобы через параметр можно было и 
передать значение внутрь процедуры, и получить значение*/

DROP PROCEDURE IF EXISTS set_x//
CREATE PROCEDURE set_x (INOUT value INT)
BEGIN
  SET @x = value;
  SET value = value - 1000;
END//

SET @y = 10000//
CALL set_x(@y)//
SELECT @x, @y//


/* Часто требуется локальная переменная без необходимости 
передавать или возвращать с ее помощью какие-либо значения.ALTER

Команда DECLARE может появляться только внутри блока BEGIN...END, 
область видимости объявленной переменной также ограничена этим блоком.*/

DROP PROCEDURE IF EXISTS declare_var//
CREATE PROCEDURE declare_var ()
BEGIN
  DECLARE id, num INT DEFAULT 0;
  DECLARE name, hello, temp TINYTEXT;
END//

CALL declare_var()//

SELECT @id//

/* Один оператор DECLARE позволяет объявить сразу 
несколько переменных одного типа, причем необязательное слово 
DEFAULT позволяет назначить инициирующее значение. 

Те переменные, для которых не указывается ключевое слово DEFAULT, 
можно инициировать при помощи команды SET. */



/*Циклы
MySQL предоставляет три цикла: 
while, repeat и loop. Их можно использовать в теле хранимой процедуры 
или функции, т.е., между ключевыми словами BEGIN и END. */

DROP PROCEDURE IF EXISTS NOW3//
CREATE PROCEDURE NOW3 ()
BEGIN
  DECLARE i INT DEFAULT 5;
  WHILE i > 0 DO
	SELECT NOW();
    SET i = i - 1;
  END WHILE;
END//

CALL NOW3()//


DROP PROCEDURE IF EXISTS NOWN//
CREATE PROCEDURE NOWN (IN num INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  IF (num > 0) THEN
	WHILE i < num DO
  	  SELECT NOW();
  	  SET i = i + 1;
	END WHILE;
  ELSE
	SELECT 'Ошибочное значение параметра';
  END IF;
END//


CALL NOWN(2)//


/*Итак, у нас выводится только две даты. Для досрочного выхода из цикла предназначен оператор LEAVE.*/

DROP PROCEDURE IF EXISTS NOWN//
CREATE PROCEDURE NOWN (IN num INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  IF (num > 0) THEN
	cycle: WHILE i < num DO  # Создаём метку цикла
  	  IF i >= 2 THEN LEAVE cycle;  # Добавим условие на выход
  	  END IF;
  	  SELECT NOW();
  	  SET i = i + 1;
	END WHILE cycle;
  ELSE
	SELECT 'Ошибочное значение параметра';
  END IF;
END//


CALL NOWN(20)//


DROP PROCEDURE IF EXISTS NOW3//
CREATE PROCEDURE NOW3 ()
BEGIN
  DECLARE i INT DEFAULT 3;
  REPEAT
	SELECT NOW();
	SET i = i - 1;
  UNTIL 10 >= 0
  END REPEAT;
END//


CALL NOW3()//

/*Цикл LOOP, в отличие от операторов WHILE и REPEAT, не имеет условий выхода. 
Поэтому он должен обязательно иметь в составе оператор LEAVE. */


DROP PROCEDURE IF EXISTS NOW3//
CREATE PROCEDURE NOW3 ()
BEGIN
  DECLARE i INT DEFAULT 3;
  cycle: LOOP
	SELECT NOW();
	SET i = i - 1;
	IF i <= 0 THEN LEAVE cycle;
	END IF;
  END LOOP cycle;
END//


CALL NOW3()//



/* Триггер — специальная хранимая процедура, 
привязанная к событию изменения содержимого таблицы.*/


DROP TRIGGER IF EXISTS catalogs_count//
CREATE TRIGGER catalogs_count AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
  SELECT COUNT(*) INTO @total1 FROM catalogs;
END//


INSERT INTO catalogs VALUES (NULL, 'Мониторы12')//

SELECT * FROM catalogs//

SELECT @total1//


/* Давайте создадим триггер, который при вставке новой товарной 
позиции в таблицу products будет следить за состоянием внешнего ключа 
catalog_id. Если внешний ключ будет оставаться незаполненным, 
триггер будет извлекать из таблицы catalogs 
наименьший идентификатор id и назначать его записи. */

DROP TRIGGER IF EXISTS check_catalog_id_insert//
CREATE TRIGGER check_catalog_id_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  DECLARE cat_id INT;
  SELECT id INTO cat_id FROM catalogs ORDER BY id LIMIT 1;
  SET NEW.catalog_id = COALESCE(NEW.catalog_id, cat_id);
END//


SELECT * FROM products//


SELECT COALESCE(NULL, NULL, NULL, 1, 2, 3)//
SELECT COALESCE(NULL, 3, NULL)//


SELECT * FROM products//

INSERT INTO products
  (name, description, price)
VALUES
  ('Intel Core i987-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00)//
