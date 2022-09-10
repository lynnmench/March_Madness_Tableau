-- Author: Lynn Menchaca
-- Created: 07Sept2022

-- The purpose of this file is to explore and clean the
-- NCAA data set provided by Kaggle

-- Problems during coding:
-- 1) Converting the StartSeed column from varchar(2) to int data type
--       RIGHT(SEED, 2) AS StartSeed
--       ...
--       ALTER TABLE `Mens NCAA`.mncaatourneysummary
--       MODIFY COLUMN StartSeedChar INT;
--       LIMIT 1008,1; This was the line with the problem
--       Problem ended up coming from line 1009 Y16a -> 6a (couldn't int the char 'a')


-- All the tables available:
-- `Mens NCAA`.mncaatourneyseeds
-- `Mens NCAA`.mncaatourneycompactresults
-- `Mens NCAA`.mncaatourneyslots
-- `Mens NCAA`.mteams
-- `Mens NCAA`.mteamconferences
-- `Mens NCAA`.mncaatourneysummary
-- `Mens NCAA`.mmasseyordinals
-- `Mens NCAA`.mteamcoaches
SELECT *
FROM `Mens NCAA`.mteamcoaches
LIMIT 100;


-- Creating MNCAA Summary Table to join the other tables too
-- This way I am no altering any original data tables
DROP TABLE IF EXISTS `Mens NCAA`.mncaatourneysummary;
CREATE TABLE `Mens NCAA`.mncaatourneysummary AS
SELECT result.Season as Season,
		result.DayNum as DayNum,
        result.WTeamID as TeamID,
		seed.Seed AS Seed,
        REGEXP_REPLACE(Seed, '[^0-9]', '') AS StartSeed
        -- CAST(StartSeed AS UNSIGNED) AS StartSeed
FROM `Mens NCAA`.mncaatourneyseeds seed
RIGHT JOIN `Mens NCAA`.mncaatourneycompactresults result
				on result.Season = seed.Season
                and result.WTeamID = seed.TeamID;

-- Converting StartSeed column to integer data type
ALTER TABLE `Mens NCAA`.mncaatourneysummary
MODIFY COLUMN StartSeed INT;

-- Removing duplicate rows (by season and TeamID)
-- Use SET SQL_SAFE_UPDATES to turn off and allow MySQL to make the changes to table
-- At the end close SQL_SAFE_UPDATES to put the safety feature back on
SET SQL_SAFE_UPDATES = 0;
DELETE T1 
FROM `Mens NCAA`.mncaatourneysummary T1
JOIN `Mens NCAA`.mncaatourneysummary T2
ON T1.Season = T2.Season 
AND T1.TeamID = T2.TeamID 
AND T1.DayNum < T2.DayNum;
SET SQL_SAFE_UPDATES = 1;

-- Add Final MNCAA Tournament Seed
ALTER TABLE `Mens NCAA`.mncaatourneysummary
ADD FinalSeed INT AS (CASE
					WHEN DayNum = 154 THEN 1
					WHEN DayNum = 152 THEN 2
					WHEN DayNum = 146 OR DayNum = 145 THEN 4
					WHEN DayNum = 144 OR DayNum = 143 THEN 8
					WHEN DayNum = 139 OR DayNum = 138 THEN 16
					ELSE 32
					END);

-- Adding M Massey Ordinals Ranking to the MNCAA Tourney Summary table
-- SELECT summ.*,
-- 		massey.OrdinalRank AS OrdinalRank
-- FROM `Mens NCAA`.mmasseyordinals AS massey
-- RIGHT JOIN `Mens NCAA`.mncaatourneysummary AS summ
-- 				on summ.TeamID = massey.TeamID
--                 AND massey.RankingDayNum = 133;

-- Adding Team Name to the MNCAA Tourney Summary table
SET SQL_SAFE_UPDATES = 0;
-- ALTER TABLE `Mens NCAA`.mncaatourneysummary
-- DROP COLUMN TeamName;
ALTER TABLE `Mens NCAA`.mncaatourneysummary
ADD TeamName text;
UPDATE `Mens NCAA`.mncaatourneysummary AS summ
	LEFT JOIN `Mens NCAA`.mteams AS team
				on summ.TeamID = team.TeamID
SET summ.TeamName = team.TeamName
WHERE summ.TeamID = team.TeamID;
SET SQL_SAFE_UPDATES = 1;

-- Adding Conference to the MNCAA Tourney Summary table
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE `Mens NCAA`.mncaatourneysummary
ADD ConfAbbrev text;
UPDATE `Mens NCAA`.mncaatourneysummary AS summ
	LEFT JOIN `Mens NCAA`.mteamconferences AS conf
				on summ.Season = conf.Season
                and summ.TeamID = conf.TeamID
SET summ.ConfAbbrev = conf.ConfAbbrev
WHERE summ.Season = conf.Season
      and summ.TeamID = conf.TeamID;
SET SQL_SAFE_UPDATES = 1;

-- Adding Coaches to the MNCAA Tourney Summary table
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE `Mens NCAA`.mncaatourneysummary
ADD CoachName text;
UPDATE `Mens NCAA`.mncaatourneysummary AS summ
	LEFT JOIN `Mens NCAA`.mteamcoaches AS coach
				on summ.Season = coach.Season
                and summ.TeamID = coach.TeamID
                and coach.LastDayNum > 133
SET summ.CoachName = coach.CoachName
WHERE summ.Season = coach.Season
		and summ.TeamID = coach.TeamID
		and coach.LastDayNum > 133;
SET SQL_SAFE_UPDATES = 1;


SELECT *
FROM `Mens NCAA`.mncaatourneysummary
LIMIT 100;

-- Ways to test my mncaatourneysummary table
-- Check for null values
-- Looking to see if all 1st place winners for each season is listed

SELECT *
FROM `Mens NCAA`.mncaatourneysummary AS summ
WHERE summ.FinalSeed = 1;
