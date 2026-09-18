-- List of behavior incidents per student for the current school year, broken down by type 
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

WITH Events AS (
    SELECT DISTINCT personID, eventName, eventID
    FROM v_BehaviorDetail
    WHERE role IN ('Offender', 'Participant')
    AND calendarID IN (
        SELECT calendarID
        FROM Calendar
        WHERE name LIKE '%' + @SchoolName + '%'
            AND endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
    )
),
EventCounts AS (
    SELECT personID, eventName, COUNT(*) AS eventCount
    FROM Events
    GROUP BY personID, eventName
),
StudentInformation AS (
    SELECT DISTINCT personID, studentNumber, lastName, firstName
    FROM student
    WHERE calendarID IN (
        SELECT calendarID
        FROM Calendar
        WHERE name LIKE '%' + @SchoolName + '%'
            AND endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
    )
)
SELECT
    si.studentNumber, si.lastName, si.firstName,
    SUM(eventCount) AS TotalEvents,
    STRING_AGG(eventName + ' (' + CAST(eventCount AS VARCHAR(10)) + ')', ', ')
        WITHIN GROUP (ORDER BY eventCount DESC, eventName) AS EventBreakdown
FROM EventCounts ec
LEFT JOIN StudentInformation si ON ec.personID = si.personID
GROUP BY si.studentNumber, si.lastName, si.firstName
ORDER BY TotalEvents DESC;
