-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
    id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

-- Create Emails Table
CREATE TABLE IF NOT EXISTS emails (
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subject      VARCHAR(255),
    body         TEXT,
    sent_date    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    from_user_id INTEGER NOT NULL,
    CONSTRAINT fk_email_sender FOREIGN KEY (from_user_id)
         REFERENCES users(id) ON DELETE CASCADE
);

-- Create Email Recipients Table
CREATE TABLE IF NOT EXISTS email_recipients (
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email_id       INTEGER NOT NULL,
    user_id        INTEGER NOT NULL,
    recipient_type VARCHAR(10) CHECK (recipient_type IN ('TO', 'CC', 'BCC')),
    CONSTRAINT fk_email FOREIGN KEY (email_id)
         REFERENCES emails(id) ON DELETE CASCADE,
    CONSTRAINT fk_recipient FOREIGN KEY (user_id)
         REFERENCES users(id) ON DELETE CASCADE
);

-- Create the send_email procedure
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

    -- Insert TO recipients
    FOREACH recipient IN ARRAY p_to_users LOOP
        INSERT INTO email_recipients (email_id, user_id, recipient_type)
        VALUES (v_email_id, recipient, 'TO');
    END LOOP;

    -- Insert CC recipients
    FOREACH recipient IN ARRAY p_cc_users LOOP
        INSERT INTO email_recipients (email_id, user_id, recipient_type)
        VALUES (v_email_id, recipient, 'CC');
    END LOOP;

    -- Insert BCC recipients
    FOREACH recipient IN ARRAY p_bcc_users LOOP
        INSERT INTO email_recipients (email_id, user_id, recipient_type)
        VALUES (v_email_id, recipient, 'BCC');
    END LOOP;

    COMMIT;
    RAISE NOTICE 'Email Sent with ID: %', v_email_id;
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS err_msg = MESSAGE_TEXT;
        ROLLBACK;
        RAISE NOTICE 'Error: %', err_msg;
END;
$$;
