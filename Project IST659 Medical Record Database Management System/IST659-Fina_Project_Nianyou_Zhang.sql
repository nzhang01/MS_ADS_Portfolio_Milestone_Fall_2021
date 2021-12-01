--IST659M005-Project-Zhang-Nianyou-Yawen-Zheng

--create tables
--part 1: basic information

CREATE TABLE demographicInformation
( 
	citizenId INTEGER NOT NULL,
	firstName VARCHAR (40) NOT NULL,
	middleName VARCHAR (40),
	lastName VARCHAR (40) NOT NULL,
	gender VARCHAR (1) NOT NULL,
	maritalStatus VARCHAR(30) NOT NULL,
	ethnicity VARCHAR (40) NOT NULL,
	dateOfBirth DATE NOT NULL,

	CONSTRAINT pk_demographicInformation PRIMARY KEY (citizenId),

	CONSTRAINT chk_gender CHECK (gender='M' OR gender='F'),
	CONSTRAINT chk_maritalStatus CHECK (maritalStatus='Single' OR maritalStatus='Married'OR maritalStatus='Divorced'OR maritalStatus='Widowed'),
	CONSTRAINT chk_ethnicity CHECK (ethnicity='White' OR ethnicity='African American' OR ethnicity='Native American' OR ethnicity='Pacific Islander' OR ethnicity='Asian' OR ethnicity='Native Hawaiian'),
);

CREATE TABLE geographicInformation
(
	citizenId INTEGER NOT NULL,
	startDate DATE NOT NULL,
	cStreetNo VARCHAR (30) NOT NULL,
	cStreetName VARCHAR (30) NOT NULL,
	cCity VARCHAR (30) NOT NULL,
	cState VARCHAR (30) NOT NULL,
	cZipCode VARCHAR (10) NOT NULL,

	CONSTRAINT pk_geographicInformation PRIMARY KEY (citizenId, startDate),
	CONSTRAINT fk_geographicInformation FOREIGN KEY (citizenId) REFERENCES demographicInformation (citizenId),
);

CREATE TABLE birthInformation
(
	childCitizenId INTEGER NOT NULL,
	fatherCitizenId INTEGER,
	motherCitizenId INTEGER,
	bStreetNo VARCHAR (30) NOT NULL,
	bStreetName VARCHAR (30) NOT NULL,
	bCity VARCHAR (30) NOT NULL,
	bState VARCHAR (30) NOT NULL,
	bZipCode VARCHAR (10) NOT NULL,

	CONSTRAINT pk_birthInformation PRIMARY KEY (childCitizenId),
	CONSTRAINT fk_birthInformation1 FOREIGN KEY (childCitizenId) REFERENCES demographicInformation (citizenId),
	CONSTRAINT fk_birthInformation2 FOREIGN KEY (fatherCitizenId) REFERENCES demographicInformation (citizenId),
	CONSTRAINT fk_birthInformation3 FOREIGN KEY (motherCitizenId) REFERENCES demographicInformation (citizenId),
);

--part 2: immunization

CREATE TABLE vaccineDictionary
(
	vaccineId			INTEGER			NOT NULL,
	vaccineName			VARCHAR(100)	NOT NULL,
	vaccineDescription	TEXT,

	CONSTRAINT		pk_vaccineDictionary	PRIMARY KEY (vaccineId),

	CONSTRAINT		chk_vaccineName CHECK (vaccineName='Tetanus' OR vaccineName='Hepatitis' OR vaccineName='Human Papillomavirus' OR vaccineName='Mumps' OR vaccineName='Influenza' OR vaccineName='Hib')	
);

CREATE TABLE immunizationRecord
(
	citizenId			INTEGER			NOT NULL,
	vaccineId			INTEGER			NOT NULL,
	dateAdministered	DATETIME		DEFAULT GETDATE()	NOT NULL,
	iClinicName			VARCHAR(80)		NOT NULL,
	immunizationCost	DECIMAL			NOT NULL,
	iFoundingSource		VARCHAR(1)		NOT NULL,

	CONSTRAINT	pk_immunizationRecord	PRIMARY KEY (citizenId, vaccineId, dateAdministered),
	CONSTRAINT	fk_immunizationRecord1	FOREIGN KEY (citizenId) REFERENCES demographicInformation (citizenId),
	CONSTRAINT	fk_immunizationRecord2	FOREIGN KEY (vaccineId) REFERENCES vaccineDictionary (vaccineId),

	CONSTRAINT chk_iFoundingSource CHECK (iFoundingSource='F' OR iFoundingSource='S' OR iFoundingSource='P')
);

