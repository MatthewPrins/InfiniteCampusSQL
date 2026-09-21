-- Report of enrollment by school/grade/district on a specific day
-- Matthew Prins, 2026

-- Enter date as of when you want to look at enrollment, 'YYYY-MM-DD'
DECLARE @EnrollmentAsOfDate DATE = '2026-08-27';

WITH ranked AS (
    SELECT stu.studentNumber, sch.name AS school, stu.grade,
           ROW_NUMBER() OVER (
               PARTITION BY stu.studentNumber
               ORDER BY stu.startDate DESC, stu.enrollmentID DESC
           ) AS rn
    FROM student stu
    INNER JOIN Enrollment e ON e.enrollmentID = stu.enrollmentID
    INNER JOIN Calendar cal ON cal.calendarID = stu.calendarID
    INNER JOIN School sch ON sch.schoolID = stu.schoolID
    WHERE stu.activeYear = 1
      AND stu.startDate <= @EnrollmentAsOfDate
      AND (stu.endDate IS NULL OR stu.endDate >= @EnrollmentAsOfDate)
      AND stu.studentNumber NOT LIKE '%test%' -- line to remove test students
      AND ISNULL(e.stateExclude, 0) = 0
      AND ISNULL(cal.summerSchool, 0) = 0
      AND ISNULL(cal.exclude, 0) = 0
)
SELECT
    CASE WHEN GROUPING(school) = 1 THEN 'District' ELSE school END AS school,
    CASE WHEN GROUPING(grade) = 1 AND GROUPING(school) = 1 THEN 'Total'
         WHEN GROUPING(grade) = 1 THEN 'School Total'
         ELSE grade END AS grade,
    COUNT(*) AS students
FROM ranked
WHERE rn = 1
GROUP BY GROUPING SETS (
    (school, grade),
    (school),
    (grade),
    ()
)
ORDER BY GROUPING(school), school, GROUPING(grade), grade;
