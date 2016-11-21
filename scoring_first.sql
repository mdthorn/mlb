--create table

CREATE TABLE mlb_line_scores (
        game_date       date,
        visiting_team   varchar(20),
        home_team       varchar(20),
        visiting_score  int,
        home_score      int,
        innings         int,
        visiting_line_score     varchar(50),
        home_line_score         varchar(50)
        );

COPY mlb_line_scores (
        game_date, visiting_team, home_team, visiting_score, home_score, innings, visiting_line_score, home_line_score
        )
FROM '/Users/mthorn/Documents/fun/mlb_games_2015/mlb_line_scores_2015.csv'
WITH DELIMITER ',' CSV
;

-- spot-check win/loss records for accuracy and completeness

SELECT v.visiting_team as team,
        v.wins + h.wins as total_wins
FROM (
        SELECT visiting_team,
                COUNT(*) as wins
        FROM mlb_line_scores
        WHERE visiting_score > home_score
        GROUP BY 1
        ) v
JOIN (
        SELECT home_team,
                COUNT(*) as wins
        FROM mlb_line_scores
        WHERE home_score > visiting_score
        GROUP BY 1
        ) h
        ON v.visiting_team = h.home_team
ORDER BY 2 DESC

-- % of time first scorer won

WITH first_scores as (
        SELECT *,
                POSITION(SUBSTRING(visiting_line_score, '[1-9]') in visiting_line_score) as visiting_first_score_inning,
                POSITION(SUBSTRING(home_line_score, '[1-9]') in home_line_score) as home_first_score_inning,
                SUBSTRING(visiting_line_score, '[1-9]') as visiting_first_runs,
                SUBSTRING(home_line_score, '[1-9]') as home_first_runs
        FROM mlb_line_scores
        ),
outcomes as (
        SELECT *,
                CASE WHEN visiting_first_score_inning <= home_first_score_inning OR home_first_score_inning IS NULL THEN 'visitor'
                        WHEN home_first_score_inning < visiting_first_score_inning OR visiting_first_score_inning IS NULL THEN 'home'
                        ELSE 'other' END as scored_first,
                CASE WHEN visiting_score > home_score THEN 'visitor'
                        WHEN home_score > visiting_score THEN 'home'
                        ELSE 'other' END as winner
        FROM first_scores
        )
SELECT scored_first,
        winner,
        COUNT(*) as games
FROM outcomes
GROUP BY 1,2
ORDER BY 3 DESC

-- aggregated

WITH first_scores as (
        SELECT *,
                POSITION(SUBSTRING(visiting_line_score, '[1-9]') in visiting_line_score) as visiting_first_score_inning,
                POSITION(SUBSTRING(home_line_score, '[1-9]') in home_line_score) as home_first_score_inning,
                SUBSTRING(visiting_line_score, '[1-9]') as visiting_first_runs,
                SUBSTRING(home_line_score, '[1-9]') as home_first_runs
        FROM mlb_line_scores
        ),
outcomes as (
        SELECT *,
                CASE WHEN visiting_first_score_inning <= home_first_score_inning OR home_first_score_inning IS NULL THEN 'visitor'
                        WHEN home_first_score_inning < visiting_first_score_inning OR visiting_first_score_inning IS NULL THEN 'home'
                        ELSE 'other' END as scored_first,
                CASE WHEN visiting_score > home_score THEN 'visitor'
                        WHEN home_score > visiting_score THEN 'home'
                        ELSE 'other' END as winner
        FROM first_scores
        )
SELECT CASE WHEN scored_first = winner THEN 'Yes' ELSE 'No' END as first_scorer_won,
        COUNT(*) as games
FROM outcomes
GROUP BY 1
ORDER BY 2 DESC

-- % of time first scorer is visitor/home

WITH first_scores as (
        SELECT *,
                POSITION(SUBSTRING(visiting_line_score, '[1-9]') in visiting_line_score) as visiting_first_score_inning,
                POSITION(SUBSTRING(home_line_score, '[1-9]') in home_line_score) as home_first_score_inning,
                SUBSTRING(visiting_line_score, '[1-9]') as visiting_first_runs,
                SUBSTRING(home_line_score, '[1-9]') as home_first_runs
        FROM mlb_line_scores
        ),