--part 3: disease

CREATE TABLE diseaseDictionary
(
	diseaseTypeId		INTEGER			NOT NULL,
	diseaseName			VARCHAR(100)	NOT NULL,
	diseaseDescription	TEXT,
	
	CONSTRAINT	pk_diseaseDictionary	PRIMARY KEY (diseaseTypeId)
);

CREATE TABLE symptomDictionary
(
	symptomId			INTEGER			NOT NULL,
	symptomName			VARCHAR(100)	NOT NULL,
	symptomDescription	TEXT,
	
	CONSTRAINT	pk_symptomDictionary	PRIMARY KEY (symptomId)
);

CREATE TABLE disease
(
	diseaseId			INTEGER			NOT NULL,
	diseaseTypeId		INTEGER			NOT NULL,

	CONSTRAINT	pk_disease	PRIMARY KEY (diseaseId),
	CONSTRAINT	fk_disease  FOREIGN KEY (diseaseTypeId) REFERENCES diseaseDictionary (diseaseTypeId)
);

CREATE TABLE diseaseSymptom
(
	diseaseId			INTEGER		NOT NULL,
	symptomId			INTEGER		NOT NULL,

	CONSTRAINT	pk_diseaseSymptom	PRIMARY KEY (diseaseId,symptomId),
	CONSTRAINT	fk_diseaseSymptom1	FOREIGN KEY (diseaseId) REFERENCES disease (diseaseId),
	CONSTRAINT	fk_diseaseSymptom2	FOREIGN KEY (symptomId) REFERENCES symptomDictionary (symptomId)
);

--part 4: diagnose

CREATE TABLE diagnosedDisease
(
	citizenId INTEGER NOT NULL,
	diseaseId INTEGER NOT NULL,
	dateDiagnosed DATETIME NOT NULL DEFAULT GETDATE(),
	dClinicName VARCHAR (80) NOT NULL,
	diagnoseCost DECIMAL NOT NULL,
	dFoundingSource VARCHAR (1) NOT NULL,

	CONSTRAINT pk_diagnosedDisease PRIMARY KEY (citizenId, diseaseId, dateDiagnosed),
	CONSTRAINT fk_diagnosedDisease1 FOREIGN KEY (citizenId) REFERENCES demographicInformation (citizenId),
	CONSTRAINT fk_diagnosedDisease2 FOREIGN KEY (diseaseId) REFERENCES disease (diseaseId),

	CONSTRAINT chk_DFoundingSource CHECK (dFoundingSource='F' OR dFoundingSource='S' OR dFoundingSource='P'),
);

--part 5: treatment

CREATE TABLE medicineDictionary
(
	medicineId			INTEGER				NOT NULL,
	medicineName		VARCHAR(100)		NOT NULL,
	medicineDescription	TEXT,
	
	CONSTRAINT		pk_medicineDictionary		PRIMARY KEY (medicineId)
);

CREATE TABLE surgeryDictionary
(
	surgeryId			INTEGER			NOT NULL,
	surgeryName			VARCHAR(100)	NOT NULL,
	surgeryDescription	TEXT,
	
	CONSTRAINT		pk_surgeryDictionary		PRIMARY KEY (surgeryId)
);

CREATE TABLE treatment
(
	treatmentId			INTEGER		NOT NULL,
	medicineId			INTEGER,		
	surgeryId			INTEGER,		

	CONSTRAINT	pk_treatment	PRIMARY KEY (treatmentId),
	CONSTRAINT	fk_treatment1	FOREIGN KEY (medicineId) REFERENCES medicineDictionary (medicineId),
	CONSTRAINT	fk_treatment2	FOREIGN KEY (surgeryId) REFERENCES surgeryDictionary (surgeryId)
);

