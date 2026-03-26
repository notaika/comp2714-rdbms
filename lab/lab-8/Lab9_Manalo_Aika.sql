-- ──────────────────────────────────────────────────────────────────
-- Aika Manalo - Set 2C
-- A01461325
-- ──────────────────────────────────────────────────────────────────

DROP SCHEMA IF EXISTS bikeshare CASCADE;
CREATE SCHEMA bikeshare;
SET search_path TO bikeshare;

-- Task 1. Overall usage summary: total trips, total distance (km), and average distance (km).
SELECT
    COUNT(*)                   AS total_trips,
    SUM(distance_km)           AS total_distance_km,
    ROUND(AVG(distance_km), 2) AS avg_distance_km
FROM
    trip;


-- Task 2. Average distance per neighborhood pair (start → end).
-- Show start_neighborhood, end_neighborhood, avg_km, ordered by avg_km desc.
SELECT
    ss.neighborhood              AS start_neighborhood,
    es.neighborhood              AS end_neighborhood,
    ROUND(AVG(t.distance_km), 2) AS avg_km
FROM
    trip t
        JOIN station ss ON t.start_station_id = ss.station_id
        JOIN station es ON t.end_station_id = es.station_id
GROUP BY ss.neighborhood, es.neighborhood -- Slide 18: multiple group cols
ORDER BY avg_km DESC;


-- Task 3. Distinct riders per plan: show plan_name, rider_count using
-- COUNT(DISTINCT customer_id) over the trip table
SELECT
    p.plan_name,
    COUNT(DISTINCT t.customer_id) AS rider_count
FROM
    plan p
        JOIN customer c ON c.plan_id = p.plan_id
        JOIN trip t ON t.customer_id = c.customer_id
GROUP BY p.plan_name;

-- 3b) Compare with COUNT(*) counts trips, not unique riders
SELECT
    p.plan_name,
    COUNT(*) AS trip_count_not_riders
FROM
    plan p
        JOIN customer c ON c.plan_id = p.plan_id
        JOIN trip t ON t.customer_id = c.customer_id
GROUP BY p.plan_name;


-- Task 4. Per‑day totals: date, trips, total distance.
-- Keep only days where total distance > 10 km (use HAVING).
SELECT
    start_time::date AS trip_date,
    COUNT(*)         AS trips,
    SUM(distance_km) AS total_distance_km
FROM
    trip
GROUP BY start_time::date
HAVING
    SUM(distance_km) > 10 -- filters the GROUP, not individual rows
ORDER BY trip_date;


-- Task 5. For each start neighborhood, show trips and avg_km.
-- Keep only neighborhoods with avg_km ≥ 5 (use HAVING).
SELECT
    ss.neighborhood              AS start_neighborhood,
    COUNT(*)                     AS trips,
    ROUND(AVG(t.distance_km), 2) AS avg_km
FROM
    trip t
        JOIN station ss ON t.start_station_id = ss.station_id
GROUP BY ss.neighborhood
HAVING
    AVG(t.distance_km) >= 5
ORDER BY avg_km DESC;


-- Task 6. For each plan, show riders, trips, and avg_trip_km, ordered by riders desc.
SELECT
    p.plan_name,
    COUNT(DISTINCT t.customer_id) AS riders,
    COUNT(*)                      AS trips,
    ROUND(AVG(t.distance_km), 2)  AS avg_trip_km
FROM
    plan p
        JOIN customer c ON c.plan_id = p.plan_id
        JOIN trip t ON t.customer_id = c.customer_id
GROUP BY p.plan_name
ORDER BY riders DESC;


-- Task 7. “Popular stations”: stations whose trip count is greater than the overall average daily trips.
-- Use a scalar subquery in WHERE.
SELECT
    s.station_id,
    s.station_name,
    COUNT(*) AS trip_count
FROM
    trip t
        JOIN station s ON t.start_station_id = s.station_id
GROUP BY s.station_id, s.station_name
HAVING
    COUNT(*) >
    (SELECT AVG(daily_trips) FROM (SELECT COUNT(*) AS daily_trips FROM trip GROUP BY start_time::date) AS daily_counts)
ORDER BY trip_count DESC;


-- Task 8. Customers who have no trips yet. Use NOT EXISTS (anti‑join pattern).
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM
    customer c
WHERE
    NOT EXISTS (SELECT 1 FROM trip t WHERE t.customer_id = c.customer_id);


-- Task 9. Create a view v_trip_summary with:
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM
    customer c
WHERE
    c.customer_id NOT IN (SELECT customer_id FROM trip);

CREATE OR REPLACE VIEW v_trip_summary AS
    SELECT
        t.start_time::date AS trip_date,
        t.customer_id,
        p.plan_name,
        ss.neighborhood    AS start_neighborhood,
        es.neighborhood    AS end_neighborhood,
        t.distance_km
    FROM
        trip t
            JOIN customer c ON t.customer_id = c.customer_id
            JOIN plan p ON c.plan_id = p.plan_id
            JOIN station ss ON t.start_station_id = ss.station_id
            JOIN station es ON t.end_station_id = es.station_id;

-- Query the view
SELECT *
FROM v_trip_summary
WHERE start_neighborhood = 'Downtown' AND end_neighborhood = 'Mount Pleasant' AND distance_km >= 5;


-- Task 10. Run EXPLAIN ANALYZE on the following filter, then create an index and run it again.
-- In a comment, note what changed in the plan.
INSERT INTO trip (customer_id, bike_id, start_station_id, end_station_id, start_time, end_time, distance_km)
SELECT
    1 + (RANDOM() * 4)::int,
    1 + (RANDOM() * 5)::int,
    1 + (RANDOM() * 5)::int,
    1 + (RANDOM() * 5)::int,
    ts,
    ts + ((10 + (RANDOM() * 50)::int) * INTERVAL '1 minute'),
    ROUND((1 + RANDOM() * 12)::numeric, 2)
FROM
    GENERATE_SERIES('2025-09-15'::timestamp, '2025-11-15'::timestamp, INTERVAL '15 minutes') AS ts;

-- Before Index
EXPLAIN ANALYZE
    SELECT * FROM trip WHERE start_time >= '2025-10-06' AND start_time < '2025-10-08';

/*
    Before creating an INDEX:
    Rows Removed by Filter: ~5800

    The DBMS must scan EVERY row (Sequential Scan) and check the WHERE condition on each one.
    This makes it slow for large tables.
*/

-- Create the index
CREATE INDEX trip_start_time_idx ON trip (start_time);

-- After Index
EXPLAIN ANALYZE
    SELECT * FROM trip WHERE start_time >= '2025-10-06' AND start_time < '2025-10-08';

DROP INDEX trip_start_time_idx;

/*
    After creating an INDEX:
    Instead of scanning all ~6000 rows, the index is used to jump directly to the matching rows which is much faster.
*/