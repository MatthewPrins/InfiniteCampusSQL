-- Pull a list of siblings where one pays a specific fee and another doesn't
-- Matthew Prins, 2026

-- Enter the EXACT name of the fee from the Infinite Campus Fee Editor
DECLARE @FeeName VARCHAR(100) = '';

WITH ActiveYear AS (
    SELECT endYear FROM schoolYear WHERE active = 1
),
StudentActive AS (
    SELECT DISTINCT personID, studentNumber, schoolID
    FROM Student
    WHERE endYear = (SELECT endYear FROM ActiveYear)
),
Payers AS (
    SELECT DISTINCT fa.personID
    FROM FeeAssignment fa
    JOIN calendar c ON c.calendarID = fa.calendarID
    WHERE fa.feeID = (SELECT feeID FROM Fee WHERE name = @FeeName)
        AND c.endYear = (SELECT endYear FROM ActiveYear)
),
ActiveMembership AS (
    SELECT hm.householdID, hm.personID
    FROM HouseholdMember hm
    WHERE hm.secondary = 0
        AND (hm.startDate IS NULL OR hm.startDate <= GETDATE())
        AND (hm.endDate IS NULL OR hm.endDate >= GETDATE())
),
PayerHouseholds AS (
    SELECT DISTINCT am.householdID, am.personID AS payingPersonID
    FROM ActiveMembership am
    WHERE am.personID IN (SELECT personID FROM Payers)
)
SELECT DISTINCT su.studentNumber AS unpaidStudentNumber,
    (SELECT name FROM School WHERE schoolID = su.schoolID) AS unpaidSchool,
    sp.studentNumber AS payingStudentNumber,
    (SELECT name FROM School WHERE schoolID = sp.schoolID) AS payingSchool
FROM Student s
INNER JOIN StudentActive su ON su.personID = s.personID
INNER JOIN ActiveMembership am ON am.personID = s.personID
INNER JOIN PayerHouseholds ph ON ph.householdID = am.householdID
INNER JOIN StudentActive sp ON sp.personID = ph.payingPersonID
WHERE s.endYear = (SELECT endYear FROM ActiveYear)
    AND NOT EXISTS (SELECT 1 FROM Payers p WHERE p.personID = s.personID)
