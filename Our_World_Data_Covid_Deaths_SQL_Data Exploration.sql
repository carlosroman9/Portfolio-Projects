SELECT *

FROM [Portfolio Project]..CovidDeaths

ORDER BY 3, 4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population

FROM [Portfolio Project]..CovidDeaths

ORDER by 1,2


-- Looking at Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract covid in your country


SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS percentage_of_deaths

FROM [Portfolio Project]..CovidDeaths

WHERE location LIKE '%states%'

ORDER by 1,2



-- Looking at Total Cases vs Population

--Shows what percentage of population got covid


SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_of_positive_cases

FROM [Portfolio Project]..CovidDeaths

WHERE location LIKE '%states%'

ORDER by 1,2

-- Looking at countries with highest infection rates compared to population

SELECT location, MAX(total_cases) AS largest_case, population, MAX((total_cases/population))*100 AS percentage_of_positive_cases

FROM [Portfolio Project]..CovidDeaths

GROUP BY location, population

ORDER BY percentage_of_positive_cases DESC


--Looking at countries with most deaths compared to the population

SELECT location, MAX(cast(total_deaths as int)) AS largest_deaths, population, MAX((total_deaths/population))*100 AS percentage_of_deaths

FROM [Portfolio Project]..CovidDeaths

WHERE continent is not null

GROUP BY location, population

ORDER BY largest_deaths DESC

--Looking at the continents and largest deaths


SELECT location, MAX(cast(total_deaths as int)) AS largest_deaths

FROM [Portfolio Project]..CovidDeaths

WHERE continent is null

GROUP BY location

ORDER BY largest_deaths DESC


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS largest_deaths

FROM [Portfolio Project]..CovidDeaths

WHERE continent is not null

GROUP BY continent

ORDER BY largest_deaths DESC


-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS global_death_rate

FROM [Portfolio Project]..CovidDeaths

WHERE continent is not null

--WHERE location like '%states'

GROUP BY date

ORDER BY 1, 2



SELECT continent, MAX(cast(people_fully_vaccinated as int)) AS total_vaccinations

FROM [Portfolio Project]..[Covid Vaccinations]

GROUP BY continent



-- Total Vaccination vs Total Population

-- USE CTE

With PopvsVac (continent, date, location, population, new_vaccinations, rolling_people_vaccinated)
AS



--TEMP TABLE2
DROP TABLE IF exists percentpopulationvaccinated


CREATE TABLE percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric

)





INSERT INTO percentpopulationvaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER by cd.location, cd.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)
FROM [Portfolio Project]..CovidDeaths AS cd

JOIN [Portfolio Project]..[Covid Vaccinations] AS cv ON cd.location = cv.location
AND cd.date = cv.date

WHERE cd.continent is not null

--ORDER by 2,3

SELECT *, (rolling_people_vaccinated/population)*100 AS percent_change

FROM percentpopulationvaccinated


--Creating View to store data in visualizations later


DROP VIEW if exists pct_pop_vax

CREATE VIEW pct_pop_vax AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER by cd.location, cd.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)
FROM [Portfolio Project]..CovidDeaths AS cd

JOIN [Portfolio Project]..[Covid Vaccinations] AS cv ON cd.location = cv.location
AND cd.date = cv.date

WHERE cd.continent is not null

--ORDER by 2,3