CREATE TABLE deaths (
iso_code VARCHAR(10),
continent VARCHAR(15),
location VARCHAR(50),
record_date VARCHAR(20),
total_cases INT ,
new_cases INT SIGNED,
new_cases_smoothed DOUBLE SIGNED,
total_deaths INT,
new_deaths INT SIGNED,   
new_deaths_smoothed DOUBLE SIGNED,
total_cases_per_million DOUBLE,
new_cases_per_million DOUBLE SIGNED,
new_cases_smoothed_per_million DOUBLE SIGNED,
total_deaths_per_million DOUBLE,
new_deaths_per_million DOUBLE SIGNED,
new_deaths_smoothed_per_million DOUBLE SIGNED,
reproduction_rate DOUBLE SIGNED,
icu_patients INT,
icu_patients_per_million DOUBLE,
hosp_patients INT,
hosp_patients_per_million DOUBLE,
weekly_icu_admissions DOUBLE,
weekly_icu_admissions_per_million DOUBLE,
weekly_hosp_admissions DOUBLE,
weekly_hosp_admissions_per_million DOUBLE,
new_tests INT SIGNED,
total_tests INT,
total_tests_per_thousand DOUBLE,
new_tests_per_thousand DOUBLE SIGNED,
new_tests_smoothed INT,
new_tests_smoothed_per_thousand DOUBLE,
positive_rate DOUBLE,
tests_per_case DOUBLE,
tests_units VARCHAR(30),
total_vaccinations INT,
people_vaccinated INT,
people_fully_vaccinated INT,
new_vaccinations INT,
new_vaccinations_smoothed INT,
total_vaccinations_per_hundred DOUBLE,
people_vaccinated_per_hundred DOUBLE,
people_fully_vaccinated_per_hundred DOUBLE,
new_vaccinations_smoothed_per_million INT,
stringency_index DOUBLE,
population INT,
population_density DOUBLE,
median_age DOUBLE,
aged_65_older DOUBLE,
aged_70_older DOUBLE,
gdp_per_capita DOUBLE,
extreme_poverty DOUBLE,
cardiovasc_death_rate DOUBLE,
diabetes_prevalence DOUBLE,
female_smokers DOUBLE,
male_smokers DOUBLE,
handwashing_facilities DOUBLE,
hospital_beds_per_thousand DOUBLE,
life_expectancy DOUBLE,
human_development_index DOUBLE
);

LOAD DATA LOCAL INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Deaths.csv" INTO TABLE deaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(iso_code, continent, location, record_date, total_cases, new_cases, new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, hosp_patients,hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions, weekly_hosp_admissions_per_million, new_tests, total_tests, total_tests_per_thousand, new_tests_per_thousand, new_tests_smoothed, new_tests_smoothed_per_thousand, positive_rate, tests_per_case, tests_units, total_vaccinations, people_vaccinated, people_fully_vaccinated, new_vaccinations, new_vaccinations_smoothed, total_vaccinations_per_hundred, people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred, new_vaccinations_smoothed_per_million, stringency_index, population, population_density, median_age, aged_65_older, aged_70_older, gdp_per_capita, extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities,hospital_beds_per_thousand, life_expectancy, human_development_index)
-- set record_date = STR_TO_DATE(record_date,'%m/%d/%Y')
;

UPDATE deaths SET record_date = STR_TO_DATE(record_date, '%m/%d/%Y');

SELECT * FROM covid.deaths;

-- Study on Covid deaths 
----------------------------

-- Inspecting the data we are going to use
SELECT location, record_date, total_cases, new_cases, total_deaths, population
FROM deaths
WHERE continent != ''
ORDER BY 1, 2;

-- Lets see what are the locations available in this data
SELECT DISTINCT location AS DistinctLocations
FROM deaths
ORDER BY 1 ;

-- Filtering out continents listed in locations
SELECT DISTINCT location AS WrongLocations
FROM deaths
WHERE continent = ''
ORDER BY 1 ;

