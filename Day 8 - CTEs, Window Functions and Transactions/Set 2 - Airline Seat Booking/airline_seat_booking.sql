CREATE DATABASE AirlineBookingDB;

USE AirlineBookingDB;

CREATE TABLE dbo.FlightSeats
(
    FlightID INT NOT NULL,
    SeatNo VARCHAR(5) NOT NULL,
    SeatStatus VARCHAR(20) NOT NULL
        CHECK (SeatStatus IN ('AVAILABLE', 'BOOKED')),
    CONSTRAINT PK_FlightSeats PRIMARY KEY (FlightID, SeatNo)
);

CREATE TABLE dbo.Bookings
(
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    FlightID INT NOT NULL,
    SeatNo VARCHAR(5) NOT NULL,
    PassengerName VARCHAR(100) NOT NULL,
    Fare DECIMAL(10,2) NOT NULL CHECK (Fare >= 0),
    BookedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_Bookings_Flight_Seat UNIQUE (FlightID, SeatNo),
    CONSTRAINT FK_Bookings_FlightSeats
        FOREIGN KEY (FlightID, SeatNo)
        REFERENCES dbo.FlightSeats (FlightID, SeatNo)
);

INSERT INTO dbo.FlightSeats (FlightID, SeatNo, SeatStatus)
VALUES
(501, '12A', 'AVAILABLE'),
(501, '12B', 'AVAILABLE'),
(501, '12C', 'AVAILABLE'),
(502, '03A', 'AVAILABLE'),
(502, '03B', 'AVAILABLE');
GO

CREATE OR ALTER PROCEDURE dbo.BookSeat
    @FlightID INT,
    @SeatNo VARCHAR(5),
    @PassengerName VARCHAR(100),
    @Fare DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.FlightSeats WITH (UPDLOCK, HOLDLOCK)
        SET SeatStatus = 'BOOKED'
        WHERE FlightID = @FlightID
          AND SeatNo = @SeatNo
          AND SeatStatus = 'AVAILABLE';

        IF @@ROWCOUNT <> 1
            THROW 50101, 'Seat does not exist or is already booked.', 1;

        INSERT INTO dbo.Bookings (FlightID, SeatNo, PassengerName, Fare)
        VALUES (@FlightID, @SeatNo, @PassengerName, @Fare);

        COMMIT TRANSACTION;
        PRINT 'Booking committed.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        PRINT CONCAT('Booking failed: ', ERROR_MESSAGE());
        THROW;
    END CATCH
END;
GO

EXEC dbo.BookSeat
    @FlightID = 501,
    @SeatNo = '12A',
    @PassengerName = 'Meera',
    @Fare = 8500.00;
GO

SELECT * FROM dbo.FlightSeats ORDER BY FlightID, SeatNo;
SELECT * FROM dbo.Bookings ORDER BY BookingID;
GO

/*
CONCURRENCY TEST
Reset one test seat before testing:
UPDATE dbo.FlightSeats SET SeatStatus = 'AVAILABLE'
WHERE FlightID = 501 AND SeatNo = '12B';
DELETE FROM dbo.Bookings WHERE FlightID = 501 AND SeatNo = '12B';

Open two SSMS windows. In each, execute the same procedure for 501 / 12B
but use different passenger names. Only one should commit. The second
request waits for the row lock and then sees that the seat is no longer
AVAILABLE, so it throws and rolls back.
*/



/* SECTION 2: ranking_report.sql */
/*
Passenger fare ranking and running revenue per flight.
*/

WITH PassengerFares AS
(
    SELECT
        BookingID,
        FlightID,
        SeatNo,
        PassengerName,
        Fare,
        RANK() OVER
        (
            PARTITION BY FlightID
            ORDER BY Fare DESC
        ) AS FareRank,
        DENSE_RANK() OVER
        (
            PARTITION BY FlightID
            ORDER BY Fare DESC
        ) AS DenseFareRank
    FROM dbo.Bookings
)
SELECT
    BookingID,
    FlightID,
    SeatNo,
    PassengerName,
    Fare,
    FareRank,
    DenseFareRank
FROM PassengerFares
ORDER BY FlightID, Fare DESC, PassengerName;
GO

WITH FlightRevenue AS
(
    SELECT
        BookingID,
        FlightID,
        SeatNo,
        PassengerName,
        Fare,
        SUM(Fare) OVER
        (
            PARTITION BY FlightID
            ORDER BY BookedAt, BookingID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningRevenue
    FROM dbo.Bookings
)
SELECT
    BookingID,
    FlightID,
    SeatNo,
    PassengerName,
    Fare,
    RunningRevenue
FROM FlightRevenue
ORDER BY FlightID, BookingID;
GO

/*
RANK example for fares 9000, 8000, 8000, 7000:
RANK       = 1, 2, 2, 4 (rank numbers contain a gap after a tie)
DENSE_RANK = 1, 2, 2, 3 (rank numbers do not contain a gap)
*/
