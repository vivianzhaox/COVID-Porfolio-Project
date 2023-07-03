SELECT *
From PortfolioProject..CovidDeaths
--Where continent is not null
Order by 3,4


Select *
From PortfolioProject..CovidVaccinations
Order by 3,4,5

-- Looking at total cases vs total deaths 
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at the total cases vs population
-- Shows what population got Covid
Select Location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at countries with the highest infection rate compared to population
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc

-- Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- break things down by continent
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc


-- show the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers
--accross the world 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))
/SUM(New_Cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

SELECT *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date

-- looking at total pop vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea,location, dea.date) --runs only in one country and so it doesnt keep going and going
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3
