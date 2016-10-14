drop table SRAA_SAND.VENDOR_TIER;

CREATE MULTISET TABLE SRAA_SAND.VENDOR_TIER
(
	MasterVendorID integer,
	PAR_VENDOR_ID INTEGER,
	PAR_VENDOR_LEGAL_DESC VARCHAR(200) CHARACTER SET LATIN NOT CASESPECIFIC,
	VENDOR_ID INTEGER,
	VENDOR_LEGAL_DESC VARCHAR(200) CHARACTER SET LATIN NOT CASESPECIFIC,
	Category VARCHAR(23) CHARACTER SET UNICODE NOT CASESPECIFIC,
	Tier varchar(30),
	Date_Modified date);
	
	insert into SRAA_SAND.SRAA_SAND.VENDOR_TIER
	VALUES (?,?,?,?,?,?,?,?);
	
	select * from SRAA_SAND.VENDOR_TIER;