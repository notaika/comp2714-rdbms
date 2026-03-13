SET search_path TO bikeshare;

SELECT * FROM bike;

-- 1) Aggregates
-- Task 1. Overall usage summary: total trips, total distance (km), and average distance (km).
SELECT * FROM trip;

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

-- Task 3. Distinct riders per plan: show plan_name, rider_count using COUNT(DISTINCT customer_id)
-- over the trip table (via join). Compare with a naive COUNT(*) to understand the difference.
SELECT
    p.plan_name,
    COUNT(DISTINCT t.customer_id) AS rider_count,
    COUNT(*)                      AS total_trips_per_plan
FROM
    plan AS p
        JOIN customer AS c ON p.plan_id = c.plan_id
        JOIN trip AS t ON c.customer_id = t.trip_id
GROUP BY p.plan_name;


-- 2) GROUP BY and HAVING
-- Task 4. Per‑day totals: date, trips, total distance.
-- Keep only days where total distance > 10 km (use HAVING).
SELECT
    CAST(start_time AS DATE) AS trip_date,
    COUNT(trip_id)           AS trip,
    SUM(distance_km)         AS total_distance

FROM
    trip
GROUP BY trip_date
HAVING
    SUM(distance_km) > 10;

SELECT
    CAST(start_time AS DATE) AS trip_date,
    COUNT(trip_id)           AS trip,
    SUM(distance_km)         AS total_distance

FROM
    trip
WHERE
    distance_km > 10
GROUP BY trip_date;


-- Task 5. For each start neighborhood, show trips and avg_km. Keep only neighborhoods with avg_km ≥ 5 (use HAVING).
--
-- Task 6. For each plan, show riders, trips, and avg_trip_km, ordered by riders desc.
--
-- 3) Subqueries
-- Task 7. “Popular stations”: stations whose trip count is greater than the overall average daily trips. Use a scalar subquery in WHERE.
--
-- Task 8. Customers who have no trips yet. Use NOT EXISTS (anti‑join pattern).
--
-- 4) Views
-- Task 9. Create a view v_trip_summary with:
--
-- trip_date, customer_id, plan_name, start_neighborhood, end_neighborhood, distance_km. Then query the view for commutes that start in Downtown and end in Mount Pleasant with distance_km ≥ 5.
--
-- 5) Index (EXPLAIN demo)
-- Task 10. Run EXPLAIN ANALYZE on the following filter, then create an index and run it again. In a comment, note what changed in the plan.
--
-- -- Add ~6k synthetic rows spread across 2025-09-15..2025-11-15
--     INSERT INTO bikeshare.trip (customer_id,bike_id,start_station_id,end_station_id,start_time,end_time,distance_km)
-- SELECT
--     1 + (random()*4)::int,
--     1 + (random()*5)::int,
--     1 + (random()*5)::int,
--     1 + (random()*5)::int,
--     ts,
--     ts + ((10 + (random()*50)::int) * interval '1 minute'),
--     round((1 + random()*12)::numeric,2)
-- FROM generate_series('2025-09-15'::timestamp, '2025-11-15'::timestamp, interval '15 minutes') AS ts;
--
-- EXPLAIN ANALYZE
--     SELECT * FROM bikeshare.trip
--     WHERE start_time >= '2025-10-06' AND start_time < '2025-10-08';
--
-- CREATE INDEX trip_start_time_idx ON bikeshare.trip(start_time);
--
-- EXPLAIN ANALYZE
--     SELECT * FROM bikeshare.trip
--     WHERE start_time >= '2025-10-06' AND start_time < '2025-10-08';