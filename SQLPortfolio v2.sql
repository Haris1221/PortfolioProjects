select * 
from PortfolioProject..covidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--total cases vs total deaths


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%sudan%'
order by 1,2


--total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as Percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rates

select location,population, Max(total_cases) AS highestinfectionrate, Max((total_cases/population))*100 as Percentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by population,location
order by Percentage desc


--how many people died

select location, Max(cast(total_deaths as bigint)) as highestdeathrates
from PortfolioProject..CovidDeaths
where continent is null
--where location like '%states%'
--where location like '%sudan%
group by location
order by highestdeathrates desc

--Breaking it down by continents

select continent, Max(cast(total_deaths as bigint)) as highestdeathrates
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
--where location like '%sudan%'
group by continent
order by highestdeathrates desc


select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%sudan%'
--group by date
order by 1 

select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%sudan%'
group by date
order by 1 

--total population vs total vaccination

select dea.continent,dea.location,dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea	
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3
 

 --using a CTE
 with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as 
 (
 select dea.continent,dea.location,dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea	
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopVsVac 


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated 
( 
continent nvarchar(250),
location nvarchar(250),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea	
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated

--creating a view to store data for later vizualizations 

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea	
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3