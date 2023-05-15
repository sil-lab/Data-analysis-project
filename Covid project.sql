select *
from Portfolioproject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from Portfolioproject..CovidVaccination$
--order by 3,4

--Select data that i am going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths$
where location like '%nigeria%'
 and continent is not null
order by 1,2
 
-- looking at total cases vs population
--show what percentage of population got covid
select Location, date, total_cases,population, (total_cases/population)*100 as PercentPolpulationInfected
from Portfolioproject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPolpulationInfected
from Portfolioproject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by location, population
order by PercentPolpulationInfected desc

select Location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPolpulationInfected
from Portfolioproject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by location, population, date
order by PercentPolpulationInfected desc

-- showing countries with highest death count per population
select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
from Portfolioproject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by location
order by HighestDeathCount desc

--Breaking things down by continents
select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from Portfolioproject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by continent
order by HighestDeathCount desc

--showing continents with highest death count per population
select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from Portfolioproject..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
Group by continent
order by HighestDeathCount desc

--Global Numbers
select sum(new_cases)as TotalCases,sum(cast(new_deaths as bigint)) as TotalDeaths, (sum(new_cases)/sum(cast(new_deaths as bigint)))*100 as GlobalDeathPercentage
from Portfolioproject..CovidDeaths$
--where location like '%nigeria%'
 where continent is not null
 --group by date
order by 1,2

--Looking at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVacc
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE
with PopvsVac (Continent, Location, Date, Poplatiion, New_vaccinations, RollingPeopleVacc
) as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVacc
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVacc/Poplatiion)*100 as RollingPeoplePercent
from PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVacc numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVacc
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVacc/Population)*100 as RollingPeoplePercent
from #PercentPopulationVaccinated


--creating view to store data for visualizations
Create view PercentPopulationVacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVacc
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVacc

select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc