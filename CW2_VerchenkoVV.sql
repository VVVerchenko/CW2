-- -----------------------------------------------------------------------------
/*
1. ОПИСАНИЕ КП
В курсовом проекте представлена БД CRM-системы приборостроительной компании, в которую вносятся данные по выданным 
технико-коммерческим предложениям (ТКП, quotes), потенциальным сделкам (ПС, opportunities) и
размещённым в производство заказам (placement).
Имеются следующие таблицы:
1. regions - таблица возможных регионов (федеральных округов) для заказчиков и конечных пользователей
2. customers - таблица инжиниринговых компаний-посредников, которые закупают и устанавливают оборудование
3. end_users - таблица предприятий - конечных пользователей, на которые будет установлено оборудование
4. currency - таблица валют в которых производится оплата
5. factories - таблица заводов изготовителей
6. business_categories - таблица линеек продуктов, производимых компанией
7. quote_table - таблица выданных технико-коммерческих предложений
8. op_statuses - возможные статусы потенциальных сделок
9. opportunities - таблица потенциальных сделок
10. order_statuses - возможные статусы заказов размещённых в производство
11. placement - заказы размещённые в производство
12. sales_engineers - список инженеров поддержки продаж, которые занимаются подбором оборудования и выдачей ТКП
13. responsible_sellers - список ответственных продавцов, которые взаимодействуют с заказчиками, 
принимают решения по скидкам, подписывают спецификации, соглашения, договора
 */
-- -----------------------------------------------------------------------------

DROP DATABASE IF EXISTS CRM_IMC;
CREATE DATABASE CRM_IMC;
USE CRM_IMC;

-- -----------------------------------------------------------------------------
-- 2,3. СОЗДАНИЕ ТАБЛИЦ
-- -----------------------------------------------------------------------------

-- Табилца инженеров поддержки продаж
DROP TABLE IF EXISTS sales_engineers;
CREATE TABLE sales_engineers (
sales_engineer_account VARCHAR (40) NOT NULL UNIQUE PRIMARY KEY,
name VARCHAR (20) NOT NULL,
surname VARCHAR (20) NOT NULL,
email VARCHAR (40) NOT NULL,
phone BIGINT UNSIGNED NOT NULL,
password_hash VARCHAR(100) NOT NULL,
department VARCHAR (20) NOT NULL
);

-- Табилца ответственных продавцов
DROP TABLE IF EXISTS responsible_sellers;
CREATE TABLE responsible_sellers (
responsible_seller_account VARCHAR (40) NOT NULL UNIQUE PRIMARY KEY,
name VARCHAR (20) NOT NULL,
surname VARCHAR (20) NOT NULL,
email VARCHAR (40) NOT NULL,
phone BIGINT UNSIGNED NOT NULL,
password_hash VARCHAR(100) NOT NULL,
department VARCHAR (200) NOT NULL
);

-- Табица регионов
DROP TABLE IF EXISTS regions;
CREATE TABLE regions (
region VARCHAR (2) NOT NULL UNIQUE PRIMARY KEY,
region_name VARCHAR (100) NOT NULL 
);

