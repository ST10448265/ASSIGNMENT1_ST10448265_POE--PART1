/*
    RaceDay - Part 1 SQL Database Script
    SQL Server / SSMS
*/

IF DB_ID('RaceDayDb') IS NULL
    CREATE DATABASE RaceDayDb;
GO

USE RaceDayDb;
GO

-- Remove existing tables so the script can be tested again
DROP TABLE IF EXISTS dbo.WeatherSnapshots;
DROP TABLE IF EXISTS dbo.EventRoutes;
DROP TABLE IF EXISTS dbo.Results;
DROP TABLE IF EXISTS dbo.Enrolments;
DROP TABLE IF EXISTS dbo.Categories;
DROP TABLE IF EXISTS dbo.Events;
DROP TABLE IF EXISTS dbo.Users;
GO

/* =========================
   USERS
   ========================= */

CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Users PRIMARY KEY,

    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,

    Email NVARCHAR(255) NOT NULL
        CONSTRAINT UQ_Users_Email UNIQUE,

    PasswordHash NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(30) NULL,

    Role NVARCHAR(20) NOT NULL
        CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser', 'Participant')),

    CreatedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_Users_CreatedAt
        DEFAULT SYSUTCDATETIME()
);
GO


/* =========================
   EVENTS
   ========================= */

CREATE TABLE dbo.Events (
    EventId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Events PRIMARY KEY,

    OrganiserId INT NOT NULL,

    Name NVARCHAR(120) NOT NULL,
    Description NVARCHAR(1000) NULL,
    EventDate DATE NOT NULL,
    Location NVARCHAR(150) NOT NULL,

    EventType NVARCHAR(20) NOT NULL
        CONSTRAINT CK_Events_EventType
        CHECK (EventType IN ('Running', 'Walking', 'Cycling')),

    Status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Events_Status
        DEFAULT 'Upcoming',

    CreatedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_Events_CreatedAt
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Events_Organiser
        FOREIGN KEY (OrganiserId)
        REFERENCES dbo.Users(UserId)
);
GO


/* =========================
   CATEGORIES
   ========================= */

CREATE TABLE dbo.Categories (
    CategoryId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Categories PRIMARY KEY,

    EventId INT NOT NULL,

    Name NVARCHAR(80) NOT NULL,

    DistanceKm DECIMAL(5,2) NOT NULL
        CONSTRAINT CK_Categories_Distance
        CHECK (DistanceKm > 0),

    MaxParticipants INT NOT NULL
        CONSTRAINT CK_Categories_MaxParticipants
        CHECK (MaxParticipants > 0),

    EntryFee DECIMAL(10,2) NOT NULL
        CONSTRAINT CK_Categories_EntryFee
        CHECK (EntryFee >= 0),

    MinAge INT NULL,

    MaxAge INT NULL,

    CONSTRAINT FK_Categories_Event
        FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId)
        ON DELETE CASCADE,

    CONSTRAINT UQ_Categories_Event_Name
        UNIQUE (EventId, Name),

    CONSTRAINT UQ_Categories_Event_Category
        UNIQUE (EventId, CategoryId),

    CONSTRAINT CK_Categories_AgeRange
        CHECK (
            MaxAge IS NULL
            OR MinAge IS NULL
            OR MaxAge >= MinAge
        )
);
GO


/* =========================
   ENROLMENTS
   ========================= */

CREATE TABLE dbo.Enrolments (
    EnrolmentId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Enrolments PRIMARY KEY,

    ParticipantId INT NOT NULL,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,

    EnrolmentDate DATETIME2(0) NOT NULL
        CONSTRAINT DF_Enrolments_Date
        DEFAULT SYSUTCDATETIME(),

    Status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Enrolments_Status
        DEFAULT 'Confirmed',

    BibNumber NVARCHAR(20) NULL,

    CONSTRAINT CK_Enrolments_Status
        CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),

    CONSTRAINT FK_Enrolments_Participant
        FOREIGN KEY (ParticipantId)
        REFERENCES dbo.Users(UserId),

    CONSTRAINT FK_Enrolments_Event
        FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId),

    CONSTRAINT FK_Enrolments_Category
        FOREIGN KEY (CategoryId)
        REFERENCES dbo.Categories(CategoryId),

    CONSTRAINT FK_Enrolments_Event_Category
        FOREIGN KEY (EventId, CategoryId)
        REFERENCES dbo.Categories(EventId, CategoryId),

    CONSTRAINT UQ_Enrolments_Participant_Event_Category
        UNIQUE (ParticipantId, EventId, CategoryId)
);

