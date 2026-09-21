-- List of students achieving below a certain score and/or percentile on a specific assessment
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

-- Enter current grade restriction here (e.g. '08'), or leave as '' for all schools
DECLARE @CurrentGrade VARCHAR(100) = '';

-- Enter EXACT test name from IC here
DECLARE @TestName VARCHAR(100) = '';

-- Enter highest scale score to include (this scale score and lower); leave as 0 to exclude
DECLARE @HighestScaleScore INTEGER = 0

-- Enter percentile to include (this percentile and lower); leave as 0 to exclude
DECLARE @HighestPercentile INTEGER = 0

SELECT stu.studentNumber, stu.lastName, stu.firstName, stu.grade AS 'currentGrade', 
    t.name AS "testName", ts.scaleScore, ts.percentile
FROM TestScore ts
INNER JOIN student stu 
    ON stu.personID = ts.personID
        AND calendarID IN (
            SELECT calendarID
            FROM Calendar
            WHERE name LIKE '%' + @SchoolName + '%'
                AND endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
        )

LEFT JOIN Test t on t.testID = ts.testID
WHERE t.name = @TestName
    AND (@HighestScaleScore = 0 OR ts.scaleScore <= @HighestScaleScore)
    AND (@HighestPercentile = 0 OR ts.percentile <= @HighestPercentile)
    AND (@CurrentGrade = '' OR stu.grade = @CurrentGrade)
