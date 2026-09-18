-- List of staff with multiple active assignments
-- Matthew Prins, 2026

SELECT
    sm.personID, sm.lastName, sm.firstName,
    COUNT(*) AS AssignmentCount,
    STRING_AGG(sm.title + ' (' + sch.name + ')', ', ')
        WITHIN GROUP (ORDER BY sch.name, sm.title) AS Assignments
FROM staffMember sm
LEFT JOIN School sch ON sm.schoolID = sch.schoolID
WHERE sm.startDate <= GETDATE()
    AND (sm.endDate IS NULL OR sm.endDate >= GETDATE())
GROUP BY sm.personID, sm.lastName, sm.firstName
HAVING COUNT(*) >= 2
ORDER BY AssignmentCount DESC;
