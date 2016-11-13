-- avg. margin per team 

WITH all_games as (
        select game_date,
                visiting_team as team,
                home_team as other_team,
                park_id,
                1 as visiting_team,
                visiting_score as team_score,
                home_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        union all
        select game_date,
                home_team as team,
                visiting_team as other_team,
                park_id,
                0 as visiting_team,
                home_score as team_score,
                visiting_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        )
SELECT team,
        AVG(margin) as avg_margin,
        COUNT(CASE WHEN team_score > other_team_score THEN game_date END) as wins
FROM all_games
group by 1
ORDER BY 2 DESC

-- look at 1-run games

WITH all_games as (
        select game_date,
                visiting_team as team,
                home_team as other_team,
                park_id,
                1 as visiting_team,
                visiting_score as team_score,
                home_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        union all
        select game_date,
                home_team as team,
                visiting_team as other_team,
                park_id,
                0 as visiting_team,
                home_score as team_score,
                visiting_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        )
SELECT team,
        COUNT(game_date) as total_games,
        COUNT(CASE WHEN margin = 1 THEN game_date END) as one_run_games,
        COUNT(CASE WHEN margin = 1 AND team_score > other_team_score THEN game_date END) as one_run_wins,
        COUNT(CASE WHEN margin = 1 AND team_score < other_team_score THEN game_date END) as one_run_losses
FROM all_games
group by 1
ORDER BY 3 DESC

-- win pct by margin

WITH all_games as (
        select game_date,
                visiting_team as team,
                home_team as other_team,
                park_id,
                1 as visiting_team,
                visiting_score as team_score,
                home_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        union all
        select game_date,
                home_team as team,
                visiting_team as other_team,
                park_id,
                0 as visiting_team,
                home_score as team_score,
                visiting_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        )
SELECT team,
        CASE WHEN margin > 4 THEN 5 ELSE margin END as margin,
        COUNT(game_date) as total_games,
        COUNT(CASE WHEN team_score > other_team_score THEN game_date END) as wins
FROM all_games
group by 1,2
ORDER BY 1,2 ASC

-- look at runs scored/allowed in aggregate over season

WITH all_games as (
        select game_date,
                visiting_team as team,
                home_team as other_team,
                park_id,
                1 as visiting_team,
                visiting_score as team_score,
                home_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        union all
        select game_date,
                home_team as team,
                visiting_team as other_team,
                park_id,
                0 as visiting_team,
                home_score as team_score,
                visiting_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        )
SELECT team,
        SUM(team_score) as runs_scored,
        SUM(other_team_score) as runs_allowed,
        SUM(team_score) - SUM(other_team_score) as diff,
        COUNT(CASE WHEN team_score > other_team_score THEN game_date END) as wins
FROM all_games
GROUP BY 1
ORDER BY 4 DESC

-- look at avg margin by month

SELECT date_trunc('month', game_date)::date as month,
        COUNT(*) as games,
        AVG(margin) as avg_margin
FROM (
        SELECT game_date,
                ABS(visiting_score - home_score) as margin
        FROM mlb_games_2015
        ) m
GROUP BY 1
ORDER BY 1

-- comparing win vs. loss margins by team

WITH all_games as (
        select game_date,
                visiting_team as team,
                home_team as other_team,
                park_id,
                1 as visiting_team,
                visiting_score as team_score,
                home_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        union all
        select game_date,
                home_team as team,
                visiting_team as other_team,
                park_id,
                0 as visiting_team,
                home_score as team_score,
                visiting_score as other_team_score,
                ABS(visiting_score - home_score) as margin
        from mlb_games_2015
        )
SELECT team,
        COUNT(CASE WHEN team_score > other_team_score THEN game_date END) as wins,
        AVG(CASE WHEN team_score > other_team_score THEN margin END)::numeric(20,1) as avg_win_margin,
        AVG(CASE WHEN team_score < other_team_score THEN margin END)::numeric(20,1) as avg_loss_margin
FROM all_games
GROUP BY 1
ORDER BY 2 DESC
