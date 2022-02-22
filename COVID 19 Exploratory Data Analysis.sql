/*
Skills used: Joins, CTE's, Windows Functions(over() clause), Aggregate Functions, Converting Data Types
*/

create database portfolioproject
use portfolioproject

-- Viewing column names in CovidDeath table
select * from CovidDeaths$

-- Selecting data that we are going to work on

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by location, date

-- Gloabal Scenario: Total cases vs Total deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
from CovidDeaths$
where total_deaths IS NOT null

-- India's Scenario: During 1st wave Death percentage peaked during April-June 2020
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
from CovidDeaths$
where location = 'India' AND total_deaths IS NOT null
order by total_cases desc

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  round((total_cases/population)*100, 5) as PercentPopulationInfected
From CovidDeaths$
order by location, date

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Continent wise Scenario
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Date wise global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast (v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.location, d.Date) as total_Vaccinated_population
From CovidDeaths$ AS d
Join CovidVaccinations$ AS v
On d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null
order by 1

-- Finding out when did India start vaccinating people
-- How many people were vaccinated every day in India

Select d.location, d.date, d.population, v.new_vaccinations, 
round((new_vaccinations/d.population) * 100, 4) AS vaccinated_population_percent
From CovidDeaths$ AS d
Join CovidVaccinations$ AS v
On d.location = v.location and d.date = v.date
where v.location = 'India' and v.new_vaccinations is not null
order by 3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Location, Date, Population, New_Vaccinations, total_Vaccinated_population)
as
(
Select d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast (v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.location, d.Date) as total_Vaccinated_population
From CovidDeaths$ AS d
Join CovidVaccinations$ AS v
On d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null
)
Select *, (total_Vaccinated_population/Population)*100 AS percent_total_Vaccinated_population
From PopvsVac