drop table booking_calendar;
drop table restaurant;
drop table amenities_and_features;
drop table payment;
drop table booking_order;
drop table feedback;
drop table property;
drop table customer;
drop table host;
drop table airbnb_user;

CREATE TABLE airbnb_user (
  user_id VARCHAR(20) NOT NULL,
  password VARCHAR(20) NOT NULL,
 PRIMARY KEY (user_id)
);

CREATE TABLE customer (
  user_id VARCHAR(20) NOT NULL,
  first_name VARCHAR(10) NOT NULL,
  last_name VARCHAR(10) NOT NULL,
  email  VARCHAR(20) NOT NULL,
  phone_number CHAR(10),
  payment_details VARCHAR(20),
PRIMARY KEY(user_id),
FOREIGN KEY(user_id) REFERENCES airbnb_user(User_ID)
);


CREATE TABLE host (
  user_id VARCHAR(20) NOT NULL,
  first_name VARCHAR(10) NOT NULL,
  last_name VARCHAR(10) NOT NULL,
  email  VARCHAR(20) NOT NULL,
  phone_number CHAR(10),
  Location VARCHAR(20) NOT NULL,
  PRIMARY KEY(user_id),
 FOREIGN KEY(user_id) REFERENCES airbnb_user(user_id)
);


CREATE TABLE property (
  property_id INT NOT NULL,
  property_type VARCHAR(15) NOT NULL,
  host_user_id VARCHAR(20) NOT NULL,
  room_type VARCHAR(15),
  capacity INT NOT NULL,
  address_line_1  VARCHAR(15),
  address_line_2 VARCHAR(15),
  city VARCHAR(10),
  state VARCHAR(10),
  country VARCHAR(10),
  zip VARCHAR(5),
  price INT,
  special_offer VARCHAR(50),
  house_rules VARCHAR(50),
 PRIMARY KEY(property_id, property_type),
 FOREIGN KEY(host_user_id) REFERENCES airbnb_user(user_id)
);


CREATE TABLE feedback (
  review_id INT NOT NULL,
  customer_user_id VARCHAR(20),
  property_id INT NOT NULL,
  property_type VARCHAR(15) NOT NULL,
  ratings INT ,  
  recommendations VARCHAR(20),
 PRIMARY KEY (review_id),
 FOREIGN KEY (customer_user_id) REFERENCES customer (user_id),
 FOREIGN KEY (property_id,property_type) REFERENCES property (property_id,property_type)
 on delete cascade
 );
 
CREATE TABLE amenities_and_features (
  property_id INT NOT NULL,
  property_type VARCHAR(15) NOT NULL,
  air_conditioning  CHAR(10),
  wifi CHAR(10),
  private_bath CHAR(10),
  bed CHAR(10),
  kitchen CHAR(10),
  gym CHAR(10),
  pool CHAR(10),
  parking CHAR(10),
  washer CHAR(10),
  cleaning  CHAR(10),
 PRIMARY KEY (property_id, property_type),
FOREIGN KEY (property_id, property_type) REFERENCES property (property_id, property_type)
on delete cascade
);

CREATE TABLE booking_order (
  order_number INT NOT NULL,
  property_id INT NOT NULL,
  property_type VARCHAR(15) NOT NULL,
  host_user_id VARCHAR(20) NOT NULL,
  customer_user_id VARCHAR(20) NOT NULL,
  reserved_dates CHAR(10),
  guest_count INT NOT NULL,
  order_date CHAR(10),
  order_price INT,
  check_in_date CHAR(10),
  check_out_date CHAR(10),
  move_out_date CHAR(10),
 PRIMARY KEY(order_number),
FOREIGN KEY(property_id,property_type) REFERENCES property(property_id,property_type)
on delete cascade,
FOREIGN KEY(host_user_id) REFERENCES host(user_id),
FOREIGN KEY(customer_user_id) REFERENCES customer(user_id)
);

CREATE TABLE payment (
  payment_id INT NOT NULL,
  order_number INT NOT NULL,
  payment_type VARCHAR(15) NOT NULL,
  amount DECIMAL(4,2),
  host_user_id VARCHAR(20) NOT NULL,
  PRIMARY KEY(payment_id),
  FOREIGN KEY(order_number) REFERENCES booking_order(order_number),
  FOREIGN KEY(host_user_id) REFERENCES host(user_id)
);

