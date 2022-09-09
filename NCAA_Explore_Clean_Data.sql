-- Author: Lynn Menchaca
-- Created: 07Sept2022

-- The purpose of this file is to explore and clean the
-- NCAA data set provided by Kaggle

-- Tables
-- `Mens NCAA`.mncaatourneyseeds;
-- `Mens NCAA`.mncaatourneycompactresults;
-- `Mens NCAA`.mncaatourneyslots;
-- `Mens NCAA`.mteams;
-- `Mens NCAA`.mteamconferences;


-- Analyzing Conference and Seed with final NCAA Rank
CREATE TABLE `Mens NCAA`.mncaatourneysummary AS
SELECT result.Season as Season,
		result.DayNum as DayNum,
        result.WTeamID as TeamID,
		seed.Seed AS Seed
FROM `Mens NCAA`.mncaatourneyseeds seed
RIGHT JOIN `Mens NCAA`.mncaatourneycompactresults result
				on result.Season = seed.Season
                and result.WTeamID = seed.TeamID;
                
-- alter table `Mens NCAA`.mncaatourneysummary 
-- alter column `Mens NCAA`.mncaatourneysummary.Seed TYPE INTEGER USING (substr(Seed, 2)::integer);

--  SUBSTRING(`Mens NCAA`.mncaatourneysummary.Seed, 1:) AS int;
-- SELECT RIGHT(`Mens NCAA`.mncaatourneysummary.Seed, LEN(`Mens NCAA`.mncaatourneysummary.Seed) - 1) AS SEED



SELECT RIGHT(`Mens NCAA`.mncaatourneysummary.Seed, LEN(`Mens NCAA`.mncaatourneysummary.Seed) - 1) AS SEED;
FROM `Mens NCAA`.mncaatourneysummary;
