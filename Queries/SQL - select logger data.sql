SELECT tItemValue.Id, ItemId, TimeLoc, NumValue, StrValue, tItem.Address
FROM tItemValue
JOIN tItem ON tItemValue.ItemId = tItem.Id
WHERE Address LIKE '%Logged_Tag1%'
-- AND TimeLoc >= '2024-01-10 00:00:00.000' AND TimeLoc < '2024-01-11 00:00:00.000'
ORDER BY TimeLOC DESC

-- DELETE tItemValue WHERE TimeLoc BETWEEN '2024-01-10 00:00:00.000' AND '2024-01-11 00:00:00.000'