SELECT COUNT(DISTINCT location) AS DistinctLocationsCount
FROM deaths
WHERE continent != '' ;


-- Total cases vs Total Deaths

SELECT location, record_date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM deaths
WHERE continent != ''
ORDER BY 1,2 ;

-- Likelihood of dying if you contract covid in your country
SELECT location, record_date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM deaths
WHERE location like 'India'
AND continent != ''
ORDER BY 5 DESC;

SELECT location, record_date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM deaths
WHERE location like '%United Arab%'
AND continent != ''
ORDER BY 5 DESC;

-- Total cases vs Population
-- What percentage of population got covid
SELECT location, record_date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM  deaths
WHERE location like 'India'
AND  continent != ''
ORDER BY 5 DESC;

-- can I get aggregate of distinct locations with maximum of pupulation infected?
SELECT location, MAX((total_cases/population)*100) AS MaxPercentInfected
FROM deaths
WHERE continent != ''
GROUP BY location
ORDER BY 2 DESC;

SELECT location, record_date, population, total_cases, MAX((total_cases/population)*100) AS MaxPercentInfected
FROM deaths
WHERE continent != ''
-- AND location  LIKE '%States%'
GROUP BY location, record_date, population, total_cases
ORDER BY 5 DESC
;
  
SELECT location, MAX(record_date) AS LatestRecordDate, MAX((total_cases/population)*100) AS MaxPercentInfected
FROM deaths
WHERE continent != ''
GROUP BY location
ORDER BY 3 DESC
; 

-- Tried to filter with JOIN and Subqueries
SELECT deaths.location, total_cases, population, MaxInfectionDetails.MaxPopulationInfected
FROM deaths
LEFT JOIN (
SELECT location, MAX((total_cases/population)*100) AS MaxPopulationInfected
FROM deaths
GROUP BY location
)MaxInfectionDetails
ON MaxInfectionDetails.location = deaths.location
;

-- What country has the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM deaths
WHERE continent != ''
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with highest death count per population
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population)*100) AS PercentPopulationDied
FROM deaths
WHERE continent != ''
GROUP BY location, population
ORDER BY PercentPopulationDied DESC;

-- Continent with highest death count per population
SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM deaths
WHERE continent != ''
GROUP BY continent 
ORDER BY PercentPopulationDied DESC;

-- Shows what percentage of population died because of Covid 19
SELECT location, record_date, total_deaths, population, (total_deaths/population)*100 as DeathPercent
FROM deaths
WHERE continent != ''
AND location = 'India'
ORDER BY 2 DESC, 5 DESC;

-- Likelihood of dying in a country if one contract with covid in one's country. For instance India

SELECT location, record_date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercent
FROM deaths
WHERE continent != ''
AND location = 'India' 
ORDER BY 5 DESC;

-- Likelihood of dying in a country if one contract with covid in one's country. For instance India
-- Especially when the total cases reported is greater than 200000
SELECT location, record_date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercent
FROM deaths
WHERE continent != ''
AND location = 'India'
AND total_cases > 200000
ORDER BY 5 DESC;

-- GLOBAL ANALYSIS

SELECT record_date, SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathRate
FROM deaths
WHERE continent != ''
GROUP BY record_date
ORDER BY record_date DESC
;

-- USE CTE

WITH GlobalDeathPercent (record_date, new_cases, new_deaths, global_death_rate)
AS
(
SELECT record_date, SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathRate
FROM deaths
WHERE continent != ''
GROUP BY record_date
ORDER BY record_date DESC
)
SELECT *
FROM GlobalDeathPercent
;


-- TEMP TABLE
 DROP TEMPORARY TABLE IF EXISTS GlobalDeathPercent ;
CREATE TEMPORARY TABLE GlobalDeathPercent
SELECT record_date, SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS GlobalDeathRate
FROM deaths
WHERE continent != ''
GROUP BY record_date
ORDER BY record_date DESC
;
SELECT *
FROM globaldeathpercent;

