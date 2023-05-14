/*

Queries used for Tableau Project

*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null and location not like '%income%' 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.
-- replace null values with 0

With TempInfection(location, population, highestInfectionCount, percentPopulationInfected)
as
(
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases * 1.0 /population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
--order by PercentPopulationInfected desc
)
Select location, population, ISNULL(highestInfectionCount, 0) as HighestInfectionCount, ISNULL(percentPopulationInfected, 0) as PercentPopulationInfected
From TempInfection 
order by PercentPopulationInfected desc


-- 4.

With TempPopInfection(location, population, date, highestInfectionCount, percentPopulationInfected)
as
(
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases *1.0 / population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
-- order by PercentPopulationInfected desc
)
Select location, population, date, ISNULL(highestInfectionCount, 0) as HighestInfectionCount, ISNULL(percentPopulationInfected, 0) as PercentPopulationInfected
From TempPopInfection 
order by PercentPopulationInfected desc