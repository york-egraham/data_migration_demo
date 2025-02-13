SET SERVEROUTPUT ON;

-- Insert Users
INSERT INTO system.users (name, email) VALUES ('Alice', 'alice@example.com');
INSERT INTO system.users (name, email) VALUES ('Bob', 'bob@example.com');
INSERT INTO system.users (name, email) VALUES ('Charlie', 'charlie@example.com');
INSERT INTO system.users (name, email) VALUES ('Kelly', 'k@example.com');
INSERT INTO system.users (name, email) VALUES ('Helly', 'h@example.com');
--

COMMIT;
-- copy users to users_target
INSERT INTO system.users_target
SELECT * FROM system.users;

COMMIT;
-- -- Insert Email (sent by Alice)
-- INSERT INTO system.emails (subject, body, from_user_id)
-- VALUES ('Meeting Reminder', 'Do not forget our meeting tomorrow.', 1);
--
-- -- Insert Recipients (TO: Bob, CC: Charlie)
-- INSERT INTO email_recipients (email_id, user_id, recipient_type) VALUES (1, 2, 'TO');
-- INSERT INTO email_recipients (email_id, user_id, recipient_type) VALUES (1, 3, 'CC');


BEGIN
    DBMS_OUTPUT.PUT_LINE('start sending email');
    system.send_email(
          p_subject   => 'Project Update',
          p_body      => 'Please review the latest project updates.',
          p_from_user => 1,  -- Alice (Sender)
          p_to_users  => SYS.ODCINUMBERLIST(2, 3),
          p_cc_users  => SYS.ODCINUMBERLIST(3),
          p_bcc_users => SYS.ODCINUMBERLIST()
    );
    system.send_email_target(
            p_subject   => 'Project Update',
            p_body      => 'Please review the latest project updates2.',
            p_from_user => 1,  -- Alice (Sender)
            p_to_users  => SYS.ODCINUMBERLIST(2, 3),
            p_cc_users  => SYS.ODCINUMBERLIST(3),
            p_bcc_users => SYS.ODCINUMBERLIST()
    );
END;
/