CREATE TABLE restaurant (
  property_id INT NOT NULL,
  property_type VARCHAR(15) NOT NULL,
  booking_date CHAR(10),
  cuisine VARCHAR(15),
  menu VARCHAR(15),
  bar VARCHAR(15),
  total_seats INT,
  available_seats INT,
PRIMARY KEY(property_id, property_type),
FOREIGN KEY(property_id, property_type) REFERENCES property(property_id, property_type)
on delete cascade
);

CREATE TABLE booking_calendar (
  property_id INT NOT NULL,
  property_type VARCHAR(15) NOT NULL,
  booked_dates CHAR(10),
  PRIMARY KEY(property_id),
  FOREIGN KEY(property_id,property_type) REFERENCES property (property_id,property_type)
  on delete cascade
);

/*One Cust and Host Inserted*/

Insert into airbnb_user (USER_ID,PASSWORD) VALUES ('11','ghgbck');
Insert into airbnb_user (USER_ID,PASSWORD) VALUES ('12','ghgck');

Insert into Customer (USER_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,PAYMENT_DETAILS) VALUES ('11','John','Smith','js10@gmail.com',2145678976,987654321);
Insert into host (USER_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,LOCATION) VALUES ('12','Helga','Smith','j10@gmail.com',2145698076,'Texas');

/*Insert into Property(PROPERTY_ID,PROPERTY_TYPE,HOST_USER_ID,REVIEW_ID,ROOM_TYPE,CAPACITY,ADDRESS_LINE_1,ADDRESS_LINE_2,CITY,STATE,COUNTRY,ZIP,PRICE,SPECIAL_OFFER,HOUSE_RULES)
VALUES              (1212,'Bungalow',1234,5467,'3BHK',6,'AB Road','Lonel Colony','Richardson','Texas','US','75252',5000,300,'Hygienic,Pet free');
*/

/*Data for Trigger-1*/

Insert into Property(PROPERTY_ID,PROPERTY_TYPE,HOST_USER_ID,ROOM_TYPE,CAPACITY,ADDRESS_LINE_1,ADDRESS_LINE_2,CITY,STATE,COUNTRY,ZIP,PRICE,SPECIAL_OFFER,HOUSE_RULES)
VALUES              (1213,'Restaurant','12','',20,'AB Road','Lonel Colony-2','Richardson','Texas','US','75252',5000,0,'');


Insert into feedback(REVIEW_ID,
CUSTOMER_USER_ID,
RATINGS,
PROPERTY_ID,
PROPERTY_TYPE,
RECOMMENDATIONS) values(467,'11',4,1213,'Restaurant','guest friendly');

Insert into Restaurant(PROPERTY_ID,PROPERTY_TYPE,CUISINE,MENU,BAR,TOTAL_SEATS,AVAILABLE_SEATS) 
values(1213,'Restaurant','Chinese','','No',20,5);

/*Trigger-1 Restaurant Seat Availability Check */
CREATE OR REPLACE TRIGGER restaurant_full 
BEFORE INSERT ON booking_order FOR EACH ROW 
ENABLE
DECLARE
available_seat_count restaurant.available_seats%TYPE;
BEGIN
DBMS_OUTPUT.PUT_LINE(:new.property_id||:new.property_type);
  IF(:new.property_type='Restaurant') THEN
      select available_seats into available_seat_count from restaurant r 
        where :new.property_id = r.property_id and 
              :new.property_type = r.property_type; 
        IF (:new.guest_count - available_seat_count) = :new.guest_count THEN
            RAISE_APPLICATION_ERROR(-20001,'No seats are available, recheck booking');
        ELSIF ((0 < (:new.guest_count - available_seat_count)) AND 
                ((:new.guest_count - available_seat_count) < :new.guest_count)) THEN
            RAISE_APPLICATION_ERROR(-20002,'Only '||available_seat_count||' seats are available, recheck booking');
        END IF;
  END IF;
END;

Insert into Booking_Order(ORDER_NUMBER,
PROPERTY_ID,
PROPERTY_TYPE,
HOST_USER_ID,
CUSTOMER_USER_ID,
RESERVED_DATES,
GUEST_COUNT,
ORDER_DATE,
ORDER_PRICE,
CHECK_IN_DATE,
CHECK_OUT_DATE,
MOVE_OUT_DATE) values (2,1213,'Restaurant','12','11','',8,'',4000,'','','');

/* End Data*/


/*Trigger-2 Customer Payment-Details Check*/
CREATE OR REPLACE TRIGGER cust_payment_detail_check 
BEFORE INSERT ON booking_order FOR EACH ROW 
ENABLE
DECLARE
payment customer.payment_details%TYPE;
cust_id booking_order.customer_user_id%TYPE;
BEGIN
     select payment_details INTO payment from CUSTOMER c
     where c.user_id = :new.customer_user_id;
     IF payment is NULL THEN 
        RAISE_APPLICATION_ERROR(-20003,'Add payment details for customer');
     END IF;
