-- Pull missing assignments from within the current term, along with parent emails
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

-- Enter number of days to look backward; leave as 0 to have no limit
DECLARE @DaysLookingBackward INTEGER = 0;

SELECT DISTINCT stuCon.email 'studentEmail', i.firstName + ' ' + i.lastName 'studentName', 
    gad.activityName, co.name 'subject', gad.dueDate, 
    (SELECT (STUFF((SELECT CAST(', ' + email AS VARCHAR(MAX)) FROM v_CensusContactSummary WHERE personID = gad.personID AND guardian = 1 AND email IS NOT NULL FOR XML PATH ('')), 1, 2, ''))) 'parentEmails'
FROM v_GradebookActivityDetail gad
LEFT JOIN Term t ON t.termID = gad.termID
LEFT JOIN Section sec ON sec.sectionID = gad.sectionID
LEFT JOIN Course co ON co.courseID = sec.courseID
LEFT JOIN Person p ON p.personID = gad.personID
LEFT JOIN [Identity] i ON i.identityID = p.currentIdentityID
LEFT JOIN Contact stuCon ON stuCon.personID = p.personID
LEFT JOIN LessonPlanGroup lpg ON lpg.groupID = gad.groupID
WHERE gad.calendarID IN (
    SELECT calendarID FROM Calendar WHERE NAME LIKE '%' + @SchoolName +'%'
        AND endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
)
    AND GETDATE() BETWEEN t.startDate AND t.endDate -- in current term
    AND (@DaysLookingBackward = 0 OR DATEDIFF(DAY, gad.dueDate, GETDATE()) <= @DaysLookingBackward)
    AND gad.exempt = 0
    AND gad.weight <> 0
    AND lpg.calcExclude = 0
    AND gad.notGraded = 0
    AND gad.missing = 1
ORDER BY stuCon.email
