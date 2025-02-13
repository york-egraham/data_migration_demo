-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
    id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    age   INTEGER NOT NULL,
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
