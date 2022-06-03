SELECT * 
FROM Covid19DB..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM Covid19DB..CovidVaccinations
--ORDER BY 3,4

-- Select Data That we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid19DB..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

-- Show likelihood of dying if you contract convid-19 in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid19DB..CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population

-- Shows what percentage of population got Covid-19
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS PercentPopulationInfected
FROM Covid19DB..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to population.
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM Covid19DB..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with highest death count per population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Covid19DB..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent

-- Showing the continent with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Covid19DB..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Let's breaking the global number
SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Covid19DB..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Poppulation vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.Population
, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.Population)*100 AS VaccinatedPercentage
FROM Covid19DB..CovidDeaths dea
JOIN Covid19DB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.Population)*100 AS VaccinatedPercentage
FROM Covid19DB..CovidDeaths dea
JOIN Covid19DB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Coontinent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.Population)*100 AS VaccinatedPercentage
FROM Covid19DB..CovidDeaths dea
JOIN Covid19DB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations
--DROP VIEW PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.Population)*100 AS VaccinatedPercentage
FROM Covid19DB..CovidDeaths dea
JOIN Covid19DB..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

-- SELECT FROM VIEW WE"VE CREATED
SELECT *
FROM PercentPopulationVaccinated
