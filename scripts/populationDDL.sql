-- Drop if exists and create pop.population_demo
IF OBJECT_ID('pop.population_demo', 'U') IS NOT NULL
    DROP TABLE pop.population_demo
CREATE TABLE pop.population_demo (
    country_name NVARCHAR(200),
    population_year INT,
    population_total BIGINT, 
    population_children_under_1 FLOAT,
    population_children_under_5 BIGINT,
    population_children_under_15 BIGINT,
    population_under_25 BIGINT,
    population_15_to_64 BIGINT,
    population_older_15 BIGINT,
    population_older_18 BIGINT,
    population_at_1 FLOAT,
    population_1_to_4 FLOAT,
    population_5_to_9 BIGINT,
    population_10_to_14 BIGINT,
    population_15_to_19 BIGINT,
    population_20_to_29 BIGINT,
    population_30_to_39 BIGINT,
    population_40_to_49 BIGINT,
    population_50_to_59 BIGINT,
    population_60_to_69 BIGINT,
    population_70_to_79 BIGINT,
    population_80_to_89 BIGINT,
    population_90_to_99 BIGINT,
    population_100_above FLOAT
);
GO

-- Truncating table if data already exists 
TRUNCATE TABLE pop.population_demo;
GO

-- Loading data into table pop.population_demo
BULK INSERT pop.population_demo
FROM '/var/opt/mssql/popDataSource/population-and-demography.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    TABLOCK
);

SELECT * FROM pop.population_demo