outcomes as (
        SELECT *,
                CASE WHEN visiting_first_score_inning <= home_first_score_inning OR home_first_score_inning IS NULL THEN 'visitor'
                        WHEN home_first_score_inning < visiting_first_score_inning OR visiting_first_score_inning IS NULL THEN 'home'
                        ELSE 'other' END as scored_first,
                CASE WHEN visiting_score > home_score THEN 'visitor'
                        WHEN home_score > visiting_score THEN 'home'
                        ELSE 'other' END as winner
        FROM first_scores
        )
SELECT scored_first,
        COUNT(*) as games
FROM outcomes
GROUP BY 1
ORDER BY 2 DESC

-- what % of teams win after scoring first by inning

WITH first_scores as (
        SELECT *,
                POSITION(SUBSTRING(visiting_line_score, '[1-9]') in visiting_line_score) as visiting_first_score_inning,
                POSITION(SUBSTRING(home_line_score, '[1-9]') in home_line_score) as home_first_score_inning,
                SUBSTRING(visiting_line_score, '[1-9]') as visiting_first_runs,
                SUBSTRING(home_line_score, '[1-9]') as home_first_runs
        FROM mlb_line_scores
        ),
outcomes as (
        SELECT *,
                CASE WHEN visiting_first_score_inning <= home_first_score_inning OR home_first_score_inning IS NULL THEN 'visitor'
                        WHEN home_first_score_inning < visiting_first_score_inning OR visiting_first_score_inning IS NULL THEN 'home'
                        ELSE 'other' END as scored_first,
                CASE WHEN visiting_score > home_score THEN 'visitor'
                        WHEN home_score > visiting_score THEN 'home'
                        ELSE 'other' END as winner
        FROM first_scores
        )
SELECT LEAST(visiting_first_score_inning, home_first_score_inning) as first_score_inning,
        COUNT(*) as games,
        COUNT(CASE WHEN scored_first = winner THEN game_date END) as first_scorer_won
FROM outcomes
GROUP BY 1
ORDER BY 1

-- grouping by first score amount

WITH first_scores as (
        SELECT *,
                POSITION(SUBSTRING(visiting_line_score, '[1-9]') in visiting_line_score) as visiting_first_score_inning,
                POSITION(SUBSTRING(home_line_score, '[1-9]') in home_line_score) as home_first_score_inning,
                SUBSTRING(visiting_line_score, '[1-9]') as visiting_first_runs,
                SUBSTRING(home_line_score, '[1-9]') as home_first_runs
        FROM mlb_line_scores
        ),
outcomes as (
        SELECT *,
                CASE WHEN visiting_first_score_inning <= home_first_score_inning OR home_first_score_inning IS NULL THEN 'visitor'
                        WHEN home_first_score_inning < visiting_first_score_inning OR visiting_first_score_inning IS NULL THEN 'home'
                        ELSE 'other' END as scored_first,
                CASE WHEN visiting_score > home_score THEN 'visitor'
                        WHEN home_score > visiting_score THEN 'home'
                        ELSE 'other' END as winner
        FROM first_scores
        )
SELECT CASE WHEN scored_first = 'visitor' THEN visiting_first_runs WHEN scored_first = 'home' THEN home_first_runs ELSE NULL END as first_runs_scored,
        COUNT(*) as games,
        COUNT(CASE WHEN scored_first = winner THEN game_date END) as first_scorer_won
FROM outcomes
GROUP BY 1
ORDER BY 1

-- grouping by first score inning and runs scored

WITH first_scores as (
        SELECT *,
                POSITION(SUBSTRING(visiting_line_score, '[1-9]') in visiting_line_score) as visiting_first_score_inning,
                POSITION(SUBSTRING(home_line_score, '[1-9]') in home_line_score) as home_first_score_inning,
                SUBSTRING(visiting_line_score, '[1-9]') as visiting_first_runs,
                SUBSTRING(home_line_score, '[1-9]') as home_first_runs
        FROM mlb_line_scores
        ),
