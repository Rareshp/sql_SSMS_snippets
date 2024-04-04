-- I strongly recommend making a custom table for downtime reasons, instead of using manual input 
-- it is a bit more work to insert the data at first, but reading it back is a lot easier with better schema

-- replace the times shown below with dynamic tokens inside Reports:
-- WHERE Orig_TS_Local BETWEEN '[tp#Start_Data]' AND '[tp#End_Data]'


---------------------------------

-- these tables are needed in case you wish to have combo-boxes use data from SQL instead of being hardcoded 
-- this is what I have done, and I recommend it because is easier to change things in 1 or to tables, than in Reports
-- you must choose "object to send updates to" if you want to send one combo-box selection to another; category > reason 


-- keys have been ommited from the code below
CREATE TABLE Downtime_Categories_Table (
    Id INT PRIMARY KEY,
    Category_Name VARCHAR(50)
);

INSERT INTO Downtime_Categories_Table (Id, Category_Name)
VALUES 
    (1, 'Category1'),
    (2, 'Category2'),
    (3, 'Category3'),
    (4, 'Category4');

CREATE TABLE Downtime_Reason_Table (
	[1] [varchar](50) NULL,
	[2] [varchar](50) NULL,
	[3] [varchar](50) NULL,
	[4] [varchar](50) NULL
);


---------------------------------


-- get everything that day
SELECT * FROM [Manual_Data_table]
WHERE Orig_TS_Local BETWEEN '2024-04-02 00:00:00.000' AND '2024-04-03 00:00:00.000'

-- get all the downtime reasons for a day 
SELECT [Orig_TS_Local], Tag_Name, Str_Value FROM [Manual_Data_table]
WHERE Orig_TS_Local BETWEEN '2024-04-02 00:00:00.000' AND '2024-04-03 00:00:00.000'
AND Tag_Name = 'downtime_reason_tag'

-- get the full amount of hours per day as inputed by user 
SELECT [Orig_TS_Local], Tag_Name, Num_Value FROM [Manual_Data_table]
WHERE Orig_TS_Local BETWEEN '2024-04-02 00:00:00.000' AND '2024-04-03 00:00:00.000'
and Tag_Name = 'ac2_ore_oprire'

-- get only cases when a category = 1
SELECT [Orig_TS_Local], Tag_Name, Str_Value FROM [Manual_Data_table]
WHERE Orig_TS_Local IN (
    SELECT [Orig_TS_Local] FROM [Manual_Data_table]
    WHERE Orig_TS_Local BETWEEN '2024-04-02 01:00:00.000' AND '2024-04-03 00:00:00.000'
    AND Tag_Name = 'downtime_category_tag' AND Num_Value = 1 -- here you add a dynamic token
)
AND Tag_Name = 'downtime_reason_tag'


-- filter by category, then find number of hours spent in that category 
SELECT SUM(Num_Value) FROM [Manual_Data_table]
WHERE Orig_TS_Local IN (
    SELECT [Orig_TS_Local] FROM [Manual_Data_table]
    WHERE Orig_TS_Local BETWEEN '2024-04-02 00:00:00.000' AND '2024-04-03 00:00:00.000'
    AND Tag_Name = 'downtime_category_tag' AND Num_Value = 1 -- here you add a dynamic token
)
AND Tag_Name = 'downtime_hours_tag'

---------------------------------

-- below are several queries that require JOINs 
-- this is to show different tags at once, such as downtime reasons + hours 


-- find downtime reasons for all categories, and display number of hours for the same insert times
SELECT m1.[Orig_TS_Local], m1.Str_Value AS Cauza_Oprire, m2.Num_Value AS Ore_Oprire
FROM [Manual_Data_table] AS m1
JOIN [Manual_Data_table] AS m2 
ON m1.[Orig_TS_Local] = m2.[Orig_TS_Local]
WHERE m1.Orig_TS_Local IN (
    SELECT [Orig_TS_Local] FROM [Manual_Data_table]
    WHERE Orig_TS_Local BETWEEN '2024-04-02 00:00:00.000' AND '2024-04-03 00:00:00.000'
    AND Tag_Name = 'downtime_category_tag'
)
AND m1.Tag_Name = 'downtime_reason_tag'
AND m2.Tag_Name = 'downtime_hours_tag'


-- same as above, but also filter by category
SELECT m1.[Orig_TS_Local], m1.Str_Value AS Cauza_Oprire, m2.Num_Value AS Ore_Oprire
FROM [Manual_Data_table] AS m1
JOIN [Manual_Data_table] AS m2 
ON m1.[Orig_TS_Local] = m2.[Orig_TS_Local]
WHERE m1.Orig_TS_Local IN (
    SELECT [Orig_TS_Local] FROM [Manual_Data_table]
    WHERE Orig_TS_Local BETWEEN '2024-04-02 01:00:00.000' AND '2024-04-03 00:00:00.000'
    AND Tag_Name = 'downtime_category_tag' AND Num_Value = 1  -- here you add a dynamic token
)
AND m1.Tag_Name = 'downtime_reason_tag'
AND m2.Tag_Name = 'downtime_hours_tag'



-- retrieves the sum of hours grouped by downtime reason
-- it is a must to first have the values column, then the legend column for pie charts
SELECT SUM(m2.Num_Value) AS Ore_Oprire, m1.Str_Value AS Cauza_Oprire
FROM [Manual_Data_table] AS m1
JOIN [Manual_Data_table] AS m2 
ON m1.[Orig_TS_Local] = m2.[Orig_TS_Local]
WHERE m1.Orig_TS_Local IN (
    SELECT [Orig_TS_Local] FROM [Manual_Data_table]
    WHERE Orig_TS_Local BETWEEN '2024-04-02 00:00:00.000' AND '2024-04-03 00:00:00.000'
    AND Tag_Name = 'downtime_category_tag'
)
AND m1.Tag_Name = 'downtime_reason_tag'
AND m2.Tag_Name = 'downtime_hours_tag'
GROUP BY m1.Str_Value;



-- this query will return the sum of downtime hours, per category
-- but because the category is an Id, we need to retrieve that from another table
SELECT SUM(m2.Num_Value) AS Ore_Oprire, cl.Category_Name AS Category
FROM [Manual_Data_table] AS m1
JOIN [Manual_Data_table] AS m2 ON m1.[Orig_TS_Local] = m2.[Orig_TS_Local]
JOIN Downtime_Categories_Table AS cl ON m1.Num_Value = cl.id
WHERE m1.Orig_TS_Local IN (
    SELECT [Orig_TS_Local] FROM [Manual_Data_table]
    WHERE Orig_TS_Local BETWEEN '2024-04-02 00:00:00.000' AND '2024-04-03 00:00:00.000'
    AND Tag_Name = 'downtime_category_tag'
)
AND m1.Tag_Name = 'downtime_category_tag'
AND m2.Tag_Name = 'downtime_hours_tag'
GROUP BY cl.Category_Name;
