-- Pull students who do not have the permission checked off for POS Eligibility
-- Matthew Prins, 2026

-- Enter partial school name here (e.g. 'Washington'), or leave as '' for all schools
DECLARE @SchoolName VARCHAR(100) = '';
    
SELECT pose.eligibilityID, pose.personID, stu.firstName, stu.lastName, sch.name AS school, stu.grade 
FROM POSEligibility pose 
LEFT JOIN POSEligibilityPermission posep ON pose.eligibilityID = posep.eligibilityID
LEFT JOIN student stu ON stu.personID = pose.personID
    AND stu.endYear = (SELECT endYear FROM SchoolYear WHERE active = 1)
LEFT JOIN School sch ON sch.schoolID = stu.schoolID
WHERE pose.endyear = (SELECT endYear FROM SchoolYear WHERE active = 1)
    AND posep.eligibilityID IS NULL
    AND stu.personID IS NOT NULL
     AND sch.name LIKE '%' + @SchoolName + '%'