END;

/*Data for Trigger-2*/

Insert into airbnb_user (USER_ID,PASSWORD) VALUES ('13','ujghgbck');
Insert into airbnb_user (USER_ID,PASSWORD) VALUES ('14','ujghgbck');
Insert into Customer (USER_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,PAYMENT_DETAILS) VALUES ('13','Jeny','Sheik','js10@gmail.com',2145608976,NULL);
Insert into host (USER_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,LOCATION) VALUES ('14','Helga','Bob','HB@gmail.com',2145698076,'Texas');
 
Insert into Property(PROPERTY_ID,PROPERTY_TYPE,HOST_USER_ID,ROOM_TYPE,CAPACITY,ADDRESS_LINE_1,ADDRESS_LINE_2,CITY,STATE,COUNTRY,ZIP,PRICE,SPECIAL_OFFER,HOUSE_RULES)
VALUES              (567,'Restaurant','14','',20,'AB Road','Lonel Colony-2','Richardson','Texas','US','75252',5000,0,'');


Insert into feedback(REVIEW_ID,
CUSTOMER_USER_ID,
RATINGS,
PROPERTY_ID,
PROPERTY_TYPE,
RECOMMENDATIONS) values(967,'13',4,567,'Restaurant','');

Insert into Restaurant(PROPERTY_ID,PROPERTY_TYPE,CUISINE,MENU,BAR,TOTAL_SEATS,AVAILABLE_SEATS) 
values(567,'Restaurant','Chinese','','No',20,30);


Insert into Booking_Order(ORDER_NUMBER,
PROPERTY_ID,
PROPERTY_TYPE,
HOST_USER_ID,
CUSTOMER_USER_ID,
RESERVED_DATES,
GUEST_COUNT,
ORDER_DATE,
ORDER_PRICE,
CHECK_IN_DATE,
CHECK_OUT_DATE,
MOVE_OUT_DATE) values (2,1213,'Restaurant','14','13','',3,'',4000,'','','');

/*Data for trigger-3*/
Insert into airbnb_user (USER_ID,PASSWORD) VALUES ('1223','opghgbck');

Insert into Customer (USER_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,PAYMENT_DETAILS) VALUES ('1223','Beny','Beliheik','bb10@gmail.com',2145608996,987654323);


Insert into Property(PROPERTY_ID,PROPERTY_TYPE,HOST_USER_ID,ROOM_TYPE,CAPACITY,ADDRESS_LINE_1,ADDRESS_LINE_2,CITY,STATE,COUNTRY,ZIP,PRICE,SPECIAL_OFFER,HOUSE_RULES)
VALUES              (123,'Restaurant','12','',20,'AB Road','Lonel Colony-2','Richardson','Texas','US','75252',5000,0,'');


Insert into feedback(REVIEW_ID,
CUSTOMER_USER_ID,
RATINGS,
PROPERTY_ID,
PROPERTY_TYPE,
RECOMMENDATIONS) values(34,'1223',1,123,'Restaurant','');


Insert into feedback(REVIEW_ID,
CUSTOMER_USER_ID,
RATINGS,
PROPERTY_ID,
PROPERTY_TYPE,
RECOMMENDATIONS) values(35,'1223',1,123,'Restaurant','');



Insert into feedback(REVIEW_ID,
CUSTOMER_USER_ID,
RATINGS,
PROPERTY_ID,
PROPERTY_TYPE,
RECOMMENDATIONS) values(36,'1223',1,123,'Restaurant','');

Insert into Restaurant(PROPERTY_ID,PROPERTY_TYPE,BOOKING_DATE,CUISINE,MENU,BAR,TOTAL_SEATS,AVAILABLE_SEATS) 
values(123,'Restaurant','2019-04-04','Thai','','No',20,10);


Insert into Booking_Order(ORDER_NUMBER,
PROPERTY_ID,
PROPERTY_TYPE,
HOST_USER_ID,
CUSTOMER_USER_ID,
RESERVED_DATES,
GUEST_COUNT,
ORDER_DATE,
ORDER_PRICE,
CHECK_IN_DATE,
CHECK_OUT_DATE,
MOVE_OUT_DATE) values (7,123,'Restaurant','12','11','',1,'',4000,'2019-04-04','','');

insert into booking_order values(9999,9999,'bonus',999,999,NULL,0,NULL,NULL,NULL,NULL,NULL);