outcomes as (
        SELECT *,
                CASE WHEN visiting_first_score_inning <= home_first_score_inning OR home_first_score_inning IS NULL THEN 'visitor'
                        WHEN home_first_score_inning < visiting_first_score_inning OR visiting_first_score_inning IS NULL THEN 'home'
                        ELSE 'other' END as scored_first,
                CASE WHEN visiting_score > home_score THEN 'visitor'
                        WHEN home_score > visiting_score THEN 'home'
                        ELSE 'other' END as winner
        FROM first_scores
        )
SELECT CASE WHEN first_score_inning::int > 4 THEN '5' ELSE first_score_inning END as first_score_inning,
        CASE WHEN first_runs_scored::int > 2 THEN '3' ELSE first_runs_scored END as first_runs_scored,
        SUM(games) as games,
        SUM(first_scorer_won) as first_scorer_won
FROM (
        SELECT LEAST(visiting_first_score_inning, home_first_score_inning) as first_score_inning,
                CASE WHEN scored_first = 'visitor' THEN visiting_first_runs WHEN scored_first = 'home' THEN home_first_runs ELSE NULL END as first_runs_scored,
                COUNT(*) as games,
                COUNT(CASE WHEN scored_first = winner THEN game_date END) as first_scorer_won
        FROM outcomes
        GROUP BY 1,2
        ORDER BY 1,2
        ) r
GROUP BY 1,2
ORDER BY 1,2

-- which teams score first most often?

WITH first_scores as (
        SELECT *,
                POSITION(SUBSTRING(visiting_line_score, '[1-9]') in visiting_line_score) as visiting_first_score_inning,
                POSITION(SUBSTRING(home_line_score, '[1-9]') in home_line_score) as home_first_score_inning,
                SUBSTRING(visiting_line_score, '[1-9]') as visiting_first_runs,
                SUBSTRING(home_line_score, '[1-9]') as home_first_runs
        FROM mlb_line_scores
        ),
outcomes as (
        SELECT *,
                CASE WHEN visiting_first_score_inning <= home_first_score_inning OR home_first_score_inning IS NULL THEN 'visitor'
                        WHEN home_first_score_inning < visiting_first_score_inning OR visiting_first_score_inning IS NULL THEN 'home'
                        ELSE 'other' END as scored_first,
                CASE WHEN visiting_score > home_score THEN 'visitor'
                        WHEN home_score > visiting_score THEN 'home'
                        ELSE 'other' END as winner
        FROM first_scores
        )
SELECT CASE WHEN scored_first = 'visitor' THEN visiting_team WHEN scored_first = 'home' THEN home_team ELSE 'other' END as team,
        COUNT(*) as games_scored_first,
        COUNT(CASE WHEN scored_first = winner THEN game_date END) as subset_won
FROM outcomes
GROUP BY 1
ORDER BY 2 DESC

-- which teams come back most often?

WITH first_scores as (
        SELECT *,
                POSITION(SUBSTRING(visiting_line_score, '[1-9]') in visiting_line_score) as visiting_first_score_inning,
                POSITION(SUBSTRING(home_line_score, '[1-9]') in home_line_score) as home_first_score_inning,
                SUBSTRING(visiting_line_score, '[1-9]') as visiting_first_runs,
                SUBSTRING(home_line_score, '[1-9]') as home_first_runs
        FROM mlb_line_scores
        ),
outcomes as (
        SELECT *,
                CASE WHEN visiting_first_score_inning <= home_first_score_inning OR home_first_score_inning IS NULL THEN 'visitor'
                        WHEN home_first_score_inning < visiting_first_score_inning OR visiting_first_score_inning IS NULL THEN 'home'
                        ELSE 'other' END as scored_first,
                CASE WHEN visiting_score > home_score THEN 'visitor'
                        WHEN home_score > visiting_score THEN 'home'
                        ELSE 'other' END as winner
        FROM first_scores
        )
SELECT CASE WHEN scored_first = 'visitor' THEN home_team WHEN scored_first = 'home' THEN visiting_team ELSE 'other' END as team,
        COUNT(*) as games_behind,
        COUNT(CASE WHEN scored_first != winner THEN game_date END) as subset_won
FROM outcomes
GROUP BY 1
ORDER BY 2 DESC
