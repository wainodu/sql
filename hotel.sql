create table HOTEL
(
    ID_hotel SERIAL PRIMARY KEY,
    hotel_name varchar NOT NULL UNIQUE,
    country varchar NOT NULL,
    stars integer NOT NULL,
    adress varchar NOT NULL
);
create table ROOM
(
    room_number integer NOT NULL PRIMARY KEY,
    room_size varchar NOT NULL,
    hotel_name varchar,
    status varchar NOT NULL,
    daily_room_price float NOT NULL,
    CONSTRAINT fk_hotel FOREIGN KEY (hotel_name) REFERENCES HOTEL (hotel_name)
);
create table CLIENT
(
    client_id SERIAL PRIMARY KEY,
    full_name varchar NOT NULL,
    passport integer UNIQUE,
    birth_date date NOT NULL,
    citizenship varchar NOT NULL
);
create table RESERVATION
(
    reservation_id SERIAL PRIMARY KEY,
    client_id integer,
    hotel_name varchar,
    room_number integer,
    arrival_date date,
    departure_date date,
    CONSTRAINT fk_client FOREIGN KEY (client_id) REFERENCES CLIENT (client_id),
    CONSTRAINT fk_room FOREIGN KEY (room_number) REFERENCES ROOM (room_number)
);
CREATE OR REPLACE PROCEDURE ADD_HOTEL(_hotel_name varchar, _country varchar, _stars integer, _adress varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO HOTEL(hotel_name, country, stars, adress)
    VALUES(_hotel_name, _country, _stars, _adress);
    EXCEPTION
        when unique_violation then raise NOTICE 'duplicate error';
end;
$$;
CREATE OR REPLACE PROCEDURE ADD_ROOM
    (_room_number integer, _room_size varchar, _hotel_name varchar, _status varchar, _daily_room_price float)
LANGUAGE plpgsql
AS $$
DECLARE
    check_hotel varchar;
BEGIN
    begin
    SELECT hotel_name FROM HOTEL H where H.hotel_name = _hotel_name INTO check_hotel;
    EXCEPTION when NO_DATA_FOUND then NULL;
    end;
    if check_hotel is NULL then
        raise NOTICE 'hotel is missing';
    end if;
    if check_hotel is not NULL then
        begin
        INSERT INTO ROOM(room_number, room_size, hotel_name, status, daily_room_price)
        VALUES(_room_number, _room_size, _hotel_name, _status, _daily_room_price);
        EXCEPTION when unique_violation then raise NOTICE 'duplicate error';
        end;
    end if;
end;
$$;
CREATE OR REPLACE PROCEDURE ADD_CLIENT
    (_full_name varchar, _passport integer, _birth_date date, _citizenship varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO CLIENT(full_name, passport, birth_date, citizenship)
    VALUES(_full_name, _passport, _birth_date, _citizenship);
    EXCEPTION
        when unique_violation then raise NOTICE 'duplicate error';
end;
$$;
CREATE OR REPLACE PROCEDURE ADD_RESERVATION
    (_client_id integer, _hotel_name varchar, _room_number integer, _arrival_date date, _departure_date date)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO RESERVATION(client_id, hotel_name, room_number, arrival_date, departure_date)
    VALUES(_client_id, _hotel_name, _room_number, _arrival_date, _departure_date);
    EXCEPTION
        when unique_violation then raise NOTICE 'duplicate error';
    UPDATE ROOM
    SET status = 'busy'
    WHERE hotel_name = _hotel_name AND room_number = _room_number;
end
$$;
CREATE OR REPLACE PROCEDURE UPDATE_CLIENT
    (_client_id integer, _full_name varchar, _passport integer, _birth_date date, _citizenship varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE CLIENT
    SET full_name = _full_name, passport = _passport, birth_date = _birth_date, citizenship = _citizenship
    WHERE client_id = _client_id;
end;
$$;
CREATE OR REPLACE PROCEDURE UPDATE_CLIENT
    (_client_id integer, _full_name varchar, _passport integer, _birth_date date, _citizenship varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE CLIENT
    SET full_name = _full_name, passport = _passport, birth_date = _birth_date, citizenship = _citizenship
    WHERE client_id = _client_id;
end;
$$;
CREATE OR REPLACE PROCEDURE DELETE_CLIENT
    (_client_id integer)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM CLIENT
    WHERE client_id = _client_id;
end;
$$;
CREATE OR REPLACE PROCEDURE DELETE_RESERVATION
    (_reservation_id integer)
LANGUAGE plpgsql
AS $$
DECLARE
    check_number integer;
BEGIN
    SELECT room_number FROM RESERVATION where reservation_id = _reservation_id INTO check_number;
    DELETE FROM RESERVATION
    WHERE reservation_id = _reservation_id;
    UPDATE ROOM
    SET status = 'free'
    WHERE room_number = check_number;
end;
$$;
CREATE ROLE administrator
SUPERUSER
LOGIN
PASSWORD 'adminpass';



