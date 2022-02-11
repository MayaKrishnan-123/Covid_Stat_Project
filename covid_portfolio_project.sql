Select *
FROM PortFolioProject.dbo.CovidDeaths

-- select statament for coviddeaths
SELECT location,date,population,total_cases,new_cases,total_deaths
FROM PortFolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 1,2

--Total cases vs total deaths
--Percentage of people dying if they contract covid -- in india

SELECT location,date,population,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortFolioProject.dbo.CovidDeaths
WHERE location = 'India'
order by 1,2


-- Total cases wrt population 
SELECT location,date,total_cases,population, (total_cases/population)*100 as CovidAffected
FROM PortFolioProject.dbo.CovidDeaths
WHERE location = 'India'
order by 1,2


-- Country where most of the population got infected 
SELECT location,Max(total_cases),population, max((total_cases/population))*100 as CovidAffected
FROM PortFolioProject.dbo.CovidDeaths
--WHERE location = 'India'
group by location , population
--order by 1,2
order by CovidAffected DESC


-- Getting country with highest death rate 
SELECT location,Max(cast(total_deaths as int)) as total_death_count,population, max((cast(total_deaths as int)/population))*100 as PrecentageDeathsperPopulation
FROM PortFolioProject.dbo.CovidDeaths
--WHERE location = 'India'
where continent is not null
group by location , population
--order by 1,2
order by PrecentageDeathsperPopulation DESC


-- see where there is most deaths in respective continents and countries
SELECT location,Max(cast(total_deaths as int)) as total_death_count
FROM PortFolioProject.dbo.CovidDeaths
--WHERE location = 'India'
where continent is not null
group by location 
--order by 1,2
order by total_death_count DESC

SELECT continent,Max(cast(total_deaths as int)) as total_death_count
FROM PortFolioProject.dbo.CovidDeaths
--WHERE location = 'India'
where continent is not null
group by continent 
--order by 1,2
order by total_death_count DESC


--GLOBAL STAT -- Across the world

SELECT date, SUM(new_cases) as Total_Cases , SUM(cast(new_deaths as int)) as Total_deaths ,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortFolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

SELECT SUM(new_cases) as Total_Cases , SUM(cast(new_deaths as int)) as Total_deaths ,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortFolioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2



-- Joining the two tables on location and date

SELECT * 
FROM PortFolioProject..CovidDeaths Dea
JOIN PortFolioProject..CovidVaccinations Vacc
	on Dea.location = Vacc.location
	and Dea.date = Vacc.date
where Dea.continent is not null
order by 3,4


--- Total Vaccinations Vs Population

SELECT Dea.continent,Dea.location,Dea.date,population,Vacc.new_vaccinations,
SUM(convert(int,Vacc.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location,Dea.date) as peoplevaccday
FROM PortFolioProject..CovidDeaths Dea
JOIN PortFolioProject..CovidVaccinations Vacc
	on Dea.location = Vacc.location
	and Dea.date = Vacc.date
where Dea.continent is not null and Dea.location = 'India'
order by 2,3


---Using CTE 

With PopulationVsVacc (Continent,Location,Date,Population,NewVacc,RollingPeopleVacc)
as
(
SELECT Dea.continent,Dea.location,Dea.date,population,Vacc.new_vaccinations,
SUM(convert(int,Vacc.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location,Dea.date) as peoplevaccday
FROM PortFolioProject..CovidDeaths Dea
JOIN PortFolioProject..CovidVaccinations Vacc
	on Dea.location = Vacc.location
	and Dea.date = Vacc.date
where Dea.continent is not null and Dea.location = 'India'
---order by 2,3
)
Select *,(RollingPeopleVacc/Population)*100 as PercentageofPopulationVacc
From PopulationVsVacc
--where Location='India'

-- Creating a View - people vaccinated per day 
Create View PercentageofPeopleVacc as 
SELECT Dea.continent,Dea.location,Dea.date,population,Vacc.new_vaccinations,
SUM(convert(int,Vacc.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location,Dea.date) as peoplevaccday
FROM PortFolioProject..CovidDeaths Dea
JOIN PortFolioProject..CovidVaccinations Vacc
	on Dea.location = Vacc.location
	and Dea.date = Vacc.date
where Dea.continent is not null
--where Dea.continent is not null and Dea.location = 'India'
--order by 2,3
