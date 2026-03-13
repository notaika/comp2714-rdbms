DROP SCHEMA IF EXISTS bikeshare CASCADE;
CREATE SCHEMA bikeshare;
SET search_path TO bikeshare;

CREATE TABLE plan
(
    plan_id     SMALLINT PRIMARY KEY,
    plan_name   TEXT          NOT NULL,
    monthly_fee NUMERIC(6, 2) NOT NULL
);

CREATE TABLE station
(
    station_id   SERIAL PRIMARY KEY,
    station_name TEXT NOT NULL,
    neighborhood TEXT NOT NULL
);

CREATE TABLE customer
(
    customer_id SERIAL PRIMARY KEY,
    first_name  TEXT        NOT NULL,
    last_name   TEXT        NOT NULL,
    email       TEXT UNIQUE NOT NULL,
    plan_id     SMALLINT    NOT NULL REFERENCES plan (plan_id),
    created_at  DATE        NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE bike
(
    bike_id    SERIAL PRIMARY KEY,
    model      TEXT    NOT NULL,
    in_service BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE trip
(
    trip_id          BIGSERIAL PRIMARY KEY,
    customer_id      INT           NOT NULL REFERENCES customer (customer_id),
    bike_id          INT           NOT NULL REFERENCES bike (bike_id),
    start_station_id INT           NOT NULL REFERENCES station (station_id),
    end_station_id   INT           NOT NULL REFERENCES station (station_id),
    start_time       TIMESTAMP     NOT NULL,
    end_time         TIMESTAMP     NOT NULL,
    distance_km      NUMERIC(5, 2) NOT NULL CHECK (distance_km >= 0)
);

INSERT INTO plan VALUES (1, 'Casual', 0.00), (2, 'Commuter', 14.99), (3, 'Pro', 24.99);

INSERT INTO station(station_name, neighborhood)
VALUES ('Waterfront', 'Downtown'),
       ('Seabus Terminal', 'Downtown'),
       ('Science World', 'Mount Pleasant'),
       ('Commercial-Broadway', 'Grandview'),
       ('Kits Beach', 'Kitsilano'),
       ('UBC Loop', 'UBC');

INSERT INTO bike(model, in_service)
VALUES ('Roadster', TRUE),
       ('Roadster', TRUE),
       ('CityX', TRUE),
       ('CityX', TRUE),
       ('CargoPlus', TRUE),
       ('CityX', FALSE);

INSERT INTO customer(first_name, last_name, email, plan_id, created_at)
VALUES ('Ava', 'Ng', 'ava@example.com', 2, '2025-09-15'),
       ('Ben', 'Singh', 'ben@example.com', 1, '2025-09-10'),
       ('Cara', 'Lopez', 'cara@example.com', 3, '2025-09-01'),
       ('Dan', 'Kim', 'dan@example.com', 2, '2025-09-20'),
       ('Elle', 'Wong', 'elle@example.com', 3, '2025-09-25'),
       ('Maryam', 'Khezrzadeh', 'maryam@example.com', 1, '2025-10-01');

INSERT INTO trip(customer_id, bike_id, start_station_id, end_station_id, start_time, end_time, distance_km)
VALUES (1, 1, 1, 2, '2025-10-01 08:05', '2025-10-01 08:22', 4.2),
       (1, 1, 2, 1, '2025-10-01 17:45', '2025-10-01 18:03', 4.1),
       (2, 3, 3, 1, '2025-10-02 09:10', '2025-10-02 09:38', 6.0),
       (2, 3, 1, 3, '2025-10-03 11:05', '2025-10-03 11:29', 5.1),
       (3, 5, 5, 6, '2025-10-04 07:30', '2025-10-04 08:20', 10.5),
       (3, 5, 6, 5, '2025-10-05 18:05', '2025-10-05 18:53', 10.7),
       (4, 2, 4, 3, '2025-10-06 08:12', '2025-10-06 08:34', 3.9),
       (4, 2, 3, 4, '2025-10-06 17:20', '2025-10-06 17:41', 3.8),
       (5, 4, 2, 5, '2025-10-07 10:10', '2025-10-07 10:55', 9.4),
       (5, 6, 5, 2, '2025-10-08 15:25', '2025-10-08 16:02', 9.2),
       (1, 1, 1, 3, '2025-10-09 08:04', '2025-10-09 08:33', 5.4),
       (2, 3, 3, 2, '2025-10-09 12:10', '2025-10-09 12:38', 6.3),
       (3, 5, 6, 2, '2025-10-10 19:05', '2025-10-10 19:47', 11.2);
