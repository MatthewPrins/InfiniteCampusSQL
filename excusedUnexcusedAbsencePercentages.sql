-- Pull excused and unexused absence percentages for the current school year
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

SELECT stu.lastName, stu.firstName, stu.studentNumber, sch.name AS schoolName,
    CAST(100.0 * SUM(addf.absentDay)
        / NULLIF(COUNT(DISTINCT addf.date), 0) AS DECIMAL(5,1)) AS pctAbsent,
    CAST(100.0 * SUM(addf.unexcusedAbsentDay)
        / NULLIF(COUNT(DISTINCT addf.date), 0) AS DECIMAL(5,1)) AS pctUnexcusedAbsent
FROM Student stu
LEFT JOIN Calendar cal ON stu.calendarID = cal.calendarID
LEFT JOIN School sch ON sch.schoolID = cal.schoolID
INNER JOIN v_AttDayDetail_Federal addf
    ON stu.personID = addf.personID AND stu.calendarID = addf.calendarID
WHERE stu.activeYear = 1
  AND sch.name LIKE '%' + @SchoolName + '%'
GROUP BY stu.lastName, stu.firstName, stu.studentNumber, sch.name
ORDER BY pctAbsent DESC
