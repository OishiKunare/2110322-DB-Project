-- =========================
-- 1. The system shall allow a user to register by specifying the name, telephone number, email, and password.
-- =========================
BEGIN;

INSERT INTO
    users (email, password, role)
VALUES
    ('user@example.com', 'password', 'customer')
RETURNING
    user_id;

INSERT INTO
    persons (national_id, first_name, last_name)
VALUES
    ('1234567890123', 'John', 'Doe');

INSERT INTO
    customers (user_id, national_id, phone)
VALUES
    (LASTVAL(), '1234567890000', '0800000000');

COMMIT;

-- =========================
-- 2. After registration, the user becomes a registered user, and the system shall allow the user to log in to use the system by specifying the email and password.
-- The system shall allow a registered user to log out.
-- =========================
SELECT
    user_id,
    password,
    role
FROM
    users
WHERE
    email = 'user@example.com'
    AND password = 'password';

-- =========================
-- 3. After login, the system shall allow the registered user to book up to 3 nights by specifying the date and the preferred hotel.
-- The hotel list is also provided to the user.
-- =========================
INSERT INTO
    bookings (
        check_in_date,
        check_out_date,
        total_price,
        user_id,
        room_number,
        hotel_id,
        status
    )
SELECT
    '2026-01-01',
    '2026-01-02',
    4500.00,
    1,
    '101',
    1,
    'confirmed'
WHERE
    ('2026-03-04'::date - '2026-03-01'::date) <= 3;

-- A hotel information includes the hotel name, address, and telephone number.
SELECT
    h.name,
    h.street || ' ' || h.district || ' ' || h.province AS address,
    hp.phone
FROM
    hotels h
    LEFT JOIN hotel_phones hp ON h.hotel_id = hp.hotel_id;

-- =========================
-- 4. The system shall allow the registered user to view his hotel bookings.
-- =========================
SELECT
    b.*,
    h.name AS hotel_name,
    r.room_type_id
FROM
    bookings b
    JOIN hotels h ON b.hotel_id = h.hotel_id
    JOIN rooms r ON b.room_number = r.room_number
    AND b.hotel_id = r.hotel_id
WHERE
    b.user_id = 1;

-- =========================
-- 5. The system shall allow the registered user to edit his hotel bookings.
-- =========================
UPDATE bookings
SET
    check_in_date = '2026-01-03',
    check_out_date = '2026-01-04'
WHERE
    booking_id = 1
    AND user_id = 1
    AND ('2026-01-04'::date - '2026-01-03'::date) <= 3;

-- =========================
-- 6. The system shall allow the registered user to delete his hotel bookings.'
-- =========================
DELETE FROM bookings
WHERE
    booking_id = 10
    AND user_id = 1;

-- =========================
-- 7. The system shall allow the admin to view any hotel bookings.
-- =========================
SELECT
    b.booking_id,
    u.email,
    b.check_in_date,
    b.check_out_date,
    b.status,
    h.name as hotel_name
FROM
    bookings b
    JOIN users u ON b.user_id = u.user_id
    JOIN hotels h ON b.hotel_id = h.hotel_id;

-- =========================
-- 8. The system shall allow the admin to edit any hotel bookings.
-- =========================
UPDATE bookings
SET
    status = 'confirmed',
    room_number = '001'
WHERE
    booking_id = 10;

-- =========================
-- 9. The system shall allow the admin to delete any hotel bookings.
-- =========================
DELETE FROM bookings
WHERE
    booking_id = 10;