CREATE UNIQUE INDEX UX_Enrolments_BibNumber
ON dbo.Enrolments(BibNumber)
WHERE BibNumber IS NOT NULL;
GO


/* =========================
   RESULTS
   ========================= */

CREATE TABLE dbo.Results (
    ResultId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Results PRIMARY KEY,

    EnrolmentId INT NOT NULL
        CONSTRAINT UQ_Results_Enrolment UNIQUE,

    FinishTime TIME(0) NULL,

    Position INT NULL
        CONSTRAINT CK_Results_Position
        CHECK (Position IS NULL OR Position > 0),

    ResultStatus NVARCHAR(20) NOT NULL
        CONSTRAINT CK_Results_Status
        CHECK (ResultStatus IN ('Finished', 'DNF', 'DNS', 'DSQ')),

    RecordedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_Results_RecordedAt
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Results_Enrolment
        FOREIGN KEY (EnrolmentId)
        REFERENCES dbo.Enrolments(EnrolmentId)
        ON DELETE CASCADE
);
GO


/* =========================
   EVENT ROUTES
   ========================= */

CREATE TABLE dbo.EventRoutes (
    RouteId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_EventRoutes PRIMARY KEY,

    EventId INT NOT NULL
        CONSTRAINT UQ_EventRoutes_Event UNIQUE,

    RouteName NVARCHAR(120) NOT NULL,

    DistanceKm DECIMAL(5,2) NOT NULL
        CONSTRAINT CK_EventRoutes_Distance
        CHECK (DistanceKm > 0),

    SurfaceType NVARCHAR(50) NOT NULL,

    MapUrl NVARCHAR(500) NULL,

    ElevationGainM INT NULL
        CONSTRAINT CK_EventRoutes_Elevation
        CHECK (ElevationGainM IS NULL OR ElevationGainM >= 0),

    CONSTRAINT FK_EventRoutes_Event
        FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId)
        ON DELETE CASCADE
);
GO


/* =========================
   WEATHER
   ========================= */

CREATE TABLE dbo.WeatherSnapshots (
    WeatherId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_WeatherSnapshots PRIMARY KEY,

    EventId INT NOT NULL,

    ForecastDate DATE NOT NULL,

    TemperatureC DECIMAL(5,2) NOT NULL,

    Condition NVARCHAR(80) NOT NULL,

    WindSpeedKmh DECIMAL(6,2) NOT NULL
        CONSTRAINT CK_Weather_Wind
        CHECK (WindSpeedKmh >= 0),

    RetrievedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_Weather_RetrievedAt
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Weather_Event
        FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId)
        ON DELETE CASCADE
);
GO


/* =========================
   SAMPLE USERS
   ========================= */

INSERT INTO dbo.Users
    (FirstName, LastName, Email, PasswordHash, Phone, Role)
VALUES
    ('Thabo', 'Mokoena',
     'thabo.organiser@example.com',
     'DEMO_HASH_THABO',
     '0820000001',
     'Organiser'),

    ('Lerato', 'Naidoo',
     'lerato.organiser@example.com',
     'DEMO_HASH_LERATO',
     '0820000002',
     'Organiser'),

    ('Aisha', 'Khumalo',
     'aisha.participant@example.com',
     'DEMO_HASH_AISHA',
     '0820000003',
     'Participant'),

    ('Daniel', 'Jacobs',
     'daniel.participant@example.com',
     'DEMO_HASH_DANIEL',
     '0820000004',
     'Participant');
