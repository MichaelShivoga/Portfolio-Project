/*
COVID 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

/*

select *
From PortfolioProject..CovidDeaths
Where continent is not null 
Order By 3,4


--Selecting the Data that we are going to be Using
 
 Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
 Where continent is not null 
 Order by 1,2
 
 --Looking at Total Cases vs Total Deaths
 --Shows Likelihood of Dying if you Contact Covid in your Country

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
 From PortfolioProject..CovidDeaths
 Where location like '%states%'
 Order by 1,2

--Looking at the Total Cases vs Population
-- Shows the Percentage of population Affected with Covid

 Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 Order by 1,2

 --Countries with Highest Infection Rates Compared to Population

 Select location, population, Max(total_cases) as HighestInfectionRate, Max((total_cases/population))*100 AS PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 Group by location, population
 Order by PercentPopulationInfected Desc

--Showing Countries with the Highest Death Counts per Population

Select Location, population, Max(Cast(total_deaths as int)) as TotalDeathsCounts
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group BY location, population
Order by TotalDeathsCounts desc

--BREAKing Down THE NUMBERS BY CONTINENTS
-- Showing Continent With The Highest Death Count Per Population

Select location, Max(Cast(total_deaths as int)) as TotalDeathCounts
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCounts Desc

--Accurrate Continent Infection 

Select continent, Max(Cast(total_deaths as int)) as TotalDeathCounts
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCounts Desc

--GLOBAL NUMBERS
--Sum of new cases and new deaths 

 Select date, Sum(new_cases)as Total_Cases, Sum(Cast (new_deaths as int)) as Total_Deaths, Sum(Cast (new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group By date 
 Order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac(continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *
From PopvsVac

--Percentage of RollingPeopleVaccinated vs Population

With PopvsVac(continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if Exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated

--Creating view to store Data for later visualization

Create View PercentagePopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
