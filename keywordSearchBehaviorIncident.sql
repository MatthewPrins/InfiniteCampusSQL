-- Keyword search within behavior incident details
-- Matthew Prins, 2026

-- Enter partial calendar name here, or leave as '' for all schools
DECLARE @CalendarName VARCHAR(100) = '';

-- Name of role of student searching for (e.g. 'Offender')
DECLARE @RoleName VARCHAR(100) = '';

-- Name of keyword searching for in behavior details (e.g. 'bus')
DECLARE @BehaviorKeyword VARCHAR(100) = '';

SELECT DISTINCT stu.studentNumber, bh.submittedByDate, bh.details, bh.eventID
FROM v_BehaviorDetail bh
LEFT JOIN student stu ON stu.personID = bh.personID and stu.calendarID = bh.calendarID
WHERE bh.calendarID IN (SELECT calendarID FROM Calendar WHERE name LIKE '%' + @CalendarName + '%')
AND bh.details LIKE '%' + @BehaviorKeyword + '%'
AND bh.role = @RoleName
ORDER BY submittedByDate DESC;
