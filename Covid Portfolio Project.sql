-- Retrieve data for total cases vs total deaths in states
SELECT
    Location,
    Date,
    Total_Cases,
    Total_Deaths,
    (Total_Deaths / Total_Cases) * 100 AS DeathPercentage
FROM
    ProjectPortfolio..CovidDeaths
WHERE
    Location LIKE '%state%'
ORDER BY
    Location,
    Date;

-- Retrieve data for total cases vs population in states
SELECT
    Location,
    Date,
    Population,
    Total_Cases,
    (Total_Cases / Population) * 100 AS PercentagePopulationInfection
FROM
    ProjectPortfolio..CovidDeaths
WHERE
    Location LIKE '%state%'
ORDER BY
    Location,
    Date;

-- Retrieve data for countries with the highest infection rate compared to population
SELECT
    Location,
    Population,
    MAX(Total_Cases) AS HighestInfectionCount,
    MAX((Total_Cases / Population) * 100) AS PercentagePopulationInfection
FROM
    ProjectPortfolio..CovidDeaths
GROUP BY
    Location,
    Population
ORDER BY
    PercentagePopulationInfection DESC;

-- Countries with highest death count per population
SELECT
    Location,
    MAX(CAST(Total_Deaths AS INT)) AS TotalDeathsCount
FROM
    ProjectPortfolio..CovidDeaths
WHERE 
    Continent IS NOT NULL
GROUP BY
    Location
ORDER BY
    TotalDeathsCount DESC;

-- Break down by continent for death count
SELECT
    Continent,
    MAX(CAST(Total_Deaths AS INT)) AS TotalDeathsCount
FROM
    ProjectPortfolio..CovidDeaths
WHERE 
    Continent IS NOT NULL
GROUP BY
    Continent
ORDER BY
    TotalDeathsCount DESC;

-- Global COVID-19 numbers
SELECT
    SUM(New_Cases) AS TotalCases, 
    SUM(CAST(New_Deaths AS INT)) AS TotalDeaths,
    (SUM(CAST(New_Deaths AS INT)) / SUM(New_Cases)) * 100 AS PercentageOfDeath
FROM
    ProjectPortfolio..CovidDeaths
WHERE
    Continent IS NOT NULL
ORDER BY
    1, 2;

-- Retrieve data for total population vs vaccinations with RollingPeopleVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    ProjectPortfolio..CovidDeaths dea
JOIN
    ProjectPortfolio..CovidVaccinations vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
   dea.continent IS NOT NULL
ORDER BY
    2, 3;

-- Use Common Table Expressions (CTE) for calculating PeopleVaccinatedPercentage
WITH PopVsVaca AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM
        ProjectPortfolio..CovidDeaths dea
    JOIN
        ProjectPortfolio..CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE
       dea.continent IS NOT NULL
)
SELECT 
    *,
    (RollingPeopleVaccinated / population) * 100 AS PeopleVaccinatedPercentage
FROM 
    PopVsVaca;

-- Use a temporary table for the same purpose
DROP TABLE IF EXISTS #PercentPopulationVac;
CREATE TABLE #PercentPopulationVac (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    Date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);
INSERT INTO #PercentPopulationVac
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    ProjectPortfolio..CovidDeaths dea
JOIN
    ProjectPortfolio..CovidVaccinations vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
   dea.continent IS NOT NULL
ORDER BY
    2, 3;

-- Calculate PeopleVaccinatedPercentage using the temporary table
SELECT 
    *,
    (RollingPeopleVaccinated / population) * 100 AS PeopleVaccinatedPercentage
FROM 
    #PercentPopulationVac;

-- Create a view for the same purpose
Drop View If exists PercentPopulationVac
--CREATE VIEW PercentPopulationVac AS
--SELECT 
--    dea.continent,
--    dea.location,
--    dea.date,
--    dea.population,
--    vac.new_vaccinations,
--    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--FROM
--    ProjectPortfolio..CovidDeaths dea
--JOIN
--    ProjectPortfolio..CovidVaccinations vac
--ON 
--    dea.location = vac.location
--    AND dea.date = vac.date
--WHERE
--   dea.continent IS NOT NULL;

-- Select data from the view
SELECT * FROM PercentPopulationVac;