CREATE TABLE diagnoseTreatment
(
	citizenId			INTEGER			NOT NULL,
	diseaseId			INTEGER			NOT NULL,
	dateDiagnosed		DATETIME		NOT NULL,
	treatmentId			INTEGER			NOT NULL,		
	tHospitalName		VARCHAR(80)		NOT NULL,
	treatmentCost		DECIMAL			NOT NULL,
	treatmentResult		TEXT,
	tFoundingSource		VARCHAR(1)		NOT NULL,
	
	CONSTRAINT	pk_diagnoseTreatment	PRIMARY KEY (citizenId, diseaseId, dateDiagnosed, treatmentId),
	CONSTRAINT	fk_diagnoseTreatment1	FOREIGN KEY (citizenId, diseaseId, dateDiagnosed) REFERENCES diagnosedDisease (citizenId, diseaseId, dateDiagnosed),
	CONSTRAINT	fk_diagnoseTreatment2	FOREIGN KEY (treatmentId) REFERENCES treatment (treatmentId),

	CONSTRAINT chk_tFoundingSource CHECK (tFoundingSource='F' OR tFoundingSource='S' OR tFoundingSource='P'),
);

--insert values
--part 1: basic information
INSERT INTO demographicInformation (citizenId, firstName, middleName, lastName, gender, maritalStatus, ethnicity, dateOfBirth)
	VALUES (1, 'Mack', 'Meng', 'Wang', 'M', 'Married', 'Asian', '1990-05-15'),
	(2, 'Hiba', 'Louise', 'Blackburn', 'F', 'Widowed', 'Pacific Islander', '1993-06-16'),
	(3, 'Marta', 'Rose', 'Jennings', 'F', 'Married', 'White', '1986-11-09'),
	(4, 'Yosef', 'James', 'Bender', 'M', 'Divorced', 'White', '1966-08-02'),
	(5, 'Ernest', 'William', 'Aguilar', 'M', 'Single', 'African American', '1989-04-22'),
	(6, 'Lily', 'Mae', 'Sweeney', 'F', 'Single', 'Native American', '1977-02-27');
INSERT INTO demographicInformation (citizenId, firstName, lastName, gender, maritalStatus, ethnicity, dateOfBirth)
	VALUES (7, 'Joe', 'Johnson', 'M', 'Married', 'White', '1963-08-01'),
	(8, 'Ibrar', 'Christian', 'M', 'Divorced', 'Native Hawaiian', '1999-09-05'),
	(9, 'Zunaira', 'Hudson', 'F', 'Widowed', 'Asian', '2001-12-17');

INSERT INTO geographicInformation (citizenId, startDate, cStreetNo, cStreetName, cCity, cState, cZipCode)
VALUES (1, '1990-05-15', '410', 'Comstock Ave', 'Syracuse', 'New York', '13210'),
(2, '1993-06-16', '112', 'Lafayette Rd', 'Syracuse', 'New York', '13205'),
(3, '1986-11-09', '17', 'James St', 'Syracuse', 'New York', '13210'),
(4, '1966-08-02', '4301', 'Nottingham Rd', 'Syracuse', 'New York', '13244'),
(5, '1989-04-22', '3', 'Ostrom Ave', 'Syracuse', 'New York', '13225'),
(6, '1977-02-27', '137', 'Sumner Ave', 'Syracuse', 'New York', '13210'),
(7, '1963-08-01', '4248', 'Nottingham Rd', 'Syracuse', 'New York', '13244'),
(8, '1999-09-05', '7116', 'Lafayette Rd', 'Syracuse', 'New York', '13205'),
(9, '2001-12-17', '4237', 'Nottingham Rd', 'Syracuse', 'New York', '13244'),
(2, '2000-08-23', '415', 'Comstock Ave', 'Syracuse', 'New York', '13210'),
(4, '1999-05-17', '433', 'Comstock Ave', 'Syracuse', 'New York', '13210'),
(5, '2013-01-13', '23', 'James St', 'Syracuse', 'New York', '13210'),
(8, '2018-03-09', '44', 'Ostrom Ave', 'Syracuse', 'New York', '13225');

