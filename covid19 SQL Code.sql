--covid death
select * from covid_19..CovidDeaths$
where continent is not null
order by 3,4;

--select the data that we want to use
select location,date,total_cases,new_cases,total_deaths 
from covid_19..CovidDeaths$
order by 1,2;

--looking at total cases vs total deaths
--show likelihood of dying if you contract covid in your country  
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage 
from covid_19..CovidDeaths$
where location like 'India'
order by 1,2;

--looking at total cases vs population
--shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as cases_percentage 
from covid_19..CovidDeaths$
--where location like 'India'
order by 1,2;

--looking at countries with highest infection rate compared to population 
 select location,population,max(total_cases) as Highest_infection_count ,max((total_cases/population)*100) as cases_percentage 
from covid_19..CovidDeaths$
group by location,population
order by cases_percentage desc;

--looking at countries with highest death count compared to population 
 select location,population,max(cast(total_deaths as int)) as Highest_death_count ,max((total_deaths/population)*100) as death_percentage 
from covid_19..CovidDeaths$
where continent is not null
group by location,population
order by Highest_death_count desc;

--highest death count continent wise
select continent,max(cast(total_deaths as int)) as Highest_death_count ,max((total_deaths/population)*100) as death_percentage 
from covid_19..CovidDeaths$
where continent is not null
group by continent
order by Highest_death_count desc;

--Global wise 
select SUM(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_death ,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
from covid_19..CovidDeaths$
where continent is not null;

--covid vaccination
select * from covid_19..CovidVaccinations$
order by 3,4

--Looking at Total vaccination vs population
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date)as peopleVaccinated
--(peopleVaccinated/population)*100 cannot use the column which was created recently use cte;
from covid_19..CovidDeaths$ cd 
join covid_19..CovidVaccinations$ as cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3;

--with cte
with my_cte_name(continent,location,date,population,new_vaccination,peopleVaccinated)as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date)as peopleVaccinated
--(peopleVaccinated/population)*100 cannot use the column which was created recently use cte;
from covid_19..CovidDeaths$ cd 
join covid_19..CovidVaccinations$ as cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
--order by 2,3;--cannot use order by clause in cte
)
select *,(peopleVaccinated/population)*100 as vacc_percentage 
from my_cte_name;

--Use Table
create table #PercentPopulationVaccinated(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vacciantions numeric,
peoplevaccinated numeric
)
insert into #PercentPopulationVaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date)as peopleVaccinated
--(peopleVaccinated/population)*100 cannot use the column which was created recently use cte;
from covid_19..CovidDeaths$ cd 
join covid_19..CovidVaccinations$ as cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
--order by 2,3;

select *,(peopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

create view percentpopulationvaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date)as peopleVaccinated
--(peopleVaccinated/population)*100 cannot use the column which was created recently use cte;
from covid_19..CovidDeaths$ cd 
join covid_19..CovidVaccinations$ as cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
--order by 2,3;

select * from percentpopulationvaccinated;


