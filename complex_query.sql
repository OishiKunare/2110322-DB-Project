-- =========================
-- scenarios: query summarizes the total money earned per hotel in this year, excluding any cancelled or pending bookings. 
-- =========================
SELECT
    h.name AS hotel_name,
    SUM(b.total_price) AS total_revenue,
    COUNT(b.booking_id) AS total_completed_bookings
FROM
    hotels h
    JOIN bookings b ON h.hotel_id = b.hotel_id
WHERE
    b.status IN ('confirmed', 'checked_in', 'checked_out')
    AND b.check_in_date >= '2026-01-01'
    AND b.check_in_date <= '2026-12-31'
GROUP BY
    h.hotel_id,
    h.name
ORDER BY
    total_revenue DESC;

-- =========================
-- scenarios: query ranks every customer who has made a booking, from the highest spender down to the lowest.
-- =========================
SELECT
    p.first_name || ' ' || p.last_name AS customer_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent
FROM
    users u
    JOIN customers c ON u.user_id = c.user_id
    JOIN persons p ON c.national_id = p.national_id
    JOIN bookings b ON u.user_id = b.user_id
WHERE
    b.status IN ('confirmed', 'checked_in', 'checked_out')
GROUP BY
    u.user_id,
    p.first_name,
    p.last_name,
    u.email
ORDER BY
    total_spent DESC;