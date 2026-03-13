SET search_path TO bikeshare;

SELECT * FROM bike;

-- 1) Aggregates
-- Task 1. Overall usage summary: total trips, total distance (km), and average distance (km).
SELECT
    COUNT(*)         AS "Total Trips",
    SUM(distance_km) AS "Total Distance (km)",
    AVG(distance_km) AS "Average Distance (km)"
FROM
    trip;

-- Task 2. Average distance per neighborhood pair (start → end).
-- Show start_neighborhood, end_neighborhood, avg_km, ordered by avg_km desc.
SELECT
    s1.neighborhood    AS start_neighborhood,
    s2.neighborhood    AS end_neighborhood,
    AVG(t.distance_km) AS avg_km
FROM
    trip AS t
        JOIN station s1 ON t.start_station_id = s1.station_id
        JOIN station s2 ON t.end_station_id = s2.station_id
GROUP BY s1.neighborhood, s2.neighborhood
ORDER BY avg_km DESC;

-- Task 3. Distinct riders per plan: show plan_name, rider_count using COUNT(DISTINCT customer_id) over the trip table (via join). Compare with a naive COUNT(*) to understand the difference.
SELECT
    p.plan_name,
    COUNT(DISTINCT t.customer_id) AS rider_count,
    COUNT(*)                      AS total_trips_for_plan
FROM plan p
JOIN customer c ON p.plan_id = c.plan_id
JOIN trip t ON c.customer_id = t.customer_id
GROUP BY p.plan_name;


-- 2) GROUP BY and HAVING
-- Task 4. Per‑day totals: date, trips, total distance. Keep only days where total distance > 10 km (use HAVING).
SELECT
    CAST(start_time AS DATE) AS trip_date,
    COUNT(*)                 AS total_trips,
    SUM(distance_km)         AS total_distance
FROM trip
GROUP BY trip_date
HAVING SUM(distance_km) > 10;

-- Task 5. For each start neighborhood, show trips and avg_km. Keep only neighborhoods with avg_km ≥ 5 (use HAVING).
SELECT
    s.neighborhood   AS start_neighborhood,
    COUNT(*)         AS total_trips,
    AVG(distance_km) AS avg_km
FROM trip t
JOIN station s ON t.start_station_id = s.station_id
GROUP BY s.neighborhood
HAVING AVG(distance_km) >= 5;

-- Task 6. For each plan, show riders, trips, and avg_trip_km, ordered by riders desc.
SELECT
    p.plan_name,
    COUNT(DISTINCT c.customer_id) AS riders,
    COUNT(t.trip_id)              AS trips,
    AVG(t.distance_km)            AS avg_trip_km
FROM plan p
LEFT JOIN customer c ON p.plan_id = c.plan_id
LEFT JOIN trip t ON c.customer_id = t.customer_id
GROUP BY p.plan_name
ORDER BY riders DESC;


-- 3) Subqueries
-- Task 7. “Popular stations”: stations whose trip count is greater than the overall average daily trips. Use a scalar subquery in WHERE.
SELECT
    s.station_name,
    COUNT(*) AS trip_count
FROM trip t
JOIN station s ON t.start_station_id = s.station_id
GROUP BY s.station_name
HAVING COUNT(*) > (
    SELECT AVG(station_trips)
    FROM (
        SELECT COUNT(*) AS station_trips
        FROM trip
        GROUP BY start_station_id
    ) AS trip_stats
);

-- Task 8. Customers who have no trips yet. Use NOT EXISTS (anti‑join pattern).
SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM trip t
    WHERE t.customer_id = c.customer_id
);


-- 4) Views
-- Task 9. Create a view v_trip_summary with:
-- trip_date, customer_id, plan_name, start_neighborhood, end_neighborhood, distance_km. Then query the view for commutes that start in Downtown and end in Mount Pleasant with distance_km ≥ 5.
CREATE OR REPLACE VIEW v_trip_summary AS
SELECT
    CAST(t.start_time AS DATE) AS trip_date,
    c.customer_id,
    p.plan_name,
    s1.neighborhood            AS start_neighborhood,
    s2.neighborhood            AS end_neighborhood,
    t.distance_km
FROM trip t
JOIN customer c ON t.customer_id = c.customer_id
JOIN plan p ON c.plan_id = p.plan_id
JOIN station s1 ON t.start_station_id = s1.station_id
JOIN station s2 ON t.end_station_id = s2.station_id;

-- Query the view
SELECT *
FROM v_trip_summary
WHERE start_neighborhood = 'Downtown'
  AND end_neighborhood = 'Mount Pleasant'
  AND distance_km >= 5;


-- 5) Index (EXPLAIN demo)
-- Task 10. Run EXPLAIN ANALYZE on the following filter, then create an index and run it again. In a comment, note what changed in the plan.

-- Add ~6k synthetic rows spread across 2025-09-15..2025-11-15
INSERT INTO bikeshare.trip (customer_id,bike_id,start_station_id,end_station_id,start_time,end_time,distance_km)
SELECT
    1 + (random()*4)::int,
    1 + (random()*5)::int,
    1 + (random()*5)::int,
    1 + (random()*5)::int,
    ts,
    ts + ((10 + (random()*50)::int) * interval '1 minute'),
    round((1 + random()*12)::numeric,2)
FROM generate_series('2025-09-15'::timestamp, '2025-11-15'::timestamp, interval '15 minutes') AS ts;

-- Before Index
EXPLAIN ANALYZE
    SELECT * FROM bikeshare.trip
    WHERE start_time >= '2025-10-06' AND start_time < '2025-10-08';

CREATE INDEX trip_start_time_idx ON bikeshare.trip(start_time);

-- After Index
EXPLAIN ANALYZE
    SELECT * FROM bikeshare.trip
    WHERE start_time >= '2025-10-06' AND start_time < '2025-10-08';

-- Note: After creating the index, the execution plan likely switched from a "Sequential Scan" (reading the whole table) 
-- to an "Index Scan" or "Bitmap Index Scan", significantly reducing the execution time by only looking at relevant pages.