GO


/* =========================
   SAMPLE EVENTS
   ========================= */

INSERT INTO dbo.Events
    (OrganiserId, Name, Description, EventDate,
     Location, EventType, Status)
VALUES
    (1,
     'Johannesburg City Run',
     'Road running event through central Johannesburg.',
     '2026-10-18',
     'Johannesburg, Gauteng',
     'Running',
     'Upcoming'),

    (1,
     'Pretoria Community Walk',
     'Family-friendly community walking event.',
     '2026-11-08',
     'Pretoria, Gauteng',
     'Walking',
     'Upcoming'),

    (2,
     'Cape Coast Cycle Challenge',
     'Road cycling event along the Cape coast.',
     '2026-11-22',
     'Cape Town, Western Cape',
     'Cycling',
     'Upcoming');
GO


/* =========================
   SAMPLE CATEGORIES
   ========================= */

INSERT INTO dbo.Categories
    (EventId, Name, DistanceKm,
     MaxParticipants, EntryFee, MinAge, MaxAge)
VALUES

    (1, '10 km Open',
     10.00, 500, 180.00, 16, NULL),

    (1, '21 km Half Marathon',
     21.10, 300, 280.00, 18, NULL),

    (2, '5 km Family Walk',
     5.00, 400, 80.00, 10, NULL),

    (2, '10 km Challenge Walk',
     10.00, 250, 120.00, 16, NULL),

    (3, '40 km Social Ride',
     40.00, 350, 220.00, 16, NULL),

    (3, '80 km Challenge Ride',
     80.00, 250, 350.00, 18, NULL);
GO


/* =========================
   SAMPLE ENROLMENTS
   ========================= */

INSERT INTO dbo.Enrolments
    (ParticipantId, EventId, CategoryId,
     Status, BibNumber)
VALUES

    (3, 1, 1,
     'Confirmed', 'JR001'),

    (4, 1, 2,
     'Confirmed', 'JR002'),

    (3, 2, 3,
     'Confirmed', 'PW001'),

    (4, 3, 5,
     'Confirmed', 'CC001');
GO


/* =========================
   SAMPLE RESULTS
   ========================= */

INSERT INTO dbo.Results
    (EnrolmentId, FinishTime,
     Position, ResultStatus)
VALUES

    (1, '00:58:42',
     12, 'Finished'),

    (2, '01:52:10',
     8, 'Finished'),

    (3, NULL,
     NULL, 'DNS');
GO


/* =========================
   SAMPLE ROUTES
   ========================= */

INSERT INTO dbo.EventRoutes
    (EventId, RouteName, DistanceKm,
     SurfaceType, MapUrl, ElevationGainM)
VALUES

    (1,
     'Joburg Central Loop',
     10.00,
     'Road',
     'https://example.com/routes/joburg-central',
     120),

    (2,
     'Pretoria Family Route',
     5.00,
     'Road and paved path',
     'https://example.com/routes/pretoria-family',
     55),

    (3,
     'Cape Coast Coastal Route',
     40.00,
     'Road',
     'https://example.com/routes/cape-coast',
     430);
GO


/* =========================
   SAMPLE WEATHER
   ========================= */

INSERT INTO dbo.WeatherSnapshots
    (EventId, ForecastDate, TemperatureC,
     Condition, WindSpeedKmh)
VALUES

    (1,
     '2026-10-18',
     21.50,
     'Partly cloudy',
     14.00),

    (2,
     '2026-11-08',
     23.00,
     'Sunny',
     10.00),

    (3,
     '2026-11-22',
     19.50,
     'Cloudy',
     22.00);
GO


/* =========================
   CHECK THE DATA
   ========================= */

SELECT * FROM dbo.Users;
SELECT * FROM dbo.Events;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Enrolments;
SELECT * FROM dbo.Results;
SELECT * FROM dbo.EventRoutes;
SELECT * FROM dbo.WeatherSnapshots;
GO