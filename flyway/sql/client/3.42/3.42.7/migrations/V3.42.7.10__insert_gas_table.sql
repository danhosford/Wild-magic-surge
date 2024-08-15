DECLARE @KIOSKID INT = [dbo].udf_GetKioskID(db_name());

PRINT 'Create gases variable table...';

DECLARE @gases TABLE(
	[kioskID] INT NOT NULL
    ,[gas] VARCHAR(50) NOT NULL
    ,[gasName] VARCHAR(500) NOT NULL
    ,[gasIsActive] BIT NOT NULL
)

PRINT 'Insert Into gases variable table...';

INSERT INTO @gases 
VALUES
(@KIOSKID,'O2', 'Oxygen (19-23%)', 1),
(@KIOSKID,'CO', 'Carbon Monoxide (35-70ppm)', 1),
(@KIOSKID,'H2S', 'Hydrogen Sulfide (10-20ppm)', 1),
(@KIOSKID,'SO2', 'Sulfur Dioxide (2.0-4.0ppm)', 1),
(@KIOSKID,'NO2', 'Nitrogen Dioxide (3.0-6.0ppm)', 1),
(@KIOSKID,'CL2', 'Chlorine (0.5-1.0ppm)', 1),
(@KIOSKID,'CL02', 'Chlorine Dioxide (0.1-0.2ppm)', 1),
(@KIOSKID,'CO2', 'Carbon Dioxide (0.5-1.0%)', 1),
(@KIOSKID,'PH3', 'Phosphine (0.3-0.6ppm)', 1),
(@KIOSKID,'NH3', 'Ammonium hydroxide (Aqueous ammonia) (25-50ppm)', 1),
(@KIOSKID,'HCN', 'Hydrogen cyanide (5.0-10.0ppm)', 1),
(@KIOSKID,'NO', 'Nitric Oxide (25-50ppm)', 1),
(@KIOSKID,'HCI', 'Hydrogen Chloride (2.5-5.0ppm)', 1),
(@KIOSKID,'H2', 'Hydrogen (50-100ppm)', 1),
(@KIOSKID,'CH4', 'Methane (1.0-1.5%)', 1),
(@KIOSKID,'LEL', 'Lower Explosive Limit (10-20%)', 1),
(@KIOSKID,'PID', 'Photoionization Detector (100-200ppm)', 1)

PRINT 'Insert Into gas table from gases variable table...';

INSERT INTO [dbo].[gas](
        [kioskID],
        [gas],
        [gasName],
        [gasIsActive])
SELECT [kioskID],
        [gas],
        [gasName],
        [gasIsActive]
FROM @gases;