INSERT INTO birthInformation (childCitizenId, bStreetNo, bStreetName, bCity, bState, bZipCode)
VALUES (1, '410', 'Comstock Ave', 'Syracuse', 'New York', '13210'),
(2, '112', 'Lafayette Rd', 'Syracuse', 'New York', '13205'),
(3, '17', 'James St', 'Syracuse', 'New York', '13210'),
(4, '4301', 'Nottingham Rd', 'Syracuse', 'New York', '13244'),
(5, '3', 'Ostrom Ave', 'Syracuse', 'New York', '13225'),
(6, '137', 'Sumner Ave', 'Syracuse', 'New York', '13210'),
(7, '4248', 'Nottingham Rd', 'Syracuse', 'New York', '13244'),
(8, '7116', 'Lafayette Rd', 'Syracuse', 'New York', '13205'),
(9, '4237', 'Nottingham Rd', 'Syracuse', 'New York', '13244');

--part 2: immunization
INSERT INTO vaccineDictionary (vaccineId, vaccineName, vaccineDescription)
VALUES (101, 'Tetanus', 'A serious bacterial infection that causes painful muscle spasms and can lead to death'),
(102, 'Hepatitis', 'An inflammation of the liver'),
(103, 'Human Papillomavirus', 'An infection that causes warts in various parts of the body, depending on the strain'),
(104, 'Influenza', 'A common viral infection, flu attack of the lungs, nose, and throat'),
(105, 'Hib', 'Haemophilus influenzae type b'),
(106, 'Mumps', 'A viral infection that affects the salivary glands');

INSERT INTO immunizationRecord (citizenId, vaccineId, dateAdministered, iClinicName, immunizationCost, iFoundingSource)
VALUES (1, 101, '1990-05-15', 'SyrImmue', 50, 'F'),
(1, 102, '1990-05-15', 'SyrImmue', 150, 'F'),
(1, 103, '1990-05-15', 'SyrImmue', 75, 'S'),
(1, 104, '1990-05-15', 'SyrImmue', 50, 'P'),
(1, 105, '1990-05-15', 'SyrImmue', 100, 'S'),
(1, 106, '1990-05-15', 'SyrImmue', 20, 'P'),
(2, 101, '1993-06-16', 'SyrImmue', 50, 'F'),
(2, 102, '1993-06-16', 'SyrImmue', 125, 'F'),
(2, 105, '1993-06-16', 'SyrImmue', 120, 'F'),
(2, 106, '1993-06-16', 'SyrImmue', 25, 'P'),
(3, 101, '1986-11-09', 'USImmue', 35, 'F'),
(3, 102, '1986-11-09', 'USImmue', 45, 'F'),
(3, 103, '1986-11-09', 'USImmue', 60, 'F'),
(3, 105, '1986-11-09', 'USImmue', 20, 'F'),
(3, 106, '1990-11-09', 'USImmue', 25, 'F'),
(4, 101, '1966-08-02', 'USImmue', 50, 'S'),
(4, 102, '2000-08-02', 'USImmue', 50, 'S'),
(4, 103, '1966-08-02', 'USImmue', 50, 'S'),
(4, 104, '1966-08-02', 'USImmue', 50, 'S'),
(4, 105, '2000-08-02', 'USImmue', 50, 'S'),
(4, 106, '1966-08-02', 'USImmue', 50, 'S'),
(5, 101, '1989-04-22', 'USImmue', 100, 'P'),
(5, 102, '1989-04-22', 'USImmue', 90, 'P'),
(5, 103, '1989-04-22', 'USImmue', 50, 'P'),
(5, 105, '1989-04-22', 'USImmue', 80, 'P'),
(5, 106, '1989-04-22', 'USImmue', 80, 'P'),
(6, 101, '1977-02-27', 'SyrImmue', 50, 'F'),
(6, 102, '2000-02-27', 'SyrImmue', 50, 'P'),
(6, 103, '1977-02-27', 'SyrImmue', 150, 'S'),
(6, 105, '1977-02-27', 'SyrImmue', 150, 'S'),
(6, 106, '1977-02-27', 'SyrImmue', 50, 'F'),
(7, 101, '1963-08-01', 'SyrImmue', 250, 'F'),
(7, 102, '1963-08-01', 'SyrImmue', 50, 'P'),
(7, 103, '1963-08-01', 'SyrImmue', 40, 'P'),
(7, 105, '1963-08-01', 'SyrImmue', 150, 'P'),
(7, 106, '2000-08-01', 'SyrImmue', 30, 'F'),
(8, 101, '1999-09-05', 'USImmue', 350, 'F'),
(8, 102, '1999-09-05', 'USImmue', 150, 'P'),
(8, 103, '1999-09-05', 'USImmue', 50, 'P'),
(8, 104, '1999-09-05', 'USImmue', 50, 'P'),
(8, 105, '1999-09-05', 'USImmue', 150, 'F'),
(8, 106, '1999-09-05', 'USImmue', 50, 'S'),
(9, 101, '2001-12-17', 'USImmue', 50, 'S'),
(9, 102, '2001-12-17', 'USImmue', 120, 'S'),
(9, 104, '2001-12-17', 'USImmue', 80, 'F'),
(9, 105, '2001-12-17', 'USImmue', 90, 'P'),
(9, 106, '2001-12-17', 'USImmue', 20, 'P');

