/*
--Queries to be visualized on tableau
*/

--1. Depicting global numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null 
order by 1,2


-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--2. Depicting the countries with highest death count per population

Select Location, SUM(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is null
and location not in ('World', 'European Union', 'International')
Group by Location
order by TotalDeathCount desc


--3. Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as InfectedPercentage
from PortfolioProject..CovidDeath
--where continent is not null
Group by Location, population
order by InfectedPercentage desc


--4. 
Select Location, population, date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as InfectedPercentage
from PortfolioProject..CovidDeath
--where continent is not null
Group by Location, population, date
order by InfectedPercentage desc