-- Табица компаний - заказчиков
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
customer_name VARCHAR (100) NOT NULL UNIQUE PRIMARY KEY,
customer_region VARCHAR (2) NOT NULL,
FOREIGN KEY (customer_region) REFERENCES regions(region) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Табица компаний - конечных пользователей
DROP TABLE IF EXISTS end_users;
CREATE TABLE end_users (
end_user_name VARCHAR (100) NOT NULL UNIQUE PRIMARY KEY,
end_user_region VARCHAR (2) NOT NULL,
FOREIGN KEY (end_user_region) REFERENCES regions(region) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Табица категорий продуктов
DROP TABLE IF EXISTS business_categories;
CREATE TABLE business_categories (
business_category VARCHAR (40) NOT NULL UNIQUE PRIMARY KEY
);

-- Табица валюты расчёта
DROP TABLE IF EXISTS currencies;
CREATE TABLE currencies (
currency VARCHAR (3) NOT NULL UNIQUE PRIMARY KEY,
currency_course FLOAT NOT NULL
);

-- Таблица статусов потенциальных сделок
DROP TABLE IF EXISTS op_statuses;
CREATE TABLE op_statuses (
op_status VARCHAR (10) NOT NULL UNIQUE PRIMARY KEY
);

-- Табица выданный технико-коммерческих предложений
DROP TABLE IF EXISTS quote_table;
CREATE TABLE quote_table (
quote_number VARCHAR (20) NOT NULL UNIQUE PRIMARY KEY, 
sales_engineer_account VARCHAR (40) NOT NULL,
FOREIGN KEY (sales_engineer_account) REFERENCES sales_engineers(sales_engineer_account) ON UPDATE CASCADE ON DELETE NO ACTION,
business_category VARCHAR (100) NOT NULL,
FOREIGN KEY (business_category) REFERENCES business_categories(business_category) ON UPDATE CASCADE ON DELETE NO ACTION,
sent_date DATE NOT NULL,
currency VARCHAR (3) NOT NULL,
FOREIGN KEY (currency) REFERENCES currencies(currency) ON UPDATE CASCADE ON DELETE NO ACTION,
amount FLOAT UNSIGNED
);

-- Таблица потенциальных сделок
DROP TABLE IF EXISTS opportunities;
CREATE TABLE opportunities (
opportunity_name VARCHAR (500) NOT NULL UNIQUE PRIMARY KEY,
customer VARCHAR (100) DEFAULT 'direct order',
FOREIGN KEY (customer) REFERENCES customers(customer_name) ON UPDATE CASCADE ON DELETE NO ACTION,
end_user VARCHAR (100) NOT NULL,
FOREIGN KEY (end_user) REFERENCES end_users(end_user_name) ON UPDATE CASCADE ON DELETE NO ACTION,
responsible_seller_account VARCHAR (100) NOT NULL,
FOREIGN KEY (responsible_seller_account) REFERENCES responsible_sellers(responsible_seller_account) ON UPDATE CASCADE ON DELETE NO ACTION,
quote_number VARCHAR (20) NOT NULL,
FOREIGN KEY (quote_number) REFERENCES quote_table(quote_number) ON UPDATE CASCADE ON DELETE NO ACTION,
currency VARCHAR (3) NOT NULL,
FOREIGN KEY (currency) REFERENCES currencies(currency) ON UPDATE CASCADE ON DELETE NO ACTION,
amount FLOAT UNSIGNED,
win_probability INT,
op_status VARCHAR (10) NOT NULL,
FOREIGN KEY (op_status) REFERENCES op_statuses(op_status) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Таблица заводов
DROP TABLE IF EXISTS factories;
CREATE TABLE factories (
factory_name VARCHAR (100) NOT NULL UNIQUE PRIMARY KEY,
country VARCHAR (100) NOT NULL UNIQUE,
phone BIGINT UNSIGNED NOT NULL,
currency VARCHAR (3) NOT NULL,
FOREIGN KEY (currency) REFERENCES currencies(currency) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Таблица статусов размещённых заказов
DROP TABLE IF EXISTS order_statuses;
CREATE TABLE order_statuses (
order_status VARCHAR (50) NOT NULL UNIQUE PRIMARY KEY
);

-- Таблица размещённых заказов
DROP TABLE IF EXISTS placement;
CREATE TABLE placement (
order_number VARCHAR (500) NOT NULL UNIQUE PRIMARY KEY,
factory_name VARCHAR (100) NOT NULL,
FOREIGN KEY (factory_name) REFERENCES factories(factory_name) ON UPDATE CASCADE ON DELETE NO ACTION,
order_status VARCHAR (50) NOT NULL,
FOREIGN KEY (order_status) REFERENCES order_statuses(order_status) ON UPDATE CASCADE ON DELETE NO ACTION,
quote_number VARCHAR (20) NOT NULL,
FOREIGN KEY (quote_number) REFERENCES quote_table(quote_number) ON UPDATE CASCADE ON DELETE NO ACTION,
currency VARCHAR (3) NOT NULL,
FOREIGN KEY (currency) REFERENCES currencies(currency) ON UPDATE CASCADE ON DELETE NO ACTION,
amount FLOAT UNSIGNED
);

-- -----------------------------------------------------------------------------
-- 5. ЗАПОЛНЕНИЕ ТАБЛИЦ
-- -----------------------------------------------------------------------------

-- заполнение таблицы категорий продуктов
INSERT business_categories (business_category) VALUES
('Combustion'),
('Liquid'),
('Flame_&_Gas'),
('Process_gas'),
('Gas_chromatographs'),
('Pressure'),
('Temperature'),
('Flow'),
('Level'),
('Valves_&_Regulators'),
('APCS')
;

-- заполнение таблицы доступных валют
INSERT currencies (currency, currency_course) VALUES
('RUB', 1),
('USD', 70.34),
('EUR', 75.66),
('CNY', 9.89),
('CHF', 76.18),
('GBP', 84.79),
('JPY', 0.5306)
;

-- заполнение таблицы регионов
INSERT regions (region, region_name) VALUES
('NW', 'Northwest'),
('CS', 'Center_and_South'),
('VL', 'Volga'),
('UR', 'Ural'),
('SB', 'Siberia'),
('FE', 'Far_East')
;


-- заполнение таблицы заказчиков
INSERT customers (customer_name, customer_region) VALUES
('АО "Ангарскнефтехимпроект"', 'SB'),
('АО "ГМС Нефтемаш"', 'UR'),
('АО "РЭП Холдинг"', 'NW'),
('АО "Электронстандарт-прибор"', 'NW'),
('НПК "ВОЛГА-АВТОМАТИКА"', 'VL'),
('ООО " НПК ИТР"', 'VL'),
('ООО "Автоматика Сервис"', 'UR'),
('ООО "АЙ-ТИ-СИ"', 'CS'),
('ООО "АЛМАЗ ГРУПП"', 'UR'),
('ООО "Альматэкс"', 'CS'),
('ООО "АумаПриводСервис"', 'UR'),
('ООО "АЭРОЗОЛЕКС"', 'VL'),
('ООО "Бантер Групп"', 'UR'),
('ООО "Велесстрой"', 'CS'),
('ООО "ВЕЛМАС"', 'NW'),
('ООО "ГАЗСЕНСОР"', 'CS'),
('ООО "ГИДРОТЕХ"', 'UR'),
('ООО "Дельта Инжиниринг"', 'UR'),
('ООО "Комбит Про"', 'CS'),
('ООО "КЭР-Автоматика"', 'VL'),
('ООО "Метрол"', 'VL'),
('ООО "Метрология-Комплект"', 'CS'),
('ООО "МНУ-1 Корпорации АК "ЭСКМ"', 'CS'),
('ООО "НПО "ЭКОХИМПРИБОР"', 'CS'),
('ООО "Осмотикс"', 'NW'),
('ООО "РЕКОН"', 'CS'),
('ООО "РЕМОНТ-СЕРВИС"', 'UR'),
('ООО "РусПромЭнергоСистемы"', 'CS'),
('ООО "СМС"', 'UR'),
('ООО "СНЭМА-Сервис"', 'VL'),
('ООО "Стройтехлогистика"', 'CS'),
('ООО "Стронгарм"', 'NW'),
('ООО "ТД "Автоматика"', 'CS'),
('ООО "Технологии АСУ"', 'CS'),
('ООО "Торгово-промышленная компания "Союз"', 'VL'),
('ООО "Химсталькон-Инжиниринг"', 'VL'),
('ООО "ХРОМОС Инжиниринг"', 'VL'),
('ООО "Энергия холода"', 'NW'),
('ООО "Энтренс Электроникс"', 'CS'),
('ООО "Эртей Петрошем Рус" ', 'NW'),
('ООО "ЭТМ"', 'UR')
;


-- заполнение таблицы конечных пользователей
INSERT end_users (end_user_name, end_user_region) VALUES
('АО "КазТрансГаз"', 'CS'),
('Erdemir Group, ИСКЕНДЕРУНСКИЙ МЕТАЛЛУРГИЧЕСКИЙ КОМБИНАТ', 'CS'),
('Exxon Neftegas Limited - Chayvo OPF', 'FE'),
('Store (SEIC)', 'FE'),
('АО "Ангарская нефтехимическая компания"', 'SB'),
('АО "АНПЗ ВНК"', 'SB'),
('АО "Апатит"', 'NW'),
('АО "Ачинский НПЗ ВНК"', 'SB'),
('АО "Башнефть-Уфанефтехим"', 'VL'),
('АО "ВЧНГ"', 'SB'),
('АО "Газпромнефть-МНПЗ"', 'CS'),
('АО "Газпромнефть-ОНПЗ"', 'SB'),
('АО "ГМС Нефтемаш"', 'UR'),
('АО "Интер РАО электрогенерация - филиал "Пермская ГРЭС"', 'VL'),
('АО "КАУСТИК"', 'CS'),
('АО "Мессояханефтегаз"', 'UR'),
('АО "Невинномысский Азот"', 'CS'),
('АО "ННК-Хабаровский нефтеперерабатывающий завод"', 'SB'),
('АО "Новокуйбышевский НПЗ"', 'VL'),
('АО "Оренбургнефть"', 'VL'),
('АО "ОЭМК"', 'CS'),
('АО "РНПК"', 'CS'),
('АО "Роспан Интернешнл"', 'UR'),
('АО "Рязанская НПК"', 'CS'),
('АО "Сегежский ЦБК"', 'NW'),
('АО "СИБУР - Нефтехим"', 'VL'),
('АО "СИБУР-Химпром"', 'VL'),
('АО "Сызранский НПЗ"', 'VL'),
('АО "Тюменнефтегаз"', 'UR'),
('АО "Челябинский цинковый завод"', 'UR'),
('АО "НЗНП"', 'CS'),
('АО "РНГ"', 'FE'),
('ГК "Туркменгаз"', 'VL'),
('ЗАО "Омский завод инновационных технологий"', 'SB'),
('Институт физической химии и электрохимии РАН', 'CS'),
('ООО "Красноленинский НПЗ"', 'UR'),
('ОАО "АЛРОСА-Газ"', 'FE'),
('ОАО "Бабушкина крынка"', 'CS'),
('ОАО "ГМЗ"', 'SB'),
('ОАО "Нафтан"', 'CS'),
('ОАО "Сызранский НПЗ"', 'VL'),
('ОАО "Щекиноазот"', 'CS'),
('ОАО "Ямал СПГ"', 'UR'),
('ОАО "Пермская ГРЭС" ', 'VL'),
('ООО "Арктик СПГ 2"', 'UR'),
('ООО "Астон Крахмало-Продукты"', 'CS'),
('ООО "Афипский НПЗ"', 'CS'),
('ООО "ВПК-Ойл"', 'SB'),
('ООО "Газ Синтез"', 'NW'),
('ООО "ГАЗПРОМ НЕФТЕХИМ САЛАВАТ"', 'VL'),
('ООО "Газпром переработка Благовещенск"', 'FE'),
('ООО "Газпром ПХГ" "Песчано - Уметское УПХГ"', 'VL'),
('ООО "Газпромнефть - Ямал"', 'UR'),
('ООО "Газпромнефть - Восток" ', 'SB'),
('ООО "Газпромнефть - Заполярье" ', 'UR'),
('ООО "Газпромнефть - Оренбург"', 'VL'),
('ООО "Газпромнефть - Хантос"', 'UR'),
('ООО "Гипробиосинтез"', 'CS'),
('ООО "ИЛЬСКИЙ НПЗ"', 'CS'),
('ООО "ИНК"', 'SB'),
('ООО "КИНЕФ"', 'NW'),
('ООО "Криогаз-Высоцк"', 'NW'),
('ООО "ЛУКОЙЛ - Нижегороднефтеоргсинтез"', 'VL'),
('ООО "ЛУКОЙЛ-Пермьнефтеоргсинтез"', 'VL'),
('ООО "НевРСС" ', 'CS'),
('ООО "НЗМП"', 'VL'),
('ООО "Новатор"', 'UR'),
('ООО "Новатэк-Юрхаровнефтегаз"', 'UR'),
('ООО "Новороссийский мазутный терминал"', 'CS'),
('ООО "Няганьгазпереработка"', 'UR'),
('ООО "Ока-Синтез"', 'VL'),
('ООО "ПКФ "УралРеаХим" ', 'UR'),
('ООО "ПОРТЭНЕРГО"', 'NW'),
('ООО "Промышленные газы"', 'VL'),
('ООО "Пурнефтепереработка"', 'UR'),
('ООО "РН - Ставропольнефтегаз"', 'CS'),
('ООО "РН-Восточный Нефтехимический Терминал"', 'FE'),
('ООО "РН-Пурнефтегаз"', 'UR'),
('ООО "РН-Туапсинский НПЗ"', 'CS'),
('ООО "СевКомНефтегаз"', 'UR'),
('ООО "СИБУР Тобольск"', 'UR'),
('ООО "Синергия-Лидер"', 'VL'),
('ООО "Славнефть-Красноярскнефтегаз"', 'SB'),
('ООО "Славянск ЭКО"', 'CS'),
('ООО "Соровскнефть"', 'UR'),
('ООО "Ставролен"', 'CS'),
('ООО "ТаграС-РемСервис"', 'VL'),
('ООО "Тагульское"', 'SB'),
('ООО "Таймырская топливная компания"', 'SB'),
('ООО "ТиссенКрупп Индастриал Солюшнс (РУС)"', 'VL'),
('ООО "ТУЛАЧЕРМЕТ-СТАЛЬ"', 'CS'),
('ООО “ЛУКОЙЛ-Коми” (Усинский ГПЗ)', 'NW'),
('ООО ИК "СИБИНТЕК"', 'CS'),
('ООО "ЛУКОЙЛ-Пермнефтеоргсинтез"', 'VL'),
('ООО "Тольяттикаучук"', 'VL'),
('ОЭЗ "Алабуга"', 'VL'),
('ПАО "Казаньоргсинтез"', 'CS'),
('ПАО "Квадра"- "Воронежская Генерация"', 'CS'),
('ПАО "Нижнекамскнефтехим"', 'VL'),
('ПАО "ННК-Хабаровскнефтепродукт"', 'SB'),
('ПАО "РусГидро" Усть-Среднеканская ГЭС', 'FE'),
('ПАО "Северсталь"', 'NW'),
('ПАО "Славнефть-ЯНОС"', 'CS'),
('ПАО "Химпром"', 'VL'),
('ПАО "Энел Россия", ф-л "Невинномысская ГРЭС"', 'NW'),
('ПАО АНК "Башнефть"', 'VL'),
('УГПЗ ООО "ЛУКОЙЛ-Коми"', 'NW')
;


-- заполнение таблицы статусов потенциальных сделок
INSERT op_statuses (op_status) VALUES
('at_work'),
('won'),
('lost'),
('canceled')
;

-- заполнение таблицы инженеров поддержки продаж
INSERT sales_engineers (sales_engineer_account, name, surname, email, phone, password_hash, department) VALUES
('Fedor_Ermakov', 'Фёдор', 'Ермаков', 'Fedor.Ermakov@Technomanage.com', 89012414548, '35b821ee5d9fe2419a7bd414ebaa1f19', 'TPFL'),
('Lev_Ilyin', 'Лев', 'Ильин', 'Lev.Ilyin@Technomanage.com', 89150043899, 'fa4dba1b86be99d3e0ce7b92d0a0c809', 'TPFL'),
('Nikolay_Lazarev', 'Николай', 'Лазарев', 'Nikolay.Lazarev@Technomanage.com', 89169533645, '84c4139cead73d7b93159dff49376638', 'TPFL'),
('Alexander_Gavrilov', 'Александр', 'Гаврилов', 'Alexander.Gavrilov@Technomanage.com', 89019538735, '4da50fc9feb6e99a8c12029c14dc37f5', 'VR'),
('Gleb_Grigoriev', 'Глеб', 'Григорьев', 'Gleb.Grigoriev@Technomanage.com', 89055486925, '3357a53ce4cafe1bd22536790c814e78', 'VR'),
('Maxim_Melnikov', 'Максим', 'Мельников', 'Maxim.Melnikov@Technomanage.com', 89149861969, '818167e24b30ab52d869626259a4c6f4', 'APCS'),
('Dmitry_Simonov', 'Дмитрий', 'Симонов', 'Dmitry.Simonov@Technomanage.com', 89165144437, '0cd852414a9a0cd862b8ac6d8396084e', 'APCS'),
('Stanislav_Kuznetsov', 'Станислав', 'Кузнецов', 'Stanislav.Kuznetsov@Technomanage.com', 89084532637, 'cc44479583d657f412f71faa1a73c90f', 'Analytical'),
('Anton_Konovalov', 'Антон', 'Коновалов', 'Anton.Konovalov@Technomanage.com', 89160288778, '35ca055b89eb5d35bddc9142d0507f9e', 'Analytical'),
('Vadim_Verchenko', 'Вадим', 'Верченко', 'Vadim.Verchenko@Technomanage.com', 89174255210, '73bc66f027bc94656eaffffa2a22dcb6', 'Analytical')
;

-- заполнение ответственных за потенциальную сделку
INSERT responsible_sellers (responsible_seller_account, name, surname, email, phone, password_hash, department) VALUES
('Demyan_Andrianov', 'Демьян', 'Андрианов', 'Demyan.Andrianov@Technomanage.com', 89200657396, '033dddacd5a5b2498c0ccd8b56442921', 'General_sales_department'),
('Luka_Kuznetsov', 'Лука', 'Кузнецов', 'Luka.Kuznetsov@Technomanage.com', 89216378439, 'af3997957ed7f710731c350a7cc17e58', 'General_sales_department'),
('Vladislav_Volkov', 'Владислав', 'Волков', 'Vladislav.Volkov@Technomanage.com', 89071199835, '29393ca78abc513446ec535b8cfa750e', 'General_sales_department'),
('Ivan_Belov', 'Иван', 'Белов', 'Ivan.Belov@Technomanage.com', 89109069632, 'eae248ac2f4cd05ad9b922e934408bad', 'General_sales_department'),
('Vladimir_Galkin', 'Владимир', 'Галкин', 'Vladimir.Galkin@Technomanage.com', 89093077372, '7d0770e31b53846b67b95774181e456f', 'NW_sales_department'),
('Pyotr_Kondrashov', 'Пётр', 'Кондрашов', 'Pyotr.Kondrashov@Technomanage.com', 89146478653, '1c9020b37ba73bc69f6fde6f157eb08a', 'CS_sales_department'),
('Vladislav_Shishkin', 'Владислав', 'Шишкин', 'Vladislav.Shishkin@Technomanage.com', 89206773101, '8d4c9c8467f7c896adc7829726541f08', 'VL_sales_department'),
('Fedor_Bychkov', 'Фёдор', 'Бычков', 'Fedor.Bychkov@Technomanage.com', 89016367885, '521a78d7748181e91215b1b5fb8bae33', 'UR_sales_department'),
('Georgy_Romanov', 'Георгий', 'Романов', 'Georgy.Romanov@Technomanage.com', 89106280780, '0e64673ee8ad7a05aca3c472dfb07486', 'SB_sales_department'),
('Maxim_Kuznetsov', 'Максим', 'Кузнецов', 'Maxim.Kuznetsov@Technomanage.com', 89033076840, 'ecb9129295e5efc63f64d2b6bc2c1df8', 'FE_sales_department')
;

-- заполнение таблицы технико-коммерческих предложений
INSERT quote_table (quote_number, sales_engineer_account, business_category, sent_date, currency, amount) VALUES
('q10000000', 'Vadim_Verchenko', 'Gas_chromatographs', '2020-01-01', 'USD', 48297),
('q10000001', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-01-02', 'GBP', 22900),
('q10000002', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-01-04', 'JPY', 39242323),
('q10000003', 'Stanislav_Kuznetsov', 'Combustion', '2020-01-07', 'RUB', 1276882),
('q10000004', 'Stanislav_Kuznetsov', 'Process_gas', '2020-01-09', 'GBP', 392),
('q10000005', 'Nikolay_Lazarev', 'Temperature', '2020-01-11', 'JPY', 4881113),
('q10000006', 'Maxim_Melnikov', 'APCS', '2020-01-13', 'CNY', 156398),
('q10000007', 'Maxim_Melnikov', 'APCS', '2020-01-15', 'CNY', 75696),
('q10000008', 'Anton_Konovalov', 'Combustion', '2020-01-18', 'GBP', 19170),
('q10000009', 'Dmitry_Simonov', 'APCS', '2020-01-20', 'CHF', 21575),
('q10000010', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-01-23', 'USD', 40205),
('q10000011', 'Anton_Konovalov', 'Flame_&_Gas', '2020-01-25', 'USD', 9516),
('q10000012', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-01-27', 'CNY', 279461),
('q10000013', 'Maxim_Melnikov', 'APCS', '2020-01-29', 'USD', 220344),
('q10000014', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-01-31', 'GBP', 7713),
('q10000015', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-02-01', 'CHF', 36533),
('q10000016', 'Fedor_Ermakov', 'Level', '2020-02-01', 'JPY', 40963),
('q10000017', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-02-02', 'GBP', 30732),
('q10000018', 'Anton_Konovalov', 'Combustion', '2020-02-03', 'GBP', 19154),
('q10000019', 'Lev_Ilyin', 'Temperature', '2020-02-05', 'JPY', 2783905),
('q10000020', 'Fedor_Ermakov', 'Flow', '2020-02-05', 'CHF', 45892),
('q10000021', 'Nikolay_Lazarev', 'Pressure', '2020-02-07', 'JPY', 4036397),
('q10000022', 'Dmitry_Simonov', 'APCS', '2020-02-09', 'EUR', 32765),
('q10000023', 'Lev_Ilyin', 'Flow', '2020-02-12', 'RUB', 11833509),
('q10000024', 'Maxim_Melnikov', 'APCS', '2020-02-12', 'GBP', 25043),
('q10000025', 'Dmitry_Simonov', 'APCS', '2020-02-12', 'EUR', 37000),
('q10000026', 'Lev_Ilyin', 'Temperature', '2020-02-13', 'GBP', 34537),
('q10000027', 'Fedor_Ermakov', 'Pressure', '2020-02-15', 'JPY', 1972463),
('q10000028', 'Lev_Ilyin', 'Pressure', '2020-02-18', 'CNY', 43875),
('q10000029', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-02-20', 'USD', 120097),
('q10000030', 'Anton_Konovalov', 'Liquid', '2020-02-22', 'USD', 252393),
('q10000031', 'Stanislav_Kuznetsov', 'Liquid', '2020-02-23', 'USD', 151477),
('q10000032', 'Anton_Konovalov', 'Combustion', '2020-02-24', 'GBP', 10199),
('q10000033', 'Fedor_Ermakov', 'Temperature', '2020-02-25', 'CNY', 84828),
('q10000034', 'Fedor_Ermakov', 'Pressure', '2020-02-28', 'CNY', 98469),
('q10000035', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-03-02', 'GBP', 36369),
('q10000036', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-03-04', 'CHF', 22531),
('q10000037', 'Vadim_Verchenko', 'Liquid', '2020-03-06', 'EUR', 169042),
('q10000038', 'Maxim_Melnikov', 'APCS', '2020-03-07', 'EUR', 46317),
('q10000039', 'Dmitry_Simonov', 'APCS', '2020-03-07', 'JPY', 5663523),
('q10000040', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-03-09', 'EUR', 17373),
('q10000041', 'Nikolay_Lazarev', 'Temperature', '2020-03-09', 'GBP', 29120),
('q10000042', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-03-10', 'GBP', 29546),
('q10000043', 'Fedor_Ermakov', 'Level', '2020-03-13', 'CNY', 102068),
('q10000044', 'Dmitry_Simonov', 'APCS', '2020-03-13', 'GBP', 12883),
('q10000045', 'Fedor_Ermakov', 'Temperature', '2020-03-15', 'RUB', 1149496),
('q10000046', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-03-16', 'USD', 31403),
('q10000047', 'Dmitry_Simonov', 'APCS', '2020-03-19', 'RUB', 1647996),
('q10000048', 'Maxim_Melnikov', 'APCS', '2020-03-22', 'JPY', 37591467),
('q10000049', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-03-22', 'EUR', 48451),
('q10000050', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-03-23', 'RUB', 11755573),
('q10000051', 'Dmitry_Simonov', 'APCS', '2020-03-26', 'GBP', 1688),
('q10000052', 'Dmitry_Simonov', 'APCS', '2020-03-29', 'EUR', 18551),
('q10000053', 'Lev_Ilyin', 'Temperature', '2020-03-30', 'USD', 250452),
('q10000054', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-04-02', 'RUB', 2961173),
('q10000055', 'Stanislav_Kuznetsov', 'Gas_chromatographs', '2020-04-05', 'JPY', 2955844),
('q10000056', 'Nikolay_Lazarev', 'Level', '2020-04-08', 'JPY', 6487294),
('q10000057', 'Anton_Konovalov', 'Combustion', '2020-04-09', 'EUR', 42248),
('q10000058', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-04-09', 'CHF', 2419),
('q10000059', 'Maxim_Melnikov', 'APCS', '2020-04-12', 'USD', 49180),
('q10000060', 'Stanislav_Kuznetsov', 'Combustion', '2020-04-14', 'CHF', 13085),
('q10000061', 'Fedor_Ermakov', 'Pressure', '2020-04-17', 'JPY', 6554108),
('q10000062', 'Vadim_Verchenko', 'Liquid', '2020-04-19', 'RUB', 14241810),
('q10000063', 'Vadim_Verchenko', 'Flame_&_Gas', '2020-04-21', 'USD', 37628),
('q10000064', 'Vadim_Verchenko', 'Flame_&_Gas', '2020-04-22', 'GBP', 20673),
('q10000065', 'Fedor_Ermakov', 'Level', '2020-04-23', 'RUB', 2426449),
('q10000066', 'Stanislav_Kuznetsov', 'Liquid', '2020-04-24', 'EUR', 1678),
('q10000067', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-04-27', 'USD', 1839),
('q10000068', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-04-27', 'RUB', 1284127),
('q10000069', 'Maxim_Melnikov', 'APCS', '2020-04-28', 'USD', 39151),
('q10000070', 'Maxim_Melnikov', 'APCS', '2020-04-28', 'RUB', 801665),
('q10000071', 'Maxim_Melnikov', 'APCS', '2020-04-30', 'EUR', 34070),
('q10000072', 'Dmitry_Simonov', 'APCS', '2020-05-03', 'EUR', 14621),
('q10000073', 'Fedor_Ermakov', 'Pressure', '2020-05-04', 'EUR', 8563),
('q10000074', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-05-04', 'USD', 134907),
('q10000075', 'Fedor_Ermakov', 'Temperature', '2020-05-06', 'CHF', 9729),
('q10000076', 'Anton_Konovalov', 'Process_gas', '2020-05-07', 'CHF', 16082),
('q10000077', 'Dmitry_Simonov', 'APCS', '2020-05-09', 'GBP', 9765),
('q10000078', 'Stanislav_Kuznetsov', 'Combustion', '2020-05-10', 'GBP', 243892),
('q10000079', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-05-11', 'CNY', 102822),
('q10000080', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-05-13', 'CNY', 198986),
('q10000081', 'Stanislav_Kuznetsov', 'Combustion', '2020-05-14', 'CNY', 281140),
('q10000082', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-05-15', 'EUR', 44102),
('q10000083', 'Vadim_Verchenko', 'Flame_&_Gas', '2020-05-18', 'CNY', 21984),
('q10000084', 'Fedor_Ermakov', 'Pressure', '2020-05-18', 'JPY', 6141162),
('q10000085', 'Fedor_Ermakov', 'Temperature', '2020-05-19', 'GBP', 28143),
('q10000086', 'Dmitry_Simonov', 'APCS', '2020-05-22', 'JPY', 6506649),
('q10000087', 'Dmitry_Simonov', 'APCS', '2020-05-25', 'USD', 131963),
('q10000088', 'Dmitry_Simonov', 'APCS', '2020-05-27', 'EUR', 24563),
('q10000089', 'Dmitry_Simonov', 'APCS', '2020-05-28', 'RUB', 986237),
('q10000090', 'Vadim_Verchenko', 'Liquid', '2020-05-31', 'CHF', 32444),
('q10000091', 'Maxim_Melnikov', 'APCS', '2020-06-02', 'EUR', 29883),
('q10000092', 'Nikolay_Lazarev', 'Temperature', '2020-06-03', 'CHF', 21416),
('q10000093', 'Dmitry_Simonov', 'APCS', '2020-06-04', 'GBP', 8612),
('q10000094', 'Vadim_Verchenko', 'Liquid', '2020-06-07', 'CNY', 278167),
('q10000095', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-06-10', 'JPY', 4232994),
('q10000096', 'Stanislav_Kuznetsov', 'Flame_&_Gas', '2020-06-10', 'USD', 35505),
('q10000097', 'Maxim_Melnikov', 'APCS', '2020-06-10', 'USD', 60002),
('q10000098', 'Fedor_Ermakov', 'Flow', '2020-06-13', 'EUR', 31860),
('q10000099', 'Dmitry_Simonov', 'APCS', '2020-06-13', 'CNY', 235166),
('q10000100', 'Fedor_Ermakov', 'Flow', '2020-06-15', 'CNY', 197905),
('q10000101', 'Fedor_Ermakov', 'Pressure', '2020-06-17', 'CHF', 35885),
('q10000102', 'Stanislav_Kuznetsov', 'Process_gas', '2020-06-18', 'JPY', 3502550),
('q10000103', 'Maxim_Melnikov', 'APCS', '2020-06-18', 'CNY', 1678708),
('q10000104', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-06-18', 'USD', 42542),
('q10000105', 'Vadim_Verchenko', 'Liquid', '2020-06-20', 'EUR', 826),
('q10000106', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-06-21', 'USD', 35824),
('q10000107', 'Fedor_Ermakov', 'Temperature', '2020-06-23', 'RUB', 14000685),
('q10000108', 'Dmitry_Simonov', 'APCS', '2020-06-26', 'USD', 125015),
('q10000109', 'Fedor_Ermakov', 'Pressure', '2020-06-27', 'JPY', 4575282),
('q10000110', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-06-29', 'CNY', 29139),
('q10000111', 'Anton_Konovalov', 'Flame_&_Gas', '2020-06-29', 'CNY', 124585),
('q10000112', 'Maxim_Melnikov', 'APCS', '2020-07-02', 'RUB', 3094116),
('q10000113', 'Maxim_Melnikov', 'APCS', '2020-07-02', 'JPY', 19557330),
('q10000114', 'Dmitry_Simonov', 'APCS', '2020-07-03', 'CHF', 13123),
('q10000115', 'Maxim_Melnikov', 'APCS', '2020-07-04', 'USD', 214559),
('q10000116', 'Maxim_Melnikov', 'APCS', '2020-07-06', 'RUB', 2662650),
('q10000117', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-07-08', 'CHF', 45872),
('q10000118', 'Anton_Konovalov', 'Combustion', '2020-07-08', 'RUB', 2156413),
('q10000119', 'Dmitry_Simonov', 'APCS', '2020-07-11', 'RUB', 3325253),
('q10000120', 'Anton_Konovalov', 'Process_gas', '2020-07-14', 'CHF', 36246),
('q10000121', 'Nikolay_Lazarev', 'Pressure', '2020-07-17', 'CHF', 236483),
('q10000122', 'Dmitry_Simonov', 'APCS', '2020-07-19', 'USD', 297763),
('q10000123', 'Stanislav_Kuznetsov', 'Flame_&_Gas', '2020-07-19', 'CNY', 1838285),
('q10000124', 'Dmitry_Simonov', 'APCS', '2020-07-22', 'CNY', 1432681),
('q10000125', 'Anton_Konovalov', 'Liquid', '2020-07-22', 'RUB', 3143424),
('q10000126', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-07-24', 'JPY', 3187174),
('q10000127', 'Dmitry_Simonov', 'APCS', '2020-07-26', 'JPY', 1514577),
('q10000128', 'Fedor_Ermakov', 'Flow', '2020-07-26', 'JPY', 6114383),
('q10000129', 'Dmitry_Simonov', 'APCS', '2020-07-27', 'GBP', 40403),
('q10000130', 'Maxim_Melnikov', 'APCS', '2020-07-29', 'USD', 9690),
('q10000131', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-07-30', 'RUB', 2642041),
('q10000132', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-07-31', 'GBP', 4788),
('q10000133', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-08-02', 'EUR', 31740),
('q10000134', 'Maxim_Melnikov', 'APCS', '2020-08-03', 'CNY', 36962),
('q10000135', 'Maxim_Melnikov', 'APCS', '2020-08-04', 'USD', 20052),
('q10000136', 'Stanislav_Kuznetsov', 'Combustion', '2020-08-05', 'CHF', 267672),
('q10000137', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-08-07', 'CNY', 243210),
('q10000138', 'Dmitry_Simonov', 'APCS', '2020-08-08', 'CNY', 353407),
('q10000139', 'Stanislav_Kuznetsov', 'Combustion', '2020-08-10', 'CNY', 104649),
('q10000140', 'Fedor_Ermakov', 'Temperature', '2020-08-11', 'GBP', 98739),
('q10000141', 'Vadim_Verchenko', 'Process_gas', '2020-08-11', 'CNY', 1296774),
('q10000142', 'Dmitry_Simonov', 'APCS', '2020-08-13', 'RUB', 1442111),
('q10000143', 'Vadim_Verchenko', 'Flame_&_Gas', '2020-08-16', 'CNY', 335641),
('q10000144', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-08-18', 'EUR', 205),
('q10000145', 'Maxim_Melnikov', 'APCS', '2020-08-18', 'GBP', 3784),
('q10000146', 'Lev_Ilyin', 'Level', '2020-08-21', 'JPY', 2755801),
('q10000147', 'Nikolay_Lazarev', 'Temperature', '2020-08-23', 'CHF', 20977),
('q10000148', 'Fedor_Ermakov', 'Temperature', '2020-08-25', 'USD', 39151),
('q10000149', 'Nikolay_Lazarev', 'Temperature', '2020-08-26', 'GBP', 3271),
('q10000150', 'Dmitry_Simonov', 'APCS', '2020-08-28', 'USD', 23461),
('q10000151', 'Dmitry_Simonov', 'APCS', '2020-08-29', 'JPY', 3211566),
('q10000152', 'Maxim_Melnikov', 'APCS', '2020-08-30', 'EUR', 45939),
('q10000153', 'Vadim_Verchenko', 'Process_gas', '2020-09-02', 'JPY', 22026787),
('q10000154', 'Dmitry_Simonov', 'APCS', '2020-09-02', 'CHF', 11936),
('q10000155', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-09-02', 'GBP', 239460),
('q10000156', 'Maxim_Melnikov', 'APCS', '2020-09-02', 'USD', 21954),
('q10000157', 'Maxim_Melnikov', 'APCS', '2020-09-04', 'GBP', 135460),
('q10000158', 'Stanislav_Kuznetsov', 'Combustion', '2020-09-06', 'USD', 19772),
('q10000159', 'Anton_Konovalov', 'Liquid', '2020-09-07', 'CHF', 137439),
('q10000160', 'Maxim_Melnikov', 'APCS', '2020-09-07', 'CHF', 141301),
('q10000161', 'Vadim_Verchenko', 'Flame_&_Gas', '2020-09-08', 'JPY', 940562),
('q10000162', 'Fedor_Ermakov', 'Level', '2020-09-09', 'JPY', 6258484),
('q10000163', 'Anton_Konovalov', 'Liquid', '2020-09-11', 'JPY', 4851153),
('q10000164', 'Vadim_Verchenko', 'Liquid', '2020-09-14', 'CHF', 27594),
('q10000165', 'Vadim_Verchenko', 'Flame_&_Gas', '2020-09-14', 'CHF', 26830),
('q10000166', 'Fedor_Ermakov', 'Flow', '2020-09-17', 'RUB', 1487972),
('q10000167', 'Maxim_Melnikov', 'APCS', '2020-09-17', 'CNY', 284390),
('q10000168', 'Stanislav_Kuznetsov', 'Process_gas', '2020-09-19', 'GBP', 16423),
('q10000169', 'Lev_Ilyin', 'Temperature', '2020-09-22', 'CNY', 18264),
('q10000170', 'Lev_Ilyin', 'Level', '2020-09-23', 'CHF', 23088),
('q10000171', 'Stanislav_Kuznetsov', 'Liquid', '2020-09-23', 'RUB', 313646),
('q10000172', 'Nikolay_Lazarev', 'Flow', '2020-09-23', 'CNY', 233374),
('q10000173', 'Vadim_Verchenko', 'Flame_&_Gas', '2020-09-24', 'CHF', 15248),
('q10000174', 'Fedor_Ermakov', 'Level', '2020-09-26', 'GBP', 1877),
('q10000175', 'Dmitry_Simonov', 'APCS', '2020-09-26', 'CHF', 12727),
('q10000176', 'Anton_Konovalov', 'Process_gas', '2020-09-28', 'USD', 48579),
('q10000177', 'Vadim_Verchenko', 'Flame_&_Gas', '2020-10-01', 'CNY', 225166),
('q10000178', 'Dmitry_Simonov', 'APCS', '2020-10-02', 'CNY', 155914),
('q10000179', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-10-04', 'JPY', 6447524),
('q10000180', 'Maxim_Melnikov', 'APCS', '2020-10-04', 'JPY', 2624692),
('q10000181', 'Maxim_Melnikov', 'APCS', '2020-10-06', 'GBP', 146154),
('q10000182', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-10-07', 'CNY', 354097),
('q10000183', 'Anton_Konovalov', 'Flame_&_Gas', '2020-10-10', 'JPY', 9686796),
('q10000184', 'Fedor_Ermakov', 'Flow', '2020-10-13', 'USD', 2232),
('q10000185', 'Stanislav_Kuznetsov', 'Flame_&_Gas', '2020-10-14', 'JPY', 660581),
('q10000186', 'Anton_Konovalov', 'Combustion', '2020-10-14', 'RUB', 3355921),
('q10000187', 'Anton_Konovalov', 'Combustion', '2020-10-15', 'CHF', 121649),
('q10000188', 'Fedor_Ermakov', 'Pressure', '2020-10-15', 'GBP', 8113),
('q10000189', 'Dmitry_Simonov', 'APCS', '2020-10-16', 'CNY', 195750),
('q10000190', 'Anton_Konovalov', 'Process_gas', '2020-10-16', 'CHF', 82921),
('q10000191', 'Nikolay_Lazarev', 'Pressure', '2020-10-17', 'CHF', 11504),
('q10000192', 'Dmitry_Simonov', 'APCS', '2020-10-18', 'CNY', 262285),
('q10000193', 'Nikolay_Lazarev', 'Level', '2020-10-20', 'JPY', 36764250),
('q10000194', 'Fedor_Ermakov', 'Level', '2020-10-22', 'CNY', 207791),
('q10000195', 'Lev_Ilyin', 'Level', '2020-10-22', 'EUR', 169492),
('q10000196', 'Alexander_Gavrilov', 'Valves_&_Regulators', '2020-10-24', 'GBP', 27546),
('q10000197', 'Gleb_Grigoriev', 'Valves_&_Regulators', '2020-10-26', 'EUR', 42782),
('q10000198', 'Vadim_Verchenko', 'Gas_chromatographs', '2020-10-26', 'CNY', 202649),
('q10000199', 'Vadim_Verchenko', 'Gas_chromatographs', '2020-10-26', 'GBP', 20749)
;

-- заполнение таблицы потенциальных сделок
INSERT opportunities (opportunity_name, customer, end_user, responsible_seller_account, quote_number, currency, amount, win_probability, op_status) VALUES
('2000000-CS-Analytical ООО "АЙ-ТИ-СИ" / АО "Рязанская НПК" q10000000', 'ООО "АЙ-ТИ-СИ"', 'АО "Рязанская НПК"', 'Luka_Kuznetsov', 'q10000000', 'USD', 48297, 10, 'lost'),
('2000001-VL-Analytical ООО "АЙ-ТИ-СИ" / АО "Новокуйбышевский НПЗ" q10000001', 'ООО "АЙ-ТИ-СИ"', 'АО "Новокуйбышевский НПЗ"', 'Demyan_Andrianov', 'q10000001', 'GBP', 22900, 35, 'won'),
('2000002-CS-APCS ООО "Метрол" / ООО "РН-Туапсинский НПЗ" q10000002', 'ООО "Метрол"', 'ООО "РН-Туапсинский НПЗ"', 'Pyotr_Kondrashov', 'q10000002', 'JPY', 39242323, 85, 'canceled'),
('2000003-FE-VR ООО "Комбит Про" / ООО "РН-Восточный Нефтехимический Терминал" q10000003', 'ООО "Комбит Про"', 'ООО "РН-Восточный Нефтехимический Терминал"', 'Luka_Kuznetsov', 'q10000003', 'RUB', 1276882, 60, 'won'),
('2000004-VL-Analytical ООО "АЛМАЗ ГРУПП" / АО "Новокуйбышевский НПЗ" q10000004', 'ООО "АЛМАЗ ГРУПП"', 'АО "Новокуйбышевский НПЗ"', 'Vladislav_Volkov', 'q10000004', 'GBP', 392, 40, 'won'),
('2000005-VL-APCS ООО "Альматэкс" / ГК "Туркменгаз" q10000005', 'ООО "Альматэкс"', 'ГК "Туркменгаз"', 'Vladislav_Shishkin', 'q10000005', 'JPY', 4881113, 85, 'lost'),
('2000006-VL-VR ООО "Альматэкс" / ПАО "Химпром" q10000006', 'ООО "Альматэкс"', 'ПАО "Химпром"', 'Luka_Kuznetsov', 'q10000006', 'CNY', 156398, 60, 'won'),
('2000007-UR-VR АО "Электронстандарт-прибор" / АО "Мессояханефтегаз" q10000007', 'АО "Электронстандарт-прибор"', 'АО "Мессояханефтегаз"', 'Fedor_Bychkov', 'q10000007', 'CNY', 75696, 10, 'won'),
('2000008-VL-APCS ООО "КЭР-Автоматика" / ГК "Туркменгаз" q10000008', 'ООО "КЭР-Автоматика"', 'ГК "Туркменгаз"', 'Demyan_Andrianov', 'q10000008', 'GBP', 19170, 25, 'lost'),
('2000009-CS-TPFL ООО "АЛМАЗ ГРУПП" / ООО "Гипробиосинтез" q10000009', 'ООО "АЛМАЗ ГРУПП"', 'ООО "Гипробиосинтез"', 'Luka_Kuznetsov', 'q10000009', 'CHF', 21575, 40, 'lost'),
('2000010-NW-APCS ООО "Автоматика Сервис" / ООО "Газ Синтез" q10000010', 'ООО "Автоматика Сервис"', 'ООО "Газ Синтез"', 'Vladimir_Galkin', 'q10000010', 'USD', 40205, 100, 'canceled'),
('2000011-CS-Analytical ООО "Метрол" / ООО "РН-Туапсинский НПЗ" q10000011', 'ООО "Метрол"', 'ООО "РН-Туапсинский НПЗ"', 'Pyotr_Kondrashov', 'q10000011', 'USD', 9516, 20, 'won'),
('2000012-UR-TPFL ООО "РЕМОНТ-СЕРВИС" / ООО "СИБУР Тобольск" q10000012', 'ООО "РЕМОНТ-СЕРВИС"', 'ООО "СИБУР Тобольск"', 'Ivan_Belov', 'q10000012', 'CNY', 279461, 30, 'canceled'),
('2000013-CS-VR НПК "ВОЛГА-АВТОМАТИКА" / ООО "НевРСС"  q10000013', 'НПК "ВОЛГА-АВТОМАТИКА"', 'ООО "НевРСС" ', 'Ivan_Belov', 'q10000013', 'USD', 220344, 25, 'canceled'),
('2000014-VL-Analytical ООО "АЭРОЗОЛЕКС" / АО "Сызранский НПЗ" q10000014', 'ООО "АЭРОЗОЛЕКС"', 'АО "Сызранский НПЗ"', 'Vladislav_Shishkin', 'q10000014', 'GBP', 7713, 20, 'won'),
('2000015-SB-APCS ООО "СМС" / ООО "Славнефть-Красноярскнефтегаз" q10000015', 'ООО "СМС"', 'ООО "Славнефть-Красноярскнефтегаз"', 'Georgy_Romanov', 'q10000015', 'CHF', 36533, 5, 'canceled'),
('2000016-UR-VR ООО "Бантер Групп" / АО "Мессояханефтегаз" q10000016', 'ООО "Бантер Групп"', 'АО "Мессояханефтегаз"', 'Luka_Kuznetsov', 'q10000016', 'JPY', 40963, 85, 'canceled'),
('2000017-VL-TPFL ООО "Метрол" / ООО "Промышленные газы" q10000017', 'ООО "Метрол"', 'ООО "Промышленные газы"', 'Ivan_Belov', 'q10000017', 'GBP', 30732, 90, 'won'),
('2000018-CS-Analytical АО "Ангарскнефтехимпроект" / ОАО "Щекиноазот" q10000018', 'АО "Ангарскнефтехимпроект"', 'ОАО "Щекиноазот"', 'Luka_Kuznetsov', 'q10000018', 'GBP', 19154, 70, 'lost'),
('2000019-UR-Analytical ООО "Энергия холода" / ООО "СевКомНефтегаз" q10000019', 'ООО "Энергия холода"', 'ООО "СевКомНефтегаз"', 'Fedor_Bychkov', 'q10000019', 'JPY', 2783905, 95, 'lost'),
('2000020-CS-VR ООО "Технологии АСУ" / Институт физической химии и электрохимии РАН q10000020', 'ООО "Технологии АСУ"', 'Институт физической химии и электрохимии РАН', 'Pyotr_Kondrashov', 'q10000020', 'CHF', 45892, 85, 'canceled'),
('2000021-FE-VR ООО " НПК ИТР" / ПАО "РусГидро" Усть-Среднеканская ГЭС q10000021', 'ООО " НПК ИТР"', 'ПАО "РусГидро" Усть-Среднеканская ГЭС', 'Luka_Kuznetsov', 'q10000021', 'JPY', 4036397, 5, 'lost'),
('2000022-FE-APCS ООО "АЙ-ТИ-СИ" / Exxon Neftegas Limited - Chayvo OPF q10000022', 'ООО "АЙ-ТИ-СИ"', 'Exxon Neftegas Limited - Chayvo OPF', 'Demyan_Andrianov', 'q10000022', 'EUR', 32765, 20, 'canceled'),
('2000023-SB-VR ООО "ВЕЛМАС" / АО "АНПЗ ВНК" q10000023', 'ООО "ВЕЛМАС"', 'АО "АНПЗ ВНК"', 'Georgy_Romanov', 'q10000023', 'RUB', 11833509, 70, 'canceled'),
('2000024-CS-VR АО "РЭП Холдинг" / ОАО "Щекиноазот" q10000024', 'АО "РЭП Холдинг"', 'ОАО "Щекиноазот"', 'Fedor_Bychkov', 'q10000024', 'GBP', 25043, 45, 'won'),
('2000025-SB-VR ООО "Автоматика Сервис" / ООО "ВПК-Ойл" q10000025', 'ООО "Автоматика Сервис"', 'ООО "ВПК-Ойл"', 'Georgy_Romanov', 'q10000025', 'EUR', 37000, 80, 'won'),
('2000026-UR-VR ООО "АумаПриводСервис" / ООО "Пурнефтепереработка" q10000026', 'ООО "АумаПриводСервис"', 'ООО "Пурнефтепереработка"', 'Ivan_Belov', 'q10000026', 'GBP', 34537, 40, 'won'),
('2000027-VL-VR ООО "ЭТМ" / ООО "ЛУКОЙЛ-Пермнефтеоргсинтез" q10000027', 'ООО "ЭТМ"', 'ООО "ЛУКОЙЛ-Пермнефтеоргсинтез"', 'Vladislav_Shishkin', 'q10000027', 'JPY', 1972463, 5, 'canceled'),
('2000028-CS-APCS ООО "АЙ-ТИ-СИ" / ООО "ТУЛАЧЕРМЕТ-СТАЛЬ" q10000028', 'ООО "АЙ-ТИ-СИ"', 'ООО "ТУЛАЧЕРМЕТ-СТАЛЬ"', 'Pyotr_Kondrashov', 'q10000028', 'CNY', 43875, 20, 'canceled'),
('2000029-CS-VR ООО "Альматэкс" / ООО "Славянск ЭКО" q10000029', 'ООО "Альматэкс"', 'ООО "Славянск ЭКО"', 'Demyan_Andrianov', 'q10000029', 'USD', 120097, 35, 'canceled'),
('2000030-SB-TPFL ООО "ГАЗСЕНСОР" / ООО "Славнефть-Красноярскнефтегаз" q10000030', 'ООО "ГАЗСЕНСОР"', 'ООО "Славнефть-Красноярскнефтегаз"', 'Georgy_Romanov', 'q10000030', 'USD', 252393, 50, 'canceled'),
('2000031-VL-TPFL ООО " НПК ИТР" / ПАО АНК "Башнефть" q10000031', 'ООО " НПК ИТР"', 'ПАО АНК "Башнефть"', 'Vladislav_Shishkin', 'q10000031', 'USD', 151477, 100, 'won'),
('2000032-VL-VR ООО "Метрол" / ОАО "Сызранский НПЗ" q10000032', 'ООО "Метрол"', 'ОАО "Сызранский НПЗ"', 'Vladislav_Shishkin', 'q10000032', 'GBP', 10199, 50, 'canceled'),
('2000033-UR-Analytical ООО " НПК ИТР" / ОАО "Ямал СПГ" q10000033', 'ООО " НПК ИТР"', 'ОАО "Ямал СПГ"', 'Demyan_Andrianov', 'q10000033', 'CNY', 84828, 20, 'lost'),
('2000034-VL-TPFL НПК "ВОЛГА-АВТОМАТИКА" / ООО "ЛУКОЙЛ-Пермнефтеоргсинтез" q10000034', 'НПК "ВОЛГА-АВТОМАТИКА"', 'ООО "ЛУКОЙЛ-Пермнефтеоргсинтез"', 'Vladislav_Volkov', 'q10000034', 'CNY', 98469, 80, 'won'),
('2000035-CS-VR ООО "Бантер Групп" / ООО "НевРСС"  q10000035', 'ООО "Бантер Групп"', 'ООО "НевРСС" ', 'Pyotr_Kondrashov', 'q10000035', 'GBP', 36369, 70, 'won'),
('2000036-CS-APCS ООО "Энергия холода" / ООО "Афипский НПЗ" q10000036', 'ООО "Энергия холода"', 'ООО "Афипский НПЗ"', 'Ivan_Belov', 'q10000036', 'CHF', 22531, 20, 'won'),
('2000037-SB-APCS ООО "ХРОМОС Инжиниринг" / АО "ННК-Хабаровский нефтеперерабатывающий завод" q10000037', 'ООО "ХРОМОС Инжиниринг"', 'АО "ННК-Хабаровский нефтеперерабатывающий завод"', 'Georgy_Romanov', 'q10000037', 'EUR', 169042, 10, 'lost'),
('2000038-CS-Analytical ООО "Осмотикс" / АО "ОЭМК" q10000038', 'ООО "Осмотикс"', 'АО "ОЭМК"', 'Pyotr_Kondrashov', 'q10000038', 'EUR', 46317, 70, 'won'),
('2000039-UR-Analytical ООО "ВЕЛМАС" / ООО "Газпромнефть - Заполярье"  q10000039', 'ООО "ВЕЛМАС"', 'ООО "Газпромнефть - Заполярье" ', 'Fedor_Bychkov', 'q10000039', 'JPY', 5663523, 85, 'won'),
('2000040-CS-TPFL ООО "АЙ-ТИ-СИ" / АО "НЗНП" q10000040', 'ООО "АЙ-ТИ-СИ"', 'АО "НЗНП"', 'Vladislav_Volkov', 'q10000040', 'EUR', 17373, 90, 'won'),
('2000041-VL-APCS ООО "ЭТМ" / ООО "ТиссенКрупп Индастриал Солюшнс (РУС)" q10000041', 'ООО "ЭТМ"', 'ООО "ТиссенКрупп Индастриал Солюшнс (РУС)"', 'Ivan_Belov', 'q10000041', 'GBP', 29120, 80, 'lost'),
('2000042-FE-VR ООО "Эртей Петрошем Рус"  / ООО "РН-Восточный Нефтехимический Терминал" q10000042', 'ООО "Эртей Петрошем Рус" ', 'ООО "РН-Восточный Нефтехимический Терминал"', 'Vladislav_Volkov', 'q10000042', 'GBP', 29546, 65, 'lost'),
('2000043-NW-Analytical ООО "ГАЗСЕНСОР" / АО "Апатит" q10000043', 'ООО "ГАЗСЕНСОР"', 'АО "Апатит"', 'Ivan_Belov', 'q10000043', 'CNY', 102068, 80, 'lost'),
('2000044-SB-APCS ООО "ГИДРОТЕХ" / ООО "Славнефть-Красноярскнефтегаз" q10000044', 'ООО "ГИДРОТЕХ"', 'ООО "Славнефть-Красноярскнефтегаз"', 'Georgy_Romanov', 'q10000044', 'GBP', 12883, 30, 'lost'),
('2000045-VL-Analytical ООО "Эртей Петрошем Рус"  / АО "Башнефть-Уфанефтехим" q10000045', 'ООО "Эртей Петрошем Рус" ', 'АО "Башнефть-Уфанефтехим"', 'Vladislav_Shishkin', 'q10000045', 'RUB', 1149496, 25, 'canceled'),
('2000046-SB-VR ООО "Энтренс Электроникс" / ООО "Таймырская топливная компания" q10000046', 'ООО "Энтренс Электроникс"', 'ООО "Таймырская топливная компания"', 'Georgy_Romanov', 'q10000046', 'USD', 31403, 70, 'canceled'),
('2000047-CS-VR ООО "АЭРОЗОЛЕКС" / ПАО "Квадра"- "Воронежская Генерация" q10000047', 'ООО "АЭРОЗОЛЕКС"', 'ПАО "Квадра"- "Воронежская Генерация"', 'Pyotr_Kondrashov', 'q10000047', 'RUB', 1647996, 60, 'canceled'),
('2000048-CS-Analytical ООО "ВЕЛМАС" / АО "ОЭМК" q10000048', 'ООО "ВЕЛМАС"', 'АО "ОЭМК"', 'Ivan_Belov', 'q10000048', 'JPY', 37591467, 55, 'lost'),
('2000049-SB-VR АО "Электронстандарт-прибор" / ООО "ИНК" q10000049', 'АО "Электронстандарт-прибор"', 'ООО "ИНК"', 'Georgy_Romanov', 'q10000049', 'EUR', 48451, 20, 'lost'),
('2000050-NW-Analytical ООО "Химсталькон-Инжиниринг" / ООО "КИНЕФ" q10000050', 'ООО "Химсталькон-Инжиниринг"', 'ООО "КИНЕФ"', 'Luka_Kuznetsov', 'q10000050', 'RUB', 11755573, 30, 'won'),
('2000051-NW-Analytical ООО "РусПромЭнергоСистемы" / ООО “ЛУКОЙЛ-Коми” (Усинский ГПЗ) q10000051', 'ООО "РусПромЭнергоСистемы"', 'ООО “ЛУКОЙЛ-Коми” (Усинский ГПЗ)', 'Vladimir_Galkin', 'q10000051', 'GBP', 1688, 85, 'lost'),
('2000052-UR-VR ООО "АЛМАЗ ГРУПП" / ООО "СевКомНефтегаз" q10000052', 'ООО "АЛМАЗ ГРУПП"', 'ООО "СевКомНефтегаз"', 'Ivan_Belov', 'q10000052', 'EUR', 18551, 50, 'canceled'),
('2000053-CS-Analytical АО "Электронстандарт-прибор" / АО "КАУСТИК" q10000053', 'АО "Электронстандарт-прибор"', 'АО "КАУСТИК"', 'Pyotr_Kondrashov', 'q10000053', 'USD', 250452, 85, 'lost'),
('2000054-VL-VR ООО "АЛМАЗ ГРУПП" / ООО "ГАЗПРОМ НЕФТЕХИМ САЛАВАТ" q10000054', 'ООО "АЛМАЗ ГРУПП"', 'ООО "ГАЗПРОМ НЕФТЕХИМ САЛАВАТ"', 'Vladislav_Shishkin', 'q10000054', 'RUB', 2961173, 40, 'canceled'),
('2000055-VL-VR АО "РЭП Холдинг" / ООО "ЛУКОЙЛ-Пермьнефтеоргсинтез" q10000055', 'АО "РЭП Холдинг"', 'ООО "ЛУКОЙЛ-Пермьнефтеоргсинтез"', 'Vladislav_Shishkin', 'q10000055', 'JPY', 2955844, 20, 'won'),
('2000056-VL-APCS ООО "АЭРОЗОЛЕКС" / ООО "ТаграС-РемСервис" q10000056', 'ООО "АЭРОЗОЛЕКС"', 'ООО "ТаграС-РемСервис"', 'Demyan_Andrianov', 'q10000056', 'JPY', 6487294, 15, 'lost'),
('2000057-VL-APCS ООО "Метрол" / АО "Интер РАО электрогенерация - филиал "Пермская ГРЭС" q10000057', 'ООО "Метрол"', 'АО "Интер РАО электрогенерация - филиал "Пермская ГРЭС"', 'Demyan_Andrianov', 'q10000057', 'EUR', 42248, 55, 'canceled'),
('2000058-UR-TPFL ООО "Альматэкс" / ООО "СевКомНефтегаз" q10000058', 'ООО "Альматэкс"', 'ООО "СевКомНефтегаз"', 'Fedor_Bychkov', 'q10000058', 'CHF', 2419, 60, 'lost'),
('2000059-CS-VR ООО "Велесстрой" / АО "КАУСТИК" q10000059', 'ООО "Велесстрой"', 'АО "КАУСТИК"', 'Ivan_Belov', 'q10000059', 'USD', 49180, 85, 'canceled'),
('2000060-CS-VR ООО "Альматэкс" / ООО "Астон Крахмало-Продукты" q10000060', 'ООО "Альматэкс"', 'ООО "Астон Крахмало-Продукты"', 'Demyan_Andrianov', 'q10000060', 'CHF', 13085, 20, 'lost'),
('2000061-UR-VR ООО "Комбит Про" / АО "ГМС Нефтемаш" q10000061', 'ООО "Комбит Про"', 'АО "ГМС Нефтемаш"', 'Luka_Kuznetsov', 'q10000061', 'JPY', 6554108, 5, 'lost'),
('2000062-UR-APCS ООО "Стронгарм" / АО "Челябинский цинковый завод" q10000062', 'ООО "Стронгарм"', 'АО "Челябинский цинковый завод"', 'Fedor_Bychkov', 'q10000062', 'RUB', 14241810, 50, 'won'),
('2000063-CS-TPFL ООО "СМС" / ООО "РН-Туапсинский НПЗ" q10000063', 'ООО "СМС"', 'ООО "РН-Туапсинский НПЗ"', 'Pyotr_Kondrashov', 'q10000063', 'USD', 37628, 5, 'canceled'),
('2000064-SB-TPFL ООО "Технологии АСУ" / ПАО "ННК-Хабаровскнефтепродукт" q10000064', 'ООО "Технологии АСУ"', 'ПАО "ННК-Хабаровскнефтепродукт"', 'Georgy_Romanov', 'q10000064', 'GBP', 20673, 45, 'canceled'),
('2000065-SB-APCS ООО "Осмотикс" / ООО "Газпромнефть - Восток"  q10000065', 'ООО "Осмотикс"', 'ООО "Газпромнефть - Восток" ', 'Georgy_Romanov', 'q10000065', 'RUB', 2426449, 15, 'lost'),
('2000066-CS-TPFL ООО "Технологии АСУ" / ОАО "Бабушкина крынка" q10000066', 'ООО "Технологии АСУ"', 'ОАО "Бабушкина крынка"', 'Vladislav_Volkov', 'q10000066', 'EUR', 1678, 20, 'won'),
('2000067-CS-VR ООО "Метрология-Комплект" / ООО "Славянск ЭКО" q10000067', 'ООО "Метрология-Комплект"', 'ООО "Славянск ЭКО"', 'Vladislav_Volkov', 'q10000067', 'USD', 1839, 65, 'won'),
('2000068-UR-APCS ООО "СМС" / АО "ГМС Нефтемаш" q10000068', 'ООО "СМС"', 'АО "ГМС Нефтемаш"', 'Fedor_Bychkov', 'q10000068', 'RUB', 1284127, 100, 'canceled'),
('2000069-VL-VR ООО "Дельта Инжиниринг" / ПАО АНК "Башнефть" q10000069', 'ООО "Дельта Инжиниринг"', 'ПАО АНК "Башнефть"', 'Vladislav_Shishkin', 'q10000069', 'USD', 39151, 90, 'won'),
('2000070-CS-APCS ООО "Метрология-Комплект" / АО "Рязанская НПК" q10000070', 'ООО "Метрология-Комплект"', 'АО "Рязанская НПК"', 'Pyotr_Kondrashov', 'q10000070', 'RUB', 801665, 60, 'won'),
('2000071-SB-APCS ООО "ТД "Автоматика" / АО "Ачинский НПЗ ВНК" q10000071', 'ООО "ТД "Автоматика"', 'АО "Ачинский НПЗ ВНК"', 'Georgy_Romanov', 'q10000071', 'EUR', 34070, 85, 'canceled'),
('2000072-SB-APCS ООО "Химсталькон-Инжиниринг" / АО "Ачинский НПЗ ВНК" q10000072', 'ООО "Химсталькон-Инжиниринг"', 'АО "Ачинский НПЗ ВНК"', 'Georgy_Romanov', 'q10000072', 'EUR', 14621, 50, 'won'),
('2000073-UR-TPFL ООО "ГИДРОТЕХ" / ООО "РН-Пурнефтегаз" q10000073', 'ООО "ГИДРОТЕХ"', 'ООО "РН-Пурнефтегаз"', 'Ivan_Belov', 'q10000073', 'EUR', 8563, 80, 'canceled'),
('2000074-VL-VR ООО "АЭРОЗОЛЕКС" / ООО "Газпром ПХГ" "Песчано - Уметское УПХГ" q10000074', 'ООО "АЭРОЗОЛЕКС"', 'ООО "Газпром ПХГ" "Песчано - Уметское УПХГ"', 'Vladislav_Shishkin', 'q10000074', 'USD', 134907, 45, 'lost'),
('2000075-UR-TPFL ООО "МНУ-1 Корпорации АК "ЭСКМ" / АО "Тюменнефтегаз" q10000075', 'ООО "МНУ-1 Корпорации АК "ЭСКМ"', 'АО "Тюменнефтегаз"', 'Demyan_Andrianov', 'q10000075', 'CHF', 9729, 70, 'lost'),
('2000076-FE-APCS ООО "Химсталькон-Инжиниринг" / Exxon Neftegas Limited - Chayvo OPF q10000076', 'ООО "Химсталькон-Инжиниринг"', 'Exxon Neftegas Limited - Chayvo OPF', 'Maxim_Kuznetsov', 'q10000076', 'CHF', 16082, 60, 'lost'),
('2000077-UR-APCS ООО "СНЭМА-Сервис" / ООО "Пурнефтепереработка" q10000077', 'ООО "СНЭМА-Сервис"', 'ООО "Пурнефтепереработка"', 'Fedor_Bychkov', 'q10000077', 'GBP', 9765, 60, 'lost'),
('2000078-VL-Analytical ООО "Химсталькон-Инжиниринг" / ООО "Тольяттикаучук" q10000078', 'ООО "Химсталькон-Инжиниринг"', 'ООО "Тольяттикаучук"', 'Ivan_Belov', 'q10000078', 'GBP', 243892, 80, 'won'),
('2000079-VL-APCS ООО "СНЭМА-Сервис" / ОАО "Пермская ГРЭС"  q10000079', 'ООО "СНЭМА-Сервис"', 'ОАО "Пермская ГРЭС" ', 'Vladislav_Shishkin', 'q10000079', 'CNY', 102822, 90, 'lost'),
('2000080-VL-APCS ООО "ЭТМ" / ОАО "Пермская ГРЭС"  q10000080', 'ООО "ЭТМ"', 'ОАО "Пермская ГРЭС" ', 'Vladislav_Shishkin', 'q10000080', 'CNY', 198986, 5, 'lost'),
('2000081-CS-VR ООО "АЛМАЗ ГРУПП" / АО "КазТрансГаз" q10000081', 'ООО "АЛМАЗ ГРУПП"', 'АО "КазТрансГаз"', 'Luka_Kuznetsov', 'q10000081', 'CNY', 281140, 50, 'won'),
('2000082-CS-TPFL ООО " НПК ИТР" / ООО "Ставролен" q10000082', 'ООО " НПК ИТР"', 'ООО "Ставролен"', 'Luka_Kuznetsov', 'q10000082', 'EUR', 44102, 70, 'won'),
('2000083-FE-TPFL ООО "КЭР-Автоматика" / ООО "Газпром переработка Благовещенск" q10000083', 'ООО "КЭР-Автоматика"', 'ООО "Газпром переработка Благовещенск"', 'Maxim_Kuznetsov', 'q10000083', 'CNY', 21984, 25, 'canceled'),
('2000084-CS-VR ООО "МНУ-1 Корпорации АК "ЭСКМ" / АО "НЗНП" q10000084', 'ООО "МНУ-1 Корпорации АК "ЭСКМ"', 'АО "НЗНП"', 'Pyotr_Kondrashov', 'q10000084', 'JPY', 6141162, 10, 'won'),
('2000085-VL-APCS ООО "Химсталькон-Инжиниринг" / ООО "ТиссенКрупп Индастриал Солюшнс (РУС)" q10000085', 'ООО "Химсталькон-Инжиниринг"', 'ООО "ТиссенКрупп Индастриал Солюшнс (РУС)"', 'Ivan_Belov', 'q10000085', 'GBP', 28143, 85, 'canceled'),
('2000086-VL-Analytical ООО "Энергия холода" / АО "Сызранский НПЗ" q10000086', 'ООО "Энергия холода"', 'АО "Сызранский НПЗ"', 'Demyan_Andrianov', 'q10000086', 'JPY', 6506649, 90, 'lost'),
('2000087-CS-Analytical АО "РЭП Холдинг" / ПАО "Казаньоргсинтез" q10000087', 'АО "РЭП Холдинг"', 'ПАО "Казаньоргсинтез"', 'Pyotr_Kondrashov', 'q10000087', 'USD', 131963, 80, 'won'),
('2000088-VL-VR ООО "Химсталькон-Инжиниринг" / АО "Сызранский НПЗ" q10000088', 'ООО "Химсталькон-Инжиниринг"', 'АО "Сызранский НПЗ"', 'Vladislav_Shishkin', 'q10000088', 'EUR', 24563, 80, 'lost'),
('2000089-SB-VR ООО "РЕМОНТ-СЕРВИС" / АО "АНПЗ ВНК" q10000089', 'ООО "РЕМОНТ-СЕРВИС"', 'АО "АНПЗ ВНК"', 'Luka_Kuznetsov', 'q10000089', 'RUB', 986237, 25, 'won'),
('2000090-CS-VR ООО "Метрология-Комплект" / ООО "Славянск ЭКО" q10000090', 'ООО "Метрология-Комплект"', 'ООО "Славянск ЭКО"', 'Demyan_Andrianov', 'q10000090', 'CHF', 32444, 95, 'lost'),
('2000091-FE-TPFL ООО "МНУ-1 Корпорации АК "ЭСКМ" / Exxon Neftegas Limited - Chayvo OPF q10000091', 'ООО "МНУ-1 Корпорации АК "ЭСКМ"', 'Exxon Neftegas Limited - Chayvo OPF', 'Ivan_Belov', 'q10000091', 'EUR', 29883, 85, 'won'),
('2000092-CS-VR АО "Ангарскнефтехимпроект" / АО "КазТрансГаз" q10000092', 'АО "Ангарскнефтехимпроект"', 'АО "КазТрансГаз"', 'Demyan_Andrianov', 'q10000092', 'CHF', 21416, 55, 'canceled'),
('2000093-VL-TPFL ООО "Альматэкс" / ООО "Синергия-Лидер" q10000093', 'ООО "Альматэкс"', 'ООО "Синергия-Лидер"', 'Vladislav_Volkov', 'q10000093', 'GBP', 8612, 25, 'lost'),
('2000094-CS-APCS ООО "Метрология-Комплект" / АО "РНПК" q10000094', 'ООО "Метрология-Комплект"', 'АО "РНПК"', 'Pyotr_Kondrashov', 'q10000094', 'CNY', 278167, 85, 'canceled'),
('2000095-CS-Analytical ООО "НПО "ЭКОХИМПРИБОР" / АО "НЗНП" q10000095', 'ООО "НПО "ЭКОХИМПРИБОР"', 'АО "НЗНП"', 'Pyotr_Kondrashov', 'q10000095', 'JPY', 4232994, 80, 'won'),
('2000096-UR-APCS ООО "Метрология-Комплект" / ООО "Пурнефтепереработка" q10000096', 'ООО "Метрология-Комплект"', 'ООО "Пурнефтепереработка"', 'Demyan_Andrianov', 'q10000096', 'USD', 35505, 20, 'won'),
('2000097-FE-VR АО "Электронстандарт-прибор" / АО "РНГ" q10000097', 'АО "Электронстандарт-прибор"', 'АО "РНГ"', 'Maxim_Kuznetsov', 'q10000097', 'USD', 60002, 45, 'canceled'),
('2000098-VL-Analytical ООО "ТД "Автоматика" / ООО "ТаграС-РемСервис" q10000098', 'ООО "ТД "Автоматика"', 'ООО "ТаграС-РемСервис"', 'Ivan_Belov', 'q10000098', 'EUR', 31860, 70, 'canceled'),
('2000099-FE-Analytical ООО "Химсталькон-Инжиниринг" / Store (SEIC) q10000099', 'ООО "Химсталькон-Инжиниринг"', 'Store (SEIC)', 'Demyan_Andrianov', 'q10000099', 'CNY', 235166, 80, 'lost'),
('2000100-SB-Analytical ООО "ХРОМОС Инжиниринг" / АО "ВЧНГ" q10000100', 'ООО "ХРОМОС Инжиниринг"', 'АО "ВЧНГ"', 'Georgy_Romanov', 'q10000100', 'CNY', 197905, 40, 'canceled'),
('2000101-CS-TPFL АО "Электронстандарт-прибор" / АО "НЗНП" q10000101', 'АО "Электронстандарт-прибор"', 'АО "НЗНП"', 'Luka_Kuznetsov', 'q10000101', 'CHF', 35885, 100, 'canceled'),
('2000102-CS-VR ООО "Энергия холода" / ПАО "Казаньоргсинтез" q10000102', 'ООО "Энергия холода"', 'ПАО "Казаньоргсинтез"', 'Pyotr_Kondrashov', 'q10000102', 'JPY', 3502550, 65, 'lost'),
('2000103-UR-VR ООО "АЭРОЗОЛЕКС" / АО "Роспан Интернешнл" q10000103', 'ООО "АЭРОЗОЛЕКС"', 'АО "Роспан Интернешнл"', 'Fedor_Bychkov', 'q10000103', 'CNY', 1678708, 70, 'lost'),
('2000104-VL-APCS ООО "ТД "Автоматика" / ООО "Промышленные газы" q10000104', 'ООО "ТД "Автоматика"', 'ООО "Промышленные газы"', 'Vladislav_Volkov', 'q10000104', 'USD', 42542, 60, 'lost'),
('2000105-UR-Analytical ООО "Альматэкс" / ООО "Пурнефтепереработка" q10000105', 'ООО "Альматэкс"', 'ООО "Пурнефтепереработка"', 'Luka_Kuznetsov', 'q10000105', 'EUR', 826, 40, 'canceled'),
('2000106-SB-TPFL ООО "ТД "Автоматика" / АО "АНПЗ ВНК" q10000106', 'ООО "ТД "Автоматика"', 'АО "АНПЗ ВНК"', 'Ivan_Belov', 'q10000106', 'USD', 35824, 60, 'lost'),
('2000107-VL-TPFL ООО "КЭР-Автоматика" / ООО "ТаграС-РемСервис" q10000107', 'ООО "КЭР-Автоматика"', 'ООО "ТаграС-РемСервис"', 'Luka_Kuznetsov', 'q10000107', 'RUB', 14000685, 10, 'canceled'),
('2000108-VL-VR ООО "Автоматика Сервис" / ООО "ТиссенКрупп Индастриал Солюшнс (РУС)" q10000108', 'ООО "Автоматика Сервис"', 'ООО "ТиссенКрупп Индастриал Солюшнс (РУС)"', 'Vladislav_Shishkin', 'q10000108', 'USD', 125015, 95, 'canceled'),
('2000109-CS-Analytical ООО "Энтренс Электроникс" / ПАО "Квадра"- "Воронежская Генерация" q10000109', 'ООО "Энтренс Электроникс"', 'ПАО "Квадра"- "Воронежская Генерация"', 'Ivan_Belov', 'q10000109', 'JPY', 4575282, 100, 'won'),
('2000110-SB-Analytical ООО "ХРОМОС Инжиниринг" / ОАО "ГМЗ" q10000110', 'ООО "ХРОМОС Инжиниринг"', 'ОАО "ГМЗ"', 'Vladislav_Volkov', 'q10000110', 'CNY', 29139, 55, 'won'),
('2000111-UR-TPFL ООО "ЭТМ" / ООО "Арктик СПГ 2" q10000111', 'ООО "ЭТМ"', 'ООО "Арктик СПГ 2"', 'Luka_Kuznetsov', 'q10000111', 'CNY', 124585, 45, 'canceled'),
('2000112-SB-TPFL ООО "Осмотикс" / ООО "ИНК" q10000112', 'ООО "Осмотикс"', 'ООО "ИНК"', 'Georgy_Romanov', 'q10000112', 'RUB', 3094116, 45, 'canceled'),
('2000113-VL-TPFL ООО "СНЭМА-Сервис" / ООО "ТаграС-РемСервис" q10000113', 'ООО "СНЭМА-Сервис"', 'ООО "ТаграС-РемСервис"', 'Vladislav_Shishkin', 'q10000113', 'JPY', 19557330, 90, 'lost'),
('2000114-UR-VR ООО "Альматэкс" / ООО "Новатэк-Юрхаровнефтегаз" q10000114', 'ООО "Альматэкс"', 'ООО "Новатэк-Юрхаровнефтегаз"', 'Ivan_Belov', 'q10000114', 'CHF', 13123, 60, 'lost'),
('2000115-NW-APCS ООО "Осмотикс" / УГПЗ ООО "ЛУКОЙЛ-Коми" q10000115', 'ООО "Осмотикс"', 'УГПЗ ООО "ЛУКОЙЛ-Коми"', 'Vladimir_Galkin', 'q10000115', 'USD', 214559, 65, 'canceled'),
('2000116-VL-VR ООО "Метрология-Комплект" / АО "Новокуйбышевский НПЗ" q10000116', 'ООО "Метрология-Комплект"', 'АО "Новокуйбышевский НПЗ"', 'Ivan_Belov', 'q10000116', 'RUB', 2662650, 30, 'lost'),
('2000117-VL-Analytical АО "Ангарскнефтехимпроект" / ООО "ТаграС-РемСервис" q10000117', 'АО "Ангарскнефтехимпроект"', 'ООО "ТаграС-РемСервис"', 'Vladislav_Volkov', 'q10000117', 'CHF', 45872, 100, 'canceled'),
('2000118-CS-VR ООО "Метрология-Комплект" / АО "ОЭМК" q10000118', 'ООО "Метрология-Комплект"', 'АО "ОЭМК"', 'Pyotr_Kondrashov', 'q10000118', 'RUB', 2156413, 35, 'won'),
('2000119-CS-TPFL ООО "МНУ-1 Корпорации АК "ЭСКМ" / ООО "Астон Крахмало-Продукты" q10000119', 'ООО "МНУ-1 Корпорации АК "ЭСКМ"', 'ООО "Астон Крахмало-Продукты"', 'Pyotr_Kondrashov', 'q10000119', 'RUB', 3325253, 15, 'lost'),
('2000120-CS-VR ООО "РЕКОН" / ООО "ТУЛАЧЕРМЕТ-СТАЛЬ" q10000120', 'ООО "РЕКОН"', 'ООО "ТУЛАЧЕРМЕТ-СТАЛЬ"', 'Vladislav_Volkov', 'q10000120', 'CHF', 36246, 25, 'canceled'),
('2000121-NW-Analytical АО "Электронстандарт-прибор" / ООО "ПОРТЭНЕРГО" q10000121', 'АО "Электронстандарт-прибор"', 'ООО "ПОРТЭНЕРГО"', 'Demyan_Andrianov', 'q10000121', 'CHF', 236483, 30, 'canceled'),
('2000122-UR-VR ООО "СМС" / ООО "СИБУР Тобольск" q10000122', 'ООО "СМС"', 'ООО "СИБУР Тобольск"', 'Fedor_Bychkov', 'q10000122', 'USD', 297763, 60, 'lost'),
('2000123-CS-TPFL ООО "Технологии АСУ" / ООО "Гипробиосинтез" q10000123', 'ООО "Технологии АСУ"', 'ООО "Гипробиосинтез"', 'Pyotr_Kondrashov', 'q10000123', 'CNY', 1838285, 10, 'canceled'),
('2000124-FE-APCS ООО "Велесстрой" / Exxon Neftegas Limited - Chayvo OPF q10000124', 'ООО "Велесстрой"', 'Exxon Neftegas Limited - Chayvo OPF', 'Maxim_Kuznetsov', 'q10000124', 'CNY', 1432681, 75, 'won'),
('2000125-VL-VR НПК "ВОЛГА-АВТОМАТИКА" / ООО "Газпромнефть - Оренбург" q10000125', 'НПК "ВОЛГА-АВТОМАТИКА"', 'ООО "Газпромнефть - Оренбург"', 'Vladislav_Shishkin', 'q10000125', 'RUB', 3143424, 55, 'canceled'),
('2000126-FE-Analytical ООО " НПК ИТР" / Store (SEIC) q10000126', 'ООО " НПК ИТР"', 'Store (SEIC)', 'Luka_Kuznetsov', 'q10000126', 'JPY', 3187174, 90, 'lost'),
('2000127-VL-TPFL ООО "Осмотикс" / ПАО АНК "Башнефть" q10000127', 'ООО "Осмотикс"', 'ПАО АНК "Башнефть"', 'Vladislav_Volkov', 'q10000127', 'JPY', 1514577, 35, 'canceled'),
('2000128-NW-TPFL ООО "Химсталькон-Инжиниринг" / УГПЗ ООО "ЛУКОЙЛ-Коми" q10000128', 'ООО "Химсталькон-Инжиниринг"', 'УГПЗ ООО "ЛУКОЙЛ-Коми"', 'Ivan_Belov', 'q10000128', 'JPY', 6114383, 45, 'lost'),
('2000129-CS-APCS ООО "РЕМОНТ-СЕРВИС" / ООО "Афипский НПЗ" q10000129', 'ООО "РЕМОНТ-СЕРВИС"', 'ООО "Афипский НПЗ"', 'Ivan_Belov', 'q10000129', 'GBP', 40403, 55, 'canceled'),
('2000130-NW-TPFL ООО "Метрология-Комплект" / УГПЗ ООО "ЛУКОЙЛ-Коми" q10000130', 'ООО "Метрология-Комплект"', 'УГПЗ ООО "ЛУКОЙЛ-Коми"', 'Luka_Kuznetsov', 'q10000130', 'USD', 9690, 40, 'canceled'),
('2000131-CS-Analytical НПК "ВОЛГА-АВТОМАТИКА" / ОАО "Щекиноазот" q10000131', 'НПК "ВОЛГА-АВТОМАТИКА"', 'ОАО "Щекиноазот"', 'Luka_Kuznetsov', 'q10000131', 'RUB', 2642041, 95, 'won'),
('2000132-NW-VR ООО "Торгово-промышленная компания "Союз" / УГПЗ ООО "ЛУКОЙЛ-Коми" q10000132', 'ООО "Торгово-промышленная компания "Союз"', 'УГПЗ ООО "ЛУКОЙЛ-Коми"', 'Vladimir_Galkin', 'q10000132', 'GBP', 4788, 25, 'canceled'),
('2000133-UR-TPFL ООО "РЕКОН" / ООО "Газпромнефть - Хантос" q10000133', 'ООО "РЕКОН"', 'ООО "Газпромнефть - Хантос"', 'Vladislav_Volkov', 'q10000133', 'EUR', 31740, 75, 'lost'),
('2000134-FE-Analytical ООО "Энтренс Электроникс" / Store (SEIC) q10000134', 'ООО "Энтренс Электроникс"', 'Store (SEIC)', 'Vladislav_Volkov', 'q10000134', 'CNY', 36962, 25, 'canceled'),
('2000135-NW-Analytical ООО "Метрол" / ООО "ПОРТЭНЕРГО" q10000135', 'ООО "Метрол"', 'ООО "ПОРТЭНЕРГО"', 'Luka_Kuznetsov', 'q10000135', 'USD', 20052, 30, 'canceled'),
('2000136-NW-VR ООО "Химсталькон-Инжиниринг" / АО "Апатит" q10000136', 'ООО "Химсталькон-Инжиниринг"', 'АО "Апатит"', 'Vladimir_Galkin', 'q10000136', 'CHF', 267672, 100, 'canceled'),
('2000137-CS-TPFL ООО "РусПромЭнергоСистемы" / ООО "Афипский НПЗ" q10000137', 'ООО "РусПромЭнергоСистемы"', 'ООО "Афипский НПЗ"', 'Pyotr_Kondrashov', 'q10000137', 'CNY', 243210, 60, 'won'),
('2000138-SB-APCS ООО "АЭРОЗОЛЕКС" / ОАО "ГМЗ" q10000138', 'ООО "АЭРОЗОЛЕКС"', 'ОАО "ГМЗ"', 'Georgy_Romanov', 'q10000138', 'CNY', 353407, 10, 'lost'),
('2000139-VL-APCS ООО "Стройтехлогистика" / ООО "Синергия-Лидер" q10000139', 'ООО "Стройтехлогистика"', 'ООО "Синергия-Лидер"', 'Vladislav_Shishkin', 'q10000139', 'CNY', 104649, 70, 'canceled'),
('2000140-UR-Analytical ООО "ХРОМОС Инжиниринг" / ООО "ПКФ "УралРеаХим"  q10000140', 'ООО "ХРОМОС Инжиниринг"', 'ООО "ПКФ "УралРеаХим" ', 'Vladislav_Volkov', 'q10000140', 'GBP', 98739, 5, 'canceled'),
('2000141-CS-VR АО "РЭП Холдинг" / ПАО "Казаньоргсинтез" q10000141', 'АО "РЭП Холдинг"', 'ПАО "Казаньоргсинтез"', 'Pyotr_Kondrashov', 'q10000141', 'CNY', 1296774, 80, 'won'),
('2000142-CS-Analytical ООО "Дельта Инжиниринг" / ООО "Новороссийский мазутный терминал" q10000142', 'ООО "Дельта Инжиниринг"', 'ООО "Новороссийский мазутный терминал"', 'Vladislav_Volkov', 'q10000142', 'RUB', 1442111, 15, 'lost'),
('2000143-FE-TPFL ООО " НПК ИТР" / Exxon Neftegas Limited - Chayvo OPF q10000143', 'ООО " НПК ИТР"', 'Exxon Neftegas Limited - Chayvo OPF', 'Maxim_Kuznetsov', 'q10000143', 'CNY', 335641, 75, 'won'),
('2000144-VL-Analytical ООО "Бантер Групп" / ООО "Ока-Синтез" q10000144', 'ООО "Бантер Групп"', 'ООО "Ока-Синтез"', 'Ivan_Belov', 'q10000144', 'EUR', 205, 10, 'won'),
('2000145-UR-VR ООО "Эртей Петрошем Рус"  / ОАО "Ямал СПГ" q10000145', 'ООО "Эртей Петрошем Рус" ', 'ОАО "Ямал СПГ"', 'Vladislav_Volkov', 'q10000145', 'GBP', 3784, 50, 'won'),
('2000146-CS-TPFL ООО "Стронгарм" / ООО "ТУЛАЧЕРМЕТ-СТАЛЬ" q10000146', 'ООО "Стронгарм"', 'ООО "ТУЛАЧЕРМЕТ-СТАЛЬ"', 'Luka_Kuznetsov', 'q10000146', 'JPY', 2755801, 15, 'lost'),
('2000147-CS-APCS ООО "Стройтехлогистика" / ООО "Новороссийский мазутный терминал" q10000147', 'ООО "Стройтехлогистика"', 'ООО "Новороссийский мазутный терминал"', 'Pyotr_Kondrashov', 'q10000147', 'CHF', 20977, 60, 'lost'),
('2000148-CS-APCS ООО "Дельта Инжиниринг" / Erdemir Group, ИСКЕНДЕРУНСКИЙ МЕТАЛЛУРГИЧЕСКИЙ КОМБИНАТ q10000148', 'ООО "Дельта Инжиниринг"', 'Erdemir Group, ИСКЕНДЕРУНСКИЙ МЕТАЛЛУРГИЧЕСКИЙ КОМБИНАТ', 'Luka_Kuznetsov', 'q10000148', 'USD', 39151, 35, 'lost'),
('2000149-CS-Analytical ООО "СМС" / АО "Газпромнефть-МНПЗ" q10000149', 'ООО "СМС"', 'АО "Газпромнефть-МНПЗ"', 'Vladislav_Volkov', 'q10000149', 'GBP', 3271, 100, 'canceled'),
('2000150-VL-APCS ООО "СНЭМА-Сервис" / АО "Интер РАО электрогенерация - филиал "Пермская ГРЭС" q10000150', 'ООО "СНЭМА-Сервис"', 'АО "Интер РАО электрогенерация - филиал "Пермская ГРЭС"', 'Vladislav_Shishkin', 'q10000150', 'USD', 23461, 35, 'lost'),
('2000151-CS-TPFL ООО "Дельта Инжиниринг" / ООО "Афипский НПЗ" q10000151', 'ООО "Дельта Инжиниринг"', 'ООО "Афипский НПЗ"', 'Ivan_Belov', 'q10000151', 'JPY', 3211566, 70, 'lost'),
('2000152-CS-VR АО "Электронстандарт-прибор" / ООО "Славянск ЭКО" q10000152', 'АО "Электронстандарт-прибор"', 'ООО "Славянск ЭКО"', 'Vladislav_Volkov', 'q10000152', 'EUR', 45939, 75, 'canceled'),
('2000153-UR-Analytical ООО "АЛМАЗ ГРУПП" / ООО "СевКомНефтегаз" q10000153', 'ООО "АЛМАЗ ГРУПП"', 'ООО "СевКомНефтегаз"', 'Fedor_Bychkov', 'q10000153', 'JPY', 22026787, 45, 'lost'),
('2000154-FE-TPFL ООО "ХРОМОС Инжиниринг" / Exxon Neftegas Limited - Chayvo OPF q10000154', 'ООО "ХРОМОС Инжиниринг"', 'Exxon Neftegas Limited - Chayvo OPF', 'Vladislav_Volkov', 'q10000154', 'CHF', 11936, 35, 'canceled'),
('2000155-VL-VR АО "РЭП Холдинг" / ООО "НЗМП" q10000155', 'АО "РЭП Холдинг"', 'ООО "НЗМП"', 'Ivan_Belov', 'q10000155', 'GBP', 239460, 100, 'won'),
('2000156-CS-Analytical ООО "Стронгарм" / АО "ОЭМК" q10000156', 'ООО "Стронгарм"', 'АО "ОЭМК"', 'Pyotr_Kondrashov', 'q10000156', 'USD', 21954, 95, 'canceled'),
('2000157-VL-APCS ООО "Бантер Групп" / ОАО "Пермская ГРЭС"  q10000157', 'ООО "Бантер Групп"', 'ОАО "Пермская ГРЭС" ', 'Vladislav_Volkov', 'q10000157', 'GBP', 135460, 25, 'lost'),
('2000158-NW-Analytical ООО "Бантер Групп" / ООО "ПОРТЭНЕРГО" q10000158', 'ООО "Бантер Групп"', 'ООО "ПОРТЭНЕРГО"', 'Vladimir_Galkin', 'q10000158', 'USD', 19772, 75, 'won'),
('2000159-NW-VR ООО "НПО "ЭКОХИМПРИБОР" / ООО "Газ Синтез" q10000159', 'ООО "НПО "ЭКОХИМПРИБОР"', 'ООО "Газ Синтез"', 'Vladimir_Galkin', 'q10000159', 'CHF', 137439, 20, 'lost'),
('2000160-CS-TPFL ООО "Стройтехлогистика" / ООО "ИЛЬСКИЙ НПЗ" q10000160', 'ООО "Стройтехлогистика"', 'ООО "ИЛЬСКИЙ НПЗ"', 'Demyan_Andrianov', 'q10000160', 'CHF', 141301, 10, 'canceled'),
('2000161-SB-VR ООО "Велесстрой" / ООО "Тагульское" q10000161', 'ООО "Велесстрой"', 'ООО "Тагульское"', 'Georgy_Romanov', 'q10000161', 'JPY', 940562, 30, 'won'),
('2000162-VL-VR ООО "РусПромЭнергоСистемы" / АО "Интер РАО электрогенерация - филиал "Пермская ГРЭС" q10000162', 'ООО "РусПромЭнергоСистемы"', 'АО "Интер РАО электрогенерация - филиал "Пермская ГРЭС"', 'Luka_Kuznetsov', 'q10000162', 'JPY', 6258484, 85, 'lost'),
('2000163-VL-APCS АО "РЭП Холдинг" / ООО "Газпромнефть - Оренбург" q10000163', 'АО "РЭП Холдинг"', 'ООО "Газпромнефть - Оренбург"', 'Luka_Kuznetsov', 'q10000163', 'JPY', 4851153, 100, 'canceled'),
('2000164-VL-APCS ООО "ТД "Автоматика" / АО "Новокуйбышевский НПЗ" q10000164', 'ООО "ТД "Автоматика"', 'АО "Новокуйбышевский НПЗ"', 'Vladislav_Volkov', 'q10000164', 'CHF', 27594, 45, 'won'),
('2000165-CS-Analytical ООО "Автоматика Сервис" / Erdemir Group, ИСКЕНДЕРУНСКИЙ МЕТАЛЛУРГИЧЕСКИЙ КОМБИНАТ q10000165', 'ООО "Автоматика Сервис"', 'Erdemir Group, ИСКЕНДЕРУНСКИЙ МЕТАЛЛУРГИЧЕСКИЙ КОМБИНАТ', 'Pyotr_Kondrashov', 'q10000165', 'CHF', 26830, 85, 'canceled'),
('2000166-CS-APCS ООО "МНУ-1 Корпорации АК "ЭСКМ" / АО "НЗНП" q10000166', 'ООО "МНУ-1 Корпорации АК "ЭСКМ"', 'АО "НЗНП"', 'Luka_Kuznetsov', 'q10000166', 'RUB', 1487972, 55, 'canceled'),
('2000167-SB-APCS АО "Электронстандарт-прибор" / ОАО "ГМЗ" q10000167', 'АО "Электронстандарт-прибор"', 'ОАО "ГМЗ"', 'Demyan_Andrianov', 'q10000167', 'CNY', 284390, 80, 'lost'),
('2000168-VL-VR ООО "АЙ-ТИ-СИ" / ОЭЗ "Алабуга" q10000168', 'ООО "АЙ-ТИ-СИ"', 'ОЭЗ "Алабуга"', 'Luka_Kuznetsov', 'q10000168', 'GBP', 16423, 60, 'lost'),
('2000169-FE-Analytical ООО "Автоматика Сервис" / ОАО "АЛРОСА-Газ" q10000169', 'ООО "Автоматика Сервис"', 'ОАО "АЛРОСА-Газ"', 'Maxim_Kuznetsov', 'q10000169', 'CNY', 18264, 30, 'lost'),
('2000170-CS-TPFL АО "Электронстандарт-прибор" / ООО "РН - Ставропольнефтегаз" q10000170', 'АО "Электронстандарт-прибор"', 'ООО "РН - Ставропольнефтегаз"', 'Pyotr_Kondrashov', 'q10000170', 'CHF', 23088, 65, 'canceled'),
('2000171-UR-TPFL ООО "РЕМОНТ-СЕРВИС" / ООО "Газпромнефть - Хантос" q10000171', 'ООО "РЕМОНТ-СЕРВИС"', 'ООО "Газпромнефть - Хантос"', 'Ivan_Belov', 'q10000171', 'RUB', 313646, 35, 'lost'),
('2000172-UR-Analytical ООО "Энергия холода" / ООО "РН-Пурнефтегаз" q10000172', 'ООО "Энергия холода"', 'ООО "РН-Пурнефтегаз"', 'Fedor_Bychkov', 'q10000172', 'CNY', 233374, 70, 'canceled'),
('2000173-VL-TPFL ООО "Эртей Петрошем Рус"  / АО "Оренбургнефть" q10000173', 'ООО "Эртей Петрошем Рус" ', 'АО "Оренбургнефть"', 'Ivan_Belov', 'q10000173', 'CHF', 15248, 35, 'canceled'),
('2000174-CS-Analytical ООО "Энтренс Электроникс" / АО "РНПК" q10000174', 'ООО "Энтренс Электроникс"', 'АО "РНПК"', 'Pyotr_Kondrashov', 'q10000174', 'GBP', 1877, 35, 'lost'),
('2000175-CS-VR ООО "РЕКОН" / АО "Невинномысский Азот" q10000175', 'ООО "РЕКОН"', 'АО "Невинномысский Азот"', 'Luka_Kuznetsov', 'q10000175', 'CHF', 12727, 25, 'lost'),
('2000176-VL-VR ООО "Автоматика Сервис" / ООО "Газпром ПХГ" "Песчано - Уметское УПХГ" q10000176', 'ООО "Автоматика Сервис"', 'ООО "Газпром ПХГ" "Песчано - Уметское УПХГ"', 'Vladislav_Shishkin', 'q10000176', 'USD', 48579, 45, 'canceled'),
('2000177-NW-Analytical ООО "МНУ-1 Корпорации АК "ЭСКМ" / ПАО "Северсталь" q10000177', 'ООО "МНУ-1 Корпорации АК "ЭСКМ"', 'ПАО "Северсталь"', 'Luka_Kuznetsov', 'q10000177', 'CNY', 225166, 50, 'at_work'),
('2000178-SB-APCS ООО "ЭТМ" / АО "ННК-Хабаровский нефтеперерабатывающий завод" q10000178', 'ООО "ЭТМ"', 'АО "ННК-Хабаровский нефтеперерабатывающий завод"', 'Luka_Kuznetsov', 'q10000178', 'CNY', 155914, 35, 'lost'),
('2000179-UR-TPFL ООО "РусПромЭнергоСистемы" / ООО "Арктик СПГ 2" q10000179', 'ООО "РусПромЭнергоСистемы"', 'ООО "Арктик СПГ 2"', 'Demyan_Andrianov', 'q10000179', 'JPY', 6447524, 15, 'at_work'),
('2000180-VL-VR ООО "ВЕЛМАС" / ОЭЗ "Алабуга" q10000180', 'ООО "ВЕЛМАС"', 'ОЭЗ "Алабуга"', 'Luka_Kuznetsov', 'q10000180', 'JPY', 2624692, 80, 'at_work'),
('2000181-CS-APCS ООО "РЕМОНТ-СЕРВИС" / ООО "Славянск ЭКО" q10000181', 'ООО "РЕМОНТ-СЕРВИС"', 'ООО "Славянск ЭКО"', 'Pyotr_Kondrashov', 'q10000181', 'GBP', 146154, 90, 'at_work'),
('2000182-VL-APCS ООО "Энергия холода" / ПАО "Нижнекамскнефтехим" q10000182', 'ООО "Энергия холода"', 'ПАО "Нижнекамскнефтехим"', 'Vladislav_Volkov', 'q10000182', 'CNY', 354097, 95, 'lost'),
('2000183-CS-Analytical ООО "МНУ-1 Корпорации АК "ЭСКМ" / АО "Невинномысский Азот" q10000183', 'ООО "МНУ-1 Корпорации АК "ЭСКМ"', 'АО "Невинномысский Азот"', 'Pyotr_Kondrashov', 'q10000183', 'JPY', 9686796, 45, 'canceled'),
('2000184-CS-VR ООО "НПО "ЭКОХИМПРИБОР" / ООО "ИЛЬСКИЙ НПЗ" q10000184', 'ООО "НПО "ЭКОХИМПРИБОР"', 'ООО "ИЛЬСКИЙ НПЗ"', 'Pyotr_Kondrashov', 'q10000184', 'USD', 2232, 60, 'at_work'),
('2000185-SB-VR ООО "Бантер Групп" / ЗАО "Омский завод инновационных технологий" q10000185', 'ООО "Бантер Групп"', 'ЗАО "Омский завод инновационных технологий"', 'Vladislav_Volkov', 'q10000185', 'JPY', 660581, 65, 'won'),
('2000186-UR-Analytical ООО "РЕКОН" / ООО "Соровскнефть" q10000186', 'ООО "РЕКОН"', 'ООО "Соровскнефть"', 'Ivan_Belov', 'q10000186', 'RUB', 3355921, 15, 'won'),
('2000187-VL-Analytical ООО "Автоматика Сервис" / ООО "НЗМП" q10000187', 'ООО "Автоматика Сервис"', 'ООО "НЗМП"', 'Demyan_Andrianov', 'q10000187', 'CHF', 121649, 35, 'at_work'),
('2000188-VL-TPFL ООО "Метрология-Комплект" / АО "СИБУР - Нефтехим" q10000188', 'ООО "Метрология-Комплект"', 'АО "СИБУР - Нефтехим"', 'Vladislav_Shishkin', 'q10000188', 'GBP', 8113, 20, 'at_work'),
('2000189-FE-Analytical ООО "ГИДРОТЕХ" / Store (SEIC) q10000189', 'ООО "ГИДРОТЕХ"', 'Store (SEIC)', 'Luka_Kuznetsov', 'q10000189', 'CNY', 195750, 95, 'lost'),
('2000190-VL-APCS ООО "Эртей Петрошем Рус"  / АО "СИБУР - Нефтехим" q10000190', 'ООО "Эртей Петрошем Рус" ', 'АО "СИБУР - Нефтехим"', 'Demyan_Andrianov', 'q10000190', 'CHF', 82921, 40, 'won'),
('2000191-VL-TPFL ООО "ВЕЛМАС" / АО "Новокуйбышевский НПЗ" q10000191', 'ООО "ВЕЛМАС"', 'АО "Новокуйбышевский НПЗ"', 'Vladislav_Shishkin', 'q10000191', 'CHF', 11504, 20, 'at_work'),
('2000192-SB-APCS ООО "ЭТМ" / ООО "ИНК" q10000192', 'ООО "ЭТМ"', 'ООО "ИНК"', 'Georgy_Romanov', 'q10000192', 'CNY', 262285, 30, 'canceled'),
('2000193-VL-Analytical АО "ГМС Нефтемаш" / ООО "ЛУКОЙЛ-Пермнефтеоргсинтез" q10000193', 'АО "ГМС Нефтемаш"', 'ООО "ЛУКОЙЛ-Пермнефтеоргсинтез"', 'Vladislav_Shishkin', 'q10000193', 'JPY', 36764250, 80, 'at_work'),
('2000194-UR-Analytical ООО "РЕКОН" / ООО "Газпромнефть - Заполярье"  q10000194', 'ООО "РЕКОН"', 'ООО "Газпромнефть - Заполярье" ', 'Demyan_Andrianov', 'q10000194', 'CNY', 207791, 10, 'canceled'),
('2000195-UR-Analytical ООО "АЭРОЗОЛЕКС" / ООО "СевКомНефтегаз" q10000195', 'ООО "АЭРОЗОЛЕКС"', 'ООО "СевКомНефтегаз"', 'Fedor_Bychkov', 'q10000195', 'EUR', 169492, 95, 'won'),
('2000196-CS-Analytical ООО "ЭТМ" / Erdemir Group, ИСКЕНДЕРУНСКИЙ МЕТАЛЛУРГИЧЕСКИЙ КОМБИНАТ q10000196', 'ООО "ЭТМ"', 'Erdemir Group, ИСКЕНДЕРУНСКИЙ МЕТАЛЛУРГИЧЕСКИЙ КОМБИНАТ', 'Ivan_Belov', 'q10000196', 'GBP', 27546, 75, 'lost'),
('2000197-UR-TPFL ООО "РЕМОНТ-СЕРВИС" / ОАО "Ямал СПГ" q10000197', 'ООО "РЕМОНТ-СЕРВИС"', 'ОАО "Ямал СПГ"', 'Fedor_Bychkov', 'q10000197', 'EUR', 42782, 90, 'at_work'),
('2000198-SB-TPFL ООО "АумаПриводСервис" / ЗАО "Омский завод инновационных технологий" q10000198', 'ООО "АумаПриводСервис"', 'ЗАО "Омский завод инновационных технологий"', 'Demyan_Andrianov', 'q10000198', 'CNY', 202649, 45, 'canceled'),
('2000199-VL-TPFL ООО "Осмотикс" / ООО "Газпром ПХГ" "Песчано - Уметское УПХГ" q10000199', 'ООО "Осмотикс"', 'ООО "Газпром ПХГ" "Песчано - Уметское УПХГ"', 'Luka_Kuznetsov', 'q10000199', 'GBP', 20749, 40, 'at_work')
;

-- заполнение таблицы заводов-изготовителей компании
INSERT factories (factory_name, country, phone, currency) VALUES
('TM_Hasselroth_factory', 'Germany', '89086709771', 'EUR'),
('TM_Houston_factory', 'USA', '89489207713', 'USD'),
('TM_Chelyabinsk_factory', 'Russia', '89584561553', 'RUB'),
('TM_Chengdu_factory', 'China', '89265264852', 'CNY'),
('TM_Kyoto_factory', 'Japan', '89369728595', 'JPY'),
('TM_Geneva_factory', 'Switzerland', '89711139619', 'CHF'),
('TM_Birmingham_factory', 'UK', '89017339402', 'GBP')
;

-- заполнение таблицы статусов, размещённых в производство заказов
INSERT order_statuses (order_status) VALUES
('placed'),
('paid'),
('approved'),
('production'),
('delivery'),
('delivered')
;

-- заполнение таблицы, размещённых в производство заказов
INSERT placement (order_number, factory_name, order_status, quote_number, currency, amount) VALUES
('PL0000001', 'TM_Birmingham_factory', 'delivered', 'q10000001', 'GBP', 22900),
('PL0000002', 'TM_Chelyabinsk_factory', 'delivered', 'q10000003', 'RUB', 1276882),
('PL0000003', 'TM_Birmingham_factory', 'delivered', 'q10000004', 'GBP', 392),
('PL0000004', 'TM_Chengdu_factory', 'delivered', 'q10000006', 'CNY', 156398),
('PL0000005', 'TM_Chengdu_factory', 'delivered', 'q10000007', 'CNY', 75696),
('PL0000006', 'TM_Houston_factory', 'delivery', 'q10000011', 'USD', 9516),
('PL0000007', 'TM_Birmingham_factory', 'delivered', 'q10000014', 'GBP', 7713),
('PL0000008', 'TM_Birmingham_factory', 'delivery', 'q10000017', 'GBP', 30732),
('PL0000009', 'TM_Birmingham_factory', 'delivered', 'q10000024', 'GBP', 25043),
('PL0000010', 'TM_Hasselroth_factory', 'delivered', 'q10000025', 'EUR', 37000),
('PL0000011', 'TM_Birmingham_factory', 'delivery', 'q10000026', 'GBP', 34537),
('PL0000012', 'TM_Houston_factory', 'delivery', 'q10000031', 'USD', 151477),
('PL0000013', 'TM_Chengdu_factory', 'delivery', 'q10000034', 'CNY', 98469),
('PL0000014', 'TM_Birmingham_factory', 'delivered', 'q10000035', 'GBP', 36369),
('PL0000015', 'TM_Geneva_factory', 'delivery', 'q10000036', 'CHF', 22531),
('PL0000016', 'TM_Hasselroth_factory', 'delivery', 'q10000038', 'EUR', 46317),
('PL0000017', 'TM_Kyoto_factory', 'delivered', 'q10000039', 'JPY', 5663523),
('PL0000018', 'TM_Hasselroth_factory', 'delivery', 'q10000040', 'EUR', 17373),
('PL0000019', 'TM_Chelyabinsk_factory', 'delivery', 'q10000050', 'RUB', 11755573),
('PL0000020', 'TM_Kyoto_factory', 'delivery', 'q10000055', 'JPY', 2955844),
('PL0000021', 'TM_Chelyabinsk_factory', 'production', 'q10000062', 'RUB', 14241810),
('PL0000022', 'TM_Hasselroth_factory', 'production', 'q10000066', 'EUR', 1678),
('PL0000023', 'TM_Houston_factory', 'production', 'q10000067', 'USD', 1839),
('PL0000024', 'TM_Houston_factory', 'production', 'q10000069', 'USD', 39151),
('PL0000025', 'TM_Chelyabinsk_factory', 'production', 'q10000070', 'RUB', 801665),
('PL0000026', 'TM_Hasselroth_factory', 'production', 'q10000072', 'EUR', 14621),
('PL0000027', 'TM_Birmingham_factory', 'production', 'q10000078', 'GBP', 243892),
('PL0000028', 'TM_Chengdu_factory', 'production', 'q10000081', 'CNY', 281140),
('PL0000029', 'TM_Hasselroth_factory', 'production', 'q10000082', 'EUR', 44102),
('PL0000030', 'TM_Kyoto_factory', 'production', 'q10000084', 'JPY', 6141162),
('PL0000031', 'TM_Houston_factory', 'production', 'q10000087', 'USD', 131963),
('PL0000032', 'TM_Chelyabinsk_factory', 'production', 'q10000089', 'RUB', 986237),
('PL0000033', 'TM_Hasselroth_factory', 'production', 'q10000091', 'EUR', 29883),
('PL0000034', 'TM_Kyoto_factory', 'production', 'q10000095', 'JPY', 4232994),
('PL0000035', 'TM_Houston_factory', 'approved', 'q10000096', 'USD', 35505),
('PL0000036', 'TM_Kyoto_factory', 'approved', 'q10000109', 'JPY', 4575282),
('PL0000037', 'TM_Chengdu_factory', 'production', 'q10000110', 'CNY', 29139),
('PL0000038', 'TM_Chelyabinsk_factory', 'production', 'q10000118', 'RUB', 2156413),
('PL0000039', 'TM_Chengdu_factory', 'approved', 'q10000124', 'CNY', 1432681),
('PL0000040', 'TM_Chelyabinsk_factory', 'approved', 'q10000131', 'RUB', 2642041),
('PL0000041', 'TM_Chengdu_factory', 'approved', 'q10000137', 'CNY', 243210),
('PL0000042', 'TM_Chengdu_factory', 'approved', 'q10000141', 'CNY', 1296774),
('PL0000043', 'TM_Chengdu_factory', 'paid', 'q10000143', 'CNY', 335641),
('PL0000044', 'TM_Hasselroth_factory', 'paid', 'q10000144', 'EUR', 205),
('PL0000045', 'TM_Birmingham_factory', 'placed', 'q10000145', 'GBP', 3784),
('PL0000046', 'TM_Birmingham_factory', 'paid', 'q10000155', 'GBP', 239460),
('PL0000047', 'TM_Houston_factory', 'paid', 'q10000158', 'USD', 19772),
('PL0000048', 'TM_Kyoto_factory', 'placed', 'q10000161', 'JPY', 940562),
('PL0000049', 'TM_Geneva_factory', 'paid', 'q10000164', 'CHF', 27594),
('PL0000050', 'TM_Kyoto_factory', 'placed', 'q10000185', 'JPY', 660581),
('PL0000051', 'TM_Chelyabinsk_factory', 'placed', 'q10000186', 'RUB', 3355921),
('PL0000052', 'TM_Geneva_factory', 'placed', 'q10000190', 'CHF', 82921),
('PL0000053', 'TM_Hasselroth_factory', 'placed', 'q10000195', 'EUR', 169492)
;


-- -----------------------------------------------------------------------------
-- 6. ВЫБОРКИ ДАННЫХ
-- -----------------------------------------------------------------------------

-- 1. Выведем список технико-коммерческих предложений с размещённым оборудованием из Швейцарии и Германии
SELECT 
	quote_number,
	end_user
	FROM opportunities
WHERE quote_number IN (SELECT quote_number FROM placement WHERE factory_name IN 
(SELECT factory_name FROM factories WHERE country = 'Switzerland' OR country = 'Germany'));


-- 2. Выведем список количества потенциальных сделок и продавцов ответственных за их проведение
SELECT 
	responsible_seller_account,
	COUNT(*) AS 'quantity'	
	FROM opportunities o 
GROUP BY responsible_seller_account 
ORDER BY COUNT(*) DESC;


-- 3. Выведем данные по стоимостям оборудования в ТКП и выразим их в рублях и долларах
SELECT 
	qt.sales_engineer_account,
	qt.quote_number,
	qt.amount,
	c.currency,
	c.currency_course,
	ROUND(amount * c.currency_course, 2) AS 'amount in RUB',
	ROUND(amount * c.currency_course / (SELECT currency_course FROM currencies WHERE currency = 'USD'), 2) AS 'amount in USD'
	FROM quote_table qt 
		JOIN currencies c WHERE c.currency = qt.currency
		ORDER BY quote_number;

	
-- 4. Определим объёмы продаж по линейкам оборудования, выраженные в рублях
SELECT 
	qt.business_category,
	ROUND(SUM(o.amount * c.currency_course), 2) AS 'sum, RUB'
FROM quote_table qt  
JOIN opportunities o ON qt.quote_number = o.quote_number
JOIN currencies c ON c.currency = qt.currency 
WHERE o.op_status = 'won'
GROUP BY qt.business_category 
ORDER BY `sum, RUB` DESC;


-- 5. Выведем список инженеров, общее количество и сумму в выданных ими ТКП, количество и сумму в выданных ими ТКП для выйграных сделок, 
-- выразим в рублях и определим эффективность работы
SELECT 
	t1.sales_engineer_account,
	t1.`sum, RUB`,
	t2.`won sum, RUB`,
	ROUND(t2.`won sum, RUB`/ t1.`sum, RUB` * 100, 2) AS 'efficiency, %',
	t1.`quantity`,
	t2.`won quantity`	 
FROM
	(SELECT
	qt.sales_engineer_account,
	ROUND(SUM(qt.amount * c.currency_course), 2) AS 'sum, RUB',
	COUNT(qt.quote_number) AS 'quantity'	
		FROM quote_table qt	
		JOIN currencies c ON c.currency = qt.currency
		JOIN opportunities o ON o.quote_number = qt.quote_number 
		GROUP BY qt.sales_engineer_account) t1,	
	(SELECT
	qt.sales_engineer_account,
	ROUND(SUM(qt.amount * c.currency_course), 2) AS 'won sum, RUB',
	COUNT(qt.quote_number) AS 'won quantity'	
		FROM quote_table qt	
		JOIN currencies c ON c.currency = qt.currency
		JOIN opportunities o ON o.quote_number = qt.quote_number 
		WHERE o.op_status = 'won'
		GROUP BY qt.sales_engineer_account) t2
	WHERE t2.sales_engineer_account = t1.sales_engineer_account
	ORDER BY `efficiency, %` DESC;


-- 6. Выведем список компаний - конечных пользователей, общее количество и сумму выданных ТКП, количество и сумму ТКП для выйграных потенциальных сделок, 
-- выраим в рублях и определим эффективность работы с ними
SELECT 
	t1.end_user,
	t1.`sum, RUB`,
	t2.`won sum, RUB`,
	ROUND(t2.`won sum, RUB`/ t1.`sum, RUB` * 100, 2) AS 'efficiency, %',
	t1.`quantity`,
	t2.`won quantity`	 
FROM
	(SELECT
		o.end_user,
		COUNT(o.opportunity_name) AS 'quantity',
		ROUND(SUM(o.amount * c.currency_course), 2) AS 'sum, RUB'
		FROM opportunities o 
		JOIN currencies c ON c.currency = o.currency 
		GROUP BY o.end_user) t1,
	(SELECT	
		o.end_user,
		COUNT(o.opportunity_name) AS 'won quantity',
		ROUND(SUM(o.amount * c.currency_course), 2) AS 'won sum, RUB'
		FROM opportunities o
		JOIN currencies c ON c.currency = o.currency
		WHERE o.op_status = 'won'
		GROUP BY o.end_user) t2	
	WHERE t2.end_user = t1.end_user
	ORDER BY t2.`won sum, RUB` DESC,`efficiency, %` DESC;


-- -----------------------------------------------------------------------------
-- 7. Представления
-- -----------------------------------------------------------------------------

-- 1. Создадим представление для просмотра информации по сделкам и связанным ТКП
CREATE OR REPLACE VIEW view_opportunity
AS
SELECT 
	opportunity_name, 
	customer, 
	end_user,
	responsible_seller_account,
	qt.quote_number,
	o.currency,
	o.amount,
	op_status,
	sales_engineer_account,
	business_category,
	sent_date
	FROM opportunities o
	JOIN quote_table qt ON qt.quote_number = o.quote_number;

-- Выведем информацию о сделках для указанного ответственного продавца и категории продукта
SELECT * FROM view_opportunity
WHERE responsible_seller_account = 'Luka_Kuznetsov' AND business_category = 'Gas_chromatographs';
	

-- 2. Создадим представление для просмотра текущих потенциальных сделок в указанном регионе
CREATE OR REPLACE VIEW view_opportunity_region
AS
SELECT 
	opportunity_name, 
	quote_number, 
	customer, 
	end_user, 
	currency, 
	amount, 
	responsible_seller_account, 
	win_probability,
	end_user_region
	FROM opportunities o 
	JOIN end_users eu ON o.end_user = eu.end_user_name
	WHERE o.op_status = 'at_work';

-- Выведем информацио о текущих потенциальных сделках в указанном регионе
SELECT * FROM view_opportunity_region
WHERE end_user_region = 'UR';
	
	
-- -----------------------------------------------------------------------------
-- 8.1 Хранимые процедуры
-- -----------------------------------------------------------------------------

-- 1. Создадим процедуру для добавления ТКП и потенциальной сделки в БД с проверкой правильности вводимых данных
DROP PROCEDURE IF EXISTS sp_quote_opportunity_add;
DELIMITER //
//
CREATE DEFINER = `root`@`localhost` PROCEDURE `sp_quote_opportunity_add` (
	opportunity_name VARCHAR (500), customer VARCHAR (100), 
	end_user VARCHAR (100), responsible_seller_account VARCHAR (20), 
	quote_number VARCHAR (20), currency VARCHAR (3), 
	amount FLOAT, win_probability INT, op_status VARCHAR (10),
	sales_engineer_account VARCHAR (40), business_category VARCHAR (100), sent_date DATE,
	OUT tran_result VARCHAR (1000)
	)
BEGIN
	DECLARE `_rollback` BIT DEFAULT 0;
	DECLARE code VARCHAR(100);
	DECLARE error_string VARCHAR(100); 
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			SET `_rollback` = 1;
			GET stacked DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
			SET tran_result = CONCAT('Ошибка ввода данных: ', code, ' Текст ошибки: ', error_string);
END;
START TRANSACTION;
INSERT INTO quote_table (quote_number, sales_engineer_account, business_category, sent_date, currency, amount)
VALUES (quote_number, sales_engineer_account, business_category, sent_date, currency, amount);
INSERT INTO opportunities (opportunity_name, customer, end_user, responsible_seller_account, quote_number, currency, amount, win_probability, op_status)
VALUES (opportunity_name, customer, end_user, responsible_seller_account, quote_number, currency, amount, win_probability, op_status);
IF `_rollback` THEN
ROLLBACK;
ELSE
SET tran_result = 'OK';
COMMIT;
END IF;
END//
DELIMITER ;

-- Добавим ТКП и потенциальную сделку в базу данных
CALL sp_quote_opportunity_add ('2000200-VL-APCS ООО "ЭТМ" / ООО "Газпром ПХГ" "Песчано - Уметское УПХГ" q10000200', 
'ООО "ЭТМ"', 'ООО "Газпром ПХГ" "Песчано - Уметское УПХГ"', 
'Luka_Kuznetsov', 'q10000200', 'EUR', 50522, 40, 'at_work', 
'Vadim_Verchenko', 'Gas_chromatographs', '2023-10-28', @tran_result);
-- проверим правильность ввода данных
SELECT @tran_result;
	


-- 2. Создадим процедуру для удаления ошибочно созданных ТКП и потенциальной сделки в БД с проверкой наличия в БД
DROP PROCEDURE IF EXISTS sp_quote_opportunity_delete;
DELIMITER //
//
CREATE DEFINER = `root`@`localhost` PROCEDURE `sp_quote_opportunity_delete` (
	opportunity_name_del VARCHAR (500), quote_number_del VARCHAR (20), OUT tran_result2 VARCHAR (1000)
	)
BEGIN
START TRANSACTION;
IF (SELECT COUNT(*) FROM opportunities WHERE opportunity_name = opportunity_name_del) = 0 OR 
(SELECT COUNT(*) FROM quote_table WHERE quote_number = quote_number_del) = 0
THEN SET tran_result2 = 'Не найдено записей для удаления';	
ELSE
	DELETE FROM opportunities WHERE opportunity_name = opportunity_name_del;
	DELETE FROM quote_table WHERE quote_number = quote_number_del;
	SET tran_result2 = 'ПС и ТКП удалены из базы';
END IF;
END//
DELIMITER ;

-- удалим ошибочное ТКП и потенциальную сделку из базы данных
CALL sp_quote_opportunity_delete('2000200-VL-APCS ООО "ЭТМ" / ООО "Газпром ПХГ" "Песчано - Уметское УПХГ" q10000200', 'q10000200', @tran_result2);
-- проверим правильность ввода данных
SELECT @tran_result2;


	
-- -----------------------------------------------------------------------------
-- 8.2 Триггеры
-- -----------------------------------------------------------------------------

-- 1. Создадим триггер для проверки корректности даты выдачи ТКП
DROP TRIGGER IF EXISTS check_quote_sent_date;
DELIMITER //
CREATE TRIGGER check_quote_sent_date BEFORE INSERT ON quote_table
FOR EACH ROW
BEGIN
	IF NEW.sent_date > CURRENT_DATE() THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Проверьте дату выдачи ТКП';
	END IF;
END//
DELIMITER ;

-- проверим срабатывание триггера
INSERT quote_table (quote_number, sales_engineer_account, business_category, sent_date, currency, amount) VALUES
('q10000200', 'Vadim_Verchenko', 'Gas_chromatographs', '2035-03-01', 'USD', 48297);


-- 2. Создадим триггер для проверки лимитов стоимости ТКП (100...1000000 USD)
DROP TRIGGER IF EXISTS check_quote_amount;
DELIMITER //
CREATE TRIGGER check_quote_amount BEFORE INSERT ON quote_table
FOR EACH ROW
BEGIN 
	IF (NEW.amount * (SELECT currency_course FROM currencies WHERE currency = NEW.currency) / (SELECT currency_course FROM currencies WHERE currency = 'USD')) > 1000000 OR 
	(NEW.amount * (SELECT currency_course FROM currencies WHERE currency = NEW.currency) / (SELECT currency_course FROM currencies WHERE currency = 'USD')) < 100
	THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Стоимость ТКП должа быть в пределах 100...1000000 USD!';
	END IF;
END//
DELIMITER ;

-- проверка триггера
-- пересчитаем USD в RUB
SELECT ROUND(1000001 * (SELECT currency_course FROM currencies WHERE currency = 'USD') / (SELECT currency_course FROM currencies WHERE currency = 'RUB'), 2);
SELECT ROUND(999999 * (SELECT currency_course FROM currencies WHERE currency = 'USD') / (SELECT currency_course FROM currencies WHERE currency = 'RUB'), 2);
-- проверим срабатывание триггера в 1000001 USD = 70340066.68 RUB
INSERT quote_table (quote_number, sales_engineer_account, business_category, sent_date, currency, amount) VALUES
('q10000200', 'Vadim_Verchenko', 'Gas_chromatographs', '2021-03-01', 'RUB', 70340066.68);

-- пересчитаем USD в CHF
SELECT ROUND(1000001 * (SELECT currency_course FROM currencies WHERE currency = 'USD') / (SELECT currency_course FROM currencies WHERE currency = 'CHF'), 2);
SELECT ROUND(999999 * (SELECT currency_course FROM currencies WHERE currency = 'USD') / (SELECT currency_course FROM currencies WHERE currency = 'CHF'), 2);
-- проверим срабатывание триггера в 1000001 USD = 923340.33 CHF
INSERT quote_table (quote_number, sales_engineer_account, business_category, sent_date, currency, amount) VALUES
('q10000200', 'Vadim_Verchenko', 'Gas_chromatographs', '2021-03-01', 'CHF', 923340.33);













