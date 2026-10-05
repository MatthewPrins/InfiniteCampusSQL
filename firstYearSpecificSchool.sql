-- List of students who are in their first year at a specific school (but not necessarily district)
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington')
DECLARE @SchoolName VARCHAR(100) = '';

WITH TargetSchool AS (
    SELECT schoolID
    FROM School
    WHERE name LIKE '%' + @SchoolName + '%'
),
FirstYearAtSchool AS (
    SELECT stu.personID, MIN(stu.endYear) AS firstEndYear
    FROM Student stu
    JOIN TargetSchool ts ON ts.schoolID = stu.schoolID
    WHERE stu.serviceType = 'P'
    GROUP BY stu.personID
)
SELECT DISTINCT stu.studentNumber, stu.lastName, stu.firstName, stu.grade
FROM Student stu
INNER JOIN TargetSchool ts ON ts.schoolID = stu.schoolID
INNER JOIN FirstYearAtSchool fyas ON fyas.personID = stu.personID
WHERE stu.activeYear = 1
AND stu.serviceType = 'P'
AND fyas.firstEndYear = stu.endYear
AND stu.startDate <= GETDATE()
AND (stu.endDate IS NULL OR stu.endDate >= GETDATE())
ORDER BY stu.grade, stu.lastName, stu.firstName;
