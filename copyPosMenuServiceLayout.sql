-- Copies the POS menu service layout from a particular application/service to a new, blank application/service
-- Matthew Prins, 2026

-- Enter the EXACT name of the APPLICATION to GET the service layout FROM
DECLARE @FromApplication VARCHAR(100) = 'Indian Trail 2.0';

-- Enter the EXACT name of the SERVICE to GET the service layout FROM
DECLARE @FromService VARCHAR(100) = 'BREAKFAST';

-- Enter the EXACT name of the APPLICATION to COPY the service layout TO
DECLARE @ToApplication VARCHAR(100) = 'Test 2.0';

-- Enter the EXACT name of the SERVICE to COPY the service layout TO
DECLARE @ToService VARCHAR(100) = 'BREAKFAST';

INSERT INTO POSMenuItem
    (serviceID, purchasableID, positionX, positionY, width, height,
     fontColorRed, fontColorGreen, fontColorBlue,
     fontBold, fontItalic, fontUnderline, fontType, fontSize,
     backgroundColorRed, backgroundColorGreen, backgroundColorBlue)
SELECT
    (SELECT serviceID
       FROM POSService
      WHERE applicationID = (SELECT applicationID FROM POSApplication WHERE name = @ToApplication)
        AND name = @ToService),
    purchasableID, positionX, positionY, width, height,
    fontColorRed, fontColorGreen, fontColorBlue,
    fontBold, fontItalic, fontUnderline, fontType, fontSize,
    backgroundColorRed, backgroundColorGreen, backgroundColorBlue
  FROM POSMenuItem
 WHERE serviceID = (
     SELECT serviceID
       FROM POSService
      WHERE applicationID = (SELECT applicationID FROM POSApplication WHERE name = @FromApplication)
        AND name = @FromService
 );