--part 3: disease
INSERT INTO diseaseDictionary (diseaseTypeId, diseaseName, diseaseDescription)
VALUES (1001,'atherosclerotic disease','a hardening and narrowing of arteries'),
(1002,'heart arrhythmias','improper beating of the heart, whether irregular, too fast, or too slow'),
(1003,'dilated cardiomyopathy','a disease of the heart muscle, usually starting in heart main pumping chamber (left ventricle)'),
(1004,'valvular heart disease','Valvular heart disease is characterized by damage to or a defect in one of the four heart valves'),
(1005,'heart defects','an abnormality in the heart that develops before birth'),
(1006,'meningitis','an inflammation of the lining around the brain or spinal cord'),
(1007,'hydrocephalus','an abnormally increased amount of cerebrospinal (brain) fluid inside the skull'),
(1008,'pseudotumor cerebri','increased pressure inside the skull with no apparent cause'),
(1009,'liver cancer','a type of cancer that starts in the liver');

INSERT INTO symptomDictionary (symptomId, symptomName, symptomDescription)
VALUES (2001,'chest pain',''),
(2002,'shortness of breath',''),
(2003,'fluttering in chest',''),
(2004,'bradycardia','Slow heartbeat'),
(2005,'leg muscle infection', 'swelling of the legs, ankles and feet'),
(2006,'cyanosis','pale gray or blue skin color '),
(2007,'headache',''),
(2008,'jaundice','Yellow discoloration of your skin and the whites of your eyes'),
(2009,'upper abdominal pain','');

INSERT INTO disease (diseaseId, diseaseTypeId)
VALUES (6001,1001),
(6002,1001),
(6003,1006),
(6004,1002),
(6005,1003),
(6006,1004),
(6007,1005),
(6008,1008),
(6009,1009);

INSERT INTO diseaseSymptom (diseaseId, symptomId)
VALUES (6001,2001),
(6002,2002),
(6003,2003),
(6004,2004),
(6005,2005),
(6006,2002),
(6007,2006),
(6008,2007),
(6009,2008);

--part 4: diagnose
INSERT INTO diagnosedDisease (citizenId, diseaseId, dClinicName, diagnoseCost, dFoundingSource)
VALUES (1, 6003, 'SyrImmue', 200, 'S'),
(1, 6004, 'SyrImmue', 80, 'F'),
(1, 6005, 'SyrImmue', 150, 'S'),
(1, 6007, 'USImmue', 20, 'P'),
(2,6004,'SyrImmue',55,'P'),
(2,6006,'SyrImmue',40,'S'),
(2,6001,'SyrImmue',15,'P'),
(3,6009,'USImmue',150,'P'),
(4,6002,'SyrImmue',60,'S'),
(4,6001,'SyrImmue',60,'S'),
(4,6008,'USImmue',60,'F'),
(4,6007,'USImmue',60,'S'),
(6,6003,'SyrImmue',710,'F'),
(7,6008,'USImmue',230,'F'),
(7,6004,'USImmue',130,'P'),
(9, 6007, 'USImmue', 225, 'P'),
(9, 6005, 'SyrImmue', 525, 'P');

