-- Search for the specific duck crime
SELECT id, description
FROM crime_scene_reports
WHERE year = 2021 AND month = 7 AND day = 28;
--FINDINGS: Crime took place at 10:15 am. It has something to do with the bakery

-- Searching the interviews for more information regarding the bakery
SELECT *
FROM interviews
WHERE year = 2021 AND month = 7 AND day = 28 AND transcript LIKE '%bakery%';
-- FINDINGS
-- 1. Criminal left within 10 mins of the crime
-- 2. He/she visited the ATM at leggett street earlier morning
-- 3. talked for < a minute with someone while leaving the bakery
--    * Asked the other person to purchase the earliest flight for tomorrow

-- Searching the bakery_security_logs for people who exited between 10:10 to 10:20
SELECT *
FROM bakery_security_logs
WHERE activity = 'exit' AND year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute BETWEEN 10 AND 20;
--FINDINGS: Noted all the cars which exited between 10:10 to 10:20 am

-- Searching the persons with the cars with license plates found in the previous query
SELECT *
FROM people
WHERE license_plate IN (SELECT license_plate
                        FROM bakery_security_logs
                        WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute BETWEEN 10 AND 20 AND activity = 'exit');
-- FOUND the potential criminals by matching the license plates which exited the bakery around crime time
-- FOUND their name, phone and passport number

-- Searching for those people from the prev query who visited the ATM earlier morning
SELECT *
FROM atm_transactions
WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw';
-- FOUND the account numbers

-- Using these account numbers I found the bankaccounts to trace back which person exited the bakery and used ATM as well earlier morning
SELECT p.name
FROM bank_accounts b
JOIN people p ON p.id = b.person_id
WHERE b.account_number IN     -- account number should match the prev query
        (SELECT account_number
        FROM atm_transactions
        WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw')
        AND p.name IN         -- People should match the ones who exited the bakery between 1015 to 1025
        (SELECT name
        FROM people
        WHERE license_plate IN
                        (SELECT license_plate
                        FROM bakery_security_logs
                        WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute BETWEEN 10 AND 20 AND activity = 'exit'));
-- FINDINGS: Only 2 people match this combination.

-- Searching the call logs and find those who called during this time between 10:10 to 10:20
-- Also searching that the call duration match as well i.e less than a minute
SELECT p.name
FROM phone_calls c
JOIN people p ON p.phone_number = c.caller
WHERE  year = 2021 AND month = 7 AND day = 28 AND c.duration < 60 AND
    p.name IN -- name should match the previous query
        (SELECT p.name
        FROM bank_accounts b
        JOIN people p ON p.id = b.person_id
        WHERE b.account_number IN     -- account number should match the prev query
                (SELECT account_number
                FROM atm_transactions
                WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw')
                AND p.name IN         -- People should match the ones who exited the bakery between 1015 to 1025
                (SELECT name
                FROM people
                WHERE license_plate IN
                                (SELECT license_plate
                                FROM bakery_security_logs
                                WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute BETWEEN 10 AND 20 AND activity = 'exit')));
-- It turns out Bruce is the theif because he matches all the requirements


-- Using the previous query to trace the criminals accomplice
SELECT name
FROM people
WHERE phone_number =
            (SELECT c.receiver
            FROM phone_calls c
            JOIN people p ON p.phone_number = c.caller
            WHERE  year = 2021 AND month = 7 AND day = 28 AND c.duration < 60 AND
                p.name IN -- name should match the previous query
                    (SELECT p.name
                    FROM bank_accounts b
                    JOIN people p ON p.id = b.person_id
                    WHERE b.account_number IN     -- account number should match the prev query
                            (SELECT account_number
                            FROM atm_transactions
                            WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw')
                            AND p.name IN         -- People should match the ones who exited the bakery between 1015 to 1025
                            (SELECT name
                            FROM people
                            WHERE license_plate IN
                                            (SELECT license_plate
                                            FROM bakery_security_logs
                                            WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute BETWEEN 10 AND 20 AND activity = 'exit'))));
-- Bruce is the thief and Robin is the accomplice

-- Searching for the flight Bruce took on 29th
SELECT name, p.passport_number, s.flight_id, a.city Destination_City
FROM people p
JOIN passengers s ON p.passport_number = s.passport_number
JOIN flights f ON f.id = s.flight_id
JOIN airports a ON a.id = f.destination_airport_id
WHERE name = 'Bruce' OR name = 'Robin' AND f.year = 2021 AND f.month = 7 AND f.day = 29;

-- Tracing the passengers which match the passport numbers\
SELECT name, p.passport_number, s.flight_id, a.city Origin_City
FROM people p
JOIN passengers s ON p.passport_number = s.passport_number
JOIN flights f ON f.id = s.flight_id
JOIN airports a ON a.id = f.origin_airport_id
WHERE name = 'Bruce' AND f.year = 2021 AND f.month = 7 AND f.day = 29;
-- Turns out RObin's id passport_number is not in the records


