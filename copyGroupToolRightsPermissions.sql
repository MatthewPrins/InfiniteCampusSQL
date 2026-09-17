-- Copy group tool rights permissions from one User Group into another
-- Matthew Prins, 2026

-- Enter the EXACT name of the User Group to GET the tool rights FROM
DECLARE @FromGroup VARCHAR(100) = '';

-- Enter the EXACT name of the User Group to COPY the tool rights TO
DECLARE @ToGroup VARCHAR(100) = '';

INSERT INTO dbo.UserGroupToolRights (
    toolID,
    groupID,
    [read],
    [write],
    [add],
    [delete],
    [grant],
    registeredComponentID
)
SELECT
    toolID,
    (SELECT groupID FROM UserGroup WHERE name = @ToGroup) AS groupID,
    [read],
    [write],
    [add],
    [delete],
    [grant],
    registeredComponentID
FROM dbo.UserGroupToolRights
WHERE groupID = (SELECT groupID FROM UserGroup WHERE name = @FromGroup)
