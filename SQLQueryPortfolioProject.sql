-- Checking the tables to see if they transferred to the SQL Server correctly.

Select *
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject1.dbo.CovidVaccinations AS vaccinations
ORDER BY 3,4

-- Here, I am taking out irrelevant information (for now) and also changing the 
-- order of the data to make the table easier to read.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
ORDER BY 1,2

---- Total Cases vs. Total Deaths

-- This shows us a very good glimpse at the death percentage of total cases 
-- and how the lockout was necessary since the percentages we at an all time high.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
WHERE location = 'United States'
ORDER BY 1,2

-- Here, we're looking at the total cases vs. the population to see the percentage of population that has had covid.

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS CasePercentage
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
WHERE location = 'United States'
ORDER BY 1,2

-- Which Countries have the highest infection rates? Let's Find Out...

-- NOTE: This doesn't really show the exact percentage since a person is able to contract COVID-19 multiple times, however
-- we will write the code as a learning exercise.

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY 4 DESC

-- Which Countries have the highest death number? Lets find out

SELECT location, MAX(total_deaths) As MaxDeathCount
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
WHERE continent is not null -- This line makes sure that we are only looking at the data by country and not continent.
GROUP BY location
ORDER BY 2 DESC

-- Now, let us find out the highest death count by continent.

SELECT population, location, MAX(total_deaths) As MaxDeathCount
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
WHERE continent is null -- This line makes sure that we are only looking at the data by country and not continent.
GROUP BY location, population -- This groups up the data by continent, making it easier to see which continent contains the country that has the highest death count.
ORDER BY 2 DESC

-- Now, we are going to look at death rates based on income to see any interesting trends.

SELECT population, location, MAX(total_deaths) As MaxDeathCount, MAX(total_deaths/population)*100 AS IncomePercentDeath
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location like '%income%'
GROUP BY location, population
ORDER BY 3 DESC

-- Lets take a look at COVID case over time globally.

SELECT date, SUM(new_cases) as sumnewcases, SUM(new_deaths) as sumnewdeaths
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Death percentage of the entire world currently.

SELECT SUM(new_cases) as sumnewcases, SUM(new_deaths) as sumnewdeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Lets Join the death and vaccination data for further analysis.

SELECT *
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
Join PortfolioProject1.dbo.CovidVaccinations AS vaccinations
	ON deaths.location = vaccinations.location AND deaths.date = vaccinations.date

-- Now, lets make a table that adds up new cases to each country (Pretty cool if you ask me!)

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	addedvaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(cast(vaccinations.new_vaccinations AS bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS AddedVaccinations
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
Join PortfolioProject1.dbo.CovidVaccinations AS vaccinations
	ON deaths.location = vaccinations.location AND deaths.date = vaccinations.date
WHERE deaths.continent is not null
ORDER by 2,3

SELECT *, (AddedVaccinations/population)*100
FROM #PercentPopulationVaccinated


--WITH PopulationVSVaccination (continent, location, date, population, new_vaccinations, AddedVaccinations)
--AS
--(
--SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
--, SUM(cast(vaccinations.new_vaccinations AS bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS AddedVaccinations
--FROM PortfolioProject1.dbo.CovidDeaths AS deaths
--Join PortfolioProject1.dbo.CovidVaccinations AS vaccinations
--	ON deaths.location = vaccinations.location AND deaths.date = vaccinations.date
--WHERE deaths.continent is not null
----ORDER by 2,3
--)
--SELECT *, (AddedVaccinations/population)*100
--FROM PopulationVSVaccination

-- Creating View to store data for visualizations.

DROP VIEW if exists IncomeDeathRates
CREATE VIEW IncomeDeathRates as 
SELECT population, location, MAX(total_deaths) As MaxDeathCount, MAX(total_deaths/SUM(population))*100 AS IncomePercentDeath
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location like '%income%'
GROUP BY location, population

CREATE VIEW IncomeRollingRates AS
SELECT deaths.location, deaths.date, deaths.population, new_deaths
, SUM(cast(deaths.new_deaths AS bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS AddedVaccinations
FROM PortfolioProject1.dbo.CovidDeaths AS deaths
WHERE location like '%income%'
--ORDER BY 1,2

