Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kenya%'
and  continent is not null
Order by 1, 2

--Looking at Total Cases vs Population

Select location, total_cases, population, (total_cases / population) * 100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kenya%'
and continent is not null
Order by 1, 2

--Looking at countries with the highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount,
MAX(total_cases / population) * 100 as HighestInfectedPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by HighestInfectedPercentage

--Showing countries with highest death count per population

Select location, MAX(Cast(total_deaths  as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


--Breaking things down by continent

--Showing continents with the highest death count per population


Select continent, MAX(Cast(total_deaths  as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2


--Looking at Total Population vs Vaccinations

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

)

Select *, (RollingPeopleVaccinated / population) * 100
From PopvsVac


--Temp Table

Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated / population) * 100
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated
