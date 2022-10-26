select *
From [Covid Project]..CovidDeaths
order by 3,4

select distinct(location), continent
from CovidDeaths
where continent is not null


--select *
--From [Covid Project]..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths, population
from [Covid Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Death count 

select location,date,total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as death_rate
from [Covid Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Death count 

select location,date,total_cases,population, (total_cases/population)*100 as suffered_percent_population
from [Covid Project]..CovidDeaths
where continent is not null
order by 1,2

-- Countries with highet infection rate vs population

select location, max(total_cases) as highest_infection ,population, max((total_cases/population))*100 as suffered_percent_total
from [Covid Project]..CovidDeaths
where continent is not null
group by location, population
order by suffered_percent_total Desc

--Highest death count per population

select location, max(cast(total_deaths as int)) as total_deaths_continent
from [Covid Project]..CovidDeaths
where continent is not null 
group by location, population
order by  total_deaths_continent Desc

--Breaking things down by continent


--Continents with higgest death counts

select continent, max(cast(total_deaths as int)) as total_deaths_continent
from [Covid Project]..CovidDeaths
where continent is not null
group by continent
order by  total_deaths_continent Desc

--Global numbers

select sum(new_cases) as totalcases, sum(cast (new_deaths as int)) as totalDeaths,
(sum(cast (new_deaths as int))/sum(new_cases))* 100 as Deathpercent
from [Covid Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2


select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVac
from [Covid Project]..CovidDeaths dea
join [Covid Project].. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

with popvsvac (continent,location,date,population,newVacination,RollingTotalVac)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVac
from [Covid Project]..CovidDeaths dea
join [Covid Project].. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingTotalVac/population) *100 as percentVaccine
from popvsvac

--Temp table

drop table if exists RollingTotalVac
Create table RollingTotalVac
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
New_Vaccine numeric,
RollingTotalVac numeric
)

insert into RollingTotalVac
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVac
from [Covid Project]..CovidDeaths dea
join [Covid Project].. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingTotalVac/population) *100 as percentVaccine
from RollingTotalVac

--View

Create view Rollingtotal as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVac
from [Covid Project]..CovidDeaths dea
join [Covid Project].. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3