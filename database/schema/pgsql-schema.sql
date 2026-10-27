--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

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
-- Name: attendance_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendance_records (
    id integer NOT NULL,
    employee_management_id bigint,
    attendance_area character varying(100),
    attendance_point_name character varying(100),
    verification_mode character varying(100),
    attendance_photo character varying,
    data_sources character varying,
    record_date timestamp without time zone,
    earliest_time character varying(20),
    latest_time character varying(20),
    weekday character varying(20),
    biometric_imports_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    late boolean,
    late_hours bigint,
    late_minutes bigint,
    leaves boolean,
    is_manual boolean DEFAULT false NOT NULL,
    original_earliest_time character varying(20),
    original_latest_time character varying(20),
    edited_by character varying(100),
    edited_at timestamp(0) without time zone
);


--
-- Name: attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendance_id_seq OWNED BY public.attendance_records.id;


--
-- Name: attendance_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendance_logs (
    id integer NOT NULL,
    user_id integer,
    action character varying(155),
    "timestamp" timestamp(6) without time zone,
    ip_address character varying(45),
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone
);


--
-- Name: attendance_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendance_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendance_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendance_logs_id_seq OWNED BY public.attendance_logs.id;


--
-- Name: biometric_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.biometric_imports (
    id integer NOT NULL,
    title character varying(100),
    status character varying(100) DEFAULT 'load'::character varying,
    imported_by character varying(100),
    imported_at character varying(100),
    total_rows character varying(100),
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    is_locked boolean,
    locked_by character varying(50),
    locked_at date,
    unlocked_by character varying(50),
    unlocked_at date,
    period_start date,
    period_end date
);


--
-- Name: biometric_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.biometric_imports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: biometric_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.biometric_imports_id_seq OWNED BY public.biometric_imports.id;


--
-- Name: business_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business_units (
    id integer NOT NULL,
    name character varying(100),
    head character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: business_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.business_unit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: business_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.business_unit_id_seq OWNED BY public.business_units.id;


--
-- Name: certificate_attendance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificate_attendance (
    id integer NOT NULL,
    employee_management_id bigint,
    earliest_time character varying(20),
    latest_time character varying(20),
    others text,
    reason text,
    date date,
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    approval_status character varying DEFAULT 'Pending'::character varying,
    weekday character varying(20),
    action character varying(50) DEFAULT 'add'::character varying,
    attendance_area character varying(100),
    biometric_imports_id integer,
    is_cutoff boolean DEFAULT false,
    attendance_records_id integer
);


--
-- Name: certificate_attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certificate_attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificate_attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificate_attendance_id_seq OWNED BY public.certificate_attendance.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name character varying(100),
    head character varying(100),
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    business_unit_id integer
);


--
-- Name: company_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.company_id_seq OWNED BY public.companies.id;


--
-- Name: csvimports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.csvimports (
    id bigint NOT NULL,
    entry_date date,
    basic character varying(255),
    dh character varying(255),
    dh_nd character varying(255),
    dh_nd_excess character varying(255),
    dh_nd_ot character varying(255),
    dh_ot character varying(255),
    dh_rd character varying(255),
    dh_rd_nd character varying(255),
    dh_rd_nd_ot character varying(255),
    dh_rd_ot character varying(255),
    hours_worked character varying(255),
    id_number character varying(255),
    lh character varying(255),
    lh_nd character varying(255),
    lh_nd_excess character varying(255),
    lh_nd_ot character varying(255),
    lh_ot character varying(255),
    lh_rd character varying(255),
    lh_rd_nd character varying(255),
    lh_rd_nd_excess character varying(255),
    lh_rd_nd_ot character varying(255),
    lh_rd_ot character varying(255),
    name character varying(255),
    ord_nd character varying(255),
    ord_nd_ot character varying(255),
    ord_ot character varying(255),
    rd character varying(255),
    rd_nd character varying(255),
    rd_nd_ot character varying(255),
    rd_ot character varying(255),
    reg_nd_excess character varying(255),
    sh character varying(255),
    sh_nd character varying(255),
    sh_nd_excess character varying(255),
    sh_nd_ot character varying(255),
    sh_ot character varying(255),
    sh_rd character varying(255),
    sh_rd_nd character varying(255),
    sh_rd_nd_excess character varying(255),
    sh_rd_nd_ot character varying(255),
    sh_rd_ot character varying(255),
    sun_nd_excess character varying(255),
    total_non_working_days_present character varying(255),
    total_regular_working_days_present character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    generate_status boolean DEFAULT false,
    biometric_imports_id integer,
    period_start date,
    period_end date
);


