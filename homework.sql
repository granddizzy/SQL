DROP FUNCTION IF EXISTS format_seconds;
DELIMITER //
CREATE FUNCTION format_seconds(seconds INT)
RETURNS TEXT DETERMINISTIC
BEGIN
	DECLARE days INT;
	DECLARE hours INT;
	DECLARE minutes INT;
	DECLARE secs INT;
    
	SET days = seconds DIV (24 * 3600);
	SET seconds = seconds % (24 * 3600);
	SET hours = seconds DIV 3600;
	SET seconds = seconds % 3600;
	SET minutes = seconds DIV 60;
	SET secs = seconds % 60;

	RETURN CONCAT(days, ' days ', hours, ' hours ', minutes, ' minutes ', secs, ' seconds');
END //

SELECT format_seconds(86400) AS format_seconds//


DROP PROCEDURE IF EXISTS even_numbers//
CREATE PROCEDURE even_numbers(IN begin_num INT, IN end_num INT)
BEGIN
	DECLARE counter INT;
	IF begin_num % 2 != 0 THEN
		SET begin_num = begin_num + 1;
	END IF;
  SET counter = begin_num;
  WHILE counter <= end_num DO
		IF counter != 0 THEN
			SELECT counter;
		END IF;
		SET counter = counter + 2;
	END WHILE;
END //

CALL even_numbers(-3, 10) //