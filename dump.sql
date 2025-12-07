--
-- PostgreSQL database dump
--


-- Dumped from database version 16.9
-- Dumped by pg_dump version 17.7 (Ubuntu 17.7-3.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: _heroku; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA _heroku;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: create_ext(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.create_ext() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

  schemaname TEXT;
  databaseowner TEXT;

  r RECORD;

BEGIN

  IF tg_tag OPERATOR(pg_catalog.=) 'CREATE EXTENSION' AND current_user OPERATOR(pg_catalog.!=) 'rds_superuser' THEN
    PERFORM _heroku.validate_search_path();

    FOR r IN SELECT * FROM pg_catalog.pg_event_trigger_ddl_commands()
    LOOP
        CONTINUE WHEN r.command_tag != 'CREATE EXTENSION' OR r.object_type != 'extension';

        schemaname := (
            SELECT n.nspname
            FROM pg_catalog.pg_extension AS e
            INNER JOIN pg_catalog.pg_namespace AS n
            ON e.extnamespace = n.oid
            WHERE e.oid = r.objid
        );

        databaseowner := (
            SELECT pg_catalog.pg_get_userbyid(d.datdba)
            FROM pg_catalog.pg_database d
            WHERE d.datname = pg_catalog.current_database()
        );
        --RAISE NOTICE 'Record for event trigger %, objid: %,tag: %, current_user: %, schema: %, database_owenr: %', r.object_identity, r.objid, tg_tag, current_user, schemaname, databaseowner;
        IF r.object_identity = 'address_standardizer_data_us' THEN
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'us_gaz');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'us_lex');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'us_rules');
        ELSIF r.object_identity = 'amcheck' THEN
            EXECUTE pg_catalog.format('GRANT EXECUTE ON FUNCTION %I.bt_index_check TO %I;', schemaname, databaseowner);
            EXECUTE pg_catalog.format('GRANT EXECUTE ON FUNCTION %I.bt_index_parent_check TO %I;', schemaname, databaseowner);
        ELSIF r.object_identity = 'dict_int' THEN
            EXECUTE pg_catalog.format('ALTER TEXT SEARCH DICTIONARY %I.intdict OWNER TO %I;', schemaname, databaseowner);
        ELSIF r.object_identity = 'pg_partman' THEN
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'part_config');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'part_config_sub');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'custom_time_partitions');
        ELSIF r.object_identity = 'pg_stat_statements' THEN
            EXECUTE pg_catalog.format('GRANT EXECUTE ON FUNCTION %I.pg_stat_statements_reset TO %I;', schemaname, databaseowner);
        ELSIF r.object_identity = 'postgis' THEN
            PERFORM _heroku.postgis_after_create();
        ELSIF r.object_identity = 'postgis_raster' THEN
            PERFORM _heroku.postgis_after_create();
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT', databaseowner, 'raster_columns');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT', databaseowner, 'raster_overviews');
        ELSIF r.object_identity = 'postgis_topology' THEN
            PERFORM _heroku.postgis_after_create();
            EXECUTE pg_catalog.format('GRANT USAGE ON SCHEMA topology TO %I;', databaseowner);
            EXECUTE pg_catalog.format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA topology TO %I;', databaseowner);
            PERFORM _heroku.grant_table_if_exists('topology', 'SELECT, UPDATE, INSERT, DELETE', databaseowner);
            EXECUTE pg_catalog.format('GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA topology TO %I;', databaseowner);
        ELSIF r.object_identity = 'postgis_tiger_geocoder' THEN
            PERFORM _heroku.postgis_after_create();
            EXECUTE pg_catalog.format('GRANT USAGE ON SCHEMA tiger TO %I;', databaseowner);
            EXECUTE pg_catalog.format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA tiger TO %I;', databaseowner);
            PERFORM _heroku.grant_table_if_exists('tiger', 'SELECT, UPDATE, INSERT, DELETE', databaseowner);

            EXECUTE pg_catalog.format('GRANT USAGE ON SCHEMA tiger_data TO %I;', databaseowner);
            EXECUTE pg_catalog.format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA tiger_data TO %I;', databaseowner);
            PERFORM _heroku.grant_table_if_exists('tiger_data', 'SELECT, UPDATE, INSERT, DELETE', databaseowner);
        END IF;
    END LOOP;
  END IF;
END;
$$;


