-- Schema for the project-3-ironhack-delivery-es project.

DROP TABLE IF EXISTS orders;

DROP TABLE IF EXISTS messages;


CREATE TABLE messages (
    sender_app_type TEXT,
    customer_id INT,
    from_id INT,
    to_id INT,
    chat_started_by_message TEXT,
    order_id INT,
    order_stage TEXT,
    courier_id INT,
    message_sent_time DATETIME
);


CREATE TABLE orders (
    order_id INT NOT NULL,
    city_code TEXT
);


INSERT INTO orders VALUES
    (59528555, 'BCN'),
    (59528038, 'MAD');


INSERT INTO messages VALUES
    ('Customer iOS', 17071099, 17071099, 16293039, 'f', 59528555, 'PICKING_UP', 16293039, '2019-08-19 08:03:00'),
    ('Courier iOS', 17071099, 16293039, 17071099, 'f', 59528555, 'ARRIVING', 16293039, '2019-08-19 08:01:00'),
    ('Customer iOS', 17071099, 17071099, 16293039, 'f', 59528555, 'PICKING_UP', 16293039, '2019-08-19 08:00:00'),
    ('Courier Android', 12874122, 18325287, 12874122, 't', 59528038, 'ADDRESS_DELIVERY', 18325287, '2019-08-19 07:59:00');
