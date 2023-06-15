SELECT *
FROM CovidDeaths cd 
ORDER BY 3,4


----SELECT *
---FROM CovidVaccinations cv 
--ORDER BY 3,4

--Select Data that we are going to use---

SELECT location,date, total_cases ,new_cases,total_deaths ,population 
FROM CovidDeaths cd 
order BY 1,2

--1.Looking at the total cases vs total deaths---
 --shows the likihood of dying if you come in contact with covid in your country---

SELECT location,date, total_cases ,total_deaths, CAST (total_deaths AS float)/total_cases*100 AS deathPercentage
FROM CovidDeaths cd 
WHERE location LIKE '%states%'
order BY 1,2


--2. Looking at Total Cases vs Population
-- Shows what percentage of population got Covid---
SELECT location,date, population, total_cases ,CAST (total_cases  AS float)/population *100 AS PopulationPercentage
FROM CovidDeaths cd 
WHERE location LIKE '%states%'
order BY 1,2


--Looking at countries with highest infection rate compared to population---
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX( CAST (total_cases  AS float)/population) *100 AS PopulationPercentage
FROM CovidDeaths cd 
GROUP BY location ,population 
order BY 4 DESC 



-- Showing the countries with highest death count per population
SELECT location,  MAX(CAST (total_cases  AS float)) AS TotalDeathCount
FROM CovidDeaths cd 
WHERE continent NOTNULL 
GROUP BY location  
order BY 2 DESC 



--Let's Break things down by continent---


SELECT location  ,  MAX(CAST (total_deaths  AS int)) AS TotalDeathCount
FROM CovidDeaths cd 
WHERE continent NOTNULL 
GROUP BY location 
order BY 2 DESC 



--Showing continents WITH the highest death count per population---

SELECT continent,  MAX(CAST (total_deaths  AS int)) AS TotalDeathCount
FROM CovidDeaths cd 
WHERE continent NOTNULL 
GROUP BY continent 
order BY 2 DESC 


---Global Numbers---
SELECT date ,SUM(new_cases) AS TotalCases,SUM(new_deaths) AS TotalDeaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM CovidDeaths cd 
WHERE continent NOTNULL 
GROUP BY 1
ORDER BY 1,2

--Across the world death percentage

SELECT SUM(new_cases) AS TotalCases,SUM(new_deaths) AS TotalDeaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM CovidDeaths cd 
WHERE continent NOTNULL 
ORDER BY 1,2
--------------------------------------------


--Looking at Total Population vs Vaccinations


SELECT cd.continent, cd.location, cd.date ,cd.population,cv.new_vaccinations  
FROM CovidDeaths cd 
JOIN CovidVaccinations cv ON cd.location = cv.location 
AND cd.date = cv.date 
ORDER BY 2,3
----


SELECT cd.continent, cd.location, cd.date ,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations)  OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv ON cd.location = cv.location 
AND cd.date = cv.date 
ORDER BY 2,3



--use Cte---


WITH PopvsVac  (Continent,Location, Date, Population,New_Vaccinations,RollingPeopleVAccinated)

AS 
(SELECT cd.continent, cd.location, cd.date ,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations)  OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv ON cd.location = cv.location 
AND cd.date = cv.date 

)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac




---creating view to store data for later visualizations-----


---TEMP TABLE

CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datatime,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated numeric
)


INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date ,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations)  OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv ON cd.location = cv.location 
AND cd.date = cv.date 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated





----Creating View to store data for later visualizations


CREATE VIEW PrecentPopulationVaccinated AS 
SELECT cd.continent, cd.location, cd.date ,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations)  OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv ON cd.location = cv.location 
AND cd.date = cv.date 
WHERE cd.continent NOTNULL 