INSERT INTO diagnosedDisease (citizenId, diseaseId, dateDiagnosed, dClinicName, diagnoseCost, dFoundingSource)
VALUES (1, 6001, '2018-09-07 21:37:48.111', 'SyrImmue', 180, 'P'),
(2,6002,'2017-05-05 10:56:56.876','SyrImmue',55,'P'),
(3,6003,'1998-12-15 16:55:33.345','USImmue',170,'P'),
(4,6004,'2019-08-13 21:51:12.333','SyrImmue',160,'S'),
(5,6005,'2012-10-16 22:24:25.776','USImmue',150,'P'),
(6,6006,'2020-06-22 08:33:21.823','SyrImmue',70,'F'),
(7,6007,'2017-09-19 07:07:07.886','USImmue',220,'F'),
(8,6008,'2014-07-31 18:45:47.234','SyrImmue',94,'P'),
(9,6009,'2008-04-27 14:14:14.624','USImmue',111,'S');

--part 5: treatment
INSERT INTO medicineDictionary (medicineId, medicineName, medicineDescription)
VALUES (3001,'atorvastatin ','statins'),
(3002,'lovastatin','statins'),
(3003,'amiodarone','This medication is used to treat certain types of serious (possibly fatal) irregular heartbeat (such as persistent ventricular fibrillation/tachycardia). It is used to restore normal heart rhythm and maintain a regular, steady heartbeat.'),
(3004,'flecainide','It is used to restore normal heart rhythm and maintain a regular, steady heartbeat. It is also used to prevent certain types of irregular heartbeat from returning (such as atrial fibrillation).'),
(3005,'digoxin','Digoxin helps make the heart beat stronger and with a more regular rhythm.'),
(3006,'warfarin','a prescription medication used to prevent harmful blood clots from forming or growing larger'),
(3007,'acetazolamide','a glaucoma drug'),
(3008,'cabozantinib','a medication used to treat medullary thyroid cancer and a second line treatment for renal cell carcinoma among others'),
(3009,'prednisone','a corticosteroid. It prevents the release of substances in the body that cause inflammation. It also suppresses the immune system');

INSERT INTO surgeryDictionary (surgeryId, surgeryName, surgeryDescription)
VALUES (4001,'appendectomy','an appendectomy is removing the appendix'),
(4002,'breast biopsy','a test used to help diagnose cancer. The surgeon removes a small sample of tissue or cells'),
(4003,'cataract surgery','Cataracts cloud the normally clear lens of the eyes.'),
(4004,'carotid endarterectomy','a surgery to remove blockage from carotid arteries'),
(4005,'coronary artery bypass grafting','a procedure to improve poor blood flow to the heart'),
(4006,'dilation and curettage','a minor surgery where the cervix is expanded (dilated)'),
(4007,'partial colectomy','A partial colectomy is removing part of the large intestine (colon).'),
(4008,'prostatectom','A prostatectomy is removing all or part of the prostate gland.'),
(4009,'tonsillectomy','A tonsillectomy is removing of one or both tonsils.');

INSERT INTO treatment (treatmentId, medicineId, surgeryId)
VALUES (5001,3001,4004),
(5002,3002,4005);
INSERT INTO treatment (treatmentId, medicineId)
VALUES (5003,3003),
(5004,3004),
(5005,3005),
(5006,3006),
(5007,3005),
(5008,3007),
(5009,3008);

