SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE continent is not null
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Total cases vs total deaths 
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Total cases vs population
-- Shows what population got Covid
SELECT Location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Countries with the highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Break things down by continent
-- Continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global numbers
-- accross the world 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))
/SUM(New_Cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date

-- Total pop vs vaccinations
-- Shows percentage of pop that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query
-- Make sure collumns in with is the same as collumns in SELECT or else it will give an error
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating Views to store data for visualization later
-- Order by's don't work when creating views 

-- 1.

CREATE VIEW globalNumbers as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 

-- 2. 

CREATE VIEW TotalDeathsPerContinent as 
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
Group by location


-- 3.  

create view PercentPopInfectedPerCountry as
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by Location, Population


-- 4. 

create view PercentPopulationInfected as
SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by Location, Population, date


-- 5
-- same as global numbers but for the states

CREATE VIEW USNumbers as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'


-- 6

create view InfectionRateUS as
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'





