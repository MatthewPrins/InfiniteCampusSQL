-- Pull students with more than one AM or more than one PM bus route (Transportation 2.0)
-- Assumes that routes end in AM/A for morning and PM/P for afternoon
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';

SELECT DISTINCT
    stu.studentNumber, stu.lastName + ', ' + stu.firstName AS studentName, sch.name AS 'schoolName',
    r.routesAM, r.routesPM, r.countAM, r.countPM
FROM Student stu
INNER JOIN School sch ON sch.schoolID = stu.schoolID
INNER JOIN (
    SELECT personID,
        STRING_AGG(CASE WHEN routeName LIKE '%AM' OR routeName LIKE '%A'
            THEN routeName END, '; ') AS routesAM,
        STRING_AGG(CASE WHEN routeName LIKE '%PM' OR routeName LIKE '%P'
            THEN routeName END, '; ') AS routesPM,
        COUNT(DISTINCT CASE WHEN routeName LIKE '%AM' OR routeName LIKE '%A'
            THEN routeName END) AS countAM,
        COUNT(DISTINCT CASE WHEN routeName LIKE '%PM' OR routeName LIKE '%P'
            THEN routeName END) AS countPM
    FROM v_TransportationRoute
    WHERE startDate <= GETDATE()
        AND (endDate >= GETDATE() OR endDate IS NULL)
    GROUP BY personID
    HAVING COUNT(DISTINCT CASE WHEN routeName LIKE '%AM' OR routeName LIKE '%A'
               THEN routeName END) > 1
        OR COUNT(DISTINCT CASE WHEN routeName LIKE '%PM' OR routeName LIKE '%P'
               THEN routeName END) > 1
) r ON stu.personID = r.personID
WHERE stu.activeYear = 1
    AND sch.name LIKE '%' + @SchoolName + '%'
ORDER BY sch.name, studentName;