--
-- Name: csvimports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.csvimports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: csvimports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.csvimports_id_seq OWNED BY public.csvimports.id;


--
-- Name: custom_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_dates (
    id bigint NOT NULL,
    record_date timestamp without time zone,
    title character varying,
    holiday_type character varying
);


--
-- Name: custom_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.custom_dates ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.custom_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    department_name character varying(250),
    department_head integer,
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    company_id integer
);


--
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.department_id_seq OWNED BY public.departments.id;


--
-- Name: dtr_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dtr_report (
    id integer NOT NULL,
    employee_management_id bigint,
    type character varying(250),
    record_date timestamp without time zone,
    adjustments character varying(250),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    biometric_imports_id integer,
    hours bigint
);


--
-- Name: dtr_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dtr_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dtr_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dtr_report_id_seq OWNED BY public.dtr_report.id;


--
-- Name: employee_management; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_management (
    id bigint NOT NULL,
    unique_id character varying(255) NOT NULL,
    employee_name character varying(255) NOT NULL,
    basic_salary character varying(255) DEFAULT 'Not Assigned'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    department character varying(100) DEFAULT 'Not Assigned'::character varying,
    report_to character varying(100) DEFAULT 'Not Assigned'::character varying,
    schedule character varying(100) DEFAULT '7-16'::character varying,
    relievers boolean,
    serial_number character varying(100),
    rank character varying(20),
    schedule_shift character varying(50),
    biometric_id integer,
    status character varying(50),
    reliever boolean DEFAULT false
);


--
-- Name: employee_management_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employee_management_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_management_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employee_management_id_seq OWNED BY public.employee_management.id;


--
-- Name: employee_management_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.employee_management ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.employee_management_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: leaves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leaves (
    id integer NOT NULL,
    employee_management_id bigint,
    status character varying(100),
    record_date timestamp without time zone,
    leave_type character varying(100),
    reason character varying(250),
    with_pay boolean,
    biometric_imports_id integer,
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    weekday character varying(20),
    others text,
    attendance_records_id integer
);


--
-- Name: leaves_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leaves_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leaves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leaves_id_seq OWNED BY public.leaves.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: overtimes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.overtimes (
    id bigint NOT NULL,
    unique_id character varying(255),
    first_name character varying(125),
    last_name character varying(125),
    employee_name character varying(255),
    earliest_time character varying(20),
    latest_time character varying(20),
    type character varying(10),
    department character varying(200),
    attendance_area character varying(50),
    serial_number character varying(20),
    schedule character varying(10),
    ord_ot character varying(10),
    ord_nd character varying(10),
    ord_nd_ot character varying(10),
    rd character varying(10),
    rd_ot character varying(10),
    rd_nd character varying(10),
    rd_nd_ot character varying(10),
    total_non_working_days_present bigint,
    late boolean,
    late_hours bigint,
    late_minutes bigint,
    out_time_required character varying(10),
    record_date timestamp(6) without time zone,
    status character varying(50) DEFAULT 'Pending'::character varying,
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    original_earliest_time character varying(20),
    original_latest_time character varying(20),
    biometric_imports_id integer,
    schedule_shift character varying(50),
    attendance_records_id integer,
    employee_management_id bigint
);


