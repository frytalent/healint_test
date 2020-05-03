--
-- PostgreSQL database dump
--

-- Dumped from database version 12.2 (Ubuntu 12.2-4)
-- Dumped by pg_dump version 12.2 (Ubuntu 12.2-4)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ip_country; Type: TABLE; Schema: public; Owner: gene
--

CREATE TABLE public.ip_country (
    ip_from numeric,
    ip_to numeric,
    registry character varying(50),
    assigned numeric,
    ctry character varying(50),
    cntry character varying(50),
    country character varying(50)
);


ALTER TABLE public.ip_country OWNER TO gene;

--
-- Name: top10; Type: TABLE; Schema: public; Owner: gene
--

CREATE TABLE public.top10 (
    ctry text,
    user_count bigint,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.top10 OWNER TO gene;

--
-- Name: user_ip; Type: TABLE; Schema: public; Owner: gene
--

CREATE TABLE public.user_ip (
    userid integer,
    ip_address character varying(50)
);


ALTER TABLE public.user_ip OWNER TO gene;

--
-- Name: ix_top10_ctry; Type: INDEX; Schema: public; Owner: gene
--

CREATE INDEX ix_top10_ctry ON public.top10 USING btree (ctry);


--
-- PostgreSQL database dump complete
--

