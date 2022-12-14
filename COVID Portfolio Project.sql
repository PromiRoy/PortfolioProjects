Select distinct continent
From CovidDeaths


 

Select *
From CovidDeaths
where continent is not null
order by 3,4

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%states%' AND continent is not null 
order by 1,2


--Looking at Total Cases vs Population
Select Location, date, population,total_cases,  (total_cases/population)*100 as PersonPopulationInfected
From ProjectPortfolio..CovidDeaths
where continent is not null
--Where location like '%states%' and date='2020-06-23 00:00:00.000'
order by 1,2 

----Looking at Countries with Highest Infection Rate compared to Population
Select Location, population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)*100) as PersonPopulationInfected
From ProjectPortfolio..CovidDeaths
where continent is not null
--Where location like '%states%' and date='2020-06-23 00:00:00.000'
group by Location, population
order by PersonPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
--Where location like '%states%' and date='2020-06-23 00:00:00.000'
group by Location
order by TotalDeathCount desc


--Let's break things down by continent
--Showing Continent with highest Death Count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
--Where location like '%states%' and date='2020-06-23 00:00:00.000'
group by continent
order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where continent is not null 
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where continent is not null 
order by 1,2

--Looking at Total Population vs Vaccinations
--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join  ProjectPortfolio..CovidVaccinations vac
      on dea.location=vac.location
	  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 PercentageRollingPeopleVaccinated
From  PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join  ProjectPortfolio..CovidVaccinations vac
      on dea.location=vac.location
	  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 PercentageRollingPeopleVaccinated
From  #PercentPopulationVaccinated


-- Create View to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join  ProjectPortfolio..CovidVaccinations vac
      on dea.location=vac.location
	  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
 from PercentPopulationVaccinated