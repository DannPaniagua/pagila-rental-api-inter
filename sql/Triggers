CREATE OR REPLACE FUNCTION check_active_rentals() 
RETURNS TRIGGER AS $$
DECLARE
    active_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO active_count
    FROM rental
    WHERE customer_id = NEW.customer_id 
    AND return_date IS NULL;

    IF active_count >= 3 THEN
        RAISE EXCEPTION 'ALERTA DE NEGOCIO: El cliente % ya tiene % rentas activas. Límite superado.', NEW.customer_id, active_count;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_limit_rentals ON rental;

CREATE TRIGGER trg_limit_rentals
BEFORE INSERT ON rental
FOR EACH ROW EXECUTE FUNCTION check_active_rentals();