--
-- Name: drop_ext(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.drop_ext() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

  schemaname TEXT;
  databaseowner TEXT;

  r RECORD;

BEGIN

  IF tg_tag OPERATOR(pg_catalog.=) 'DROP EXTENSION' AND current_user OPERATOR(pg_catalog.!=) 'rds_superuser' THEN
    PERFORM _heroku.validate_search_path();

    FOR r IN SELECT * FROM pg_catalog.pg_event_trigger_dropped_objects()
    LOOP
      CONTINUE WHEN r.object_type != 'extension';

      databaseowner := (
            SELECT pg_catalog.pg_get_userbyid(d.datdba)
            FROM pg_catalog.pg_database d
            WHERE d.datname = pg_catalog.current_database()
      );

      --RAISE NOTICE 'Record for event trigger %, objid: %,tag: %, current_user: %, database_owner: %, schemaname: %', r.object_identity, r.objid, tg_tag, current_user, databaseowner, r.schema_name;

      IF r.object_identity = 'postgis_topology' THEN
          EXECUTE pg_catalog.format('DROP SCHEMA IF EXISTS topology');
      END IF;
    END LOOP;

  END IF;
END;
$$;


--
-- Name: extension_before_drop(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.extension_before_drop() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

  query TEXT;

BEGIN
  query := (SELECT pg_catalog.current_query());

  -- RAISE NOTICE 'executing extension_before_drop: tg_event: %, tg_tag: %, current_user: %, session_user: %, query: %', tg_event, tg_tag, current_user, session_user, query;
  IF tg_tag OPERATOR(pg_catalog.=) 'DROP EXTENSION' AND NOT pg_catalog.pg_has_role(session_user, 'rds_superuser', 'MEMBER') THEN
    PERFORM _heroku.validate_search_path();

    -- DROP EXTENSION [ IF EXISTS ] name [, ...] [ CASCADE | RESTRICT ]
    IF (pg_catalog.regexp_match(query, 'DROP\s+EXTENSION\s+(IF\s+EXISTS)?.*(plpgsql)', 'i') IS NOT NULL) THEN
      RAISE EXCEPTION 'The plpgsql extension is required for database management and cannot be dropped.';
    END IF;
  END IF;
END;
$$;


--
-- Name: grant_table_if_exists(text, text, text, text); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.grant_table_if_exists(alias_schemaname text, grants text, databaseowner text, alias_tablename text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

BEGIN
  PERFORM _heroku.validate_search_path();

  IF alias_tablename IS NULL THEN
    EXECUTE pg_catalog.format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', grants, alias_schemaname, databaseowner);
  ELSE
    IF EXISTS (SELECT 1 FROM pg_tables WHERE pg_tables.schemaname = alias_schemaname AND pg_tables.tablename = alias_tablename) THEN
      EXECUTE pg_catalog.format('GRANT %s ON TABLE %I.%I TO %I;', grants, alias_schemaname, alias_tablename, databaseowner);
    END IF;
  END IF;
END;
$$;


--
-- Name: postgis_after_create(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.postgis_after_create() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    schemaname TEXT;
    databaseowner TEXT;
BEGIN
    PERFORM _heroku.validate_search_path();

    schemaname := (
        SELECT n.nspname
        FROM pg_catalog.pg_extension AS e
        INNER JOIN pg_catalog.pg_namespace AS n ON e.extnamespace = n.oid
        WHERE e.extname = 'postgis'
    );
    databaseowner := (
        SELECT pg_catalog.pg_get_userbyid(d.datdba)
        FROM pg_catalog.pg_database d
        WHERE d.datname = pg_catalog.current_database()
    );

    EXECUTE pg_catalog.format('GRANT EXECUTE ON FUNCTION %I.st_tileenvelope TO %I;', schemaname, databaseowner);
    EXECUTE pg_catalog.format('GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE %I.spatial_ref_sys TO %I;', schemaname, databaseowner);
END;
$$;


--
-- Name: validate_extension(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.validate_extension() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

  schemaname TEXT;
  r RECORD;

BEGIN

  IF tg_tag OPERATOR(pg_catalog.=) 'CREATE EXTENSION' AND current_user OPERATOR(pg_catalog.!=) 'rds_superuser' THEN
    PERFORM _heroku.validate_search_path();

    FOR r IN SELECT * FROM pg_catalog.pg_event_trigger_ddl_commands()
    LOOP
      CONTINUE WHEN r.command_tag != 'CREATE EXTENSION' OR r.object_type != 'extension';

      schemaname := (
        SELECT n.nspname
        FROM pg_catalog.pg_extension AS e
        INNER JOIN pg_catalog.pg_namespace AS n
        ON e.extnamespace = n.oid
        WHERE e.oid = r.objid
      );

      IF schemaname = '_heroku' THEN
        RAISE EXCEPTION 'Creating extensions in the _heroku schema is not allowed';
      END IF;
    END LOOP;
  END IF;
END;
$$;


--
-- Name: validate_search_path(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.validate_search_path() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE

  current_search_path TEXT;
  schemas TEXT[];
  pg_catalog_index INTEGER;

BEGIN

  current_search_path := pg_catalog.current_setting('search_path');
  schemas := pg_catalog.string_to_array(current_search_path, ',');

  schemas := (
    SELECT pg_catalog.array_agg(TRIM(schema_name::text))
    FROM pg_catalog.unnest(schemas) AS schema_name
  );

  IF ('pg_catalog' OPERATOR(pg_catalog.=) ANY(schemas)) THEN
    SELECT pg_catalog.array_position(schemas, 'pg_catalog') INTO pg_catalog_index;
    IF pg_catalog_index OPERATOR(pg_catalog.!=) 1 THEN
      RAISE EXCEPTION 'pg_catalog must be first in the search_path for this operation. Current search_path: %', current_search_path;
    END IF;
  END IF;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: entrants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entrants (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    surname character varying NOT NULL,
    club character varying,
    address character varying,
    email character varying NOT NULL,
    paid boolean DEFAULT false NOT NULL,
    variable_symbol character varying NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    year integer NOT NULL,
    male boolean DEFAULT true,
    climber boolean DEFAULT false
);


--
-- Name: entrants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entrants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entrants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entrants_id_seq OWNED BY public.entrants.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: entrants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entrants ALTER COLUMN id SET DEFAULT nextval('public.entrants_id_seq'::regclass);


--
-- Data for Name: entrants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.entrants (id, first_name, surname, club, address, email, paid, variable_symbol, archived, created_at, updated_at, year, male, climber) FROM stdin;
2021	Romana 	Balážová 	Baláž EXTREME-TEAM Frenštát p.R.		balazteam@seznam.cz	f	1104205263	f	2025-11-04 20:47:52.33683	2025-11-04 20:47:52.33683	2012	f	f
2022	Anna	Balážová 	Baláž EXTREME-TEAM Frenštát p.R.		balazteam@seznam.cz	f	1104209209	f	2025-11-04 20:50:02.600727	2025-11-04 20:50:02.600727	2009	f	f
2024	Pavol	Svoboda 	Atletika Novy Jičín 	28.října 50/10 , Nový Jičín.  74101	pablo-s@seznam.cz	f	1104229475	f	2025-11-04 22:41:04.240838	2025-11-04 22:41:04.240838	1983	t	f
2026	Martin	Holiš		Na Kopci 383, Zubří, 75654	martin.holis@seznam.cz	f	1105053193	f	2025-11-05 05:26:10.888878	2025-11-05 05:26:10.888878	1974	t	f
2031	Dalibor	Olejník		Ostrava - Poruba	daliborolejnik@volny.cz	f	1105141999	f	2025-11-05 14:16:59.042536	2025-11-05 14:16:59.042536	1965	t	f
2017	Adam	Bárta		Kunčina	barta1992@seznam.cz	t	1104207705	f	2025-11-04 20:10:44.089225	2025-11-04 20:10:44.089225	1992	t	f
2016	Martin	Novotný			martin.cipis@seznam.cz	t	1104109914	f	2025-11-04 10:47:41.186875	2025-11-04 10:47:41.186875	1988	t	f
2018	Zuzana	Bártová		Kunčina	jurezu02@gmail.com	t	1104205044	f	2025-11-04 20:12:01.789673	2025-11-04 20:12:01.789673	1995	f	f
2029	Denisa	Hajková			denisa.hajkova12@seznam.cz	t	1105099373	f	2025-11-05 09:16:29.100407	2025-11-05 09:16:29.100407	1991	f	f
2030	Tomáš	Lipina	MK SEITL Ostrava	Ostrava, Hlavní třída 841/58	tomaslipina@gmail.com	t	1105125027	f	2025-11-05 12:39:23.40699	2025-11-05 12:39:23.40699	1966	t	f
2040	Dominik	Gawlas	KWbielsk Biela	Ciesztn	dominik.gawlas@wp.pl	f	1105222041	f	2025-11-05 22:17:36.644905	2025-11-05 22:17:36.644905	1982	t	t
2041	Jiří	Heralt			heraltjiri@gmail.com	f	1106098783	f	2025-11-06 09:20:32.963629	2025-11-06 09:20:32.963629	2002	t	f
2034	Alexandra	Muroňová	MK Seitl	Otakara Jeremiáše 1932/12, Ostrava - Poruba	amuronova@email.cz	t	1105172049	f	2025-11-05 17:26:42.863419	2025-11-05 17:26:42.863419	1974	f	f
2035	Ivan	Rodina	MK Seitl 		servisnimail@seznam.cz	t	1105174062	f	2025-11-05 17:30:47.339569	2025-11-05 17:30:47.339569	1968	t	f
2032	Michal	Heralt			michal.heralt@seznam.cz	t	1105169733	f	2025-11-05 16:12:36.29282	2025-11-05 16:12:36.29282	2003	t	f
2038	Vladimír	Maloň	Lokomotiva Trojanovice	Trojanovice č. evidenční 224	vladimir.malon@centrum.cz	t	1105206100	f	2025-11-05 20:01:07.711238	2025-11-05 20:01:07.711238	1980	t	f
2036	Jiří	Bučánek			bugybugy@seznam.cz	t	1105182168	f	2025-11-05 18:13:20.265761	2025-11-05 18:13:20.265761	1956	t	f
2042	Miroslav	Pavlík	MOUNTAINTIME 4Ever	Pustá Polom	mp.pp.polom@seznam.cz	t	1106187258	f	2025-11-06 18:39:02.556921	2025-11-06 18:39:02.556921	1964	t	f
2019	Ondřej	Pop			popondrej@seznam.cz	t	1104204128	f	2025-11-04 20:34:28.120654	2025-11-04 20:34:28.120654	1994	t	f
2015	Marek	Radomský 		Ostrava	marekradomsky@centrum.cz	t	1104085610	f	2025-11-04 08:52:52.992002	2025-11-04 08:52:52.992002	1989	t	f
2047	Stanislav	Berek	Štěpánkovice	U Pekaře 854/6 Štěpánkovice	berek.s@seznam.cz	t	1107202607	f	2025-11-07 20:13:41.372795	2025-11-07 20:13:41.372795	1983	t	f
2058	Petr	Ševčík			petr@sevcik.me	f	1113104610	f	2025-11-13 10:25:36.823521	2025-11-13 10:25:36.823521	1982	t	f
2062	Martin	Holeksa			Holeksa.martin@seznam.cz	f	1114180454	f	2025-11-14 18:23:11.19711	2025-11-14 18:23:11.19711	1997	t	f
2069	Libor	Hrdina			hrdinali@email.cz	f	1116216439	f	2025-11-16 21:54:13.045734	2025-11-16 21:54:13.045734	1979	t	f
2070	Eliška	Slehová			elinkaslehova1@seznam.cz	f	1117088717	f	2025-11-17 08:46:48.082119	2025-11-17 08:46:48.082119	2004	f	f
2073	Danuše	Škrdová	BO VZS Ostrava		danuse.skrdova@seznam.cz	t	1117189442	f	2025-11-17 18:50:27.382808	2025-11-17 18:50:27.382808	1965	f	f
2068	Tomáš	Hájovský	Hlučín		gras_servis@post.cz	t	1116149966	f	2025-11-16 14:32:45.509821	2025-11-16 14:32:45.509821	1964	t	f
2065	Jan	Barabáš	Olomoucká osma snů	Einsteinova 12 Olomouc	jan.barabas@cbox.cz	t	1116062570	f	2025-11-16 06:21:03.366008	2025-11-16 06:21:03.366008	1976	t	f
2072	Monika	Blechtová			1monik@seznam.cz	t	1117140912	f	2025-11-17 14:15:13.83311	2025-11-17 14:15:13.83311	1991	f	f
2066	Rudolf	Šelepa		Frenštát Za Střelnicí 403	tina.fren@seznam.cz	t	1116129104	f	2025-11-16 12:57:08.887269	2025-11-16 12:57:08.887269	1964	t	f
2061	Jiří	Kramoliš	AKEZ Kopřivnice		jkramolis@seznam.cz	t	1114175667	f	2025-11-14 17:31:15.89761	2025-11-14 17:31:15.89761	1991	t	f
2059	Šimon	Mandúr			Mandursimon@gmail.com	t	1114069224	f	2025-11-14 06:03:29.25203	2025-11-14 06:03:29.25203	2002	t	t
2037	Michal	Krupka		Anastázova 10/16 Praha 6 16900	michalkrupka1@seznam.cz	t	1105194344	f	2025-11-05 19:25:10.817292	2025-11-05 19:25:10.817292	1989	t	f
2060	Michal	Angyal			765michala@seznam.cz	t	1114099777	f	2025-11-14 09:13:14.955582	2025-11-14 09:13:14.955582	1986	t	f
2057	Jakub	Lanča			lancajakub@gmail.com	t	1112144149	f	2025-11-12 14:19:01.302131	2025-11-12 14:19:01.302131	1996	t	f
2046	Jonáš	Kaňovský	Letka Štěpánkovice	Štěpánkovice	ondrej.kanovsky@seznam.cz	t	1107192443	f	2025-11-07 19:29:25.878088	2025-11-07 19:29:25.878088	2012	t	f
2045	Ondřej	Kaňovský	Modrá Ústřice	Štěpánkovice	ondrej.kanovsky@seznam.cz	t	1107182508	f	2025-11-07 18:37:15.545117	2025-11-07 18:37:15.545117	1983	t	f
2056	Dominik	Ther	rundal.cz	Ostrava	ther.dominik@gmail.com	t	1112088205	f	2025-11-12 08:18:02.88575	2025-11-12 08:18:02.88575	1991	t	f
2055	Stanislav	Kováček	Ultraman 	Bohumín, Štefaniková 1079	staniko@email.cz	t	1112043407	f	2025-11-12 04:00:41.920467	2025-11-12 04:00:41.920467	1983	t	f
2052	Tomáš	Nejedlý			tomas.nejedly@centrum.cz	t	1110075981	f	2025-11-10 07:38:54.767491	2025-11-10 07:38:54.767491	1979	t	f
2048	Václav 	Boža	LowellPro Runing Team 		vasek.boza@seznam.cz	t	1108174984	f	2025-11-08 17:21:23.082315	2025-11-08 17:21:23.082315	1996	t	f
2051	Petr	Bytomský	Bolatice		petr.bytomsky@seznam.cz	t	1109151113	f	2025-11-09 15:23:11.577288	2025-11-09 15:23:11.577288	1984	t	f
2050	Tomáš	Maliňák	SHS James		malinak@malinak.cz	t	1108203050	f	2025-11-08 20:25:15.934146	2025-11-08 20:25:15.934146	1971	t	t
2027	Zuzana 	Pustková 			Z.koc@seznam.cz	t	1105051943	f	2025-11-05 05:41:58.875205	2025-11-05 05:41:58.875205	1985	f	f
2071	Lukáš	Muras			lukasmuras@seznam.cz	t	1117130131	f	2025-11-17 13:14:31.980755	2025-11-17 13:14:31.980755	1996	t	f
2064	Jan	Fousek	Mk Seitl Ostrava	Ostrava	fousekjan.ob@gmail.com	t	1115071548	f	2025-11-15 07:12:35.729171	2025-11-15 07:12:35.729171	1991	t	f
2067	Rudolf	Šelepa		Frenštát Za Střelnicí 403	tina.fren@seznam.cz	f	1116121630	t	2025-11-16 12:57:11.483378	2025-11-16 12:57:11.483378	1964	t	f
2020	Roman	Baláž 	Baláž EXTREME-TEAM Frenštát p.R.		balazteam@seznam.cz	t	1104205173	f	2025-11-04 20:46:33.243977	2025-11-04 20:46:33.243977	1965	t	f
2049	Vladan	Pupík	Lokomotiva Trojanovice		racochejl83@email.cz	t	1108197245	f	2025-11-08 19:12:57.869374	2025-11-08 19:12:57.869374	1983	t	f
2028	Ivana	Korčeková 			ikorcekova@seznam.cz	t	1105084474	f	2025-11-05 08:11:40.368112	2025-11-05 08:11:40.368112	1982	f	f
2063	Petr	Moravcik	James		petr.moravcik3@gmail.com	t	1114187372	f	2025-11-14 18:40:33.549162	2025-11-14 18:40:33.549162	1981	t	t
2025	Jiří	Grill	Pomalé šípy Kopřivnice		gri032@email.cz	t	1105041862	f	2025-11-05 04:06:19.530215	2025-11-05 04:06:19.530215	1985	t	f
2039	Roman	Král	Oceláci		roman.kk@seznam.cz	t	1105209333	f	2025-11-05 20:09:35.66638	2025-11-05 20:09:35.66638	1969	t	f
2074	Pavlina 	Kurinová	SK ZaFaR Frenštát p.R	Ostrava Michálkovice  č.815	majka.drhova@seznam.cz	t	1117198650	f	2025-11-17 19:11:08.287702	2025-11-17 19:11:08.287702	1970	f	f
2044	Marie 	Drhová Štefanova	SK ZaFaR Frenštát p.R	Frenštát p.R Rožnovská 343	majka.drhova@seznam.cz	t	1107085858	f	2025-11-07 08:37:49.699985	2025-11-07 08:37:49.699985	1970	f	f
2043	Štefan	Groš	SK ZaFaR Frenštát p.R	Frenštát p.R Rožnovská 343	stefangros@seznam.cz	t	1107082711	f	2025-11-07 08:36:45.539074	2025-11-07 08:36:45.539074	1961	t	f
2033	Marek	Halamíček	JenTak	Frenštát pod Radhoštěm	mhalamicek@seznam.cz	t	1105170262	t	2025-11-05 17:10:57.547002	2025-11-05 17:10:57.547002	1975	t	f
2023	Kateřina 	Mertová 	Baláž EXTREME-TEAM Frenštát p.R.		balazteam@seznam.cz	t	1104205017	f	2025-11-04 20:51:04.775306	2025-11-04 20:51:04.775306	1988	f	f
2054	Jan	Šrajer	rundal.cz		srajerjan@gmail.com	t	1111215118	f	2025-11-11 21:29:11.49771	2025-11-11 21:29:11.49771	1991	t	f
2079	Vojtěch	Rajdus			vojta.rajdus@gmail.com	t	1117211158	f	2025-11-17 21:43:23.308403	2025-11-17 21:43:23.308403	1987	t	f
2077	Filip	Káňa	Káňovci	Potoční 646, Frenštát p. R. 	tom.kana@seznam.cz	t	1117196840	f	2025-11-17 19:43:23.714206	2025-11-17 19:43:23.714206	2006	t	f
2076	Štěpán	Káňa	Káňovci	Potoční 646, Frenštát p. R. 	tom.kana@seznam.cz	t	1117199139	f	2025-11-17 19:43:00.452407	2025-11-17 19:43:00.452407	2008	t	f
2078	Tom	Káňa	Káňovci	Potoční 646, Frenštát p. R. 	tom.kana@seznam.cz	t	1117193587	f	2025-11-17 19:44:22.689387	2025-11-17 19:44:22.689387	1976	t	f
2075	Martin	Káňa	Káňovci	Potoční 646, Frenštát p. R. 	tom.kana@seznam.cz	t	1117192637	f	2025-11-17 19:42:23.494406	2025-11-17 19:42:23.494406	2012	t	f
2053	Kamil 	Jeřábek 	Ostrava	Hlavní třídě 568/71 Ostrava 70800	kjerabek64@gmail.com	t	1110158322	f	2025-11-10 15:08:27.617834	2025-11-10 15:08:27.617834	1976	t	f
2082	Michaela	Trilcová 	BO VZS Ostrava		trilcova.michaela@gmail.com	f	1120075648	f	2025-11-20 07:23:30.912225	2025-11-20 07:23:30.912225	1989	f	f
2085	Radim	Murárik	MK Seitl Ostrava	Ostrava Poruba	MurarikRadim@seznam.cz	t	1120087148	f	2025-11-20 08:15:48.427544	2025-11-20 08:15:48.427544	1992	t	f
2086	Tomáš	Bordovský	BUTT Bordovice ultra trail team		bordovskyt@post.cz	t	1120179555	f	2025-11-20 17:14:17.837357	2025-11-20 17:14:17.837357	1987	t	f
2088	Petr	Ďásek	HO START Ostrava	\N	petr.dasek@portaflex.cz	t	0000112101	f	2025-11-21 07:34:31.914864	2025-11-21 07:34:31.914864	1963	t	t
2089	Petr	Mareš	HO START Ostrava	\N	petr.dasek@portaflex.cz	t	0000112102	f	2025-11-21 07:34:31.920888	2025-11-21 07:34:31.920888	1979	t	t
2090	Luděk	Mimra	HO START Ostrava	\N	petr.dasek@portaflex.cz	t	0000112103	f	2025-11-21 07:34:31.925509	2025-11-21 07:34:31.925509	1958	t	t
2091	Jiří	Šrámek	HO START Ostrava	\N	petr.dasek@portaflex.cz	t	0000112104	f	2025-11-21 07:34:31.930522	2025-11-21 07:34:31.930522	1971	t	t
2092	Petr	Sotolář	HO START Ostrava	\N	petr.dasek@portaflex.cz	t	0000112105	f	2025-11-21 07:34:31.934675	2025-11-21 07:34:31.934675	1982	t	t
2093	Lenka	Sotolářová	HO START Ostrava	\N	petr.dasek@portaflex.cz	t	0000112106	f	2025-11-21 07:34:31.943006	2025-11-21 07:34:31.943006	1983	f	t
2084	Pavlína	Rybová	MK Seitl Ostrava	Ostrava Poruba	pavlina.rybova@post.cz	t	1120080624	f	2025-11-20 08:13:56.427943	2025-11-20 08:13:56.427943	1991	f	f
2080	Radovan	Ott	Frenštát 		radovan.ott@seznam.cz	t	1118134726	f	2025-11-18 13:54:48.545198	2025-11-18 13:54:48.545198	1973	t	f
2095	Gabriela	Mikešková		Rožnov pod Radhošťem	gaba.mikes1978@seznam.cz	f	1121155448	f	2025-11-21 15:35:43.438699	2025-11-21 15:35:43.438699	1978	f	f
2109	Jiri	Styskalik	Bike Triatlon Morkovice	Kolaříkova 498, 738 33 Morkovice	jiri.styskalik@geovap.cz	f	1124129453	f	2025-11-24 12:37:39.781396	2025-11-24 12:37:39.781396	1974	t	f
2110	Adam	Bernard	Pro Dřeň na Dřeň		garnat@post.cz	f	1124148564	f	2025-11-24 14:27:13.735551	2025-11-24 14:27:13.735551	1984	t	f
2116	Petr	Vávrová 	HO START OSTRAVA	Stará Ves Nad Ondřejnicí	pavla438@seznam.cz	f	1125062998	f	2025-11-25 06:25:42.789371	2025-11-25 06:25:42.789371	1962	t	t
2117	Petr	Vávra		Stará Ves Nad Ondřejnici	pavla438@seznam.cz	t	1125064553	f	2025-11-25 06:32:11.380697	2025-11-25 06:32:11.380697	1962	t	f
2115	Adéla	Němčíková			adelanemcikova@seznam.cz	t	1124202682	f	2025-11-24 20:59:49.240607	2025-11-24 20:59:49.240607	2004	f	f
2113	David	Fiala	Purple team		davidfiala@centrum.cz	t	1124190607	f	2025-11-24 19:02:57.223013	2025-11-24 19:02:57.223013	1970	t	f
2114	Josef	Bártek	Atletika Nový Jičín	Nový Jičín Beskydská 157	bartisek2@seznam.cz	t	1124207540	f	2025-11-24 20:09:42.016037	2025-11-24 20:09:42.016037	1976	t	f
2105	Vojta	Goláň	AC Sportguides Rožnov p.R.	Hutisko-Solanec 616	vojtech.golan@centrum.cz	t	1124089033	f	2025-11-24 08:22:15.952928	2025-11-24 08:22:15.952928	1983	t	f
2106	Petr	Křístek	HO VŠB Ostrava	Kaňovice 63, 73936 Kaňovice	petr.kristek.st@seznam.cz	t	1124099563	f	2025-11-24 09:55:22.847582	2025-11-24 09:55:22.847582	1987	t	t
2104	Tomáš 	Kocián	LM3X	Trojanovice	kocian.t@seznam.cz	t	1124088401	f	2025-11-24 08:13:00.934426	2025-11-24 08:13:00.934426	1987	t	f
2101	Jan	Filip	Praha 10		Honza.filip@seznam.cz	t	1122182017	f	2025-11-22 18:45:31.869755	2025-11-22 18:45:31.869755	1976	t	f
2100	Martina	Palagyiová			martinap1234@seznam.cz	t	1122184259	f	2025-11-22 18:36:45.778602	2025-11-22 18:36:45.778602	1981	f	f
2094	Milan 	Bezstarosti		I.Šustaly 1106, Kopřivnice 	mbezstarosti@edsystem.cz	t	1121152558	f	2025-11-21 15:32:56.907784	2025-11-21 15:32:56.907784	1972	t	f
2081	Lenka	Vraníková	VZS Ostrava		lenkavranikova@email.cz	t	1120063057	f	2025-11-20 06:41:09.609788	2025-11-20 06:41:09.609788	1972	f	f
2123	Jakub	Plhoň	Mattoni FreeRun Zlín	Grohova 1174,76901 Holešov	plhon.jakub@email.cz	f	1125200045	f	2025-11-25 20:14:00.740649	2025-11-25 20:14:00.740649	1978	t	f
2112	David	Fiala 			davidfiala@centrum.cz	f	1124189891	t	2025-11-24 18:56:37.065309	2025-11-24 18:56:37.065309	1970	t	f
2097	Gabriela	Mikešk9vá		Jaroňkova 1748, Rožnpv pod Radhoštěm	gaba.mikes1978@seznam.cz	f	1121159225	t	2025-11-21 15:37:29.55431	2025-11-21 15:37:29.55431	1978	f	f
2096	Gabriela	Mikešková		Rožnov pod Radhošťem	gaba.mikes1978@seznam.cz	f	1121159728	t	2025-11-21 15:36:20.300989	2025-11-21 15:36:20.300989	1978	f	f
2108	Jiri	Styskalik	Bi		jiri.styskalik@geovap.cz	f	1124128657	t	2025-11-24 12:36:34.681285	2025-11-24 12:36:34.681285	1974	t	f
2099	Roman	Čtvrtečka	ČhS	NOVÝ JIČÍN	ctvrteckaroman@gmail.com	t	1122183951	f	2025-11-22 18:16:06.49623	2025-11-22 18:16:06.49623	1984	t	t
2103	Radomir	Nykl			radomir.nykl@gmail.com	t	1122230999	f	2025-11-22 23:47:43.605339	2025-11-22 23:47:43.605339	1985	t	f
2102	Jitka	Gregořicová	Azimut	Španielova 976/12, Ostrava-Poruba, 70800	jitka.g@post.cz	t	1122203044	f	2025-11-22 20:21:38.418179	2025-11-22 20:21:38.418179	1977	f	t
2120	Zbyněk	Harabiš	Titan Troyer		z.harabis@seznam.cz	t	1125154100	f	2025-11-25 15:51:17.362599	2025-11-25 15:51:17.362599	1965	t	f
2118	Radek	Kubik		Bohumín	raduz.kubik@seznam.cz	t	1125123139	f	2025-11-25 12:37:14.703748	2025-11-25 12:37:14.703748	1978	t	f
2119	Markéta	Kubiková	BK Ludgeřovice	Bohumín	raduz.kubik@seznam.cz	t	1125121839	f	2025-11-25 12:38:56.779339	2025-11-25 12:38:56.779339	1980	f	f
2127	Šimon	Hurta	AC Sportguides Rožnov p.R.		simon.hurta@seznam.cz	t	1126201743	f	2025-11-26 20:35:40.084347	2025-11-26 20:35:40.084347	2009	t	f
2107	Lubomír	Černý		Životice u Nového Jičína	martinalubos@seznam.cz	t	1124106153	f	2025-11-24 10:19:39.84529	2025-11-24 10:19:39.84529	1972	t	f
2098	Jiří	Štývar			styvar.jirik@seznam.cz	t	1121213931	f	2025-11-21 21:16:46.656943	2025-11-21 21:16:46.656943	1989	t	f
2111	Jana	Němčíková			jana.nemcikova1@seznam.cz	t	1124189817	f	2025-11-24 18:50:41.030064	2025-11-24 18:50:41.030064	2000	f	f
2121	Anežka	Procházková	HO Družba Krú Ostrava	V Holotovci 74, Petřvald 73511	anc.proch@gmail.com	t	1125165133	f	2025-11-25 16:40:28.333099	2025-11-25 16:40:28.333099	1997	f	t
2124	Marta	Stražovcová 			malimalinova@seznam.cz	t	1126078760	f	2025-11-26 07:45:42.527028	2025-11-26 07:45:42.527028	1982	f	f
2126	Jiří	Pokluda	BBCHŠ		jrp@email.cz	t	1126170763	f	2025-11-26 17:36:01.913745	2025-11-26 17:36:01.913745	1979	t	f
2125	David	Molek			david.molek114@gmail.com	t	1126100301	f	2025-11-26 10:22:09.023332	2025-11-26 10:22:09.023332	2006	t	f
2122	Tomáš	Martinek		Kunčice pod Ondřejníkem	X-tomas.martinek@swznam.cz	t	1125198043	f	2025-11-25 19:08:27.033047	2025-11-25 19:08:27.033047	1985	t	f
2083	Petra	Schwarzová	VZS Ostrava	Fryčovice 674	pschwarzova@post.cz	t	1120078141	f	2025-11-20 07:51:51.568661	2025-11-20 07:51:51.568661	1968	f	f
2087	Jan	Kratochvil		9. Května 825, Klimkovice	kratochvil.email@seznam.cz	t	1121051505	f	2025-11-21 05:48:07.920242	2025-11-21 05:48:07.920242	1975	t	f
2148	Filip	Kahánek		Frenštát p.R.	kahanekfilip@seznam.cz	f	1128111665	f	2025-11-28 11:59:09.412473	2025-11-28 11:59:09.412473	2001	t	f
2158	Kateřina 	Kurková 	AC Sportguides Rožnov pod Radhoštěm 		kkurkova510@gmail.com	f	1201170680	f	2025-12-01 17:34:12.361746	2025-12-01 17:34:12.361746	2010	f	f
2171	Kateřina 	Havránková 	AK šnek 	Krmelín 	k.havrankova@icloud.com	t	1203163744	f	2025-12-03 16:35:04.760202	2025-12-03 16:35:04.760202	1986	f	f
2159	Kateřina 	Kurková 	AC Sportguides Rožnov pod Radhoštěm 		kkurkova510@gmail.com	t	1201174675	f	2025-12-01 17:34:53.688383	2025-12-01 17:34:53.688383	2010	f	f
2157	Monika	Kociánová			Monika.kocianova107@gmail.com	t	1201133875	f	2025-12-01 13:47:18.018517	2025-12-01 13:47:18.018517	1992	f	f
2156	Tamara	Vantuchová			vantuchovatamara@seznam.cz	t	1201101758	f	2025-12-01 10:30:09.604534	2025-12-01 10:30:09.604534	1976	f	f
2128	Petr	Šimíček	SDH Mniší	\N	simicekp93@gmail.com	t	0000112701	f	2025-11-27 09:50:55.696101	2025-11-27 09:50:55.696101	1979	t	f
2129	Stanislav	Žabenský	SDH Mniší	\N	zabensky.stanislav@gmail.com	t	0000112702	f	2025-11-27 09:51:01.842101	2025-11-27 09:51:01.842101	1991	t	f
2130	Robert	Jalůvka	SDH Mniší	\N	rojal@seznam.cz	t	0000112703	f	2025-11-27 09:51:05.545424	2025-11-27 09:51:05.545424	1976	t	f
2131	Štěpán	Holub	SDH Mniší	\N	stepyh@gmail.com	t	0000112704	f	2025-11-27 09:51:08.136746	2025-11-27 09:51:08.136746	1981	t	f
2132	Ondřej	Marák	SDH Mniší	\N	ondrej.marak@gmail.com	t	0000112705	f	2025-11-27 09:51:10.627909	2025-11-27 09:51:10.627909	1991	t	f
2133	Tomáš	Černošek	SDH Mniší	\N	cernosek6@seznam.cz	t	0000112706	f	2025-11-27 09:51:12.928352	2025-11-27 09:51:12.928352	1994	t	f
2134	Jakub	Marák	SDH Mniší	\N	jakub.marak@gmail.com	t	0000112707	f	2025-11-27 09:51:20.60496	2025-11-27 09:51:20.60496	1994	t	f
2135	Svatopluk	Holub	SDH Mniší	\N	svatopluk.holub@email.cz	t	0000112708	f	2025-11-27 09:51:28.601401	2025-11-27 09:51:28.601401	1977	t	f
2136	Libor	Jurecka	SDH Mniší	\N	simicekp93@gmail.com	t	0000112709	f	2025-11-27 09:51:33.154891	2025-11-27 09:51:33.154891	1980	t	f
2137	Jakub	Klepal	SDH Mniší	\N	simicekp93@gmail.com	t	0000112710	f	2025-11-27 09:51:37.289413	2025-11-27 09:51:37.289413	2010	t	f
2138	Tomáš	Klepal	SDH Mniší	\N	simicekp93@gmail.com	t	0000112711	f	2025-11-27 09:52:18.29735	2025-11-27 09:52:18.29735	2010	t	f
2139	Simon	Holub	SDH Mniší	\N	svatopluk.holub@email.cz	t	0000112712	f	2025-11-27 09:52:21.400029	2025-11-27 09:52:21.400029	2007	t	f
2152	Tomáš	Kubečka		Paskov, Rudé armády 320	kubeckat@seznam.cz	t	1130146321	f	2025-11-30 14:44:56.065397	2025-11-30 14:44:56.065397	1972	t	f
2149	Adam	Sedláček	LA4 RUN	Trojanovice 810	lenkaa.sedlackova@centrum.cz	t	1128142703	f	2025-11-28 14:59:39.040449	2025-11-28 14:59:39.040449	2008	t	f
2150	Lenka	Sedláčková	LA4 RUN	Trojanovice 810	lenkaa.sedlackova@centrum.cz	t	1128159523	f	2025-11-28 15:00:25.582541	2025-11-28 15:00:25.582541	1982	f	f
2147	Veronika	Krčmáriková			veronika.krcmarikova02@gmail.com	t	1128074024	f	2025-11-28 07:48:45.049264	2025-11-28 07:48:45.049264	2002	f	f
2163	Gabriela	Sobková	VRV	Komárno 35	gabisobkova@seznam.cz	f	1202072240	f	2025-12-02 07:37:29.464732	2025-12-02 07:37:29.464732	2000	f	f
2170	Viktor	BALINT	The Minions	Bratislava	victorio@victorio.sk	f	1203168940	f	2025-12-03 16:32:48.580731	2025-12-03 16:32:48.580731	1978	t	f
2172	Dagmar	Imrichová		Limbach	dagmarimrichova@centrum.sk	f	1203167052	f	2025-12-03 16:36:19.321379	2025-12-03 16:36:19.321379	1977	f	f
2178	Vlastimil	Dobeš	Valašské Meziříčí	Lhota 80	vlast.dobes@seznam.cz	f	1203205351	f	2025-12-03 20:27:15.911809	2025-12-03 20:27:15.911809	1970	t	f
2176	Matyáš 	Děcký	AC Sportguides Rožnov pod Radhoštěm 		Petradecka@email.cz	t	1203190658	f	2025-12-03 19:39:47.671167	2025-12-03 19:39:47.671167	2012	t	f
2167	Marek	Škapa	MK Seitl Ostrava		skapamarek@seznam.cz	t	1202207274	f	2025-12-02 20:12:17.777367	2025-12-02 20:12:17.777367	1971	t	f
2174	Ondřej 	Blaha 	Guty	Třinec - Guty	andrew.eu@seznam.cz	t	1203181405	f	2025-12-03 18:31:07.753051	2025-12-03 18:31:07.753051	1986	t	f
2146	Julius	Pšenica 	SK Zafar  Frenstat pod  Radhoštem 	Lidicka 477  Malenovice  Zlín 4	JuliusPsenica@seznam.cz	t	1128067382	f	2025-11-28 06:33:07.993429	2025-11-28 06:33:07.993429	1967	t	f
2175	Dominik 	Čupa		Trojanovice 	lenkaa.sedlackova@centrum.cz	t	1203199774	f	2025-12-03 19:14:32.351945	2025-12-03 19:14:32.351945	2009	t	f
2153	Daniel	Helák	NC Line	Nový Jičín	colalokac@seznam.cz	t	1201053557	f	2025-12-01 05:42:55.33513	2025-12-01 05:42:55.33513	1975	t	f
2165	Igor	Kocurek			igor.kocurek@seznam.cz	t	1202143645	f	2025-12-02 14:37:59.387165	2025-12-02 14:37:59.387165	1974	t	f
2169	Martin 	Jeřábek 	AKEZ Kopřivnice 	Mošnov 42	arch.jerabek@seznam.cz	t	1203122164	f	2025-12-03 12:00:40.486045	2025-12-03 12:00:40.486045	1974	t	f
2161	David	Špaček			david.spacek55@seznam.cz	t	1201190217	f	2025-12-01 19:48:28.919699	2025-12-01 19:48:28.919699	2001	t	f
2168	David	Juračák	TJ Trojanovice Bystré	Trojanovice 785	mira.juracak@gmail.com	t	1203079526	f	2025-12-03 07:42:40.334172	2025-12-03 07:42:40.334172	2008	t	f
2151	Jiří	Vinklárek	TJ Rožnov pod Radhoštěm		jiri.vinklarek@valachnet.cz	t	1129199529	f	2025-11-29 19:42:46.082809	2025-11-29 19:42:46.082809	1961	t	f
2155	Samuel	Punge	StartUp Praha		samuel.punge@gmail.com	t	1201082068	f	2025-12-01 08:32:27.317905	2025-12-01 08:32:27.317905	2006	t	f
2154	Petr	Punge	SK Přerov		petr.punge@seznam.cz	t	1201083386	f	2025-12-01 08:29:39.866036	2025-12-01 08:29:39.866036	1967	t	f
2162	Petr	Girard	SK Skialpin Pustevny		p.girard@centrum.cz	t	1201200620	f	2025-12-01 20:19:33.885498	2025-12-01 20:19:33.885498	1987	t	f
2166	Kowboj	Čert	Pohorská Jednota Radhošť	Frndštát	cowboycz@centrum.cz	t	1202195516	f	2025-12-02 19:28:31.145957	2025-12-02 19:28:31.145957	1987	t	f
2164	Pavel	SLÍVA	Pomalé šípy Kopřivnice		sliva.home@seznam.cz	t	1202081803	f	2025-12-02 08:10:19.167953	2025-12-02 08:10:19.167953	1971	t	f
2160	David	Špaček		Střelniční 980, 74401 Frenštát pod Radhoštěm 	david.spacek815@gmail.com	t	1201196918	f	2025-12-01 19:30:19.096652	2025-12-01 19:30:19.096652	2009	t	f
2179	Onřej	Schwarz	OMASK	\N	omask@centrum.cz	t	1204182370	f	2025-12-04 18:26:27.53859	2025-12-04 18:26:27.53859	1977	t	f
2177	Jan	Kunčický 	AK ŠNEK		honza.kuncicky@seznam.cz	t	1203207563	f	2025-12-03 20:16:09.6544	2025-12-03 20:16:09.6544	1999	t	f
2173	Matěj	Havránek	AK Šnek 	Krmelín 	k.havrankova@icloud.com	t	1203169358	f	2025-12-03 16:37:44.379318	2025-12-03 16:37:44.379318	1983	t	f
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (version) FROM stdin;
20151028222115
20151103011643
20151202214517
20161004171402
20161004212310
20180930211906
20191008211645
\.


--
-- Name: entrants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.entrants_id_seq', 2179, true);


--
-- Name: entrants entrants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entrants
    ADD CONSTRAINT entrants_pkey PRIMARY KEY (id);


--
-- Name: index_entrants_on_variable_symbol; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entrants_on_variable_symbol ON public.entrants USING btree (variable_symbol);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: extension_before_drop; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER extension_before_drop ON ddl_command_start
   EXECUTE FUNCTION _heroku.extension_before_drop();


--
-- Name: log_create_ext; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER log_create_ext ON ddl_command_end
   EXECUTE FUNCTION _heroku.create_ext();


--
-- Name: log_drop_ext; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER log_drop_ext ON sql_drop
   EXECUTE FUNCTION _heroku.drop_ext();


--
-- Name: validate_extension; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER validate_extension ON ddl_command_end
   EXECUTE FUNCTION _heroku.validate_extension();


--
-- PostgreSQL database dump complete
--

\unrestrict EMuFDUc0z3auEGbZRMgZV9EuBVRxuNF74c1Vb6rzP38sCXaksdJKNSg7bwKK13P

