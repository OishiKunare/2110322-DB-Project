-- =========================
-- ENUM TYPES
-- =========================
CREATE TYPE user_role AS ENUM ('customer', 'admin');
CREATE TYPE room_status AS ENUM ('available', 'unavailable', 'maintenance');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled', 'checked_in', 'checked_out');

-- =========================
-- LOOKUP TABLES
-- =========================
CREATE TABLE facilities (
    facility_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    facility_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE room_types (
    room_type_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_type_name VARCHAR(100) NOT NULL UNIQUE,
    room_description TEXT,
    max_adults INTEGER NOT NULL CHECK (max_adults >= 0),
    max_children INTEGER NOT NULL CHECK (max_children >= 0),
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    extra_person_fee DECIMAL(10,2) CHECK (extra_person_fee >= 0)
);

-- =========================
-- HOTELS & RELATED
-- =========================
CREATE TABLE hotels (
    hotel_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    check_in_time TIME NOT NULL,
    check_out_time TIME NOT NULL,
    street TEXT,
    sub_district VARCHAR(100),
    district VARCHAR(100),
    province VARCHAR(100),
    zip_code VARCHAR(10),
    map_url TEXT,
    location_latitude DECIMAL(9,6),
    location_longitude DECIMAL(9,6)
);

CREATE TABLE hotel_phones (
    hotel_id INTEGER NOT NULL REFERENCES hotels(hotel_id) ON DELETE CASCADE,
    phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (hotel_id, phone)
);

CREATE TABLE hotel_facilities (
    hotel_id INTEGER NOT NULL REFERENCES hotels(hotel_id) ON DELETE CASCADE,
    facility_id INTEGER NOT NULL REFERENCES facilities(facility_id) ON DELETE CASCADE,
    PRIMARY KEY (hotel_id, facility_id)
);

-- =========================
-- ROOMS
-- =========================
CREATE TABLE rooms (
    room_number VARCHAR(20) NOT NULL,
    hotel_id INTEGER NOT NULL REFERENCES hotels(hotel_id) ON DELETE CASCADE,
    room_type_id INTEGER REFERENCES room_types(room_type_id) ON DELETE SET NULL,
    price_override DECIMAL(10,2) CHECK (price_override >= 0),
    room_status room_status NOT NULL DEFAULT 'available',
    PRIMARY KEY (room_number, hotel_id)
);

CREATE TABLE room_facilities (
    room_type_id INTEGER NOT NULL REFERENCES room_types(room_type_id) ON DELETE CASCADE,
    facility_id INTEGER NOT NULL REFERENCES facilities(facility_id) ON DELETE CASCADE,
    PRIMARY KEY (room_type_id, facility_id)
);

-- =========================
-- IDENTITY & USERS
-- =========================
CREATE TABLE users (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role user_role NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE persons (
    national_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL

-- =========================
-- ROLES & PERMISSIONS
-- =========================
CREATE TABLE customers (
    user_id INTEGER PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    national_id VARCHAR(20) NOT NULL REFERENCES persons(national_id) ON DELETE CASCADE,
    phone VARCHAR(20)
);

CREATE TABLE admins (
    user_id INTEGER PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    access_level INTEGER NOT NULL CHECK (access_level > 0)
);

CREATE TABLE hotel_managers (
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    hotel_id INTEGER NOT NULL REFERENCES hotels(hotel_id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, hotel_id)
);

-- =========================
-- BOOKINGS
-- =========================
CREATE TABLE bookings (
    booking_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price DECIMAL(12,2) NOT NULL CHECK (total_price >= 0),
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    status booking_status NOT NULL DEFAULT 'pending',
    room_number VARCHAR(20) NOT NULL,
    hotel_id INTEGER NOT NULL,
    CONSTRAINT fk_booking_room FOREIGN KEY (room_number, hotel_id) REFERENCES rooms(room_number, hotel_id),
    CONSTRAINT chk_booking_dates CHECK (check_out_date > check_in_date)
);

-- =========================
-- INDEXES
-- =========================
CREATE INDEX idx_booking_dates ON bookings (check_in_date, check_out_date);
CREATE INDEX idx_rooms_status ON rooms (room_status);
CREATE INDEX idx_hotel_location ON hotels (province, district);
CREATE INDEX idx_bookings_room ON bookings (hotel_id, room_number);