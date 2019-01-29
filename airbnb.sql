CREATE OR REPLACE TRIGGER restraunt_full 
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
        ELSE
            bad_feedback_chk(:new.property_id);
        END IF;
  END IF;
DBMS_OUTPUT.PUT_LINE('leaving rest full');
END;
/
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
DBMS_OUTPUT.PUT_LINE('lleaving cust pay check');
END;
/
CREATE OR REPLACE TRIGGER after_order_placed 
FOR INSERT ON booking_order COMPOUND TRIGGER
AFTER EACH ROW IS
BEGIN
    IF :new.property_type = 'Restaurant' THEN
        rest_upd_after_order(:new.property_id,:new.property_type,:new.guest_count,:new.check_in_date);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS 
BEGIN
bonus_check;
END AFTER STATEMENT;
END;
/

CREATE OR REPLACE PROCEDURE rest_upd_after_order(tproperty_id IN booking_order.property_id%TYPE,tproperty_type IN booking_order.property_type%TYPE,
tguest_count IN booking_order.guest_count%TYPE,tcheck_in_date IN booking_order.check_in_date%TYPE) IS
BEGIN
update restaurant r set available_seats = (available_seats - tguest_count) 
where r.property_id = tproperty_id and
      r.property_type = tproperty_type and
      r.booking_date = tcheck_in_date;
END;
/
CREATE OR REPLACE PROCEDURE bad_feedback_chk(bproperty_id IN booking_order.property_id%TYPE) AS
CURSOR feed_bk_chk IS
    select property_id,avg(ratings) as avg_ratings from feedback  
           group by property_id having count(*)> 2; 
cur_ptr feed_bk_chk%ROWTYPE;
BEGIN
open feed_bk_chk;
LOOP
    FETCH feed_bk_chk into cur_ptr;
    IF feed_bk_chk%NOTFOUND THEN
    EXIT;
    END IF;
    IF ((bproperty_id = cur_ptr.property_id) and (cur_ptr.avg_ratings < 2)) THEN
    RAISE_APPLICATION_ERROR(-20003,'Trying to book in a restaurant with low rating,denying booking');
    END IF;
END LOOP;
END;
/
CREATE OR REPLACE PROCEDURE bonus_check AS
random_val_1 INT;
CURSOR fetch_host_id IS
    select host_user_id from booking_order group by host_user_id having count(*) = 50;
    cur_ptr fetch_host_id%ROWTYPE;
BEGIN
    open fetch_host_id;
LOOP
    FETCH fetch_host_id into cur_ptr;
    IF fetch_host_id%NOTFOUND THEN
    EXIT;
    ELSE
        select dbms_random.value(900,999) into random_val_1 from dual ;
        insert into payment values(random_val_1,9999,'card',1000,cur_ptr.host_user_id);
    END IF;
END LOOP;
    close fetch_host_id;
END;
/
