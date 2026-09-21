-- List current year or future year students without student numbers
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

SELECT DISTINCT stu.lastName, stu.firstName, stu.grade, sch.name AS schoolName
FROM Student stu
LEFT JOIN School sch ON sch.schoolID = stu.schoolID
WHERE endYear >= (SELECT endYear FROM SchoolYear WHERE active = 1)
    AND studentNumber IS NULL
    AND sch.name LIKE '%' + @SchoolName +'%'
