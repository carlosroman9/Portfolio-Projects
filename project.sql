CREATE VIEW pct_pop_vax AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER by cd.location, cd.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)
FROM [Portfolio Project]..CovidDeaths AS cd

JOIN [Portfolio Project]..[Covid Vaccinations] AS cv ON cd.location = cv.location
AND cd.date = cv.date

WHERE cd.continent is not null

--ORDER by 2,3