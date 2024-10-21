### 1. START ###

-- Завантажте дані:
--
-- Створіть схему pandemic у базі даних за допомогою SQL-команди.
-- Оберіть її як схему за замовчуванням за допомогою SQL-команди.
-- Імпортуйте дані за допомогою Import wizard так, як ви вже робили це у темі 3.
-- Продивіться дані, щоб бути у контексті.
-- 💡 Як бачите, атрибути Entity та Code постійно повторюються. Позбудьтеся цього за допомогою нормалізації даних.

CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic;

CREATE TABLE IF NOT EXISTS infectious_cases (
    entity VARCHAR(255),
    code VARCHAR(10),
    year INT,
    number_yaws INT,
    polio_cases INT,
    cases_guinea_worm FLOAT,
    number_rabies FLOAT,
    number_malaria FLOAT,
    number_hiv FLOAT,
    number_tuberculosis FLOAT,
    number_smallpox INT,
    number_cholera_cases INT
);

### END ###

### 2. START ###

-- Нормалізуйте таблицю infectious_cases до 3ї нормальної форми.
-- Збережіть у цій же схемі дві таблиці з нормалізованими даними.

CREATE TABLE IF NOT EXISTS countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL,
    UNIQUE (entity, code)
);

CREATE TABLE IF NOT EXISTS disease_cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT,
    year INT NOT NULL,
    number_yaws INT,
    polio_cases INT,
    cases_guinea_worm FLOAT,
    number_rabies FLOAT,
    number_malaria FLOAT,
    number_hiv FLOAT,
    number_tuberculosis FLOAT,
    number_smallpox INT,
    number_cholera_cases INT,
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

INSERT INTO countries (entity, code)
    SELECT DISTINCT entity, code
        FROM infectious_cases
        WHERE code IS NOT NULL;

INSERT INTO disease_cases (country_id, year, number_yaws, polio_cases, cases_guinea_worm, number_rabies, number_malaria, number_hiv, number_tuberculosis, number_smallpox, number_cholera_cases)
    SELECT c.country_id, ic.year, ic.number_yaws, ic.polio_cases, ic.cases_guinea_worm, ic.number_rabies, ic.number_malaria, ic.number_hiv, ic.number_tuberculosis, ic.number_smallpox, ic.number_cholera_cases
        FROM infectious_cases ic
        JOIN countries c ON ic.entity = c.entity AND ic.code = c.code;

### END ###

### 3. START ###

SELECT
    c.entity,
    c.code,
    AVG(dc.number_rabies) AS mean_number_rabies,
    MIN(dc.number_rabies) AS min_number_rabies,
    MAX(dc.number_rabies) AS max_number_rabies,
    SUM(dc.number_rabies) AS sum_number_rabies
FROM countries c
         JOIN disease_cases dc ON c.country_id = dc.country_id
WHERE dc.number_rabies IS NOT NULL
GROUP BY c.entity, c.code
ORDER BY mean_number_rabies DESC
LIMIT 10;

### END ###

### 4. START ###

-- Побудуйте колонку різниці в роках.
--
-- Для оригінальної або нормованої таблиці для колонки Year побудуйте з використанням вбудованих SQL-функцій:
--
-- атрибут, що створює дату першого січня відповідного року,
-- 💡 Наприклад, якщо атрибут містить значення ’1996’, то значення нового атрибута має бути ‘1996-01-01’.
-- атрибут, що дорівнює поточній даті,
-- атрибут, що дорівнює різниці в роках двох вищезгаданих колонок.
-- 💡 Перераховувати всі інші атрибути, такі як Number_malaria, не потрібно.

SELECT
    country_id,
    year,
    STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d') AS start_of_year,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d'), CURDATE()) AS year_difference
FROM disease_cases;

### END ###

### 5. START ###

Побудуйте власну функцію.

-- Створіть і використайте функцію, що будує такий же атрибут, як і в попередньому завданні: функція має приймати на вхід значення року, а повертати різницю в роках між поточною датою та датою, створеною з атрибута року (1996 рік → ‘1996-01-01’).

DROP FUNCTION IF EXISTS calculate_year_difference;

DELIMITER //

CREATE FUNCTION calculate_year_difference(input_year INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE start_date DATE;
    DECLARE year_diff INT;

    -- Создаем дату 1 января на основе входного года
    SET start_date = STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d');

    -- Вычисляем разницу в годах между текущей датой и начальной датой
    SET year_diff = TIMESTAMPDIFF(YEAR, start_date, CURDATE());

RETURN year_diff;
END //

DELIMITER ;

SELECT
    country_id,
    year,
    calculate_year_difference(year) AS year_difference
FROM disease_cases;

### END ###