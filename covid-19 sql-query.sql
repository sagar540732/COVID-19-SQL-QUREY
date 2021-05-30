select * 
from [portfolio project]..coviddeath
order by 3,4

--select * 
--from [portfolio project]..covidvaccination
--order by 3,4
--select data that we are going to be using 
select 
location,
date,
total_cases,
new_cases,
total_deaths,
population
from [dbo].[coviddeath]
order by 1,2

--looking at total cases vs total deaths 
--shows likehood of dying if you contract covid in Nepal
select 
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as deathpercentage
from [dbo].[coviddeath]
where location like '%Nepal%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select 
location,
date,
population,
total_cases,
total_deaths,
(total_cases/population)*100 as deathpercentage
from [dbo].[coviddeath]
--where location like '%Nepal%'
order by 1,2

--looking at counry with highest infection rate compare to population 
select 
location,
population,
max(total_cases) as HighestInfectioncount,
max(total_cases/population)*100 as percentagepopulationinfectd
from [dbo].[coviddeath]
--where location like '%Nepal%'
group by population,location
order by percentagepopulationinfectd desc

--country with higest death count per population 
select 
location,
max(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[coviddeath]
--where location like '%Nepal%'
group by location
order by Totaldeathcount desc


--lets break things down by continnent 
select 
location,
max(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[coviddeath]
--where location like '%Nepal%'
where continent is  not null 
group by location
order by Totaldeathcount desc

--showing continents with higest death count per population 
select 
continent,
max(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[coviddeath]
--where location like '%Nepal%'
where continent is  not null 
group by continent
order by Totaldeathcount desc

--GLobal number  
select 
sum(new_cases) as totalcases,
sum(cast(new_deaths as int)) as totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [dbo].[coviddeath]
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

with popvsVac(continent,location,Date,Population,New_vaccinations,Rollingpeoplevaccinated)
as 
(
select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from [dbo].[coviddeath ]  dea 
join
[dbo].[covidvaccination]  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *,(Rollingpeoplevaccinated/Population)*100
from popvsVac

--temp table 
drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from [dbo].[coviddeath ]  dea 
join
[dbo].[covidvaccination]  vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[coviddeath ] dea
Join [dbo].[covidvaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
