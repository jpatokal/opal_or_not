DROP TABLE opal;
CREATE TABLE opal (
    name  varchar(10),
    count integer,
    sum   numeric(10,2)
);
INSERT INTO opal (name, count, sum) VALUES
    ('Opal',     0, 0.0),
    ('Non-Opal', 0, 0.0);
SELECT * from opal;