--
-- Name: overtime_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.overtimes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.overtime_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_resets (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: schedule_adjustments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedule_adjustments (
    id bigint NOT NULL,
    earliest_time character varying(20),
    latest_time character varying(20),
    attendance_area character varying(50),
    late boolean,
    late_hours bigint,
    late_minutes bigint,
    approval_status character varying(10) DEFAULT 'Pending'::character varying,
    action character varying(50),
    record_date timestamp without time zone,
    employee_management_id bigint,
    total_non_working_days_present integer,
    schedule character varying(100),
    out_time_required character(100),
    others character varying(100),
    reason character varying(100),
    weekday character varying(100),
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    biometric_imports_id integer,
    attendance_records_id integer
);


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules (
    id integer NOT NULL,
    schedule_name character varying(100),
    schedule_type character varying(100),
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone,
    schedule_shift character varying(50)
);


--
-- Name: schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schedule_id_seq OWNED BY public.schedules.id;


--
-- Name: security_attendance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_attendance (
    id integer NOT NULL,
    employee_management_id bigint NOT NULL,
    earliest_time character varying(20),
    latest_time character varying(20),
    hours_worked bigint,
    record_date timestamp without time zone,
    weekday character varying,
    ot bigint,
    nd bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    biometric_imports_id integer
);


--
-- Name: security_attendance_employee_management_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.security_attendance_employee_management_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: security_attendance_employee_management_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.security_attendance_employee_management_id_seq OWNED BY public.security_attendance.employee_management_id;


--
-- Name: security_attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.security_attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: security_attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.security_attendance_id_seq OWNED BY public.security_attendance.id;


--
-- Name: temp_sched_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.schedule_adjustments ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.temp_sched_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    role character varying(100) DEFAULT 'user'::character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: attendance_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_logs ALTER COLUMN id SET DEFAULT nextval('public.attendance_logs_id_seq'::regclass);


--
-- Name: attendance_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records ALTER COLUMN id SET DEFAULT nextval('public.attendance_id_seq'::regclass);


--
-- Name: biometric_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_imports ALTER COLUMN id SET DEFAULT nextval('public.biometric_imports_id_seq'::regclass);


--
-- Name: business_units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_units ALTER COLUMN id SET DEFAULT nextval('public.business_unit_id_seq'::regclass);


--
-- Name: certificate_attendance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_attendance ALTER COLUMN id SET DEFAULT nextval('public.certificate_attendance_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.company_id_seq'::regclass);


--
-- Name: csvimports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csvimports ALTER COLUMN id SET DEFAULT nextval('public.csvimports_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.department_id_seq'::regclass);


--
-- Name: dtr_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dtr_report ALTER COLUMN id SET DEFAULT nextval('public.dtr_report_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: leaves id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaves ALTER COLUMN id SET DEFAULT nextval('public.leaves_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedule_id_seq'::regclass);


--
-- Name: security_attendance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_attendance ALTER COLUMN id SET DEFAULT nextval('public.security_attendance_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: attendance_logs attendance_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_logs
    ADD CONSTRAINT attendance_logs_pkey PRIMARY KEY (id);


--
-- Name: attendance_records attendance_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_pkey PRIMARY KEY (id);


--
-- Name: biometric_imports biometric_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_imports
    ADD CONSTRAINT biometric_imports_pkey PRIMARY KEY (id);


--
-- Name: business_units business_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_units
    ADD CONSTRAINT business_units_pkey PRIMARY KEY (id);


--
-- Name: certificate_attendance certificate_attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_attendance
    ADD CONSTRAINT certificate_attendance_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: csvimports csvimports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csvimports
    ADD CONSTRAINT csvimports_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: dtr_report dtr_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dtr_report
    ADD CONSTRAINT dtr_report_pkey PRIMARY KEY (id);


--
-- Name: employee_management employee_management_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_management
    ADD CONSTRAINT employee_management_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: leaves leaves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaves
    ADD CONSTRAINT leaves_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: overtimes overtimes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtimes
    ADD CONSTRAINT overtimes_pkey PRIMARY KEY (id);


--
-- Name: password_resets password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_pkey PRIMARY KEY (email);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: schedule_adjustments schedule_adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule_adjustments
    ADD CONSTRAINT schedule_adjustments_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: security_attendance security_attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_attendance
    ADD CONSTRAINT security_attendance_pkey PRIMARY KEY (id);


--
-- Name: custom_dates unique_record_title; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_dates
    ADD CONSTRAINT unique_record_title UNIQUE (record_date, title);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: attendance_logs_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attendance_logs_user_id_index ON public.attendance_logs USING btree (user_id);


--
-- Name: attendance_records_biometric_imports_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attendance_records_biometric_imports_id_index ON public.attendance_records USING btree (biometric_imports_id);


--
-- Name: attendance_records_employee_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attendance_records_employee_date_index ON public.attendance_records USING btree (employee_management_id, record_date);


--
-- Name: attendance_records_employee_management_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attendance_records_employee_management_id_index ON public.attendance_records USING btree (employee_management_id);


--
-- Name: certificate_attendance_attendance_records_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX certificate_attendance_attendance_records_id_index ON public.certificate_attendance USING btree (attendance_records_id);


--
-- Name: certificate_attendance_biometric_imports_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX certificate_attendance_biometric_imports_id_index ON public.certificate_attendance USING btree (biometric_imports_id);


--
-- Name: certificate_attendance_employee_management_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX certificate_attendance_employee_management_id_index ON public.certificate_attendance USING btree (employee_management_id);


--
-- Name: companies_business_unit_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX companies_business_unit_id_index ON public.companies USING btree (business_unit_id);


--
-- Name: csvimports_biometric_imports_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX csvimports_biometric_imports_id_index ON public.csvimports USING btree (biometric_imports_id);


--
-- Name: departments_company_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX departments_company_id_index ON public.departments USING btree (company_id);


--
-- Name: dtr_report_biometric_imports_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dtr_report_biometric_imports_id_index ON public.dtr_report USING btree (biometric_imports_id);


--
-- Name: dtr_report_employee_management_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dtr_report_employee_management_id_index ON public.dtr_report USING btree (employee_management_id);


--
-- Name: leaves_attendance_records_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX leaves_attendance_records_id_index ON public.leaves USING btree (attendance_records_id);


--
-- Name: leaves_biometric_imports_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX leaves_biometric_imports_id_index ON public.leaves USING btree (biometric_imports_id);


--
-- Name: leaves_employee_management_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX leaves_employee_management_id_index ON public.leaves USING btree (employee_management_id);


--
-- Name: overtimes_attendance_records_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX overtimes_attendance_records_id_index ON public.overtimes USING btree (attendance_records_id);


--
-- Name: overtimes_biometric_imports_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX overtimes_biometric_imports_id_index ON public.overtimes USING btree (biometric_imports_id);


--
-- Name: overtimes_employee_management_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX overtimes_employee_management_id_index ON public.overtimes USING btree (employee_management_id);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: schedule_adjustments_attendance_records_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedule_adjustments_attendance_records_id_index ON public.schedule_adjustments USING btree (attendance_records_id);


--
-- Name: schedule_adjustments_biometric_imports_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedule_adjustments_biometric_imports_id_index ON public.schedule_adjustments USING btree (biometric_imports_id);


--
-- Name: schedule_adjustments_employee_management_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedule_adjustments_employee_management_id_index ON public.schedule_adjustments USING btree (employee_management_id);


--
-- Name: security_attendance_biometric_imports_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX security_attendance_biometric_imports_id_index ON public.security_attendance USING btree (biometric_imports_id);


--
-- Name: security_attendance_employee_management_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX security_attendance_employee_management_id_index ON public.security_attendance USING btree (employee_management_id);


--
-- Name: attendance_logs attendance_logs_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_logs
    ADD CONSTRAINT attendance_logs_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: attendance_records attendance_records_biometric_imports_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_biometric_imports_id_foreign FOREIGN KEY (biometric_imports_id) REFERENCES public.biometric_imports(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: attendance_records attendance_records_employee_management_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_employee_management_id_foreign FOREIGN KEY (employee_management_id) REFERENCES public.employee_management(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: certificate_attendance certificate_attendance_attendance_records_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_attendance
    ADD CONSTRAINT certificate_attendance_attendance_records_id_foreign FOREIGN KEY (attendance_records_id) REFERENCES public.attendance_records(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: certificate_attendance certificate_attendance_biometric_imports_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_attendance
    ADD CONSTRAINT certificate_attendance_biometric_imports_id_foreign FOREIGN KEY (biometric_imports_id) REFERENCES public.biometric_imports(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: certificate_attendance certificate_attendance_employee_management_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_attendance
    ADD CONSTRAINT certificate_attendance_employee_management_id_foreign FOREIGN KEY (employee_management_id) REFERENCES public.employee_management(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: companies companies_business_unit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_business_unit_id_foreign FOREIGN KEY (business_unit_id) REFERENCES public.business_units(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: csvimports csvimports_biometric_imports_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csvimports
    ADD CONSTRAINT csvimports_biometric_imports_id_foreign FOREIGN KEY (biometric_imports_id) REFERENCES public.biometric_imports(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: departments departments_company_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_company_id_foreign FOREIGN KEY (company_id) REFERENCES public.companies(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: dtr_report dtr_report_biometric_imports_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dtr_report
    ADD CONSTRAINT dtr_report_biometric_imports_id_foreign FOREIGN KEY (biometric_imports_id) REFERENCES public.biometric_imports(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: dtr_report dtr_report_employee_management_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dtr_report
    ADD CONSTRAINT dtr_report_employee_management_id_foreign FOREIGN KEY (employee_management_id) REFERENCES public.employee_management(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: leaves leaves_attendance_records_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaves
    ADD CONSTRAINT leaves_attendance_records_id_foreign FOREIGN KEY (attendance_records_id) REFERENCES public.attendance_records(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: leaves leaves_biometric_imports_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaves
    ADD CONSTRAINT leaves_biometric_imports_id_foreign FOREIGN KEY (biometric_imports_id) REFERENCES public.biometric_imports(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: leaves leaves_employee_management_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaves
    ADD CONSTRAINT leaves_employee_management_id_foreign FOREIGN KEY (employee_management_id) REFERENCES public.employee_management(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: overtimes overtimes_attendance_records_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtimes
    ADD CONSTRAINT overtimes_attendance_records_id_foreign FOREIGN KEY (attendance_records_id) REFERENCES public.attendance_records(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: overtimes overtimes_biometric_imports_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtimes
    ADD CONSTRAINT overtimes_biometric_imports_id_foreign FOREIGN KEY (biometric_imports_id) REFERENCES public.biometric_imports(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: overtimes overtimes_employee_management_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.overtimes
    ADD CONSTRAINT overtimes_employee_management_id_foreign FOREIGN KEY (employee_management_id) REFERENCES public.employee_management(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: schedule_adjustments schedule_adjustments_attendance_records_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule_adjustments
    ADD CONSTRAINT schedule_adjustments_attendance_records_id_foreign FOREIGN KEY (attendance_records_id) REFERENCES public.attendance_records(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: schedule_adjustments schedule_adjustments_biometric_imports_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule_adjustments
    ADD CONSTRAINT schedule_adjustments_biometric_imports_id_foreign FOREIGN KEY (biometric_imports_id) REFERENCES public.biometric_imports(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: schedule_adjustments schedule_adjustments_employee_management_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule_adjustments
    ADD CONSTRAINT schedule_adjustments_employee_management_id_foreign FOREIGN KEY (employee_management_id) REFERENCES public.employee_management(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: security_attendance security_attendance_biometric_imports_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_attendance
    ADD CONSTRAINT security_attendance_biometric_imports_id_foreign FOREIGN KEY (biometric_imports_id) REFERENCES public.biometric_imports(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: security_attendance security_attendance_employee_management_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_attendance
    ADD CONSTRAINT security_attendance_employee_management_id_foreign FOREIGN KEY (employee_management_id) REFERENCES public.employee_management(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

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
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	2014_10_12_000000_create_users_table	1
2	2014_10_12_100000_create_password_resets_table	1
3	2019_08_19_000000_create_failed_jobs_table	1
4	2019_12_14_000001_create_personal_access_tokens_table	1
5	2024_10_28_061014_create_csvimports_table	2
6	2024_11_02_050750_create_employee_management_table	3
7	2026_09_22_093731_add_role_to_users_table	4
8	2026_09_25_000001_add_period_to_biometric_imports_table	5
9	2026_09_25_000002_add_manual_audit_to_attendance_records_table	6
12	2026_09_28_000001_add_period_to_csvimports_table	8
13	2026_09_29_000001_drop_stub_tables	8
14	2026_09_29_000002_standardize_foreign_keys	8
\.


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 14, true);


--
-- PostgreSQL database dump complete
--

