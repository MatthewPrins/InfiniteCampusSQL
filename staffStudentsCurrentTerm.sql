-- List all staff's students for the current term, searching by staff number or email address
-- Matthew Prins, 2026

-- Enter staff number, or leave as '' to not use
DECLARE @StaffNumberSearch VARCHAR(100) = '';

-- Enter staff email, or leave as '' to not use
DECLARE @StaffEmailSearch VARCHAR(100) = '';

WITH SelectedStaff AS (
    SELECT DISTINCT sm.personID
    FROM staffMember sm
    LEFT JOIN v_CensusContactSummary ccs ON sm.personID = ccs.personID AND ccs.relationship = 'Self'
    WHERE (sm.startDate IS NULL OR sm.startDate <= GETDATE())
        AND (sm.endDate IS NULL OR sm.endDate >= GETDATE())
        AND (@StaffEmailSearch = '' OR @StaffEmailSearch = ccs.email)
        AND (@StaffNumberSearch = '' OR @StaffNumberSearch = sm.staffNumber)
),

SectionPeriods AS (
    SELECT DISTINCT stu.studentNumber, stu.lastName, stu.firstName, ssh.sectionID, cs.courseNumber, cs.courseName, p.name AS periodName, p.seq
    FROM Roster r
    INNER JOIN SectionStaffHistory ssh ON ssh.sectionID = r.sectionID AND ssh.trialID = r.trialID
    LEFT JOIN v_CourseSection cs ON cs.sectionID = r.sectionID AND cs.trialID = r.trialID
    LEFT JOIN SectionPlacement sp ON cs.sectionID = sp.sectionID AND cs.trialID = sp.trialID
    LEFT JOIN Term t ON t.termID = sp.termID
    LEFT JOIN Period p ON p.periodID = sp.periodID
    LEFT JOIN Student stu ON r.personID = stu.personID AND stu.activeYear = 1
    WHERE ssh.personID = (SELECT personID FROM SelectedStaff)
            AND r.trialID IN (SELECT trialID FROM activeTrial)
            AND (r.startDate IS NULL OR r.startDate <= GETDATE())
            AND (r.endDate IS NULL OR r.endDate >= GETDATE())
            AND (t.startDate IS NULL OR t.startDate <= GETDATE())
            AND (t.endDate IS NULL OR t.endDate >= GETDATE())
            AND (ssh.startDate IS NULL OR ssh.startDate <= GETDATE())
            AND (ssh.endDate IS NULL OR ssh.endDate >= GETDATE())
)

SELECT studentNumber, lastName, firstName, sectionID, courseNumber, courseName, 
    STRING_AGG(periodName, ', ') WITHIN GROUP (ORDER BY seq) AS periods
FROM SectionPeriods
GROUP BY studentNumber, lastName, firstName, sectionID, courseNumber, courseName
ORDER BY MIN(seq), lastName;
