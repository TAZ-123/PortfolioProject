USE PortfolioProject

-- Covid Deaths:
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4;


SELECT Location, Date, Total_cases, Total_deaths, Population
FROM CovidDeaths
ORDER BY 1,2;

-- Cases vs Deaths in India:
SELECT Location, Date, Total_cases, Total_deaths, Population,
	(total_deaths/total_cases) * 100 AS Death_Percent
FROM CovidDeaths
WHERE Location LIKE 'India'
ORDER BY 1,2;

-- Percentage of population infected:
SELECT Location, Date, Total_cases, Total_deaths, Population, Continent,
	(total_cases/population) * 100 AS Infected_Percent
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3 DESC;

-- Infection rate of countries:
SELECT Location, Population, MAX(Total_cases) AS Cases,
	MAX(total_cases/population) * 100 AS Infected_Percent
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY 3 DESC;

-- Death rates per country:
SELECT Location, Population, MAX(CAST(Total_Deaths AS INT)) AS Deaths,
MAX(total_deaths/population) * 100 AS Death_Percent
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY Deaths DESC;

-- Death rates per continent:
SELECT continent, MAX(CAST(Total_Deaths AS INT)) AS Deaths
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY Deaths DESC;

-- Global counts:
SELECT 
	Date,
	SUM(new_cases) AS Total_cases, 
	SUM(CAST(new_deaths AS int)) AS Total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percent
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY Date,2;

-- Total Cases(World):
SELECT 
	SUM(new_cases) AS Total_cases, 
	SUM(CAST(new_deaths AS int)) AS Total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percent
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;

-- COVID VACCINATIONS:
SELECT *
FROM CovidVaccinations
ORDER BY 3,4;

-- Joining both tables:
SELECT * 
FROM CovidDeaths Deaths
JOIN CovidVaccinations Vacc
ON Deaths.location = Vacc.location
	AND Deaths.Date = Vacc.Date;

-- Vaccination counts(Running count):
SELECT
	Deaths.Continent,
	Deaths.location,
	Deaths.Date,
	Deaths.Population,
	Vacc.New_Vaccinations,
	SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Location, Deaths.Date ) As Rol_Count_Vaccinations
FROM CovidDeaths Deaths
JOIN CovidVaccinations Vacc
ON Deaths.location = Vacc.location
	AND Deaths.Date = Vacc.Date
WHERE  Deaths.continent IS NOT NULL
ORDER BY 2,3;

-- Vaccinated percent by location:
WITH Vaccinated (Continent,Location,Date,Population,New_Vaccination,Rol_Count_Vaccinations)
AS
(
	SELECT
		Deaths.Continent,
		Deaths.location,
		Deaths.Date,
		Deaths.Population,
		Vacc.New_Vaccinations,
		SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Location, Deaths.Date ) As Rol_Count_Vaccinations
	FROM CovidDeaths Deaths
	JOIN CovidVaccinations Vacc
	ON Deaths.location = Vacc.location
		AND Deaths.Date = Vacc.Date
	WHERE  Deaths.continent IS NOT NULL
) 
Select 
	*,
	(Rol_Count_Vaccinations/population) * 100
FROM Vaccinated;

-- Storing data with views:
CREATE VIEW Vaccinated
AS 
SELECT
		Deaths.Continent,
		Deaths.location,
		Deaths.Date,
		Deaths.Population,
		Vacc.New_Vaccinations,
		SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.Location, Deaths.Date ) As Rol_Count_Vaccinations
	FROM CovidDeaths Deaths
	JOIN CovidVaccinations Vacc
	ON Deaths.location = Vacc.location
		AND Deaths.Date = Vacc.Date
	WHERE  Deaths.continent IS NOT NULL

SELECT *
FROM Vaccinated