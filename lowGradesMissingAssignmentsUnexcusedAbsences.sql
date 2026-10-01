-- Count of unexcused absent days, low grades, and missing assignments per student for each term in the current school year
-- Warning, this can take a minute or two
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

WITH selectedTerms AS (
    SELECT t.termID, t.name AS termName, t.startDate, t.endDate
    FROM Term t
    JOIN TermSchedule ts ON t.termScheduleID = ts.termScheduleID
    JOIN ScheduleStructure ss ON ss.structureID = ts.structureID
    JOIN Calendar cal ON cal.calendarID = ss.calendarID
    WHERE cal.endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
      AND cal.name LIKE '%' + @SchoolName + '%'
)
SELECT stu.studentNumber, stu.lastName, stu.firstName, stu.grade,
    st.termName,
    (SELECT COUNT(*)
     FROM v_AttDayDetail_Federal addf
     WHERE addf.personID = stu.personID
       AND addf.unexcusedAbsentDay = 1
       AND addf.date >= st.startDate
       AND addf.date BETWEEN st.startDate and st.endDate) AS unexcusedAbsentDays
    ISNULL(g.cGrades, 0) AS cGrades,
    ISNULL(g.dGrades, 0) AS dGrades,
    ISNULL(g.fGrades, 0) AS fGrades,
    ISNULL(g.missing, 0) AS missing
FROM Student stu
CROSS JOIN selectedTerms st
OUTER APPLY (
    SELECT
        SUM(CASE WHEN gad.missing = 0 AND gad.letterGrade IN ('C+','C','C-') THEN 1 ELSE 0 END) AS cGrades,
        SUM(CASE WHEN gad.missing = 0 AND gad.letterGrade IN ('D+','D','D-') THEN 1 ELSE 0 END) AS dGrades,
        SUM(CASE WHEN gad.missing = 0 AND gad.letterGrade = 'F' THEN 1 ELSE 0 END) AS fGrades,
        SUM(CASE WHEN gad.missing = 1 THEN 1 ELSE 0 END) AS missing
    FROM v_GradebookActivityDetail gad
    WHERE gad.personID = stu.personID
      AND gad.termID = st.termID
      AND gad.active = 1
      AND gad.notGraded = 0
      AND gad.weight <> 0
      AND gad.exempt = 0
) g
WHERE stu.activeYear = 1
  AND stu.schoolID IN (SELECT schoolID FROM School WHERE name LIKE '%' + @SchoolName + '%')
ORDER BY stu.lastName, stu.firstName, st.startDate
