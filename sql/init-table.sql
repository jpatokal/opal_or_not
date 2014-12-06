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

-- Additional stats for peak vs off-peak fares
DROP TABLE times;
CREATE TABLE times (
    time varchar(10)
);
INSERT INTO times(time) VALUES
	('before'),
	('peak'),
	('after');

DROP TABLE peak_stats;
CREATE TABLE peak_stats (
	name  varchar(10),
	am    varchar(10),
	pm    varchar(10),
	count integer,
	sum   numeric(10,2)
);

CREATE OR REPLACE FUNCTION initPeakStats() RETURNS VOID AS
$BODY$
DECLARE
    am times.time%TYPE;
    pm times.time%TYPE;
BEGIN
	FOR am IN SELECT time FROM times
	LOOP
		FOR pm IN SELECT time FROM times
		LOOP
			INSERT INTO peak_stats (name, am, pm, count, sum) VALUES
				('Opal',     am, pm, 0, 0.0),
				('Non-Opal', am, pm, 0, 0.0);
		END LOOP;
	END LOOP;
END
$BODY$
LANGUAGE 'plpgsql';

SELECT initPeakStats();
SELECT * from peak_stats;
