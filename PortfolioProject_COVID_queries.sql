----EXPLORING DATASET

Select *
From PortfolioProject..CovidDeath
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--1. Select the data to be used:

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
order by 1,2

--2. Looking at Total cases vs Total Deaths in Germany

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeath
where location = 'Germany'
order by 1,2



--3. Looking at the total cases vs the population
------Aim is to show what percentage of population got Covid-19	

Select Location, date, population, total_cases, (total_cases/population)* 100 as InfectedPercentage
from PortfolioProject..CovidDeath
where location = 'Germany'
order by 1,2


--4. Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as InfectedPercentage
from PortfolioProject..CovidDeath
where continent is not null
Group by Location, population
order by InfectedPercentage desc



--5. Depicting the countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is null
Group by Location
order by TotalDeathCount desc



--6. Examining the scenario by contient	

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
Group by continent
order by TotalDeathCount desc



--7. Depicting global numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null 
order by 1,2



--8. Joining two tables

Select*
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent	is not null
order by 1,2


--9. Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent	is not null
order by 1,2


--9.1. Using "Partition by" function

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent	is not null
order by 2,3


--9.2. Using "CTE (common table expression)

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent	is not null
---order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)* 100
from PopVsVac 


--9.3. Using "Create Table" 
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
--Since in "Create Table" its necesssary to mention the columns and their type, so mentioning the columns with their type to be executed below:
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
---where dea.continent	is not null
---order by 2,3

Select*, (RollingPeopleVaccinated/Population)* 100
from #PercentPopulationVaccinated



--10. Finally Creating View to store data for Visualization on Tableau

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
---where dea.continent	is not null
---order by 2,3


