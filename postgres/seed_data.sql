-- Create the send_email procedure without explicit transaction control.
CREATE OR REPLACE PROCEDURE send_email(
    p_subject   TEXT,
    p_body      TEXT,
    p_from_user INTEGER,
    p_to_users  INTEGER[],  -- Array of TO recipient IDs
    p_cc_users  INTEGER[],  -- Array of CC recipient IDs
    p_bcc_users INTEGER[]   -- Array of BCC recipient IDs
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_email_id INTEGER;
    err_msg    TEXT;
    recipient  INTEGER;
BEGIN
    -- Insert email into the emails table and capture its ID.
    INSERT INTO emails (subject, body, from_user_id)
    VALUES (p_subject, p_body, p_from_user)
    RETURNING id INTO v_email_id;

    -- Insert TO recipients.
    FOREACH recipient IN ARRAY p_to_users LOOP
        INSERT INTO email_recipients (email_id, user_id, recipient_type)
        VALUES (v_email_id, recipient, 'TO');
    END LOOP;

    -- Insert CC recipients.
    FOREACH recipient IN ARRAY p_cc_users LOOP
        INSERT INTO email_recipients (email_id, user_id, recipient_type)
        VALUES (v_email_id, recipient, 'CC');
    END LOOP;

    -- Insert BCC recipients.
    FOREACH recipient IN ARRAY p_bcc_users LOOP
        INSERT INTO email_recipients (email_id, user_id, recipient_type)
        VALUES (v_email_id, recipient, 'BCC');
    END LOOP;

    RAISE NOTICE 'Email Sent with ID: %', v_email_id;
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS err_msg = MESSAGE_TEXT;
        RAISE NOTICE 'Error: %', err_msg;
        -- No explicit ROLLBACK here; the outer transaction will handle it.
END;
$$;

-- Seeder script: Create 100 users (each with a random age between 25 and 60)
-- and have each send 100 emails with TO, CC, and BCC recipients.
DO $$
DECLARE
    sender_id      INTEGER;
    user_id        INTEGER;
    user_ids       INTEGER[] := '{}';
    i              INTEGER;
    j              INTEGER;
    recipient_ids  INTEGER[];
    to_users       INTEGER[];
    cc_users       INTEGER[];
    bcc_users      INTEGER[];
BEGIN
    -- 1. Create 100 users.
    FOR i IN 1..100 LOOP
        INSERT INTO users (name, email, age)
        VALUES (
            'User ' || i,
            'user' || i || '@example.com',
            FLOOR(random() * 36)::int + 25  -- Random age between 25 and 60
        )
        RETURNING id INTO user_id;
        user_ids := array_append(user_ids, user_id);
    END LOOP;
    
    -- 2. For each user, send 100 emails.
    FOR i IN 1..array_length(user_ids, 1) LOOP
        sender_id := user_ids[i];
        
        FOR j IN 1..100 LOOP
            -- Select all other users as potential recipients.
            SELECT array_agg(u) INTO recipient_ids
            FROM unnest(user_ids) AS u
            WHERE u <> sender_id;
            
            -- Split the recipient_ids into TO, CC, and BCC groups.
            -- For example, with 99 recipients:
            --   - First 33 go to TO.
            --   - Next 33 go to CC.
            --   - Remaining go to BCC.
            to_users  := recipient_ids[1:3];
            cc_users  := recipient_ids[4:6];
            bcc_users := recipient_ids[7:array_length(recipient_ids, 1)];
            
            -- Call the send_email procedure.
            CALL send_email(
                p_subject   => 'Email ' || j || ' from User ' || sender_id,
                p_body      => 'This is a sample email body for email ' || j,
                p_from_user => sender_id,
                p_to_users  => to_users,
                p_cc_users  => cc_users,
                p_bcc_users => bcc_users
            );
        END LOOP;
    END LOOP;
END $$;