INSERT INTO diagnoseTreatment (citizenId, diseaseId, dateDiagnosed, treatmentId, tHospitalName, treatmentCost, treatmentResult, tFoundingSource)
VALUES (1,6001,'2018-09-07 21:37:48.111','5001','Aultman Hospital',120000,'','P'),
(2,6002,'2017-05-05 10:56:56.876','5002','Upstate Health Care Center',200000,'','P'),
(3,6003,'1998-12-15 16:55:33.345','5003','Aultman Hospital',178,'','P'),
(4,6004,'2019-08-13 21:51:12.333','5004','Upstate Health Care Center',166,'','S'),
(5,6005,'2012-10-16 22:24:25.776','5005','Crouse Hospital',150,'','P'),
(6,6006,'2020-06-22 08:33:21.823','5006','Upstate Health Care Center',150,'','F'),
(7,6007,'2017-09-19 07:07:07.886','5007','Upstate Health Care Center',333,'','F'),
(8,6008,'2014-07-31 18:45:47.234','5008','Crouse Hospital',94,'','P'),
(9,6009,'2008-04-27 14:14:14.624','5009','Aultman Hospital',111,'','S');

--select tables
--part 1: basic information
SELECT * FROM	demographicInformation
SELECT * FROM	geographicInformation
SELECT * FROM	birthInformation

--part 2: immunization
SELECT * FROM	vaccineDictionary
SELECT * FROM	immunizationRecord

--part 3: disease
SELECT * FROM	diseaseDictionary
SELECT * FROM	symptomDictionary
SELECT * FROM	disease
SELECT * FROM	diseaseSymptom

--part 4: diagnose
SELECT * FROM	diagnosedDisease

--part 5: treatment
SELECT * FROM	medicineDictionary
SELECT * FROM	surgeryDictionary
SELECT * FROM	treatment
SELECT * FROM	diagnoseTreatment

