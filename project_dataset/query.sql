.headers on
drop table if exists customer_courier_conversations;
create table customer_courier_conversations as
    with
        -- columna 3: Marca de tiempo del primer mensaje del repartidor
        first_courier_timestamp as (
        select
            order_id,
            min(message_sent_time) as first_courier_timestamp
        from messages
        group by order_id
        having sender_app_type like 'Courier%'
        ),
        -- columna 4: Marca de tiempo del primer mensaje del cliente
        first_customer_timestamp as (
        select
            order_id,
            min(message_sent_time) as first_customer_timestamp
        from messages
        group by order_id
        having sender_app_type like 'Customer%'
        ),
        -- columna 5:Número de mensajes del repartidor
        num_messages_courier as (
            select order_id, courier_id, count(message_sent_time) as num_msg_courier
            from messages where sender_app_type like 'Courier%' group by order_id, courier_id
        ),
        -- columna 6:Número de mensajes del cliente
        num_messages_customer as (
            select order_id, customer_id, count(message_sent_time) as num_msg_customer
            from messages where sender_app_type like 'customer%' group by order_id, customer_id
        ),
        -- columna 7: El primer remitente del mensaje (repartidor o cliente)
        primer_mensaje as (
            select order_id, min(message_sent_time) as first_timestamp from messages group by order_id
        ),
        primer_remitente as (
            select
                messages.order_id, substr(sender_app_type, 1, instr(sender_app_type, ' ') - 1) as primer_remitente
            from messages join primer_mensaje on messages.order_id = primer_mensaje.order_id
            where message_sent_time = first_timestamp
        ),
        -- columna 8: Tiempo (en segundos) transcurrido hasta la primera respuesta
        --            Asumimos que el segundo mensaje responde siempre el primero
        ordered_messages as (
            select order_id, message_sent_time, row_number() over (partition by order_id order by message_sent_time) as row_num
            from messages
        ),
        tiempo_segundos as (
            SELECT
                m1.order_id,
                m1.message_sent_time AS first_message_time,
                m2.message_sent_time AS second_message_time,
                round((JULIANDAY(m2.message_sent_time) - JULIANDAY(m1.message_sent_time)) * 86400) AS time_diff_seconds
            FROM
                ordered_messages AS m1
            JOIN
                ordered_messages AS m2
            ON
                m1.order_id = m2.order_id
                AND m1.row_num = 1
                AND m2.row_num = 2
            ORDER BY
                m1.order_id
        ),
        -- columna 9: Timestamp of the last message sent and columna 10: The stage of the order when the last message was sent
        last_message_time as (
            select order_id, order_stage as last_order_stage, max(message_sent_time) as last_message_time
            from messages
            group by order_id
        )
    select distinct orders.order_id, city_code,
           first_courier_timestamp, first_customer_timestamp,
           num_msg_courier, num_msg_customer,
           primer_remitente, first_timestamp,
           time_diff_seconds,
           last_message_time, last_order_stage

    from messages join orders on messages.order_id = orders.order_id
              left join first_courier_timestamp on orders.order_id = first_courier_timestamp.order_id
              left join  first_customer_timestamp on orders.order_id = first_customer_timestamp.order_id
              left join num_messages_courier on orders.order_id = num_messages_courier.order_id
              left join num_messages_customer on orders.order_id = num_messages_customer.order_id
              left join primer_remitente on orders.order_id = primer_remitente.order_id
              left join primer_mensaje on orders.order_id = primer_mensaje.order_id
              left join tiempo_segundos on orders.order_id = tiempo_segundos.order_id
              left join last_message_time on orders.order_id = last_message_time.order_id;

select * from customer_courier_conversations;

--                 substr(sender_app_type, 1, instr(sender_app_type, ' ') - 1) as primer_remitente

