SELECT Orig_TS_Local, Tag_Name, Num_Value, Str_Value, Transaction_Id, Transfer_Id, 'User'
FROM Manual_Data_md
where Tag_Name like '%Tag1%'
order by Orig_TS_Local desc

-- DELETE Manual_Data_Electro_TOT WHERE Orig_TS_Local BETWEEN '2024-01-10 00:00:00.000' AND '2024-01-11 00:00:00.000'
