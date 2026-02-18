-- Exploring our data
SELECT * FROM pop.population_demo


-- Checking the year span of the data
SELECT
    MIN(population_year),
    MAX(population_year)
FROM pop.population_demo;


-- Checking the number of countries we have 
SELECT
    country_name,
    COUNT(*)
FROM pop.population_demo
GROUP BY country_name
ORDER BY country_name ASC;


-- Filtering Geographical region 
SELECT
    DISTINCT country_name
FROM pop.population_demo
WHERE country_name LIKE '%(UN)%';


--Creating new clumn to distinct between continecnt and country 
ALTER TABLE pop.population_demo ADD record_type VARCHAR(100);

UPDATE pop.population_demo
SET record_type = 'Continent'
WHERE country_name LIKE '%(UN)%';


-- Futher exploration to filter datas that are not countries 
SELECT
    DISTINCT country_name
FROM pop.population_demo
WHERE record_type IS NULL;

UPDATE pop.population_demo
SET record_type = 'Category'
WHERE country_name IN (
    'High-income countries',
    'Land-locked developing countries (LLDC)',
    'Least developed countries',
    'Less developed regions',
    '"Less developed regions- excluding China"',
    '"Less developed regions- excluding least developed countries"',
    'Low-income countries',
    'Lower-middle-income countries',
    'More developed regions',
    'Small island developing states (SIDS)',
    'Upper-middle-income countries',
    'World'
);

UPDATE pop.population_demo
SET record_type = 'Country'
WHERE record_type IS NULL;


-- What is the population of people aged 90 and above for each country in the latest year?
SELECT 
    country_name,
    population_year,
    population_90_to_99 + population_100_above AS pop_90_above
FROM pop.population_demo
WHERE population_year = 2021 AND record_type = 'Country'
ORDER BY country_name ASC;


-- Which countries have the highest population growth in the last year?
SELECT
    country_name,
    population_2020,
    population_2021,
    population_2021 - population_2020 AS pop_growth_num,
    CONCAT(ROUND(CAST((population_2021 - population_2020) AS FLOAT)/ population_2020 * 100, 2), '%') AS pop_growth_pct
FROM(
SELECT
    p.country_name,
    (SELECT
        p1.population_total
    FROM pop.population_demo AS p1
    WHERE p1.country_name = p.country_name
    AND population_year = 2020) AS population_2020,
    (SELECT
        p2.population_total
    FROM pop.population_demo AS p2
    WHERE p2.country_name = p.country_name
    AND population_year = 2021) AS population_2021
    FROM pop.population_demo AS p 
    WHERE p.record_type = 'Country' AND population_year = 2021) AS s
    ORDER BY pop_growth_num DESC


-- Which single country has the highest population decline in the last year 
SELECT TOP 1
    country_name,
    population_2020,
    population_2021,
    population_2021 - population_2020 AS pop_growth_num,
    CONCAT(ROUND(CAST((population_2021 - population_2020) AS FLOAT)/ population_2020 * 100, 2), '%') AS pop_growth_pct
FROM(
SELECT
    p.country_name,
    (SELECT
        p1.population_total
    FROM pop.population_demo AS p1
    WHERE p1.country_name = p.country_name
    AND population_year = 2020) AS population_2020,
    (SELECT
        p2.population_total
    FROM pop.population_demo AS p2
    WHERE p2.country_name = p.country_name
    AND population_year = 2021) AS population_2021
    FROM pop.population_demo AS p 
    WHERE p.record_type = 'Country' AND population_year = 2021) AS s
    ORDER BY pop_growth_num ASC;


-- Which age group had the highest population out of all countries last year?
SELECT 
    v.age_group,
    v.pop_  
FROM pop.population_demo p
CROSS APPLY (
    VALUES 
        ('population_1_to_9', population_1_to_4 + population_5_to_9),
        ('population_10_to_19', population_10_to_14 + population_15_to_19),
        ('population_20_to_29', population_20_to_29),
        ('population_30_to_39', population_30_to_39),
        ('population_40_to_49', population_40_to_49),
        ('population_50_to_59', population_50_to_59),
        ('population_60_to_69', population_60_to_69),
        ('population_70_to_79', population_70_to_79),
        ('population_80_to_89', population_80_to_89),
        ('population_90_to_99', population_90_to_99),
        ('population_100_above', population_100_above)
) AS v(age_group, pop_)
WHERE country_name = 'WORLD' 
AND population_year = 2021
ORDER BY pop_ DESC;

-- What are the top 10 countries with the highest  population growth in the last 10 years?
SELECT TOP 10
    country_name,
    population_2011,
    population_2021,
    population_2021 - population_2011 AS pop_growth_num
FROM(
SELECT
    p.country_name,
    (SELECT
        p1.population_total
    FROM pop.population_demo AS p1
    WHERE p1.country_name = p.country_name
    AND population_year = 2011) AS population_2011,
    (SELECT
        p2.population_total
    FROM pop.population_demo AS p2
    WHERE p2.country_name = p.country_name
    AND population_year = 2021) AS population_2021
    FROM pop.population_demo AS p 
    WHERE p.record_type = 'Country' AND population_year = 2021) AS s
    ORDER BY pop_growth_num DESC

-- Which country has the highest percentage growth since the first year recorded?
SELECT
    country_name,
    population_1950,
    population_2021,
    ROUND(CAST((population_2021 - population_1950) AS FLOAT)/ population_1950 * 100, 2) AS pop_growth_pct
 FROM(
        SELECT
            p.country_name,
            (SELECT
                p1.population_total
            FROM pop.population_demo AS p1
            WHERE p1.country_name = p.country_name
            AND population_year = 1950) AS population_1950,
            (SELECT
                p2.population_total
            FROM pop.population_demo AS p2
            WHERE p2.country_name = p.country_name
            AND population_year = 2021) AS population_2021
            FROM pop.population_demo AS p 
            WHERE p.record_type = 'Country' AND population_year = 2021) AS s
            ORDER BY pop_growth_pct DESC;



-- Which country has the highest population aged 1 as a percentage of their overall population?
SELECT
    country_name,
    population_total,
    population_at_1,
    ROUND(CAST(population_at_1 AS FLOAT)/population_total * 100, 2) AS pop_ratio
 FROM pop.population_demo
 WHERE record_type = 'country'
 AND population_year = 2021
 ORDER BY pop_ratio DESC;


-- What is the popuation of each continent in each year and how much in each year?
SELECT
    country_name AS continent_,
    population_year,
    population_total,
    COALESCE(population_total - pop_prior, 0) AS pop_change,
    CONCAT(COALESCE(ROUND(CAST((population_total - pop_prior) AS FLOAT)/pop_prior * 100, 2), 0), '%') AS pop_pct_growth
 FROM (
    SELECT
        country_name,
        population_year,
        population_total,
        LAG(population_total, 1) OVER(PARTITION BY country_name ORDER BY population_year ASC) as pop_prior
    FROM pop.population_demo
    WHERE record_type = 'Continent'
 ) AS t
  ORDER BY continent_ ASC, population_year ASC


