WITH NumberSequence AS (
    SELECT 0 AS Number
    UNION ALL
    SELECT Number + 1
    FROM NumberSequence
    WHERE Number < 49
)

SELECT Number
FROM NumberSequence;