-- List of duplicate active Program Participation events, per active student
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

SELECT stu.studentNumber, stu.lastName, stu.firstName, pp.name AS 'ppName', COUNT(*) AS ppCount,
    (SELECT name FROM School WHERE stu.schoolID = schoolID) AS 'schoolName'
FROM v_ProgramParticipation pp
INNER JOIN student stu ON stu.personID = pp.personID
    AND stu.activeYear = 1
WHERE pp.active = 1
    AND calendarID IN (
        SELECT calendarID
        FROM Calendar
        WHERE name LIKE '%' + @SchoolName + '%'
            AND endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
    )
GROUP BY stu.studentNumber, stu.lastName, stu.firstName, pp.programID, stu.schoolID, pp.name
HAVING COUNT(*) >= 2
ORDER BY ppCount DESC, stu.studentNumber, stu.lastName, stu.firstName
