/* =====================================================================
   Netflix / MovieLens project - GOLD layer (star schema)
   Database: sqldb-netflix-gold (Azure SQL Database)
   Run once in the Azure portal Query editor.
   ===================================================================== */

-- 1. A schema is a "folder" inside the database that groups related tables.
CREATE SCHEMA gold;
GO

/* ---------------------------------------------------------------------
   2. DIMENSION: one row per movie
   PRIMARY KEY = movie_id is unique (one row per movie)
   --------------------------------------------------------------------- */
CREATE TABLE gold.dim_movie (
    movie_id      INT            NOT NULL PRIMARY KEY,
    title         NVARCHAR(500)  NOT NULL,
    release_year  SMALLINT       NULL      -- a few movies have no year
);

/* ---------------------------------------------------------------------
   3. BRIDGE: one row per movie per genre
   PRIMARY KEY = the pair (movie_id, genre) is unique
   --------------------------------------------------------------------- */
CREATE TABLE gold.movie_genre (
    movie_id  INT           NOT NULL,
    genre     NVARCHAR(50)  NOT NULL,
    CONSTRAINT pk_movie_genre PRIMARY KEY (movie_id, genre)
);

/* ---------------------------------------------------------------------
   4. DIMENSION: one row per calendar day
   --------------------------------------------------------------------- */
CREATE TABLE gold.dim_date (
    date_key      DATE          NOT NULL PRIMARY KEY,
    [year]        SMALLINT      NOT NULL,
    [quarter]     TINYINT       NOT NULL,
    [month]       TINYINT       NOT NULL,
    month_name    NVARCHAR(10)  NOT NULL,
    day_of_month  TINYINT       NOT NULL,
    day_of_week   TINYINT       NOT NULL,   -- 1 = Sunday ... 7 = Saturday (same as ADF dayOfWeek)
    day_name      NVARCHAR(10)  NOT NULL,
    is_weekend    BIT           NOT NULL
);

/* ---------------------------------------------------------------------
   5. FACT: one row per rating (user x movie)  -> ~20 million rows
   No PRIMARY KEY here on purpose: a CLUSTERED COLUMNSTORE index stores
   the table column by column, compressed - ideal for big analytic tables
   (fast SUM/AVG/COUNT, much smaller on disk).
   Grain uniqueness (user_id, movie_id) is checked with a query after loading.
   --------------------------------------------------------------------- */
CREATE TABLE gold.fact_rating (
    user_id     INT           NOT NULL,
    movie_id    INT           NOT NULL,   -- links to gold.dim_movie
    rated_date  DATE          NOT NULL,   -- links to gold.dim_date
    rated_at    DATETIME2(0)  NOT NULL,
    rating      DECIMAL(2,1)  NOT NULL    -- 0.5 to 5.0
);
CREATE CLUSTERED COLUMNSTORE INDEX cci_fact_rating ON gold.fact_rating;

/* ---------------------------------------------------------------------
   6. AGGREGATES: pre-computed answers for dashboards
   --------------------------------------------------------------------- */
CREATE TABLE gold.agg_movie_stats (
    movie_id          INT            NOT NULL PRIMARY KEY,
    title             NVARCHAR(500)  NOT NULL,
    rating_count      INT            NOT NULL,
    avg_rating        DECIMAL(3,2)   NOT NULL,
    first_rated_date  DATE           NOT NULL,
    last_rated_date   DATE           NOT NULL
);

CREATE TABLE gold.agg_genre_year (
    genre         NVARCHAR(50)  NOT NULL,
    rating_year   SMALLINT      NOT NULL,
    rating_count  INT           NOT NULL,
    avg_rating    DECIMAL(3,2)  NOT NULL,
    CONSTRAINT pk_agg_genre_year PRIMARY KEY (genre, rating_year)
);
GO

/* ---------------------------------------------------------------------
   7. FILL dim_date: every day from 1995-01-01 to 2016-12-31
   (covers all MovieLens 20M rating dates). Expected: 8,036 rows.
   --------------------------------------------------------------------- */
SET DATEFIRST 7;  -- week starts on Sunday, so Sunday = 1 (matches ADF)

WITH days AS (
    SELECT CAST('1995-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d) FROM days WHERE d < '2016-12-31'
)
INSERT INTO gold.dim_date
    (date_key, [year], [quarter], [month], month_name, day_of_month, day_of_week, day_name, is_weekend)
SELECT
    d,
    YEAR(d),
    DATEPART(QUARTER, d),
    MONTH(d),
    DATENAME(MONTH, d),
    DAY(d),
    DATEPART(WEEKDAY, d),
    DATENAME(WEEKDAY, d),
    CASE WHEN DATEPART(WEEKDAY, d) IN (1, 7) THEN 1 ELSE 0 END
FROM days
OPTION (MAXRECURSION 0);
GO

-- 8. Checks
SELECT COUNT(*) AS dim_date_rows FROM gold.dim_date;                 -- expect 8036
SELECT TOP 7 * FROM gold.dim_date ORDER BY date_key;                 -- 1995-01-01 was a Sunday
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'gold';  -- expect 6 tables