--query questions:
--1. Query individual vaccination history (example Mack Wang's immunization history).
SELECT d.citizenId, d.firstName, d.lastName, v.vaccineName, i.dateAdministered, i.immunizationCost, i.iClinicName
FROM demographicInformation d
JOIN immunizationRecord i
ON d.citizenId=i.citizenId
JOIN vaccineDictionary v
ON i.vaccineId=v.vaccineId
WHERE d.firstName='Mack' AND d.lastName='Wang'

CREATE VIEW vaccination_history_Mack_Wang AS (
	SELECT d.citizenId, d.firstName, d.lastName, v.vaccineName, i.dateAdministered, i.immunizationCost, i.iClinicName
	FROM demographicInformation d
	JOIN immunizationRecord i
	ON d.citizenId=i.citizenId
	JOIN vaccineDictionary v
	ON i.vaccineId=v.vaccineId
	WHERE d.firstName='Mack' AND d.lastName='Wang'
);

--2. What part of the population has effective immunization against Tetanus and Influenza, and when were they vaccinated?
SELECT d.citizenId, d.firstName, d.lastName, v.vaccineName, i.dateAdministered
FROM immunizationRecord i
JOIN demographicInformation d
ON i.citizenId=d.citizenId
JOIN vaccineDictionary v
ON i.vaccineId=v.vaccineId
WHERE i.vaccineId=101 OR i.vaccineId=104
ORDER BY i.vaccineId

CREATE VIEW vaccination_history_tetanus_influenza AS (
	SELECT d.citizenId, d.firstName, d.lastName, v.vaccineName, i.dateAdministered
	FROM immunizationRecord i
	JOIN demographicInformation d
	ON i.citizenId=d.citizenId
	JOIN vaccineDictionary v
	ON i.vaccineId=v.vaccineId
	WHERE i.vaccineId=101 OR i.vaccineId=104
);

--3. What are common symptoms for atherosclerotic disease?
SELECT dd.dClinicName ,dd.dateDiagnosed, ddc.diseaseName, sdc.symptomName, sdc.symptomDescription, ddc.diseaseDescription
FROM diagnosedDisease dd
JOIN disease d
ON dd.diseaseId=d.diseaseId
JOIN diseaseSymptom ds
ON d.diseaseId=ds.diseaseId
JOIN diseaseDictionary ddc
ON d.diseaseTypeId=ddc.diseaseTypeId
JOIN symptomDictionary sdc
ON ds.symptomId=sdc.symptomId
WHERE ddc.diseaseName='atherosclerotic disease'

-- important note, this view protects patient information
CREATE VIEW symptom_atherosclerotic_disease AS (
	SELECT dd.dClinicName ,dd.dateDiagnosed, ddc.diseaseName, sdc.symptomName, sdc.symptomDescription, ddc.diseaseDescription
	FROM diagnosedDisease dd
	JOIN disease d
	ON dd.diseaseId=d.diseaseId
	JOIN diseaseSymptom ds
	ON d.diseaseId=ds.diseaseId
	JOIN diseaseDictionary ddc
	ON d.diseaseTypeId=ddc.diseaseTypeId
	JOIN symptomDictionary sdc
	ON ds.symptomId=sdc.symptomId
	WHERE ddc.diseaseName='atherosclerotic disease'
);

--4. What diseases are appearing on Nottingham Rd?
SELECT dd.dClinicName, dd.dateDiagnosed, ddc.diseaseName, ddc.diseaseDescription
FROM demographicInformation d
JOIN geographicInformation g
ON d.citizenId=g.citizenId
JOIN diagnosedDisease dd
ON d.citizenId=dd.citizenId
JOIN disease di
ON dd.diseaseId=di.diseaseId
JOIN diseaseDictionary ddc
ON di.diseaseTypeId=ddc.diseaseTypeId
WHERE g.cStreetName='Nottingham Rd'

CREATE VIEW diagnoses_Nottingham_Rd AS (
	SELECT dd.dClinicName, dd.dateDiagnosed, ddc.diseaseName, ddc.diseaseDescription
	FROM demographicInformation d
	JOIN geographicInformation g
	ON d.citizenId=g.citizenId
	JOIN diagnosedDisease dd
	ON d.citizenId=dd.citizenId
	JOIN disease di
	ON dd.diseaseId=di.diseaseId
	JOIN diseaseDictionary ddc
	ON di.diseaseTypeId=ddc.diseaseTypeId
	WHERE g.cStreetName='Nottingham Rd'
);

-- 5. Where did federal government funding go in diagnose and treatment?
SELECT d.citizenId, dd.diagnoseCost, dt.treatmentCost, dd.dateDiagnosed
FROM demographicInformation d
FULL OUTER JOIN diagnosedDisease dd
ON d.citizenId=dd.citizenId
FULL OUTER JOIN diagnoseTreatment dt
ON dd.citizenId=dt.citizenId AND dd.diseaseId=dt.diseaseId AND dd.dateDiagnosed=dt.dateDiagnosed
WHERE dFoundingSource='F' OR tFoundingSource='F'

CREATE VIEW federal_funding_diagnose_treatment AS (
	SELECT d.citizenId, dd.diagnoseCost, dt.treatmentCost, dd.dateDiagnosed
	FROM demographicInformation d
	FULL OUTER JOIN diagnosedDisease dd
	ON d.citizenId=dd.citizenId
	FULL OUTER JOIN diagnoseTreatment dt
	ON dd.citizenId=dt.citizenId AND dd.diseaseId=dt.diseaseId AND dd.dateDiagnosed=dt.dateDiagnosed
	WHERE dFoundingSource='F' OR tFoundingSource='F'
);

--select views
SELECT * FROM	vaccination_history_Mack_Wang
SELECT * FROM	vaccination_history_tetanus_influenza
SELECT * FROM	symptom_atherosclerotic_disease
SELECT * FROM	diagnoses_Nottingham_Rd
SELECT * FROM	federal_funding_diagnose_treatment

--drop views
DROP VIEW vaccination_history_Mack_Wang
DROP VIEW vaccination_history_tetanus_influenza
DROP VIEW symptom_atherosclerotic_disease
DROP VIEW diagnoses_Nottingham_Rd
DROP VIEW federal_funding_diagnose_treatment

--drop tables
--part 5: treatment
DROP TABLE	diagnoseTreatment
DROP TABLE	treatment
DROP TABLE	surgeryDictionary
DROP TABLE	medicineDictionary

--part 4: diagnose
DROP TABLE	diagnosedDisease

--part 3: disease
DROP TABLE	diseaseSymptom
DROP TABLE	disease
DROP TABLE	symptomDictionary
DROP TABLE	diseaseDictionary

--part 2: immunization
DROP TABLE	immunizationRecord
DROP TABLE	vaccineDictionary

--part 1: basic information
DROP TABLE	birthInformation
DROP TABLE	geographicInformation
DROP TABLE	demographicInformation
