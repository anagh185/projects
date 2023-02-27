--  Created a new table merging input data 1,2,3
CREATE TABLE input_table_1 AS
SELECT *
  FROM input_data_1

 UNION ALL

 SELECT *
   FROM input_data_2
   
   UNION ALL
   select * from input_data_3;
   
--    Created new table input table 2 merging input data 4,5,6
CREATE TABLE input_table_2 AS
SELECT *
  FROM input_data_4

 UNION ALL

 SELECT *
   FROM input_data_5
   
   UNION ALL
   select * from input_data_6;
   
--   Created new table input table 2 merging input data 7,8,9
CREATE TABLE input_table_3 AS
SELECT *
  FROM input_data_7

 UNION ALL

 SELECT *
   FROM input_data_8
   
   UNION ALL
   select * from input_data_9;
   
--   Joining Table 1,2,3 in one final table

create table input as
SELECT
 *
FROM input_table_1
JOIN input_table_2
  ON input_table_1.key_1 = input_table_2.key_1
JOIN input_table_3
  ON input_table_3.key_2 = input_table_2.key_2;
  
  
--  data manipulation on target table
-- Created a table to store the second last value  
  create table second_last as
 select masked_acct, max(score_ind) ,  
RecoveryPctBalanceAtDefaultRatioMACO12 as sec_last
 from target where score_ind 
 not in  (SELECT Max (score_ind) FROM target group by masked_acct) group by masked_acct;
 
--  CREATED TABLE WITH FIRST AND LAST VALUE
CREATE TABLE FIRST_LAST AS
select target.masked_acct,  FIRST_VALUE(TARGET.RecoveryPctBalanceAtDefaultRatioMACO12) 
	OVER (PARTITION BY target.masked_acct ORDER BY target.score_ind) AS SCORE_FIRST,
	sec_last 
	FROM target INNER JOIN second_last ON TARGET.masked_acct = second_last.masked_acct GROUP BY target.masked_acct;
	
-- TARGET_FINAL TABLE WITH TRUE RECOVERY RATE
create table target_final as
SELECT masked_acct, (sec_last+SCORE_FIRST) /2 AS SCORE FROM FIRST_LAST;
 
--   Joining target table with 'target' table on masked_acct

create table final as
select * from input join target_final on input.masked_acct = target_final.masked_acct;

select * from final;