select * from ProjectPortfolio..['covid death$']
where continent is not null
order by 3,4

select Location, date, total_cases, new_cases, total_deaths
from ProjectPortfolio..['covid death$']
order by 1,2

---looking at total case vs total deaths
---Likelihood of dying if you catch covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from ProjectPortfolio..['covid death$']
Where location like '%states%'
order by 1,2

---Total cases as a percentage of population
select Location, date, total_cases, population, (total_deaths/population)*100 as DeathPercentagePerPopulation
from ProjectPortfolio..['covid death$']
Where location like '%states%'
order by 1,2

--- Infection rate as a percentage of population by countries
select Location, population, max(total_cases) as HighestInfectionCount, max (total_cases/population)*100 as PercentPopulationInfected
From ProjectPortfolio..['covid death$']
Group by location,population
order by PercentPopulationInfected desc

--- Highest death count per population in a continent
 select continent, max(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..['covid death$']
where continent is not null
Group by continent
order by TotalDeathCount desc

---Break  out to global numbers
select date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, (sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
from ProjectPortfolio..['covid death$']
Where continent is not null
group by date
order by 1,2

---Total populatiion as a percentage of vaccination
---USE CTE
With PopsvsVac (Continent, Location, date, population, new_vaccinations,CummulativeVaccine)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location, dea.Date) as CummulativeVaccine
from ProjectPortfolio..['covid death$'] dea
Join ProjectPortfolio..['covid vaccination$'] vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (CummulativeVaccine/Population) *100 
from PopsvsVac

---Creating a Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar(255),
date datetime ,
population numeric,
new_vaccinations numeric,
CummulativeVaccine numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location, dea.Date) as CummulativeVaccine
from ProjectPortfolio..['covid death$'] dea
Join ProjectPortfolio..['covid vaccination$'] vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
select *, (CummulativeVaccine/Population) *100 
from #PercentPopulationVaccinated

--Creating view to store data for visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location, dea.Date) as CummulativeVaccine
from ProjectPortfolio..['covid death$'] dea
Join ProjectPortfolio..['covid vaccination$'] vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null