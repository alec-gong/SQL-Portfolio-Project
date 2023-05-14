-- Select Data
Select *
From PortfolioProject..CovidDeaths
order by 1,2

-- Troubleshoot why DeathPercentage returns 0
USE PortfolioProject;  
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths';


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if contracting covid in a particular country

Select Location, date, total_cases, total_deaths, (total_deaths*1.0 / total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Total Cases vs Population
-- Shows infection rate

Select Location, date, total_cases, population, (total_cases*1.0 / population) * 100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, MAX(total_cases) as highestInfectionCount, population, MAX((total_cases*1.0 / population)) * 100 as percentagePopulationInfected
From PortfolioProject..CovidDeaths
group by population, location
order by percentagePopulationInfected desc


-- Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as totalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by totalDeathCount desc

-- Break down by continent
Select location, MAX(total_deaths) as totalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null and location not like '%income%' and location != 'World' and location not like '%union%'
group by location
order by totalDeathCount desc

-- Global Numbers
Select date, SUM(new_cases) as totalCases, SUM(new_deaths) as totalDeaths, (SUM(new_deaths) / Nullif (SUM(new_cases), 0)) * 100 as deathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by date
Order by 1, 2


-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as rollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null 
order by 2, 3

-- Use CTE

With PopvsVac (Continent, Location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as rollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null 
)
Select *, (CAST(rollingPeopleVaccinated as float) / population)*100
From PopvsVac


-- Temp Table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as rollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null 
Select *, (CAST(rollingPeopleVaccinated as float) / population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as rollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null 