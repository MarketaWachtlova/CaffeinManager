--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.13
-- Dumped by pg_dump version 9.5.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: caffeine_manager; Type: DATABASE; Schema: -
--

CREATE DATABASE caffeine_manager WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect caffeine_manager

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: coffee_drinker; Type: TABLE; Schema: public
--

CREATE TABLE public.coffee_drinker (
    id integer NOT NULL,
    login character varying(50) NOT NULL,
    password text NOT NULL,
    email text NOT NULL
);


--
-- Name: coffee_drinker_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.coffee_drinker_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coffee_drinker_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.coffee_drinker_id_seq OWNED BY public.coffee_drinker.id;


--
-- Name: coffee_machine; Type: TABLE; Schema: public
--

CREATE TABLE public.coffee_machine (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    caffeine integer NOT NULL
);


--
-- Name: coffee_machine_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.coffee_machine_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coffee_machine_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.coffee_machine_id_seq OWNED BY public.coffee_machine.id;


--
-- Name: coffee_sale; Type: TABLE; Schema: public
--

CREATE TABLE public.coffee_sale (
    id integer NOT NULL,
    "time" timestamp with time zone,
    coffee_drinker_id integer,
    coffee_machine_id integer
);


--
-- Name: coffee_sale_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.coffee_sale_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coffee_sale_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.coffee_sale_id_seq OWNED BY public.coffee_sale.id;


--
-- Name: id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.coffee_drinker ALTER COLUMN id SET DEFAULT nextval('public.coffee_drinker_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.coffee_machine ALTER COLUMN id SET DEFAULT nextval('public.coffee_machine_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.coffee_sale ALTER COLUMN id SET DEFAULT nextval('public.coffee_sale_id_seq'::regclass);


--
-- Name: coffee_drinker_email_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.coffee_drinker
    ADD CONSTRAINT coffee_drinker_email_key UNIQUE (email);


--
-- Name: coffee_drinker_login_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.coffee_drinker
    ADD CONSTRAINT coffee_drinker_login_key UNIQUE (login);


--
-- Name: coffee_drinker_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.coffee_drinker
    ADD CONSTRAINT coffee_drinker_pkey PRIMARY KEY (id);


--
-- Name: coffee_machine_name_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.coffee_machine
    ADD CONSTRAINT coffee_machine_name_key UNIQUE (name);


--
-- Name: coffee_machine_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.coffee_machine
    ADD CONSTRAINT coffee_machine_pkey PRIMARY KEY (id);


--
-- Name: coffee_sale_coffee_drinker_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.coffee_sale
    ADD CONSTRAINT coffee_sale_coffee_drinker_id_fkey FOREIGN KEY (coffee_drinker_id) REFERENCES public.coffee_drinker(id);


--
-- Name: coffee_sale_coffee_machine_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.coffee_sale
    ADD CONSTRAINT coffee_sale_coffee_machine_id_fkey FOREIGN KEY (coffee_machine_id) REFERENCES public.coffee_machine(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

