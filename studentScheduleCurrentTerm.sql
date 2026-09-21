-- List student's schedule for the current term, searching by student number or email address
-- Matthew Prins, 2026

-- Enter student number, or leave as '' to not use
DECLARE @StudentNumberSearch VARCHAR(100) = '';

-- Enter student email, or leave as '' to not use
DECLARE @StudentEmailSearch VARCHAR(100) = '';

WITH SelectedStudent AS (
    SELECT DISTINCT stu.personID
    FROM Student stu
    LEFT JOIN v_CensusContactSummary ccs ON stu.personID = ccs.personID AND ccs.relationship = 'Self'
    WHERE stu.activeYear = 1
        AND (@StudentEmailSearch = '' OR @StudentEmailSearch = ccs.email)
        AND (@StudentNumberSearch = '' OR @StudentNumberSearch = stu.studentNumber)
),

SectionPeriods AS (
    SELECT DISTINCT r.sectionID, cs.courseNumber, cs.courseName, cs.teacherDisplay, p.name AS periodName, p.seq
    FROM Roster r
    LEFT JOIN v_CourseSection cs ON cs.sectionID = r.sectionID AND cs.trialID = r.trialID
    LEFT JOIN SectionPlacement sp ON cs.sectionID = sp.sectionID AND cs.trialID = sp.trialID
    LEFT JOIN Term t ON t.termID = sp.termID
    LEFT JOIN Period p ON p.periodID = sp.periodID
    WHERE r.personID IN (SELECT personID FROM SelectedStudent)
        AND r.trialID IN (SELECT trialID FROM activeTrial)
        AND (r.startDate IS NULL OR r.startDate <= GETDATE())
        AND (r.endDate IS NULL OR r.endDate >= GETDATE())
        AND (t.startDate IS NULL OR t.startDate <= GETDATE())
        AND (t.endDate IS NULL OR t.endDate >= GETDATE())
)

SELECT courseNumber, courseName, teacherDisplay,
    STRING_AGG(periodName, ', ') WITHIN GROUP (ORDER BY seq) AS periods
FROM SectionPeriods
GROUP BY sectionID, courseNumber, courseName, teacherDisplay
ORDER BY MIN(seq);
