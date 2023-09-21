select *
From PortfolioProject..CovidDeaths
Order By 3,4

--select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Selecting the Data that we are going to be Using
 
 Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
 Order by 1,2
 
 --Looking at Total Cases vs Total Deaths (% of People that died from each case reported)

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
 From PortfolioProject..CovidDeaths
 Where location like '%states%'
 Order by 1,2

--Looking at the Total Cases vs Population

Select location, date, total_cases, total_deaths,population 
 From PortfolioProject..CovidDeaths
 Order by 1,2

 Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 Order by 1,2

 --Looking at Countries with Highest infection rates Compared to population

 Select location, population, Max(total_cases) as HighestInfectionRate, Max((total_cases/population))*100 AS PercentPopulationInfected
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 Group by location, population
 Order by PercentPopulationInfected Desc

--Showing countries with the highest death counts per population

Select Location, population, Max(Cast(total_deaths as int)) as TotalDeathsCounts
From PortfolioProject..CovidDeaths
Where continent is not null
Group BY location, population
Order by TotalDeathsCounts desc

--LETS BREAK THE NUMBERS BY CONTINENTS

Select location, Max(Cast(total_deaths as int)) as TotalDeathCounts
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCounts Desc

--To get accurrate continent infection we replace the location with continent and search where the continent is not null

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

 --JOINING THE TWO TABLE (CovidDeaths and CovidVaccination)

 Select *
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	and dea.date = vac.date

--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATION

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidDeaths vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

--PEOPLE VACCINATED IN THE COUNTIRES VS POPULATION

--USING CTE
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

--Using Temp Table for Population vs Vaccination

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

Select *
From PercentagePopulationVaccinated