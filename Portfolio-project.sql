
SELECT * 
FROM PortfolioProject.dbo.CovidDeath
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccination
--ORDER BY 3,4


--SELECT DATA THAT WERE ARE GOING TO BE USING

SELECT continent, location,  date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeath
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs  Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT continent,location,  date, total_cases, total_deaths, CAST(total_deaths AS float) / CAST(total_cases AS float)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeath
WHERE location = 'Canada'
AND continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT continent,location,  date, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeath
WHERE location = 'Canada'
AND continent is not null
ORDER BY 1,2

--Looking at Countries with higest infection Rate compared to population
SELECT continent,location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeath
--WHERE location = 'Canada'
WHERE continent is not null
GROUP BY continent, population, location
ORDER BY PercentPopulationInfected desc

--Showing country with Highest Death Count per Population
SELECT continent,location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeath
--WHERE location = 'Canada'
WHERE continent is not null
GROUP BY continent,location, population
ORDER BY TotalDeathCount desc

--Let's break thigns down by continent

--Showing continent with the higests death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeath
--WHERE location = 'Canada'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Looking at Total Population vs vaccinations

SELECT Dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float)) OVER (Partition BY dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

With PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT Dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float)) OVER (Partition BY dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP table
DROP TABLE if exists  #PercentPopulationvaccinated
CREATE TABLE #PercentPopulationvaccinated
(continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


INSERT INTO #PercentPopulationvaccinated
SELECT Dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float)) OVER (Partition BY dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationvaccinated


--creating view to store data for later visulization
CREATE VIEW PercentPopulationvaccinated as 
SELECT Dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float)) OVER (Partition BY dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeath dea
JOIN PortfolioProject.dbo.CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationvaccinated