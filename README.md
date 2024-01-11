# sql_SSMS_snippets
Microsoft SQL Server - snippets for Dream Reports

You can use these snippets where Dream Reports allows for Raw SQL. 
Note that values inside tables cannot be accessed as tokens.

### tItemValue inserts
Manual inserts to the logger table (`tItemValue`) are only needed if:
- you wish to keep using the builtin interface for logged tags
- you need to insert logged values at different times than NOW()

Because you need IDs from the `tItem` table it can be time consuming to write inserts manually. So I didn't.
I suppose you could write a SQL query to achieve this, but here is an Excel function that can create the inserts. Simply copy paste the lines from Excel into Reports action button. See example in this repository for query.

```
"(@UTCDateTime, @LocalDateTime, [f#" & MID(C563, FIND(":", C1) + 1, LEN(C1)) &"], NULL, 0, " & A1 & "),"
```
where C column is `tItem.Address` and A column is `tItem.Id`.

Result:
```
(@UTCDateTime, @LocalDateTime, [f#Token1], NULL, 1, id_number),
```

If you need DELETE as well, below is a join to get the IDs. Given Sheet1 with tItems data, and Sheet2 with column A as logger group name (example: `report_name` for `report_name:tag1`):

```
=TEXTJOIN(",", TRUE(), IF(ISNUMBER(SEARCH(A2, $Sheet1.C:C)), $Sheet1.A:A, ""))
```
