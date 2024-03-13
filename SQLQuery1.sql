select * 
from CovidDeaths$
order by 3,4

select *
from CovidVaccionations$
order by 3,4

--select the data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2


--looking at total_cases vs total_deaths
shows the likelyhood dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths$
where location like '%brazil%'
order by 5 desc


--looking at total_cases vs population
show what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as contratactper
from CovidDeaths$
where location like '%brazil%'
order by 5 desc

select location, max(total_cases), population, max((total_cases/population))*100 as contratactper
from CovidDeaths$
group by location, population
order by 4 desc

--showing countries with highest death count  per population

select location, max(cast(total_deaths as int))
from CovidDeaths$
where continent is not null 
group by location
order by 2 desc


--let's break down things by continent
select location, max(cast(total_deaths as int))
from CovidDeaths$
where continent is null 
group by location
order by 2 desc


--daily global numbers

select date, sum(new_cases) newcases, sum(cast(new_deaths as int)) newdeaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as 
death_percentage
from coviddeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) newcases, sum(cast(new_deaths as int)) newdeaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as 
death_percentage
from coviddeaths$
where continent is not null
order by 1,2

--looking at total population vs vaccionations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths$ dea
join CovidVaccionations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/dea.population) * 100
from CovidDeaths$ dea
join CovidVaccionations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte
with PopvsVac(continent, location, date, population, RollingPeopleVaccinated, new_vaccionations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/dea.population) * 100
from CovidDeaths$ dea
join CovidVaccionations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3)
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--use temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/dea.population) * 100
from CovidDeaths$ dea
join CovidVaccionations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated


--creating view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/dea.population) * 100
from CovidDeaths$ dea
join CovidVaccionations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated