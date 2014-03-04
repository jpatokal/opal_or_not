DROP TABLE modes;
CREATE TABLE modes (
    mode varchar(20)
);
INSERT INTO modes(mode) VALUES
	('bus'),
	('bus+ferry'),
	('bus+train'),
	('ferry'),
	('ferry+train'),
	('train'),
	('unknown');

DROP TABLE opal;
CREATE TABLE opal (
    name  varchar(10),
    mode  varchar(20),
    count integer,
    sum   numeric(10,2)
);

CREATE OR REPLACE FUNCTION initOpal() RETURNS VOID AS
$BODY$
DECLARE
    m modes.mode%TYPE;
BEGIN
	FOR m IN SELECT mode FROM modes
	LOOP
		INSERT INTO opal (name, mode, count, sum) VALUES
		    ('Opal',     m, 0, 0.0),
		    ('Non-Opal', m, 0, 0.0);
	END LOOP;
END
$BODY$
LANGUAGE 'plpgsql';

SELECT initOpal();
SELECT * from opal;

