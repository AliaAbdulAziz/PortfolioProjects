-- Looking at CovidDeaths table

Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select *
-- From PortfolioProject..CovidVaccinations
-- order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Malaysia or Singapore

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
where (location like '%Malaysia%') OR (location like '%Singapore%')
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
where (location like '%Malaysia%') OR (location like '%Singapore%')
order by 1,2

-- Looking at Countries with HHighest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount, population, MAX((total_deaths/population))*100 as PercentPopulationDied
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
order by PercentPopulationDied desc

-- CONTINENT NUMBERS

-- Showing continents with the highest death count per population

select continent, SUM(new_deaths) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2

-- Looking at CovidVaccinations table

Select *
From CovidVaccinations

-- Joining CovidDeaths and CovidVaccinations tables

Select *
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE Common Table Expressions (CTE)

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac
order by 2,3

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated
order by 2,3

-- Creating View to store data for later visualisations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccinated