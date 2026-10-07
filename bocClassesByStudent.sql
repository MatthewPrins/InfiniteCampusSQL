-- List and count of all Band/Orchestra/Chorus classes by students
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

WITH BocCourses AS (
    SELECT DISTINCT stu.studentNumber, stu.lastName, stu.firstName, cs.courseName
    FROM Roster r
    LEFT JOIN Trial t ON r.trialID = t.trialID
    LEFT JOIN student stu ON stu.personID = r.personID AND stu.calendarID = t.calendarID
    LEFT JOIN v_ClassSection cs ON r.sectionID = cs.sectionID AND r.trialID = cs.trialID
    WHERE r.trialID IN (SELECT trialID FROM Trial WHERE active = 1)
        AND t.calendarID IN (
            SELECT calendarID 
            FROM Calendar 
            WHERE name LIKE '%'+ @SchoolName + '%'
                AND endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
        )
        AND (cs.courseName LIKE '%Band%'
            OR cs.courseName LIKE '%Orchestra%'
            OR cs.courseName LIKE '%Chorus%')
        AND (r.startDate IS NULL or r.startDate <= GETDATE())
        AND (r.endDate IS NULL or r.endDate >= GETDATE())
)
SELECT studentNumber, lastName, firstName,
    STRING_AGG(courseName, ', ') WITHIN GROUP (ORDER BY courseName) AS courses,
    COUNT(*) AS courseCount
FROM BocCourses
GROUP BY studentNumber, lastName, firstName
ORDER BY lastName, firstName;
