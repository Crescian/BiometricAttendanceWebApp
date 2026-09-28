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
-- Data for Name: attendance_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attendance_logs (id, user_id, action, "timestamp", ip_address, created_at, updated_at) FROM stdin;
295	6	login	2026-09-09 16:29:50	172.23.0.1	2026-09-09 16:29:50	2026-09-09 16:29:50
296	6	login	2026-09-16 11:10:43	172.22.0.1	2026-09-16 11:10:43	2026-09-16 11:10:43
297	6	login	2026-09-16 14:30:33	172.22.0.1	2026-09-16 14:30:33	2026-09-16 14:30:33
298	26	login	2026-09-16 15:26:44	172.22.0.1	2026-09-16 15:26:44	2026-09-16 15:26:44
299	6	login	2026-09-18 10:13:56	172.26.0.1	2026-09-18 10:13:56	2026-09-18 10:13:56
300	26	login	2026-09-18 15:24:33	172.26.0.1	2026-09-18 15:24:33	2026-09-18 15:24:33
301	6	login	2026-09-18 16:10:47	172.26.0.1	2026-09-18 16:10:47	2026-09-18 16:10:47
302	\N	failed_login	2026-09-21 15:40:03	172.26.0.1	2026-09-21 15:40:03	2026-09-21 15:40:03
303	26	login	2026-09-21 15:40:22	172.26.0.1	2026-09-21 15:40:22	2026-09-21 15:40:22
304	6	login	2026-09-22 08:21:46	172.26.0.1	2026-09-22 08:21:46	2026-09-22 08:21:46
305	6	logout	2026-09-22 09:25:14	172.27.0.1	2026-09-22 09:25:14	2026-09-22 09:25:14
306	6	login	2026-09-22 09:25:26	172.27.0.1	2026-09-22 09:25:26	2026-09-22 09:25:26
307	6	logout	2026-09-22 09:25:33	172.27.0.1	2026-09-22 09:25:33	2026-09-22 09:25:33
308	6	login	2026-09-22 09:26:10	172.27.0.1	2026-09-22 09:26:10	2026-09-22 09:26:10
309	6	logout	2026-09-22 09:26:19	172.27.0.1	2026-09-22 09:26:19	2026-09-22 09:26:19
310	6	login	2026-09-22 09:26:42	172.27.0.1	2026-09-22 09:26:42	2026-09-22 09:26:42
311	6	logout	2026-09-22 09:32:32	172.27.0.1	2026-09-22 09:32:32	2026-09-22 09:32:32
312	6	login	2026-09-22 09:53:37	172.27.0.1	2026-09-22 09:53:37	2026-09-22 09:53:37
313	6	logout	2026-09-22 09:54:02	172.27.0.1	2026-09-22 09:54:02	2026-09-22 09:54:02
314	27	login	2026-09-22 09:54:58	172.27.0.1	2026-09-22 09:54:58	2026-09-22 09:54:58
315	27	logout	2026-09-22 09:55:07	172.27.0.1	2026-09-22 09:55:07	2026-09-22 09:55:07
316	27	login	2026-09-22 09:55:10	172.27.0.1	2026-09-22 09:55:10	2026-09-22 09:55:10
317	27	logout	2026-09-22 09:55:26	172.27.0.1	2026-09-22 09:55:26	2026-09-22 09:55:26
318	6	login	2026-09-22 09:56:39	172.27.0.1	2026-09-22 09:56:39	2026-09-22 09:56:39
319	6	login	2026-09-22 13:31:04	172.27.0.1	2026-09-22 13:31:04	2026-09-22 13:31:04
320	6	logout	2026-09-22 13:31:10	172.27.0.1	2026-09-22 13:31:10	2026-09-22 13:31:10
321	6	login	2026-09-22 13:32:50	172.27.0.1	2026-09-22 13:32:50	2026-09-22 13:32:50
322	6	logout	2026-09-22 13:35:49	172.27.0.1	2026-09-22 13:35:49	2026-09-22 13:35:49
323	26	login	2026-09-22 13:37:53	172.27.0.1	2026-09-22 13:37:53	2026-09-22 13:37:53
324	16	login	2026-09-22 13:38:05	172.27.0.1	2026-09-22 13:38:05	2026-09-22 13:38:05
325	16	logout	2026-09-22 13:38:10	172.27.0.1	2026-09-22 13:38:10	2026-09-22 13:38:10
326	16	login	2026-09-22 13:56:28	172.27.0.1	2026-09-22 13:56:28	2026-09-22 13:56:28
327	19	login	2026-09-22 13:56:52	172.27.0.1	2026-09-22 13:56:52	2026-09-22 13:56:52
328	19	logout	2026-09-22 13:57:07	172.27.0.1	2026-09-22 13:57:07	2026-09-22 13:57:07
329	16	logout	2026-09-22 13:57:43	172.27.0.1	2026-09-22 13:57:43	2026-09-22 13:57:43
330	16	login	2026-09-22 14:00:07	172.27.0.1	2026-09-22 14:00:07	2026-09-22 14:00:07
331	16	login	2026-09-22 14:01:38	172.27.0.1	2026-09-22 14:01:38	2026-09-22 14:01:38
332	27	login	2026-09-22 14:10:34	172.27.0.1	2026-09-22 14:10:34	2026-09-22 14:10:34
333	27	logout	2026-09-22 14:10:39	172.27.0.1	2026-09-22 14:10:39	2026-09-22 14:10:39
334	16	logout	2026-09-22 14:15:23	172.27.0.1	2026-09-22 14:15:23	2026-09-22 14:15:23
335	27	login	2026-09-22 14:15:32	172.27.0.1	2026-09-22 14:15:32	2026-09-22 14:15:32
336	27	login	2026-09-22 14:15:33	172.27.0.1	2026-09-22 14:15:33	2026-09-22 14:15:33
337	27	logout	2026-09-22 14:52:24	172.27.0.1	2026-09-22 14:52:24	2026-09-22 14:52:24
338	6	login	2026-09-22 15:16:18	172.27.0.1	2026-09-22 15:16:18	2026-09-22 15:16:18
339	6	login	2026-09-25 13:19:21	172.25.0.1	2026-09-25 13:19:21	2026-09-25 13:19:21
341	26	login	2026-09-28 12:01:02	172.25.0.1	2026-09-28 12:01:02	2026-09-28 12:01:02
342	6	login	2026-09-28 13:23:57	172.26.0.1	2026-09-28 13:23:57	2026-09-28 13:23:57
343	26	logout	2026-09-28 15:14:41	172.26.0.1	2026-09-28 15:14:41	2026-09-28 15:14:41
\.


--
-- Data for Name: attendance_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attendance_records (id, employee_management_id, attendance_area, attendance_point_name, verification_mode, attendance_photo, data_sources, record_date, earliest_time, latest_time, weekday, biometric_imports_id, created_at, updated_at, late, late_hours, late_minutes, leaves, is_manual, original_earliest_time, original_latest_time, edited_by, edited_at) FROM stdin;
66235	93	MANUAL	\N	\N	\N	Manual Entry	2026-08-26 00:00:00	08:25:00	16:25:00	Wednesday	14	2026-09-28 13:25:49	2026-09-28 13:25:49	f	0	0	f	t	\N	\N	CML (Developer)	2026-09-28 13:25:49
63723	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-24 00:00:00	06:00:59	16:54:08	Monday	12	2026-09-09 11:21:56	2026-09-09 11:21:56	f	0	0	f	f	\N	\N	\N	\N
65175	431	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065723-504.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:23	17:51:59	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65176	431	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065723-504.jpg	Time Attendance Device	2026-08-18 00:00:00	07:01:42	17:52:21	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65177	431	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065723-504.jpg	Time Attendance Device	2026-08-24 00:00:00	07:53:28	19:49:39	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65178	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-10 00:00:00	11:24:00	19:51:38	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65179	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-11 00:00:00	11:13:47	19:50:19	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65180	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-12 00:00:00	10:56:21	20:15:21	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65181	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-13 00:00:00	12:12:06	19:50:35	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65182	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-14 00:00:00	14:31:27	19:50:21	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65183	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-15 00:00:00	12:10:47	19:50:12	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65184	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-17 00:00:00	10:46:47	19:00:10	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65185	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-18 00:00:00	11:36:00	19:50:05	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65186	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-19 00:00:00	10:27:08	19:00:27	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65187	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-20 00:00:00	11:18:32	19:50:08	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65188	542	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810112400-233.jpg	Time Attendance Device	2026-08-24 00:00:00	07:19:59	19:23:44	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65189	459	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065250-306.jpg	Time Attendance Device	2026-08-11 00:00:00	06:52:50	18:00:53	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65190	459	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065250-306.jpg	Time Attendance Device	2026-08-12 00:00:00	07:12:42	18:05:19	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65191	459	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065250-306.jpg	Time Attendance Device	2026-08-13 00:00:00	07:06:25	18:00:27	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65192	459	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065250-306.jpg	Time Attendance Device	2026-08-14 00:00:00	07:11:35	18:00:15	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65193	459	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065250-306.jpg	Time Attendance Device	2026-08-15 00:00:00	07:01:47	16:00:09	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65194	459	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065250-306.jpg	Time Attendance Device	2026-08-19 00:00:00	07:08:35	16:03:41	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65195	459	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065250-306.jpg	Time Attendance Device	2026-08-20 00:00:00	07:12:35	16:05:03	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65196	459	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065250-306.jpg	Time Attendance Device	2026-08-22 00:00:00	07:07:45	16:04:46	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65197	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-10 00:00:00	07:06:34	17:51:04	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65198	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-11 00:00:00	06:54:29	17:51:14	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65199	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-12 00:00:00	06:52:27	17:49:03	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65200	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-13 00:00:00	07:05:29	17:50:02	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65201	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-17 00:00:00	07:19:06	17:50:38	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65202	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-18 00:00:00	07:05:14	17:51:44	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65203	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-19 00:00:00	07:04:37	17:50:38	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65204	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-20 00:00:00	06:56:36	17:50:14	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65205	130	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070634-555.jpg	Time Attendance Device	2026-08-24 00:00:00	07:01:51	19:00:13	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65206	348	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065927-1150.jpg	Time Attendance Device	2026-08-10 00:00:00	06:59:27	17:31:22	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65207	348	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065927-1150.jpg	Time Attendance Device	2026-08-11 00:00:00	06:58:57	18:00:49	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65208	348	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065927-1150.jpg	Time Attendance Device	2026-08-13 00:00:00	07:19:15	17:48:50	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65209	348	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065927-1150.jpg	Time Attendance Device	2026-08-14 00:00:00	07:23:11	15:55:30	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65210	348	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065927-1150.jpg	Time Attendance Device	2026-08-18 00:00:00	07:04:23	17:52:58	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65211	348	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065927-1150.jpg	Time Attendance Device	2026-08-19 00:00:00	07:07:03	17:55:15	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65212	348	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065927-1150.jpg	Time Attendance Device	2026-08-20 00:00:00	07:11:06	17:33:23	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65213	348	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065927-1150.jpg	Time Attendance Device	2026-08-24 00:00:00	07:05:42	19:01:43	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65214	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-11 00:00:00	06:06:24	18:21:16	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65215	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-12 00:00:00	06:02:55	18:46:13	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65216	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-14 00:00:00	06:07:45	16:43:10	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65217	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-17 00:00:00	06:07:16	18:56:02	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65218	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-18 00:00:00	07:15:31	18:54:13	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65219	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-19 00:00:00	07:01:15	18:00:09	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65220	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-20 00:00:00	07:06:13	18:00:42	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65221	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-21 00:00:00	06:47:44	16:00:13	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65222	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-24 00:00:00	07:07:55	18:00:45	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65223	454	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184804-197.jpg	Time Attendance Device	2026-08-25 00:00:00	07:15:03	18:00:28	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65224	466	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812102942-880.jpg	Time Attendance Device	2026-08-13 00:00:00	07:20:10	17:51:18	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65225	466	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812102942-880.jpg	Time Attendance Device	2026-08-18 00:00:00	07:01:21	18:09:57	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65226	466	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812102942-880.jpg	Time Attendance Device	2026-08-20 00:00:00	07:01:48	17:54:26	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65227	466	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812102942-880.jpg	Time Attendance Device	2026-08-24 00:00:00	07:00:15	17:53:22	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65228	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-10 00:00:00	06:55:38	17:53:21	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65229	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:10	17:50:40	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65230	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-12 00:00:00	06:58:02	17:49:43	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65231	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-13 00:00:00	07:00:27	17:48:57	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65232	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-14 00:00:00	06:58:38	15:50:41	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65233	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-18 00:00:00	06:56:11	17:50:32	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65234	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-19 00:00:00	06:56:43	17:53:15	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65235	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-20 00:00:00	06:59:04	17:51:21	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65236	505	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065538-1425.jpg	Time Attendance Device	2026-08-24 00:00:00	06:59:59	17:53:15	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65237	10	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070214-1466.jpg	Time Attendance Device	2026-08-17 00:00:00	07:02:14	17:51:52	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65238	10	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070214-1466.jpg	Time Attendance Device	2026-08-18 00:00:00	07:00:46	17:52:31	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65239	10	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070214-1466.jpg	Time Attendance Device	2026-08-19 00:00:00	07:00:12	17:51:38	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65240	10	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070214-1466.jpg	Time Attendance Device	2026-08-20 00:00:00	07:01:26	17:47:05	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65241	10	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070214-1466.jpg	Time Attendance Device	2026-08-24 00:00:00	06:59:54	17:52:36	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65242	540	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065942-682.jpg	Time Attendance Device	2026-08-10 00:00:00	06:59:42	18:00:48	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65243	540	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065942-682.jpg	Time Attendance Device	2026-08-11 00:00:00	06:52:37	17:52:43	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65244	540	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065942-682.jpg	Time Attendance Device	2026-08-12 00:00:00	07:13:57	17:50:49	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65245	540	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065942-682.jpg	Time Attendance Device	2026-08-13 00:00:00	07:20:02	17:55:57	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65246	540	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065942-682.jpg	Time Attendance Device	2026-08-14 00:00:00	07:14:02	15:53:26	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65247	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-10 00:00:00	06:49:26	18:00:42	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65248	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-11 00:00:00	06:42:41	18:01:32	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65249	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-12 00:00:00	06:55:57	17:50:34	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65250	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-13 00:00:00	06:53:39	17:50:51	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65251	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-14 00:00:00	06:53:23	15:52:32	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65252	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-17 00:00:00	07:12:51	17:50:47	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65253	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-18 00:00:00	06:48:21	17:55:37	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65254	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-19 00:00:00	06:55:19	17:52:16	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65255	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-20 00:00:00	06:55:29	17:53:15	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65256	386	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064926-1139.jpg	Time Attendance Device	2026-08-24 00:00:00	06:44:01	19:00:22	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65257	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-10 00:00:00	07:02:10	17:52:19	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65258	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-11 00:00:00	06:55:55	17:52:26	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65259	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-12 00:00:00	07:00:41	17:54:35	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65260	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-13 00:00:00	06:51:43	17:50:24	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65261	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-14 00:00:00	07:12:57	15:56:02	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65262	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-17 00:00:00	07:12:41	17:52:11	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65263	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-18 00:00:00	06:55:32	17:53:21	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65264	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-19 00:00:00	06:54:19	17:51:40	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65265	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-20 00:00:00	06:56:13	17:50:33	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65266	57	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070210-383.jpg	Time Attendance Device	2026-08-24 00:00:00	06:59:05	19:05:23	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65267	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-10 00:00:00	07:13:20	17:52:07	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65268	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-11 00:00:00	06:56:28	17:50:57	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65269	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-12 00:00:00	07:05:32	17:51:26	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65270	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-13 00:00:00	07:21:02	17:52:47	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65271	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-14 00:00:00	06:58:54	15:55:34	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65272	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-17 00:00:00	07:03:18	17:51:32	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65273	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-18 00:00:00	07:04:41	17:52:16	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65274	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-19 00:00:00	07:09:32	17:54:29	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65275	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-20 00:00:00	07:07:43	17:50:46	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65276	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-21 00:00:00	06:56:51	15:56:55	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65277	506	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810071320-1415.jpg	Time Attendance Device	2026-08-24 00:00:00	07:10:28	18:01:02	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65278	455	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184755-198.jpg	Time Attendance Device	2026-08-11 00:00:00	07:17:06	18:00:36	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65279	455	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184755-198.jpg	Time Attendance Device	2026-08-13 00:00:00	07:08:35	18:01:35	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65280	455	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184755-198.jpg	Time Attendance Device	2026-08-14 00:00:00	06:09:58	16:43:13	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65281	455	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184755-198.jpg	Time Attendance Device	2026-08-18 00:00:00	07:11:42	18:54:20	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65282	455	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184755-198.jpg	Time Attendance Device	2026-08-19 00:00:00	07:12:20	18:01:32	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65283	455	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184755-198.jpg	Time Attendance Device	2026-08-20 00:00:00	07:06:58	18:00:35	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65284	455	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184755-198.jpg	Time Attendance Device	2026-08-24 00:00:00	07:07:22	18:00:47	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65285	455	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810184755-198.jpg	Time Attendance Device	2026-08-25 00:00:00	07:08:34	18:00:55	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65286	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-10 00:00:00	06:58:31	13:57:58	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65287	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-12 00:00:00	06:55:47	17:55:03	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65288	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-13 00:00:00	07:16:49	17:50:20	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65289	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-14 00:00:00	06:33:36	15:54:25	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65290	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-17 00:00:00	07:06:41	17:52:37	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65291	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-18 00:00:00	07:11:16	17:55:08	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65292	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-19 00:00:00	07:11:41	17:55:05	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65293	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-20 00:00:00	07:14:21	17:55:02	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65294	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-22 00:00:00	06:15:06	14:55:01	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65295	333	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065831-1414.jpg	Time Attendance Device	2026-08-24 00:00:00	06:57:37	17:55:11	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65296	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-10 00:00:00	07:04:54	18:07:19	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65297	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-11 00:00:00	07:06:57	18:01:17	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65298	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-12 00:00:00	07:08:07	17:55:09	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65299	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-13 00:00:00	07:18:41	17:55:46	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65300	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-17 00:00:00	07:10:36	17:55:13	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65301	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-18 00:00:00	07:01:30	17:55:33	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65302	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-19 00:00:00	07:10:52	17:55:28	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65303	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-20 00:00:00	06:56:30	17:55:14	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65304	338	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070454-222.jpg	Time Attendance Device	2026-08-24 00:00:00	06:57:33	19:04:51	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65305	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-10 00:00:00	21:47:42	07:02:28	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65306	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-11 00:00:00	21:50:55	07:02:05	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65307	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-12 00:00:00	22:13:09	07:03:04	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65308	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-13 00:00:00	21:40:58	07:02:51	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65309	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-14 00:00:00	21:46:39	07:02:39	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65310	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-15 00:00:00	21:43:38	07:04:32	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65311	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-17 00:00:00	21:54:56	07:02:12	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65312	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-18 00:00:00	21:44:41	07:02:33	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65313	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-19 00:00:00	21:41:23	07:02:08	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65314	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-20 00:00:00	21:45:45	07:01:09	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65315	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-22 00:00:00	21:53:10	07:01:12	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65316	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-24 00:00:00	21:26:53	07:02:09	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65317	286	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810214742-1474.jpg	Time Attendance Device	2026-08-25 00:00:00	19:44:10	07:00:53	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65318	287	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811210234-1113.jpg	Time Attendance Device	2026-08-18 00:00:00	07:00:37	21:06:50	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65319	287	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811210234-1113.jpg	Time Attendance Device	2026-08-19 00:00:00	07:00:18	20:56:03	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65320	287	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811210234-1113.jpg	Time Attendance Device	2026-08-20 00:00:00	07:00:31	20:42:42	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65321	287	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811210234-1113.jpg	Time Attendance Device	2026-08-25 00:00:00	07:05:13	21:01:26	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65322	306	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811203853-733.jpg	Time Attendance Device	2026-08-12 00:00:00	07:00:54	21:29:57	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65323	306	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811203853-733.jpg	Time Attendance Device	2026-08-13 00:00:00	07:01:43	20:49:36	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65324	306	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811203853-733.jpg	Time Attendance Device	2026-08-14 00:00:00	07:03:24	20:55:02	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65325	306	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811203853-733.jpg	Time Attendance Device	2026-08-15 00:00:00	07:03:32	20:54:25	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65326	306	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811203853-733.jpg	Time Attendance Device	2026-08-18 00:00:00	07:00:03	21:04:04	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65327	306	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811203853-733.jpg	Time Attendance Device	2026-08-19 00:00:00	07:00:08	21:12:37	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65328	306	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811203853-733.jpg	Time Attendance Device	2026-08-20 00:00:00	07:00:06	21:33:30	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65329	306	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811203853-733.jpg	Time Attendance Device	2026-08-25 00:00:00	07:04:59	20:57:03	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65330	185	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817064828-286.jpg	Time Attendance Device	2026-08-17 00:00:00	06:48:28	17:51:20	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65331	185	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817064828-286.jpg	Time Attendance Device	2026-08-18 00:00:00	06:47:41	17:54:35	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65332	185	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817064828-286.jpg	Time Attendance Device	2026-08-19 00:00:00	06:51:27	17:52:57	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65333	185	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817064828-286.jpg	Time Attendance Device	2026-08-20 00:00:00	07:01:57	17:50:29	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65334	185	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817064828-286.jpg	Time Attendance Device	2026-08-24 00:00:00	06:51:22	17:51:23	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65335	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-10 00:00:00	06:47:42	17:54:09	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65336	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:31	17:57:08	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65337	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-12 00:00:00	07:07:37	17:54:46	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65338	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-13 00:00:00	07:06:31	17:57:36	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65339	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-14 00:00:00	07:01:36	15:59:26	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65340	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-17 00:00:00	07:08:48	17:56:44	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65341	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-18 00:00:00	07:03:44	17:56:00	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65342	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-19 00:00:00	07:00:05	17:55:47	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65343	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-20 00:00:00	07:01:13	17:56:26	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65344	85	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064742-1356.jpg	Time Attendance Device	2026-08-24 00:00:00	06:53:43	17:55:53	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65345	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-10 00:00:00	06:54:32	17:51:36	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65346	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-11 00:00:00	06:58:25	17:51:02	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65347	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-12 00:00:00	06:58:24	17:50:20	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65348	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-13 00:00:00	07:00:32	17:49:10	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65349	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-14 00:00:00	06:57:16	15:51:09	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65350	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-18 00:00:00	07:01:09	17:51:30	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65351	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-19 00:00:00	07:00:38	17:50:40	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65352	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-20 00:00:00	06:59:33	17:52:49	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65353	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-24 00:00:00	07:00:17	17:53:48	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65354	321	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065432-1808.jpg	Time Attendance Device	2026-08-26 00:00:00	06:54:42	06:59:23	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65355	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-10 00:00:00	07:31:19	17:53:10	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65356	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:57	17:52:34	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65357	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-12 00:00:00	06:58:27	17:54:39	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65358	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-13 00:00:00	07:01:09	17:50:39	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65359	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-14 00:00:00	06:59:49	15:55:54	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65360	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-17 00:00:00	07:05:49	17:52:14	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65361	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-18 00:00:00	06:55:36	17:53:24	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65362	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-19 00:00:00	06:54:26	17:52:10	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65363	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-20 00:00:00	06:56:17	17:50:37	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65364	40	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810073119-716.jpg	Time Attendance Device	2026-08-24 00:00:00	07:10:58	17:53:44	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65365	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-10 00:00:00	06:54:21	17:53:14	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65366	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-11 00:00:00	06:58:42	17:51:48	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65367	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-12 00:00:00	06:55:07	17:47:28	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65368	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-13 00:00:00	07:11:38	17:50:58	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65369	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-14 00:00:00	06:57:31	15:52:28	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65370	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-17 00:00:00	06:59:47	17:51:26	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65371	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-18 00:00:00	06:57:17	17:51:52	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65372	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-19 00:00:00	06:58:20	17:52:21	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65373	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-20 00:00:00	06:55:17	17:51:45	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65374	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-21 00:00:00	07:12:02	17:04:42	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65375	503	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065421-683.jpg	Time Attendance Device	2026-08-24 00:00:00	07:07:37	19:11:56	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65376	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-10 00:00:00	06:58:08	17:52:26	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65377	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-11 00:00:00	06:56:03	17:52:22	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65378	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-12 00:00:00	06:55:18	17:53:53	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65379	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-13 00:00:00	06:55:31	17:48:28	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65380	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-14 00:00:00	06:55:45	15:55:05	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65381	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-18 00:00:00	06:56:46	17:52:25	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65382	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-19 00:00:00	06:57:26	17:51:28	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65383	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-20 00:00:00	06:59:23	17:47:27	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65384	49	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065808-1475.jpg	Time Attendance Device	2026-08-24 00:00:00	06:54:23	17:52:50	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65385	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-10 00:00:00	06:55:06	17:55:37	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65386	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-11 00:00:00	06:58:17	17:54:43	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65387	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-12 00:00:00	06:59:07	17:50:56	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65388	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-13 00:00:00	06:44:24	17:51:12	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65389	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-14 00:00:00	06:57:12	15:51:14	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65390	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-17 00:00:00	07:02:32	17:54:34	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65391	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-18 00:00:00	06:49:43	17:54:06	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65392	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-19 00:00:00	06:56:38	17:54:53	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65393	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-20 00:00:00	06:59:19	17:56:41	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65394	448	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065506-1751.jpg	Time Attendance Device	2026-08-24 00:00:00	07:00:24	17:52:44	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65395	78	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065735-1419.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:35	17:49:27	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65396	78	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065735-1419.jpg	Time Attendance Device	2026-08-12 00:00:00	06:55:42	17:50:01	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65397	78	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065735-1419.jpg	Time Attendance Device	2026-08-13 00:00:00	06:55:25	17:49:21	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65398	78	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065735-1419.jpg	Time Attendance Device	2026-08-14 00:00:00	06:56:02	15:49:23	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65399	78	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065735-1419.jpg	Time Attendance Device	2026-08-17 00:00:00	06:59:54	17:50:59	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65400	78	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065735-1419.jpg	Time Attendance Device	2026-08-18 00:00:00	06:55:45	17:51:00	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65401	78	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065735-1419.jpg	Time Attendance Device	2026-08-20 00:00:00	06:55:34	17:49:29	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65402	78	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065735-1419.jpg	Time Attendance Device	2026-08-24 00:00:00	06:54:19	17:50:11	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65403	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-10 00:00:00	06:54:01	17:50:45	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65404	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:40	17:49:46	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65405	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-12 00:00:00	06:56:54	17:47:58	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65406	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-13 00:00:00	06:27:44	17:48:53	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65407	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-17 00:00:00	06:59:25	17:50:26	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65408	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-18 00:00:00	06:56:02	17:50:31	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65409	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-19 00:00:00	06:57:44	17:55:18	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65410	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-20 00:00:00	06:55:39	17:49:45	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65411	465	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065401-1660.jpg	Time Attendance Device	2026-08-24 00:00:00	06:55:38	17:50:30	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65412	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-10 00:00:00	10:00:45	18:51:46	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65413	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-11 00:00:00	11:07:02	18:50:03	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65414	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-12 00:00:00	09:42:02	18:50:58	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65415	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-13 00:00:00	09:58:55	18:50:28	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65416	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-14 00:00:00	09:59:19	18:50:11	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65417	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-15 00:00:00	06:51:35	15:50:04	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65418	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-18 00:00:00	06:59:57	17:50:18	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65419	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-19 00:00:00	06:57:09	17:50:03	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65420	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-20 00:00:00	06:55:25	17:49:41	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65421	275	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810100045-1675.jpg	Time Attendance Device	2026-08-24 00:00:00	06:52:15	15:50:04	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65422	204	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-13/20260813070040-251.jpg	Time Attendance Device	2026-08-13 00:00:00	07:00:40	17:50:47	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65423	204	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-13/20260813070040-251.jpg	Time Attendance Device	2026-08-15 00:00:00	06:41:45	18:02:35	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65424	204	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-13/20260813070040-251.jpg	Time Attendance Device	2026-08-16 00:00:00	06:41:55	15:59:19	Sunday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65425	204	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-13/20260813070040-251.jpg	Time Attendance Device	2026-08-17 00:00:00	06:59:04	17:50:54	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65426	204	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-13/20260813070040-251.jpg	Time Attendance Device	2026-08-18 00:00:00	06:55:28	17:52:08	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65427	204	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-13/20260813070040-251.jpg	Time Attendance Device	2026-08-19 00:00:00	06:57:05	17:50:05	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65428	204	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-13/20260813070040-251.jpg	Time Attendance Device	2026-08-20 00:00:00	06:54:53	17:50:24	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65429	204	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-13/20260813070040-251.jpg	Time Attendance Device	2026-08-24 00:00:00	06:55:16	17:50:19	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65430	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-11 00:00:00	06:56:59	17:48:57	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65431	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-12 00:00:00	06:56:59	17:49:12	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65432	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-13 00:00:00	07:00:54	17:49:29	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65433	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-14 00:00:00	06:56:52	15:50:48	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65434	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-17 00:00:00	06:59:14	17:51:05	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65435	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-18 00:00:00	06:55:58	17:50:56	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65436	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-19 00:00:00	06:57:15	17:51:00	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65437	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-20 00:00:00	06:55:03	17:50:01	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65438	90	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811065659-1686.jpg	Time Attendance Device	2026-08-24 00:00:00	06:55:27	17:49:17	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65439	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-10 00:00:00	06:54:06	17:50:27	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65440	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:02	17:49:37	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65441	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-12 00:00:00	06:56:30	17:49:21	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65442	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-13 00:00:00	07:00:45	17:49:49	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65443	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-14 00:00:00	06:56:36	15:49:39	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65444	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-17 00:00:00	06:59:02	17:50:39	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65445	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-18 00:00:00	06:55:42	17:50:55	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65446	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-19 00:00:00	06:57:20	17:50:52	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65447	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-20 00:00:00	06:54:54	17:50:06	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65448	86	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065406-265.jpg	Time Attendance Device	2026-08-24 00:00:00	06:55:05	19:00:17	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65449	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-10 00:00:00	06:56:22	18:00:03	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65450	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-11 00:00:00	06:54:24	18:00:04	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65451	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-12 00:00:00	06:50:06	18:00:04	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65452	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-13 00:00:00	06:54:43	18:00:03	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65453	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-14 00:00:00	06:56:47	16:00:20	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65454	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-17 00:00:00	06:55:42	18:00:04	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65455	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-18 00:00:00	06:50:06	18:00:19	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65456	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-19 00:00:00	06:51:20	18:00:15	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65457	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-20 00:00:00	06:56:51	18:00:15	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65458	92	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065622-1145.jpg	Time Attendance Device	2026-08-24 00:00:00	06:49:14	18:00:05	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65459	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-10 00:00:00	06:59:53	17:52:41	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65460	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-11 00:00:00	06:58:27	17:52:07	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65461	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-12 00:00:00	06:53:30	17:54:27	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65462	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-13 00:00:00	06:54:34	17:50:29	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65463	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-14 00:00:00	06:50:22	15:55:02	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65464	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-17 00:00:00	06:46:29	17:51:42	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65465	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-18 00:00:00	06:53:14	17:53:17	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65466	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-19 00:00:00	06:45:08	17:52:06	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65467	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-20 00:00:00	06:56:08	17:50:40	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65468	47	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065953-1277.jpg	Time Attendance Device	2026-08-24 00:00:00	06:47:11	17:53:35	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65469	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-10 00:00:00	06:57:38	17:51:01	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65470	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-11 00:00:00	07:00:21	17:49:56	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65471	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-12 00:00:00	06:51:54	17:48:58	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65472	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-13 00:00:00	07:06:08	17:49:33	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65473	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-14 00:00:00	07:03:04	15:49:16	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65474	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-17 00:00:00	07:13:32	17:52:26	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65475	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-18 00:00:00	07:03:57	17:51:57	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65476	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-20 00:00:00	06:40:28	17:49:47	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65477	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-22 00:00:00	08:29:53	17:53:54	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65478	122	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065738-1285.jpg	Time Attendance Device	2026-08-24 00:00:00	06:40:47	17:54:26	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65479	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-10 00:00:00	06:44:56	18:04:23	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65480	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:35	18:04:52	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65481	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-12 00:00:00	06:47:12	18:01:09	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65482	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-13 00:00:00	07:01:03	18:03:56	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65483	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-14 00:00:00	07:07:37	16:01:40	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65484	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-17 00:00:00	06:53:56	18:01:47	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65485	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-18 00:00:00	07:04:17	18:02:18	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65486	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-19 00:00:00	06:55:40	18:04:10	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65487	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-20 00:00:00	06:46:23	18:01:05	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65488	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-24 00:00:00	06:42:21	18:04:12	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65489	6	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810064456-232.jpg	Time Attendance Device	2026-08-25 00:00:00	06:50:49	18:01:03	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65490	249	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-24/20260824064804-256.jpg	Time Attendance Device	2026-08-24 00:00:00	06:48:04	17:51:09	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65491	137	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070136-228.jpg	Time Attendance Device	2026-08-10 00:00:00	07:01:36	18:01:05	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65492	137	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070136-228.jpg	Time Attendance Device	2026-08-11 00:00:00	07:01:27	18:00:18	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65493	137	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070136-228.jpg	Time Attendance Device	2026-08-12 00:00:00	06:57:09	18:00:18	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65494	137	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070136-228.jpg	Time Attendance Device	2026-08-13 00:00:00	07:08:59	18:00:39	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65495	137	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070136-228.jpg	Time Attendance Device	2026-08-14 00:00:00	07:07:21	15:56:13	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65496	137	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070136-228.jpg	Time Attendance Device	2026-08-19 00:00:00	06:37:53	17:52:30	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65497	137	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070136-228.jpg	Time Attendance Device	2026-08-20 00:00:00	06:43:41	18:00:34	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65498	137	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070136-228.jpg	Time Attendance Device	2026-08-24 00:00:00	06:53:03	18:00:55	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65499	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-10 00:00:00	06:26:27	16:51:26	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65500	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-11 00:00:00	06:13:31	16:50:39	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65501	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-12 00:00:00	06:22:04	16:55:43	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65502	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-13 00:00:00	06:36:17	16:58:56	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65503	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-14 00:00:00	07:07:49	15:50:27	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65504	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-17 00:00:00	06:30:34	16:53:18	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65505	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-18 00:00:00	06:12:05	16:59:01	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65506	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-19 00:00:00	06:14:13	16:57:26	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65507	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-20 00:00:00	06:14:53	17:02:30	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65508	46	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062627-442.jpg	Time Attendance Device	2026-08-24 00:00:00	06:41:41	16:50:30	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65509	546	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065147-1295.jpg	Time Attendance Device	2026-08-10 00:00:00	06:51:47	16:00:43	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65510	546	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065147-1295.jpg	Time Attendance Device	2026-08-12 00:00:00	06:35:29	16:05:53	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65511	546	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065147-1295.jpg	Time Attendance Device	2026-08-14 00:00:00	06:40:24	16:05:38	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65512	546	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065147-1295.jpg	Time Attendance Device	2026-08-19 00:00:00	06:17:45	16:01:44	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65513	546	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065147-1295.jpg	Time Attendance Device	2026-08-20 00:00:00	06:29:37	16:02:19	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65514	546	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065147-1295.jpg	Time Attendance Device	2026-08-23 00:00:00	06:49:01	16:04:15	Sunday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65515	546	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065147-1295.jpg	Time Attendance Device	2026-08-24 00:00:00	06:47:04	16:03:14	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65516	546	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065147-1295.jpg	Time Attendance Device	2026-08-25 00:00:00	06:52:09	16:00:40	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65517	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-10 00:00:00	06:51:09	16:01:22	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65518	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-11 00:00:00	06:46:24	08:38:31	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65519	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-13 00:00:00	06:43:19	16:03:18	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65520	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-16 00:00:00	06:42:19	16:03:23	Sunday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65521	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-18 00:00:00	06:33:33	16:01:59	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65522	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-19 00:00:00	06:26:16	16:01:02	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65523	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-20 00:00:00	06:33:44	16:00:09	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65524	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-23 00:00:00	06:41:30	16:04:52	Sunday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65525	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-24 00:00:00	06:40:30	16:01:09	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65526	314	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065109-737.jpg	Time Attendance Device	2026-08-25 00:00:00	06:43:40	16:00:34	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65527	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-10 00:00:00	07:01:25	17:55:05	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65528	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-11 00:00:00	06:29:36	17:55:11	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65529	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-12 00:00:00	06:45:26	17:49:30	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65530	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-13 00:00:00	06:35:46	17:55:29	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65531	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-17 00:00:00	06:52:18	17:59:12	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65532	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-18 00:00:00	06:51:15	17:53:32	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65533	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-19 00:00:00	06:45:37	17:58:16	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65534	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-20 00:00:00	06:31:15	17:49:24	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65535	464	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070125-960.jpg	Time Attendance Device	2026-08-24 00:00:00	06:40:42	17:56:31	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65536	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-10 00:00:00	06:51:01	17:50:41	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65537	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-11 00:00:00	06:40:02	17:49:52	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65538	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-12 00:00:00	06:42:46	17:48:42	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65539	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-13 00:00:00	06:44:32	17:50:07	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65540	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-14 00:00:00	06:46:04	15:49:28	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65541	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-17 00:00:00	06:55:52	17:52:23	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65542	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-18 00:00:00	06:34:02	17:51:48	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65543	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-19 00:00:00	06:39:54	17:50:31	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65544	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-20 00:00:00	06:34:14	17:50:21	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65545	215	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065101-271.jpg	Time Attendance Device	2026-08-24 00:00:00	06:39:13	17:50:50	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65546	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-10 00:00:00	03:10:38	15:35:57	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65547	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-11 00:00:00	03:09:15	15:31:50	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65548	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-12 00:00:00	03:10:07	15:20:58	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65549	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-13 00:00:00	03:13:30	15:46:53	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65550	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-14 00:00:00	03:11:10	15:24:30	Friday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65551	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-15 00:00:00	03:05:43	15:35:55	Saturday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65552	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-17 00:00:00	06:56:01	17:54:49	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65553	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-18 00:00:00	06:48:49	17:51:41	Tuesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65554	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-19 00:00:00	06:30:02	17:55:24	Wednesday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65555	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-20 00:00:00	06:46:20	17:53:09	Thursday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65556	500	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810031038-272.jpg	Time Attendance Device	2026-08-24 00:00:00	06:45:00	17:54:00	Monday	14	2026-09-22 15:04:40	2026-09-22 15:04:40	f	0	0	f	f	\N	\N	\N	\N
65557	77	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812055835-1081.jpg	Time Attendance Device	2026-08-12 00:00:00	05:58:35	16:51:15	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65558	77	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812055835-1081.jpg	Time Attendance Device	2026-08-13 00:00:00	06:07:38	16:48:53	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65559	77	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812055835-1081.jpg	Time Attendance Device	2026-08-14 00:00:00	06:36:18	15:51:56	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65560	77	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812055835-1081.jpg	Time Attendance Device	2026-08-17 00:00:00	06:15:00	16:52:43	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65561	77	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812055835-1081.jpg	Time Attendance Device	2026-08-18 00:00:00	06:01:32	16:53:49	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65562	77	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812055835-1081.jpg	Time Attendance Device	2026-08-19 00:00:00	06:03:01	16:53:40	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65563	77	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812055835-1081.jpg	Time Attendance Device	2026-08-20 00:00:00	06:51:14	17:00:50	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65564	77	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-12/20260812055835-1081.jpg	Time Attendance Device	2026-08-24 00:00:00	06:25:33	16:51:15	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65565	50	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060931-1080.jpg	Time Attendance Device	2026-08-10 00:00:00	06:09:31	16:51:05	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65566	50	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060931-1080.jpg	Time Attendance Device	2026-08-11 00:00:00	05:43:29	16:51:44	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65567	50	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060931-1080.jpg	Time Attendance Device	2026-08-13 00:00:00	05:51:52	16:48:20	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65568	50	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060931-1080.jpg	Time Attendance Device	2026-08-14 00:00:00	06:44:28	15:48:48	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65569	50	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060931-1080.jpg	Time Attendance Device	2026-08-18 00:00:00	06:20:16	16:52:17	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65570	50	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060931-1080.jpg	Time Attendance Device	2026-08-19 00:00:00	05:46:10	16:52:22	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65571	50	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060931-1080.jpg	Time Attendance Device	2026-08-24 00:00:00	06:10:59	16:51:09	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65572	329	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814065551-1182.jpg	Time Attendance Device	2026-08-14 00:00:00	06:55:51	15:54:31	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65573	329	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814065551-1182.jpg	Time Attendance Device	2026-08-17 00:00:00	07:00:20	17:52:32	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65574	329	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814065551-1182.jpg	Time Attendance Device	2026-08-18 00:00:00	06:56:17	17:55:17	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65575	329	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814065551-1182.jpg	Time Attendance Device	2026-08-19 00:00:00	06:58:02	17:55:11	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65576	329	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814065551-1182.jpg	Time Attendance Device	2026-08-20 00:00:00	07:02:09	17:55:09	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65577	329	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814065551-1182.jpg	Time Attendance Device	2026-08-22 00:00:00	06:15:11	14:55:12	Saturday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65578	329	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814065551-1182.jpg	Time Attendance Device	2026-08-24 00:00:00	06:24:03	19:00:48	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65579	480	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054803-1450.jpg	Time Attendance Device	2026-08-10 00:00:00	05:48:03	18:04:21	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65580	480	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054803-1450.jpg	Time Attendance Device	2026-08-11 00:00:00	05:48:48	17:53:56	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65581	480	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054803-1450.jpg	Time Attendance Device	2026-08-12 00:00:00	06:00:29	15:57:01	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65582	480	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054803-1450.jpg	Time Attendance Device	2026-08-13 00:00:00	05:47:27	15:07:04	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65583	480	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054803-1450.jpg	Time Attendance Device	2026-08-14 00:00:00	06:09:05	15:03:35	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65584	480	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054803-1450.jpg	Time Attendance Device	2026-08-15 00:00:00	06:09:59	12:06:09	Saturday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65585	480	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054803-1450.jpg	Time Attendance Device	2026-08-24 00:00:00	06:23:40	17:54:43	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65586	462	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-24/20260824060247-995.jpg	Time Attendance Device	2026-08-24 00:00:00	06:02:47	18:30:33	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65587	462	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-24/20260824060247-995.jpg	Time Attendance Device	2026-08-25 00:00:00	06:10:36	18:30:16	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65588	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-10 00:00:00	06:00:36	16:53:26	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65589	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-11 00:00:00	06:07:40	16:53:44	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65590	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-12 00:00:00	06:00:43	16:54:24	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65591	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-13 00:00:00	06:07:08	16:50:34	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65592	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-14 00:00:00	06:44:56	15:52:55	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65593	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-17 00:00:00	06:19:59	16:54:11	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65594	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-18 00:00:00	05:59:36	16:55:17	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65595	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-19 00:00:00	05:59:34	16:54:16	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65596	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-20 00:00:00	06:02:37	16:58:56	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65597	64	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060036-1197.jpg	Time Attendance Device	2026-08-24 00:00:00	06:08:28	16:55:09	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65598	68	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055555-1089.jpg	Time Attendance Device	2026-08-10 00:00:00	05:55:55	16:55:02	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65599	68	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055555-1089.jpg	Time Attendance Device	2026-08-11 00:00:00	06:01:57	16:50:09	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65600	68	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055555-1089.jpg	Time Attendance Device	2026-08-12 00:00:00	06:06:08	16:50:13	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65601	68	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055555-1089.jpg	Time Attendance Device	2026-08-14 00:00:00	07:07:42	15:49:42	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65602	68	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055555-1089.jpg	Time Attendance Device	2026-08-17 00:00:00	06:08:39	16:52:14	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65603	68	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055555-1089.jpg	Time Attendance Device	2026-08-19 00:00:00	05:59:30	18:00:47	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65604	68	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055555-1089.jpg	Time Attendance Device	2026-08-20 00:00:00	06:56:58	17:11:57	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65605	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-10 00:00:00	05:57:16	16:56:20	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65606	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-11 00:00:00	06:05:25	16:55:39	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65607	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-12 00:00:00	05:56:35	16:55:02	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65608	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-13 00:00:00	06:10:03	16:55:44	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65609	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-14 00:00:00	06:41:17	15:53:59	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65610	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-17 00:00:00	06:10:37	16:54:35	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65611	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-18 00:00:00	06:01:07	16:56:11	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65612	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-20 00:00:00	06:00:57	17:02:24	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65613	37	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055716-399.jpg	Time Attendance Device	2026-08-24 00:00:00	06:14:56	16:55:30	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65614	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-10 00:00:00	06:04:06	16:55:45	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65615	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-11 00:00:00	06:07:45	16:55:48	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65616	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-12 00:00:00	05:50:43	16:54:48	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65617	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-13 00:00:00	06:06:58	16:51:12	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65618	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-14 00:00:00	06:47:39	15:53:32	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65619	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-17 00:00:00	06:16:12	16:53:25	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65620	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-18 00:00:00	06:01:18	16:55:29	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65621	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-19 00:00:00	05:56:12	16:57:20	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65622	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-20 00:00:00	05:57:40	16:59:07	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65623	59	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060406-387.jpg	Time Attendance Device	2026-08-24 00:00:00	06:08:18	16:56:34	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65624	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-10 00:00:00	06:04:29	16:54:47	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65625	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-11 00:00:00	06:04:19	16:55:09	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65626	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-12 00:00:00	06:01:37	16:51:29	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65627	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-13 00:00:00	06:09:43	16:50:47	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65628	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-14 00:00:00	06:45:00	15:52:16	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65629	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-17 00:00:00	06:18:58	16:53:22	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65630	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-18 00:00:00	06:01:11	16:55:58	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65631	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-19 00:00:00	05:59:38	16:54:32	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65632	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-20 00:00:00	05:57:34	16:59:20	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65633	63	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810060429-1838.jpg	Time Attendance Device	2026-08-24 00:00:00	06:07:53	16:55:02	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65634	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-10 00:00:00	05:56:50	16:51:09	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65635	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-11 00:00:00	05:46:35	16:51:38	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65636	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-12 00:00:00	06:00:48	16:49:27	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65637	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-13 00:00:00	06:05:15	16:49:29	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65638	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-14 00:00:00	06:45:04	15:51:29	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65639	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-17 00:00:00	06:16:19	16:53:36	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65640	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-18 00:00:00	05:58:56	16:53:24	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65641	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-19 00:00:00	05:56:01	16:53:56	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65642	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-20 00:00:00	05:57:29	16:59:23	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65643	22	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055650-687.jpg	Time Attendance Device	2026-08-24 00:00:00	06:08:24	16:54:41	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65644	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-10 00:00:00	05:53:42	16:55:11	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65645	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-11 00:00:00	05:59:30	16:50:48	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65646	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-12 00:00:00	05:56:42	16:51:21	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65647	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-13 00:00:00	06:01:44	16:51:21	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65648	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-14 00:00:00	06:47:32	15:52:05	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65649	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-17 00:00:00	06:25:11	16:51:53	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65650	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-18 00:00:00	05:58:07	16:55:42	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65651	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-19 00:00:00	05:47:34	16:55:15	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65652	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-20 00:00:00	05:58:16	16:58:46	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65653	18	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055342-1101.jpg	Time Attendance Device	2026-08-24 00:00:00	06:06:07	16:55:56	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65654	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-10 00:00:00	05:55:24	16:51:38	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65655	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-11 00:00:00	06:01:43	16:51:49	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65656	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-12 00:00:00	05:51:37	16:50:01	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65657	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-13 00:00:00	06:03:27	16:50:30	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65658	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-17 00:00:00	06:10:23	16:52:57	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65659	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-18 00:00:00	06:01:15	16:55:11	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65660	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-19 00:00:00	05:57:48	16:53:30	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65661	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-20 00:00:00	05:51:23	17:00:39	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65662	56	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055524-1673.jpg	Time Attendance Device	2026-08-24 00:00:00	06:08:55	16:54:20	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65663	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-10 00:00:00	05:55:18	16:51:31	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65664	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-11 00:00:00	06:02:02	16:53:40	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65665	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-12 00:00:00	05:59:08	16:50:55	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65666	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-13 00:00:00	06:05:20	16:49:42	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65667	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-14 00:00:00	06:50:40	15:51:32	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65668	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-17 00:00:00	06:10:18	16:53:28	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65669	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-18 00:00:00	05:47:23	16:53:53	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65670	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-19 00:00:00	05:49:19	16:52:25	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65671	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-20 00:00:00	05:51:35	16:59:26	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65672	55	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055518-445.jpg	Time Attendance Device	2026-08-24 00:00:00	06:04:48	16:52:08	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65673	75	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054728-993.jpg	Time Attendance Device	2026-08-10 00:00:00	05:47:28	16:51:42	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65674	75	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054728-993.jpg	Time Attendance Device	2026-08-11 00:00:00	05:54:36	16:52:20	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65675	75	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054728-993.jpg	Time Attendance Device	2026-08-12 00:00:00	05:51:05	16:50:34	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65676	75	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054728-993.jpg	Time Attendance Device	2026-08-13 00:00:00	05:53:02	16:50:22	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65677	75	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054728-993.jpg	Time Attendance Device	2026-08-18 00:00:00	05:53:25	16:52:48	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65678	75	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054728-993.jpg	Time Attendance Device	2026-08-19 00:00:00	05:57:29	16:53:16	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65679	75	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054728-993.jpg	Time Attendance Device	2026-08-20 00:00:00	05:53:02	17:01:04	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65680	75	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054728-993.jpg	Time Attendance Device	2026-08-24 00:00:00	06:04:43	16:52:22	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65681	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-10 00:00:00	05:42:32	16:54:36	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65682	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-11 00:00:00	05:33:22	16:54:58	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65683	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-12 00:00:00	05:44:23	16:51:01	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65684	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-13 00:00:00	05:46:56	16:51:29	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65685	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-14 00:00:00	06:26:16	15:52:45	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65686	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-18 00:00:00	05:41:36	16:53:19	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65687	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-19 00:00:00	05:38:34	16:54:45	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65688	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-20 00:00:00	05:47:28	17:00:26	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65689	66	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054232-1176.jpg	Time Attendance Device	2026-08-24 00:00:00	05:42:07	16:52:16	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65690	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-10 00:00:00	05:50:44	16:52:30	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65691	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-11 00:00:00	05:47:29	16:49:56	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65692	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-12 00:00:00	05:40:06	16:49:37	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65693	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-13 00:00:00	06:01:24	16:47:46	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65694	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-14 00:00:00	06:52:22	15:49:54	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65695	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-18 00:00:00	05:50:17	16:54:48	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65696	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-19 00:00:00	05:59:18	16:52:56	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65697	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-20 00:00:00	05:58:00	17:00:19	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65698	51	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055044-1454.jpg	Time Attendance Device	2026-08-24 00:00:00	06:02:01	16:50:51	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65699	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-10 00:00:00	05:54:05	16:54:56	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65700	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-11 00:00:00	05:54:31	16:49:12	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65701	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-12 00:00:00	05:51:16	16:49:53	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65702	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-13 00:00:00	06:01:10	16:48:58	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65703	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-14 00:00:00	06:30:55	15:50:15	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65704	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-17 00:00:00	05:43:45	16:52:07	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65705	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-18 00:00:00	06:02:33	16:53:08	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65706	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-19 00:00:00	05:51:29	16:55:38	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65707	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-20 00:00:00	05:52:58	17:00:02	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65708	25	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055405-925.jpg	Time Attendance Device	2026-08-24 00:00:00	06:07:47	16:54:04	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65709	477	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060112-1381.jpg	Time Attendance Device	2026-08-10 00:00:00	06:01:12	19:00:18	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65710	477	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060112-1381.jpg	Time Attendance Device	2026-08-11 00:00:00	05:50:47	19:04:46	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65711	477	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060112-1381.jpg	Time Attendance Device	2026-08-13 00:00:00	06:05:07	18:57:48	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65712	477	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060112-1381.jpg	Time Attendance Device	2026-08-24 00:00:00	05:59:24	18:59:16	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65713	477	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060112-1381.jpg	Time Attendance Device	2026-08-25 00:00:00	06:02:29	19:00:45	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65714	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-10 00:00:00	05:57:11	16:54:11	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65715	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-11 00:00:00	05:58:23	16:54:17	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65716	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-12 00:00:00	06:01:59	16:54:53	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65717	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-13 00:00:00	06:06:53	16:55:39	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65718	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-14 00:00:00	06:55:00	15:58:55	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65719	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-17 00:00:00	05:41:10	16:53:39	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65720	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-18 00:00:00	05:51:48	16:56:16	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65721	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-19 00:00:00	05:52:43	16:54:03	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65722	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-20 00:00:00	05:58:09	16:59:12	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65723	21	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055711-1678.jpg	Time Attendance Device	2026-08-24 00:00:00	05:55:55	16:55:04	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65724	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-10 00:00:00	05:55:34	19:00:38	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65725	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-11 00:00:00	05:55:10	19:00:05	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65726	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-12 00:00:00	05:53:53	19:00:21	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65727	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-13 00:00:00	05:51:06	19:01:03	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65728	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-14 00:00:00	05:57:13	17:01:48	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65729	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-17 00:00:00	06:03:05	19:00:11	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65730	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-18 00:00:00	05:57:56	19:00:20	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65731	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-19 00:00:00	06:01:14	19:00:35	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65732	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-20 00:00:00	05:50:45	19:00:08	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65733	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-21 00:00:00	05:50:33	18:00:26	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65734	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-24 00:00:00	05:51:21	19:01:00	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65735	501	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810055534-943.jpg	Time Attendance Device	2026-08-25 00:00:00	05:47:49	19:00:57	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65736	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-10 00:00:00	05:52:39	16:53:55	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65737	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-11 00:00:00	05:58:39	16:53:52	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65738	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-12 00:00:00	05:49:41	16:54:16	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65739	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-13 00:00:00	06:06:49	16:51:05	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65740	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-14 00:00:00	06:18:01	15:52:37	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65741	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-17 00:00:00	05:52:43	16:53:59	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65742	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-18 00:00:00	05:51:57	16:54:43	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65743	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-19 00:00:00	05:52:48	16:54:22	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65744	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-20 00:00:00	05:53:47	16:59:35	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65745	9	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055239-1842.jpg	Time Attendance Device	2026-08-24 00:00:00	05:55:49	16:52:43	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65746	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-10 00:00:00	05:54:13	16:54:07	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65747	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-11 00:00:00	05:52:59	16:53:58	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65748	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-12 00:00:00	05:52:33	16:49:47	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65749	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-14 00:00:00	06:23:09	15:52:57	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65750	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-17 00:00:00	05:59:00	16:53:31	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65751	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-18 00:00:00	05:59:54	16:56:03	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65752	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-19 00:00:00	05:54:38	16:53:36	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65753	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-20 00:00:00	05:51:57	17:00:46	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65754	32	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055413-1477.jpg	Time Attendance Device	2026-08-24 00:00:00	06:05:46	16:53:06	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65755	74	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055424-1213.jpg	Time Attendance Device	2026-08-10 00:00:00	05:54:24	16:51:51	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65756	74	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055424-1213.jpg	Time Attendance Device	2026-08-11 00:00:00	05:54:59	16:54:24	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65757	74	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055424-1213.jpg	Time Attendance Device	2026-08-13 00:00:00	06:00:47	16:50:50	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65758	74	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055424-1213.jpg	Time Attendance Device	2026-08-14 00:00:00	07:07:59	15:58:49	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65759	74	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055424-1213.jpg	Time Attendance Device	2026-08-17 00:00:00	06:04:30	16:53:00	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65760	74	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055424-1213.jpg	Time Attendance Device	2026-08-19 00:00:00	05:47:52	16:54:56	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65761	74	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055424-1213.jpg	Time Attendance Device	2026-08-20 00:00:00	05:54:38	17:01:58	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65762	74	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055424-1213.jpg	Time Attendance Device	2026-08-24 00:00:00	06:20:19	16:52:32	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65763	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-10 00:00:00	05:49:52	16:55:09	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65764	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-11 00:00:00	05:49:15	16:52:35	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65765	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-13 00:00:00	05:56:41	16:51:37	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65766	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-14 00:00:00	06:09:16	15:53:17	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65767	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-17 00:00:00	05:53:28	16:54:25	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65768	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-18 00:00:00	05:50:07	16:53:01	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65769	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-19 00:00:00	05:53:48	16:55:22	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65770	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-20 00:00:00	05:47:41	17:01:46	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65771	26	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054952-1098.jpg	Time Attendance Device	2026-08-24 00:00:00	05:58:08	16:55:23	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65772	479	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055144-580.jpg	Time Attendance Device	2026-08-10 00:00:00	05:51:44	19:00:08	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65773	479	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055144-580.jpg	Time Attendance Device	2026-08-11 00:00:00	05:55:28	19:00:04	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65774	479	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055144-580.jpg	Time Attendance Device	2026-08-12 00:00:00	05:54:09	19:00:11	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65775	479	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055144-580.jpg	Time Attendance Device	2026-08-13 00:00:00	05:46:29	19:00:10	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65776	479	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055144-580.jpg	Time Attendance Device	2026-08-14 00:00:00	05:48:00	17:00:49	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65777	479	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055144-580.jpg	Time Attendance Device	2026-08-24 00:00:00	05:51:06	19:01:31	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65778	479	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055144-580.jpg	Time Attendance Device	2026-08-25 00:00:00	05:38:18	19:00:38	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65779	8	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055605-1237.jpg	Time Attendance Device	2026-08-10 00:00:00	05:56:05	16:50:50	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65780	8	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055605-1237.jpg	Time Attendance Device	2026-08-11 00:00:00	05:47:37	16:52:04	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65781	8	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055605-1237.jpg	Time Attendance Device	2026-08-12 00:00:00	05:49:15	16:48:58	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65782	8	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055605-1237.jpg	Time Attendance Device	2026-08-13 00:00:00	05:52:33	16:48:33	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65783	8	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055605-1237.jpg	Time Attendance Device	2026-08-14 00:00:00	06:29:29	15:48:32	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65784	8	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055605-1237.jpg	Time Attendance Device	2026-08-18 00:00:00	05:50:11	16:52:26	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65785	8	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055605-1237.jpg	Time Attendance Device	2026-08-24 00:00:00	05:54:39	16:51:12	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65786	41	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055110-1633.jpg	Time Attendance Device	2026-08-11 00:00:00	05:51:10	16:48:54	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65787	41	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055110-1633.jpg	Time Attendance Device	2026-08-12 00:00:00	05:51:08	16:48:01	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65788	41	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055110-1633.jpg	Time Attendance Device	2026-08-13 00:00:00	05:52:01	16:47:54	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65789	41	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055110-1633.jpg	Time Attendance Device	2026-08-17 00:00:00	05:53:22	16:51:28	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65790	41	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055110-1633.jpg	Time Attendance Device	2026-08-18 00:00:00	05:57:43	16:52:01	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65791	41	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055110-1633.jpg	Time Attendance Device	2026-08-19 00:00:00	05:55:21	16:53:09	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65792	41	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055110-1633.jpg	Time Attendance Device	2026-08-20 00:00:00	05:30:47	16:58:52	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65793	41	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055110-1633.jpg	Time Attendance Device	2026-08-24 00:00:00	06:01:02	16:53:55	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65794	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-10 00:00:00	05:30:45	16:50:24	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65795	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-11 00:00:00	05:51:20	16:48:36	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65796	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-12 00:00:00	05:51:21	16:47:54	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65797	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-13 00:00:00	05:51:47	16:48:44	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65798	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-14 00:00:00	06:56:19	15:48:12	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65799	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-17 00:00:00	05:53:20	16:51:33	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65800	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-18 00:00:00	05:57:50	16:52:06	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65801	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-19 00:00:00	05:55:18	16:52:51	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65802	69	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810053045-1473.jpg	Time Attendance Device	2026-08-20 00:00:00	05:30:54	16:58:39	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65804	481	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-11/20260811113128-639.jpg	Time Attendance Device	2026-08-11 00:00:00	11:31:28	19:46:48	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65805	481	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-11/20260811113128-639.jpg	Time Attendance Device	2026-08-17 00:00:00	06:10:12	19:02:32	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65806	481	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-11/20260811113128-639.jpg	Time Attendance Device	2026-08-18 00:00:00	05:59:02	19:00:34	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65807	481	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-11/20260811113128-639.jpg	Time Attendance Device	2026-08-19 00:00:00	05:40:59	19:08:27	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65808	481	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-11/20260811113128-639.jpg	Time Attendance Device	2026-08-20 00:00:00	05:56:12	19:01:43	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65809	481	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-11/20260811113128-639.jpg	Time Attendance Device	2026-08-24 00:00:00	05:50:46	19:01:08	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65810	481	LAMI Mining Site		Fingerprint only	upload/att/transactionPhoto/AJE1255000088/2026-08-11/20260811113128-639.jpg	Time Attendance Device	2026-08-25 00:00:00	06:07:37	19:04:59	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65811	11	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814055352-1163.jpg	Time Attendance Device	2026-08-14 00:00:00	05:53:52	15:51:52	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65812	11	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814055352-1163.jpg	Time Attendance Device	2026-08-17 00:00:00	06:09:46	16:52:18	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65813	11	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814055352-1163.jpg	Time Attendance Device	2026-08-18 00:00:00	05:53:42	16:54:13	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65814	11	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-14/20260814055352-1163.jpg	Time Attendance Device	2026-08-24 00:00:00	05:50:24	19:04:57	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65815	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-10 00:00:00	05:55:37	16:51:13	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65816	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-11 00:00:00	05:46:00	16:52:00	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65817	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-12 00:00:00	05:46:56	16:48:55	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65818	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-13 00:00:00	05:51:17	16:48:01	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65819	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-14 00:00:00	06:27:52	15:48:53	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65820	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-18 00:00:00	05:50:02	16:52:10	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65821	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-19 00:00:00	05:32:09	16:52:18	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65822	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-20 00:00:00	05:31:00	17:01:02	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65823	76	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055537-1246.jpg	Time Attendance Device	2026-08-24 00:00:00	05:52:50	16:51:29	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65824	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-10 00:00:00	05:49:10	16:53:48	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65825	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-11 00:00:00	05:55:14	16:54:33	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65826	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-12 00:00:00	05:49:47	16:54:42	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65827	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-13 00:00:00	06:05:05	16:58:46	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65828	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-14 00:00:00	06:26:29	15:52:10	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65829	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-18 00:00:00	05:53:31	16:57:11	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65830	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-19 00:00:00	05:57:39	16:55:49	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65831	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-20 00:00:00	05:49:49	17:01:42	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65832	71	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054910-1164.jpg	Time Attendance Device	2026-08-24 00:00:00	06:01:23	16:57:24	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65833	38	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054710-390.jpg	Time Attendance Device	2026-08-10 00:00:00	05:47:10	16:53:45	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65834	38	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054710-390.jpg	Time Attendance Device	2026-08-12 00:00:00	05:49:51	16:54:34	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65835	38	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054710-390.jpg	Time Attendance Device	2026-08-13 00:00:00	05:20:17	16:50:56	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65836	38	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054710-390.jpg	Time Attendance Device	2026-08-14 00:00:00	06:36:07	15:49:01	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65837	38	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054710-390.jpg	Time Attendance Device	2026-08-17 00:00:00	05:39:26	16:51:25	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65838	38	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054710-390.jpg	Time Attendance Device	2026-08-18 00:00:00	05:33:42	16:55:24	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65839	38	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054710-390.jpg	Time Attendance Device	2026-08-19 00:00:00	05:32:03	16:57:10	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65840	38	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054710-390.jpg	Time Attendance Device	2026-08-20 00:00:00	05:28:38	17:01:23	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65841	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-10 00:00:00	05:45:23	16:50:47	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65842	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-11 00:00:00	06:01:32	16:49:05	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65843	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-12 00:00:00	05:45:18	16:48:20	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65844	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-13 00:00:00	06:04:57	16:47:20	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65845	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-14 00:00:00	06:30:31	15:48:22	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65846	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-17 00:00:00	06:04:59	16:51:58	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65847	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-18 00:00:00	05:53:04	16:52:21	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65848	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-19 00:00:00	05:50:03	16:52:10	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65849	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-20 00:00:00	05:44:49	16:59:44	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65850	62	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054523-1082.jpg	Time Attendance Device	2026-08-24 00:00:00	05:56:10	16:50:36	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65851	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-10 00:00:00	05:47:41	16:51:23	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65852	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-11 00:00:00	05:56:31	16:49:32	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65853	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-12 00:00:00	05:56:30	16:50:49	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65854	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-13 00:00:00	06:00:59	16:50:16	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65855	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-14 00:00:00	06:22:55	15:50:24	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65856	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-17 00:00:00	06:00:03	16:52:33	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65857	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-18 00:00:00	05:52:50	16:52:43	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65858	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-19 00:00:00	05:45:26	16:53:12	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65859	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-20 00:00:00	05:49:07	17:00:35	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65860	34	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054741-1429.jpg	Time Attendance Device	2026-08-24 00:00:00	06:02:10	16:51:36	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65861	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-10 00:00:00	05:46:08	16:50:38	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65862	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-11 00:00:00	06:11:11	16:48:45	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65863	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-13 00:00:00	06:07:33	16:47:55	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65864	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-14 00:00:00	06:32:34	15:48:20	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65865	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-17 00:00:00	06:07:21	16:51:20	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65866	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-18 00:00:00	05:38:31	16:51:50	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65867	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-19 00:00:00	05:43:12	16:52:07	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65868	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-20 00:00:00	05:46:26	09:32:52	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65869	44	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054608-1243.jpg	Time Attendance Device	2026-08-24 00:00:00	05:51:48	16:50:56	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65870	45	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055748-1814.jpg	Time Attendance Device	2026-08-10 00:00:00	05:57:48	16:51:01	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65871	45	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055748-1814.jpg	Time Attendance Device	2026-08-11 00:00:00	06:00:02	16:50:03	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65872	45	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055748-1814.jpg	Time Attendance Device	2026-08-12 00:00:00	06:10:19	16:50:08	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65873	45	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055748-1814.jpg	Time Attendance Device	2026-08-13 00:00:00	06:06:35	16:50:03	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65874	45	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055748-1814.jpg	Time Attendance Device	2026-08-14 00:00:00	06:43:36	15:50:04	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65875	45	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055748-1814.jpg	Time Attendance Device	2026-08-18 00:00:00	05:53:10	16:51:54	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65876	45	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055748-1814.jpg	Time Attendance Device	2026-08-19 00:00:00	05:51:03	16:52:01	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65877	45	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055748-1814.jpg	Time Attendance Device	2026-08-20 00:00:00	05:52:19	16:58:35	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65878	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-10 00:00:00	05:44:57	16:50:40	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65879	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-11 00:00:00	05:49:36	16:51:34	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65880	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-12 00:00:00	05:41:17	16:48:09	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65881	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-13 00:00:00	05:54:06	16:47:35	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65882	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-14 00:00:00	06:17:37	15:48:08	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65883	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-17 00:00:00	05:52:37	16:51:48	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65884	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-18 00:00:00	05:47:11	16:51:39	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65885	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-19 00:00:00	05:58:49	15:55:06	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65886	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-20 00:00:00	05:54:14	16:58:26	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65887	24	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054457-379.jpg	Time Attendance Device	2026-08-24 00:00:00	05:56:26	16:50:37	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65888	65	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811054742-1768.jpg	Time Attendance Device	2026-08-11 00:00:00	05:47:42	16:52:12	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65889	65	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811054742-1768.jpg	Time Attendance Device	2026-08-12 00:00:00	05:31:57	16:50:20	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65890	65	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811054742-1768.jpg	Time Attendance Device	2026-08-13 00:00:00	05:46:06	16:49:23	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65891	65	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811054742-1768.jpg	Time Attendance Device	2026-08-14 00:00:00	06:09:29	15:49:59	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65892	65	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811054742-1768.jpg	Time Attendance Device	2026-08-17 00:00:00	05:46:57	16:52:52	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65893	65	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811054742-1768.jpg	Time Attendance Device	2026-08-18 00:00:00	05:28:43	16:54:56	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65894	65	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811054742-1768.jpg	Time Attendance Device	2026-08-19 00:00:00	05:38:46	16:53:52	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65895	65	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811054742-1768.jpg	Time Attendance Device	2026-08-20 00:00:00	05:27:50	17:00:23	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65896	61	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055352-1679.jpg	Time Attendance Device	2026-08-10 00:00:00	05:53:52	16:50:31	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65897	61	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055352-1679.jpg	Time Attendance Device	2026-08-11 00:00:00	05:43:37	16:48:50	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65898	61	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055352-1679.jpg	Time Attendance Device	2026-08-17 00:00:00	05:56:50	13:11:01	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65899	61	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055352-1679.jpg	Time Attendance Device	2026-08-20 00:00:00	05:47:49	16:58:18	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65900	61	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055352-1679.jpg	Time Attendance Device	2026-08-24 00:00:00	06:04:27	16:50:25	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65901	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-10 00:00:00	05:43:22	16:56:07	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65902	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-11 00:00:00	05:43:56	16:55:06	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65903	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-12 00:00:00	05:42:14	16:54:57	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65904	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-13 00:00:00	05:49:36	16:52:02	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65905	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-14 00:00:00	06:47:52	15:53:55	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65906	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-17 00:00:00	05:48:39	16:54:15	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65907	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-18 00:00:00	05:46:54	16:56:07	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65908	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-19 00:00:00	05:49:26	16:53:43	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65909	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-20 00:00:00	05:44:26	17:02:11	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65910	43	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054322-1547.jpg	Time Attendance Device	2026-08-24 00:00:00	05:51:55	16:55:19	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65911	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-10 00:00:00	05:51:39	16:52:06	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65912	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-11 00:00:00	05:43:50	16:52:31	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65913	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-12 00:00:00	05:44:29	16:49:14	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65914	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-13 00:00:00	05:47:32	16:50:40	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65915	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-14 00:00:00	06:04:25	15:51:37	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65916	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-17 00:00:00	05:52:21	16:52:48	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65917	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-18 00:00:00	05:45:19	16:53:13	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65918	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-19 00:00:00	05:45:54	16:54:38	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65919	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-20 00:00:00	05:44:55	16:58:49	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65920	15	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055139-1181.jpg	Time Attendance Device	2026-08-24 00:00:00	05:49:10	16:54:55	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65921	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-10 00:00:00	05:47:23	16:50:30	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65922	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-11 00:00:00	05:51:40	16:50:24	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65923	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-12 00:00:00	05:44:19	16:48:39	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65924	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-13 00:00:00	05:49:51	16:48:09	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65925	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-14 00:00:00	06:30:46	15:48:28	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65926	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-18 00:00:00	05:41:30	16:51:36	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65927	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-19 00:00:00	05:47:22	16:52:29	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65928	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-20 00:00:00	05:52:15	16:59:04	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65929	54	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054723-1090.jpg	Time Attendance Device	2026-08-24 00:00:00	06:29:16	16:50:47	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65930	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-10 00:00:00	05:46:20	16:52:20	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65931	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-11 00:00:00	05:51:15	16:48:57	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65932	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-12 00:00:00	05:49:10	16:49:41	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65933	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-13 00:00:00	05:56:48	16:49:09	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65934	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-14 00:00:00	06:31:00	15:48:56	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65935	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-18 00:00:00	05:35:34	16:53:27	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65936	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-19 00:00:00	05:41:37	16:55:34	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65937	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-20 00:00:00	05:40:17	16:59:16	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65938	58	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054620-1703.jpg	Time Attendance Device	2026-08-24 00:00:00	05:51:25	16:54:15	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65939	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-10 00:00:00	05:44:05	16:51:47	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65940	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-11 00:00:00	06:01:23	16:49:25	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65941	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-12 00:00:00	05:57:50	16:48:42	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65942	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-13 00:00:00	06:03:09	16:47:39	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65943	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-14 00:00:00	06:38:57	15:49:05	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65944	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-17 00:00:00	05:24:04	16:52:29	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65945	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-18 00:00:00	05:46:59	16:52:38	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65946	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-19 00:00:00	05:42:07	16:52:14	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65947	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-20 00:00:00	05:41:52	17:00:51	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65948	14	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054405-1730.jpg	Time Attendance Device	2026-08-24 00:00:00	06:08:35	16:51:32	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65949	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-10 00:00:00	05:44:01	16:51:19	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65950	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-11 00:00:00	06:01:19	16:49:21	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65951	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-12 00:00:00	05:57:36	16:49:21	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65952	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-13 00:00:00	06:03:15	16:49:35	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65953	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-14 00:00:00	06:39:22	15:51:04	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65954	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-17 00:00:00	05:24:17	16:52:40	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65955	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-18 00:00:00	05:46:48	16:53:36	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65956	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-19 00:00:00	05:41:56	16:52:40	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65957	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-20 00:00:00	05:41:46	16:59:40	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65958	36	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054401-994.jpg	Time Attendance Device	2026-08-24 00:00:00	06:17:43	16:51:48	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65959	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-10 00:00:00	05:42:38	16:55:27	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65960	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-11 00:00:00	05:47:19	16:55:22	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65961	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-12 00:00:00	05:49:26	16:54:04	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65962	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-13 00:00:00	05:48:07	16:55:11	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65963	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-14 00:00:00	06:29:43	15:51:23	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65964	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-17 00:00:00	05:49:28	16:53:44	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65965	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-18 00:00:00	05:45:11	16:55:54	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65966	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-19 00:00:00	05:40:05	16:54:11	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65967	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-20 00:00:00	05:44:43	17:01:30	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65968	30	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054238-1752.jpg	Time Attendance Device	2026-08-24 00:00:00	05:50:14	16:54:30	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65969	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-10 00:00:00	05:45:05	16:55:41	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65970	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-11 00:00:00	05:32:50	16:50:55	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65971	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-12 00:00:00	05:42:57	16:50:25	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65972	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-13 00:00:00	05:47:16	16:50:36	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65973	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-17 00:00:00	05:54:07	16:54:21	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65974	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-18 00:00:00	05:46:11	16:55:50	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65975	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-19 00:00:00	05:44:02	16:55:02	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65976	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-20 00:00:00	05:47:11	17:01:27	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65977	16	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054505-1432.jpg	Time Attendance Device	2026-08-24 00:00:00	05:50:32	11:07:08	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65978	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-10 00:00:00	06:58:52	17:52:50	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65979	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-11 00:00:00	06:58:09	17:50:22	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65980	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-12 00:00:00	07:01:17	17:47:44	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65981	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-13 00:00:00	06:56:04	17:49:40	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65982	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-14 00:00:00	06:58:43	15:50:35	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65983	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-17 00:00:00	03:45:48	15:43:36	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65984	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-18 00:00:00	03:57:47	15:33:40	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65985	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-19 00:00:00	03:59:35	15:36:05	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65986	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-20 00:00:00	03:57:54	15:52:04	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65987	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-21 00:00:00	04:18:17	15:26:42	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65988	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-22 00:00:00	04:13:53	15:42:47	Saturday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65989	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-24 00:00:00	03:52:52	16:08:36	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65990	504	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065852-616.jpg	Time Attendance Device	2026-08-25 00:00:00	03:47:10	15:10:42	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65991	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-12 00:00:00	12:41:56	22:02:57	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65992	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-13 00:00:00	12:53:30	22:02:11	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65993	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-14 00:00:00	13:10:34	22:13:53	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65994	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-17 00:00:00	12:59:38	22:02:25	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65995	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-18 00:00:00	13:06:51	22:00:56	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65996	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-19 00:00:00	13:05:34	22:03:34	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65997	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-20 00:00:00	13:02:04	22:00:20	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65998	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-23 00:00:00	13:08:17	22:02:33	Sunday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
65999	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-24 00:00:00	13:11:11	22:00:36	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66000	290	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-12/20260812124156-161.jpg	Time Attendance Device	2026-08-25 00:00:00	13:03:30	22:01:03	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66001	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-10 00:00:00	06:58:43	17:53:25	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66002	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-11 00:00:00	06:58:00	17:51:46	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66003	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-12 00:00:00	06:58:17	17:49:35	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66004	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-13 00:00:00	07:00:21	17:49:00	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66005	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-17 00:00:00	07:02:46	17:51:36	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66006	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-18 00:00:00	07:01:25	17:50:14	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66007	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-19 00:00:00	07:00:34	17:50:12	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66008	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-20 00:00:00	07:01:50	17:50:51	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66009	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-24 00:00:00	07:00:07	19:08:48	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66010	548	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065843-645.jpg	Time Attendance Device	2026-08-25 00:00:00	17:51:24	20:57:47	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66011	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-10 00:00:00	06:00:49	18:26:56	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66012	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-11 00:00:00	05:56:08	18:09:53	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66013	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-12 00:00:00	05:58:58	18:19:20	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66014	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-13 00:00:00	06:25:44	18:18:22	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66015	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-14 00:00:00	06:25:35	16:22:23	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66016	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-17 00:00:00	06:19:50	18:01:16	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66017	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-18 00:00:00	02:03:05	22:07:06	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66018	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-19 00:00:00	06:49:25	17:58:08	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66019	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-20 00:00:00	05:56:40	18:34:36	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66020	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-22 00:00:00	03:55:20	20:24:34	Saturday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66021	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-24 00:00:00	06:20:56	18:00:39	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66022	549	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810060049-957.jpg	Time Attendance Device	2026-08-25 00:00:00	06:53:44	20:47:37	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66023	498	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065308-213.jpg	Time Attendance Device	2026-08-11 00:00:00	07:06:59	16:01:11	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66024	498	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065308-213.jpg	Time Attendance Device	2026-08-12 00:00:00	06:41:26	16:02:29	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66025	498	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065308-213.jpg	Time Attendance Device	2026-08-13 00:00:00	06:55:06	16:02:06	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66026	498	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065308-213.jpg	Time Attendance Device	2026-08-17 00:00:00	06:54:23	18:00:12	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66027	498	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065308-213.jpg	Time Attendance Device	2026-08-20 00:00:00	06:47:29	18:01:07	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66028	498	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065308-213.jpg	Time Attendance Device	2026-08-24 00:00:00	06:57:13	18:02:08	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66029	257	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065239-650.jpg	Time Attendance Device	2026-08-10 00:00:00	06:52:39	18:00:10	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66030	257	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065239-650.jpg	Time Attendance Device	2026-08-13 00:00:00	06:58:59	16:01:46	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66031	257	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065239-650.jpg	Time Attendance Device	2026-08-17 00:00:00	06:54:13	18:00:02	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66032	257	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065239-650.jpg	Time Attendance Device	2026-08-18 00:00:00	06:41:01	18:02:25	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66033	257	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065239-650.jpg	Time Attendance Device	2026-08-19 00:00:00	06:53:42	18:00:02	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66034	257	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065239-650.jpg	Time Attendance Device	2026-08-20 00:00:00	06:47:19	18:00:51	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66035	257	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065239-650.jpg	Time Attendance Device	2026-08-24 00:00:00	06:57:01	18:03:59	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66036	257	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810065239-650.jpg	Time Attendance Device	2026-08-25 00:00:00	06:54:43	18:00:21	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66037	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-10 00:00:00	07:08:52	17:50:56	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66038	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-11 00:00:00	07:03:21	17:48:48	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66039	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-12 00:00:00	07:06:09	17:50:43	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66040	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-13 00:00:00	07:25:50	17:51:21	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66041	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-14 00:00:00	07:36:16	15:52:23	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66042	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-17 00:00:00	07:19:40	17:51:09	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66043	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-19 00:00:00	07:10:21	17:51:25	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66044	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-20 00:00:00	07:16:20	17:50:57	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66045	89	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070852-485.jpg	Time Attendance Device	2026-08-24 00:00:00	06:59:03	19:17:29	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66046	84	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065356-1417.jpg	Time Attendance Device	2026-08-10 00:00:00	06:53:56	17:50:21	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66047	84	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065356-1417.jpg	Time Attendance Device	2026-08-11 00:00:00	06:56:55	17:49:24	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66048	84	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065356-1417.jpg	Time Attendance Device	2026-08-12 00:00:00	06:56:19	17:49:14	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66049	84	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065356-1417.jpg	Time Attendance Device	2026-08-13 00:00:00	06:57:13	17:50:54	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66050	84	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065356-1417.jpg	Time Attendance Device	2026-08-18 00:00:00	06:55:07	17:50:52	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66051	84	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065356-1417.jpg	Time Attendance Device	2026-08-19 00:00:00	06:56:46	17:50:48	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66052	84	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065356-1417.jpg	Time Attendance Device	2026-08-24 00:00:00	06:55:01	17:49:38	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66053	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-10 00:00:00	05:40:38	16:54:28	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66054	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-11 00:00:00	05:46:05	16:55:15	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66055	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-12 00:00:00	05:55:40	16:51:08	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66056	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-13 00:00:00	05:58:17	16:48:15	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66057	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-14 00:00:00	06:30:50	15:51:49	Friday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66058	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-17 00:00:00	06:05:23	16:53:06	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66059	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-18 00:00:00	06:02:39	16:55:36	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66060	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-19 00:00:00	05:53:02	16:54:26	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66061	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-20 00:00:00	05:49:37	17:01:09	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66062	53	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810054038-1279.jpg	Time Attendance Device	2026-08-24 00:00:00	06:08:39	16:51:24	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66063	70	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055439-1501.jpg	Time Attendance Device	2026-08-10 00:00:00	05:54:39	16:56:13	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66064	70	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055439-1501.jpg	Time Attendance Device	2026-08-11 00:00:00	05:54:42	16:55:36	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66065	70	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055439-1501.jpg	Time Attendance Device	2026-08-12 00:00:00	05:56:50	16:55:10	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66066	70	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055439-1501.jpg	Time Attendance Device	2026-08-13 00:00:00	06:02:46	16:58:38	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66067	70	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055439-1501.jpg	Time Attendance Device	2026-08-17 00:00:00	05:57:06	16:52:22	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66068	70	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055439-1501.jpg	Time Attendance Device	2026-08-20 00:00:00	05:48:02	16:59:51	Thursday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66069	70	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810055439-1501.jpg	Time Attendance Device	2026-08-24 00:00:00	06:05:21	16:54:47	Monday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66070	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-11 00:00:00	06:01:50	16:52:16	Tuesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66071	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-12 00:00:00	05:53:54	16:49:09	Wednesday	14	2026-09-22 15:04:41	2026-09-22 15:04:41	f	0	0	f	f	\N	\N	\N	\N
66072	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-13 00:00:00	06:16:59	16:48:28	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66073	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-14 00:00:00	06:40:58	15:49:47	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66074	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-17 00:00:00	05:56:05	16:53:15	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66075	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-18 00:00:00	05:53:36	16:54:19	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66076	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-19 00:00:00	05:56:45	16:52:32	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66077	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-20 00:00:00	05:52:09	17:00:08	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66078	42	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811060150-1088.jpg	Time Attendance Device	2026-08-24 00:00:00	06:14:16	16:50:16	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66079	450	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065341-417.jpg	Time Attendance Device	2026-08-10 00:00:00	06:53:41	15:48:32	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66080	450	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065341-417.jpg	Time Attendance Device	2026-08-11 00:00:00	06:30:05	15:49:29	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66081	450	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065341-417.jpg	Time Attendance Device	2026-08-12 00:00:00	06:37:22	15:48:02	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66082	476	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-12/20260812061050-549.jpg	Time Attendance Device	2026-08-12 00:00:00	06:10:50	20:46:12	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66083	476	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-12/20260812061050-549.jpg	Time Attendance Device	2026-08-15 00:00:00	06:11:10	14:34:49	Saturday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66084	476	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-12/20260812061050-549.jpg	Time Attendance Device	2026-08-17 00:00:00	06:03:16	19:21:33	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66085	476	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-12/20260812061050-549.jpg	Time Attendance Device	2026-08-18 00:00:00	06:08:31	17:00:07	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66086	476	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-12/20260812061050-549.jpg	Time Attendance Device	2026-08-19 00:00:00	06:12:22	19:11:35	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66087	476	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-12/20260812061050-549.jpg	Time Attendance Device	2026-08-20 00:00:00	06:11:12	19:03:42	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66088	476	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-12/20260812061050-549.jpg	Time Attendance Device	2026-08-21 00:00:00	06:07:23	15:03:14	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66089	476	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-12/20260812061050-549.jpg	Time Attendance Device	2026-08-24 00:00:00	06:13:16	18:36:28	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66090	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-10 00:00:00	07:21:39	17:58:00	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66091	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-11 00:00:00	07:24:24	18:00:14	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66092	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-12 00:00:00	07:13:43	17:59:04	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66093	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-13 00:00:00	07:21:38	17:57:26	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66094	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-14 00:00:00	07:33:34	16:00:37	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66095	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-17 00:00:00	07:22:05	18:00:19	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66096	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-18 00:00:00	07:20:21	18:00:26	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66097	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-19 00:00:00	07:15:21	18:00:08	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66098	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-20 00:00:00	07:16:08	18:00:21	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66099	87	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810072139-241.jpg	Time Attendance Device	2026-08-24 00:00:00	07:15:47	18:00:34	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66100	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-10 00:00:00	07:07:11	18:07:11	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66101	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-11 00:00:00	07:02:08	17:50:47	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66102	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-12 00:00:00	06:56:26	17:48:31	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66103	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-13 00:00:00	07:00:36	17:49:11	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66104	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-14 00:00:00	06:57:07	15:49:19	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66105	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-17 00:00:00	07:25:13	17:50:45	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66106	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-18 00:00:00	06:55:12	17:50:48	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66107	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-19 00:00:00	06:56:57	17:50:28	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66108	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-20 00:00:00	07:08:45	17:51:07	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66109	349	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070711-292.jpg	Time Attendance Device	2026-08-24 00:00:00	07:07:11	17:50:53	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66110	12	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055454-1824.jpg	Time Attendance Device	2026-08-11 00:00:00	05:54:54	16:49:45	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66111	12	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055454-1824.jpg	Time Attendance Device	2026-08-12 00:00:00	05:49:31	16:51:33	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66112	12	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055454-1824.jpg	Time Attendance Device	2026-08-18 00:00:00	05:53:56	16:51:47	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66113	12	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055454-1824.jpg	Time Attendance Device	2026-08-19 00:00:00	06:06:06	16:53:05	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66114	12	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055454-1824.jpg	Time Attendance Device	2026-08-20 00:00:00	05:48:35	16:58:59	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66115	12	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-11/20260811055454-1824.jpg	Time Attendance Device	2026-08-24 00:00:00	06:22:22	16:54:37	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66116	243	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062136-270.jpg	Time Attendance Device	2026-08-10 00:00:00	06:21:36	17:50:35	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66117	243	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062136-270.jpg	Time Attendance Device	2026-08-11 00:00:00	06:28:05	17:50:12	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66118	243	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810062136-270.jpg	Time Attendance Device	2026-08-24 00:00:00	06:37:38	16:01:23	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66119	451	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-19/20260819070500-1256.jpg	Time Attendance Device	2026-08-19 00:00:00	07:05:00	16:03:55	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66120	451	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-19/20260819070500-1256.jpg	Time Attendance Device	2026-08-20 00:00:00	07:16:16	15:54:59	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66121	451	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-19/20260819070500-1256.jpg	Time Attendance Device	2026-08-21 00:00:00	07:10:12	15:59:49	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66122	451	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-19/20260819070500-1256.jpg	Time Attendance Device	2026-08-22 00:00:00	07:06:41	15:55:06	Saturday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66123	451	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-19/20260819070500-1256.jpg	Time Attendance Device	2026-08-23 00:00:00	07:18:40	15:55:38	Sunday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66124	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-10 00:00:00	06:01:06	19:00:56	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66125	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-11 00:00:00	05:56:35	18:57:21	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66126	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-12 00:00:00	06:02:31	19:00:17	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66127	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-13 00:00:00	06:07:06	18:57:32	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66128	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-14 00:00:00	06:05:44	17:02:31	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66129	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-17 00:00:00	06:14:01	18:56:22	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66130	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-18 00:00:00	06:08:30	18:57:04	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66131	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-19 00:00:00	06:02:59	18:56:26	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66132	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-20 00:00:00	06:04:01	19:00:06	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66133	484	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810060106-732.jpg	Time Attendance Device	2026-08-22 00:00:00	05:56:50	17:10:00	Saturday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66134	251	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-17/20260817060839-99.jpg	Time Attendance Device	2026-08-17 00:00:00	06:08:39	18:56:10	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66135	251	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-17/20260817060839-99.jpg	Time Attendance Device	2026-08-18 00:00:00	05:51:50	18:54:05	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66136	251	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-17/20260817060839-99.jpg	Time Attendance Device	2026-08-19 00:00:00	05:54:45	18:52:58	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66137	251	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-17/20260817060839-99.jpg	Time Attendance Device	2026-08-20 00:00:00	05:51:12	18:34:44	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66138	154	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-17/20260817060336-578.jpg	Time Attendance Device	2026-08-17 00:00:00	06:03:36	18:55:37	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66139	154	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-17/20260817060336-578.jpg	Time Attendance Device	2026-08-18 00:00:00	06:05:24	18:53:58	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66140	154	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-17/20260817060336-578.jpg	Time Attendance Device	2026-08-19 00:00:00	06:05:06	18:52:40	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66141	154	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-17/20260817060336-578.jpg	Time Attendance Device	2026-08-20 00:00:00	06:01:16	18:34:27	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66142	102	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817071340-1151.jpg	Time Attendance Device	2026-08-17 00:00:00	07:13:40	17:51:18	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66143	102	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817071340-1151.jpg	Time Attendance Device	2026-08-18 00:00:00	07:02:41	17:53:14	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66144	102	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817071340-1151.jpg	Time Attendance Device	2026-08-19 00:00:00	07:08:21	17:51:16	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66145	102	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817071340-1151.jpg	Time Attendance Device	2026-08-20 00:00:00	07:15:51	17:51:51	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66146	115	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070758-409.jpg	Time Attendance Device	2026-08-17 00:00:00	07:07:58	17:51:14	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66147	115	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070758-409.jpg	Time Attendance Device	2026-08-18 00:00:00	06:58:05	17:53:11	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66148	115	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070758-409.jpg	Time Attendance Device	2026-08-19 00:00:00	06:57:24	17:51:11	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66149	115	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817070758-409.jpg	Time Attendance Device	2026-08-20 00:00:00	07:04:48	17:51:18	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66150	2	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817054938-565.jpg	Time Attendance Device	2026-08-17 00:00:00	05:49:38	17:49:51	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66151	2	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817054938-565.jpg	Time Attendance Device	2026-08-18 00:00:00	05:45:31	17:51:34	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66152	2	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817054938-565.jpg	Time Attendance Device	2026-08-19 00:00:00	05:46:20	17:50:23	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66153	2	LAMI Mining Site		Palm print	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817054938-565.jpg	Time Attendance Device	2026-08-20 00:00:00	05:46:08	17:49:13	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66154	1	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817052508-1460.jpg	Time Attendance Device	2026-08-17 00:00:00	05:25:08	17:50:03	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66155	1	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817052508-1460.jpg	Time Attendance Device	2026-08-18 00:00:00	05:33:29	17:50:22	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66156	1	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817052508-1460.jpg	Time Attendance Device	2026-08-19 00:00:00	05:39:30	17:50:07	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66157	1	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-17/20260817052508-1460.jpg	Time Attendance Device	2026-08-20 00:00:00	05:36:21	17:49:09	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66158	337	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811070332-1235.jpg	Time Attendance Device	2026-08-11 00:00:00	07:03:32	16:00:12	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66159	337	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811070332-1235.jpg	Time Attendance Device	2026-08-12 00:00:00	07:03:20	16:01:58	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66160	337	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811070332-1235.jpg	Time Attendance Device	2026-08-20 00:00:00	07:13:04	11:10:05	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66161	327	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811070338-516.jpg	Time Attendance Device	2026-08-11 00:00:00	07:03:38	16:00:06	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66162	327	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811070338-516.jpg	Time Attendance Device	2026-08-12 00:00:00	07:06:49	16:02:15	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66163	327	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-11/20260811070338-516.jpg	Time Attendance Device	2026-08-20 00:00:00	07:12:57	11:09:59	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66164	79	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-15/20260815064655-1605.jpg	Time Attendance Device	2026-08-15 00:00:00	06:46:55	17:51:18	Saturday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66165	79	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-15/20260815064655-1605.jpg	Time Attendance Device	2026-08-16 00:00:00	06:49:04	15:54:57	Sunday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66166	79	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-15/20260815064655-1605.jpg	Time Attendance Device	2026-08-18 00:00:00	06:44:55	17:53:27	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66167	79	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-15/20260815064655-1605.jpg	Time Attendance Device	2026-08-19 00:00:00	06:40:49	17:51:19	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66168	478	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810054710-105.jpg	Time Attendance Device	2026-08-10 00:00:00	05:47:10	19:01:04	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66169	478	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810054710-105.jpg	Time Attendance Device	2026-08-11 00:00:00	05:42:11	19:01:07	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66170	478	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810054710-105.jpg	Time Attendance Device	2026-08-12 00:00:00	05:41:35	19:04:37	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66171	478	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810054710-105.jpg	Time Attendance Device	2026-08-13 00:00:00	05:46:25	19:01:43	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66172	478	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810054710-105.jpg	Time Attendance Device	2026-08-14 00:00:00	05:47:38	17:05:15	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66173	107	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055211-1396.jpg	Time Attendance Device	2026-08-10 00:00:00	05:52:11	18:48:14	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66174	107	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055211-1396.jpg	Time Attendance Device	2026-08-11 00:00:00	05:55:19	18:45:59	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66175	107	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055211-1396.jpg	Time Attendance Device	2026-08-12 00:00:00	05:52:18	18:46:20	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66176	107	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055211-1396.jpg	Time Attendance Device	2026-08-13 00:00:00	05:52:45	18:39:48	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66177	107	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055211-1396.jpg	Time Attendance Device	2026-08-14 00:00:00	05:52:45	16:43:20	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66178	149	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055526-791.jpg	Time Attendance Device	2026-08-10 00:00:00	05:55:26	18:47:46	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66179	149	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055526-791.jpg	Time Attendance Device	2026-08-11 00:00:00	05:56:10	18:45:41	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66180	149	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055526-791.jpg	Time Attendance Device	2026-08-12 00:00:00	05:47:43	18:46:05	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66181	149	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055526-791.jpg	Time Attendance Device	2026-08-13 00:00:00	06:01:29	18:39:32	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66182	149	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000081/2026-08-10/20260810055526-791.jpg	Time Attendance Device	2026-08-14 00:00:00	05:54:52	16:43:00	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66183	237	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070809-187.jpg	Time Attendance Device	2026-08-10 00:00:00	07:08:09	16:00:20	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66184	237	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070809-187.jpg	Time Attendance Device	2026-08-11 00:00:00	06:50:10	16:00:03	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66185	237	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070809-187.jpg	Time Attendance Device	2026-08-12 00:00:00	07:03:34	15:58:27	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66186	237	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070809-187.jpg	Time Attendance Device	2026-08-14 00:00:00	06:51:19	15:53:06	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66187	217	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064459-947.jpg	Time Attendance Device	2026-08-10 00:00:00	06:44:59	16:00:07	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66188	217	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064459-947.jpg	Time Attendance Device	2026-08-11 00:00:00	06:49:53	15:59:59	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66189	217	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064459-947.jpg	Time Attendance Device	2026-08-12 00:00:00	06:47:17	15:58:38	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66190	217	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810064459-947.jpg	Time Attendance Device	2026-08-14 00:00:00	06:51:32	15:53:02	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66191	161	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810061937-362.jpg	Time Attendance Device	2026-08-10 00:00:00	06:19:37	17:51:18	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66192	161	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810061937-362.jpg	Time Attendance Device	2026-08-11 00:00:00	06:36:25	17:50:38	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66193	161	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810061937-362.jpg	Time Attendance Device	2026-08-12 00:00:00	06:38:43	17:50:39	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66194	161	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810061937-362.jpg	Time Attendance Device	2026-08-13 00:00:00	06:53:25	17:50:11	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66195	161	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810061937-362.jpg	Time Attendance Device	2026-08-14 00:00:00	06:51:12	15:52:18	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66196	126	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070929-255.jpg	Time Attendance Device	2026-08-10 00:00:00	07:09:29	17:51:14	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66197	126	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070929-255.jpg	Time Attendance Device	2026-08-11 00:00:00	06:56:24	17:51:27	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66198	126	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070929-255.jpg	Time Attendance Device	2026-08-12 00:00:00	07:10:10	17:49:06	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66199	126	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070929-255.jpg	Time Attendance Device	2026-08-13 00:00:00	07:14:21	17:50:14	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66200	126	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070929-255.jpg	Time Attendance Device	2026-08-14 00:00:00	07:12:51	15:51:36	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66201	238	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065256-388.jpg	Time Attendance Device	2026-08-10 00:00:00	06:52:56	13:51:13	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66202	238	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065256-388.jpg	Time Attendance Device	2026-08-11 00:00:00	06:44:32	17:49:36	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66203	238	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065256-388.jpg	Time Attendance Device	2026-08-12 00:00:00	06:42:51	17:49:08	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66204	238	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065256-388.jpg	Time Attendance Device	2026-08-13 00:00:00	06:52:49	17:49:06	Thursday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66205	238	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065256-388.jpg	Time Attendance Device	2026-08-14 00:00:00	06:54:32	15:49:36	Friday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66206	457	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065448-1819.jpg	Time Attendance Device	2026-08-10 00:00:00	06:54:48	15:48:38	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66207	457	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065448-1819.jpg	Time Attendance Device	2026-08-11 00:00:00	06:56:08	15:49:36	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66208	457	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065448-1819.jpg	Time Attendance Device	2026-08-12 00:00:00	06:47:31	15:48:08	Wednesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66209	7	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810070707-1642.jpg	Time Attendance Device	2026-08-10 00:00:00	07:07:07	18:06:10	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66210	7	LAMI Mining Site		human face	upload/att/transactionPhoto/AJE1255000088/2026-08-10/20260810070707-1642.jpg	Time Attendance Device	2026-08-11 00:00:00	06:57:57	18:06:06	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66211	268	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070740-954.jpg	Time Attendance Device	2026-08-10 00:00:00	07:07:40	17:50:10	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66212	268	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810070740-954.jpg	Time Attendance Device	2026-08-11 00:00:00	07:09:19	17:50:59	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66213	216	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065659-367.jpg	Time Attendance Device	2026-08-10 00:00:00	06:56:59	17:50:04	Monday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
66214	216	LAMI Mining Site		human face	upload/att/transactionPhoto/CLGO205160003/2026-08-10/20260810065659-367.jpg	Time Attendance Device	2026-08-11 00:00:00	06:50:43	17:49:07	Tuesday	14	2026-09-22 15:04:42	2026-09-22 15:04:42	f	0	0	f	f	\N	\N	\N	\N
\.


--
-- Data for Name: biometric_imports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.biometric_imports (id, title, status, imported_by, imported_at, total_rows, created_at, updated_at, is_locked, locked_by, locked_at, unlocked_by, unlocked_at, period_start, period_end) FROM stdin;
13	Biometric data for 9/11/2026 - 9/25/2026	unload	site.hr02@lnl.com.ph	2026-09-22 15:01:53	\N	2026-09-22 15:01:53	2026-09-22 15:04:39	\N	\N	\N	\N	\N	2026-08-10	2026-08-26
12	Biometric data for 8/26/2026 - 9/10/2026	unload	cmlanoy@leoniogroup.com	2026-09-09 11:22:03	\N	2026-09-09 11:22:03	2026-09-22 15:01:53	\N	\N	\N	\N	\N	2026-08-10	2026-08-26
14	Biometric data for 8/26/2026 - 9/10/2026	unload	site.hr02@lnl.com.ph	2026-09-22 15:04:39	\N	2026-09-22 15:04:39	2026-09-28 13:31:29	\N	\N	\N	\N	\N	2026-08-10	2026-08-26
15	DailyAttendance.csv	unload	mtyuson@leoniogroup.com	2026-09-28 13:31:29	\N	2026-09-28 13:31:29	2026-09-28 13:32:36	\N	\N	\N	\N	\N	\N	\N
16	Biometric data for 9/11/2026 - 9/26/2026	load	mtyuson@leoniogroup.com	2026-09-28 13:32:36	\N	2026-09-28 13:32:36	2026-09-28 13:32:39	\N	\N	\N	\N	\N	2026-09-11	2026-09-26
\.


--
-- Data for Name: business_units; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.business_units (id, name, head, created_at, updated_at) FROM stdin;
1	Leonio Group	\N	\N	\N
2	LNL Resources Inc.	\N	\N	\N
\.


--
-- Data for Name: certificate_attendance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.certificate_attendance (id, employee_management_id, earliest_time, latest_time, others, reason, date, created_at, updated_at, approval_status, weekday, action, attendance_area, biometric_imports_id, is_cutoff, attendance_records_id) FROM stdin;
1	93	18:00:00	15:00:00	Manual Attendance	\N	2025-11-20	2025-11-28 13:40:13	2025-11-28 13:40:13	Pending	Thursday	add	\N	\N	t	\N
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.companies (id, name, head, created_at, updated_at, business_unit_id) FROM stdin;
1	Petrolift	Joan Villalon	2025-10-16 11:11:12	2025-10-16 11:11:12	\N
2	Mining	John Go	2025-10-17 11:17:04	2025-10-17 11:17:04	\N
\.


--
-- Data for Name: csvimports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.csvimports (id, entry_date, basic, dh, dh_nd, dh_nd_excess, dh_nd_ot, dh_ot, dh_rd, dh_rd_nd, dh_rd_nd_ot, dh_rd_ot, hours_worked, id_number, lh, lh_nd, lh_nd_excess, lh_nd_ot, lh_ot, lh_rd, lh_rd_nd, lh_rd_nd_excess, lh_rd_nd_ot, lh_rd_ot, name, ord_nd, ord_nd_ot, ord_ot, rd, rd_nd, rd_nd_ot, rd_ot, reg_nd_excess, sh, sh_nd, sh_nd_excess, sh_nd_ot, sh_ot, sh_rd, sh_rd_nd, sh_rd_nd_excess, sh_rd_nd_ot, sh_rd_ot, sun_nd_excess, total_non_working_days_present, total_regular_working_days_present, created_at, updated_at, generate_status, biometric_imports_id, period_start, period_end) FROM stdin;
148644	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	68.21	TMNG-202410-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ABELLA, CHRISTIAN JAY VALENCIA	06:00	00:00	12:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148645	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.47	TMNG-202510-991	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	AGPAWA, JHUNEL MAYO	08:00	00:00	18:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148646	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	45.09	TMNG-202510-999	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ALVAREZ, EUGENE ANQUILLIANO	04:00	00:00	13:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148647	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	71.44	TMNG-202208-068	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ANDAL, MARK JOSEPH CATALBAS	00:00	00:00	07:43	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148648	2026-09-28	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.79	TMNG-202509-622	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	APAREJADO, ELAINE BANTOLINO	00:00	00:00	06:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148649	2026-09-28	1000	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	49.19	TMNG-202410-090	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALDAS, GRAIL AGLANO	00:00	00:00	09:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148650	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.31	TMNG-202509-654	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALELIN, EFREN JR. EBEN	05:00	00:00	17:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148651	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	109.27	TMNG-202509-629	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALONCIO, KATRINA MEDALLA	102:00	02:00	12:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	13	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148652	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	40.93	TMNG-202410-051	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BANTOLIN, JUPITER BASILA	03:00	00:00	08:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148653	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.41	TMNG-202510-918	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BARTOLATA, MICHAEL MERTOLA	04:00	00:00	11:23	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148654	2026-09-28	1,187.50	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.57	TMNG-202505-534	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BENG-AD, REYNAN MANGLICMOT	00:00	00:00	17:40	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148655	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.46	TMNG-202504-492	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BERUNIO, REY MIRADOR	06:00	00:00	18:28	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148656	2026-09-28	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.31	TMNG-202509-621	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BONCATO, IVY JOY MOVILLA	00:00	00:00	07:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148657	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.68	TMNG-202410-007	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BORLAZA, JEFFREY MISTA	09:00	00:00	19:41	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148658	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.52	TMNG-202410-020	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BUSTAMANTE, GEORGE JR. MARTICIO	09:00	00:00	17:14	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148659	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	95.39	TMNG-202509-628	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CARDAÑO, WILFREDO JR. PARINAS	00:00	00:00	16:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148660	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.06	TMNG-202410-078	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CASTRO, DANIEL MADAMBA	06:00	00:00	17:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148661	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	118.98	TMNG-202208-235	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CATALBAS, MARICRIS MOVILLA	18:00	00:00	30:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148662	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	51.67	TMNG-202310-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DALANON, ARJAY MAPA	00:00	00:00	19:40	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148663	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.51	TMNG-202509-563	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DAYAG, JEFFRY MELANIO	00:00	00:00	06:52	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148664	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.33	TMNG-202403-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, DARWIN CASUPANAN	00:00	00:00	23:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148665	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	22.79	TMNG-202301-188	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, JOVANNI CASUPANAN	00:00	00:00	06:47	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148666	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	142.2	TMNG-202312-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, RANDY FERNANDEZ	10:00	00:00	46:12	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148667	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.99	TMNG-202510-815	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELOS SANTOS, LORENZ ALOTA	00:00	00:00	14:50	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148668	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.31	TMNG-202509-567	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DIZON, MARCELO AQUINO	00:00	00:00	16:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148669	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	144.41	TMNG-202510-1028	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROSALINO EBANCULLA	10:00	00:04	45:36	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148670	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.86	TMNG-202509-562	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROY ANGELO PULIDO	00:00	00:00	14:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148671	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	60.07	TMNG-202403-002	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBEN, JEFREY BALILIN	02:00	00:00	20:04	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148672	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	91.65	TMNG-202503-486	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ECALDRE, EDDIE NAVIDA	00:00	00:00	19:39	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148673	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.55	TMNG-202501-389	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EDQUILA, ZERWIN MINIMO	00:00	00:00	17:33	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148674	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.16	TMNG-202509-636	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EGMAO, NELSON MENDIGORIN	00:00	00:00	13:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148675	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.49	TMNG-202509-637	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ELAIDA, DARYL SAGUN	00:00	00:00	06:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148676	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.36	TMNG-202510-943	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EQUIZA, JERWIN ARANILLO	00:00	00:00	14:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148677	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.95	TMNG-202310-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, ARIEL TEMPORAL	07:00	00:00	17:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148678	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202507-545	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, JOMEL TEMPORAL	05:00	00:00	16:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148679	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.22	TMNG-202510-670	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GINEZ, SAMUEL BUSTAMANTE	04:00	00:00	12:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148680	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.61	TMNG-202410-057	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GONZAGA, JULIE SAWKILYO	09:00	00:00	17:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148681	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	24.42	TMNG-202409-120	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	INTERNO, JINNO ALBA	00:00	00:00	00:30	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148682	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LABAO, SALVADOR MARAVE	06:00	00:00	17:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148683	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.48	TMNG-202403-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAGUISMA, VALENTINO VALLEJO	05:00	00:00	19:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148684	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.11	TMNG-202509-656	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAZARO, MARK MENOR	04:00	00:00	17:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148685	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.07	TMNG-202410-011	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LEMON, RENO MOSE	08:00	00:00	17:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148686	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.88	TMNG-202310-033	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LUCING, LAURENCE MANAPAT	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148687	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.12	TMNG-202208-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADARANG, ANGELICA MAY MEROY	00:00	00:31	50:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148688	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.42	TMNG-202502-446	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, BRANDO ECLEO	00:00	00:00	06:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148689	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.02	TMNG-202509-574	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MANNY MAESTRE	00:00	00:00	15:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148690	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.82	TMNG-202510-853	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MARDY CONRADA	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148691	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.3	TMNG-202403-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANA, JERRY NEIL CLAVERIA	07:00	00:00	27:18	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148692	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.02	TMNG-202510-1014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANALO, JESUS MODELO	00:00	00:00	03:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148693	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	106.87	TMNG-202212-032	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANUEL, CHRISTIAN EGMAO	00:00	00:00	18:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148694	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	48.93	TMNG-202509-580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, GERI MARAVE	00:00	00:00	08:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148695	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	66.95	TMNG-202303-035	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, JOVENCIO MEJOS	00:00	00:00	11:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148696	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.29	TMNG-202002-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, NICSON MELU	00:00	00:00	19:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148697	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.74	TMNG-202505-524	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, APOLLO MOVILLA	09:00	00:00	19:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148698	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.23	TMNG-202410-161	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, RANDY MERZA	07:00	00:00	16:14	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148699	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	62.99	TMNG-202410-058	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTINEZ, ODEMAR MIRADOR	03:00	00:00	10:09	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148700	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.15	TMNG-202410-013	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYA, JAYMAR MEJOS	06:00	00:00	18:09	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148701	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	50	TMNG-202508-553	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, ARVIN FERNANDO	00:00	00:00	10:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148702	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.41	TMNG-202409-132	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, JOHN LESTER CABICO	00:00	00:00	12:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148703	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.38	TMNG-202410-081	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, REYNALD MACALTAO	06:00	00:00	18:23	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148704	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.33	TMNG-202509-643	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYPAY, RUSSEL LEE MENDOZA	00:00	00:00	13:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148705	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.12	TMNG-202410-030	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ARIES MODELO	02:00	00:00	15:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148706	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202410-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ROGELIO JR. SALVADOR	07:00	00:00	16:27	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148707	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.29	TMNG-202410-026	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JAMES MAYPAY	00:00	00:00	15:53	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148708	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.03	TMNG-202412-310	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JOHN PHILIP MOSE	07:00	00:00	16:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148709	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.06	TMNG-202410-040	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDI, ARMAN MODELO	05:00	00:00	15:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148710	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.01	TMNG-202509-617	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDOZA, JUN MOLINO	00:00	00:00	14:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148711	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.42	TMNG-202410-166	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENES, PATRICK MADARANG	09:00	00:00	19:25	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148712	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	132.65	TMNG-202208-236	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCED, MARICEL MONTEJO	22:00	00:00	28:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	13	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148713	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87	TMNG-202410-043	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCURIO, HAIDEE VALLEJOS	00:00	00:00	14:52	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148714	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.5	TMNG-202410-063	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, CHRISTOPHER MEDEL	05:00	00:00	13:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148715	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.32	TMNG-202510-878	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, FRANK JUSTIN MESIA	04:00	00:00	13:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148716	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	93.51	TMNG-202410-029	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, MARWIN MILANIO	00:00	00:00	13:48	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148717	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.28	TMNG-202509-620	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, NIÑO MOVILLA	00:00	00:00	19:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148718	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.86	TMNG-202509-587	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, WARREN MOVILLA	00:00	00:00	03:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148719	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	32.63	TMNG-202509-578	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	METANTE, JOSEPH MENES	00:00	00:00	00:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148720	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.02	TMNG-202410-082	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILANIO, CHRISTIAN CARPIO	00:00	00:00	18:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148721	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	103.7	TMNG-202409-142	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, JOMAR MISA	00:00	00:00	16:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148722	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	30.69	TMNG-202510-779	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, LAWRENCE BORBON	00:00	00:00	06:35	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148723	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.87	TMNG-202510-863	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MINIMO, JAY PEE OCLIMA	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148724	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.29	TMNG-202410-111	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MIRADOR, VICTORINO MAGNASE	00:00	00:00	15:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148725	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.15	TMNG-202410-012	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MISA, LORENZVIL CADANO	03:00	00:00	11:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148726	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.78	TMNG-202410-085	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, JAY RACRAQUIN	06:00	00:00	15:49	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148727	2026-09-28	550	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.1	TMNG-202410-061	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, LORIMO RACRAQUIN	06:00	00:00	18:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148728	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.1	TMNG-202410-006	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, REYNALD RACRAQUIN	07:00	00:00	16:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148729	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.84	TMNG-202101-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOJENO, JOAN MACALTAO	00:00	00:00	17:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148730	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	109.65	TMNG-202409-150	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTALLA, JAMES MITCHELL MANANGAN	00:00	00:00	21:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148731	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.26	TMNG-202509-644	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTANO, EMMANUEL MARMETO	00:00	00:00	17:18	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148732	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.21	TMNG-202410-014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, AURELIO JR. MODELO	05:00	00:00	17:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148733	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.98	TMNG-202501-346	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, BERNARD MIRADOR	04:00	00:00	16:59	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:39	2026-09-28 13:32:39	f	16	\N	\N
148734	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, HOMER INTERNO	00:00	00:00	18:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148735	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.14	TMNG-202502-443	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, JOE BERT ABAT	08:00	00:00	17:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148736	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.08	TMNG-202509-645	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEROLA, EDWIN MENDIGORIN	00:00	00:00	18:12	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148737	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202408-059	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, MARIO JR. MEDEL	03:00	00:00	16:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148738	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	94.54	TMNG-202509-646	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEVIRGEN, OLIVER MAS	00:00	00:00	09:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148739	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	31.98	TMNG-202509-575	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, DOMINADOR JR. MIANO	00:00	00:00	00:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148740	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.02	TMNG-202509-579	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, JESS MIANO	00:00	00:00	06:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148741	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.21	TMNG-202501-411	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, KENNETH JAY COLISAO	04:00	00:00	07:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148742	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202403-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, OLIVER MESIA	04:00	00:00	27:22	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148743	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	29.25	TMNG-202509-602	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, JAMES MILITAR	00:00	00:00	05:15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148744	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	10.05	TMNG-202509-573	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, ULYSSIS MON	00:00	00:00	02:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	1	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148745	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.9	TMNG-202410-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUEGA, LINO MIRADIOS	06:00	00:00	17:55	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148746	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.53	TMNG-202509-572	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, JOEL MANUEL	03:00	00:00	15:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148747	2026-09-28	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	115.32	TMNG-202403-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, REY ANGELO MEROY	02:00	00:00	35:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148748	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	92	TMNG-202510-1027	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NACIONAL, JONATHAN LEGASPI	00:00	00:00	21:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148749	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	20.12	TMNG-202412-338	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NAVARRO, NIÑO COSME TUGA	00:00	00:00	04:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148750	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	104.69	TMNG-202108-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	OPINGA, REY MERA	00:00	00:00	40:42	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148751	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.99	TMNG-202509-648	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ORINIO, JOAQUIN YANGGA	00:00	00:00	12:45	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148752	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.54	TMNG-202510-963	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, JAYSON MONTERO	02:00	00:00	16:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148753	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.53	TMNG-202410-106	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, MAURICIO MONTERO	02:00	00:00	16:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148754	2026-09-28	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	102.75	TMNG-202502-439	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RALLY MILA	00:00	00:00	21:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148755	2026-09-28	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.35	TMNG-202502-441	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RICKY MILA	00:00	00:00	14:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148756	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202507-547	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PRESTOZA, NICKSON MODELO	07:00	00:00	16:27	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148757	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.17	TMNG-202508-554	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PULIDO, FREDDIE VALENTINO	00:00	00:00	15:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148758	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.04	TMNG-202410-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	QUINACMAN, GILBERT MAYO	08:00	00:00	18:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148759	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.93	TMNG-202509-649	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RABINA, JOESEL CASTILLO	00:00	00:00	15:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148760	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.23	TMNG-202510-704	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ROBENTA, RUEL ALBERO	00:00	00:00	03:21	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148761	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.22	TMNG-202410-031	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RODULFO, RUEL LOPEZ	02:00	00:00	11:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148762	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.22	TMNG-202410-162	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SALES, ALMIL MEDIARIO	08:00	00:00	18:21	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148763	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.89	TMNG-202410-156	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, CARL JUSTIN MOSE	05:00	00:00	13:53	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148528	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	118.98	TMNG-202208-235	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CATALBAS, MARICRIS MOVILLA	18:00	00:00	30:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148529	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	51.67	TMNG-202310-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DALANON, ARJAY MAPA	00:00	00:00	19:40	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148530	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.51	TMNG-202509-563	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DAYAG, JEFFRY MELANIO	00:00	00:00	06:52	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148531	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.33	TMNG-202403-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, DARWIN CASUPANAN	00:00	00:00	23:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148532	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	22.79	TMNG-202301-188	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, JOVANNI CASUPANAN	00:00	00:00	06:47	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148533	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	142.2	TMNG-202312-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, RANDY FERNANDEZ	10:00	00:00	46:12	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148534	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.99	TMNG-202510-815	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELOS SANTOS, LORENZ ALOTA	00:00	00:00	14:50	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148535	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.31	TMNG-202509-567	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DIZON, MARCELO AQUINO	00:00	00:00	16:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148536	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	144.41	TMNG-202510-1028	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROSALINO EBANCULLA	10:00	00:04	45:36	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148537	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.86	TMNG-202509-562	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROY ANGELO PULIDO	00:00	00:00	14:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148538	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	60.07	TMNG-202403-002	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBEN, JEFREY BALILIN	02:00	00:00	20:04	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148539	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	91.65	TMNG-202503-486	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ECALDRE, EDDIE NAVIDA	00:00	00:00	19:39	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148540	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.55	TMNG-202501-389	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EDQUILA, ZERWIN MINIMO	00:00	00:00	17:33	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148541	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.16	TMNG-202509-636	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EGMAO, NELSON MENDIGORIN	00:00	00:00	13:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148542	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.49	TMNG-202509-637	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ELAIDA, DARYL SAGUN	00:00	00:00	06:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148543	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.36	TMNG-202510-943	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EQUIZA, JERWIN ARANILLO	00:00	00:00	14:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148544	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.95	TMNG-202310-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, ARIEL TEMPORAL	07:00	00:00	17:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148545	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202507-545	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, JOMEL TEMPORAL	05:00	00:00	16:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148764	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.63	TMNG-202410-036	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, DOMINADOR MANLINCON	06:00	00:00	16:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148765	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.1	TMNG-202509-651	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SINANGOTE, FREDERICK ESTEBAN	00:00	00:00	19:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148766	2026-09-28	730	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.51	TMNG-202503-453	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SOLIS, VERNIE MILLAN	00:00	00:00	12:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148767	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	81.6	TMNG-202510-1025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TABUCOL, RONALD MARAVE	00:00	00:00	40:34	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148768	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.89	TMNG-202510-1018	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TESORO, MECHELLE MOVILLA	00:00	00:00	07:40	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148769	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.21	TMNG-202410-025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TEVES, MARK ANTHONY MANIAGO	04:00	00:00	13:22	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148770	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.04	TMNG-202208-064	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TUPIG, MARVIN CALVO	00:00	00:00	15:36	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148771	2026-09-28	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.4	TMNG-202509-571	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	URBANO, JOEMAR MONJE	00:00	00:00	03:24	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148772	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202410-022	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, DEXTER BONA	07:00	00:00	15:49	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148773	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.21	TMNG-202410-021	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, NORLITO BUSTAMANTE	08:00	00:00	17:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148774	2026-09-28	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	54.78	TMNG-202510-884	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENTINO, EDILBERTO MERINO	00:00	00:00	06:10	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148775	2026-09-28	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	75.76	TMNG-202410-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENZUELA, JOEL JR. RUBIS	01:00	00:00	11:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
148776	2026-09-28	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	23.8	TMNG-202510-887	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VILLAFLORES, JOHN LUIS MOVILLA	00:00	00:00	00:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-28 13:32:40	2026-09-28 13:32:40	f	16	\N	\N
147624	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.42	TMNG-202502-446	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, BRANDO ECLEO	00:00	00:00	10:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147625	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.02	TMNG-202509-574	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MANNY MAESTRE	00:00	00:00	19:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147626	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.82	TMNG-202510-853	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MARDY CONRADA	00:00	00:00	01:52	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147627	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.3	TMNG-202403-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANA, JERRY NEIL CLAVERIA	07:00	00:00	34:18	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147628	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.02	TMNG-202510-1014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANALO, JESUS MODELO	00:00	00:00	11:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147629	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	106.87	TMNG-202212-032	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANUEL, CHRISTIAN EGMAO	00:00	00:00	29:53	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147630	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	48.93	TMNG-202509-580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, GERI MARAVE	00:00	00:00	13:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147631	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	66.95	TMNG-202303-035	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, JOVENCIO MEJOS	00:00	00:00	17:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147632	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.29	TMNG-202002-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, NICSON MELU	00:00	00:00	29:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147633	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.74	TMNG-202505-524	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, APOLLO MOVILLA	09:00	00:00	29:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147634	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.23	TMNG-202410-161	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, RANDY MERZA	07:00	00:00	25:14	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147635	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	62.99	TMNG-202410-058	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTINEZ, ODEMAR MIRADOR	03:00	00:00	16:04	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147636	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.15	TMNG-202410-013	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYA, JAYMAR MEJOS	06:00	00:00	28:09	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147647	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.42	TMNG-202410-166	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENES, PATRICK MADARANG	09:00	00:00	29:25	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147648	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	132.65	TMNG-202208-236	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCED, MARICEL MONTEJO	22:00	00:00	41:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	13	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147649	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87	TMNG-202410-043	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCURIO, HAIDEE VALLEJOS	00:00	00:00	23:42	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147650	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.5	TMNG-202410-063	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, CHRISTOPHER MEDEL	05:00	00:00	21:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147651	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.32	TMNG-202510-878	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, FRANK JUSTIN MESIA	04:00	00:00	21:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147652	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	93.51	TMNG-202410-029	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, MARWIN MILANIO	00:00	00:00	23:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147653	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.28	TMNG-202509-620	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, NIÑO MOVILLA	00:00	00:00	29:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147654	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.86	TMNG-202509-587	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, WARREN MOVILLA	00:00	00:00	05:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147655	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	32.63	TMNG-202509-578	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	METANTE, JOSEPH MENES	00:00	00:00	04:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147656	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.02	TMNG-202410-082	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILANIO, CHRISTIAN CARPIO	00:00	00:00	28:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147657	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	103.7	TMNG-202409-142	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, JOMAR MISA	00:00	00:00	27:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147658	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	30.69	TMNG-202510-779	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, LAWRENCE BORBON	00:00	00:00	09:35	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147659	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.87	TMNG-202510-863	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MINIMO, JAY PEE OCLIMA	00:00	00:00	01:55	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147660	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.29	TMNG-202410-111	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MIRADOR, VICTORINO MAGNASE	00:00	00:00	24:18	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147661	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.15	TMNG-202410-012	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MISA, LORENZVIL CADANO	03:00	00:00	18:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147662	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.78	TMNG-202410-085	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, JAY RACRAQUIN	06:00	00:00	24:47	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147663	2026-09-09	550	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.1	TMNG-202410-061	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, LORIMO RACRAQUIN	06:00	00:00	28:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147664	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.1	TMNG-202410-006	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, REYNALD RACRAQUIN	07:00	00:00	25:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147665	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.84	TMNG-202101-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOJENO, JOAN MACALTAO	00:00	00:00	26:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147666	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	109.65	TMNG-202409-150	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTALLA, JAMES MITCHELL MANANGAN	00:00	00:00	32:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147667	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.26	TMNG-202509-644	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTANO, EMMANUEL MARMETO	00:00	00:00	27:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147668	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.21	TMNG-202410-014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, AURELIO JR. MODELO	05:00	00:00	27:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147669	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.98	TMNG-202501-346	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, BERNARD MIRADOR	04:00	00:00	25:59	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147670	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, HOMER INTERNO	00:00	00:00	27:59	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147671	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.14	TMNG-202502-443	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, JOE BERT ABAT	08:00	00:00	26:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147672	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.08	TMNG-202509-645	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEROLA, EDWIN MENDIGORIN	00:00	00:00	28:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147673	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202408-059	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, MARIO JR. MEDEL	03:00	00:00	26:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147674	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	94.54	TMNG-202509-646	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEVIRGEN, OLIVER MAS	00:00	00:00	18:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147675	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	31.98	TMNG-202509-575	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, DOMINADOR JR. MIANO	00:00	00:00	03:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147676	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.02	TMNG-202509-579	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, JESS MIANO	00:00	00:00	10:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147677	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.21	TMNG-202501-411	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, KENNETH JAY COLISAO	04:00	00:00	11:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147678	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202403-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, OLIVER MESIA	04:00	00:00	34:22	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147679	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	29.25	TMNG-202509-602	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, JAMES MILITAR	00:00	00:00	08:15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147680	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	10.05	TMNG-202509-573	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, ULYSSIS MON	00:00	00:00	03:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	1	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147681	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.9	TMNG-202410-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUEGA, LINO MIRADIOS	06:00	00:00	27:55	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147682	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.53	TMNG-202509-572	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, JOEL MANUEL	03:00	00:00	19:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147683	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	115.32	TMNG-202403-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, REY ANGELO MEROY	02:00	00:00	45:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147684	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	92	TMNG-202510-1027	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NACIONAL, JONATHAN LEGASPI	00:00	00:00	31:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147685	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	20.12	TMNG-202412-338	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NAVARRO, NIÑO COSME TUGA	00:00	00:00	06:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147686	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	104.69	TMNG-202108-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	OPINGA, REY MERA	00:00	00:00	48:42	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147687	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.99	TMNG-202509-648	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ORINIO, JOAQUIN YANGGA	00:00	00:00	20:45	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147688	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.54	TMNG-202510-963	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, JAYSON MONTERO	02:00	00:00	26:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147689	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.53	TMNG-202410-106	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, MAURICIO MONTERO	02:00	00:00	26:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147690	2026-09-09	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	102.75	TMNG-202502-439	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RALLY MILA	00:00	00:00	31:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147691	2026-09-09	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.35	TMNG-202502-441	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RICKY MILA	00:00	00:00	22:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147692	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202507-547	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PRESTOZA, NICKSON MODELO	07:00	00:00	24:27	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147693	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.17	TMNG-202508-554	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PULIDO, FREDDIE VALENTINO	00:00	00:00	23:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147698	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.22	TMNG-202410-162	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SALES, ALMIL MEDIARIO	08:00	00:00	28:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147699	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.89	TMNG-202410-156	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, CARL JUSTIN MOSE	05:00	00:00	20:53	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147700	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.63	TMNG-202410-036	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, DOMINADOR MANLINCON	06:00	00:00	25:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147701	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.1	TMNG-202509-651	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SINANGOTE, FREDERICK ESTEBAN	00:00	00:00	29:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147702	2026-09-09	730	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.51	TMNG-202503-453	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SOLIS, VERNIE MILLAN	00:00	00:00	19:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147703	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	81.6	TMNG-202510-1025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TABUCOL, RONALD MARAVE	00:00	00:00	51:34	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147704	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.89	TMNG-202510-1018	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TESORO, MECHELLE MOVILLA	00:00	00:00	12:34	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147705	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.21	TMNG-202410-025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TEVES, MARK ANTHONY MANIAGO	04:00	00:00	21:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147706	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.04	TMNG-202208-064	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TUPIG, MARVIN CALVO	00:00	00:00	25:28	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147707	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.4	TMNG-202509-571	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	URBANO, JOEMAR MONJE	00:00	00:00	05:24	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147708	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202410-022	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, DEXTER BONA	07:00	00:00	23:49	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147709	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.21	TMNG-202410-021	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, NORLITO BUSTAMANTE	08:00	00:00	26:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147710	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	54.78	TMNG-202510-884	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENTINO, EDILBERTO MERINO	00:00	00:00	12:10	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147711	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	75.76	TMNG-202410-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENZUELA, JOEL JR. RUBIS	01:00	00:00	19:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147712	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	23.8	TMNG-202510-887	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VILLAFLORES, JOHN LUIS MOVILLA	00:00	00:00	02:48	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147592	2026-09-09	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.31	TMNG-202509-621	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BONCATO, IVY JOY MOVILLA	00:00	00:00	11:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147593	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.68	TMNG-202410-007	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BORLAZA, JEFFREY MISTA	09:00	00:00	29:41	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147594	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.52	TMNG-202410-020	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BUSTAMANTE, GEORGE JR. MARTICIO	09:00	00:00	25:14	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147595	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	95.39	TMNG-202509-628	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CARDAÑO, WILFREDO JR. PARINAS	00:00	00:00	25:54	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147596	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.06	TMNG-202410-078	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CASTRO, DANIEL MADAMBA	06:00	00:00	27:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147597	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	118.98	TMNG-202208-235	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CATALBAS, MARICRIS MOVILLA	18:00	00:00	41:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147598	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	51.67	TMNG-202310-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DALANON, ARJAY MAPA	00:00	00:00	23:40	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147599	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.51	TMNG-202509-563	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DAYAG, JEFFRY MELANIO	00:00	00:00	11:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147600	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.33	TMNG-202403-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, DARWIN CASUPANAN	00:00	00:00	30:20	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147601	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	22.79	TMNG-202301-188	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, JOVANNI CASUPANAN	00:00	00:00	08:47	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147713	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	68.21	TMNG-202410-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ABELLA, CHRISTIAN JAY VALENCIA	06:00	00:00	19:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147714	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.47	TMNG-202510-991	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	AGPAWA, JHUNEL MAYO	08:00	00:00	28:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147715	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	45.09	TMNG-202510-999	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ALVAREZ, EUGENE ANQUILLIANO	04:00	00:00	17:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147716	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	71.44	TMNG-202208-068	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ANDAL, MARK JOSEPH CATALBAS	00:00	00:00	15:26	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147717	2026-09-16	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.79	TMNG-202509-622	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	APAREJADO, ELAINE BANTOLINO	00:00	00:00	10:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147718	2026-09-16	1000	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	49.19	TMNG-202410-090	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALDAS, GRAIL AGLANO	00:00	00:00	14:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147719	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.31	TMNG-202509-654	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALELIN, EFREN JR. EBEN	05:00	00:00	22:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147720	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	121.82	TMNG-202509-629	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALONCIO, KATRINA MEDALLA	00:00	00:11	58:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147721	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	40.93	TMNG-202410-051	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BANTOLIN, JUPITER BASILA	03:00	00:00	12:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147722	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.41	TMNG-202510-918	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BARTOLATA, MICHAEL MERTOLA	04:00	00:00	17:23	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147723	2026-09-16	1,187.50	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.57	TMNG-202505-534	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BENG-AD, REYNAN MANGLICMOT	00:00	00:00	27:34	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147724	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.46	TMNG-202504-492	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BERUNIO, REY MIRADOR	06:00	00:00	28:28	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147725	2026-09-16	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.31	TMNG-202509-621	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BONCATO, IVY JOY MOVILLA	00:00	00:00	11:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147726	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.68	TMNG-202410-007	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BORLAZA, JEFFREY MISTA	09:00	00:00	29:41	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147727	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.52	TMNG-202410-020	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BUSTAMANTE, GEORGE JR. MARTICIO	09:00	00:00	25:14	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147728	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	95.39	TMNG-202509-628	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CARDAÑO, WILFREDO JR. PARINAS	00:00	00:00	25:54	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147729	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.06	TMNG-202410-078	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CASTRO, DANIEL MADAMBA	06:00	00:00	27:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147730	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	118.98	TMNG-202208-235	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CATALBAS, MARICRIS MOVILLA	18:00	00:00	41:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147731	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	51.67	TMNG-202310-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DALANON, ARJAY MAPA	00:00	00:00	23:40	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147732	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.51	TMNG-202509-563	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DAYAG, JEFFRY MELANIO	00:00	00:00	11:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147733	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.33	TMNG-202403-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, DARWIN CASUPANAN	00:00	00:00	30:20	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147734	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	22.79	TMNG-202301-188	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, JOVANNI CASUPANAN	00:00	00:00	08:47	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147735	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	142.2	TMNG-202312-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, RANDY FERNANDEZ	10:00	00:00	58:12	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147736	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.99	TMNG-202510-815	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELOS SANTOS, LORENZ ALOTA	00:00	00:00	24:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147737	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.31	TMNG-202509-567	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DIZON, MARCELO AQUINO	00:00	00:00	25:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147738	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	144.41	TMNG-202510-1028	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROSALINO EBANCULLA	10:00	00:04	57:36	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147739	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.86	TMNG-202509-562	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROY ANGELO PULIDO	00:00	00:00	23:52	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147637	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	50	TMNG-202508-553	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, ARVIN FERNANDO	00:00	00:00	15:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147638	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.41	TMNG-202409-132	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, JOHN LESTER CABICO	00:00	00:00	20:43	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147639	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.38	TMNG-202410-081	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, REYNALD MACALTAO	06:00	00:00	28:23	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147640	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.33	TMNG-202509-643	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYPAY, RUSSEL LEE MENDOZA	00:00	00:00	20:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147641	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.12	TMNG-202410-030	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ARIES MODELO	02:00	00:00	24:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147642	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202410-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ROGELIO JR. SALVADOR	07:00	00:00	24:27	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147643	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.29	TMNG-202410-026	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JAMES MAYPAY	00:00	00:00	25:49	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147644	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.03	TMNG-202412-310	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JOHN PHILIP MOSE	07:00	00:00	24:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147645	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.06	TMNG-202410-040	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDI, ARMAN MODELO	05:00	00:00	24:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147646	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.01	TMNG-202509-617	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDOZA, JUN MOLINO	00:00	00:00	22:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147740	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	60.07	TMNG-202403-002	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBEN, JEFREY BALILIN	02:00	00:00	25:04	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147741	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	91.65	TMNG-202503-486	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ECALDRE, EDDIE NAVIDA	00:00	00:00	28:39	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147742	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.55	TMNG-202501-389	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EDQUILA, ZERWIN MINIMO	00:00	00:00	26:33	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147743	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.16	TMNG-202509-636	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EGMAO, NELSON MENDIGORIN	00:00	00:00	21:10	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147744	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.49	TMNG-202509-637	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ELAIDA, DARYL SAGUN	00:00	00:00	10:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147745	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.36	TMNG-202510-943	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EQUIZA, JERWIN ARANILLO	00:00	00:00	22:20	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147746	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.95	TMNG-202310-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, ARIEL TEMPORAL	07:00	00:00	27:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147747	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202507-545	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, JOMEL TEMPORAL	05:00	00:00	26:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147748	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.22	TMNG-202510-670	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GINEZ, SAMUEL BUSTAMANTE	04:00	00:00	16:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147749	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.61	TMNG-202410-057	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GONZAGA, JULIE SAWKILYO	09:00	00:00	27:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147750	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	24.42	TMNG-202409-120	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	INTERNO, JINNO ALBA	00:00	00:00	03:25	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147751	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LABAO, SALVADOR MARAVE	06:00	00:00	27:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147752	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.48	TMNG-202403-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAGUISMA, VALENTINO VALLEJO	05:00	00:00	24:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147753	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.11	TMNG-202509-656	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAZARO, MARK MENOR	04:00	00:00	22:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147754	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.07	TMNG-202410-011	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LEMON, RENO MOSE	08:00	00:00	26:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147755	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.88	TMNG-202310-033	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LUCING, LAURENCE MANAPAT	00:00	00:00	02:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147606	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.86	TMNG-202509-562	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROY ANGELO PULIDO	00:00	00:00	23:52	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147607	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	60.07	TMNG-202403-002	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBEN, JEFREY BALILIN	02:00	00:00	25:04	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147608	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	91.65	TMNG-202503-486	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ECALDRE, EDDIE NAVIDA	00:00	00:00	28:39	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147609	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.55	TMNG-202501-389	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EDQUILA, ZERWIN MINIMO	00:00	00:00	26:33	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147610	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.16	TMNG-202509-636	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EGMAO, NELSON MENDIGORIN	00:00	00:00	21:10	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147611	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.49	TMNG-202509-637	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ELAIDA, DARYL SAGUN	00:00	00:00	10:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147612	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.36	TMNG-202510-943	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EQUIZA, JERWIN ARANILLO	00:00	00:00	22:20	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147756	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.12	TMNG-202208-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADARANG, ANGELICA MAY MEROY	00:00	00:31	60:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147757	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.42	TMNG-202502-446	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, BRANDO ECLEO	00:00	00:00	10:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147758	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.02	TMNG-202509-574	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MANNY MAESTRE	00:00	00:00	19:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147759	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.82	TMNG-202510-853	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MARDY CONRADA	00:00	00:00	01:52	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147760	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.3	TMNG-202403-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANA, JERRY NEIL CLAVERIA	07:00	00:00	34:18	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147761	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.02	TMNG-202510-1014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANALO, JESUS MODELO	00:00	00:00	11:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147762	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	106.87	TMNG-202212-032	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANUEL, CHRISTIAN EGMAO	00:00	00:00	29:53	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147763	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	48.93	TMNG-202509-580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, GERI MARAVE	00:00	00:00	13:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147764	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	66.95	TMNG-202303-035	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, JOVENCIO MEJOS	00:00	00:00	17:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147765	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.29	TMNG-202002-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, NICSON MELU	00:00	00:00	29:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147766	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.74	TMNG-202505-524	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, APOLLO MOVILLA	09:00	00:00	29:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147767	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.23	TMNG-202410-161	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, RANDY MERZA	07:00	00:00	25:14	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147768	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	62.99	TMNG-202410-058	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTINEZ, ODEMAR MIRADOR	03:00	00:00	16:04	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147769	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.15	TMNG-202410-013	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYA, JAYMAR MEJOS	06:00	00:00	28:09	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147770	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	50	TMNG-202508-553	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, ARVIN FERNANDO	00:00	00:00	15:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147771	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.41	TMNG-202409-132	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, JOHN LESTER CABICO	00:00	00:00	20:43	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147772	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.38	TMNG-202410-081	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, REYNALD MACALTAO	06:00	00:00	28:23	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147773	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.33	TMNG-202509-643	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYPAY, RUSSEL LEE MENDOZA	00:00	00:00	20:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147774	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.12	TMNG-202410-030	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ARIES MODELO	02:00	00:00	24:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147775	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202410-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ROGELIO JR. SALVADOR	07:00	00:00	24:27	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147776	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.29	TMNG-202410-026	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JAMES MAYPAY	00:00	00:00	25:49	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147777	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.03	TMNG-202412-310	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JOHN PHILIP MOSE	07:00	00:00	24:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147778	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.06	TMNG-202410-040	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDI, ARMAN MODELO	05:00	00:00	24:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147779	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.01	TMNG-202509-617	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDOZA, JUN MOLINO	00:00	00:00	22:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147780	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.42	TMNG-202410-166	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENES, PATRICK MADARANG	09:00	00:00	29:25	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147781	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	132.65	TMNG-202208-236	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCED, MARICEL MONTEJO	22:00	00:00	41:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	13	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147782	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87	TMNG-202410-043	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCURIO, HAIDEE VALLEJOS	00:00	00:00	23:42	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147783	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.5	TMNG-202410-063	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, CHRISTOPHER MEDEL	05:00	00:00	21:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147784	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.32	TMNG-202510-878	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, FRANK JUSTIN MESIA	04:00	00:00	21:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147785	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	93.51	TMNG-202410-029	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, MARWIN MILANIO	00:00	00:00	23:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147786	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.28	TMNG-202509-620	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, NIÑO MOVILLA	00:00	00:00	29:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147787	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.86	TMNG-202509-587	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, WARREN MOVILLA	00:00	00:00	05:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147788	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	32.63	TMNG-202509-578	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	METANTE, JOSEPH MENES	00:00	00:00	04:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147789	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.02	TMNG-202410-082	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILANIO, CHRISTIAN CARPIO	00:00	00:00	28:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147790	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	103.7	TMNG-202409-142	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, JOMAR MISA	00:00	00:00	27:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147791	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	30.69	TMNG-202510-779	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, LAWRENCE BORBON	00:00	00:00	09:35	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-16 11:11:03	2026-09-22 16:20:51	t	12	\N	\N
147792	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.87	TMNG-202510-863	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MINIMO, JAY PEE OCLIMA	00:00	00:00	01:55	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147793	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.29	TMNG-202410-111	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MIRADOR, VICTORINO MAGNASE	00:00	00:00	24:18	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147794	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.15	TMNG-202410-012	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MISA, LORENZVIL CADANO	03:00	00:00	18:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147795	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.78	TMNG-202410-085	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, JAY RACRAQUIN	06:00	00:00	24:47	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147796	2026-09-16	550	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.1	TMNG-202410-061	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, LORIMO RACRAQUIN	06:00	00:00	28:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147797	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.1	TMNG-202410-006	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, REYNALD RACRAQUIN	07:00	00:00	25:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147798	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.84	TMNG-202101-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOJENO, JOAN MACALTAO	00:00	00:00	26:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147799	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	109.65	TMNG-202409-150	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTALLA, JAMES MITCHELL MANANGAN	00:00	00:00	32:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147800	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.26	TMNG-202509-644	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTANO, EMMANUEL MARMETO	00:00	00:00	27:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147801	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.21	TMNG-202410-014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, AURELIO JR. MODELO	05:00	00:00	27:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147802	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.98	TMNG-202501-346	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, BERNARD MIRADOR	04:00	00:00	25:59	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147803	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, HOMER INTERNO	00:00	00:00	27:59	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147804	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.14	TMNG-202502-443	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, JOE BERT ABAT	08:00	00:00	26:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147805	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.08	TMNG-202509-645	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEROLA, EDWIN MENDIGORIN	00:00	00:00	28:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147806	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202408-059	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, MARIO JR. MEDEL	03:00	00:00	26:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147807	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	94.54	TMNG-202509-646	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEVIRGEN, OLIVER MAS	00:00	00:00	18:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147808	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	31.98	TMNG-202509-575	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, DOMINADOR JR. MIANO	00:00	00:00	03:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147809	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.02	TMNG-202509-579	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, JESS MIANO	00:00	00:00	10:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147810	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.21	TMNG-202501-411	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, KENNETH JAY COLISAO	04:00	00:00	11:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147811	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202403-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, OLIVER MESIA	04:00	00:00	34:22	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147812	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	29.25	TMNG-202509-602	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, JAMES MILITAR	00:00	00:00	08:15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147813	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	10.05	TMNG-202509-573	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, ULYSSIS MON	00:00	00:00	03:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	1	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147814	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.9	TMNG-202410-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUEGA, LINO MIRADIOS	06:00	00:00	27:55	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147815	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.53	TMNG-202509-572	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, JOEL MANUEL	03:00	00:00	19:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147816	2026-09-16	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	115.32	TMNG-202403-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, REY ANGELO MEROY	02:00	00:00	45:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147817	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	92	TMNG-202510-1027	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NACIONAL, JONATHAN LEGASPI	00:00	00:00	31:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147818	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	20.12	TMNG-202412-338	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NAVARRO, NIÑO COSME TUGA	00:00	00:00	06:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147819	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	104.69	TMNG-202108-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	OPINGA, REY MERA	00:00	00:00	48:42	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147820	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.99	TMNG-202509-648	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ORINIO, JOAQUIN YANGGA	00:00	00:00	20:45	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147821	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.54	TMNG-202510-963	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, JAYSON MONTERO	02:00	00:00	26:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147822	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.53	TMNG-202410-106	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, MAURICIO MONTERO	02:00	00:00	26:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147823	2026-09-16	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	102.75	TMNG-202502-439	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RALLY MILA	00:00	00:00	31:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147824	2026-09-16	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.35	TMNG-202502-441	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RICKY MILA	00:00	00:00	22:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147825	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202507-547	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PRESTOZA, NICKSON MODELO	07:00	00:00	24:27	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147826	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.17	TMNG-202508-554	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PULIDO, FREDDIE VALENTINO	00:00	00:00	23:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147827	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.04	TMNG-202410-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	QUINACMAN, GILBERT MAYO	08:00	00:00	27:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147828	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.93	TMNG-202509-649	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RABINA, JOESEL CASTILLO	00:00	00:00	23:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147829	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.23	TMNG-202510-704	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ROBENTA, RUEL ALBERO	00:00	00:00	12:21	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147830	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.22	TMNG-202410-031	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RODULFO, RUEL LOPEZ	02:00	00:00	18:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147580	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	68.21	TMNG-202410-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ABELLA, CHRISTIAN JAY VALENCIA	06:00	00:00	19:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147581	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.47	TMNG-202510-991	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	AGPAWA, JHUNEL MAYO	08:00	00:00	28:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147582	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	45.09	TMNG-202510-999	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ALVAREZ, EUGENE ANQUILLIANO	04:00	00:00	17:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147583	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	71.44	TMNG-202208-068	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ANDAL, MARK JOSEPH CATALBAS	00:00	00:00	15:26	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147584	2026-09-09	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.79	TMNG-202509-622	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	APAREJADO, ELAINE BANTOLINO	00:00	00:00	10:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147585	2026-09-09	1000	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	49.19	TMNG-202410-090	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALDAS, GRAIL AGLANO	00:00	00:00	14:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147586	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.31	TMNG-202509-654	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALELIN, EFREN JR. EBEN	05:00	00:00	22:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147587	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	121.82	TMNG-202509-629	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALONCIO, KATRINA MEDALLA	00:00	00:11	58:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147588	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	40.93	TMNG-202410-051	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BANTOLIN, JUPITER BASILA	03:00	00:00	12:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147589	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.41	TMNG-202510-918	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BARTOLATA, MICHAEL MERTOLA	04:00	00:00	17:23	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147831	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.22	TMNG-202410-162	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SALES, ALMIL MEDIARIO	08:00	00:00	28:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147832	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.89	TMNG-202410-156	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, CARL JUSTIN MOSE	05:00	00:00	20:53	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147833	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.63	TMNG-202410-036	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, DOMINADOR MANLINCON	06:00	00:00	25:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147834	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.1	TMNG-202509-651	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SINANGOTE, FREDERICK ESTEBAN	00:00	00:00	29:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147835	2026-09-16	730	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.51	TMNG-202503-453	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SOLIS, VERNIE MILLAN	00:00	00:00	19:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147836	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	81.6	TMNG-202510-1025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TABUCOL, RONALD MARAVE	00:00	00:00	51:34	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147837	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.89	TMNG-202510-1018	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TESORO, MECHELLE MOVILLA	00:00	00:00	12:34	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147838	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.21	TMNG-202410-025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TEVES, MARK ANTHONY MANIAGO	04:00	00:00	21:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147839	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.04	TMNG-202208-064	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TUPIG, MARVIN CALVO	00:00	00:00	25:28	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147840	2026-09-16	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.4	TMNG-202509-571	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	URBANO, JOEMAR MONJE	00:00	00:00	05:24	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147841	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202410-022	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, DEXTER BONA	07:00	00:00	23:49	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147842	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.21	TMNG-202410-021	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, NORLITO BUSTAMANTE	08:00	00:00	26:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147843	2026-09-16	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	54.78	TMNG-202510-884	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENTINO, EDILBERTO MERINO	00:00	00:00	12:10	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147694	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.04	TMNG-202410-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	QUINACMAN, GILBERT MAYO	08:00	00:00	27:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147695	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.93	TMNG-202509-649	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RABINA, JOESEL CASTILLO	00:00	00:00	23:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147696	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.23	TMNG-202510-704	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ROBENTA, RUEL ALBERO	00:00	00:00	12:21	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147590	2026-09-09	1,187.50	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.57	TMNG-202505-534	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BENG-AD, REYNAN MANGLICMOT	00:00	00:00	27:34	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147591	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.46	TMNG-202504-492	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BERUNIO, REY MIRADOR	06:00	00:00	28:28	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147602	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	142.2	TMNG-202312-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, RANDY FERNANDEZ	10:00	00:00	58:12	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147603	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.99	TMNG-202510-815	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELOS SANTOS, LORENZ ALOTA	00:00	00:00	24:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147604	2026-09-09	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.31	TMNG-202509-567	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DIZON, MARCELO AQUINO	00:00	00:00	25:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147605	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	144.41	TMNG-202510-1028	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROSALINO EBANCULLA	10:00	00:04	57:36	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147697	2026-09-09	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.22	TMNG-202410-031	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RODULFO, RUEL LOPEZ	02:00	00:00	18:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147844	2026-09-16	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	75.76	TMNG-202410-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENZUELA, JOEL JR. RUBIS	01:00	00:00	19:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147845	2026-09-16	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	23.8	TMNG-202510-887	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VILLAFLORES, JOHN LUIS MOVILLA	00:00	00:00	02:48	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-16 11:11:04	2026-09-22 16:20:51	t	12	\N	\N
147846	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	68.21	TMNG-202410-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ABELLA, CHRISTIAN JAY VALENCIA	06:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147847	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.47	TMNG-202510-991	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	AGPAWA, JHUNEL MAYO	08:00	00:00	15:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147848	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	45.09	TMNG-202510-999	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ALVAREZ, EUGENE ANQUILLIANO	04:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147849	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	71.44	TMNG-202208-068	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ANDAL, MARK JOSEPH CATALBAS	00:00	00:00	05:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147850	2026-09-18	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.79	TMNG-202509-622	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	APAREJADO, ELAINE BANTOLINO	00:00	00:00	03:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147962	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.23	TMNG-202510-704	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ROBENTA, RUEL ALBERO	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147963	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.22	TMNG-202410-031	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RODULFO, RUEL LOPEZ	02:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147964	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.22	TMNG-202410-162	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SALES, ALMIL MEDIARIO	08:00	00:00	11:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147965	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.89	TMNG-202410-156	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, CARL JUSTIN MOSE	05:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147966	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.63	TMNG-202410-036	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, DOMINADOR MANLINCON	06:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147967	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.1	TMNG-202509-651	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SINANGOTE, FREDERICK ESTEBAN	00:00	00:00	18:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147613	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.95	TMNG-202310-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, ARIEL TEMPORAL	07:00	00:00	27:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147614	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202507-545	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, JOMEL TEMPORAL	05:00	00:00	26:57	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147615	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.22	TMNG-202510-670	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GINEZ, SAMUEL BUSTAMANTE	04:00	00:00	16:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147616	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.61	TMNG-202410-057	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GONZAGA, JULIE SAWKILYO	09:00	00:00	27:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147617	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	24.42	TMNG-202409-120	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	INTERNO, JINNO ALBA	00:00	00:00	03:25	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147618	2026-09-09	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LABAO, SALVADOR MARAVE	06:00	00:00	27:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147851	2026-09-18	1000	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	49.19	TMNG-202410-090	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALDAS, GRAIL AGLANO	00:00	00:00	05:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147852	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.31	TMNG-202509-654	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALELIN, EFREN JR. EBEN	05:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147853	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	121.82	TMNG-202509-629	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALONCIO, KATRINA MEDALLA	00:00	00:00	44:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147854	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	40.93	TMNG-202410-051	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BANTOLIN, JUPITER BASILA	03:00	00:00	07:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147855	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.41	TMNG-202510-918	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BARTOLATA, MICHAEL MERTOLA	04:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147856	2026-09-18	1,187.50	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.57	TMNG-202505-534	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BENG-AD, REYNAN MANGLICMOT	00:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147619	2026-09-09	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.48	TMNG-202403-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAGUISMA, VALENTINO VALLEJO	05:00	00:00	24:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147620	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.11	TMNG-202509-656	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAZARO, MARK MENOR	04:00	00:00	22:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147621	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.07	TMNG-202410-011	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LEMON, RENO MOSE	08:00	00:00	26:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147622	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.88	TMNG-202310-033	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LUCING, LAURENCE MANAPAT	00:00	00:00	02:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147623	2026-09-09	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.12	TMNG-202208-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADARANG, ANGELICA MAY MEROY	00:00	00:31	60:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-09 14:04:25	2026-09-22 16:20:51	t	12	\N	\N
147857	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.46	TMNG-202504-492	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BERUNIO, REY MIRADOR	06:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147858	2026-09-18	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.31	TMNG-202509-621	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BONCATO, IVY JOY MOVILLA	00:00	00:00	04:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147859	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.68	TMNG-202410-007	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BORLAZA, JEFFREY MISTA	09:00	00:00	18:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147860	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.52	TMNG-202410-020	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BUSTAMANTE, GEORGE JR. MARTICIO	09:00	00:00	16:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147861	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	95.39	TMNG-202509-628	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CARDAÑO, WILFREDO JR. PARINAS	00:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147862	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.06	TMNG-202410-078	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CASTRO, DANIEL MADAMBA	06:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147863	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	118.98	TMNG-202208-235	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CATALBAS, MARICRIS MOVILLA	18:00	00:00	27:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147864	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	51.67	TMNG-202310-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DALANON, ARJAY MAPA	00:00	00:00	17:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147865	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.51	TMNG-202509-563	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DAYAG, JEFFRY MELANIO	00:00	00:00	04:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147866	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.33	TMNG-202403-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, DARWIN CASUPANAN	00:00	00:00	19:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147867	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	22.79	TMNG-202301-188	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, JOVANNI CASUPANAN	00:00	00:00	06:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147868	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	142.2	TMNG-202312-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELA CRUZ, RANDY FERNANDEZ	10:00	00:00	43:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147869	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.99	TMNG-202510-815	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DELOS SANTOS, LORENZ ALOTA	00:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147870	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.31	TMNG-202509-567	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	DIZON, MARCELO AQUINO	00:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147871	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	144.41	TMNG-202510-1028	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROSALINO EBANCULLA	10:00	00:00	41:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	12	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147872	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.86	TMNG-202509-562	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBANA, ROY ANGELO PULIDO	00:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147873	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	60.07	TMNG-202403-002	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EBEN, JEFREY BALILIN	02:00	00:00	16:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147874	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	91.65	TMNG-202503-486	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ECALDRE, EDDIE NAVIDA	00:00	00:00	17:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147875	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.55	TMNG-202501-389	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EDQUILA, ZERWIN MINIMO	00:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147876	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.16	TMNG-202509-636	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EGMAO, NELSON MENDIGORIN	00:00	00:00	07:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147877	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.49	TMNG-202509-637	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ELAIDA, DARYL SAGUN	00:00	00:00	06:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147878	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.36	TMNG-202510-943	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	EQUIZA, JERWIN ARANILLO	00:00	00:00	11:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147879	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.95	TMNG-202310-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, ARIEL TEMPORAL	07:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147880	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202507-545	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	FLORES, JOMEL TEMPORAL	05:00	00:00	11:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147881	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.22	TMNG-202510-670	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GINEZ, SAMUEL BUSTAMANTE	04:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147882	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.61	TMNG-202410-057	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GONZAGA, JULIE SAWKILYO	09:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147883	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	24.42	TMNG-202409-120	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	INTERNO, JINNO ALBA	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147884	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LABAO, SALVADOR MARAVE	06:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147885	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.48	TMNG-202403-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAGUISMA, VALENTINO VALLEJO	05:00	00:00	18:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147886	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.11	TMNG-202509-656	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAZARO, MARK MENOR	04:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147887	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.07	TMNG-202410-011	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LEMON, RENO MOSE	08:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147888	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.88	TMNG-202310-033	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LUCING, LAURENCE MANAPAT	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147889	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.12	TMNG-202208-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADARANG, ANGELICA MAY MEROY	00:00	00:00	50:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147890	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.42	TMNG-202502-446	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, BRANDO ECLEO	00:00	00:00	04:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147891	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.02	TMNG-202509-574	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MANNY MAESTRE	00:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147892	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.82	TMNG-202510-853	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MARDY CONRADA	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147893	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.3	TMNG-202403-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANA, JERRY NEIL CLAVERIA	07:00	00:00	26:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147894	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.02	TMNG-202510-1014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANALO, JESUS MODELO	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147895	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	106.87	TMNG-202212-032	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANUEL, CHRISTIAN EGMAO	00:00	00:00	11:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147896	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	48.93	TMNG-202509-580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, GERI MARAVE	00:00	00:00	07:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147897	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	66.95	TMNG-202303-035	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, JOVENCIO MEJOS	00:00	00:00	07:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147898	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.29	TMNG-202002-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, NICSON MELU	00:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147899	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.74	TMNG-202505-524	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, APOLLO MOVILLA	09:00	00:00	18:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147900	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.23	TMNG-202410-161	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, RANDY MERZA	07:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147901	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	62.99	TMNG-202410-058	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTINEZ, ODEMAR MIRADOR	03:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147902	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.15	TMNG-202410-013	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYA, JAYMAR MEJOS	06:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147903	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	50	TMNG-202508-553	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, ARVIN FERNANDO	00:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147904	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.41	TMNG-202409-132	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, JOHN LESTER CABICO	00:00	00:00	06:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147905	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.38	TMNG-202410-081	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, REYNALD MACALTAO	06:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147906	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.33	TMNG-202509-643	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYPAY, RUSSEL LEE MENDOZA	00:00	00:00	07:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147907	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.12	TMNG-202410-030	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ARIES MODELO	02:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147908	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202410-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ROGELIO JR. SALVADOR	07:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147909	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.29	TMNG-202410-026	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JAMES MAYPAY	00:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147910	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.03	TMNG-202412-310	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JOHN PHILIP MOSE	07:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147911	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.06	TMNG-202410-040	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDI, ARMAN MODELO	05:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147912	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.01	TMNG-202509-617	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDOZA, JUN MOLINO	00:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147913	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.42	TMNG-202410-166	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENES, PATRICK MADARANG	09:00	00:00	18:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147914	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	132.65	TMNG-202208-236	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCED, MARICEL MONTEJO	22:00	00:00	21:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	13	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147915	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87	TMNG-202410-043	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCURIO, HAIDEE VALLEJOS	00:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147916	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.5	TMNG-202410-063	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, CHRISTOPHER MEDEL	05:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147917	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.32	TMNG-202510-878	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, FRANK JUSTIN MESIA	04:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147918	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	93.51	TMNG-202410-029	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, MARWIN MILANIO	00:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147919	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.28	TMNG-202509-620	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, NIÑO MOVILLA	00:00	00:00	16:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147920	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.86	TMNG-202509-587	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, WARREN MOVILLA	00:00	00:00	02:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147921	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	32.63	TMNG-202509-578	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	METANTE, JOSEPH MENES	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147922	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.02	TMNG-202410-082	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILANIO, CHRISTIAN CARPIO	00:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147923	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	103.7	TMNG-202409-142	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, JOMAR MISA	00:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147924	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	30.69	TMNG-202510-779	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, LAWRENCE BORBON	00:00	00:00	04:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147925	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.87	TMNG-202510-863	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MINIMO, JAY PEE OCLIMA	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147926	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.29	TMNG-202410-111	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MIRADOR, VICTORINO MAGNASE	00:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147927	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.15	TMNG-202410-012	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MISA, LORENZVIL CADANO	03:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147928	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.78	TMNG-202410-085	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, JAY RACRAQUIN	06:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147929	2026-09-18	550	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.1	TMNG-202410-061	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, LORIMO RACRAQUIN	06:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147930	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.1	TMNG-202410-006	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, REYNALD RACRAQUIN	07:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147931	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.84	TMNG-202101-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOJENO, JOAN MACALTAO	00:00	00:00	11:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147932	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	109.65	TMNG-202409-150	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTALLA, JAMES MITCHELL MANANGAN	00:00	00:00	19:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147933	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.26	TMNG-202509-644	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTANO, EMMANUEL MARMETO	00:00	00:00	11:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147934	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.21	TMNG-202410-014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, AURELIO JR. MODELO	05:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147935	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.98	TMNG-202501-346	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, BERNARD MIRADOR	04:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147936	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, HOMER INTERNO	00:00	00:00	11:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147937	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.14	TMNG-202502-443	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, JOE BERT ABAT	08:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147938	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.08	TMNG-202509-645	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEROLA, EDWIN MENDIGORIN	00:00	00:00	11:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147939	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202408-059	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, MARIO JR. MEDEL	03:00	00:00	12:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147940	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	94.54	TMNG-202509-646	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEVIRGEN, OLIVER MAS	00:00	00:00	07:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147941	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	31.98	TMNG-202509-575	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, DOMINADOR JR. MIANO	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147942	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.02	TMNG-202509-579	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, JESS MIANO	00:00	00:00	05:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147943	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.21	TMNG-202501-411	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, KENNETH JAY COLISAO	04:00	00:00	06:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147944	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202403-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, OLIVER MESIA	04:00	00:00	24:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147945	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	29.25	TMNG-202509-602	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, JAMES MILITAR	00:00	00:00	04:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147946	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	10.05	TMNG-202509-573	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, ULYSSIS MON	00:00	00:00	02:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	1	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147947	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.9	TMNG-202410-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUEGA, LINO MIRADIOS	06:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147948	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.53	TMNG-202509-572	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, JOEL MANUEL	03:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147949	2026-09-18	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	115.32	TMNG-202403-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, REY ANGELO MEROY	02:00	00:00	28:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147950	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	92	TMNG-202510-1027	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NACIONAL, JONATHAN LEGASPI	00:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147951	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	20.12	TMNG-202412-338	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NAVARRO, NIÑO COSME TUGA	00:00	00:00	03:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147952	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	104.69	TMNG-202108-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	OPINGA, REY MERA	00:00	00:00	36:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147953	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.99	TMNG-202509-648	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ORINIO, JOAQUIN YANGGA	00:00	00:00	07:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147954	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.54	TMNG-202510-963	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, JAYSON MONTERO	02:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147955	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.53	TMNG-202410-106	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, MAURICIO MONTERO	02:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147956	2026-09-18	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	102.75	TMNG-202502-439	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RALLY MILA	00:00	00:00	15:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147957	2026-09-18	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.35	TMNG-202502-441	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RICKY MILA	00:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147958	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202507-547	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PRESTOZA, NICKSON MODELO	07:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147959	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.17	TMNG-202508-554	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PULIDO, FREDDIE VALENTINO	00:00	00:00	14:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147960	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.04	TMNG-202410-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	QUINACMAN, GILBERT MAYO	08:00	00:00	16:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147961	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.93	TMNG-202509-649	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RABINA, JOESEL CASTILLO	00:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147968	2026-09-18	730	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.51	TMNG-202503-453	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SOLIS, VERNIE MILLAN	00:00	00:00	08:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147969	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	81.6	TMNG-202510-1025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TABUCOL, RONALD MARAVE	00:00	00:00	34:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147970	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.89	TMNG-202510-1018	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TESORO, MECHELLE MOVILLA	00:00	00:00	05:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147971	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.21	TMNG-202410-025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TEVES, MARK ANTHONY MANIAGO	04:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147972	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.04	TMNG-202208-064	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TUPIG, MARVIN CALVO	00:00	00:00	09:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147973	2026-09-18	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.4	TMNG-202509-571	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	URBANO, JOEMAR MONJE	00:00	00:00	02:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147974	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202410-022	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, DEXTER BONA	07:00	00:00	10:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147975	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.21	TMNG-202410-021	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, NORLITO BUSTAMANTE	08:00	00:00	13:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147976	2026-09-18	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	54.78	TMNG-202510-884	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENTINO, EDILBERTO MERINO	00:00	00:00	06:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147977	2026-09-18	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	75.76	TMNG-202410-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENZUELA, JOEL JR. RUBIS	01:00	00:00	07:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
147978	2026-09-18	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	23.8	TMNG-202510-887	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VILLAFLORES, JOHN LUIS MOVILLA	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-18 16:13:25	2026-09-22 16:20:51	t	12	\N	\N
148546	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.22	TMNG-202510-670	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GINEZ, SAMUEL BUSTAMANTE	04:00	00:00	12:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148547	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.61	TMNG-202410-057	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	GONZAGA, JULIE SAWKILYO	09:00	00:00	17:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148548	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	24.42	TMNG-202409-120	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	INTERNO, JINNO ALBA	00:00	00:00	00:30	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148549	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LABAO, SALVADOR MARAVE	06:00	00:00	17:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148550	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.48	TMNG-202403-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAGUISMA, VALENTINO VALLEJO	05:00	00:00	19:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148551	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.11	TMNG-202509-656	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LAZARO, MARK MENOR	04:00	00:00	17:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148552	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.07	TMNG-202410-011	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LEMON, RENO MOSE	08:00	00:00	17:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148553	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.88	TMNG-202310-033	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	LUCING, LAURENCE MANAPAT	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148554	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.12	TMNG-202208-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADARANG, ANGELICA MAY MEROY	00:00	00:31	50:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148555	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.42	TMNG-202502-446	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, BRANDO ECLEO	00:00	00:00	06:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148556	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.02	TMNG-202509-574	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MANNY MAESTRE	00:00	00:00	15:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148557	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.82	TMNG-202510-853	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MADREO, MARDY CONRADA	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148558	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	83.3	TMNG-202403-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANA, JERRY NEIL CLAVERIA	07:00	00:00	27:18	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148559	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.02	TMNG-202510-1014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANALO, JESUS MODELO	00:00	00:00	03:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148560	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	106.87	TMNG-202212-032	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MANUEL, CHRISTIAN EGMAO	00:00	00:00	18:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148561	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	48.93	TMNG-202509-580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, GERI MARAVE	00:00	00:00	08:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148562	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	66.95	TMNG-202303-035	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, JOVENCIO MEJOS	00:00	00:00	11:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148563	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.29	TMNG-202002-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARAVE, NICSON MELU	00:00	00:00	19:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148564	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.74	TMNG-202505-524	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, APOLLO MOVILLA	09:00	00:00	19:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148565	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.23	TMNG-202410-161	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTICIO, RANDY MERZA	07:00	00:00	16:14	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148566	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	62.99	TMNG-202410-058	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MARTINEZ, ODEMAR MIRADOR	03:00	00:00	10:09	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148567	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.15	TMNG-202410-013	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYA, JAYMAR MEJOS	06:00	00:00	18:09	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148511	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	68.21	TMNG-202410-023	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ABELLA, CHRISTIAN JAY VALENCIA	06:00	00:00	12:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148512	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.47	TMNG-202510-991	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	AGPAWA, JHUNEL MAYO	08:00	00:00	18:29	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148513	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	45.09	TMNG-202510-999	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ALVAREZ, EUGENE ANQUILLIANO	04:00	00:00	13:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148514	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	71.44	TMNG-202208-068	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ANDAL, MARK JOSEPH CATALBAS	00:00	00:00	07:43	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148515	2026-09-22	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	38.79	TMNG-202509-622	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	APAREJADO, ELAINE BANTOLINO	00:00	00:00	06:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148516	2026-09-22	1000	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	49.19	TMNG-202410-090	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALDAS, GRAIL AGLANO	00:00	00:00	09:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148517	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	57.31	TMNG-202509-654	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALELIN, EFREN JR. EBEN	05:00	00:00	17:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148518	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	109.27	TMNG-202509-629	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BALONCIO, KATRINA MEDALLA	102:00	02:00	12:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	13	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148519	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	40.93	TMNG-202410-051	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BANTOLIN, JUPITER BASILA	03:00	00:00	08:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148520	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	59.41	TMNG-202510-918	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BARTOLATA, MICHAEL MERTOLA	04:00	00:00	11:23	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148521	2026-09-22	1,187.50	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.57	TMNG-202505-534	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BENG-AD, REYNAN MANGLICMOT	00:00	00:00	17:40	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148522	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.46	TMNG-202504-492	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BERUNIO, REY MIRADOR	06:00	00:00	18:28	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148523	2026-09-22	580	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	39.31	TMNG-202509-621	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BONCATO, IVY JOY MOVILLA	00:00	00:00	07:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148524	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.68	TMNG-202410-007	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BORLAZA, JEFFREY MISTA	09:00	00:00	19:41	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148525	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.52	TMNG-202410-020	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	BUSTAMANTE, GEORGE JR. MARTICIO	09:00	00:00	17:14	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148526	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	95.39	TMNG-202509-628	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CARDAÑO, WILFREDO JR. PARINAS	00:00	00:00	16:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148527	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.06	TMNG-202410-078	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	CASTRO, DANIEL MADAMBA	06:00	00:00	17:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148568	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	50	TMNG-202508-553	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, ARVIN FERNANDO	00:00	00:00	10:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148569	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.41	TMNG-202409-132	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, JOHN LESTER CABICO	00:00	00:00	12:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148570	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.38	TMNG-202410-081	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYO, REYNALD MACALTAO	06:00	00:00	18:23	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148571	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.33	TMNG-202509-643	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MAYPAY, RUSSEL LEE MENDOZA	00:00	00:00	13:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148572	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.12	TMNG-202410-030	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ARIES MODELO	02:00	00:00	15:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148573	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202410-019	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MEDEL, ROGELIO JR. SALVADOR	07:00	00:00	16:27	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148574	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.29	TMNG-202410-026	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JAMES MAYPAY	00:00	00:00	15:53	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148575	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.03	TMNG-202412-310	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MELU, JOHN PHILIP MOSE	07:00	00:00	16:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148576	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.06	TMNG-202410-040	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDI, ARMAN MODELO	05:00	00:00	15:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148577	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	78.01	TMNG-202509-617	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENDOZA, JUN MOLINO	00:00	00:00	14:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148578	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.42	TMNG-202410-166	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MENES, PATRICK MADARANG	09:00	00:00	19:25	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148579	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	132.65	TMNG-202208-236	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCED, MARICEL MONTEJO	22:00	00:00	28:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	13	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148580	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87	TMNG-202410-043	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERCURIO, HAIDEE VALLEJOS	00:00	00:00	14:52	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148581	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.5	TMNG-202410-063	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, CHRISTOPHER MEDEL	05:00	00:00	13:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148582	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.32	TMNG-202510-878	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, FRANK JUSTIN MESIA	04:00	00:00	13:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148583	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	93.51	TMNG-202410-029	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERTOLA, MARWIN MILANIO	00:00	00:00	13:48	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148584	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.28	TMNG-202509-620	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, NIÑO MOVILLA	00:00	00:00	19:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148585	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.86	TMNG-202509-587	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MERZA, WARREN MOVILLA	00:00	00:00	03:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148586	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	32.63	TMNG-202509-578	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	METANTE, JOSEPH MENES	00:00	00:00	00:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148587	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.02	TMNG-202410-082	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILANIO, CHRISTIAN CARPIO	00:00	00:00	18:02	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148588	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	103.7	TMNG-202409-142	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, JOMAR MISA	00:00	00:00	16:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148589	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	30.69	TMNG-202510-779	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MILLAN, LAWRENCE BORBON	00:00	00:00	06:35	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148590	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	18.87	TMNG-202510-863	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MINIMO, JAY PEE OCLIMA	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148591	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.29	TMNG-202410-111	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MIRADOR, VICTORINO MAGNASE	00:00	00:00	15:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148592	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.15	TMNG-202410-012	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MISA, LORENZVIL CADANO	03:00	00:00	11:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148593	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	87.78	TMNG-202410-085	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, JAY RACRAQUIN	06:00	00:00	15:49	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148594	2026-09-22	550	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.1	TMNG-202410-061	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, LORIMO RACRAQUIN	06:00	00:00	18:05	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148595	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.1	TMNG-202410-006	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MODELO, REYNALD RACRAQUIN	07:00	00:00	16:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148596	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.84	TMNG-202101-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOJENO, JOAN MACALTAO	00:00	00:00	17:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148597	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	109.65	TMNG-202409-150	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTALLA, JAMES MITCHELL MANANGAN	00:00	00:00	21:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148598	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.26	TMNG-202509-644	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTANO, EMMANUEL MARMETO	00:00	00:00	17:18	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148599	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.21	TMNG-202410-014	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, AURELIO JR. MODELO	05:00	00:00	17:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148600	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.98	TMNG-202501-346	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, BERNARD MIRADOR	04:00	00:00	16:59	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148601	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.96	TMNG-202410-083	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, HOMER INTERNO	00:00	00:00	18:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148602	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.14	TMNG-202502-443	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, JOE BERT ABAT	08:00	00:00	17:08	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148603	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.08	TMNG-202509-645	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEROLA, EDWIN MENDIGORIN	00:00	00:00	18:12	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148604	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.94	TMNG-202408-059	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTERO, MARIO JR. MEDEL	03:00	00:00	16:56	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148605	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	94.54	TMNG-202509-646	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MONTEVIRGEN, OLIVER MAS	00:00	00:00	09:44	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148606	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	31.98	TMNG-202509-575	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, DOMINADOR JR. MIANO	00:00	00:00	00:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148607	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	44.02	TMNG-202509-579	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, JESS MIANO	00:00	00:00	06:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148608	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.21	TMNG-202501-411	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, KENNETH JAY COLISAO	04:00	00:00	07:58	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148609	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202403-005	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOSE, OLIVER MESIA	04:00	00:00	27:22	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148610	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	29.25	TMNG-202509-602	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, JAMES MILITAR	00:00	00:00	05:15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148611	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	10.05	TMNG-202509-573	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MOVILLA, ULYSSIS MON	00:00	00:00	02:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	1	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148612	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	97.9	TMNG-202410-004	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUEGA, LINO MIRADIOS	06:00	00:00	17:55	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148613	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	47.53	TMNG-202509-572	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, JOEL MANUEL	03:00	00:00	15:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	4	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148614	2026-09-22	600	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	115.32	TMNG-202403-008	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	MUYANO, REY ANGELO MEROY	02:00	00:00	35:19	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148615	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	92	TMNG-202510-1027	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NACIONAL, JONATHAN LEGASPI	00:00	00:00	21:51	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148616	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	20.12	TMNG-202412-338	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	NAVARRO, NIÑO COSME TUGA	00:00	00:00	04:07	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148617	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	104.69	TMNG-202108-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	OPINGA, REY MERA	00:00	00:00	40:42	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148618	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	85.99	TMNG-202509-648	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ORINIO, JOAQUIN YANGGA	00:00	00:00	12:45	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148619	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.54	TMNG-202510-963	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, JAYSON MONTERO	02:00	00:00	16:32	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148620	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.53	TMNG-202410-106	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PEÑARANDA, MAURICIO MONTERO	02:00	00:00	16:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148621	2026-09-22	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	102.75	TMNG-202502-439	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RALLY MILA	00:00	00:00	21:16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148622	2026-09-22	640	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.35	TMNG-202502-441	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PISIGAN, RICKY MILA	00:00	00:00	14:37	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148623	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	80.44	TMNG-202507-547	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PRESTOZA, NICKSON MODELO	07:00	00:00	16:27	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148624	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.17	TMNG-202508-554	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	PULIDO, FREDDIE VALENTINO	00:00	00:00	15:11	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148625	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	90.04	TMNG-202410-001	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	QUINACMAN, GILBERT MAYO	08:00	00:00	18:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148626	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	86.93	TMNG-202509-649	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RABINA, JOESEL CASTILLO	00:00	00:00	15:03	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148627	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.23	TMNG-202510-704	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	ROBENTA, RUEL ALBERO	00:00	00:00	03:21	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148628	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	67.22	TMNG-202410-031	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	RODULFO, RUEL LOPEZ	02:00	00:00	11:31	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148629	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	98.22	TMNG-202410-162	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SALES, ALMIL MEDIARIO	08:00	00:00	18:21	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148630	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	69.89	TMNG-202410-156	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, CARL JUSTIN MOSE	05:00	00:00	13:53	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	7	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148631	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	88.63	TMNG-202410-036	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SARMIENTO, DOMINADOR MANLINCON	06:00	00:00	16:38	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148632	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	99.1	TMNG-202509-651	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SINANGOTE, FREDERICK ESTEBAN	00:00	00:00	19:06	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148633	2026-09-22	730	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	76.51	TMNG-202503-453	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	SOLIS, VERNIE MILLAN	00:00	00:00	12:17	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148634	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	81.6	TMNG-202510-1025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TABUCOL, RONALD MARAVE	00:00	00:00	40:34	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	11	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148635	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	46.89	TMNG-202510-1018	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TESORO, MECHELLE MOVILLA	00:00	00:00	07:40	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	5	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148636	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	77.21	TMNG-202410-025	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TEVES, MARK ANTHONY MANIAGO	04:00	00:00	13:22	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148637	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	96.04	TMNG-202208-064	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	TUPIG, MARVIN CALVO	00:00	00:00	15:36	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	10	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148638	2026-09-22	900	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	19.4	TMNG-202509-571	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	URBANO, JOEMAR MONJE	00:00	00:00	03:24	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	2	2026-09-22 16:20:53	2026-09-22 16:20:53	f	14	\N	\N
148639	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	79.83	TMNG-202410-022	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, DEXTER BONA	07:00	00:00	15:49	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:54	2026-09-22 16:20:54	f	14	\N	\N
148640	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	89.21	TMNG-202410-021	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENCIA, NORLITO BUSTAMANTE	08:00	00:00	17:13	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	9	2026-09-22 16:20:54	2026-09-22 16:20:54	f	14	\N	\N
148641	2026-09-22	650	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	54.78	TMNG-202510-884	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENTINO, EDILBERTO MERINO	00:00	00:00	06:10	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	6	2026-09-22 16:20:54	2026-09-22 16:20:54	f	14	\N	\N
148642	2026-09-22	773	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	75.76	TMNG-202410-003	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VALENZUELA, JOEL JR. RUBIS	01:00	00:00	11:46	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	8	2026-09-22 16:20:54	2026-09-22 16:20:54	f	14	\N	\N
148643	2026-09-22	570	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	23.8	TMNG-202510-887	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	VILLAFLORES, JOHN LUIS MOVILLA	00:00	00:00	00:01	00:00	00:00	00:00	00:00	00:00	00:00	00:00	\N	00:00	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	3	2026-09-22 16:20:54	2026-09-22 16:20:54	f	14	\N	\N
\.


--
-- Data for Name: custom_dates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.custom_dates (id, record_date, title, holiday_type) FROM stdin;
1	2025-01-05 00:00:00	Sunday Rest Day	Rest Day
2	2025-01-12 00:00:00	Sunday Rest Day	Rest Day
3	2025-01-19 00:00:00	Sunday Rest Day	Rest Day
4	2025-01-26 00:00:00	Sunday Rest Day	Rest Day
5	2025-02-02 00:00:00	Sunday Rest Day	Rest Day
6	2025-02-09 00:00:00	Sunday Rest Day	Rest Day
7	2025-02-16 00:00:00	Sunday Rest Day	Rest Day
8	2025-02-23 00:00:00	Sunday Rest Day	Rest Day
9	2025-03-02 00:00:00	Sunday Rest Day	Rest Day
10	2025-03-09 00:00:00	Sunday Rest Day	Rest Day
11	2025-03-16 00:00:00	Sunday Rest Day	Rest Day
12	2025-03-23 00:00:00	Sunday Rest Day	Rest Day
13	2025-03-30 00:00:00	Sunday Rest Day	Rest Day
14	2025-04-06 00:00:00	Sunday Rest Day	Rest Day
15	2025-04-13 00:00:00	Sunday Rest Day	Rest Day
16	2025-04-20 00:00:00	Sunday Rest Day	Rest Day
17	2025-04-27 00:00:00	Sunday Rest Day	Rest Day
18	2025-05-04 00:00:00	Sunday Rest Day	Rest Day
19	2025-05-11 00:00:00	Sunday Rest Day	Rest Day
20	2025-05-18 00:00:00	Sunday Rest Day	Rest Day
21	2025-05-25 00:00:00	Sunday Rest Day	Rest Day
22	2025-06-01 00:00:00	Sunday Rest Day	Rest Day
23	2025-06-08 00:00:00	Sunday Rest Day	Rest Day
24	2025-06-15 00:00:00	Sunday Rest Day	Rest Day
25	2025-06-22 00:00:00	Sunday Rest Day	Rest Day
26	2025-06-29 00:00:00	Sunday Rest Day	Rest Day
27	2025-07-06 00:00:00	Sunday Rest Day	Rest Day
28	2025-07-13 00:00:00	Sunday Rest Day	Rest Day
29	2025-07-20 00:00:00	Sunday Rest Day	Rest Day
30	2025-07-27 00:00:00	Sunday Rest Day	Rest Day
31	2025-08-03 00:00:00	Sunday Rest Day	Rest Day
32	2025-08-10 00:00:00	Sunday Rest Day	Rest Day
33	2025-08-17 00:00:00	Sunday Rest Day	Rest Day
34	2025-08-24 00:00:00	Sunday Rest Day	Rest Day
35	2025-08-31 00:00:00	Sunday Rest Day	Rest Day
36	2025-09-07 00:00:00	Sunday Rest Day	Rest Day
37	2025-09-14 00:00:00	Sunday Rest Day	Rest Day
38	2025-09-21 00:00:00	Sunday Rest Day	Rest Day
39	2025-09-28 00:00:00	Sunday Rest Day	Rest Day
40	2025-10-05 00:00:00	Sunday Rest Day	Rest Day
41	2025-10-12 00:00:00	Sunday Rest Day	Rest Day
42	2025-10-19 00:00:00	Sunday Rest Day	Rest Day
43	2025-10-26 00:00:00	Sunday Rest Day	Rest Day
44	2025-11-02 00:00:00	Sunday Rest Day	Rest Day
45	2025-11-09 00:00:00	Sunday Rest Day	Rest Day
46	2025-11-16 00:00:00	Sunday Rest Day	Rest Day
47	2025-11-23 00:00:00	Sunday Rest Day	Rest Day
48	2025-11-30 00:00:00	Sunday Rest Day	Rest Day
49	2025-12-07 00:00:00	Sunday Rest Day	Rest Day
50	2025-12-14 00:00:00	Sunday Rest Day	Rest Day
51	2025-12-21 00:00:00	Sunday Rest Day	Rest Day
52	2025-12-28 00:00:00	Sunday Rest Day	Rest Day
53	2025-01-01 00:00:00	New Year’s Day	Regular Holiday
54	2025-04-17 00:00:00	Maundy Thursday	Regular Holiday
55	2025-04-18 00:00:00	Good Friday	Regular Holiday
56	2025-04-09 00:00:00	Araw ng Kagitingan (Day of Valor)	Regular Holiday
57	2025-05-01 00:00:00	Labor Day	Regular Holiday
58	2025-06-06 00:00:00	Eid’l Adha	Regular Holiday
59	2025-06-12 00:00:00	Independence Day	Regular Holiday
60	2025-08-25 00:00:00	National Heroes Day	Regular Holiday
61	2025-11-30 00:00:00	Bonifacio Day (Falls on Rest Day)	Regular Holiday
62	2025-12-25 00:00:00	Christmas Day	Regular Holiday
63	2025-12-30 00:00:00	Rizal Day	Regular Holiday
64	2025-01-29 00:00:00	Chinese New Year	Special Non-Working Holiday
65	2025-04-19 00:00:00	Black Saturday	Special Non-Working Holiday
66	2025-08-21 00:00:00	Ninoy Aquino Day	Special Non-Working Holiday
67	2025-10-31 00:00:00	All Saints’ Eve	Special Non-Working Holiday
68	2025-11-01 00:00:00	All Saints’ Day	Special Non-Working Holiday
69	2025-12-08 00:00:00	Feast of the Immaculate Conception of Mary	Special Non-Working Holiday
70	2025-12-24 00:00:00	Christmas Eve	Special Non-Working Holiday
71	2025-12-31 00:00:00	Last Day of the Year	Special Non-Working Holiday
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, department_name, department_head, created_at, updated_at, company_id) FROM stdin;
2	SECURITY	7	2025-10-16 13:47:03	2025-10-16 13:47:03	1
16	ADMINISTRATIVE SERVICES	11	2025-11-27 09:57:22	2025-11-27 09:57:22	2
17	COMMUNITY RELATIONS STAFF	15	2025-11-27 09:57:54	2025-11-27 09:57:54	2
18	EXPLORATION AND MINE GEOLOGY	12	2025-11-27 09:58:31	2025-11-27 09:58:31	2
19	FLEET MAINTENANCE	19	2025-11-27 09:59:16	2025-11-27 09:59:16	2
20	FLEET OPERATIONS	17	2025-11-27 09:59:49	2025-11-27 09:59:49	2
21	FUEL MANAGEMENT	10	2025-11-27 10:00:42	2025-11-27 10:00:42	2
22	HR SERVICES	16	2025-11-27 10:01:15	2025-11-27 10:01:15	2
23	MEPED	20	2025-11-27 10:03:32	2025-11-27 10:03:32	2
24	MINE ENGINEERING	13	2025-11-27 10:04:45	2025-11-27 10:04:45	2
25	OCCUPATIONAL HEALTH AND SAFETY	14	2025-11-27 10:06:41	2025-11-27 10:06:41	2
26	OFFICE OF THE RESIDENT MANAGER	11	2025-11-27 10:07:08	2025-11-27 10:07:08	2
27	PURCHASING	11	2025-11-27 10:10:22	2025-11-27 10:10:22	2
28	WAREHOUSE LOGISTICS	11	2025-11-27 10:11:03	2025-11-27 10:11:03	2
29	VESSEL LOADING	22	2025-11-27 10:11:53	2025-11-27 10:11:53	2
30	SHIPMENT OPERATIONS	22	2025-11-27 10:12:52	2025-11-27 10:12:52	2
31	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	22	2025-11-27 10:14:02	2025-11-27 10:14:02	2
32	LABORATORY	\N	2026-09-28 15:32:52	2026-09-28 15:32:52	2
\.


--
-- Data for Name: dtr_report; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dtr_report (id, employee_management_id, type, record_date, adjustments, created_at, updated_at, biometric_imports_id, hours) FROM stdin;
\.


--
-- Data for Name: employee_management; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employee_management (id, unique_id, employee_name, basic_salary, created_at, updated_at, department, report_to, schedule, relievers, serial_number, rank, schedule_shift, biometric_id, status, reliever) FROM stdin;
5	TMNG-202506-539	MOJENO, ALEXIS MELU	570	\N	\N	COMMUNITY RELATIONS STAFF	Charleane L. Cudal	7-16	\N	\N	\N	\N	\N	Active	f
6	TMNG-202409-150	MONTALLA, JAMES MITCHELL MANANGAN	570	\N	\N	COMMUNITY RELATIONS STAFF	Charleane L. Cudal	7-16	\N	\N	\N	\N	\N	Active	f
7	TMNG-202412-338	NAVARRO, NIÑO COSME TUGA	570	\N	\N	COMMUNITY RELATIONS STAFF	Charleane L. Cudal	7-16	\N	\N	\N	\N	\N	Active	f
20	TMNG-202410-159	ENCILA, JOSHUA NEPACENA	1000	\N	\N	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
27	TMNG-202410-086	LOBINO, CHUCKIE LYN TRUGILLO	1000	\N	\N	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
9	TMNG-202510-991	AGPAWA, JHUNEL MAYO	570	\N	2025-12-15 13:33:05	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
1	TMNG-202510-999	ALVAREZ, EUGENE ANQUILLIANO	600	\N	2025-12-15 13:35:37	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
11	TMNG-202410-051	BANTOLIN, JUPITER BASILA	650	\N	2025-12-15 13:52:34	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
12	TMNG-202510-918	BARTOLATA, MICHAEL MERTOLA	570	\N	2025-12-15 13:53:08	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
13	TMNG-202510-957	BERINGUELA, MELVIN	570	\N	2025-12-15 13:54:15	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
14	TMNG-202504-492	BERUNIO, REY MIRADOR	570	\N	2025-12-15 13:55:19	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
15	TMNG-202410-007	BORLAZA, JEFFREY MISTA	773	\N	2025-12-15 13:56:41	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
16	TMNG-202410-020	BUSTAMANTE, GEORGE JR. MARTICIO	570	\N	2025-12-15 13:57:40	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
17	TMNG-202503-444	BUSTAMANTE, JONNEL MARTICIO	570	\N	2025-12-15 13:57:48	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
18	TMNG-202410-078	CASTRO, DANIEL MADAMBA	773	\N	2025-12-15 14:01:02	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
21	TMNG-202310-023	FLORES, ARIEL TEMPORAL	570	\N	2025-12-15 14:11:21	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
22	TMNG-202507-545	FLORES, JOMEL TEMPORAL	570	\N	2025-12-15 14:11:30	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
2	TMNG-202510-670	GINEZ, SAMUEL BUSTAMANTE	600	\N	2025-12-15 14:14:26	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
23	TMNG-202410-079	GATUS, REX OCAMPO	570	\N	2025-12-15 14:13:06	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
24	TMNG-202410-057	GONZAGA, JULIE SAWKILYO	773	\N	2025-12-15 14:14:41	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
25	TMNG-202410-005	LABAO, SALVADOR MARAVE	773	\N	2025-12-15 14:17:03	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
26	TMNG-202410-011	LEMON, RENO MOSE	570	\N	2025-12-15 14:19:14	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
28	TMNG-202504-491	MANILA, LLOYD MARTIZANO	570	\N	2025-12-15 14:24:07	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
29	TMNG-202410-042	MARDO, KING JAY MEDUL	570	\N	2025-12-15 14:33:14	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
31	TMNG-202410-188	MARTICIO, JOHNRICK MERTO	570	\N	2025-12-15 14:37:41	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
32	TMNG-202410-161	MARTICIO, RANDY MERZA	570	\N	2025-12-15 14:38:43	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
33	TMNG-202510-972	MARTY, SHEILA MAE MUJER	570	\N	2025-12-16 07:58:05	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
34	TMNG-202410-013	MAYA, JAYMAR MEJOS	570	\N	2025-12-16 08:01:33	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
35	TMNG-202410-080	MAYO, JONEL CARIG	570	\N	2025-12-16 08:04:19	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
36	TMNG-202410-081	MAYO, REYNALD MACALTAO	570	\N	2025-12-16 08:06:08	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
37	TMNG-202410-030	MEDEL, ARIES MODELO	650	\N	2025-12-16 08:08:22	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
38	TMNG-202410-019	MEDEL, ROGELIO JR. SALVADOR	570	\N	2025-12-16 08:09:12	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
39	TMNG-202510-919	MELENDEZ, JHUN REYES	570	\N	2025-12-16 08:12:26	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
40	TMNG-202410-026	MELU, JAMES MAYPAY	570	\N	2025-12-16 08:12:53	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
42	TMNG-202410-040	MENDI, ARMAN MODELO	650	\N	2025-12-16 08:13:48	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
43	TMNG-202410-166	MENES, PATRICK MADARANG	570	\N	2025-12-16 08:17:20	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
44	TMNG-202410-063	MERTOLA, CHRISTOPHER MEDEL	650	\N	2025-12-16 08:21:30	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
45	TMNG-202510-878	MERTOLA, FRANK JUSTIN MESIA	570	\N	2025-12-16 08:21:41	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
46	TMNG-202410-029	MERTOLA, MARWIN MILANIO	650	\N	2025-12-16 08:21:58	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
47	TMNG-202410-082	MILANIO, CHRISTIAN CARPIO	570	\N	2025-12-16 08:27:42	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
48	TMNG-202411-217	MILANIO, TIMOTHY GALLARDO	570	\N	2025-12-16 08:28:01	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
3	TMNG-202510-809	MINIMO, ELMER MISA	600	\N	2025-12-16 08:28:55	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
49	TMNG-202410-111	MIRADOR, VICTORINO MAGNASE	650	\N	2025-12-16 08:30:25	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
50	TMNG-202410-012	MISA, LORENZVIL CADANO	773	\N	2025-12-16 08:30:50	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
52	TMNG-202411-265	MODELO, JOSE BASILIO	570	\N	2025-12-16 08:32:57	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
53	TMNG-202410-061	MODELO, LORIMO RACRAQUIN	550	\N	2025-12-16 08:33:09	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
54	TMNG-202410-006	MODELO, REYNALD RACRAQUIN	773	\N	2025-12-16 08:33:20	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
4	TMNG-202510-989	TORNITO, RAFFY MORILLO	600	\N	2025-12-19 08:23:52	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
78	TMNG-202509-636	EGMAO, NELSON MENDIGORIN	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
79	TMNG-202509-637	ELAIDA, DARYL SAGUN	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
80	TMNG-202509-639	LAZARO, DANNY VALENTINO	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
81	TMNG-202509-640	MARQUEZ, EDGAR MINIMO	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
82	TMNG-202509-641	MARTICIO, JOHNUEL TEMPORAL	600	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
83	TMNG-202509-642	MAYA, JOHN LLOYD MEJOS	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
84	TMNG-202509-643	MAYPAY, RUSSEL LEE MENDOZA	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
85	TMNG-202509-644	MONTANO, EMMANUEL MARMETO	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
86	TMNG-202509-645	MONTEROLA, EDWIN MENDIGORIN	600	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
87	TMNG-202509-646	MONTEVIRGEN, OLIVER MAS	650	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
88	TMNG-202509-647	MOSE, JEREMIE MILLAN	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
89	TMNG-202509-648	ORINIO, JOAQUIN YANGGA	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
90	TMNG-202509-649	RABINA, JOESEL CASTILLO	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
91	TMNG-202509-650	RACZA, JESTONI MERCULLO	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
92	TMNG-202509-651	SINANGOTE, FREDERICK ESTEBAN	570	\N	\N	FLEET MAINTENANCE	Limuel N. Macabunga	7-16	\N	\N	\N	\N	\N	Active	f
94	TMNG-202510-765	ADVINCULA, ARIEL NACARIO	900	\N	2025-12-15 13:30:27	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
95	TMNG-202510-769	AGAM, EDMAR MARTEJA	900	\N	2025-12-15 13:32:05	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
96	TMNG-202510-748	AGBULOS, DIOSDADO MERIÑO	900	\N	2025-12-15 13:32:46	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
97	TMNG-202510-927	AGPAWA, JOHN LIMON	900	\N	2025-12-15 13:33:17	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
98	TMNG-202510-721	AGUSTIN, JOY ALNGOG	900	\N	2025-12-15 13:33:36	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
99	TMNG-202510-920	ALMONTE, ALEXANDER PERNACINTA	900	\N	2025-12-15 13:34:57	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
100	TMNG-202510-676	ANCHETA, ARISON MARAVE	900	\N	2025-12-15 13:36:17	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
102	TMNG-202509-622	APAREJADO, ELAINE BANTOLINO	580	\N	2025-12-15 13:46:25	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
103	TMNG-202510-750	APOLINAR, EFREN MAYO	900	\N	2025-12-15 13:46:42	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
104	TMNG-202510-768	AQUINO, ROBIE GARGABITE	900	\N	2025-12-15 13:47:36	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
105	TMNG-202510-671	ARGA, SHAIRA MAE MIRADOR	570	\N	2025-12-15 13:47:50	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
106	TMNG-202510-845	ARIZO, CRISTINA AGACOSCOS	570	\N	2025-12-15 13:48:01	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
107	TMNG-202509-654	BALELIN, EFREN JR. EBEN	900	\N	2025-12-15 13:49:41	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
108	TMNG-202510-684	BANAG, RONEL OCLIMA	900	\N	2025-12-15 13:51:11	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
109	TMNG-202510-894	BANAG, RONNIE LACAMURA	900	\N	2025-12-15 13:51:58	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
56	TMNG-202501-346	MONTERO, BERNARD MIRADOR	570	\N	2025-12-16 08:46:27	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
57	TMNG-202410-083	MONTERO, HOMER INTERNO	650	\N	2025-12-16 08:46:50	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
58	TMNG-202502-443	MONTERO, JOE BERT ABAT	570	\N	2025-12-16 08:48:17	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
59	TMNG-202408-059	MONTERO, MARIO JR. MEDEL	773	\N	2025-12-16 08:48:53	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
60	TMNG-202410-182	MONTERO, RAMEL MODELO	570	\N	2025-12-16 08:49:56	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
61	TMNG-202501-411	MOSE, KENNETH JAY COLISAO	570	\N	2025-12-16 09:04:40	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
62	TMNG-202410-004	MUEGA, LINO MIRADIOS	773	\N	2025-12-16 09:34:27	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
63	TMNG-202510-963	PEÑARANDA, JAYSON MONTERO	570	\N	2025-12-16 09:41:42	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
65	TMNG-202507-547	PRESTOZA, NICKSON MODELO	570	\N	2025-12-16 09:44:14	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
66	TMNG-202410-001	QUINACMAN, GILBERT MAYO	773	\N	2025-12-16 09:46:07	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
67	TMNG-202410-015	RAMIL, CHRISTIAN JHON OSABEL	570	\N	2025-12-16 09:47:41	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
68	TMNG-202410-031	RODULFO, RUEL LOPEZ	650	\N	2025-12-16 09:48:36	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
69	TMNG-202410-162	SALES, ALMIL MEDIARIO	570	\N	2025-12-19 08:21:36	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
71	TMNG-202410-036	SARMIENTO, DOMINADOR MANLINCON	650	\N	2025-12-19 08:21:52	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
70	TMNG-202410-156	SARMIENTO, CARL JUSTIN MOSE	570	\N	2025-12-19 08:22:00	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
72	TMNG-202503-461	SERGIO, RUBEN JR ZAMORA	600	\N	2025-12-19 08:22:15	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
73	TMNG-202504-490	SISON, JOSEPH MOLINO	570	\N	2025-12-19 08:22:40	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
74	TMNG-202410-025	TEVES, MARK ANTHONY MANIAGO	570	\N	2025-12-19 08:23:39	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
76	TMNG-202410-021	VALENCIA, NORLITO BUSTAMANTE	570	\N	2025-12-19 08:25:57	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
77	TMNG-202410-003	VALENZUELA, JOEL JR. RUBIS	773	\N	2025-12-19 08:27:37	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
111	TMNG-202510-683	BANTOLINO, FROILAN CATALBAS	900	\N	2025-12-15 13:52:50	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
112	TMNG-202509-581	BATCHO, MARK MARAVE	900	\N	2025-12-15 13:53:25	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
114	TMNG-202509-611	BERSABE, JERRIMY MAYO	570	\N	2025-12-15 13:55:00	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
115	TMNG-202509-621	BONCATO, IVY JOY MOVILLA	580	\N	2025-12-15 13:55:59	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
116	TMNG-202510-959	BONIEL, VICTOR MERIÑO	900	\N	2025-12-15 13:56:21	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
117	TMNG-202510-685	BUCAT, MARVIN MARAVE	900	\N	2025-12-15 13:57:08	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
118	TMNG-202509-610	CACABILOS, GHYNHEL LANDINGIN	570	\N	2025-12-15 13:58:31	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
119	TMNG-202509-585	CADUNGON, NOIE FRANCISCO	900	\N	2025-12-15 13:58:45	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
120	TMNG-202509-564	CAPINPIN, MELFRED MAYO	900	\N	2025-12-15 13:59:32	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
121	TMNG-202510-901	CARBONEL, JAMES ACOSTA	900	\N	2025-12-15 13:59:44	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
123	TMNG-202510-895	CLEMENTE, VERGILIO ABUAN	900	\N	2025-12-15 14:01:21	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
124	TMNG-202510-759	COLLADO, ROSS BIEN CALDERON	900	\N	2025-12-15 14:01:55	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
125	TMNG-202510-723	CUEVAS, ISAGANI MABANGLO	900	\N	2025-12-15 14:02:36	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
126	TMNG-202509-563	DAYAG, JEFFRY MELANIO	900	\N	2025-12-15 14:03:02	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
127	TMNG-202510-930	DE QUEÑA, ROWELL MAYO	900	\N	2025-12-15 14:03:51	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
128	TMNG-202510-722	DE VERA, HERALD	900	\N	2025-12-15 14:04:02	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
129	TMNG-202510-831	DEL ROSARIO, GARRY MARTILLANO	900	\N	2025-12-15 14:04:55	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
130	TMNG-202509-567	DIZON, MARCELO AQUINO	900	\N	2025-12-15 14:06:42	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
131	TMNG-202509-565	DUMAYAG, ERICK PASCUAL	900	\N	2025-12-15 14:07:05	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
133	TMNG-202510-693	EBITNER, JONNEL EDNALAGA	900	\N	2025-12-15 14:08:19	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
134	TMNG-202510-886	ECALDRE, KHYLA RICA LAQUINDANUM	570	\N	2025-12-15 14:08:57	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
135	TMNG-202510-775	EDILLOR, RICKY JR. MORETO	570	\N	2025-12-15 14:09:12	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
136	TMNG-202510-890	ELAOG, JONATHAN FERRER	570	\N	2025-12-15 14:10:31	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
137	TMNG-202510-943	EQUIZA, JERWIN ARANILLO	900	\N	2025-12-15 14:10:53	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
138	TMNG-202509-601	ESPINO, JOHN CARLO BALLENAS	580	\N	2025-12-15 14:11:07	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
139	TMNG-202510-924	FRANCISCO, MARICAR JOY NOBLEZA	570	\N	2025-12-15 14:11:43	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
140	TMNG-202510-821	GAYTA, GABBY FLORES	900	\N	2025-12-15 14:13:34	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
142	TMNG-202510-724	GERONIMO, JERRY DEL ROSARIO	900	\N	2025-12-15 14:14:15	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
143	TMNG-202510-715	GRANDE, MARICAR MORILLO	570	\N	2025-12-15 14:15:00	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
144	TMNG-202510-740	IBARRA, DEXTER MARCHA	900	\N	2025-12-15 14:15:16	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
145	TMNG-202510-849	IREMEDIO, ANGELITO ROMA	900	\N	2025-12-15 14:16:11	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
146	TMNG-202509-626	JOSE, JAME PRELL CAMPOS	900	\N	2025-12-15 14:16:40	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
147	TMNG-202509-566	JOSE, MARWIN CAMPOS	900	\N	2025-12-15 14:16:52	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
148	TMNG-202510-691	LALUGAN, PEPITO ANCHETA	900	\N	2025-12-15 14:17:26	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
149	TMNG-202509-656	LAZARO, MARK MENOR	570	\N	2025-12-15 14:18:07	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
150	TMNG-202510-958	LIWAN, ARNAN ALAWAS	900	\N	2025-12-15 14:19:58	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
152	TMNG-202510-888	MADREO, IAN MELU	570	\N	2025-12-15 14:21:21	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
153	TMNG-202509-560	MADREO, JEROME MELU	570	\N	2025-12-15 14:21:32	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
154	TMNG-202509-574	MADREO, MANNY MAESTRE	570	\N	2025-12-15 14:21:42	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
155	TMNG-202510-904	MALAB, JOVY RODEO	900	\N	2025-12-15 14:22:16	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
156	TMNG-202510-899	MALANNAG, MYER DUMALLAY	900	\N	2025-12-15 14:22:28	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
157	TMNG-202510-893	MALATE, FELICITO JR. REYES	900	\N	2025-12-15 14:22:43	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
158	TMNG-202510-900	MANIAGO, EDDIE MORALEJO	900	\N	2025-12-15 14:23:50	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
159	TMNG-202510-741	MAPA, JIMMY EISMA	900	\N	2025-12-15 14:24:57	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
160	TMNG-202509-588	MARAVE, DEMETRIO JR. MENDIGORIN	900	\N	2025-12-15 14:25:21	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
162	TMNG-202510-695	MARAVE, JACKIE MEDALLA	570	\N	2025-12-15 14:26:19	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
163	TMNG-202510-822	MARAVE, JAYMAR MEJOS	900	\N	2025-12-15 14:26:33	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
164	TMNG-202510-873	MARAVE, JAYSON MARTICIO	900	\N	2025-12-15 14:26:47	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
165	TMNG-202510-827	MARAVE, JERIC MAURICIO	900	\N	2025-12-15 14:27:05	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
166	TMNG-202510-764	MARAVE, MANNY MEJOS	900	\N	2025-12-15 14:27:36	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
168	TMNG-202510-732	MARAVE, RUBY JANN MARTEJA	570	\N	2025-12-15 14:32:23	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
170	TMNG-202510-694	MARDO, RICKY MOJENO	900	\N	2025-12-15 14:33:37	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
171	TMNG-202310-128	MARDO, RYAN MODELO	900	\N	2025-12-15 14:34:05	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
172	TMNG-202510-675	MARTEJA, JOHN MICHAEL BAYBAY	900	\N	2025-12-15 14:35:21	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
173	TMNG-202510-824	MARTEJA, VIMAR SISGON	900	\N	2025-12-15 14:35:46	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
174	TMNG-202510-823	MARTICIO, GARRY MELU	900	\N	2025-12-15 14:37:06	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
175	TMNG-202510-870	MARTICIO, JOHN CHRISTOPHER AQUINO	900	\N	2025-12-15 14:37:34	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
176	TMNG-202509-584	MARTICIO, LIBRADO MUEGA	900	\N	2025-12-15 14:37:59	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
177	TMNG-202510-929	MAS, ARDIL MODELO	900	\N	2025-12-16 07:58:32	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
179	TMNG-202510-828	MAS, CHARLES JOHN LAQUINDANUM	900	\N	2025-12-16 07:59:00	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
180	TMNG-202510-679	MAS, KHARTHER MAGNO	900	\N	2025-12-16 07:59:27	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
181	TMNG-202510-714	MAS, LAURICE JEAN MOJENO	570	\N	2025-12-16 07:59:41	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
182	TMNG-202510-885	MAS, PATRICK JOHN LAQUINDANUM	570	\N	2025-12-16 07:59:58	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
183	TMNG-202510-960	MATEN, JERICO MASPAT	900	\N	2025-12-16 08:01:05	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
184	TMNG-202510-892	MATILLA, JOMAR MEJOS	570	\N	2025-12-16 08:01:20	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
185	TMNG-202508-553	MAYO, ARVIN FERNANDO	900	\N	2025-12-16 08:02:10	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
186	TMNG-202510-744	MAYO, BERNARD	900	\N	2025-12-16 08:02:37	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
187	TMNG-202510-731	MAYO, CAMILO MEJOS	570	\N	2025-12-16 08:02:48	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
189	TMNG-202510-897	MAYO, MICHAEL JAY MERTOLA	900	\N	2025-12-16 08:04:37	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
190	TMNG-202510-896	MAYO, RANDY MONTANO	900	\N	2025-12-16 08:05:29	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
191	TMNG-202510-841	MAYO, SILVESTER MEÑA	900	\N	2025-12-16 08:06:45	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
192	TMNG-202510-811	MAYO, STEPANNIE MERZA	570	\N	2025-12-16 08:06:58	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
193	TMNG-202510-760	MAYPAY, RANDY MEJOS	900	\N	2025-12-16 08:07:25	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
194	TMNG-202510-889	MEDEL, JENNIE ROSE MARDO	570	\N	2025-12-16 08:08:53	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
195	TMNG-202510-979	MEDIDA, ERNESTO JR. MONTEHERMOSO	900	\N	2025-12-16 08:09:40	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
196	TMNG-202510-848	MEDRANA, EDISON FLORES	900	\N	2025-12-16 08:11:03	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
197	TMNG-202510-898	MEJIA, LORETO MAYO	900	\N	2025-12-16 08:11:22	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
199	TMNG-202509-619	MEJOS, CRISTOPHER UGLAYON	900	\N	2025-12-16 08:11:41	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
200	TMNG-202510-747	MELANIO, REY MARAVE	900	\N	2025-12-16 08:12:07	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
201	TMNG-202510-729	MELANIO, ROMY CASTRO	900	\N	2025-12-16 08:12:15	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
202	TMNG-202510-742	MELU, ELMER JR. MOSE	900	\N	2025-12-16 08:12:41	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
203	TMNG-202510-674	MENDIGORIN, RANNIE MARTICIO	900	\N	2025-12-16 08:16:02	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
204	TMNG-202509-617	MENDOZA, JUN MOLINO	900	\N	2025-12-16 08:16:19	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
206	TMNG-202510-677	MERADIOS, SONNY JR. MARAVE	900	\N	2025-12-16 08:18:22	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
205	TMNG-202510-743	MERADIOS, SONNY PAGARIGAN	900	\N	2025-12-16 08:18:28	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
207	TMNG-202510-689	MERCADO, JOEY MOVILLA	900	\N	2025-12-16 08:18:41	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
208	TMNG-202509-570	MERCADO, LINO BHOY MAYO	900	\N	2025-12-16 08:18:50	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
210	TMNG-202510-673	MEROY, RHEA BERNAL	570	\N	2025-12-16 08:21:03	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
211	TMNG-202509-583	MERZA, DARREN MOVILLA	900	\N	2025-12-16 08:22:22	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
212	TMNG-202509-609	MERZA, FATIMA JUGO	570	\N	2025-12-16 08:22:42	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
213	TMNG-202510-696	MERZA, LYNALEE LIANNE MARTEJA	570	\N	2025-12-16 08:22:59	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
215	TMNG-202509-620	MERZA, NIÑO MOVILLA	900	\N	2025-12-16 08:23:30	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
214	TMNG-202509-576	MERZA, NELSON SR. MILANIO	900	\N	2025-12-16 08:23:23	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
216	TMNG-202509-587	MERZA, WARREN MOVILLA	900	\N	2025-12-16 08:23:46	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
217	TMNG-202509-578	METANTE, JOSEPH MENES	570	\N	2025-12-16 08:24:24	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
219	TMNG-202510-783	MILA, APRIL JOY MANA	570	\N	2025-12-16 08:26:47	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
220	TMNG-202509-604	MILANIO, ANGELITO CASTRO	550	\N	2025-12-16 08:27:34	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
221	TMNG-202510-819	MILANIO, NESAL GUEVARRA	900	\N	2025-12-16 08:27:54	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
222	TMNG-202510-713	MIRADOR, MAE JOYCE PARINAS	570	\N	2025-12-16 08:30:15	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
223	TMNG-202510-829	MISOLA, REYMARK DELOS SANTOS	900	\N	2025-12-16 08:31:02	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
274	TMNG-202510-921	ACOSTA, ROY IGNACIO	650	\N	\N	FUEL MANAGEMENT	Albert M. Miva	6-15	\N	\N	\N	\N	\N	Active	f
276	TMNG-202510-814	DIAPANA, CHRIS DANIEL ROJAS	570	\N	2025-12-15 14:06:10	FUEL MANAGEMENT	Albert M. Miva	7-16	\N	\N	\N	\N	\N	Active	f
277	TMNG-202510-1022	MANEJA, MARCUS ZALDUA	570	\N	2025-12-15 14:23:15	FUEL MANAGEMENT	Albert M. Miva	7-16	\N	\N	\N	\N	\N	Active	f
278	TMNG-202509-569	MEDEL, CRISTIAN ABUAN	570	\N	2025-12-16 08:08:32	FUEL MANAGEMENT	Albert M. Miva	7-16	\N	\N	\N	\N	\N	Active	f
279	TMNG-202510-846	MENDIGORIN, JOSEPH MOLINO	650	\N	2025-12-16 08:15:40	FUEL MANAGEMENT	Albert M. Miva	7-16	\N	\N	\N	\N	\N	Active	f
224	TMNG-202510-678	MODELO, EDWARD MELU	900	\N	2025-12-16 08:32:33	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
226	TMNG-202509-614	MOJENO, VIDA MELU	570	\N	2025-12-16 08:34:26	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
227	TMNG-202510-727	MON, DARWIN MANILA	900	\N	2025-12-16 08:34:55	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
228	TMNG-202509-582	MONDALA, JOHN DAVE STA. MARIA	900	\N	2025-12-16 08:35:11	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
229	TMNG-202509-618	MONSALUD, JAYSON MENDOZA	570	\N	2025-12-16 08:35:49	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
230	TMNG-202509-555	MONSANTO, RODEL MARAVE	900	\N	2025-12-16 08:36:10	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
231	TMNG-202510-954	MONSANTO, ROMEO JR. MARAVE	900	\N	2025-12-16 08:36:15	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
232	TMNG-202510-910	MONTANO, JOHN PAUL VASQUEZ	900	\N	2025-12-16 08:36:54	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
233	TMNG-202510-730	MONTERO, JEFREY MODELO	570	\N	2025-12-16 08:47:05	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
234	TMNG-202510-734	MONTERO, JOSE MEGANO	900	\N	2025-12-16 08:48:28	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
235	TMNG-202509-652	MONTERO, VIC MAYPAY	900	\N	2025-12-16 08:50:15	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
237	TMNG-202509-575	MOSE, DOMINADOR JR. MIANO	900	\N	2025-12-16 09:03:53	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
238	TMNG-202509-579	MOSE, JESS MIANO	900	\N	2025-12-16 09:04:28	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
239	TMNG-202509-577	MOVILLA, ALDRIN MILITAR	900	\N	2025-12-16 09:31:44	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
240	TMNG-202510-716	MOVILLA, AMANDA MARIE MANZANO	570	\N	2025-12-16 09:31:54	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
241	TMNG-202510-922	MOVILLA, CELESTE JOY DEL ROSARIO	570	\N	2025-12-16 09:32:07	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
242	TMNG-202510-688	MOVILLA, GLENN MARK MELANIO	900	\N	2025-12-16 09:32:16	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
243	TMNG-202509-602	MOVILLA, JAMES MILITAR	900	\N	2025-12-16 09:32:26	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
244	TMNG-202510-720	MOVILLA, JESSIE VILLANUEVA	570	\N	2025-12-16 09:32:43	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
246	TMNG-202510-697	MOVILLA, PRINCESS MARA FERNANDEZ	570	\N	2025-12-16 09:33:04	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
247	TMNG-202510-832	MOVILLA, RAHAM BLANCIO	900	\N	2025-12-16 09:33:12	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
248	TMNG-202510-789	MOVILLA, REY PUTIAN	570	\N	2025-12-16 09:33:19	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
249	TMNG-202509-573	MOVILLA, ULYSSIS MON	900	\N	2025-12-16 09:33:51	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
250	TMNG-202509-607	MOVILLA, VIRGELUNA ACOSTA	570	\N	2025-12-16 09:34:00	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
251	TMNG-202509-572	MUYANO, JOEL MANUEL	900	\N	2025-12-16 09:34:54	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
252	TMNG-202509-608	NAVARRO, MAE MERCURIO	570	\N	2025-12-16 09:35:26	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
253	TMNG-202510-907	NAZ, JOHN MARK	570	\N	2025-12-16 09:36:02	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
254	TMNG-202510-818	NILO, DOMINADOR MADAMBA	900	\N	2025-12-16 09:36:15	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
256	TMNG-202510-725	PEREZ, LOUIE ABADAY	900	\N	2025-12-16 09:42:00	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
257	TMNG-202508-554	PULIDO, FREDDIE VALENTINO	900	\N	2025-12-16 09:44:33	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
258	TMNG-202510-925	PULIDO, RODELIO BUSTRIA	900	\N	2025-12-16 09:44:45	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
259	TMNG-202510-681	QUINACMAN, GILMER MAYO	900	\N	2025-12-16 09:46:14	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
260	TMNG-202510-738	QUINACMAN, QUINSIR MEDALLA	900	\N	2025-12-16 09:46:24	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
261	TMNG-202510-718	RABINA, RUSTOM CASTILLO	570	\N	2025-12-16 09:46:51	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
280	TMNG-202510-813	RACZA, JONALYN MERCUILLO	570	\N	2025-12-16 09:47:12	FUEL MANAGEMENT	Albert M. Miva	7-16	\N	\N	\N	\N	\N	Active	f
262	TMNG-202510-902	RAMBOYONG, JEFREY MANA	900	\N	2025-12-16 09:47:28	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
263	TMNG-202510-906	RAPADA, ELJER MELU	900	\N	2025-12-16 09:48:05	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
265	TMNG-202510-847	ROMERO, JEWIE MUYANO	900	\N	2025-12-16 09:48:46	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
266	TMNG-202510-690	TAOC, JOEL MARTINEZ	900	\N	2025-12-19 08:23:18	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
267	TMNG-202509-568	TUDLA, JONATHAN DIZON	900	\N	2025-12-19 08:24:02	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
268	TMNG-202509-571	URBANO, JOEMAR MONJE	900	\N	2025-12-19 08:25:07	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
269	TMNG-202510-981	VALE, EDUARDO DORA	900	\N	2025-12-19 08:25:35	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
270	TMNG-202510-844	VALENTINO, BRYAN MUEGA	900	\N	2025-12-19 08:26:14	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
271	TMNG-202510-706	VALLE, KIMBERLEY TAOC	570	\N	2025-12-19 08:27:50	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
272	TMNG-202509-613	VILLARUZ, GEMMO BIBAL	570	\N	2025-12-19 08:28:20	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
281	TMNG-202409-166	PISIGAN, MICHELLE MORTIL	570	\N	\N	HR SERVICES	Deo F. Sienes	7-16	\N	\N	\N	\N	\N	Active	f
282	TMNG-202510-941	ADAN, JEDAN MENEJE	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
283	TMNG-202510-905	ANAS, CHRIS MANALO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
284	TMNG-202510-936	ANGALA, REX IAN BULATAO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
285	TMNG-202510-945	ANTONIO, JULIET ACOSTA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
287	TMNG-202310-019	DALANON, ARJAY MAPA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
288	TMNG-202510-938	FRANCISCO, RONEL BOY NOBLEZA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
289	TMNG-202310-030	LEANDADO, LUISITO HIPOL	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
290	TMNG-202208-083	MADARANG, ANGELICA MAY MEROY	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
291	TMNG-202505-530	MANTES, RAYMART MONTEJO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
292	TMNG-202510-700	MARTY, JEFFERSON MUYANO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
293	TMNG-202510-942	MEER, IAN MISTICA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
294	TMNG-202510-698	MENDI, RAMON CHRISTOPHER	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
295	TMNG-202510-702	MENDIGORIN, LUIS FLORES	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
296	TMNG-202510-699	MENDOZA, REXY MINIMO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
297	TMNG-202510-707	MERCURIO, DARWIN MINIMO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
298	TMNG-202510-940	MINIMO, RONNEL MANA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
299	TMNG-202510-703	MISTICA, JOEL CARIAGA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
300	TMNG-202102-003	MOJECA, JEFFREY MORTIL	650	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
301	TMNG-202510-711	MONSALUD, JHODEL GONZAGA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
302	TMNG-202510-939	MONTEVIRGEN, JAY-VEE YANGA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
303	TMNG-202510-705	MORILLO, MARLON PABITO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
304	TMNG-202301-085	MORTIL, JESSIE MINIMO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
305	TMNG-202510-710	MOVILLA, PAOLO MENDOZA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
306	TMNG-202108-003	OPINGA, REY MERA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
307	TMNG-202510-946	OREIRO, JOVYLYN BAUTISTA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
308	TMNG-202510-934	PANDEZ, MICHELLE BALILIN	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
309	TMNG-202510-701	POCSIDIO, GRACE MARCELINO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
310	TMNG-202510-935	PRESADO, ERNESTO DELLOSA	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
311	TMNG-202510-708	QUIMERISTA, JAYSON MOLINO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
312	TMNG-202510-709	QUIMERISTA, PRUDENCIO JR. MOLINO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
313	TMNG-202208-085	QUISISIM, LEO ANTALAN	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
314	TMNG-202510-704	ROBENTA, RUEL ALBERO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
315	TMNG-202510-712	SISON, LEONARDO JR. OCAMPO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
316	TMNG-202510-937	VALDEZ, MARCHERNAN ECALDRE	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
332	TMNG-202510-877	MAYO, FERDANDO JR. DANOOG	570	\N	\N	MEPED	Maricris D. Malannag	6-15	\N	\N	\N	\N	\N	Active	f
318	TMNG-202510-876	COLLADO, RUSTAN EDZEL CALDERON	570	\N	2025-12-15 14:02:04	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
319	TMNG-202210-008	CRESENCIO, ROBERT JR. VILLARUBIA	570	\N	2025-12-15 14:02:22	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
320	TMNG-202408-029	DONES, ALEXANDER MIANO	570	\N	2025-12-15 14:06:53	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
322	TMNG-202510-867	ELAOG, ARNOLD MOLINA	570	\N	2025-12-15 14:10:21	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
323	TMNG-202510-854	GAPAC, PABLO JR. MUEGA	570	\N	2025-12-15 14:12:43	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
324	TMNG-202410-184	JOSE, ERWIN JR. CAMPOS	570	\N	2025-12-15 14:16:28	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
325	TMNG-202510-879	LAZARO, DANILO KUIZON	570	\N	2025-12-15 14:17:41	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
326	TMNG-202510-881	LEOMO, MARIA CASANDRA TUGA	650	\N	2025-12-15 14:19:27	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
327	TMNG-202510-853	MADREO, MARDY CONRADA	570	\N	2025-12-15 14:21:51	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
328	TMNG-202209-001	MARAVE, ERICSON MEDEL	570	\N	2025-12-15 14:25:46	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
329	TMNG-202303-035	MARAVE, JOVENCIO MEJOS	570	\N	2025-12-15 14:27:22	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
342	TMNG-202002-003	MOVILLA, ROGER JR. COLLADO	570	\N	2025-12-15 14:28:36	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
338	TMNG-202101-008	MOJENO, JOAN MACALTAO	570	\N	2025-12-15 14:28:47	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
331	TMNG-202408-031	MAYA, MARK CZAAR FLORES	570	\N	2025-12-16 08:01:56	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
333	TMNG-202409-132	MAYO, JOHN LESTER CABICO	570	\N	2025-12-16 08:04:07	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
334	TMNG-202510-864	MENDEZ, JERIC MORIA	570	\N	2025-12-16 08:13:25	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
335	TMNG-202505-507	MIANO, JESON BICO	570	\N	2025-12-16 08:24:56	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
336	TMNG-202408-032	MILANIO, ALVIN REYES	570	\N	2025-12-16 08:27:18	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
337	TMNG-202510-863	MINIMO, JAY PEE OCLIMA	570	\N	2025-12-16 08:29:26	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
339	TMNG-202408-033	MOJENO, ROLLY MARDO	570	\N	2025-12-16 08:34:18	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
340	TMNG-202510-961	MORADOS, JOMARI MELU	570	\N	2025-12-16 09:01:51	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
341	TMNG-202408-034	MOVILLA, JAYSON MILANIO	570	\N	2025-12-16 09:31:31	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
354	TMNG-202510-787	ALAYON, AIRAN INSIGNE	570	\N	2025-12-15 13:34:23	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
355	TMNG-202509-599	ALGABA, ALJIE MOVILLA	570	\N	2025-12-15 13:34:41	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
356	TMNG-202510-947	ANCHETA, ERIC MAOILE	570	\N	2025-12-15 13:36:37	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
358	TMNG-202510-758	ANCHETA, JAVIER TESORO	570	\N	2025-12-15 13:37:29	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
359	TMNG-202509-590	ANCHETA, RIZALDE TESORO	570	\N	2025-12-15 13:37:40	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
360	TMNG-202509-655	ANICAL, ARMAN MENDI	650	\N	2025-12-15 13:45:26	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
361	TMNG-202509-589	ANICAL, CRISALINO LEMON	570	\N	2025-12-15 13:45:35	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
362	TMNG-202509-632	BAGORIO, ROGELIO JR. MILANIO	650	\N	2025-12-15 13:48:15	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
363	TMNG-202510-772	BALANGON, ROLLYN MOJENO	570	\N	2025-12-15 13:49:14	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
364	TMNG-202504-485	BUCAT, JESTONY MERANO	570	\N	2025-12-15 13:56:59	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
365	TMNG-202510-755	BUENO, FERNANDO GONZALES	570	\N	2025-12-15 13:57:26	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
366	TMNG-202510-763	CALAGUIN, CEJAE OCDE	570	\N	2025-12-15 13:58:58	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
367	TMNG-202510-795	CAMARILLO, CLARENCE CARIASO	570	\N	2025-12-15 13:59:17	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
369	TMNG-202510-949	COLLADO, NESTOR JR. MODELO	570	\N	2025-12-15 14:01:39	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
370	TMNG-202510-812	DELOS SANTOS, HEZZEL ALGABA	570	\N	2025-12-15 14:05:43	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
371	TMNG-202510-736	GALLENDEZ, VICTOR BUKIS	650	\N	2025-12-15 14:12:14	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
372	TMNG-202510-746	LEGASPINA, JIM ERIC MEDALLA	570	\N	2025-12-15 14:18:29	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
373	TMNG-202510-810	LEGASPINA, JOHN PATRICK FERRER	570	\N	2025-12-15 14:18:36	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
374	TMNG-202509-592	LEMON, ALEX ODAN	570	\N	2025-12-15 14:18:49	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
375	TMNG-202310-124	LEMON, ALVIN MIANO	570	\N	2025-12-15 14:18:59	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
376	TMNG-202509-591	LEMON, RANY JR. MARDO	570	\N	2025-12-15 14:19:07	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
377	TMNG-202509-653	LIMON, ANASTACIO JR. MARTICIO	650	\N	2025-12-15 14:19:39	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
378	TMNG-202510-739	LIMON, ANGELO FOTANILLAS	650	\N	2025-12-15 14:19:46	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
380	TMNG-202510-915	MANIAGO, BRYCE MERCURIO	570	\N	2025-12-15 14:23:32	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
381	TMNG-202509-635	MANTOLINO, LARRY JR. DELA CRUZ	650	\N	2025-12-15 14:24:36	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
382	TMNG-202509-669	MANTOLINO, RAFFY DELA CRUZ	570	\N	2025-12-15 14:24:45	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
383	TMNG-202510-956	MARAVE, AIVEN RENZ NITUMA	570	\N	2025-12-15 14:25:08	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
384	TMNG-202509-559	MARAVE, EDWIN MUEGA	570	\N	2025-12-15 14:25:33	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
385	TMNG-202509-603	MARAVE, GENEROSO JR. MAGA	650	\N	2025-12-15 14:25:57	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
386	TMNG-202002-004	MARAVE, NICSON MELU	570	\N	2025-12-15 14:27:49	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
387	TMNG-202509-627	MARAVE, RIC PAGARIGAN	570	\N	2025-12-15 14:28:06	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
345	TMNG-202208-061	NITUMA, WALTER GARCIA	570	\N	2025-12-15 14:29:17	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
349	TMNG-202208-064	TUPIG, MARVIN CALVO	570	\N	2025-12-15 14:29:29	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
388	TMNG-202510-737	MARAVE, SALVADOR ORIENTE	650	\N	2025-12-15 14:32:40	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
390	TMNG-202509-557	MARDO, RONEL MODELO	570	\N	2025-12-15 14:33:53	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
391	TMNG-202509-631	MARI, ARMANDO MEDIARIO	570	\N	2025-12-15 14:34:16	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
343	TMNG-202410-097	MOVILLA, SIRJHON COLLADO	570	\N	2025-12-16 09:33:44	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
344	TMNG-202502-442	MUEGA, ELMER MERADIOS	570	\N	2025-12-16 09:34:16	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
346	TMNG-202510-851	PAVIA, LUISIE ARIATE	570	\N	2025-12-16 09:37:17	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
347	TMNG-202510-908	PISIGAN, MONSOUR MORTIL	570	\N	2025-12-16 09:42:12	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
348	TMNG-202503-453	SOLIS, VERNIE MILLAN	730	\N	2025-12-19 08:22:54	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
350	TMNG-202510-862	VALENTINO, DICK MESIANO	570	\N	2025-12-19 08:26:26	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
351	TMNG-202510-868	VALENTINO, JOSE JR. MAS	570	\N	2025-12-19 08:26:59	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
352	TMNG-202510-855	VALENTINO, MANDY MESIANO	570	\N	2025-12-19 08:27:11	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
393	TMNG-202509-606	MARTEJA, RICKY ARFAPO	570	\N	2025-12-15 14:35:34	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
395	TMNG-202510-762	MARTICIO, BERNARD MEBA	650	\N	2025-12-15 14:36:50	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
396	TMNG-202510-883	MARTICIO, JEFFREY MOVILLA	570	\N	2025-12-15 14:37:19	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
397	TMNG-202509-593	MARTICIO, MICHAEL ZARATE	570	\N	2025-12-15 14:38:30	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
398	TMNG-202510-913	MAYO, CARLOS MIGUEL AGAM	570	\N	2025-12-16 08:03:00	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
399	TMNG-202509-668	MAYO, JEFFREY MONTEVIRGEN	570	\N	2025-12-16 08:03:52	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
400	TMNG-202308-016	MAYO, RAYMOND MEDIARIO	650	\N	2025-12-16 08:05:43	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
401	TMNG-202510-751	MAYO, RENATO APOLINAR	570	\N	2025-12-16 08:05:54	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
402	TMNG-202410-032	MAYO, ROBERT MARTECIO	570	\N	2025-12-16 08:06:24	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
403	TMNG-202510-745	MAYO, ROLEX MARTICIO	650	\N	2025-12-16 08:06:35	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
404	TMNG-202509-633	MAYO, WILFREDO JR. MERZA	650	\N	2025-12-16 08:07:11	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
406	TMNG-202510-804	MEDEL, DELMAR MARDO	570	\N	2025-12-16 08:08:42	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
407	TMNG-202509-600	MEDEL, ROYDEN MARDO	570	\N	2025-12-16 08:09:21	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
408	TMNG-202510-955	MEJOS, JESTER MESIA	570	\N	2025-12-16 08:11:51	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
409	TMNG-202509-623	MENDEZ, FERDINAND PALCAT	650	\N	2025-12-16 08:13:19	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
410	TMNG-202510-806	MENDIGORIN, ARJAY MOLINO	570	\N	2025-12-16 08:15:19	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
411	TMNG-202510-786	MENDIGORIN, ARNEL MOLINO	570	\N	2025-12-16 08:15:32	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
412	TMNG-202510-805	MENES, EDWARD MAYO	570	\N	2025-12-16 08:16:40	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
413	TMNG-202408-061	MENES, GUALBERTO RACRAQUIN	570	\N	2025-12-16 08:16:53	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
414	TMNG-202510-800	MENES, JAYSON MIANO	570	\N	2025-12-16 08:17:11	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
415	TMNG-202510-753	MENES, REX REYES	570	\N	2025-12-16 08:17:33	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
416	TMNG-202510-778	MENOR, DOMICIANO JR. MENES	570	\N	2025-12-16 08:17:41	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
417	TMNG-202509-561	MENOR, REY MEDUL	650	\N	2025-12-16 08:17:54	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
419	TMNG-202510-767	MEREMILLA, CLARK JOSEPH GANNABAN	570	\N	2025-12-16 08:19:27	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
420	TMNG-202510-801	MEREMILLA, ROLLY NACINO	570	\N	2025-12-16 08:19:43	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
421	TMNG-202510-788	MERTO, CARMEL BERNAL	570	\N	2025-12-16 08:21:17	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
422	TMNG-202510-781	MERTOLA, JOHN POHL MERCADO	570	\N	2025-12-16 08:21:51	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
423	TMNG-202509-667	MERU, RIC MORES	570	\N	2025-12-16 08:22:10	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
424	TMNG-202510-882	MERZA, DARWIN MAGLIQUIAN	570	\N	2025-12-16 08:22:29	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
425	TMNG-202510-790	MESIA, FREDDIE MANIAGO	570	\N	2025-12-16 08:24:04	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
426	TMNG-202510-785	MEVA, JON MARK COBARDO	570	\N	2025-12-16 08:24:42	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
428	TMNG-202509-594	MIANO, RUBEN JR. CUEVA	570	\N	2025-12-16 08:26:18	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
429	TMNG-202510-754	MIEL, ROMAN MANIAGO	570	\N	2025-12-16 08:26:29	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
430	TMNG-202510-796	MILA, CHRISTIAN MAYO	570	\N	2025-12-16 08:26:56	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
431	TMNG-202510-779	MILLAN, LAWRENCE BORBON	570	\N	2025-12-16 08:28:20	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
432	TMNG-202510-798	MODELO, EDGAR MARTICIO	570	\N	2025-12-16 08:32:19	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
433	TMNG-202509-634	MOJENO, CHRUZ MARDO	650	\N	2025-12-16 08:33:58	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
434	TMNG-202510-793	MOJENO, RODOLFO JR. MARDO	650	\N	2025-12-16 08:34:11	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
435	TMNG-202510-757	MONTERO, ALEX MEDIARIO	570	\N	2025-12-16 08:37:10	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
436	TMNG-202510-752	MONTERO, RANDY INTERNO	570	\N	2025-12-16 08:50:08	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
438	TMNG-202505-532	MORES, JOHNSON MERU	570	\N	2025-12-16 09:02:03	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
445	TMNG-202510-808	TAMAYO, LORENZO AGUSTIN	570	\N	\N	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
448	TMNG-202505-534	BENG-AD, REYNAN MANGLICMOT	1,187.50	\N	\N	MINE ENGINEERING	Ben A. Belwa	7-16	\N	\N	\N	\N	\N	Active	f
449	TMNG-202509-556	CABACCANG, RAEL MILLET	570	\N	\N	MINE ENGINEERING	Medardo F. Dangbis	7-16	\N	\N	\N	\N	\N	Active	f
450	TMNG-202409-120	INTERNO, JINNO ALBA	570	\N	\N	MINE ENGINEERING	Medardo F. Dangbis	7-16	\N	\N	\N	\N	\N	Active	f
451	TMNG-202310-033	LUCING, LAURENCE MANAPAT	570	\N	\N	MINE ENGINEERING	Medardo F. Dangbis	7-16	\N	\N	\N	\N	\N	Active	f
452	TMNG-202409-151	MONTALLA, MARVIN BERMUDEZ	570	\N	\N	MINE ENGINEERING	Medardo F. Dangbis	7-16	\N	\N	\N	\N	\N	Active	f
453	TMNG-202502-440	PISIGAN, NOEL ARGA	570	\N	\N	MINE ENGINEERING	Ben A. Belwa	7-16	\N	\N	\N	\N	\N	Active	f
454	TMNG-202502-439	PISIGAN, RALLY MILA	640	\N	\N	MINE ENGINEERING	Ben A. Belwa	7-16	\N	\N	\N	\N	\N	Active	f
455	TMNG-202502-441	PISIGAN, RICKY MILA	640	\N	\N	MINE ENGINEERING	Ben A. Belwa	7-16	\N	\N	\N	\N	\N	Active	f
456	TMNG-202507-551	SABIO, MAXIMINO JR. CANTILLANA	570	\N	\N	MINE ENGINEERING	Ben A. Belwa	7-16	\N	\N	\N	\N	\N	Active	f
457	TMNG-202510-887	VILLAFLORES, JOHN LUIS MOVILLA	570	\N	\N	MINE ENGINEERING	Medardo F. Dangbis	7-16	\N	\N	\N	\N	\N	Active	f
458	TMNG-202504-513	VILLEGAS, ROSELLER PEÑA	570	\N	\N	MINE ENGINEERING	Ben A. Belwa	7-16	\N	\N	\N	\N	\N	Active	f
459	TMNG-202208-068	ANDAL, MARK JOSEPH CATALBAS	570	\N	2025-12-15 13:37:55	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
460	TMNG-202208-069	BALILIN, JERRY CAJARO	570	\N	2025-12-15 13:50:46	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
461	TMNG-202208-070	CARIÑO, DANNY LUCERO	570	\N	2025-12-15 14:00:24	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
476	TMNG-202403-001	DELA CRUZ, DARWIN CASUPANAN	600	\N	2025-12-15 14:05:21	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
462	TMNG-202301-188	DELA CRUZ, JOVANNI CASUPANAN	600	\N	2025-12-15 14:05:29	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
477	TMNG-202403-002	EBEN, JEFREY BALILIN	600	\N	2025-12-15 14:08:06	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
464	TMNG-202503-486	ECALDRE, EDDIE NAVIDA	570	\N	2025-12-15 14:08:37	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
465	TMNG-202501-389	EDQUILA, ZERWIN MINIMO	570	\N	2025-12-15 14:09:28	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
478	TMNG-202403-003	LAGUISMA, VALENTINO VALLEJO	600	\N	2025-12-15 14:17:14	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
466	TMNG-202502-446	MADREO, BRANDO ECLEO	570	\N	2025-12-15 14:21:00	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
479	TMNG-202403-004	MANA, JERRY NEIL CLAVERIA	600	\N	2025-12-15 14:23:05	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
467	TMNG-202208-072	MARAVILLA, JUANCHO ALIMANGO	570	\N	2025-12-15 14:29:41	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
468	TMNG-202211-006	MAS, JHONATAN LAQUINDANUM	570	\N	2025-12-15 14:30:40	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
473	TMNG-202301-004	NILO, JERIC MINIMO	570	\N	2025-12-15 14:31:21	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
469	TMNG-202411-213	MAYO, RANDOLF MAYPAY	570	\N	2025-12-16 08:04:49	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
470	TMNG-202410-116	MERCED, SALLY MALAY	600	\N	2025-12-16 08:19:03	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
471	TMNG-202502-447	MIRAFLOR, EDMUND MENES	570	\N	2025-12-16 08:30:39	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
472	TMNG-202510-909	MOLINO, MARTIN JR. MARCOS	570	\N	2025-12-16 08:34:43	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
439	TMNG-202510-756	MOSE, DENNY MERINDO	570	\N	2025-12-16 09:03:39	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
440	TMNG-202510-761	MOSE, JEROME MAYO	570	\N	2025-12-16 09:04:16	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
481	TMNG-202403-005	MOSE, OLIVER MESIA	600	\N	2025-12-16 09:31:16	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
441	TMNG-202510-916	MOVILLA, RICSON MARAVE	570	\N	2025-12-16 09:33:27	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
482	TMNG-202403-006	MUYANO, EFREN YBAÑEZ	600	\N	2025-12-16 09:34:45	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
484	TMNG-202403-008	MUYANO, REY ANGELO MEROY	600	\N	2025-12-16 09:35:12	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
442	TMNG-202510-766	QUINACMAN, GERALD MAYO	570	\N	2025-12-16 09:45:59	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
443	TMNG-202509-605	RAMOS, DAVE MINIMO	570	\N	2025-12-16 09:47:51	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
474	TMNG-202502-448	SAGUIN, EDILBERT JOAQUIN	570	\N	2025-12-16 09:49:05	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
444	TMNG-202510-797	SALDON, KRIS JAN MEVA	570	\N	2025-12-19 08:15:48	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
446	TMNG-202510-928	TAOC, JOYCE ANN MARTINEZ	570	\N	2025-12-19 08:23:28	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
447	TMNG-202509-598	VILLANUEVA, RAYMOND MILA	570	\N	2025-12-19 08:28:05	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
501	TMNG-202312-001	DELA CRUZ, RANDY FERNANDEZ	600	\N	\N	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	6-15	\N	\N	\N	\N	\N	Active	f
505	TMNG-202410-043	MERCURIO, HAIDEE VALLEJOS	570	\N	\N	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	6-15	\N	\N	\N	\N	\N	Active	f
506	TMNG-202409-142	MILLAN, JOMAR MISA	650	\N	\N	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	6-15	\N	\N	\N	\N	\N	Active	f
507	TMNG-202302-201	MINIMO, JONAS MASPAT	600	\N	\N	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	6-15	\N	\N	\N	\N	\N	Active	f
508	TMNG-202511-1029	ALGABA, PETER JHON MOVILLA	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
509	TMNG-202510-838	BAGORIO, JIMBOY MODELO	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
510	TMNG-202510-982	BALANGUE, GREGORIO LARON	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
511	TMNG-202510-842	BANTOLINO, REYAN CATALBAS	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
512	TMNG-202510-833	BORLAZA, SILVER MOVILLA	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
513	TMNG-202510-1009	CARLON, JONATHAN VALELIN	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
514	TMNG-202510-984	DEGAMON, MARTINO ABORDO	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
515	TMNG-202510-967	DELA PEÑA, JONARY MELU	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
516	TMNG-202510-836	DEONILA, SOLOMON MANAOIS	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
517	TMNG-202510-871	FERNANDEZ, ERNESTO VILLANUEVA	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
518	TMNG-202510-872	GALANG, ERIC TAMAYO	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
519	TMNG-202510-1006	HUECAS, ALFREDO JR. MINAS	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
520	TMNG-202510-966	MANIAGO, CARLO MENOR	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
521	TMNG-202510-969	MANTES, ROMMEL PAGADUAN	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
522	TMNG-202510-976	MAPA, WILLIAM DELA CRUZ	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
523	TMNG-202510-1015	MARAVE, JOEY APSI	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
524	TMNG-202510-1020	MARDO, JUVY MODELO	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
525	TMNG-202510-1021	MARDO, RHEA MAE BUSNILA	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
526	TMNG-202510-692	MAS, JAYSON PELAGIO	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
527	TMNG-202510-1007	MEDEL, RONEL SALVADOR	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
528	TMNG-202510-974	MEDIDA, RIGOR YAON	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
529	TMNG-202510-1017	MENDIGORIN, RONIE RACZA	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
530	TMNG-202510-835	MERTO, JUNSTER ALFEROS	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
531	TMNG-202510-977	MIBA, ROGIN MARTICIO	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
532	TMNG-202510-978	MIBA, RYAN MARTICIO	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
533	TMNG-202510-970	MINOLA, MARVIN TORALDE	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
534	TMNG-202510-965	MINOLA, WILFRED TORALDE	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
535	TMNG-202510-839	MINOLA, WILLIAM TURALDE	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
536	TMNG-202510-971	MIRADOR, PATRICK MAS	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
537	TMNG-202504-506	MIZAL, JOHN CHRISTOPHER	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
538	TMNG-202510-975	MORETE, VICTORIO MANILA	900	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
539	TMNG-202510-1019	SOLANOY, MERRY JOY MENDOZA	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
540	TMNG-202510-1018	TESORO, MECHELLE MOVILLA	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
541	TMNG-202510-1026	ANGALA, ALMIRA MILLAN	570	\N	\N	FUEL MANAGEMENT	Albert M. Miva	7-16	\N	\N	\N	\N	\N	Active	f
542	TMNG-202510-1025	TABUCOL, RONALD MARAVE	650	\N	\N	FUEL MANAGEMENT	Albert M. Miva	6-15	\N	\N	\N	\N	\N	Active	f
543	TMNG-202510-992	MOSE, MARC OWEN MEDIDA	570	\N	\N	HR SERVICES	Deo F. Sienes	6-15	\N	\N	\N	\N	\N	Active	f
544	TMNG-202510-1004	ALFARO, EDWIN CAWALING	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
545	TMNG-202510-1005	ESPINOSA, REX MATREO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
546	TMNG-202510-1014	MANALO, JESUS MODELO	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
547	TMNG-202510-1010	MERA, ALVIN CORTEZ	570	\N	\N	LABORATORY	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
500	TMNG-202208-235	CATALBAS, MARICRIS MOVILLA	570	\N	2025-12-15 14:30:13	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
503	TMNG-202212-032	MANUEL, CHRISTIAN EGMAO	570	\N	2025-12-15 14:31:08	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
550	TMNG-202510-1011	DELOS REYES, JOHN MIKE NAVARRO	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
551	TMNG-202510-1013	MANCILLA, RICHARD SORIANO	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
552	TMNG-202510-985	MINIMO, LODWIN MENORCA	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
553	TMNG-202510-986	MONSALUD, RICKY BARLAAN	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
554	TMNG-202510-962	MORALEJO, JESSIE QUIMERISTA	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
555	TMNG-202510-983	MUYANO, MELANIE QUISISIM	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
556	TMNG-202510-964	MUYANO, ROLAN MUEGA	570	\N	\N	FLEET OPERATIONS	Eugene Jay C. Tacardon	6-15	\N	\N	\N	\N	\N	Active	f
557	TMNG-202503-474	ADAN, LOWIE MENEJE	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
558	TMNG-202301-088	ANTALAN, IVAN KRISTOFFER ARISPE	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
559	TMNG-202301-044	ARCELAO, AMALIA MANILA	650	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
560	TMNG-202409-107	ARCELAO, BREYNALD DELA CRUZ	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
561	TMNG-202301-054	ARCELAO, JOSEPH DELA CRUZ	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
562	TMNG-202409-108	ARCELAO, KEYSEE MANILA	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
563	TMNG-202502-433	ATENCIO, NIÑO ALLEN VALENTINO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
564	TMNG-202310-008	AZOR, LEO MAYO	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
565	TMNG-202410-075	BALELIN, KYLA MAE CAJARO	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
567	TMNG-202510-997	BALILIN, CEDRIC JAMES CLETE	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
568	TMNG-202301-006	BALILIN, DARLYN CLETE	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
569	TMNG-202301-025	BALILIN, ELIZABETH DACANAY	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
570	TMNG-202301-052	BERNAL, MICHELLE MINIMO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
571	TMNG-202510-998	BUENO, EJAY BALILIN	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
572	TMNG-202405-012	BUENO, JHOBET BALILIN	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
573	TMNG-202510-988	BUTCON, ROSEMARIE MORTIL	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
574	TMNG-202301-198	CABREROS, LORENA CORRAL	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
575	TMNG-202502-434	CALARA, JONIELE ESTEVA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
576	TMNG-202302-016	DAGOHOY, FELINO MAPILI	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
577	TMNG-202505-525	DELOS REYES, ROLY ARIETA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
578	TMNG-202301-047	DELOS SANTOS, KIM DELA CRUZ	650	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
579	TMNG-202301-092	DIAZ, JEOFFREY ARGA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
580	TMNG-202411-240	DIMABUYU, RYAN PAMINTUAN	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
581	TMNG-202301-017	EBUEN, MERLIE ANN ANGELES	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
582	TMNG-202405-011	ECALDRE, JESSE	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
583	TMNG-202510-1003	ECLARINAL, WINSTON FERNANDEZ	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
584	TMNG-202411-245	EDANGALINO, JOHN DENVER DELA CRUZ	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
586	TMNG-202502-421	ELAOG, DAN MARK COPE	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
587	TMNG-202301-126	ELEFANE, JAYRICK VALENTINO	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
588	TMNG-202410-069	ENCINA, RON HAMLEY YVES ISLAND HERMOSO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
589	TMNG-202302-192	ESPERA, ROLDAN SARAJINA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
590	TMNG-202503-454	FABROS, REYNALDO SAWIT	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
591	TMNG-202302-011	LAYA, RAYSTAR SAN ROQUE	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
592	TMNG-202301-051	LAZARO, MARIA NENITA VALENTINO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
593	TMNG-202411-295	MALIWAT, MARK ROGIE MON	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
594	TMNG-202506-542	MAÑALAC, MICHAEL SINGCA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
595	TMNG-202301-154	MANILA, JOVELYN FAJARDO	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
596	TMNG-202510-996	MARAVE, MARK ANTHONY MORALES	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
597	TMNG-202411-290	MARTY, CARLO JAY MISA	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
598	TMNG-202410-074	MARTY, JESSIE QUISISIM	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
599	TMNG-202301-183	MAS, JUSTIN DE GUZMAN	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
600	TMNG-202301-074	MAYO, CRISPIN MENDI	650	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
601	TMNG-202310-111	MENDOZA, DENNIS MONSALVE	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
602	TMNG-202502-432	MENORCA, JHON PATRICK NAVARRO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
604	TMNG-202510-990	MEROY, CYRUS MERTO	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
605	TMNG-202301-076	MEROY, JOSIE ACOSTA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
606	TMNG-202501-377	MILITAR, JEO MARK VALENTINO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
603	TMNG-202212-014	MERIN, RONALDO MINAS	570	\N	2025-12-15 14:30:54	VESSEL LOADING	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
566	TMNG-202301-005	BALELIN, MRYNA ECALDRE	570	\N	2025-12-15 14:31:35	VESSEL LOADING	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
607	TMNG-202410-172	MINIMO, RAFFY	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
608	TMNG-202502-423	MOJECA, BENNY EDILLOR	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
609	TMNG-202302-005	MOJECA, CLARISSA MUEGA	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
610	TMNG-202406-017	MOJECA, LAURENCE MORTIL	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
611	TMNG-202502-430	MOLINO, ARVIN BATALUNA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
612	TMNG-202501-404	MOLINO, LEONARD ROBLES	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
613	TMNG-202410-173	MON, JULITO OPOLINTO	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
614	TMNG-202301-075	MONSALVE, CRISTINA FERNANDEZ	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
615	TMNG-202409-152	MONTALLA, ROMMEL CASTAÑAREZ	650	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
616	TMNG-202510-994	MONTEHERMOZO, JOHNREY VALDEZ	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
617	TMNG-202501-412	MORANO, RICKY MENDIGORIN	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
618	TMNG-202301-178	MORILLO, DANIEL MARTINEZ	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
619	TMNG-202503-451	MUEGA, JOVENEL MISA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
620	TMNG-202501-385	MUYANO, PEJAY BALELIN	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
621	TMNG-202409-160	NILO, JORDAN MINIMO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
622	TMNG-202503-458	POLICARPIO, FRANKLIN MANTES	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
623	TMNG-202510-987	PULIDO, NELVIN ABAY	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
624	TMNG-202412-330	QUIÑONEZ, JAY-AR MAPA	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
625	TMNG-202310-115	RAFANAN, DENNIS DIAZ	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
626	TMNG-202510-1016	RAMOS, JOVITH MONATO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
627	TMNG-202409-173	TALINIO, ELMARK MANTES	650	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
628	TMNG-202501-395	VALENTINO, DEXTER DE CASTRO	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
629	TMNG-202501-376	VIADO, JHON REY CASTAÑES	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
630	TMNG-202301-032	VICENTE, RICKY PASARITA	570	\N	\N	VESSEL LOADING	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
631	TMNG-202510-993	ZUÑIGA, JOE VALENTINO	570	\N	\N	VESSEL LOADING	Gabriel V. Feria	6-15	\N	\N	\N	\N	\N	Active	f
682	SC-2025001-001	MILLAN, MAC RENTON	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
683	SC-2025001-002	MILLAN, KRISTIAN	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
684	SC-2025001-003	VALDEZ, REY	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
685	SC-2025001-004	MIRADOR, JOVER	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
686	SC-2025001-005	CANLAS, TRISTAN	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
687	SC-2025001-006	MARTICIO, CRIS	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
688	SC-2025001-007	MERCADO, JAYSON	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
689	SC-2025001-008	CAMPOS, NERIC	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
690	SC-2025001-009	LIM, ALFREDO	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
691	SC-2025001-010	ANGELES, JULIUS	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
692	SC-2025001-011	MADREO, ARNOLD	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
693	SC-2025001-012	BANTILING, REMAR	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
694	SC-2025001-013	MANIAGO, MELQUIADES	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	f
695	SC-2025001-014	RIVERA, JHONNY	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
696	SC-2025001-015	MIRADOR, LEXTER	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
697	SC-2025001-016	MAYO JR., SALVADOR	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
698	SC-2025001-017	MAYA, JOHN KENNETH	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
699	SC-2025001-018	ESPEDIDO, RONNIE	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
700	SC-2025001-019	PALAZO, RANDOLF	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
701	SC-2025001-020	MAYO, GILDO	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
702	SC-2025001-021	PAGLINGAYEN, MICHAEL	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
703	SC-2025001-022	MEJIA, JERALD	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
704	SC-2025001-023	MONTERO, RUGIE	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
705	SC-2025001-024	DELA PENA, ERNIE	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
706	SC-2025001-025	MAZO, ELISEO	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
707	SC-2025001-026	COLLADO, HENRY	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
708	SC-2025001-027	DERICTO, DEXTER	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
709	SC-2025001-028	MILANIO, ARLAN	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
710	SC-2025001-029	DAZO, ANTONIO	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
711	SC-2025001-030	MARZAN, JENNY	500	\N	\N	SECURITY	RDC	19-7	\N	\N	\N	\N	\N	Active	f
712	SC-2025001-031	TAOC, JAYRICK	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
713	SC-2025001-032	MORALES, BRYAN	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
714	SC-2025001-033	RAYMOND GELIDO,	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
715	SC-2025001-034	MONTEHERMOZO, IAN	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
716	SC-2025001-035	MARAVE, JOHNRIC	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
717	SC-2025001-036	MARTEJA, LEEMARC LEONEL	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
719	SC-2025001-038	GELIDO, VRIGILIO	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
720	SC-2025001-039	GELIDO, RAYMOND	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
725	SC-2025001-044	GELIDO, VIRGILIO	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
726	SC-2025001-045	MARAVE, JHON RIC	500	\N	\N	SECURITY	RDC	7-19	\N	\N	\N	\N	\N	Active	t
585	TMNG-202201-001	EDNALAN, ALVIN MERCADO	570	\N	2025-12-15 14:28:59	VESSEL LOADING	Gabriel V. Feria	7-16	\N	\N	\N	\N	\N	Active	f
502	TMNG-202208-234	MANALO, JOEM PANELO	600	\N	2025-12-15 14:29:57	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
504	TMNG-202208-236	MERCED, MARICEL MONTEJO	570	\N	2025-12-15 14:30:27	ADMINISTRATIVE SERVICES	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
93	TMNG-202510-770	ABARDO, ROGER AREVALO	900	\N	2025-12-15 11:53:45	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
8	TMNG-202410-023	ABELLA, CHRISTIAN JAY VALENCIA	570	\N	2025-12-15 11:54:13	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
353	TMNG-202510-791	AGAYAN, ADRIAN TAMONDONG	570	\N	2025-12-15 13:32:30	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
475	TMNG-202409-104	ANCHETA, FERNANDO MERU	600	\N	2025-12-15 13:36:59	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
357	TMNG-202510-780	ANCHETA, ISAGANIE MANTOLINO	570	\N	2025-12-15 13:37:15	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
101	TMNG-202510-672	ANGELES, RENGEL MARA	570	\N	2025-12-15 13:45:06	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
10	TMNG-202410-090	BALDAS, GRAIL AGLANO	1000	\N	2025-12-15 13:49:27	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
110	TMNG-202510-682	BANAG, RONNIE JR. OCLIMA	900	\N	2025-12-15 13:52:08	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
113	TMNG-202509-615	BAYAO, JOZLE ANNE MARIZ TAOC	570	\N	2025-12-15 13:53:43	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
317	TMNG-202510-880	BUSTAMANTE, VINCENT AGAM	570	\N	2025-12-15 13:58:06	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
122	TMNG-202509-628	CARDAÑO, WILFREDO JR. PARINAS	900	\N	2025-12-15 14:00:08	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
368	TMNG-202510-782	CASILDO, WENNY CORDOVA	570	\N	2025-12-15 14:00:44	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
19	TMNG-202410-028	DE GUZMAN, MARK JOHN NEBRIDA	773	\N	2025-12-15 14:03:22	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
275	TMNG-202510-815	DELOS SANTOS, LORENZ ALOTA	570	\N	2025-12-15 14:05:52	FUEL MANAGEMENT	Albert M. Miva	7-16	\N	\N	\N	\N	\N	Active	f
463	TMNG-202208-071	DY, ALLAN ERIC REYES	570	\N	2025-12-15 14:07:22	OCCUPATIONAL HEALTH AND SAFETY	Brian Nicole M. Bal	7-16	\N	\N	\N	\N	\N	Active	f
321	TMNG-202509-562	EBANA, ROY ANGELO PULIDO	650	\N	2025-12-15 14:07:39	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
132	TMNG-202510-903	EBBA, ROMEO REYES	900	\N	2025-12-15 14:07:53	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
141	TMNG-202510-774	GELIDO, CHRISTIAN VERGEL MAURICIO	570	\N	2025-12-15 14:13:50	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
151	TMNG-202510-980	LLUSALA, NORIEL MINIMO	900	\N	2025-12-15 14:20:10	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
379	TMNG-202510-816	MACAM, ALEX JR. BALLARTA	570	\N	2025-12-15 14:20:37	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
161	TMNG-202509-580	MARAVE, GERI MARAVE	900	\N	2025-12-15 14:26:08	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
167	TMNG-202509-612	MARAVE, ROBELITO MELU	570	\N	2025-12-15 14:32:03	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
389	TMNG-202510-914	MARDO, JILBERT MOVILLA	570	\N	2025-12-15 14:33:05	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
169	TMNG-202510-820	MARDO, REMALYN BOSNILA	570	\N	2025-12-15 14:33:24	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
330	TMNG-202507-548	MARIANO, JOHN PAUL PONS	570	\N	2025-12-15 14:34:28	MEPED	Maricris D. Malannag	7-16	\N	\N	\N	\N	\N	Active	f
392	TMNG-202509-597	MARPA, JEREMY	570	\N	2025-12-15 14:34:54	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
394	TMNG-202510-784	MARTICIO, ANASTACIO JR. REYES	570	\N	2025-12-15 14:35:59	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
30	TMNG-202505-524	MARTICIO, APOLLO MOVILLA	570	\N	2025-12-15 14:36:35	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
480	TMNG-202410-058	MARTINEZ, ODEMAR MIRADOR	600	\N	2025-12-15 14:39:00	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
178	TMNG-202510-728	MAS, CEDRICK JOHN LAQUINDANUM	900	\N	2025-12-16 07:58:46	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
188	TMNG-202510-926	MAYO, GERALD MONTEVIRGEN	900	\N	2025-12-16 08:03:39	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
405	TMNG-202510-951	MEBA, JOHN SHERWIN LAGASCA	570	\N	2025-12-16 08:07:58	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
198	TMNG-202510-931	MEJIA, ROMNICK MERINDO	900	\N	2025-12-16 08:11:29	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
41	TMNG-202412-310	MELU, JOHN PHILIP MOSE	570	\N	2025-12-16 08:13:05	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
418	TMNG-202510-912	MERADIOS, JOHN PULL	570	\N	2025-12-16 08:18:07	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
209	TMNG-202510-735	MERINDO, RONNIE MOSE	900	\N	2025-12-16 08:20:51	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
427	TMNG-202509-558	MIANO, JUNIOR PACALTAO	570	\N	2025-12-16 08:25:08	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
218	TMNG-202510-825	MIANO, RICHARD MAYO	900	\N	2025-12-16 08:26:07	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
51	TMNG-202410-085	MODELO, JAY RACRAQUIN	570	\N	2025-12-16 08:32:46	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
225	TMNG-202510-837	MOJECA, ARCHIE BUENSUCESO	900	\N	2025-12-16 08:33:36	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
55	TMNG-202410-014	MONTERO, AURELIO JR. MODELO	650	\N	2025-12-16 08:37:50	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
437	TMNG-202510-777	MONTEVIRGEN, DIONYLIE MEDIARIO	570	\N	2025-12-16 09:01:29	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	Quen Russel S. Bautista	7-16	\N	\N	\N	\N	\N	Active	f
236	TMNG-202510-891	MORES, NIXON	570	\N	2025-12-16 09:02:57	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
245	TMNG-202510-817	MOVILLA, MICHAEL MARTEJA	900	\N	2025-12-16 09:32:50	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
483	TMNG-202403-007	MUYANO, NELVIN YBAÑEZ	600	\N	2025-12-16 09:35:04	OFFICE OF THE RESIDENT MANAGER	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
255	TMNG-202510-771	PARINAS, ENRILE ANCHETA	900	\N	2025-12-16 09:37:05	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
64	TMNG-202410-106	PEÑARANDA, MAURICIO MONTERO	650	\N	2025-12-16 09:41:49	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
264	TMNG-202510-843	RIVAMONTE, ROBERT JAY MESIA	900	\N	2025-12-16 09:48:17	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
75	TMNG-202410-022	VALENCIA, DEXTER BONA	570	\N	2025-12-19 08:25:51	EXPLORATION AND MINE GEOLOGY	Arianne D. Destura	7-16	\N	\N	\N	\N	\N	Active	f
273	TMNG-202510-717	VILLARUZ, RONNIE BIBAL	580	\N	2025-12-19 08:28:37	FLEET OPERATIONS	Eugene Jay C. Tacardon	7-16	\N	\N	\N	\N	\N	Active	f
286	TMNG-202509-629	BALONCIO, KATRINA MEDALLA	650	\N	\N	LABORATORY	Gabriel V. Feria	20-5	\N	\N	\N	\N	\N	Active	f
548	TMNG-202510-1027	NACIONAL, JONATHAN LEGASPI	570	\N	\N	PURCHASING	Anthony D. Macalalag	7-16	\N	\N	\N	\N	\N	Active	f
485	TMNG-202510-874	ACIERTO, JANARY QUIROY	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
486	TMNG-202510-857	BALANAY, ROMEO BINONDO	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
487	TMNG-202510-852	BALILIN, JENSEN AMORES	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
488	TMNG-202510-860	BERNAL, DARWIN MENEJE	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
489	TMNG-202510-875	BESAÑEZ, LOUIGI	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
490	TMNG-202510-859	DIAZ, LOUIE ANGELO EBUE	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
491	TMNG-202510-861	MAGNO, JED ADRIAN EDILLOR	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
492	TMNG-202510-866	MARTY, IAN MAGRATA	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
493	TMNG-202510-869	MINIMO, MARCELO MANALO	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
494	TMNG-202510-911	MONSALUD, CHRISTOPHER MEREDOR	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
495	TMNG-202510-856	PECSALEM, GUILLERMO MANILA	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
496	TMNG-202510-850	QUIMERISTA, JESSEL MOLINO	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
497	TMNG-202510-865	TUMAMAO, FREDDIE MONTERO	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
498	TMNG-202510-884	VALENTINO, EDILBERTO MERINO	650	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
499	TMNG-202510-858	VALENTINO, ROMNICK MERZA	570	\N	\N	SHIPMENT OPERATIONS	Quen Russel S. Bautista	6-15	\N	\N	\N	\N	\N	Active	f
549	TMNG-202510-1028	EBANA, ROSALINO EBANCULLA	600	\N	\N	WAREHOUSE LOGISTICS	Anthony D. Macalalag	6-15	\N	\N	\N	\N	\N	Active	f
729	1001	Len, Yuson	500	2026-08-27 13:27:55	2026-09-16 15:33:35	ADMINISTRATIVE SERVICES	John Go	8-17	\N	\N	\N	\N	\N	Active	f
732	12	Crescian Lloyd, Lanoy	23232	2026-08-27 13:52:35	2026-08-27 13:52:35	MEPED	Sete	6-15	\N	\N	\N	\N	\N	Active	f
733	777777	Marylen, Trinidad	800	2026-08-27 16:50:10	2026-09-16 15:33:13	COMMUNITY RELATIONS STAFF	Charleane Cudal	8-17	\N	\N	\N	\N	\N	Active	f
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: leaves; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leaves (id, employee_management_id, status, record_date, leave_type, reason, with_pay, biometric_imports_id, created_at, updated_at, weekday, others, attendance_records_id) FROM stdin;
1	93	pending	2025-11-13 00:00:00	\N	\N	f	\N	2025-11-28 13:42:16	2025-11-28 13:42:16	\N	\N	\N
\.


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
15	2026_09_29_000003_unique_attendance_record_per_employee_day	9
16	2026_09_29_000004_clean_up_departments_and_duplicate_employees	10
\.


--
-- Data for Name: overtimes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.overtimes (id, unique_id, first_name, last_name, employee_name, earliest_time, latest_time, type, department, attendance_area, serial_number, schedule, ord_ot, ord_nd, ord_nd_ot, rd, rd_ot, rd_nd, rd_nd_ot, total_non_working_days_present, late, late_hours, late_minutes, out_time_required, record_date, status, created_at, updated_at, original_earliest_time, original_latest_time, biometric_imports_id, schedule_shift, attendance_records_id, employee_management_id) FROM stdin;
27871	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	06:58:43	17:53:25	ord	PURCHASING	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66001	548
27872	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	06:58:00	17:51:46	ord	PURCHASING	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66002	548
27873	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	06:58:17	17:49:35	ord	PURCHASING	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66003	548
27874	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	07:00:21	17:49:00	ord	PURCHASING	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66004	548
27875	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	07:02:46	17:51:36	ord	PURCHASING	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66005	548
27876	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	07:01:25	17:50:14	ord	PURCHASING	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66006	548
27877	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	07:00:34	17:50:12	ord	PURCHASING	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66007	548
27878	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	07:01:50	17:50:51	ord	PURCHASING	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66008	548
27879	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	07:00:07	19:08:48	ord	PURCHASING	LAMI Mining Site	\N	7-16	03:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66009	548
27880	TMNG-202510-1027	 JONATHAN LEGASPI	NACIONAL	NACIONAL, JONATHAN LEGASPI	17:51:24	20:57:47	ord	PURCHASING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66010	548
27893	TMNG-202510-884	 EDILBERTO MERINO	VALENTINO	VALENTINO, EDILBERTO MERINO	07:06:59	16:01:11	ord	SHIPMENT OPERATIONS	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66023	498
27894	TMNG-202510-884	 EDILBERTO MERINO	VALENTINO	VALENTINO, EDILBERTO MERINO	06:41:26	16:02:29	ord	SHIPMENT OPERATIONS	LAMI Mining Site	\N	6-15	00:21	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66024	498
27895	TMNG-202510-884	 EDILBERTO MERINO	VALENTINO	VALENTINO, EDILBERTO MERINO	06:55:06	16:02:06	ord	SHIPMENT OPERATIONS	LAMI Mining Site	\N	6-15	00:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66025	498
27896	TMNG-202510-884	 EDILBERTO MERINO	VALENTINO	VALENTINO, EDILBERTO MERINO	06:54:23	18:00:12	ord	SHIPMENT OPERATIONS	LAMI Mining Site	\N	6-15	02:06	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66026	498
27897	TMNG-202510-884	 EDILBERTO MERINO	VALENTINO	VALENTINO, EDILBERTO MERINO	06:47:29	18:01:07	ord	SHIPMENT OPERATIONS	LAMI Mining Site	\N	6-15	02:14	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66027	498
27898	TMNG-202510-884	 EDILBERTO MERINO	VALENTINO	VALENTINO, EDILBERTO MERINO	06:57:13	18:02:08	ord	SHIPMENT OPERATIONS	LAMI Mining Site	\N	6-15	02:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66028	498
27881	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	06:00:49	18:26:56	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	03:26	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66011	549
27882	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	05:56:08	18:09:53	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	03:14	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66012	549
27883	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	05:58:58	18:19:20	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	03:20	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66013	549
27884	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	06:25:44	18:18:22	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	02:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66014	549
27885	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	06:25:35	16:22:23	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	00:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66015	549
27886	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	06:19:50	18:01:16	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	02:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66016	549
27887	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	02:03:05	22:07:06	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	11:04	00:00	00:00	00:00	00:00	04:04	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66017	549
27888	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	06:49:25	17:58:08	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	02:09	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66018	549
27889	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	05:56:40	18:34:36	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	03:38	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66019	549
27890	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	03:55:20	20:24:34	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	07:29	00:00	00:00	00:00	00:00	02:05	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66020	549
27891	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	06:20:56	18:00:39	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	02:40	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66021	549
27892	TMNG-202510-1028	 ROSALINO EBANCULLA	EBANA	EBANA, ROSALINO EBANCULLA	06:53:44	20:47:37	ord	WAREHOUSE LOGISTICS	LAMI Mining Site	\N	6-15	04:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66022	549
27645	TMNG-202403-004	 JERRY NEIL CLAVERIA	MANA	MANA, JERRY NEIL CLAVERIA	05:46:29	19:00:10	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:14	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65775	479
28079	TMNG-202412-338	 NIÑO COSME TUGA	NAVARRO	NAVARRO, NIÑO COSME TUGA	07:07:07	18:06:10	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66209	7
28080	TMNG-202412-338	 NIÑO COSME TUGA	NAVARRO	NAVARRO, NIÑO COSME TUGA	06:57:57	18:06:06	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66210	7
28081	TMNG-202509-571	 JOEMAR MONJE	URBANO	URBANO, JOEMAR MONJE	07:07:40	17:50:10	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66211	268
28082	TMNG-202509-571	 JOEMAR MONJE	URBANO	URBANO, JOEMAR MONJE	07:09:19	17:50:59	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66212	268
28083	TMNG-202509-587	 WARREN MOVILLA	MERZA	MERZA, WARREN MOVILLA	06:56:59	17:50:04	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66213	216
28084	TMNG-202509-587	 WARREN MOVILLA	MERZA	MERZA, WARREN MOVILLA	06:50:43	17:49:07	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66214	216
27668	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	06:56:19	15:48:12	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Approved	2026-09-22 15:04:44	2026-09-22 15:35:39	\N	\N	14	\N	65798	69
28087	TMNG-202510-770	ROGER AREVALO	ABARDO	ABARDO, ROGER AREVALO	08:25:00	16:25:00	ord	FLEET OPERATIONS	\N	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-26 00:00:00	Pending	2026-09-28 13:25:49	2026-09-28 13:25:49	\N	\N	14	\N	66235	93
25593	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	06:00:59	16:54:08	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Approved	2026-09-09 11:21:59	2026-09-16 15:39:35	\N	\N	12	\N	63723	69
27045	TMNG-202510-779	 LAWRENCE BORBON	MILLAN	MILLAN, LAWRENCE BORBON	06:57:23	17:51:59	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65175	431
27046	TMNG-202510-779	 LAWRENCE BORBON	MILLAN	MILLAN, LAWRENCE BORBON	07:01:42	17:52:21	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65176	431
27047	TMNG-202510-779	 LAWRENCE BORBON	MILLAN	MILLAN, LAWRENCE BORBON	07:53:28	19:49:39	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	02:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65177	431
27048	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	11:24:00	19:51:38	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65178	542
27049	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	11:13:47	19:50:19	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65179	542
27050	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	10:56:21	20:15:21	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:19	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65180	542
27051	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	12:12:06	19:50:35	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65181	542
27052	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	14:31:27	19:50:21	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65182	542
27053	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	12:10:47	19:50:12	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65183	542
27054	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	10:46:47	19:00:10	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65184	542
27055	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	11:36:00	19:50:05	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65185	542
27056	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	10:27:08	19:00:27	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65186	542
27057	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	11:18:32	19:50:08	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65187	542
27058	TMNG-202510-1025	 RONALD MARAVE	TABUCOL	TABUCOL, RONALD MARAVE	07:19:59	19:23:44	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	6-15	03:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65188	542
27059	TMNG-202208-068	 MARK JOSEPH CATALBAS	ANDAL	ANDAL, MARK JOSEPH CATALBAS	06:52:50	18:00:53	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65189	459
27060	TMNG-202208-068	 MARK JOSEPH CATALBAS	ANDAL	ANDAL, MARK JOSEPH CATALBAS	07:12:42	18:05:19	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65190	459
27061	TMNG-202208-068	 MARK JOSEPH CATALBAS	ANDAL	ANDAL, MARK JOSEPH CATALBAS	07:06:25	18:00:27	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65191	459
27062	TMNG-202208-068	 MARK JOSEPH CATALBAS	ANDAL	ANDAL, MARK JOSEPH CATALBAS	07:11:35	18:00:15	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65192	459
27063	TMNG-202208-068	 MARK JOSEPH CATALBAS	ANDAL	ANDAL, MARK JOSEPH CATALBAS	07:01:47	16:00:09	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65193	459
27064	TMNG-202208-068	 MARK JOSEPH CATALBAS	ANDAL	ANDAL, MARK JOSEPH CATALBAS	07:08:35	16:03:41	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65194	459
27065	TMNG-202208-068	 MARK JOSEPH CATALBAS	ANDAL	ANDAL, MARK JOSEPH CATALBAS	07:12:35	16:05:03	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65195	459
27066	TMNG-202208-068	 MARK JOSEPH CATALBAS	ANDAL	ANDAL, MARK JOSEPH CATALBAS	07:07:45	16:04:46	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65196	459
27067	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	07:06:34	17:51:04	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65197	130
27068	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	06:54:29	17:51:14	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65198	130
27069	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	06:52:27	17:49:03	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65199	130
27070	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	07:05:29	17:50:02	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65200	130
27071	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	07:19:06	17:50:38	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:32	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65201	130
27072	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	07:05:14	17:51:44	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65202	130
27073	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	07:04:37	17:50:38	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65203	130
27074	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	06:56:36	17:50:14	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65204	130
27075	TMNG-202509-567	 MARCELO AQUINO	DIZON	DIZON, MARCELO AQUINO	07:01:51	19:00:13	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65205	130
27076	TMNG-202503-453	 VERNIE MILLAN	SOLIS	SOLIS, VERNIE MILLAN	06:59:27	17:31:22	ord	MEPED	LAMI Mining Site	\N	7-16	01:32	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65206	348
27077	TMNG-202503-453	 VERNIE MILLAN	SOLIS	SOLIS, VERNIE MILLAN	06:58:57	18:00:49	ord	MEPED	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65207	348
27078	TMNG-202503-453	 VERNIE MILLAN	SOLIS	SOLIS, VERNIE MILLAN	07:19:15	17:48:50	ord	MEPED	LAMI Mining Site	\N	7-16	01:29	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65208	348
27079	TMNG-202503-453	 VERNIE MILLAN	SOLIS	SOLIS, VERNIE MILLAN	07:23:11	15:55:30	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65209	348
27080	TMNG-202503-453	 VERNIE MILLAN	SOLIS	SOLIS, VERNIE MILLAN	07:04:23	17:52:58	ord	MEPED	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65210	348
27081	TMNG-202503-453	 VERNIE MILLAN	SOLIS	SOLIS, VERNIE MILLAN	07:07:03	17:55:15	ord	MEPED	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65211	348
27082	TMNG-202503-453	 VERNIE MILLAN	SOLIS	SOLIS, VERNIE MILLAN	07:11:06	17:33:23	ord	MEPED	LAMI Mining Site	\N	7-16	01:22	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65212	348
27083	TMNG-202503-453	 VERNIE MILLAN	SOLIS	SOLIS, VERNIE MILLAN	07:05:42	19:01:43	ord	MEPED	LAMI Mining Site	\N	7-16	02:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65213	348
27084	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	06:06:24	18:21:16	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	03:15	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65214	454
27085	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	06:02:55	18:46:13	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	03:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65215	454
27086	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	06:07:45	16:43:10	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:35	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65216	454
27087	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	06:07:16	18:56:02	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	03:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65217	454
27088	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	07:15:31	18:54:13	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	02:39	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65218	454
27089	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	07:01:15	18:00:09	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65219	454
27090	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	07:06:13	18:00:42	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65220	454
27091	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	06:47:44	16:00:13	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:13	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-21 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65221	454
27092	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	07:07:55	18:00:45	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65222	454
27093	TMNG-202502-439	 RALLY MILA	PISIGAN	PISIGAN, RALLY MILA	07:15:03	18:00:28	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65223	454
27094	TMNG-202502-446	 BRANDO ECLEO	MADREO	MADREO, BRANDO ECLEO	07:20:10	17:51:18	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:31	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65224	466
27095	TMNG-202502-446	 BRANDO ECLEO	MADREO	MADREO, BRANDO ECLEO	07:01:21	18:09:57	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65225	466
27096	TMNG-202502-446	 BRANDO ECLEO	MADREO	MADREO, BRANDO ECLEO	07:01:48	17:54:26	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65226	466
27097	TMNG-202502-446	 BRANDO ECLEO	MADREO	MADREO, BRANDO ECLEO	07:00:15	17:53:22	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65227	466
27098	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	06:55:38	17:53:21	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65228	505
27099	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	06:57:10	17:50:40	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65229	505
27100	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	06:58:02	17:49:43	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65230	505
27101	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	07:00:27	17:48:57	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65231	505
27102	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	06:58:38	15:50:41	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65232	505
27103	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	06:56:11	17:50:32	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65233	505
27104	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	06:56:43	17:53:15	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65234	505
27105	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	06:59:04	17:51:21	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65235	505
27106	TMNG-202410-043	 HAIDEE VALLEJOS	MERCURIO	MERCURIO, HAIDEE VALLEJOS	06:59:59	17:53:15	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65236	505
27107	TMNG-202410-090	 GRAIL AGLANO	BALDAS	BALDAS, GRAIL AGLANO	07:02:14	17:51:52	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65237	10
27108	TMNG-202410-090	 GRAIL AGLANO	BALDAS	BALDAS, GRAIL AGLANO	07:00:46	17:52:31	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65238	10
27109	TMNG-202410-090	 GRAIL AGLANO	BALDAS	BALDAS, GRAIL AGLANO	07:00:12	17:51:38	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65239	10
27110	TMNG-202410-090	 GRAIL AGLANO	BALDAS	BALDAS, GRAIL AGLANO	07:01:26	17:47:05	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65240	10
27111	TMNG-202410-090	 GRAIL AGLANO	BALDAS	BALDAS, GRAIL AGLANO	06:59:54	17:52:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65241	10
27112	TMNG-202510-1018	 MECHELLE MOVILLA	TESORO	TESORO, MECHELLE MOVILLA	06:59:42	18:00:48	ord	FLEET OPERATIONS	LAMI Mining Site	\N	6-15	02:01	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65242	540
27113	TMNG-202510-1018	 MECHELLE MOVILLA	TESORO	TESORO, MECHELLE MOVILLA	06:52:37	17:52:43	ord	FLEET OPERATIONS	LAMI Mining Site	\N	6-15	02:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65243	540
27114	TMNG-202510-1018	 MECHELLE MOVILLA	TESORO	TESORO, MECHELLE MOVILLA	07:13:57	17:50:49	ord	FLEET OPERATIONS	LAMI Mining Site	\N	6-15	01:37	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65244	540
27115	TMNG-202510-1018	 MECHELLE MOVILLA	TESORO	TESORO, MECHELLE MOVILLA	07:20:02	17:55:57	ord	FLEET OPERATIONS	LAMI Mining Site	\N	6-15	01:36	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65245	540
27116	TMNG-202510-1018	 MECHELLE MOVILLA	TESORO	TESORO, MECHELLE MOVILLA	07:14:02	15:53:26	ord	FLEET OPERATIONS	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65246	540
27117	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:49:26	18:00:42	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65247	386
27118	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:42:41	18:01:32	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	02:19	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65248	386
27119	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:55:57	17:50:34	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65249	386
27120	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:53:39	17:50:51	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65250	386
27121	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:53:23	15:52:32	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65251	386
27122	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	07:12:51	17:50:47	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	01:38	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65252	386
27123	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:48:21	17:55:37	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65253	386
27124	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:55:19	17:52:16	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65254	386
27125	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:55:29	17:53:15	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65255	386
27126	TMNG-202002-004	 NICSON MELU	MARAVE	MARAVE, NICSON MELU	06:44:01	19:00:22	ord	MINE DEVELOPMENT, PRODUCTION AND GRADE CONTROL	LAMI Mining Site	\N	7-16	03:16	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65256	386
27127	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	07:02:10	17:52:19	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65257	57
27128	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	06:55:55	17:52:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65258	57
27129	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	07:00:41	17:54:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65259	57
27130	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	06:51:43	17:50:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65260	57
27131	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	07:12:57	15:56:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65261	57
27132	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	07:12:41	17:52:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:40	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65262	57
27133	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	06:55:32	17:53:21	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65263	57
27134	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	06:54:19	17:51:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65264	57
27135	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	06:56:13	17:50:33	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65265	57
27136	TMNG-202410-083	 HOMER INTERNO	MONTERO	MONTERO, HOMER INTERNO	06:59:05	19:05:23	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	03:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65266	57
27137	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	07:13:20	17:52:07	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:39	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65267	506
27138	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	06:56:28	17:50:57	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65268	506
27139	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	07:05:32	17:51:26	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65269	506
27140	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	07:21:02	17:52:47	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:32	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65270	506
27141	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	06:58:54	15:55:34	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65271	506
27142	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	07:03:18	17:51:32	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65272	506
27143	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	07:04:41	17:52:16	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65273	506
27144	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	07:09:32	17:54:29	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:45	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65274	506
27145	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	07:07:43	17:50:46	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65275	506
27146	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	06:56:51	15:56:55	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-21 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65276	506
27147	TMNG-202409-142	 JOMAR MISA	MILLAN	MILLAN, JOMAR MISA	07:10:28	18:01:02	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65277	506
27148	TMNG-202502-441	 RICKY MILA	PISIGAN	PISIGAN, RICKY MILA	07:17:06	18:00:36	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65278	455
27149	TMNG-202502-441	 RICKY MILA	PISIGAN	PISIGAN, RICKY MILA	07:08:35	18:01:35	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65279	455
27150	TMNG-202502-441	 RICKY MILA	PISIGAN	PISIGAN, RICKY MILA	06:09:58	16:43:13	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:33	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65280	455
27151	TMNG-202502-441	 RICKY MILA	PISIGAN	PISIGAN, RICKY MILA	07:11:42	18:54:20	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	02:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65281	455
27152	TMNG-202502-441	 RICKY MILA	PISIGAN	PISIGAN, RICKY MILA	07:12:20	18:01:32	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65282	455
27153	TMNG-202502-441	 RICKY MILA	PISIGAN	PISIGAN, RICKY MILA	07:06:58	18:00:35	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65283	455
27154	TMNG-202502-441	 RICKY MILA	PISIGAN	PISIGAN, RICKY MILA	07:07:22	18:00:47	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65284	455
27155	TMNG-202502-441	 RICKY MILA	PISIGAN	PISIGAN, RICKY MILA	07:08:34	18:00:55	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65285	455
27156	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	06:58:31	13:57:58	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65286	333
27157	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	06:55:47	17:55:03	ord	MEPED	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65287	333
27158	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	07:16:49	17:50:20	ord	MEPED	LAMI Mining Site	\N	7-16	01:34	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65288	333
27159	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	06:33:36	15:54:25	ord	MEPED	LAMI Mining Site	\N	7-16	00:21	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65289	333
27160	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	07:06:41	17:52:37	ord	MEPED	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65290	333
27161	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	07:11:16	17:55:08	ord	MEPED	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65291	333
27162	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	07:11:41	17:55:05	ord	MEPED	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65292	333
27163	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	07:14:21	17:55:02	ord	MEPED	LAMI Mining Site	\N	7-16	01:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65293	333
27164	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	06:15:06	14:55:01	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65294	333
27165	TMNG-202409-132	 JOHN LESTER CABICO	MAYO	MAYO, JOHN LESTER CABICO	06:57:37	17:55:11	ord	MEPED	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65295	333
27166	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	07:04:54	18:07:19	ord	MEPED	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65296	338
27167	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	07:06:57	18:01:17	ord	MEPED	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65297	338
27168	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	07:08:07	17:55:09	ord	MEPED	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65298	338
27169	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	07:18:41	17:55:46	ord	MEPED	LAMI Mining Site	\N	7-16	01:37	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65299	338
27170	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	07:10:36	17:55:13	ord	MEPED	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65300	338
27171	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	07:01:30	17:55:33	ord	MEPED	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65301	338
27172	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	07:10:52	17:55:28	ord	MEPED	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65302	338
27173	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	06:56:30	17:55:14	ord	MEPED	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65303	338
27174	TMNG-202101-008	 JOAN MACALTAO	MOJENO	MOJENO, JOAN MACALTAO	06:57:33	19:04:51	ord	MEPED	LAMI Mining Site	\N	7-16	03:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65304	338
27175	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:47:42	07:02:28	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:15	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65305	286
27176	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:50:55	07:02:05	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:11	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65306	286
27177	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	22:13:09	07:03:04	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:00	00:00	00:00	00:00	00:00	07:47	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65307	286
27178	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:40:58	07:02:51	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:22	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65308	286
27179	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:46:39	07:02:39	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:16	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65309	286
27180	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:43:38	07:04:32	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:21	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65310	286
27181	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:54:56	07:02:12	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:07	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65311	286
27182	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:44:41	07:02:33	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:18	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65312	286
27183	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:41:23	07:02:08	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:21	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65313	286
27184	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:45:45	07:01:09	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:16	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65314	286
27185	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:53:10	07:01:12	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:08	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65315	286
27186	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	21:26:53	07:02:09	ord	LABORATORY	LAMI Mining Site	\N	20-5	00:35	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65316	286
27187	TMNG-202509-629	 KATRINA MEDALLA	BALONCIO	BALONCIO, KATRINA MEDALLA	19:44:10	07:00:53	ord	LABORATORY	LAMI Mining Site	\N	20-5	02:17	00:00	00:00	00:00	00:00	08:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65317	286
27188	TMNG-202310-019	 ARJAY MAPA	DALANON	DALANON, ARJAY MAPA	07:00:37	21:06:50	ord	LABORATORY	LAMI Mining Site	\N	7-16	05:06	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65318	287
27189	TMNG-202310-019	 ARJAY MAPA	DALANON	DALANON, ARJAY MAPA	07:00:18	20:56:03	ord	LABORATORY	LAMI Mining Site	\N	7-16	04:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65319	287
27190	TMNG-202310-019	 ARJAY MAPA	DALANON	DALANON, ARJAY MAPA	07:00:31	20:42:42	ord	LABORATORY	LAMI Mining Site	\N	7-16	04:42	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65320	287
27191	TMNG-202310-019	 ARJAY MAPA	DALANON	DALANON, ARJAY MAPA	07:05:13	21:01:26	ord	LABORATORY	LAMI Mining Site	\N	7-16	04:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65321	287
27192	TMNG-202108-003	 REY MERA	OPINGA	OPINGA, REY MERA	07:00:54	21:29:57	ord	LABORATORY	LAMI Mining Site	\N	7-16	05:29	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65322	306
27193	TMNG-202108-003	 REY MERA	OPINGA	OPINGA, REY MERA	07:01:43	20:49:36	ord	LABORATORY	LAMI Mining Site	\N	7-16	04:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65323	306
27194	TMNG-202108-003	 REY MERA	OPINGA	OPINGA, REY MERA	07:03:24	20:55:02	ord	LABORATORY	LAMI Mining Site	\N	7-16	04:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65324	306
27195	TMNG-202108-003	 REY MERA	OPINGA	OPINGA, REY MERA	07:03:32	20:54:25	ord	LABORATORY	LAMI Mining Site	\N	7-16	04:51	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65325	306
27196	TMNG-202108-003	 REY MERA	OPINGA	OPINGA, REY MERA	07:00:03	21:04:04	ord	LABORATORY	LAMI Mining Site	\N	7-16	05:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65326	306
27197	TMNG-202108-003	 REY MERA	OPINGA	OPINGA, REY MERA	07:00:08	21:12:37	ord	LABORATORY	LAMI Mining Site	\N	7-16	05:13	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65327	306
27198	TMNG-202108-003	 REY MERA	OPINGA	OPINGA, REY MERA	07:00:06	21:33:30	ord	LABORATORY	LAMI Mining Site	\N	7-16	05:34	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65328	306
27199	TMNG-202108-003	 REY MERA	OPINGA	OPINGA, REY MERA	07:04:59	20:57:03	ord	LABORATORY	LAMI Mining Site	\N	7-16	04:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65329	306
27200	TMNG-202508-553	 ARVIN FERNANDO	MAYO	MAYO, ARVIN FERNANDO	06:48:28	17:51:20	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65330	185
27201	TMNG-202508-553	 ARVIN FERNANDO	MAYO	MAYO, ARVIN FERNANDO	06:47:41	17:54:35	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65331	185
27202	TMNG-202508-553	 ARVIN FERNANDO	MAYO	MAYO, ARVIN FERNANDO	06:51:27	17:52:57	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65332	185
27203	TMNG-202508-553	 ARVIN FERNANDO	MAYO	MAYO, ARVIN FERNANDO	07:01:57	17:50:29	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65333	185
27204	TMNG-202508-553	 ARVIN FERNANDO	MAYO	MAYO, ARVIN FERNANDO	06:51:22	17:51:23	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65334	185
27205	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	06:47:42	17:54:09	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65335	85
27206	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	06:57:31	17:57:08	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65336	85
27207	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	07:07:37	17:54:46	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65337	85
27208	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	07:06:31	17:57:36	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:51	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65338	85
27209	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	07:01:36	15:59:26	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65339	85
27210	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	07:08:48	17:56:44	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65340	85
27211	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	07:03:44	17:56:00	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65341	85
27212	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	07:00:05	17:55:47	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65342	85
27213	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	07:01:13	17:56:26	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65343	85
27214	TMNG-202509-644	 EMMANUEL MARMETO	MONTANO	MONTANO, EMMANUEL MARMETO	06:53:43	17:55:53	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65344	85
27215	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	06:54:32	17:51:36	ord	MEPED	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65345	321
27216	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	06:58:25	17:51:02	ord	MEPED	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65346	321
27217	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	06:58:24	17:50:20	ord	MEPED	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:42	2026-09-22 15:04:42	\N	\N	14	\N	65347	321
27218	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	07:00:32	17:49:10	ord	MEPED	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65348	321
27219	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	06:57:16	15:51:09	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65349	321
27220	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	07:01:09	17:51:30	ord	MEPED	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65350	321
27221	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	07:00:38	17:50:40	ord	MEPED	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65351	321
27222	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	06:59:33	17:52:49	ord	MEPED	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65352	321
27223	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	07:00:17	17:53:48	ord	MEPED	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65353	321
27224	TMNG-202509-562	 ROY ANGELO PULIDO	EBANA	EBANA, ROY ANGELO PULIDO	06:54:42	06:59:23	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-26 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65354	321
27225	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	07:31:19	17:53:10	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:22	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65355	40
27226	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	06:57:57	17:52:34	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65356	40
27227	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	06:58:27	17:54:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65357	40
27228	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	07:01:09	17:50:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65358	40
27229	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	06:59:49	15:55:54	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65359	40
27230	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	07:05:49	17:52:14	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65360	40
27231	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	06:55:36	17:53:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65361	40
27232	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	06:54:26	17:52:10	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65362	40
27233	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	06:56:17	17:50:37	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65363	40
27234	TMNG-202410-026	 JAMES MAYPAY	MELU	MELU, JAMES MAYPAY	07:10:58	17:53:44	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65364	40
27235	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	06:54:21	17:53:14	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65365	503
27236	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	06:58:42	17:51:48	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65366	503
27237	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	06:55:07	17:47:28	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65367	503
27238	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	07:11:38	17:50:58	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:40	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65368	503
27239	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	06:57:31	15:52:28	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65369	503
27240	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	06:59:47	17:51:26	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65370	503
27241	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	06:57:17	17:51:52	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65371	503
27242	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	06:58:20	17:52:21	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65372	503
27243	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	06:55:17	17:51:45	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65373	503
27244	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	07:12:02	17:04:42	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	00:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-21 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65374	503
27245	TMNG-202212-032	 CHRISTIAN EGMAO	MANUEL	MANUEL, CHRISTIAN EGMAO	07:07:37	19:11:56	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65375	503
27246	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:58:08	17:52:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65376	49
27247	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:56:03	17:52:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65377	49
27248	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:55:18	17:53:53	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65378	49
27249	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:55:31	17:48:28	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65379	49
27250	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:55:45	15:55:05	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65380	49
27251	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:56:46	17:52:25	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65381	49
27252	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:57:26	17:51:28	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65382	49
27253	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:59:23	17:47:27	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65383	49
27254	TMNG-202410-111	 VICTORINO MAGNASE	MIRADOR	MIRADOR, VICTORINO MAGNASE	06:54:23	17:52:50	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65384	49
27255	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	06:55:06	17:55:37	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65385	448
27256	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	06:58:17	17:54:43	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65386	448
27257	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	06:59:07	17:50:56	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65387	448
27258	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	06:44:24	17:51:12	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65388	448
27259	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	06:57:12	15:51:14	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65389	448
27260	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	07:02:32	17:54:34	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65390	448
27261	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	06:49:43	17:54:06	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65391	448
27262	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	06:56:38	17:54:53	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65392	448
27263	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	06:59:19	17:56:41	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65393	448
27264	TMNG-202505-534	 REYNAN MANGLICMOT	BENG-AD	BENG-AD, REYNAN MANGLICMOT	07:00:24	17:52:44	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65394	448
27265	TMNG-202509-636	 NELSON MENDIGORIN	EGMAO	EGMAO, NELSON MENDIGORIN	06:57:35	17:49:27	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65395	78
27266	TMNG-202509-636	 NELSON MENDIGORIN	EGMAO	EGMAO, NELSON MENDIGORIN	06:55:42	17:50:01	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65396	78
27267	TMNG-202509-636	 NELSON MENDIGORIN	EGMAO	EGMAO, NELSON MENDIGORIN	06:55:25	17:49:21	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65397	78
27268	TMNG-202509-636	 NELSON MENDIGORIN	EGMAO	EGMAO, NELSON MENDIGORIN	06:56:02	15:49:23	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65398	78
27269	TMNG-202509-636	 NELSON MENDIGORIN	EGMAO	EGMAO, NELSON MENDIGORIN	06:59:54	17:50:59	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:51	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65399	78
27270	TMNG-202509-636	 NELSON MENDIGORIN	EGMAO	EGMAO, NELSON MENDIGORIN	06:55:45	17:51:00	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65400	78
27271	TMNG-202509-636	 NELSON MENDIGORIN	EGMAO	EGMAO, NELSON MENDIGORIN	06:55:34	17:49:29	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65401	78
27272	TMNG-202509-636	 NELSON MENDIGORIN	EGMAO	EGMAO, NELSON MENDIGORIN	06:54:19	17:50:11	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65402	78
27273	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:54:01	17:50:45	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65403	465
27274	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:57:40	17:49:46	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65404	465
27275	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:56:54	17:47:58	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:51	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65405	465
27276	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:27:44	17:48:53	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:21	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65406	465
27277	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:59:25	17:50:26	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:51	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65407	465
27278	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:56:02	17:50:31	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65408	465
27279	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:57:44	17:55:18	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65409	465
27280	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:55:39	17:49:45	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65410	465
27281	TMNG-202501-389	 ZERWIN MINIMO	EDQUILA	EDQUILA, ZERWIN MINIMO	06:55:38	17:50:30	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65411	465
27282	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	10:00:45	18:51:46	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65412	275
27283	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	11:07:02	18:50:03	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65413	275
27284	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	09:42:02	18:50:58	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	00:09	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65414	275
27285	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	09:58:55	18:50:28	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65415	275
27286	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	09:59:19	18:50:11	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65416	275
27287	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	06:51:35	15:50:04	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65417	275
27288	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	06:59:57	17:50:18	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65418	275
27289	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	06:57:09	17:50:03	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65419	275
27290	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	06:55:25	17:49:41	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65420	275
27291	TMNG-202510-815	 LORENZ ALOTA	DELOS SANTOS	DELOS SANTOS, LORENZ ALOTA	06:52:15	15:50:04	ord	FUEL MANAGEMENT	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65421	275
27292	TMNG-202509-617	 JUN MOLINO	MENDOZA	MENDOZA, JUN MOLINO	07:00:40	17:50:47	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65422	204
27293	TMNG-202509-617	 JUN MOLINO	MENDOZA	MENDOZA, JUN MOLINO	06:41:45	18:02:35	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:21	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65423	204
27294	TMNG-202509-617	 JUN MOLINO	MENDOZA	MENDOZA, JUN MOLINO	06:41:55	15:59:19	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:17	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-16 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65424	204
27295	TMNG-202509-617	 JUN MOLINO	MENDOZA	MENDOZA, JUN MOLINO	06:59:04	17:50:54	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65425	204
27296	TMNG-202509-617	 JUN MOLINO	MENDOZA	MENDOZA, JUN MOLINO	06:55:28	17:52:08	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65426	204
27297	TMNG-202509-617	 JUN MOLINO	MENDOZA	MENDOZA, JUN MOLINO	06:57:05	17:50:05	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65427	204
27298	TMNG-202509-617	 JUN MOLINO	MENDOZA	MENDOZA, JUN MOLINO	06:54:53	17:50:24	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65428	204
27299	TMNG-202509-617	 JUN MOLINO	MENDOZA	MENDOZA, JUN MOLINO	06:55:16	17:50:19	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65429	204
27300	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	06:56:59	17:48:57	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65430	90
27301	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	06:56:59	17:49:12	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65431	90
27302	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	07:00:54	17:49:29	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65432	90
27303	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	06:56:52	15:50:48	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65433	90
27304	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	06:59:14	17:51:05	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65434	90
27305	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	06:55:58	17:50:56	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65435	90
27306	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	06:57:15	17:51:00	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65436	90
27307	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	06:55:03	17:50:01	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65437	90
27308	TMNG-202509-649	 JOESEL CASTILLO	RABINA	RABINA, JOESEL CASTILLO	06:55:27	17:49:17	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65438	90
27309	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:54:06	17:50:27	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65439	86
27310	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:57:02	17:49:37	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65440	86
27311	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:56:30	17:49:21	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65441	86
27312	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	07:00:45	17:49:49	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65442	86
27313	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:56:36	15:49:39	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65443	86
27314	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:59:02	17:50:39	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65444	86
27315	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:55:42	17:50:55	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65445	86
27316	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:57:20	17:50:52	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65446	86
27317	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:54:54	17:50:06	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65447	86
27318	TMNG-202509-645	 EDWIN MENDIGORIN	MONTEROLA	MONTEROLA, EDWIN MENDIGORIN	06:55:05	19:00:17	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	03:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65448	86
27319	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:56:22	18:00:03	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65449	92
27320	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:54:24	18:00:04	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65450	92
27321	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:50:06	18:00:04	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65451	92
27322	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:54:43	18:00:03	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65452	92
27323	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:56:47	16:00:20	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	00:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65453	92
27324	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:55:42	18:00:04	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65454	92
27325	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:50:06	18:00:19	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65455	92
27326	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:51:20	18:00:15	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:09	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65456	92
27327	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:56:51	18:00:15	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65457	92
27328	TMNG-202509-651	 FREDERICK ESTEBAN	SINANGOTE	SINANGOTE, FREDERICK ESTEBAN	06:49:14	18:00:05	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65458	92
27329	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:59:53	17:52:41	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65459	47
27330	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:58:27	17:52:07	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65460	47
27331	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:53:30	17:54:27	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65461	47
27332	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:54:34	17:50:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65462	47
27333	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:50:22	15:55:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65463	47
27334	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:46:29	17:51:42	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65464	47
27335	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:53:14	17:53:17	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65465	47
27336	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:45:08	17:52:06	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65466	47
27337	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:56:08	17:50:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65467	47
27338	TMNG-202410-082	 CHRISTIAN CARPIO	MILANIO	MILANIO, CHRISTIAN CARPIO	06:47:11	17:53:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65468	47
27339	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	06:57:38	17:51:01	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65469	122
27340	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	07:00:21	17:49:56	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65470	122
27341	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	06:51:54	17:48:58	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65471	122
27342	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	07:06:08	17:49:33	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65472	122
27343	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	07:03:04	15:49:16	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65473	122
27344	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	07:13:32	17:52:26	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:39	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65474	122
27345	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	07:03:57	17:51:57	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65475	122
27346	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	06:40:28	17:49:47	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65476	122
27347	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	08:29:53	17:53:54	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:24	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65477	122
27348	TMNG-202509-628	 WILFREDO JR. PARINAS	CARDAÑO	CARDAÑO, WILFREDO JR. PARINAS	06:40:47	17:54:26	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65478	122
27349	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	06:44:56	18:04:23	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:19	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65479	6
27350	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	06:57:35	18:04:52	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65480	6
27351	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	06:47:12	18:01:09	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65481	6
27352	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	07:01:03	18:03:56	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65482	6
27353	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	07:07:37	16:01:40	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65483	6
27354	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	06:53:56	18:01:47	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65484	6
27355	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	07:04:17	18:02:18	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65485	6
27356	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	06:55:40	18:04:10	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65486	6
27357	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	06:46:23	18:01:05	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:15	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65487	6
27358	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	06:42:21	18:04:12	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:22	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65488	6
27359	TMNG-202409-150	 JAMES MITCHELL MANANGAN	MONTALLA	MONTALLA, JAMES MITCHELL MANANGAN	06:50:49	18:01:03	ord	COMMUNITY RELATIONS STAFF	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65489	6
27360	TMNG-202509-573	 ULYSSIS MON	MOVILLA	MOVILLA, ULYSSIS MON	06:48:04	17:51:09	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65490	249
27361	TMNG-202510-943	 JERWIN ARANILLO	EQUIZA	EQUIZA, JERWIN ARANILLO	07:01:36	18:01:05	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65491	137
27362	TMNG-202510-943	 JERWIN ARANILLO	EQUIZA	EQUIZA, JERWIN ARANILLO	07:01:27	18:00:18	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65492	137
27363	TMNG-202510-943	 JERWIN ARANILLO	EQUIZA	EQUIZA, JERWIN ARANILLO	06:57:09	18:00:18	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65493	137
27364	TMNG-202510-943	 JERWIN ARANILLO	EQUIZA	EQUIZA, JERWIN ARANILLO	07:08:59	18:00:39	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65494	137
27365	TMNG-202510-943	 JERWIN ARANILLO	EQUIZA	EQUIZA, JERWIN ARANILLO	07:07:21	15:56:13	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65495	137
27366	TMNG-202510-943	 JERWIN ARANILLO	EQUIZA	EQUIZA, JERWIN ARANILLO	06:37:53	17:52:30	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65496	137
27367	TMNG-202510-943	 JERWIN ARANILLO	EQUIZA	EQUIZA, JERWIN ARANILLO	06:43:41	18:00:34	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:17	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65497	137
27368	TMNG-202510-943	 JERWIN ARANILLO	EQUIZA	EQUIZA, JERWIN ARANILLO	06:53:03	18:00:55	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65498	137
27369	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:26:27	16:51:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:25	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65499	46
27370	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:13:31	16:50:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:37	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65500	46
27371	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:22:04	16:55:43	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:34	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65501	46
27372	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:36:17	16:58:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:23	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65502	46
27373	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	07:07:49	15:50:27	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65503	46
27374	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:30:34	16:53:18	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:23	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65504	46
27375	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:12:05	16:59:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65505	46
27376	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:14:13	16:57:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65506	46
27377	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:14:53	17:02:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65507	46
27378	TMNG-202410-029	 MARWIN MILANIO	MERTOLA	MERTOLA, MARWIN MILANIO	06:41:41	16:50:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:09	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65508	46
27379	TMNG-202510-1014	 JESUS MODELO	MANALO	MANALO, JESUS MODELO	06:51:47	16:00:43	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:09	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65509	546
27380	TMNG-202510-1014	 JESUS MODELO	MANALO	MANALO, JESUS MODELO	06:35:29	16:05:53	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:31	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65510	546
27381	TMNG-202510-1014	 JESUS MODELO	MANALO	MANALO, JESUS MODELO	06:40:24	16:05:38	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:25	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65511	546
27382	TMNG-202510-1014	 JESUS MODELO	MANALO	MANALO, JESUS MODELO	06:17:45	16:01:44	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65512	546
27383	TMNG-202510-1014	 JESUS MODELO	MANALO	MANALO, JESUS MODELO	06:29:37	16:02:19	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:33	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65513	546
27384	TMNG-202510-1014	 JESUS MODELO	MANALO	MANALO, JESUS MODELO	06:49:01	16:04:15	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:15	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-23 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65514	546
27385	TMNG-202510-1014	 JESUS MODELO	MANALO	MANALO, JESUS MODELO	06:47:04	16:03:14	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:16	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65515	546
27386	TMNG-202510-1014	 JESUS MODELO	MANALO	MANALO, JESUS MODELO	06:52:09	16:00:40	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65516	546
27387	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:51:09	16:01:22	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65517	314
27388	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:46:24	08:38:31	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65518	314
27389	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:43:19	16:03:18	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:20	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65519	314
27390	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:42:19	16:03:23	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:21	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-16 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65520	314
27391	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:33:33	16:01:59	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:28	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65521	314
27392	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:26:16	16:01:02	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:35	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65522	314
27393	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:33:44	16:00:09	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:26	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65523	314
27394	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:41:30	16:04:52	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:23	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-23 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65524	314
27395	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:40:30	16:01:09	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:20	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65525	314
27396	TMNG-202510-704	 RUEL ALBERO	ROBENTA	ROBENTA, RUEL ALBERO	06:43:40	16:00:34	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:17	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65526	314
27397	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	07:01:25	17:55:05	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65527	464
27398	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	06:29:36	17:55:11	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:26	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65528	464
27399	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	06:45:26	17:49:30	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65529	464
27400	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	06:35:46	17:55:29	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:20	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65530	464
27401	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	06:52:18	17:59:12	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65531	464
27402	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	06:51:15	17:53:32	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65532	464
27403	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	06:45:37	17:58:16	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65533	464
27404	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	06:31:15	17:49:24	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:18	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65534	464
27405	TMNG-202503-486	 EDDIE NAVIDA	ECALDRE	ECALDRE, EDDIE NAVIDA	06:40:42	17:56:31	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	02:16	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65535	464
27406	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:51:01	17:50:41	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65536	215
27407	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:40:02	17:49:52	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65537	215
27408	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:42:46	17:48:42	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65538	215
27409	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:44:32	17:50:07	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65539	215
27410	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:46:04	15:49:28	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65540	215
27411	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:55:52	17:52:23	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65541	215
27412	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:34:02	17:51:48	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:18	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65542	215
27413	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:39:54	17:50:31	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65543	215
27414	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:34:14	17:50:21	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:16	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65544	215
27415	TMNG-202509-620	 NIÑO MOVILLA	MERZA	MERZA, NIÑO MOVILLA	06:39:13	17:50:50	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65545	215
27416	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	03:10:38	15:35:57	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:25	00:00	00:00	00:00	00:00	02:49	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65546	500
27417	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	03:09:15	15:31:50	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:23	00:00	00:00	00:00	00:00	02:51	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65547	500
27418	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	03:10:07	15:20:58	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:11	00:00	00:00	00:00	00:00	02:50	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65548	500
27419	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	03:13:30	15:46:53	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:34	00:00	00:00	00:00	00:00	02:47	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65549	500
27420	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	03:11:10	15:24:30	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:13	00:00	00:00	00:00	00:00	02:49	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65550	500
27421	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	03:05:43	15:35:55	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:30	00:00	00:00	00:00	00:00	02:54	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65551	500
27422	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	06:56:01	17:54:49	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65552	500
27423	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	06:48:49	17:51:41	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65553	500
27424	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	06:30:02	17:55:24	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:25	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65554	500
27425	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	06:46:20	17:53:09	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65555	500
27426	TMNG-202208-235	 MARICRIS MOVILLA	CATALBAS	CATALBAS, MARICRIS MOVILLA	06:45:00	17:54:00	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:09	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65556	500
27427	TMNG-202410-003	 JOEL JR. RUBIS	VALENZUELA	VALENZUELA, JOEL JR. RUBIS	05:58:35	16:51:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65557	77
27428	TMNG-202410-003	 JOEL JR. RUBIS	VALENZUELA	VALENZUELA, JOEL JR. RUBIS	06:07:38	16:48:53	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65558	77
27429	TMNG-202410-003	 JOEL JR. RUBIS	VALENZUELA	VALENZUELA, JOEL JR. RUBIS	06:36:18	15:51:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:16	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65559	77
27430	TMNG-202410-003	 JOEL JR. RUBIS	VALENZUELA	VALENZUELA, JOEL JR. RUBIS	06:15:00	16:52:43	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:38	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65560	77
27431	TMNG-202410-003	 JOEL JR. RUBIS	VALENZUELA	VALENZUELA, JOEL JR. RUBIS	06:01:32	16:53:49	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65561	77
27432	TMNG-202410-003	 JOEL JR. RUBIS	VALENZUELA	VALENZUELA, JOEL JR. RUBIS	06:03:01	16:53:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65562	77
27433	TMNG-202410-003	 JOEL JR. RUBIS	VALENZUELA	VALENZUELA, JOEL JR. RUBIS	06:51:14	17:00:50	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65563	77
27434	TMNG-202410-003	 JOEL JR. RUBIS	VALENZUELA	VALENZUELA, JOEL JR. RUBIS	06:25:33	16:51:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:26	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65564	77
27435	TMNG-202410-012	 LORENZVIL CADANO	MISA	MISA, LORENZVIL CADANO	06:09:31	16:51:05	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65565	50
27436	TMNG-202410-012	 LORENZVIL CADANO	MISA	MISA, LORENZVIL CADANO	05:43:29	16:51:44	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:17	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65566	50
27437	TMNG-202410-012	 LORENZVIL CADANO	MISA	MISA, LORENZVIL CADANO	05:51:52	16:48:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65567	50
27438	TMNG-202410-012	 LORENZVIL CADANO	MISA	MISA, LORENZVIL CADANO	06:44:28	15:48:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65568	50
27439	TMNG-202410-012	 LORENZVIL CADANO	MISA	MISA, LORENZVIL CADANO	06:20:16	16:52:17	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:32	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65569	50
27440	TMNG-202410-012	 LORENZVIL CADANO	MISA	MISA, LORENZVIL CADANO	05:46:10	16:52:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65570	50
27441	TMNG-202410-012	 LORENZVIL CADANO	MISA	MISA, LORENZVIL CADANO	06:10:59	16:51:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:40	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65571	50
27442	TMNG-202303-035	 JOVENCIO MEJOS	MARAVE	MARAVE, JOVENCIO MEJOS	06:55:51	15:54:31	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65572	329
27443	TMNG-202303-035	 JOVENCIO MEJOS	MARAVE	MARAVE, JOVENCIO MEJOS	07:00:20	17:52:32	ord	MEPED	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65573	329
27444	TMNG-202303-035	 JOVENCIO MEJOS	MARAVE	MARAVE, JOVENCIO MEJOS	06:56:17	17:55:17	ord	MEPED	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65574	329
27445	TMNG-202303-035	 JOVENCIO MEJOS	MARAVE	MARAVE, JOVENCIO MEJOS	06:58:02	17:55:11	ord	MEPED	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65575	329
27446	TMNG-202303-035	 JOVENCIO MEJOS	MARAVE	MARAVE, JOVENCIO MEJOS	07:02:09	17:55:09	ord	MEPED	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65576	329
27447	TMNG-202303-035	 JOVENCIO MEJOS	MARAVE	MARAVE, JOVENCIO MEJOS	06:15:11	14:55:12	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65577	329
27448	TMNG-202303-035	 JOVENCIO MEJOS	MARAVE	MARAVE, JOVENCIO MEJOS	06:24:03	19:00:48	ord	MEPED	LAMI Mining Site	\N	7-16	03:37	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65578	329
27449	TMNG-202410-058	 ODEMAR MIRADOR	MARTINEZ	MARTINEZ, ODEMAR MIRADOR	05:48:03	18:04:21	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:16	00:00	00:00	00:00	00:00	00:12	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65579	480
27450	TMNG-202410-058	 ODEMAR MIRADOR	MARTINEZ	MARTINEZ, ODEMAR MIRADOR	05:48:48	17:53:56	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:05	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65580	480
27451	TMNG-202410-058	 ODEMAR MIRADOR	MARTINEZ	MARTINEZ, ODEMAR MIRADOR	06:00:29	15:57:01	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	00:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65581	480
27452	TMNG-202410-058	 ODEMAR MIRADOR	MARTINEZ	MARTINEZ, ODEMAR MIRADOR	05:47:27	15:07:04	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	00:20	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65582	480
27453	TMNG-202410-058	 ODEMAR MIRADOR	MARTINEZ	MARTINEZ, ODEMAR MIRADOR	06:09:05	15:03:35	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65583	480
27454	TMNG-202410-058	 ODEMAR MIRADOR	MARTINEZ	MARTINEZ, ODEMAR MIRADOR	06:09:59	12:06:09	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65584	480
27455	TMNG-202410-058	 ODEMAR MIRADOR	MARTINEZ	MARTINEZ, ODEMAR MIRADOR	06:23:40	17:54:43	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	02:31	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65585	480
27456	TMNG-202301-188	 JOVANNI CASUPANAN	DELA CRUZ	DELA CRUZ, JOVANNI CASUPANAN	06:02:47	18:30:33	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	03:28	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65586	462
27457	TMNG-202301-188	 JOVANNI CASUPANAN	DELA CRUZ	DELA CRUZ, JOVANNI CASUPANAN	06:10:36	18:30:16	ord	OCCUPATIONAL HEALTH AND SAFETY	LAMI Mining Site	\N	7-16	03:20	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65587	462
27458	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	06:00:36	16:53:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65588	64
27459	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	06:07:40	16:53:44	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65589	64
27460	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	06:00:43	16:54:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65590	64
27461	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	06:07:08	16:50:34	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65591	64
27462	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	06:44:56	15:52:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:43	2026-09-22 15:04:43	\N	\N	14	\N	65592	64
27463	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	06:19:59	16:54:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:34	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65593	64
27464	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	05:59:36	16:55:17	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65594	64
27465	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	05:59:34	16:54:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65595	64
27466	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	06:02:37	16:58:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65596	64
27467	TMNG-202410-106	 MAURICIO MONTERO	PEÑARANDA	PEÑARANDA, MAURICIO MONTERO	06:08:28	16:55:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65597	64
27468	TMNG-202410-031	 RUEL LOPEZ	RODULFO	RODULFO, RUEL LOPEZ	05:55:55	16:55:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65598	68
27469	TMNG-202410-031	 RUEL LOPEZ	RODULFO	RODULFO, RUEL LOPEZ	06:01:57	16:50:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65599	68
27470	TMNG-202410-031	 RUEL LOPEZ	RODULFO	RODULFO, RUEL LOPEZ	06:06:08	16:50:13	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65600	68
27471	TMNG-202410-031	 RUEL LOPEZ	RODULFO	RODULFO, RUEL LOPEZ	07:07:42	15:49:42	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65601	68
27472	TMNG-202410-031	 RUEL LOPEZ	RODULFO	RODULFO, RUEL LOPEZ	06:08:39	16:52:14	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65602	68
27473	TMNG-202410-031	 RUEL LOPEZ	RODULFO	RODULFO, RUEL LOPEZ	05:59:30	18:00:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	03:01	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65603	68
27474	TMNG-202410-031	 RUEL LOPEZ	RODULFO	RODULFO, RUEL LOPEZ	06:56:58	17:11:57	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:15	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65604	68
27475	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	05:57:16	16:56:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65605	37
27476	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	06:05:25	16:55:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65606	37
27477	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	05:56:35	16:55:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65607	37
27478	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	06:10:03	16:55:44	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65608	37
27479	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	06:41:17	15:53:59	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:13	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65609	37
27480	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	06:10:37	16:54:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65610	37
27481	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	06:01:07	16:56:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65611	37
27482	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	06:00:57	17:02:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65612	37
27483	TMNG-202410-030	 ARIES MODELO	MEDEL	MEDEL, ARIES MODELO	06:14:56	16:55:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65613	37
27484	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	06:04:06	16:55:45	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65614	59
27485	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	06:07:45	16:55:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65615	59
27486	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	05:50:43	16:54:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65616	59
27487	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	06:06:58	16:51:12	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65617	59
27488	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	06:47:39	15:53:32	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:06	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65618	59
27489	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	06:16:12	16:53:25	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:37	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65619	59
27490	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	06:01:18	16:55:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65620	59
27491	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	05:56:12	16:57:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65621	59
27492	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	05:57:40	16:59:07	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65622	59
27493	TMNG-202408-059	 MARIO JR. MEDEL	MONTERO	MONTERO, MARIO JR. MEDEL	06:08:18	16:56:34	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65623	59
27494	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	06:04:29	16:54:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65624	63
27495	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	06:04:19	16:55:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:51	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65625	63
27496	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	06:01:37	16:51:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65626	63
27497	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	06:09:43	16:50:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65627	63
27498	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	06:45:00	15:52:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65628	63
27499	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	06:18:58	16:53:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:34	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65629	63
27500	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	06:01:11	16:55:58	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65630	63
27501	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	05:59:38	16:54:32	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65631	63
27502	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	05:57:34	16:59:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65632	63
27503	TMNG-202510-963	 JAYSON MONTERO	PEÑARANDA	PEÑARANDA, JAYSON MONTERO	06:07:53	16:55:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65633	63
27504	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	05:56:50	16:51:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65634	22
27505	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	05:46:35	16:51:38	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65635	22
27506	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	06:00:48	16:49:27	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65636	22
27507	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	06:05:15	16:49:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65637	22
27508	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	06:45:04	15:51:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65638	22
27509	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	06:16:19	16:53:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:37	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65639	22
27510	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	05:58:56	16:53:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65640	22
27511	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	05:56:01	16:53:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65641	22
27512	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	05:57:29	16:59:23	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65642	22
27513	TMNG-202507-545	 JOMEL TEMPORAL	FLORES	FLORES, JOMEL TEMPORAL	06:08:24	16:54:41	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65643	22
27514	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	05:53:42	16:55:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65644	18
27515	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	05:59:30	16:50:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65645	18
27516	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	05:56:42	16:51:21	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65646	18
27517	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	06:01:44	16:51:21	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65647	18
27518	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	06:47:32	15:52:05	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65648	18
27519	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	06:25:11	16:51:53	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:27	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65649	18
27520	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	05:58:07	16:55:42	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65650	18
27521	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	05:47:34	16:55:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65651	18
27522	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	05:58:16	16:58:46	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65652	18
27523	TMNG-202410-078	 DANIEL MADAMBA	CASTRO	CASTRO, DANIEL MADAMBA	06:06:07	16:55:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65653	18
27524	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	05:55:24	16:51:38	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65654	56
27525	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	06:01:43	16:51:49	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65655	56
27526	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	05:51:37	16:50:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65656	56
27527	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	06:03:27	16:50:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65657	56
27528	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	06:10:23	16:52:57	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65658	56
27529	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	06:01:15	16:55:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65659	56
27530	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	05:57:48	16:53:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65660	56
27531	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	05:51:23	17:00:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:09	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65661	56
27532	TMNG-202501-346	 BERNARD MIRADOR	MONTERO	MONTERO, BERNARD MIRADOR	06:08:55	16:54:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65662	56
27533	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	05:55:18	16:51:31	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65663	55
27534	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	06:02:02	16:53:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65664	55
27535	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	05:59:08	16:50:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65665	55
27536	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	06:05:20	16:49:42	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65666	55
27537	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	06:50:40	15:51:32	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:01	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65667	55
27538	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	06:10:18	16:53:28	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65668	55
27539	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	05:47:23	16:53:53	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65669	55
27540	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	05:49:19	16:52:25	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65670	55
27541	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	05:51:35	16:59:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65671	55
27542	TMNG-202410-014	 AURELIO JR. MODELO	MONTERO	MONTERO, AURELIO JR. MODELO	06:04:48	16:52:08	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65672	55
27543	TMNG-202410-022	 DEXTER BONA	VALENCIA	VALENCIA, DEXTER BONA	05:47:28	16:51:42	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65673	75
27544	TMNG-202410-022	 DEXTER BONA	VALENCIA	VALENCIA, DEXTER BONA	05:54:36	16:52:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65674	75
27545	TMNG-202410-022	 DEXTER BONA	VALENCIA	VALENCIA, DEXTER BONA	05:51:05	16:50:34	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65675	75
27546	TMNG-202410-022	 DEXTER BONA	VALENCIA	VALENCIA, DEXTER BONA	05:53:02	16:50:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65676	75
27547	TMNG-202410-022	 DEXTER BONA	VALENCIA	VALENCIA, DEXTER BONA	05:53:25	16:52:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65677	75
27548	TMNG-202410-022	 DEXTER BONA	VALENCIA	VALENCIA, DEXTER BONA	05:57:29	16:53:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65678	75
27549	TMNG-202410-022	 DEXTER BONA	VALENCIA	VALENCIA, DEXTER BONA	05:53:02	17:01:04	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65679	75
27550	TMNG-202410-022	 DEXTER BONA	VALENCIA	VALENCIA, DEXTER BONA	06:04:43	16:52:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65680	75
27551	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	05:42:32	16:54:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:12	00:00	00:00	00:00	00:00	00:17	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65681	66
27552	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	05:33:22	16:54:58	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:22	00:00	00:00	00:00	00:00	00:26	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65682	66
27553	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	05:44:23	16:51:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65683	66
27554	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	05:46:56	16:51:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65684	66
27555	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	06:26:16	15:52:45	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:26	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65685	66
27556	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	05:41:36	16:53:19	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:12	00:00	00:00	00:00	00:00	00:19	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65686	66
27557	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	05:38:34	16:54:45	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:16	00:00	00:00	00:00	00:00	00:22	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65687	66
27558	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	05:47:28	17:00:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65688	66
27559	TMNG-202410-001	 GILBERT MAYO	QUINACMAN	QUINACMAN, GILBERT MAYO	05:42:07	16:52:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:18	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65689	66
27560	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	05:50:44	16:52:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65690	51
27561	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	05:47:29	16:49:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65691	51
27562	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	05:40:06	16:49:37	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:20	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65692	51
27563	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	06:01:24	16:47:46	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65693	51
27564	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	06:52:22	15:49:54	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65694	51
27565	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	05:50:17	16:54:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65695	51
27566	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	05:59:18	16:52:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65696	51
27567	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	05:58:00	17:00:19	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65697	51
27568	TMNG-202410-085	 JAY RACRAQUIN	MODELO	MODELO, JAY RACRAQUIN	06:02:01	16:50:51	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65698	51
27569	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	05:54:05	16:54:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65699	25
27570	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	05:54:31	16:49:12	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65700	25
27571	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	05:51:16	16:49:53	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65701	25
27572	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	06:01:10	16:48:58	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65702	25
27573	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	06:30:55	15:50:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:19	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65703	25
27574	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	05:43:45	16:52:07	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65704	25
27575	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	06:02:33	16:53:08	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65705	25
27576	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	05:51:29	16:55:38	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65706	25
27577	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	05:52:58	17:00:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65707	25
27578	TMNG-202410-005	 SALVADOR MARAVE	LABAO	LABAO, SALVADOR MARAVE	06:07:47	16:54:04	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65708	25
27579	TMNG-202403-002	 JEFREY BALILIN	EBEN	EBEN, JEFREY BALILIN	06:01:12	19:00:18	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65709	477
27580	TMNG-202403-002	 JEFREY BALILIN	EBEN	EBEN, JEFREY BALILIN	05:50:47	19:04:46	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:14	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65710	477
27581	TMNG-202403-002	 JEFREY BALILIN	EBEN	EBEN, JEFREY BALILIN	06:05:07	18:57:48	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65711	477
27582	TMNG-202403-002	 JEFREY BALILIN	EBEN	EBEN, JEFREY BALILIN	05:59:24	18:59:16	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:00	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65712	477
27583	TMNG-202403-002	 JEFREY BALILIN	EBEN	EBEN, JEFREY BALILIN	06:02:29	19:00:45	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65713	477
27584	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	05:57:11	16:54:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65714	21
27585	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	05:58:23	16:54:17	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65715	21
27586	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	06:01:59	16:54:53	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65716	21
27587	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	06:06:53	16:55:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65717	21
27588	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	06:55:00	15:58:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65718	21
27589	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	05:41:10	16:53:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:19	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65719	21
27590	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	05:51:48	16:56:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65720	21
27591	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	05:52:43	16:54:03	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65721	21
27592	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	05:58:09	16:59:12	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65722	21
27593	TMNG-202310-023	 ARIEL TEMPORAL	FLORES	FLORES, ARIEL TEMPORAL	05:55:55	16:55:04	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65723	21
27594	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:55:34	19:00:38	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	04:05	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65724	501
27595	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:55:10	19:00:05	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	04:05	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65725	501
27596	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:53:53	19:00:21	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	04:07	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65726	501
27597	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:51:06	19:01:03	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	04:10	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65727	501
27598	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:57:13	17:01:48	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	02:05	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65728	501
27599	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	06:03:05	19:00:11	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	03:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65729	501
27600	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:57:56	19:00:20	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	04:02	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65730	501
27601	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	06:01:14	19:00:35	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	03:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65731	501
27602	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:50:45	19:00:08	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	04:10	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65732	501
27603	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:50:33	18:00:26	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	03:10	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-21 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65733	501
27604	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:51:21	19:01:00	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	04:10	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65734	501
27605	TMNG-202312-001	 RANDY FERNANDEZ	DELA CRUZ	DELA CRUZ, RANDY FERNANDEZ	05:47:49	19:00:57	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	6-15	04:13	00:00	00:00	00:00	00:00	00:12	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65735	501
27606	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	05:52:39	16:53:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65736	9
27607	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	05:58:39	16:53:52	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65737	9
27608	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	05:49:41	16:54:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65738	9
27609	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	06:06:49	16:51:05	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65739	9
27610	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	06:18:01	15:52:37	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:35	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65740	9
27611	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	05:52:43	16:53:59	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65741	9
27612	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	05:51:57	16:54:43	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65742	9
27613	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	05:52:48	16:54:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65743	9
27614	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	05:53:47	16:59:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65744	9
27615	TMNG-202510-991	 JHUNEL MAYO	AGPAWA	AGPAWA, JHUNEL MAYO	05:55:49	16:52:43	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65745	9
27616	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	05:54:13	16:54:07	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:00	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65746	32
27617	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	05:52:59	16:53:58	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65747	32
27618	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	05:52:33	16:49:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65748	32
27619	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	06:23:09	15:52:57	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:30	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65749	32
27620	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	05:59:00	16:53:31	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65750	32
27621	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	05:59:54	16:56:03	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65751	32
27622	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	05:54:38	16:53:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65752	32
27623	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	05:51:57	17:00:46	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:09	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65753	32
27624	TMNG-202410-161	 RANDY MERZA	MARTICIO	MARTICIO, RANDY MERZA	06:05:46	16:53:06	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65754	32
27625	TMNG-202410-025	 MARK ANTHONY MANIAGO	TEVES	TEVES, MARK ANTHONY MANIAGO	05:54:24	16:51:51	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65755	74
27626	TMNG-202410-025	 MARK ANTHONY MANIAGO	TEVES	TEVES, MARK ANTHONY MANIAGO	05:54:59	16:54:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65756	74
27627	TMNG-202410-025	 MARK ANTHONY MANIAGO	TEVES	TEVES, MARK ANTHONY MANIAGO	06:00:47	16:50:50	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65757	74
27628	TMNG-202410-025	 MARK ANTHONY MANIAGO	TEVES	TEVES, MARK ANTHONY MANIAGO	07:07:59	15:58:49	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65758	74
27629	TMNG-202410-025	 MARK ANTHONY MANIAGO	TEVES	TEVES, MARK ANTHONY MANIAGO	06:04:30	16:53:00	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65759	74
27630	TMNG-202410-025	 MARK ANTHONY MANIAGO	TEVES	TEVES, MARK ANTHONY MANIAGO	05:47:52	16:54:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:12	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65760	74
27631	TMNG-202410-025	 MARK ANTHONY MANIAGO	TEVES	TEVES, MARK ANTHONY MANIAGO	05:54:38	17:01:58	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65761	74
27632	TMNG-202410-025	 MARK ANTHONY MANIAGO	TEVES	TEVES, MARK ANTHONY MANIAGO	06:20:19	16:52:32	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:32	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65762	74
27633	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	05:49:52	16:55:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65763	26
27634	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	05:49:15	16:52:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65764	26
27635	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	05:56:41	16:51:37	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65765	26
27636	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	06:09:16	15:53:17	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65766	26
27637	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	05:53:28	16:54:25	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65767	26
27638	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	05:50:07	16:53:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65768	26
27639	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	05:53:48	16:55:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65769	26
27640	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	05:47:41	17:01:46	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65770	26
27641	TMNG-202410-011	 RENO MOSE	LEMON	LEMON, RENO MOSE	05:58:08	16:55:23	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65771	26
27642	TMNG-202403-004	 JERRY NEIL CLAVERIA	MANA	MANA, JERRY NEIL CLAVERIA	05:51:44	19:00:08	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:08	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65772	479
27643	TMNG-202403-004	 JERRY NEIL CLAVERIA	MANA	MANA, JERRY NEIL CLAVERIA	05:55:28	19:00:04	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:05	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65773	479
27644	TMNG-202403-004	 JERRY NEIL CLAVERIA	MANA	MANA, JERRY NEIL CLAVERIA	05:54:09	19:00:11	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:06	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65774	479
27646	TMNG-202403-004	 JERRY NEIL CLAVERIA	MANA	MANA, JERRY NEIL CLAVERIA	05:48:00	17:00:49	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:12	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65776	479
27647	TMNG-202403-004	 JERRY NEIL CLAVERIA	MANA	MANA, JERRY NEIL CLAVERIA	05:51:06	19:01:31	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:10	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65777	479
27648	TMNG-202403-004	 JERRY NEIL CLAVERIA	MANA	MANA, JERRY NEIL CLAVERIA	05:38:18	19:00:38	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:22	00:00	00:00	00:00	00:00	00:22	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65778	479
27649	TMNG-202410-023	 CHRISTIAN JAY VALENCIA	ABELLA	ABELLA, CHRISTIAN JAY VALENCIA	05:56:05	16:50:50	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65779	8
27650	TMNG-202410-023	 CHRISTIAN JAY VALENCIA	ABELLA	ABELLA, CHRISTIAN JAY VALENCIA	05:47:37	16:52:04	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65780	8
27651	TMNG-202410-023	 CHRISTIAN JAY VALENCIA	ABELLA	ABELLA, CHRISTIAN JAY VALENCIA	05:49:15	16:48:58	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:00	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65781	8
27652	TMNG-202410-023	 CHRISTIAN JAY VALENCIA	ABELLA	ABELLA, CHRISTIAN JAY VALENCIA	05:52:33	16:48:33	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65782	8
27653	TMNG-202410-023	 CHRISTIAN JAY VALENCIA	ABELLA	ABELLA, CHRISTIAN JAY VALENCIA	06:29:29	15:48:32	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:19	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65783	8
27654	TMNG-202410-023	 CHRISTIAN JAY VALENCIA	ABELLA	ABELLA, CHRISTIAN JAY VALENCIA	05:50:11	16:52:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65784	8
27655	TMNG-202410-023	 CHRISTIAN JAY VALENCIA	ABELLA	ABELLA, CHRISTIAN JAY VALENCIA	05:54:39	16:51:12	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65785	8
27656	TMNG-202412-310	 JOHN PHILIP MOSE	MELU	MELU, JOHN PHILIP MOSE	05:51:10	16:48:54	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65786	41
27657	TMNG-202412-310	 JOHN PHILIP MOSE	MELU	MELU, JOHN PHILIP MOSE	05:51:08	16:48:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65787	41
27658	TMNG-202412-310	 JOHN PHILIP MOSE	MELU	MELU, JOHN PHILIP MOSE	05:52:01	16:47:54	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65788	41
27659	TMNG-202412-310	 JOHN PHILIP MOSE	MELU	MELU, JOHN PHILIP MOSE	05:53:22	16:51:28	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65789	41
27660	TMNG-202412-310	 JOHN PHILIP MOSE	MELU	MELU, JOHN PHILIP MOSE	05:57:43	16:52:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65790	41
27661	TMNG-202412-310	 JOHN PHILIP MOSE	MELU	MELU, JOHN PHILIP MOSE	05:55:21	16:53:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65791	41
27662	TMNG-202412-310	 JOHN PHILIP MOSE	MELU	MELU, JOHN PHILIP MOSE	05:30:47	16:58:52	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:28	00:00	00:00	00:00	00:00	00:29	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65792	41
27663	TMNG-202412-310	 JOHN PHILIP MOSE	MELU	MELU, JOHN PHILIP MOSE	06:01:02	16:53:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65793	41
27664	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	05:30:45	16:50:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:20	00:00	00:00	00:00	00:00	00:29	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65794	69
27665	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	05:51:20	16:48:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65795	69
27667	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	05:51:47	16:48:44	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65797	69
27666	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	05:51:00	16:00:00	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:09	01:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Approved	2026-09-22 15:04:44	2026-09-22 15:36:52	05:51:21	16:47:54	14	\N	65796	69
27669	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	05:53:20	16:51:33	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Approved	2026-09-22 15:04:44	2026-09-22 15:37:24	\N	\N	14	\N	65799	69
27670	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	05:57:50	16:52:06	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Approved	2026-09-22 15:04:44	2026-09-22 15:38:15	\N	\N	14	\N	65800	69
27671	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	05:55:18	16:52:51	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65801	69
27672	TMNG-202410-162	 ALMIL MEDIARIO	SALES	SALES, ALMIL MEDIARIO	05:30:54	16:58:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:28	00:00	00:00	00:00	00:00	00:29	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65802	69
27674	TMNG-202403-005	 OLIVER MESIA	MOSE	MOSE, OLIVER MESIA	11:31:28	19:46:48	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65804	481
27675	TMNG-202403-005	 OLIVER MESIA	MOSE	MOSE, OLIVER MESIA	06:10:12	19:02:32	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65805	481
27676	TMNG-202403-005	 OLIVER MESIA	MOSE	MOSE, OLIVER MESIA	05:59:02	19:00:34	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:02	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65806	481
27677	TMNG-202403-005	 OLIVER MESIA	MOSE	MOSE, OLIVER MESIA	05:40:59	19:08:27	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:28	00:00	00:00	00:00	00:00	00:19	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65807	481
27678	TMNG-202403-005	 OLIVER MESIA	MOSE	MOSE, OLIVER MESIA	05:56:12	19:01:43	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:05	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65808	481
27679	TMNG-202403-005	 OLIVER MESIA	MOSE	MOSE, OLIVER MESIA	05:50:46	19:01:08	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:10	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65809	481
27680	TMNG-202403-005	 OLIVER MESIA	MOSE	MOSE, OLIVER MESIA	06:07:37	19:04:59	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65810	481
27681	TMNG-202410-051	 JUPITER BASILA	BANTOLIN	BANTOLIN, JUPITER BASILA	05:53:52	15:51:52	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:58	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65811	11
27682	TMNG-202410-051	 JUPITER BASILA	BANTOLIN	BANTOLIN, JUPITER BASILA	06:09:46	16:52:18	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65812	11
27683	TMNG-202410-051	 JUPITER BASILA	BANTOLIN	BANTOLIN, JUPITER BASILA	05:53:42	16:54:13	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65813	11
27684	TMNG-202410-051	 JUPITER BASILA	BANTOLIN	BANTOLIN, JUPITER BASILA	05:50:24	19:04:57	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	04:14	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65814	11
27685	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	05:55:37	16:51:13	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65815	76
27686	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	05:46:00	16:52:00	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65816	76
27687	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	05:46:56	16:48:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65817	76
27688	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	05:51:17	16:48:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65818	76
27689	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	06:27:52	15:48:53	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:21	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65819	76
27690	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	05:50:02	16:52:10	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65820	76
27691	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	05:32:09	16:52:18	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:20	00:00	00:00	00:00	00:00	00:28	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65821	76
27692	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	05:31:00	17:01:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:30	00:00	00:00	00:00	00:00	00:29	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65822	76
27693	TMNG-202410-021	 NORLITO BUSTAMANTE	VALENCIA	VALENCIA, NORLITO BUSTAMANTE	05:52:50	16:51:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65823	76
27694	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	05:49:10	16:53:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65824	71
27695	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	05:55:14	16:54:33	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65825	71
27696	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	05:49:47	16:54:42	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65826	71
27697	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	06:05:05	16:58:46	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65827	71
27698	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	06:26:29	15:52:10	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:26	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65828	71
27699	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	05:53:31	16:57:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65829	71
27700	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	05:57:39	16:55:49	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65830	71
27701	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	05:49:49	17:01:42	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:12	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65831	71
27702	TMNG-202410-036	 DOMINADOR MANLINCON	SARMIENTO	SARMIENTO, DOMINADOR MANLINCON	06:01:23	16:57:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65832	71
27703	TMNG-202410-019	 ROGELIO JR. SALVADOR	MEDEL	MEDEL, ROGELIO JR. SALVADOR	05:47:10	16:53:45	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65833	38
27704	TMNG-202410-019	 ROGELIO JR. SALVADOR	MEDEL	MEDEL, ROGELIO JR. SALVADOR	05:49:51	16:54:34	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65834	38
27705	TMNG-202410-019	 ROGELIO JR. SALVADOR	MEDEL	MEDEL, ROGELIO JR. SALVADOR	05:20:17	16:50:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:31	00:00	00:00	00:00	00:00	00:40	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:44	2026-09-22 15:04:44	\N	\N	14	\N	65835	38
27706	TMNG-202410-019	 ROGELIO JR. SALVADOR	MEDEL	MEDEL, ROGELIO JR. SALVADOR	06:36:07	15:49:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:13	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65836	38
27707	TMNG-202410-019	 ROGELIO JR. SALVADOR	MEDEL	MEDEL, ROGELIO JR. SALVADOR	05:39:26	16:51:25	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:12	00:00	00:00	00:00	00:00	00:20	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65837	38
27708	TMNG-202410-019	 ROGELIO JR. SALVADOR	MEDEL	MEDEL, ROGELIO JR. SALVADOR	05:33:42	16:55:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:22	00:00	00:00	00:00	00:00	00:26	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65838	38
27709	TMNG-202410-019	 ROGELIO JR. SALVADOR	MEDEL	MEDEL, ROGELIO JR. SALVADOR	05:32:03	16:57:10	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:25	00:00	00:00	00:00	00:00	00:28	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65839	38
27710	TMNG-202410-019	 ROGELIO JR. SALVADOR	MEDEL	MEDEL, ROGELIO JR. SALVADOR	05:28:38	17:01:23	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:33	00:00	00:00	00:00	00:00	00:31	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65840	38
27711	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	05:45:23	16:50:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65841	62
27712	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	06:01:32	16:49:05	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65842	62
27713	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	05:45:18	16:48:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:15	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65843	62
27714	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	06:04:57	16:47:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65844	62
27715	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	06:30:31	15:48:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:18	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65845	62
27716	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	06:04:59	16:51:58	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65846	62
27717	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	05:53:04	16:52:21	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65847	62
27718	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	05:50:03	16:52:10	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65848	62
27719	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	05:44:49	16:59:44	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:15	00:00	00:00	00:00	00:00	00:15	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65849	62
27720	TMNG-202410-004	 LINO MIRADIOS	MUEGA	MUEGA, LINO MIRADIOS	05:56:10	16:50:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65850	62
27721	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	05:47:41	16:51:23	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65851	34
27722	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	05:56:31	16:49:32	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65852	34
27723	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	05:56:30	16:50:49	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65853	34
27724	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	06:00:59	16:50:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65854	34
27725	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	06:22:55	15:50:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:28	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65855	34
27726	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	06:00:03	16:52:33	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65856	34
27727	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	05:52:50	16:52:43	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:00	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65857	34
27728	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	05:45:26	16:53:12	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65858	34
27729	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	05:49:07	17:00:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65859	34
27730	TMNG-202410-013	 JAYMAR MEJOS	MAYA	MAYA, JAYMAR MEJOS	06:02:10	16:51:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65860	34
27731	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	05:46:08	16:50:38	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65861	44
27732	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	06:11:11	16:48:45	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:38	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65862	44
27733	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	06:07:33	16:47:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:40	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65863	44
27734	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	06:32:34	15:48:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:16	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65864	44
27735	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	06:07:21	16:51:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65865	44
27736	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	05:38:31	16:51:50	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:22	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65866	44
27737	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	05:43:12	16:52:07	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:09	00:00	00:00	00:00	00:00	00:17	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65867	44
27738	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	05:46:26	09:32:52	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65868	44
27739	TMNG-202410-063	 CHRISTOPHER MEDEL	MERTOLA	MERTOLA, CHRISTOPHER MEDEL	05:51:48	16:50:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65869	44
27740	TMNG-202510-878	 FRANK JUSTIN MESIA	MERTOLA	MERTOLA, FRANK JUSTIN MESIA	05:57:48	16:51:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65870	45
27741	TMNG-202510-878	 FRANK JUSTIN MESIA	MERTOLA	MERTOLA, FRANK JUSTIN MESIA	06:00:02	16:50:03	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65871	45
27742	TMNG-202510-878	 FRANK JUSTIN MESIA	MERTOLA	MERTOLA, FRANK JUSTIN MESIA	06:10:19	16:50:08	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:40	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65872	45
27743	TMNG-202510-878	 FRANK JUSTIN MESIA	MERTOLA	MERTOLA, FRANK JUSTIN MESIA	06:06:35	16:50:03	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65873	45
27744	TMNG-202510-878	 FRANK JUSTIN MESIA	MERTOLA	MERTOLA, FRANK JUSTIN MESIA	06:43:36	15:50:04	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65874	45
27745	TMNG-202510-878	 FRANK JUSTIN MESIA	MERTOLA	MERTOLA, FRANK JUSTIN MESIA	05:53:10	16:51:54	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65875	45
27746	TMNG-202510-878	 FRANK JUSTIN MESIA	MERTOLA	MERTOLA, FRANK JUSTIN MESIA	05:51:03	16:52:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65876	45
27747	TMNG-202510-878	 FRANK JUSTIN MESIA	MERTOLA	MERTOLA, FRANK JUSTIN MESIA	05:52:19	16:58:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65877	45
27748	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:44:57	16:50:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:15	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65878	24
27749	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:49:36	16:51:34	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65879	24
27750	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:41:17	16:48:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:19	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65880	24
27751	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:54:06	16:47:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65881	24
27752	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	06:17:37	15:48:08	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:31	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65882	24
27753	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:52:37	16:51:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65883	24
27754	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:47:11	16:51:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65884	24
27755	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:58:49	15:55:06	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:56	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65885	24
27756	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:54:14	16:58:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65886	24
27757	TMNG-202410-057	 JULIE SAWKILYO	GONZAGA	GONZAGA, JULIE SAWKILYO	05:56:26	16:50:37	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65887	24
27758	TMNG-202507-547	 NICKSON MODELO	PRESTOZA	PRESTOZA, NICKSON MODELO	05:47:42	16:52:12	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65888	65
27759	TMNG-202507-547	 NICKSON MODELO	PRESTOZA	PRESTOZA, NICKSON MODELO	05:31:57	16:50:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:19	00:00	00:00	00:00	00:00	00:28	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65889	65
27760	TMNG-202507-547	 NICKSON MODELO	PRESTOZA	PRESTOZA, NICKSON MODELO	05:46:06	16:49:23	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65890	65
27761	TMNG-202507-547	 NICKSON MODELO	PRESTOZA	PRESTOZA, NICKSON MODELO	06:09:29	15:49:59	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65891	65
27762	TMNG-202507-547	 NICKSON MODELO	PRESTOZA	PRESTOZA, NICKSON MODELO	05:46:57	16:52:52	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65892	65
27763	TMNG-202507-547	 NICKSON MODELO	PRESTOZA	PRESTOZA, NICKSON MODELO	05:28:43	16:54:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:26	00:00	00:00	00:00	00:00	00:31	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65893	65
27764	TMNG-202507-547	 NICKSON MODELO	PRESTOZA	PRESTOZA, NICKSON MODELO	05:38:46	16:53:52	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:15	00:00	00:00	00:00	00:00	00:21	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65894	65
27765	TMNG-202507-547	 NICKSON MODELO	PRESTOZA	PRESTOZA, NICKSON MODELO	05:27:50	17:00:23	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:32	00:00	00:00	00:00	00:00	00:32	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65895	65
27766	TMNG-202501-411	 KENNETH JAY COLISAO	MOSE	MOSE, KENNETH JAY COLISAO	05:53:52	16:50:31	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65896	61
27767	TMNG-202501-411	 KENNETH JAY COLISAO	MOSE	MOSE, KENNETH JAY COLISAO	05:43:37	16:48:50	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65897	61
27768	TMNG-202501-411	 KENNETH JAY COLISAO	MOSE	MOSE, KENNETH JAY COLISAO	05:56:50	13:11:01	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65898	61
27769	TMNG-202501-411	 KENNETH JAY COLISAO	MOSE	MOSE, KENNETH JAY COLISAO	05:47:49	16:58:18	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:12	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65899	61
27770	TMNG-202501-411	 KENNETH JAY COLISAO	MOSE	MOSE, KENNETH JAY COLISAO	06:04:27	16:50:25	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65900	61
27771	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:43:22	16:56:07	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:17	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65901	43
27772	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:43:56	16:55:06	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65902	43
27773	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:42:14	16:54:57	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:18	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65903	43
27774	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:49:36	16:52:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65904	43
27775	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	06:47:52	15:53:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:06	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65905	43
27776	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:48:39	16:54:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65906	43
27777	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:46:54	16:56:07	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:09	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65907	43
27778	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:49:26	16:53:43	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65908	43
27779	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:44:26	17:02:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:18	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65909	43
27780	TMNG-202410-166	 PATRICK MADARANG	MENES	MENES, PATRICK MADARANG	05:51:55	16:55:19	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65910	43
27781	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:51:39	16:52:06	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65911	15
27782	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:43:50	16:52:31	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65912	15
27783	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:44:29	16:49:14	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65913	15
27784	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:47:32	16:50:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65914	15
27785	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	06:04:25	15:51:37	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65915	15
27786	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:52:21	16:52:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65916	15
27787	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:45:19	16:53:13	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65917	15
27788	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:45:54	16:54:38	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:09	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65918	15
27789	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:44:55	16:58:49	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:15	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65919	15
27790	TMNG-202410-007	 JEFFREY MISTA	BORLAZA	BORLAZA, JEFFREY MISTA	05:49:10	16:54:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65920	15
27791	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	05:47:23	16:50:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65921	54
27792	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	05:51:40	16:50:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:59	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65922	54
27793	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	05:44:19	16:48:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65923	54
27794	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	05:49:51	16:48:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65924	54
27795	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	06:30:46	15:48:28	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:18	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65925	54
27796	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	05:41:30	16:51:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:19	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65926	54
27797	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	05:47:22	16:52:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65927	54
27798	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	05:52:15	16:59:04	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65928	54
27799	TMNG-202410-006	 REYNALD RACRAQUIN	MODELO	MODELO, REYNALD RACRAQUIN	06:29:16	16:50:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:22	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65929	54
27800	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	05:46:20	16:52:20	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65930	58
27801	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	05:51:15	16:48:57	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65931	58
27802	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	05:49:10	16:49:41	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65932	58
27803	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	05:56:48	16:49:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65933	58
27804	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	06:31:00	15:48:56	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:18	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65934	58
27805	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	05:35:34	16:53:27	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:18	00:00	00:00	00:00	00:00	00:25	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65935	58
27806	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	05:41:37	16:55:34	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:19	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65936	58
27807	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	05:40:17	16:59:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:19	00:00	00:00	00:00	00:00	00:20	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65937	58
27808	TMNG-202502-443	 JOE BERT ABAT	MONTERO	MONTERO, JOE BERT ABAT	05:51:25	16:54:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:03	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65938	58
27809	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	05:44:05	16:51:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65939	14
27810	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	06:01:23	16:49:25	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65940	14
27811	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	05:57:50	16:48:42	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:51	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65941	14
27812	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	06:03:09	16:47:39	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65942	14
27813	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	06:38:57	15:49:05	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65943	14
27814	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	05:24:04	16:52:29	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:28	00:00	00:00	00:00	00:00	00:36	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65944	14
27815	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	05:46:59	16:52:38	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65945	14
27816	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	05:42:07	16:52:14	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:18	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65946	14
27817	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	05:41:52	17:00:51	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:19	00:00	00:00	00:00	00:00	00:18	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65947	14
27818	TMNG-202504-492	 REY MIRADOR	BERUNIO	BERUNIO, REY MIRADOR	06:08:35	16:51:32	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65948	14
27819	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	05:44:01	16:51:19	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65949	36
27820	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	06:01:19	16:49:21	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65950	36
27821	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	05:57:36	16:49:21	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65951	36
27822	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	06:03:15	16:49:35	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65952	36
27823	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	06:39:22	15:51:04	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:12	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65953	36
27824	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	05:24:17	16:52:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:28	00:00	00:00	00:00	00:00	00:36	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65954	36
27825	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	05:46:48	16:53:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65955	36
27826	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	05:41:56	16:52:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:18	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65956	36
27827	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	05:41:46	16:59:40	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:18	00:00	00:00	00:00	00:00	00:18	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65957	36
27828	TMNG-202410-081	 REYNALD MACALTAO	MAYO	MAYO, REYNALD MACALTAO	06:17:43	16:51:48	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:34	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65958	36
27829	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:42:38	16:55:27	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:17	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65959	30
27830	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:47:19	16:55:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65960	30
27831	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:49:26	16:54:04	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65961	30
27832	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:48:07	16:55:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:12	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65962	30
27833	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	06:29:43	15:51:23	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:22	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65963	30
27834	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:49:28	16:53:44	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65964	30
27835	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:45:11	16:55:54	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:15	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65965	30
27836	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:40:05	16:54:11	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:20	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65966	30
27837	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:44:43	17:01:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:17	00:00	00:00	00:00	00:00	00:15	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65967	30
27838	TMNG-202505-524	 APOLLO MOVILLA	MARTICIO	MARTICIO, APOLLO MOVILLA	05:50:14	16:54:30	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65968	30
27839	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:45:05	16:55:41	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:15	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65969	16
27840	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:32:50	16:50:55	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:18	00:00	00:00	00:00	00:00	00:27	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65970	16
27841	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:42:57	16:50:25	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:17	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65971	16
27842	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:47:16	16:50:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65972	16
27843	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:54:07	16:54:21	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:00	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65973	16
27844	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:46:11	16:55:50	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65974	16
27845	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:44:02	16:55:02	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:16	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65975	16
27846	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:47:11	17:01:27	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65976	16
27847	TMNG-202410-020	 GEORGE JR. MARTICIO	BUSTAMANTE	BUSTAMANTE, GEORGE JR. MARTICIO	05:50:32	11:07:08	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65977	16
27848	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	06:58:52	17:52:50	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65978	504
27849	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	06:58:09	17:50:22	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65979	504
27850	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	07:01:17	17:47:44	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65980	504
27851	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	06:56:04	17:49:40	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65981	504
27852	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	06:58:43	15:50:35	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65982	504
27853	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	03:45:48	15:43:36	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:58	00:00	00:00	00:00	00:00	02:14	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65983	504
27854	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	03:57:47	15:33:40	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:36	00:00	00:00	00:00	00:00	02:02	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65984	504
27855	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	03:59:35	15:36:05	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:37	00:00	00:00	00:00	00:00	02:01	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65985	504
27856	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	03:57:54	15:52:04	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:54	00:00	00:00	00:00	00:00	02:02	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65986	504
27857	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	04:18:17	15:26:42	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	01:42	00:00	0	f	0	0	\N	2026-08-21 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65987	504
27858	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	04:13:53	15:42:47	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:29	00:00	00:00	00:00	00:00	01:46	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65988	504
27859	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	03:52:52	16:08:36	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:16	00:00	00:00	00:00	00:00	02:07	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65989	504
27860	TMNG-202208-236	 MARICEL MONTEJO	MERCED	MERCED, MARICEL MONTEJO	03:47:10	15:10:42	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	02:23	00:00	00:00	00:00	00:00	02:13	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65990	504
27861	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	12:41:56	22:02:57	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:21	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65991	290
27862	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	12:53:30	22:02:11	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:08	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65992	290
27863	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	13:10:34	22:13:53	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:04	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65993	290
27864	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	12:59:38	22:02:25	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:03	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65994	290
27865	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	13:06:51	22:00:56	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65995	290
27866	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	13:05:34	22:03:34	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65996	290
27867	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	13:02:04	22:00:20	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65997	290
27868	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	13:08:17	22:02:33	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-23 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65998	290
27869	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	13:11:11	22:00:36	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	65999	290
27870	TMNG-202208-083	 ANGELICA MAY MEROY	MADARANG	MADARANG, ANGELICA MAY MEROY	13:03:30	22:01:03	ord	LABORATORY	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:01	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66000	290
27899	TMNG-202508-554	 FREDDIE VALENTINO	PULIDO	PULIDO, FREDDIE VALENTINO	06:52:39	18:00:10	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66029	257
27900	TMNG-202508-554	 FREDDIE VALENTINO	PULIDO	PULIDO, FREDDIE VALENTINO	06:58:59	16:01:46	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:03	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66030	257
27901	TMNG-202508-554	 FREDDIE VALENTINO	PULIDO	PULIDO, FREDDIE VALENTINO	06:54:13	18:00:02	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66031	257
27902	TMNG-202508-554	 FREDDIE VALENTINO	PULIDO	PULIDO, FREDDIE VALENTINO	06:41:01	18:02:25	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:22	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66032	257
27903	TMNG-202508-554	 FREDDIE VALENTINO	PULIDO	PULIDO, FREDDIE VALENTINO	06:53:42	18:00:02	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66033	257
27904	TMNG-202508-554	 FREDDIE VALENTINO	PULIDO	PULIDO, FREDDIE VALENTINO	06:47:19	18:00:51	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66034	257
27905	TMNG-202508-554	 FREDDIE VALENTINO	PULIDO	PULIDO, FREDDIE VALENTINO	06:57:01	18:03:59	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:07	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66035	257
27906	TMNG-202508-554	 FREDDIE VALENTINO	PULIDO	PULIDO, FREDDIE VALENTINO	06:54:43	18:00:21	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-25 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66036	257
27907	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	07:08:52	17:50:56	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:42	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66037	89
27908	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	07:03:21	17:48:48	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66038	89
27909	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	07:06:09	17:50:43	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66039	89
27910	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	07:25:50	17:51:21	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:26	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66040	89
27911	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	07:36:16	15:52:23	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66041	89
27912	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	07:19:40	17:51:09	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:31	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66042	89
27913	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	07:10:21	17:51:25	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:41	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66043	89
27914	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	07:16:20	17:50:57	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:35	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66044	89
27915	TMNG-202509-648	 JOAQUIN YANGGA	ORINIO	ORINIO, JOAQUIN YANGGA	06:59:03	19:17:29	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	03:19	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66045	89
27916	TMNG-202509-643	 RUSSEL LEE MENDOZA	MAYPAY	MAYPAY, RUSSEL LEE MENDOZA	06:53:56	17:50:21	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66046	84
27917	TMNG-202509-643	 RUSSEL LEE MENDOZA	MAYPAY	MAYPAY, RUSSEL LEE MENDOZA	06:56:55	17:49:24	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66047	84
27918	TMNG-202509-643	 RUSSEL LEE MENDOZA	MAYPAY	MAYPAY, RUSSEL LEE MENDOZA	06:56:19	17:49:14	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66048	84
27919	TMNG-202509-643	 RUSSEL LEE MENDOZA	MAYPAY	MAYPAY, RUSSEL LEE MENDOZA	06:57:13	17:50:54	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66049	84
27920	TMNG-202509-643	 RUSSEL LEE MENDOZA	MAYPAY	MAYPAY, RUSSEL LEE MENDOZA	06:55:07	17:50:52	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66050	84
27921	TMNG-202509-643	 RUSSEL LEE MENDOZA	MAYPAY	MAYPAY, RUSSEL LEE MENDOZA	06:56:46	17:50:48	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66051	84
27922	TMNG-202509-643	 RUSSEL LEE MENDOZA	MAYPAY	MAYPAY, RUSSEL LEE MENDOZA	06:55:01	17:49:38	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66052	84
27923	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	05:40:38	16:54:28	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:19	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66053	53
27924	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	05:46:05	16:55:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:09	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66054	53
27925	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	05:55:40	16:51:08	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66055	53
27926	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	05:58:17	16:48:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:02	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66056	53
27927	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	06:30:50	15:51:49	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:21	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66057	53
27928	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	06:05:23	16:53:06	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66058	53
27929	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	06:02:39	16:55:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66059	53
27930	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	05:53:02	16:54:26	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66060	53
27931	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	05:49:37	17:01:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66061	53
27932	TMNG-202410-061	 LORIMO RACRAQUIN	MODELO	MODELO, LORIMO RACRAQUIN	06:08:39	16:51:24	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66062	53
27933	TMNG-202410-156	 CARL JUSTIN MOSE	SARMIENTO	SARMIENTO, CARL JUSTIN MOSE	05:54:39	16:56:13	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66063	70
27934	TMNG-202410-156	 CARL JUSTIN MOSE	SARMIENTO	SARMIENTO, CARL JUSTIN MOSE	05:54:42	16:55:36	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66064	70
27935	TMNG-202410-156	 CARL JUSTIN MOSE	SARMIENTO	SARMIENTO, CARL JUSTIN MOSE	05:56:50	16:55:10	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66065	70
27936	TMNG-202410-156	 CARL JUSTIN MOSE	SARMIENTO	SARMIENTO, CARL JUSTIN MOSE	06:02:46	16:58:38	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66066	70
27937	TMNG-202410-156	 CARL JUSTIN MOSE	SARMIENTO	SARMIENTO, CARL JUSTIN MOSE	05:57:06	16:52:22	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66067	70
27938	TMNG-202410-156	 CARL JUSTIN MOSE	SARMIENTO	SARMIENTO, CARL JUSTIN MOSE	05:48:02	16:59:51	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:12	00:00	00:00	00:00	00:00	00:12	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66068	70
27939	TMNG-202410-156	 CARL JUSTIN MOSE	SARMIENTO	SARMIENTO, CARL JUSTIN MOSE	06:05:21	16:54:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66069	70
27940	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	06:01:50	16:52:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66070	42
27941	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	05:53:54	16:49:09	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66071	42
27942	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	06:16:59	16:48:28	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:31	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66072	42
27943	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	06:40:58	15:49:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	00:09	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66073	42
27944	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	05:56:05	16:53:15	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:45	2026-09-22 15:04:45	\N	\N	14	\N	66074	42
27945	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	05:53:36	16:54:19	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:01	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66075	42
27946	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	05:56:45	16:52:32	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66076	42
27947	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	05:52:09	17:00:08	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66077	42
27948	TMNG-202410-040	 ARMAN MODELO	MENDI	MENDI, ARMAN MODELO	06:14:16	16:50:16	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:36	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66078	42
27949	TMNG-202409-120	 JINNO ALBA	INTERNO	INTERNO, JINNO ALBA	06:53:41	15:48:32	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66079	450
27950	TMNG-202409-120	 JINNO ALBA	INTERNO	INTERNO, JINNO ALBA	06:30:05	15:49:29	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:19	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66080	450
27951	TMNG-202409-120	 JINNO ALBA	INTERNO	INTERNO, JINNO ALBA	06:37:22	15:48:02	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:11	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66081	450
27952	TMNG-202403-001	 DARWIN CASUPANAN	DELA CRUZ	DELA CRUZ, DARWIN CASUPANAN	06:10:50	20:46:12	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	05:35	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66082	476
27953	TMNG-202403-001	 DARWIN CASUPANAN	DELA CRUZ	DELA CRUZ, DARWIN CASUPANAN	06:11:10	14:34:49	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66083	476
27954	TMNG-202403-001	 DARWIN CASUPANAN	DELA CRUZ	DELA CRUZ, DARWIN CASUPANAN	06:03:16	19:21:33	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:18	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66084	476
27955	TMNG-202403-001	 DARWIN CASUPANAN	DELA CRUZ	DELA CRUZ, DARWIN CASUPANAN	06:08:31	17:00:07	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66085	476
27956	TMNG-202403-001	 DARWIN CASUPANAN	DELA CRUZ	DELA CRUZ, DARWIN CASUPANAN	06:12:22	19:11:35	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:59	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66086	476
27957	TMNG-202403-001	 DARWIN CASUPANAN	DELA CRUZ	DELA CRUZ, DARWIN CASUPANAN	06:11:12	19:03:42	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66087	476
27958	TMNG-202403-001	 DARWIN CASUPANAN	DELA CRUZ	DELA CRUZ, DARWIN CASUPANAN	06:07:23	15:03:14	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-21 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66088	476
27959	TMNG-202403-001	 DARWIN CASUPANAN	DELA CRUZ	DELA CRUZ, DARWIN CASUPANAN	06:13:16	18:36:28	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:23	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66089	476
27960	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:21:39	17:58:00	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:37	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66090	87
27961	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:24:24	18:00:14	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:36	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66091	87
27962	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:13:43	17:59:04	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:46	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66092	87
27963	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:21:38	17:57:26	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:36	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66093	87
27964	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:33:34	16:00:37	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66094	87
27965	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:22:05	18:00:19	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:38	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66095	87
27966	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:20:21	18:00:26	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:40	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66096	87
27967	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:15:21	18:00:08	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:45	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66097	87
27968	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:16:08	18:00:21	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66098	87
27969	TMNG-202509-646	 OLIVER MAS	MONTEVIRGEN	MONTEVIRGEN, OLIVER MAS	07:15:47	18:00:34	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	01:45	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66099	87
27970	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	07:07:11	18:07:11	ord	MEPED	LAMI Mining Site	\N	7-16	02:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66100	349
27971	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	07:02:08	17:50:47	ord	MEPED	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66101	349
27972	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	06:56:26	17:48:31	ord	MEPED	LAMI Mining Site	\N	7-16	01:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66102	349
27973	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	07:00:36	17:49:11	ord	MEPED	LAMI Mining Site	\N	7-16	01:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66103	349
27974	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	06:57:07	15:49:19	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66104	349
27975	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	07:25:13	17:50:45	ord	MEPED	LAMI Mining Site	\N	7-16	01:26	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66105	349
27976	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	06:55:12	17:50:48	ord	MEPED	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66106	349
27977	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	06:56:57	17:50:28	ord	MEPED	LAMI Mining Site	\N	7-16	01:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66107	349
27978	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	07:08:45	17:51:07	ord	MEPED	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66108	349
27979	TMNG-202208-064	 MARVIN CALVO	TUPIG	TUPIG, MARVIN CALVO	07:07:11	17:50:53	ord	MEPED	LAMI Mining Site	\N	7-16	01:44	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66109	349
27980	TMNG-202510-918	 MICHAEL MERTOLA	BARTOLATA	BARTOLATA, MICHAEL MERTOLA	05:54:54	16:49:45	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66110	12
27981	TMNG-202510-918	 MICHAEL MERTOLA	BARTOLATA	BARTOLATA, MICHAEL MERTOLA	05:49:31	16:51:33	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:02	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66111	12
27982	TMNG-202510-918	 MICHAEL MERTOLA	BARTOLATA	BARTOLATA, MICHAEL MERTOLA	05:53:56	16:51:47	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:58	00:00	00:00	00:00	00:00	00:06	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66112	12
27983	TMNG-202510-918	 MICHAEL MERTOLA	BARTOLATA	BARTOLATA, MICHAEL MERTOLA	06:06:06	16:53:05	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66113	12
27984	TMNG-202510-918	 MICHAEL MERTOLA	BARTOLATA	BARTOLATA, MICHAEL MERTOLA	05:48:35	16:58:59	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	02:10	00:00	00:00	00:00	00:00	00:11	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66114	12
27985	TMNG-202510-918	 MICHAEL MERTOLA	BARTOLATA	BARTOLATA, MICHAEL MERTOLA	06:22:22	16:54:37	ord	EXPLORATION AND MINE GEOLOGY	LAMI Mining Site	\N	7-16	01:32	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66115	12
27986	TMNG-202509-602	 JAMES MILITAR	MOVILLA	MOVILLA, JAMES MILITAR	06:21:36	17:50:35	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:29	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66116	243
27987	TMNG-202509-602	 JAMES MILITAR	MOVILLA	MOVILLA, JAMES MILITAR	06:28:05	17:50:12	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:22	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66117	243
27988	TMNG-202509-602	 JAMES MILITAR	MOVILLA	MOVILLA, JAMES MILITAR	06:37:38	16:01:23	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:24	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-24 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66118	243
27989	TMNG-202310-033	 LAURENCE MANAPAT	LUCING	LUCING, LAURENCE MANAPAT	07:05:00	16:03:55	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66119	451
27990	TMNG-202310-033	 LAURENCE MANAPAT	LUCING	LUCING, LAURENCE MANAPAT	07:16:16	15:54:59	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66120	451
27991	TMNG-202310-033	 LAURENCE MANAPAT	LUCING	LUCING, LAURENCE MANAPAT	07:10:12	15:59:49	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-21 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66121	451
27992	TMNG-202310-033	 LAURENCE MANAPAT	LUCING	LUCING, LAURENCE MANAPAT	07:06:41	15:55:06	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66122	451
27993	TMNG-202310-033	 LAURENCE MANAPAT	LUCING	LUCING, LAURENCE MANAPAT	07:18:40	15:55:38	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-23 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66123	451
27994	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	06:01:06	19:00:56	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66124	484
27995	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	05:56:35	18:57:21	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:01	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66125	484
27996	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	06:02:31	19:00:17	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:58	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66126	484
27997	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	06:07:06	18:57:32	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66127	484
27998	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	06:05:44	17:02:31	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66128	484
27999	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	06:14:01	18:56:22	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66129	484
28000	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	06:08:30	18:57:04	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66130	484
28001	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	06:02:59	18:56:26	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:53	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66131	484
28002	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	06:04:01	19:00:06	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	03:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66132	484
28003	TMNG-202403-008	 REY ANGELO MEROY	MUYANO	MUYANO, REY ANGELO MEROY	05:56:50	17:10:00	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	02:13	00:00	00:00	00:00	00:00	00:03	00:00	0	f	0	0	\N	2026-08-22 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66133	484
28004	TMNG-202509-572	 JOEL MANUEL	MUYANO	MUYANO, JOEL MANUEL	06:08:39	18:56:10	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66134	251
28005	TMNG-202509-572	 JOEL MANUEL	MUYANO	MUYANO, JOEL MANUEL	05:51:50	18:54:05	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	04:02	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66135	251
28006	TMNG-202509-572	 JOEL MANUEL	MUYANO	MUYANO, JOEL MANUEL	05:54:45	18:52:58	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:58	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66136	251
28007	TMNG-202509-572	 JOEL MANUEL	MUYANO	MUYANO, JOEL MANUEL	05:51:12	18:34:44	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:44	00:00	00:00	00:00	00:00	00:09	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66137	251
28008	TMNG-202509-574	 MANNY MAESTRE	MADREO	MADREO, MANNY MAESTRE	06:03:36	18:55:37	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:52	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66138	154
28009	TMNG-202509-574	 MANNY MAESTRE	MADREO	MADREO, MANNY MAESTRE	06:05:24	18:53:58	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:49	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66139	154
28010	TMNG-202509-574	 MANNY MAESTRE	MADREO	MADREO, MANNY MAESTRE	06:05:06	18:52:40	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66140	154
28011	TMNG-202509-574	 MANNY MAESTRE	MADREO	MADREO, MANNY MAESTRE	06:01:16	18:34:27	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:33	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66141	154
28012	TMNG-202509-622	 ELAINE BANTOLINO	APAREJADO	APAREJADO, ELAINE BANTOLINO	07:13:40	17:51:18	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:38	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66142	102
28013	TMNG-202509-622	 ELAINE BANTOLINO	APAREJADO	APAREJADO, ELAINE BANTOLINO	07:02:41	17:53:14	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66143	102
28014	TMNG-202509-622	 ELAINE BANTOLINO	APAREJADO	APAREJADO, ELAINE BANTOLINO	07:08:21	17:51:16	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66144	102
28015	TMNG-202509-622	 ELAINE BANTOLINO	APAREJADO	APAREJADO, ELAINE BANTOLINO	07:15:51	17:51:51	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:36	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66145	102
28016	TMNG-202509-621	 IVY JOY MOVILLA	BONCATO	BONCATO, IVY JOY MOVILLA	07:07:58	17:51:14	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:43	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66146	115
28017	TMNG-202509-621	 IVY JOY MOVILLA	BONCATO	BONCATO, IVY JOY MOVILLA	06:58:05	17:53:11	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66147	115
28018	TMNG-202509-621	 IVY JOY MOVILLA	BONCATO	BONCATO, IVY JOY MOVILLA	06:57:24	17:51:11	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:54	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66148	115
28019	TMNG-202509-621	 IVY JOY MOVILLA	BONCATO	BONCATO, IVY JOY MOVILLA	07:04:48	17:51:18	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:47	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66149	115
28020	TMNG-202510-670	 SAMUEL BUSTAMANTE	GINEZ	GINEZ, SAMUEL BUSTAMANTE	05:49:38	17:49:51	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:00	00:00	00:00	00:00	00:00	00:10	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66150	2
28021	TMNG-202510-670	 SAMUEL BUSTAMANTE	GINEZ	GINEZ, SAMUEL BUSTAMANTE	05:45:31	17:51:34	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:06	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66151	2
28022	TMNG-202510-670	 SAMUEL BUSTAMANTE	GINEZ	GINEZ, SAMUEL BUSTAMANTE	05:46:20	17:50:23	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:04	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66152	2
28023	TMNG-202510-670	 SAMUEL BUSTAMANTE	GINEZ	GINEZ, SAMUEL BUSTAMANTE	05:46:08	17:49:13	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:03	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66153	2
28024	TMNG-202510-999	 EUGENE ANQUILLIANO	ALVAREZ	ALVAREZ, EUGENE ANQUILLIANO	05:25:08	17:50:03	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:25	00:00	00:00	00:00	00:00	00:35	00:00	0	f	0	0	\N	2026-08-17 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66154	1
28025	TMNG-202510-999	 EUGENE ANQUILLIANO	ALVAREZ	ALVAREZ, EUGENE ANQUILLIANO	05:33:29	17:50:22	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:17	00:00	00:00	00:00	00:00	00:26	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66155	1
28026	TMNG-202510-999	 EUGENE ANQUILLIANO	ALVAREZ	ALVAREZ, EUGENE ANQUILLIANO	05:39:30	17:50:07	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:11	00:00	00:00	00:00	00:00	00:20	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66156	1
28027	TMNG-202510-999	 EUGENE ANQUILLIANO	ALVAREZ	ALVAREZ, EUGENE ANQUILLIANO	05:36:21	17:49:09	ord	ADMINISTRATIVE SERVICES	LAMI Mining Site	\N	7-16	03:13	00:00	00:00	00:00	00:00	00:23	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66157	1
28028	TMNG-202510-863	 JAY PEE OCLIMA	MINIMO	MINIMO, JAY PEE OCLIMA	07:03:32	16:00:12	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66158	337
28029	TMNG-202510-863	 JAY PEE OCLIMA	MINIMO	MINIMO, JAY PEE OCLIMA	07:03:20	16:01:58	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66159	337
28030	TMNG-202510-863	 JAY PEE OCLIMA	MINIMO	MINIMO, JAY PEE OCLIMA	07:13:04	11:10:05	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66160	337
28031	TMNG-202510-853	 MARDY CONRADA	MADREO	MADREO, MARDY CONRADA	07:03:38	16:00:06	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66161	327
28032	TMNG-202510-853	 MARDY CONRADA	MADREO	MADREO, MARDY CONRADA	07:06:49	16:02:15	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66162	327
28033	TMNG-202510-853	 MARDY CONRADA	MADREO	MADREO, MARDY CONRADA	07:12:57	11:09:59	ord	MEPED	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-20 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66163	327
28034	TMNG-202509-637	 DARYL SAGUN	ELAIDA	ELAIDA, DARYL SAGUN	06:46:55	17:51:18	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:04	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-15 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66164	79
28035	TMNG-202509-637	 DARYL SAGUN	ELAIDA	ELAIDA, DARYL SAGUN	06:49:04	15:54:57	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	00:06	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-16 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66165	79
28036	TMNG-202509-637	 DARYL SAGUN	ELAIDA	ELAIDA, DARYL SAGUN	06:44:55	17:53:27	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:08	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-18 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66166	79
28037	TMNG-202509-637	 DARYL SAGUN	ELAIDA	ELAIDA, DARYL SAGUN	06:40:49	17:51:19	ord	FLEET MAINTENANCE	LAMI Mining Site	\N	7-16	02:11	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-19 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66167	79
28038	TMNG-202403-003	 VALENTINO VALLEJO	LAGUISMA	LAGUISMA, VALENTINO VALLEJO	05:47:10	19:01:04	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:14	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66168	478
28039	TMNG-202403-003	 VALENTINO VALLEJO	LAGUISMA	LAGUISMA, VALENTINO VALLEJO	05:42:11	19:01:07	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:19	00:00	00:00	00:00	00:00	00:18	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66169	478
28040	TMNG-202403-003	 VALENTINO VALLEJO	LAGUISMA	LAGUISMA, VALENTINO VALLEJO	05:41:35	19:04:37	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:23	00:00	00:00	00:00	00:00	00:19	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66170	478
28041	TMNG-202403-003	 VALENTINO VALLEJO	LAGUISMA	LAGUISMA, VALENTINO VALLEJO	05:46:25	19:01:43	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	04:16	00:00	00:00	00:00	00:00	00:14	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66171	478
28042	TMNG-202403-003	 VALENTINO VALLEJO	LAGUISMA	LAGUISMA, VALENTINO VALLEJO	05:47:38	17:05:15	ord	OFFICE OF THE RESIDENT MANAGER	LAMI Mining Site	\N	7-16	02:17	00:00	00:00	00:00	00:00	00:13	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66172	478
28043	TMNG-202509-654	 EFREN JR. EBEN	BALELIN	BALELIN, EFREN JR. EBEN	05:52:11	18:48:14	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:56	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66173	107
28044	TMNG-202509-654	 EFREN JR. EBEN	BALELIN	BALELIN, EFREN JR. EBEN	05:55:19	18:45:59	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:50	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66174	107
28045	TMNG-202509-654	 EFREN JR. EBEN	BALELIN	BALELIN, EFREN JR. EBEN	05:52:18	18:46:20	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:54	00:00	00:00	00:00	00:00	00:08	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66175	107
28046	TMNG-202509-654	 EFREN JR. EBEN	BALELIN	BALELIN, EFREN JR. EBEN	05:52:45	18:39:48	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:47	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66176	107
28047	TMNG-202509-654	 EFREN JR. EBEN	BALELIN	BALELIN, EFREN JR. EBEN	05:52:45	16:43:20	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:50	00:00	00:00	00:00	00:00	00:07	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66177	107
28048	TMNG-202509-656	 MARK MENOR	LAZARO	LAZARO, MARK MENOR	05:55:26	18:47:46	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:52	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66178	149
28049	TMNG-202509-656	 MARK MENOR	LAZARO	LAZARO, MARK MENOR	05:56:10	18:45:41	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:50	00:00	00:00	00:00	00:00	00:04	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66179	149
28050	TMNG-202509-656	 MARK MENOR	LAZARO	LAZARO, MARK MENOR	05:47:43	18:46:05	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:58	00:00	00:00	00:00	00:00	00:12	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66180	149
28051	TMNG-202509-656	 MARK MENOR	LAZARO	LAZARO, MARK MENOR	06:01:29	18:39:32	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	03:38	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66181	149
28052	TMNG-202509-656	 MARK MENOR	LAZARO	LAZARO, MARK MENOR	05:54:52	16:43:00	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:48	00:00	00:00	00:00	00:00	00:05	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66182	149
28053	TMNG-202509-575	 DOMINADOR JR. MIANO	MOSE	MOSE, DOMINADOR JR. MIANO	07:08:09	16:00:20	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66183	237
28054	TMNG-202509-575	 DOMINADOR JR. MIANO	MOSE	MOSE, DOMINADOR JR. MIANO	06:50:10	16:00:03	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66184	237
28055	TMNG-202509-575	 DOMINADOR JR. MIANO	MOSE	MOSE, DOMINADOR JR. MIANO	07:03:34	15:58:27	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66185	237
28056	TMNG-202509-575	 DOMINADOR JR. MIANO	MOSE	MOSE, DOMINADOR JR. MIANO	06:51:19	15:53:06	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:02	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66186	237
28057	TMNG-202509-578	 JOSEPH MENES	METANTE	METANTE, JOSEPH MENES	06:44:59	16:00:07	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:15	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66187	217
28058	TMNG-202509-578	 JOSEPH MENES	METANTE	METANTE, JOSEPH MENES	06:49:53	15:59:59	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:10	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66188	217
28059	TMNG-202509-578	 JOSEPH MENES	METANTE	METANTE, JOSEPH MENES	06:47:17	15:58:38	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:11	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66189	217
28060	TMNG-202509-578	 JOSEPH MENES	METANTE	METANTE, JOSEPH MENES	06:51:32	15:53:02	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:02	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66190	217
28061	TMNG-202509-580	 GERI MARAVE	MARAVE	MARAVE, GERI MARAVE	06:19:37	17:51:18	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:32	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66191	161
28062	TMNG-202509-580	 GERI MARAVE	MARAVE	MARAVE, GERI MARAVE	06:36:25	17:50:38	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:14	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66192	161
28063	TMNG-202509-580	 GERI MARAVE	MARAVE	MARAVE, GERI MARAVE	06:38:43	17:50:39	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:12	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66193	161
28064	TMNG-202509-580	 GERI MARAVE	MARAVE	MARAVE, GERI MARAVE	06:53:25	17:50:11	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:57	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66194	161
28065	TMNG-202509-580	 GERI MARAVE	MARAVE	MARAVE, GERI MARAVE	06:51:12	15:52:18	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:01	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66195	161
28066	TMNG-202509-563	 JEFFRY MELANIO	DAYAG	DAYAG, JEFFRY MELANIO	07:09:29	17:51:14	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:42	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66196	126
28067	TMNG-202509-563	 JEFFRY MELANIO	DAYAG	DAYAG, JEFFRY MELANIO	06:56:24	17:51:27	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:55	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66197	126
28068	TMNG-202509-563	 JEFFRY MELANIO	DAYAG	DAYAG, JEFFRY MELANIO	07:10:10	17:49:06	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:39	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66198	126
28069	TMNG-202509-563	 JEFFRY MELANIO	DAYAG	DAYAG, JEFFRY MELANIO	07:14:21	17:50:14	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:36	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66199	126
28070	TMNG-202509-563	 JEFFRY MELANIO	DAYAG	DAYAG, JEFFRY MELANIO	07:12:51	15:51:36	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66200	126
28071	TMNG-202509-579	 JESS MIANO	MOSE	MOSE, JESS MIANO	06:52:56	13:51:13	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66201	238
28072	TMNG-202509-579	 JESS MIANO	MOSE	MOSE, JESS MIANO	06:44:32	17:49:36	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:05	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66202	238
28073	TMNG-202509-579	 JESS MIANO	MOSE	MOSE, JESS MIANO	06:42:51	17:49:08	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	02:06	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66203	238
28074	TMNG-202509-579	 JESS MIANO	MOSE	MOSE, JESS MIANO	06:52:49	17:49:06	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	01:56	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-13 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66204	238
28075	TMNG-202509-579	 JESS MIANO	MOSE	MOSE, JESS MIANO	06:54:32	15:49:36	ord	FLEET OPERATIONS	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-14 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66205	238
28076	TMNG-202510-887	 JOHN LUIS MOVILLA	VILLAFLORES	VILLAFLORES, JOHN LUIS MOVILLA	06:54:48	15:48:38	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-10 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66206	457
28077	TMNG-202510-887	 JOHN LUIS MOVILLA	VILLAFLORES	VILLAFLORES, JOHN LUIS MOVILLA	06:56:08	15:49:36	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:00	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-11 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66207	457
28078	TMNG-202510-887	 JOHN LUIS MOVILLA	VILLAFLORES	VILLAFLORES, JOHN LUIS MOVILLA	06:47:31	15:48:08	ord	MINE ENGINEERING	LAMI Mining Site	\N	7-16	00:01	00:00	00:00	00:00	00:00	00:00	00:00	0	f	0	0	\N	2026-08-12 00:00:00	Pending	2026-09-22 15:04:46	2026-09-22 15:04:46	\N	\N	14	\N	66208	457
\.


--
-- Data for Name: password_resets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_resets (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schedule_adjustments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schedule_adjustments (id, earliest_time, latest_time, attendance_area, late, late_hours, late_minutes, approval_status, action, record_date, employee_management_id, total_non_working_days_present, schedule, out_time_required, others, reason, weekday, updated_at, created_at, biometric_imports_id, attendance_records_id) FROM stdin;
1	\N	\N	\N	\N	\N	\N	Pending	\N	2025-11-20 00:00:00	93	\N	7-16	\N	Sched adjust	\N	\N	2025-11-28 13:41:23	2025-11-28 13:41:23	\N	\N
2	\N	\N	\N	\N	\N	\N	Cancelled	\N	2025-11-11 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-15 09:37:44	2025-12-15 09:34:29	\N	\N
19	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-12 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:27:42	2025-12-19 09:27:31	\N	\N
26	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-19 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:32	2025-12-19 09:27:31	\N	\N
33	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-12 00:00:00	485	\N	6-15	\N	\N	\N	\N	2025-12-19 09:47:23	2025-12-19 09:43:20	\N	\N
46	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-20 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:17	2025-12-19 10:01:20	\N	\N
51	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-25 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:43	2025-12-19 10:01:20	\N	\N
53	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-25 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:23	2026-01-16 09:29:16	\N	\N
60	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-20 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:53	2026-01-16 09:30:28	\N	\N
35	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-14 00:00:00	485	\N	6-15	\N	\N	\N	\N	2025-12-19 09:47:38	2025-12-19 09:43:20	\N	\N
16	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-24 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:22:22	2025-12-19 08:40:40	\N	\N
27	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-20 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:37	2025-12-19 09:27:31	\N	\N
14	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-22 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:22:12	2025-12-19 08:40:09	\N	\N
23	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-16 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:16	2025-12-19 09:27:31	\N	\N
38	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-12 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:01:33	2025-12-19 10:01:20	\N	\N
37	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-11 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:01:28	2025-12-19 10:01:20	\N	\N
55	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-15 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:32	2026-01-16 09:30:28	\N	\N
41	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-15 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:01:48	2025-12-19 10:01:20	\N	\N
13	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-21 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:22:08	2025-12-19 08:40:09	\N	\N
36	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-15 00:00:00	485	\N	6-15	\N	\N	\N	\N	2025-12-19 09:47:42	2025-12-19 09:43:20	\N	\N
24	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-17 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:21	2025-12-19 09:27:31	\N	\N
57	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-17 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:40	2026-01-16 09:30:28	\N	\N
43	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-17 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:00	2025-12-19 10:01:20	\N	\N
22	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-15 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:27:57	2025-12-19 09:27:31	\N	\N
21	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-14 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:27:52	2025-12-19 09:27:31	\N	\N
17	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-25 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:22:26	2025-12-19 09:21:30	\N	\N
11	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-18 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:21:58	2025-12-19 08:38:03	\N	\N
64	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-24 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:32:10	2026-01-16 09:30:28	\N	\N
50	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-24 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:38	2025-12-19 10:01:20	\N	\N
31	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-24 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:54	2025-12-19 09:27:31	\N	\N
59	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-19 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:48	2026-01-16 09:30:28	\N	\N
45	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-19 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:09	2025-12-19 10:01:20	\N	\N
9	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-14 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:21:48	2025-12-19 08:37:26	\N	\N
32	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-11 00:00:00	485	\N	6-15	\N	\N	\N	\N	2025-12-19 09:47:19	2025-12-19 09:43:20	\N	\N
30	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-23 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:50	2025-12-19 09:27:31	\N	\N
8	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-13 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:21:43	2025-12-19 08:33:14	\N	\N
15	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-23 00:00:00	93	\N	7-16	\N	\N	\N	\N	2025-12-19 09:22:17	2025-12-19 08:40:27	\N	\N
12	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-20 00:00:00	93	\N	8-17	\N	\N	\N	\N	2025-12-19 09:22:03	2025-12-19 08:38:54	\N	\N
18	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-11 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:27:37	2025-12-19 09:27:31	\N	\N
6	\N	\N	\N	\N	\N	\N	Cancelled	\N	2025-10-11 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-15 11:52:05	2025-12-15 11:45:30	\N	\N
5	\N	\N	\N	\N	\N	\N	Cancelled	\N	2025-10-11 00:00:00	8	\N	6-15	\N	\N	\N	\N	2025-12-15 11:39:49	2025-12-15 11:37:53	\N	\N
61	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-21 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:57	2026-01-16 09:30:28	\N	\N
47	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-21 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:23	2025-12-19 10:01:20	\N	\N
29	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-22 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:45	2025-12-19 09:27:31	\N	\N
56	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-16 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:36	2026-01-16 09:30:28	\N	\N
42	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-16 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:01:53	2025-12-19 10:01:20	\N	\N
63	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-23 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:32:06	2026-01-16 09:30:28	\N	\N
49	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-23 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:33	2025-12-19 10:01:20	\N	\N
66	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-14 00:00:00	94	\N	6-15	\N	\N	\N	\N	2026-01-16 10:04:27	2026-01-16 10:04:22	\N	\N
58	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-18 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:44	2026-01-16 09:30:28	\N	\N
44	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-18 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:05	2025-12-19 10:01:20	\N	\N
34	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-13 00:00:00	485	\N	6-15	\N	\N	\N	\N	2025-12-19 09:47:33	2025-12-19 09:43:20	\N	\N
52	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-13 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:18	2026-01-16 09:29:16	\N	\N
39	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-13 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:01:38	2025-12-19 10:01:20	\N	\N
54	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-14 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:31:28	2026-01-16 09:30:28	\N	\N
40	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-14 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:01:42	2025-12-19 10:01:20	\N	\N
65	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-12 00:00:00	94	\N	6-15	\N	\N	\N	\N	2026-01-16 10:02:00	2026-01-16 10:01:53	\N	\N
25	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-18 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:26	2025-12-19 09:27:31	\N	\N
28	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-21 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:28:41	2025-12-19 09:27:31	\N	\N
68	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-23 00:00:00	94	\N	6-15	\N	\N	\N	\N	2026-01-16 10:13:52	2026-01-16 10:13:41	\N	\N
20	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-13 00:00:00	8	\N	7-16	\N	\N	\N	\N	2025-12-19 09:27:47	2025-12-19 09:27:31	\N	\N
67	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-21 00:00:00	94	\N	6-15	\N	\N	\N	\N	2026-01-16 10:08:19	2026-01-16 10:07:54	\N	\N
10	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-15 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:21:53	2025-12-19 08:38:03	\N	\N
7	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-11 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-19 09:21:38	2025-12-19 08:32:47	\N	\N
4	\N	\N	\N	\N	\N	\N	Cancelled	\N	2025-10-11 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-15 11:52:21	2025-12-15 09:51:34	\N	\N
3	\N	\N	\N	\N	\N	\N	Cancelled	\N	2025-10-11 00:00:00	93	\N	6-15	\N	\N	\N	\N	2025-12-15 09:50:33	2025-12-15 09:38:00	\N	\N
62	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-22 00:00:00	282	\N	19-7	\N	\N	\N	\N	2026-01-16 09:32:02	2026-01-16 09:30:28	\N	\N
48	\N	\N	\N	\N	\N	\N	Approved	\N	2025-10-22 00:00:00	282	\N	19-7	\N	\N	\N	\N	2025-12-19 10:02:28	2025-12-19 10:01:20	\N	\N
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schedules (id, schedule_name, schedule_type, created_at, updated_at, schedule_shift) FROM stdin;
2	9-15	Day Shift (No Break)	2025-10-21 09:20:25	2025-10-21 09:20:25	Day Shift
3	10-16	Day Shift	2025-11-03 10:10:32	2025-11-03 10:10:32	Day Shift
4	7-16	Day Shift	2025-11-12 09:52:39	2025-11-12 09:52:39	Day Shift
5	8-17	Day Shift	2025-11-12 15:19:49	2025-11-12 15:19:49	Day Shift
6	7-19	Day Shift	2025-11-12 15:20:20	2025-11-12 15:20:20	Day Shift
7	18-6	Night Shift	2025-11-12 15:21:20	2025-11-12 15:21:20	Night Shift
8	19-7	Night Shift	2025-11-12 15:21:41	2025-11-12 15:21:41	Night Shift
9	19-4	Night Shift	2025-11-12 15:21:55	2025-11-12 15:21:55	Night Shift
10	20-5	Night Shift	2025-11-12 15:22:10	2025-11-12 15:22:10	Night Shift
11	15-23	Night Shift	2025-11-12 15:22:51	2025-11-12 15:22:51	Night Shift
12	15-0	Night Shift (No Break)	2025-11-12 15:23:07	2025-11-12 15:23:07	Night Shift
13	23-7	Night Shift (No Break)	2025-11-12 15:23:29	2025-11-12 15:23:29	Night Shift
14	23-8	Night Shift	2025-11-12 15:23:44	2025-11-12 15:23:44	Night Shift
15	6-15	Day Shift	2025-11-12 15:36:21	2025-11-12 15:36:21	Day Shift
16	10-18	Day Shift	2025-11-14 10:32:34	2025-11-14 10:32:34	Day Shift
17	8-17	Day Shift	2025-11-15 14:35:29	2025-11-15 14:35:29	Day Shift
\.


--
-- Data for Name: security_attendance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.security_attendance (id, employee_management_id, earliest_time, latest_time, hours_worked, record_date, weekday, ot, nd, created_at, updated_at, biometric_imports_id) FROM stdin;
87	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-15 00:00:00	Monday	4	0	\N	\N	\N
88	353	0 days 19:00:00	0 days 07:00:00	\N	2025-09-07 00:00:00	Sunday	0	0	\N	\N	\N
71	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-11 00:00:00	Thursday	0	4	\N	\N	\N
89	353	0 days 19:00:00	0 days 07:00:00	\N	2025-09-14 00:00:00	Sunday	0	0	\N	\N	\N
72	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-12 00:00:00	Friday	0	4	\N	\N	\N
73	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-13 00:00:00	Saturday	0	4	\N	\N	\N
74	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-15 00:00:00	Monday	0	4	\N	\N	\N
75	332	0 days 19:00:00	0 days 07:00:00	12	2025-09-12 00:00:00	Friday	0	4	\N	\N	\N
62	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-01 00:00:00	Monday	0	4	\N	\N	\N
76	332	0 days 07:00:00	0 days 19:00:00	12	2025-09-15 00:00:00	Monday	4	0	\N	\N	\N
63	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-02 00:00:00	Tuesday	0	4	\N	\N	\N
64	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-03 00:00:00	Wednesday	0	4	\N	\N	\N
77	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-01 00:00:00	Monday	4	0	\N	\N	\N
78	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-02 00:00:00	Tuesday	4	0	\N	\N	\N
65	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-04 00:00:00	Thursday	0	4	\N	\N	\N
79	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-03 00:00:00	Wednesday	4	0	\N	\N	\N
80	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-04 00:00:00	Thursday	4	0	\N	\N	\N
81	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-05 00:00:00	Friday	4	0	\N	\N	\N
66	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-05 00:00:00	Friday	0	4	\N	\N	\N
82	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-08 00:00:00	Monday	4	0	\N	\N	\N
83	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-09 00:00:00	Tuesday	4	0	\N	\N	\N
67	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-06 00:00:00	Saturday	0	4	\N	\N	\N
84	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-10 00:00:00	Wednesday	4	0	\N	\N	\N
85	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-11 00:00:00	Thursday	4	0	\N	\N	\N
68	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-08 00:00:00	Monday	0	4	\N	\N	\N
86	316	0 days 07:00:00	0 days 19:00:00	12	2025-09-12 00:00:00	Friday	4	0	\N	\N	\N
69	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-09 00:00:00	Tuesday	0	4	\N	\N	\N
70	353	0 days 19:00:00	0 days 07:00:00	12	2025-09-10 00:00:00	Wednesday	0	4	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, role) FROM stdin;
2	bea bianca	beabianxa@gmail.com	\N	$2y$10$ROwMepQ1fdoVG3nPsZFHQuVyljnR7EdnU8F1g56yLxdf4gtbGgkNW	\N	2024-10-15 07:04:03	2024-10-15 07:04:03	user
10	Albert M. Miva	ammiva@llri.com.ph	\N	$2y$10$TPyommXlZJJz5G5P0kSXW.nCHSeaCL4/qRz4n1zuKBkxsGgcjuF/W	\N	2025-11-19 09:48:03	2025-11-19 09:48:03	user
11	Anthony D. Macalalag	admacalalag@llri.com.ph	\N	$2y$10$b.XgEqFf93z1qilFvuzgPObK9/DqAuIjKyBzRKPDcFUfVz7jDAHUa	\N	2025-11-19 09:49:22	2025-11-19 09:49:22	user
12	Arianne D. Destura	addestura@llri.com.ph	\N	$2y$10$RXJNnrN43LE/ax9BC75XueL9Td/ZlJER73fMr69ZbX/fGHLwMNJaC	\N	2025-11-19 09:55:23	2025-11-19 09:55:23	user
13	Ben A. Belwa	babelwa@llri.com.ph	\N	$2y$10$/IkMpDKcbWosO9hyHlRLf.I4Cxa9x.y8sgqrNwSH7C9uoOGmoQoyW	\N	2025-11-19 09:57:42	2025-11-19 09:59:41	user
15	Charleane L. Cudal	crlandingin@lnl.com.ph	\N	$2y$10$ZR91tKlIC7DY6tdjsbA4p.6V9NrBOCUedvFyldohIFW4hLZVfD1bu	\N	2025-11-19 13:25:32	2025-11-19 13:25:32	user
17	Eugene Jay C. Tacardon	ectacardon@llri.com.ph	\N	$2y$10$9rtOaiMTezFd9TkhwrcDt.oiCAfrCo4onoWG1xTRs2/HlQVSm5cb.	\N	2025-11-19 13:27:02	2025-11-19 13:27:02	user
19	Limuel N. Macabunga	lnmacabunga@llri.com.ph	\N	$2y$10$mSV5CKyR3Frphf/06LOj7OHCqpy8wZuxipwlSCBSqYdZQjCJfaVJi	\N	2025-11-19 13:29:05	2025-11-19 13:29:05	user
20	Maricriz D. Malannag	mdmalanag@lnl.com.ph	\N	$2y$10$6XgN3IivREm8Nbd2IuNCselUoqSvq/QJElNcvRGPGa9XCdfxBkkNW	\N	2025-11-19 13:29:39	2025-11-19 13:29:39	user
21	Medardo F. Danbis	surveyor@lnl.com.ph	\N	$2y$10$8p11CBsA5Gv3AeBV5YpEW.6/ByQVU1/Kk7o12Fd33NewlBAjIzqsq	\N	2025-11-19 13:30:13	2025-11-19 13:30:13	user
22	Quen Russel S. Bautista	qsbautista@lnl.com.ph	\N	$2y$10$B2tU0m0mCxKKneQpj3/8gOI2wjo.FubbdoLZZtZCRd7eXXbWvwV1e	\N	2025-11-19 13:31:58	2025-11-19 13:31:58	user
14	Brian Nicole M. Bal	bnbal@llri.com.ph	\N	$2y$10$.6SrBCXyhGUS551UeZ2DBeqiWn18UYLBfFOc/y.yRWBua2IIfQ0Je	\N	2025-11-19 10:00:36	2025-11-19 10:00:36	user
6	CML (Developer)	cmlanoy@leoniogroup.com	\N	$2y$10$A46sZn4sUg9d7PX4lxSg1ej6eIfSx1F5MsjcgToVMnnczNUzU733m	\N	2025-02-25 06:03:44	2025-02-25 06:03:44	admin
7	RDC	rdconde@leoniogroup.com	\N	$2y$10$ALOOWr306EOxK/UBrcZKDec9frd0PP17j12srekMvINwumdx4HTB6	hH6Ql9Kib7xUeSFXa7vBshpP6wYOaepa8W1uysDmlvn1oTZ6gLSV6b3haHIn	2025-10-24 10:26:12	2025-10-24 10:26:12	user
8	Kathleen Mortil	site.hr@leoniogroup.com	\N	$2y$10$IODY/yXlB1MpwUYXIiWSXOYa8ASEOOMjRGgTbeDxKITVGbKFFdYlO	\N	2025-11-14 08:56:42	2025-11-14 08:56:42	admin
23	Noe Cagomoc	npcagomoc@leoniogroup.com	\N	$2y$10$nMyQy9E5jFQv/9465JkmVO5GFCpuePnAfTqSAhPbhk.BPPpbUpLO.	\N	2025-11-27 10:45:41	2025-11-27 10:45:41	admin
9	FLL (Developer)	fllegayada@leoniogroup.com	\N	$2y$10$PT4crphyS.nbT65h/kIe2uF0FtZimzPR7dTwJCsw4V1leM3epgs4K	l4SMyjydl9gWAEBXF3soK3JOcVo0l8DHvQ7iWCfe3Xw3V9hqhd0nwBjkmh4M	2025-11-14 13:24:38	2025-11-14 13:24:38	admin
16	Deo F. Sienes	dfseines@lnl.com.ph	\N	$2y$10$BVzDhRqvHJUKodXqZsfHKOUQodCUZfmbcuMAEq.bqVBvEinGCtDN6	\N	2025-11-19 13:26:33	2025-11-19 13:26:33	admin
24	Imieren Comoda	iacomoda@lnl.com.ph	\N	$2y$10$l.P5f62FsYK0gxC2/DTAy.axNaTFXfa2MFe06oiKP2L6zaFfSGtbm	\N	2025-12-05 14:46:30	2025-12-05 14:46:30	admin
25	Mary Joy Lope	mslope@lnl.com.ph	\N	$2y$10$BVzDhRqvHJUKodXqZsfHKOUQodCUZfmbcuMAEq.bqVBvEinGCtDN6	pnIBGHboZErljoNPk5PpPsQsSTTUsSMpRzAcxazmu93hzT47GBdrxk5XzCCa	2025-12-05 14:47:43	2025-12-05 14:47:43	admin
27	Kathleen Mortil	site.hr02@lnl.com.ph	\N	$2y$10$mSV5CKyR3Frphf/06LOj7OHCqpy8wZuxipwlSCBSqYdZQjCJfaVJi	\N	2026-09-22 09:54:58	2026-09-22 09:54:58	admin
26	Marylen Yuson	mtyuson@leoniogroup.com	\N	$2y$10$jSwAixsqdx01L5oYcd2Af.ZKSnX8qogPd8OYnfp5zFEYmGW7rjKn2	ewlIun0wrc9K3Rkvkq0ZYNcycq2xYe6aNdghwlmkKYle8nOXbLAKCbpxO73D	2026-08-27 12:09:05	2026-08-27 12:09:05	admin
\.


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attendance_id_seq', 66235, true);


--
-- Name: attendance_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attendance_logs_id_seq', 343, true);


--
-- Name: biometric_imports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.biometric_imports_id_seq', 16, true);


--
-- Name: business_unit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.business_unit_id_seq', 3, true);


--
-- Name: certificate_attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.certificate_attendance_id_seq', 8, true);


--
-- Name: company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.company_id_seq', 2, true);


--
-- Name: csvimports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.csvimports_id_seq', 148776, true);


--
-- Name: custom_dates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.custom_dates_id_seq', 71, true);


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.department_id_seq', 32, true);


--
-- Name: dtr_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dtr_report_id_seq', 18825, true);


--
-- Name: employee_management_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employee_management_id_seq', 1, false);


--
-- Name: employee_management_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employee_management_id_seq1', 733, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: leaves_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.leaves_id_seq', 1, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 16, true);


--
-- Name: overtime_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.overtime_id_seq', 28087, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.schedule_id_seq', 17, true);


--
-- Name: security_attendance_employee_management_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.security_attendance_employee_management_id_seq', 1, false);


--
-- Name: security_attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.security_attendance_id_seq', 89, true);


--
-- Name: temp_sched_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.temp_sched_id_seq', 68, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 27, true);


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
-- Name: attendance_records_employee_date_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX attendance_records_employee_date_unique ON public.attendance_records USING btree (employee_management_id, ((record_date)::date));


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

