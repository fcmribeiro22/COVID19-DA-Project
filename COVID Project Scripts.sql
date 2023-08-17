SELECT *
FROM CovidProject.dbo.CovidDeaths
order by 3,4

--Select Data 

SELECT 
	location,date,total_cases,new_cases, total_deaths,population
FROM
	CovidProject..CovidDeaths
ORDER BY
	1,2 

--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract Covid in your Country

SELECT 
	location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM
	CovidProject..CovidDeaths
WHERE 
	location = 'Portugal'
ORDER BY
	1,2 


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT 
	location,date,population,total_cases,  (total_cases/population)*100 as PercentPopCovid
FROM
	CovidProject..CovidDeaths
--WHERE 
--	location = 'Portugal'
ORDER BY
	1,2 


--Looking at countries with highest infection rate compared to population

SELECT 
	location,population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationINfected
FROM
	CovidProject..CovidDeaths
--WHERE 
--	location = 'Portugal'

GROUP BY 
	location,population
ORDER BY
	PercentPopulationINfected DESC


--Showing the Countries with Highest Death Count per population

SELECT 
	location, MAX(cast(total_deaths as Int)) as TotalDeathCount
FROM
	CovidProject..CovidDeaths
--WHERE 
--	location = 'Portugal'
WHERE
	continent is not null
GROUP BY 
	location
ORDER BY
	TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with highest death count by population

SELECT 
	continent, MAX(cast(total_deaths as Int)) as TotalDeathCount
FROM
	CovidProject..CovidDeaths
--WHERE 
--	location = 'Portugal'
WHERE
	continent is not null
GROUP BY 
	continent
ORDER BY
	TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT 
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases) *100 as DeathPercentage
FROM
	CovidProject..CovidDeaths
--WHERE 
--	location = 'Portugal'
WHERE
	continent is not null
--GROUP BY
--	date
ORDER BY
	1,2 

--Looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
	CovidProject..CovidDeaths dea
JOIN
	CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null 
ORDER BY
	2,3



-- Using CTE to perform Calculation on Partition By 

WITH
	PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM
	CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null 
)

SELECT
	*, (RollingPeopleVaccinated/Population)*100
FROM
	PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM
	CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


SELECT
	*, (RollingPeopleVaccinated/Population)*100
FROM
	#PercentPopulationVaccinated


--CREATE VIEW to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM
	CovidProject..CovidDeaths dea
	JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null