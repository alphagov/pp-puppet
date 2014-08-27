DROP FUNCTION find_bad_seqs();
DROP TYPE bad_seq_return;
DROP TYPE seqs_record;

CREATE TYPE seqs_record as (
  table_name VARCHAR,
  name VARCHAR
);
CREATE TYPE bad_seq_return as (
  seq_name varchar,
  max_id integer,
  last_value integer
);

CREATE OR REPLACE FUNCTION find_bad_seqs() RETURNS SETOF bad_seq_return AS $$
DECLARE
  seq seqs_record%rowtype;
  max_id integer;
  last_value integer;
BEGIN
  for seq in (SELECT left(c.relname, -7) as table_name,
                     c.relname as name
              FROM pg_class c
              WHERE c.relkind = 'S') loop

    execute format('SELECT max(id) as max_id FROM %I', seq.table_name)
      into max_id;
    execute format('SELECT last_value FROM %I', seq.name)
      into last_value;

    return next row(seq.name, max_id, last_value);
  end loop;
END;
$$
LANGUAGE plpgsql;
