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

### Manual_Data inserts 
I recommend using my go script https://github.com/Rareshp/go-mssql-insert-from-excel

Otherwise you can create an Excel file, which should look like this:

| Tag | Date (text) | NumValue | TransferId | TransactionId |
| ---- | ---- | ---- | ---- | ---- |
| E127 | 2024-02-10 | 11 | 1111 | 1010 |
| E128 | 2024-02-10 | 12 | 1112 | 1011 |

where TransferId and TransactionId are actually the previous values of the IDs.
```SQL
SELECT MAX(TransferId) and MAX(TransactionId) from Manual_Data_md
```

Below is the function you need to break apart and join back together the date field in what you want. In particular here is a complicated example where UTC time is previous date.
```
`=IF(ISBLANK(B2), "", "('"&IF(ISBLANK(B2), "", TEXT(DATE(YEAR(B2), MONTH(B2), DAY(B2)-1), "yyyy-mm-dd")&" 22:00:00.000', '"&B2&" 00:00:00.000', SYSUTCDATETIME(), SYSDATETIME(), '"&A2&"', "&C2&", 1, 1," &D2&", "&E2&", 'user'),"))
```

Remember to increment the IDs for every row, and between pages!
```
`=MAX($Pag1.D:D)
```

Gives: 
```SQL
('2024-02-09 22:00:00.000', '2024-02-10 00:00:00.000', SYSUTCDATETIME(), SYSDATETIME(), 'E127', 11, 1, 1, 1111, 1010, 'user'),
('2024-02-09 22:00:00.000', '2024-02-10 00:00:00.000', SYSUTCDATETIME(), SYSDATETIME(), 'E128', 12, 1, 1, 1112, 1011, 'user'),
```
