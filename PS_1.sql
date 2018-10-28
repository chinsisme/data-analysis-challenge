/* 
Checkpoint 1  
*/

-- Get top 25 rows from each agency

set @row_number := 1;
set @current_agency := '';

SELECT 
	date,
	registrar,
	private_agency,
    RowNumber,
	state,
	district,
	sub_district,
	pincode,
	gender,
	age,
	aadhar_generated,
	rejected,
	mobile_number,
	email_id
FROM 
(
	SELECT 
		date,
		registrar,
		private_agency,
		state,
		district,
		sub_district,
		pincode,
		gender,
		age,
		aadhar_generated,
		rejected,
		mobile_number,
		email_id,
		@row_number:=IF(@current_agency = private_agency,
			@row_number + 1,
			1) AS 'RowNumber',
		@current_agency:=private_agency AS 'dummy'
	FROM
		crisp.aadhar_data
	ORDER BY private_agency
) AS tab
WHERE RowNumber <=25;

/* 
Checkpoint 2  
*/

-- Describe the schema

DESC aadhar_data;


-- Find the count and names of registrars in the table.

SELECT 
    COUNT(DISTINCT registrar)
FROM
    aadhar_data;

-- Find the number of states, districts in each state and sub-districts in each district.

SELECT DISTINCT
    registrar
FROM
    aadhar_data;

SELECT DISTINCT
    state
FROM
    aadhar_data;

SELECT 
    state,
    GROUP_CONCAT(DISTINCT district
        ORDER BY district ASC
        SEPARATOR ', ') AS 'Districts'
FROM
    aadhar_data
GROUP BY state;

SELECT 
    district,
    GROUP_CONCAT(DISTINCT sub_district
        ORDER BY sub_district ASC
        SEPARATOR ', ') AS 'Sub districts'
FROM
    aadhar_data
GROUP BY district;


-- Find out the names of private agencies for each state

SELECT 
    state,
    GROUP_CONCAT(DISTINCT private_agency
        ORDER BY private_agency ASC
        SEPARATOR ', ') AS 'Private agencies'
FROM
    aadhar_data
GROUP BY state;

/* 
Checkpoint 3 
 */

-- Find top 3 states generating most number of Aadhaar cards?

SELECT 
    state, SUM(aadhar_generated) AS 'Number of aadhar generated'
FROM
    aadhar_data
GROUP BY state
ORDER BY `Number of aadhar generated` DESC
LIMIT 1,3;


-- Find top 3 districts where enrolment numbers are maximum?

SELECT 
    district,
    SUM(aadhar_generated + rejected) 'Number of enrolments'
FROM
    aadhar_data
GROUP BY district
ORDER BY `Number of enrolments` DESC
LIMIT 0,3;

-- Find the no. of Aadhaar cards generated in each state?

SELECT 
    state, SUM(aadhar_generated) AS 'Aadhars generated'
FROM
    aadhar_data
GROUP BY state
ORDER BY `Aadhars generated` DESC;

/* 
Checkpoint 4
 */

-- Find the number of unique pincodes in the data?

SELECT 
    COUNT(DISTINCT pincode)
FROM
    aadhar_data;

-- Find the number of Aadhaar registrations rejected in Uttar Pradesh and Maharashtra?

SELECT 
    state, COUNT(rejected) AS 'Rejected aadhar registrations'
FROM
    aadhar_data
WHERE
    state IN ('Uttar Pradesh' , 'Maharashtra')
GROUP BY state
ORDER BY `Rejected aadhar registrations` DESC;

/* 
Checkpoint 5
 */

-- Find the top 3 states where the percentage of Aadhaar cards being generated for malesis the highest.

SELECT 
    state, PercentageOfMaleRegistrations
FROM
    (SELECT 
        state,
            (MAX(`Male`) / MAX(`All`)) * 100 AS PercentageOfMaleRegistrations
    FROM
        (SELECT 
        state, COUNT(aadhar_generated) AS 'Male', 1 AS 'All'
    FROM
        aadhar_data
    WHERE
        gender = 'M'
    GROUP BY state , gender UNION ALL SELECT 
        state, 1, COUNT(aadhar_generated)
    FROM
        aadhar_data
    GROUP BY state
    ORDER BY state) AS tab
    GROUP BY state) AS tab
ORDER BY PercentageOfMaleRegistrations DESC
LIMIT 0 , 3;

/* 
Got the following result : Manipur, Assam, Arunachal Pradesh. Since MySQL does not support LIMIT within sub-queries, I had to break the above and below queries down.
 */

-- Find in each of these 3 states, identify the top 3 districts where the percentage ofAadhaar cards being rejected for females is the highest.

SELECT 
    state,
    district,
    PercentageOfFemaleRejections,
    @rank:=IF(@current_state = state,
        IF(@percentage > PercentageOfFemaleRejections,
            @rank + 1,
            @rank),
        1) AS StateLevelRank,
    @percentage:=PercentageOfFemaleRejections,
    @current_state:=state
FROM
    (SELECT 
        state,
            district,
            (MAX(`Female`) / MAX(`All`)) * 100 AS PercentageOfFemaleRejections
    FROM
        (SELECT 
        state, district, COUNT(rejected) AS 'Female', 1 AS 'All'
    FROM
        aadhar_data
    WHERE
        gender = 'F'
    GROUP BY state , district , gender UNION ALL SELECT 
        state, district, 1, COUNT(rejected)
    FROM
        aadhar_data
    GROUP BY state , district) AS tab1
    GROUP BY state , district) AS tab2
WHERE
    district IN (SELECT DISTINCT
            district
        FROM
            aadhar_data
        WHERE
            state IN ('Manipur' , 'Assam', 'Arunachal Pradesh'))
ORDER BY state , PercentageOfFemaleRejections DESC;


-- Find the summary of the acceptance percentage of all the Aadhaar cards applications bybucketing the age group into 10 buckets.

select AgeBucket, (sum(aadhar_generated) / (sum(aadhar_generated) + sum(rejected)) * 100 ) as 'AcceptancePercentage' from (
SELECT 
    aadhar_generated,
    rejected,
    age,
    CASE
        WHEN age BETWEEN 0 AND 10 THEN '0-10'
        WHEN age BETWEEN 10 AND 20 THEN '10-20'
        WHEN age BETWEEN 20 AND 30 THEN '20-30'
        WHEN age BETWEEN 30 AND 40 THEN '30-40'
        WHEN age BETWEEN 40 AND 50 THEN '40-50'
        WHEN age BETWEEN 50 AND 60 THEN '50-60'
        WHEN age BETWEEN 60 AND 70 THEN '60-70'
        WHEN age BETWEEN 70 AND 80 THEN '70-80'
        WHEN age BETWEEN 80 AND 90 THEN '80-90'
        WHEN age BETWEEN 90 AND 100 THEN '90-100'
        WHEN age > 100 THEN '100+'
        ELSE 'Misc'
    END AS 'AgeBucket'
FROM
    aadhar_data
) as tab
group by AgeBucket;