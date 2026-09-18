-- Gives student birthdays for this week (or the following week) 
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

-- Enter 0 for the week that we're in, 1 for the following week
DECLARE @NextWeek BIT = 1; 

DECLARE @WeekStart DATE = DATEADD(DAY,
    (7 * @NextWeek) - (DATEDIFF(DAY, '19000101', GETDATE()) % 7),
    CAST(GETDATE() AS DATE));

DECLARE @WeekEnd DATE = DATEADD(DAY, 6, @WeekStart);

SELECT stu.studentNumber, stu.firstName, stu.lastName, stu.grade, bd.birthday,
    DATEDIFF(YEAR, stu.birthdate, bd.birthday) AS turningAge
FROM Student stu 
CROSS APPLY (
    SELECT TOP (1) c.birthday
    FROM (VALUES (YEAR(@WeekStart)), (YEAR(@WeekEnd))) AS y(yr)
    CROSS APPLY (
        SELECT DATEFROMPARTS(y.yr, MONTH(stu.birthdate),
            CASE WHEN MONTH(stu.birthdate) = 2 AND DAY(stu.birthdate) = 29
                AND NOT (y.yr % 4 = 0 AND (y.yr % 100 <> 0 OR y.yr % 400 = 0))
                THEN 28 -- Feb 29 birthdays in a non-leap year
                ELSE DAY(stu.birthdate) END) AS birthday
    ) c
    WHERE c.birthday BETWEEN @WeekStart AND @WeekEnd
) bd
WHERE stu.calendarID IN (
    SELECT cal.calendarID
    FROM Calendar cal
    WHERE cal.name LIKE '%' + @SchoolName + '%'
        AND cal.endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
)
ORDER BY bd.birthday, stu.lastName, stu.firstName;
