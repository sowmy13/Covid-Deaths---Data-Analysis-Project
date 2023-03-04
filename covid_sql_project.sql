
select * from [PortfolioProject-Coviddeaths]..CovidDeaths
where continent is not null

--- Select data for the project

Select location, date, total_cases, new_deaths, total_deaths, population
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
order by 1, 2

-- Looking at total cases vs total deaths.
--shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as Deathpercentage
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
where location ='India'
order by 1, 2

--shows the likelihood of dying if you contract covid in United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as PercentPopulationInfected
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
where location like '%states%'
order by 1, 2

-- Looking at total cases vs Population.
-- showing what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100  as PercentPopulationInfected
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
--where location like '%states%'
order by 1, 2

--Looking at countries with Highest Infection Rate compared to Population

Select location, population, max(total_cases) as HighestInfectionRate, max (total_cases/population)*100  as PercentPopulationInfected
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

 -- Showing the countries with the Highest Death count per Population 
Select location, population,continent, max(cast(total_deaths as int)) as TotalDeathcount
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
where continent is not null
group by location, population, continent
order by TotalDeathcount desc

--and breaking things by continent
Select continent, max(cast(total_deaths as int)) as TotalDeathcount
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathcount desc

--- showing continets with highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathcount
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathcount desc

---Total new cases & death percent per day
Select  date, sum(new_cases) as Total_cases, sum(cast(new_deaths as integer)) as total_deaths, 
(sum(cast(new_deaths as integer))/sum(new_cases))*100  as DeathPercentage
FROM [PortfolioProject-Coviddeaths]..CovidDeaths
where continent is not null
group by date
order by 1, 2


-- Use CTE
With PopvsVac (Continet, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeoplVaccinated
from [PortfolioProject-Coviddeaths]..CovidDeaths dea
Join [PortfolioProject-Coviddeaths]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select *, (RollingPeopleVaccinated/Population) *100  
	from 
	PopvsVac;

--TEMP TABLE
Drop table if exists #PercentpopulationVaccinated
Create table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacciations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentpopulationVaccinated
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeoplVaccinated
from [PortfolioProject-Coviddeaths]..CovidDeaths dea
Join [PortfolioProject-Coviddeaths]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	Select *, (RollingPeopleVaccinated/Population) *100  
	from 
	#PercentpopulationVaccinated;

-- Creating Views to store data for visualizations
USE [PortfolioProject-Coviddeaths]

--drop view PercentpopulationVaccinated

Create View PercentpopulationVaccinated as
(Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeoplVaccinated
from [PortfolioProject-Coviddeaths]..CovidDeaths dea
Join [PortfolioProject-Coviddeaths]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null )
	--order by 2,3
---------------------------------------------------------------------
Select *
	from 
	PercentpopulationVaccinated;
----------------------------------------------------------------------