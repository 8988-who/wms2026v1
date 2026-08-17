/*
 Navicat Premium Dump SQL

 Source Server         : wmsdev
 Source Server Type    : PostgreSQL
 Source Server Version : 160014 (160014)
 Source Host           : 192.168.175.131:5432
 Source Catalog        : wms_all_template
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 160014 (160014)
 File Encoding         : 65001

 Date: 12/08/2026 13:49:17
*/


-- ----------------------------
-- Sequence structure for sys_config_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_config_id_seq";
CREATE SEQUENCE "public"."sys_config_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dept_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dept_id_seq";
CREATE SEQUENCE "public"."sys_dept_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dict_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dict_id_seq";
CREATE SEQUENCE "public"."sys_dict_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dict_item_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dict_item_id_seq";
CREATE SEQUENCE "public"."sys_dict_item_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_log_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_log_id_seq";
CREATE SEQUENCE "public"."sys_log_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_menu_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_menu_id_seq";
CREATE SEQUENCE "public"."sys_menu_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_notice_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_notice_id_seq";
CREATE SEQUENCE "public"."sys_notice_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_role_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_role_id_seq";
CREATE SEQUENCE "public"."sys_role_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_user_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_user_id_seq";
CREATE SEQUENCE "public"."sys_user_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_user_notice_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_user_notice_id_seq";
CREATE SEQUENCE "public"."sys_user_notice_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_user_social_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_user_social_id_seq";
CREATE SEQUENCE "public"."sys_user_social_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Table structure for api_request_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."api_request_log";
CREATE TABLE "public"."api_request_log" (
  "id" int8 NOT NULL,
  "api_code" varchar(64) COLLATE "pg_catalog"."default",
  "api_method_name" varchar(128) COLLATE "pg_catalog"."default",
  "api_url" varchar(512) COLLATE "pg_catalog"."default",
  "api_name" varchar(128) COLLATE "pg_catalog"."default",
  "req_params" text COLLATE "pg_catalog"."default",
  "res_params" text COLLATE "pg_catalog"."default",
  "is_success" varchar(1) COLLATE "pg_catalog"."default",
  "err_msg" text COLLATE "pg_catalog"."default",
  "module" varchar(64) COLLATE "pg_catalog"."default",
  "req_time" timestamp(6),
  "res_time" timestamp(6),
  "http_code" varchar(16) COLLATE "pg_catalog"."default",
  "res_code" varchar(16) COLLATE "pg_catalog"."default",
  "duration" int8,
  "retry_count" int4 DEFAULT 0,
  "trace_id" varchar(64) COLLATE "pg_catalog"."default",
  "created_by" int8,
  "created_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_by" int8,
  "updated_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."api_request_log"."id" IS '主键ID（自增）';
COMMENT ON COLUMN "public"."api_request_log"."api_code" IS '接口编码';
COMMENT ON COLUMN "public"."api_request_log"."api_method_name" IS '接口方法名';
COMMENT ON COLUMN "public"."api_request_log"."api_url" IS '接口地址';
COMMENT ON COLUMN "public"."api_request_log"."api_name" IS '接口名称';
COMMENT ON COLUMN "public"."api_request_log"."req_params" IS '请求参数（JSON格式）';
COMMENT ON COLUMN "public"."api_request_log"."res_params" IS '返回参数（JSON格式）';
COMMENT ON COLUMN "public"."api_request_log"."is_success" IS '是否成功：Y-成功，N-失败';
COMMENT ON COLUMN "public"."api_request_log"."err_msg" IS '错误信息';
COMMENT ON COLUMN "public"."api_request_log"."module" IS '所属模块（如 RCS、WMS、MES）';
COMMENT ON COLUMN "public"."api_request_log"."req_time" IS '请求时间';
COMMENT ON COLUMN "public"."api_request_log"."res_time" IS '返回时间';
COMMENT ON COLUMN "public"."api_request_log"."http_code" IS 'HTTP状态码（200、404、500等）';
COMMENT ON COLUMN "public"."api_request_log"."res_code" IS '业务返回状态码';
COMMENT ON COLUMN "public"."api_request_log"."duration" IS '耗时（毫秒）';
COMMENT ON COLUMN "public"."api_request_log"."retry_count" IS '重试次数';
COMMENT ON COLUMN "public"."api_request_log"."trace_id" IS '链路追踪ID';
COMMENT ON COLUMN "public"."api_request_log"."created_by" IS '创建人ID';
COMMENT ON COLUMN "public"."api_request_log"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."api_request_log"."updated_by" IS '更新人ID';
COMMENT ON COLUMN "public"."api_request_log"."updated_time" IS '更新时间';
COMMENT ON COLUMN "public"."api_request_log"."remark" IS '备注';
COMMENT ON TABLE "public"."api_request_log" IS '接口请求日志表（记录所有外部系统接口调用，支持链路追踪与性能监控）';

-- ----------------------------
-- Records of api_request_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_config";
CREATE TABLE "public"."sys_config" (
  "id" int8 NOT NULL DEFAULT nextval('sys_config_id_seq'::regclass),
  "config_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "config_key" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "config_value" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "remark" varchar(255) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6),
  "create_by" int8,
  "update_time" timestamp(6),
  "update_by" int8,
  "is_deleted" int2 NOT NULL DEFAULT 0
)
;
COMMENT ON COLUMN "public"."sys_config"."id" IS '主键';
COMMENT ON COLUMN "public"."sys_config"."config_name" IS '配置名称';
COMMENT ON COLUMN "public"."sys_config"."config_key" IS '配置key';
COMMENT ON COLUMN "public"."sys_config"."config_value" IS '配置值';
COMMENT ON COLUMN "public"."sys_config"."remark" IS '备注';
COMMENT ON COLUMN "public"."sys_config"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_config"."create_by" IS '创建人ID';
COMMENT ON COLUMN "public"."sys_config"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_config"."update_by" IS '更新人ID';
COMMENT ON COLUMN "public"."sys_config"."is_deleted" IS '逻辑删除标识(0-未删除 1-已删除)';
COMMENT ON TABLE "public"."sys_config" IS '系统配置表';

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO "public"."sys_config" VALUES (1, '系统限流QPS', 'IP_QPS_THRESHOLD_LIMIT', '10', '单个IP请求的最大每秒查询数（QPS）阈值Key', '2026-07-13 20:12:07.928443', 1, NULL, NULL, 0);

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dept";
CREATE TABLE "public"."sys_dept" (
  "id" int8 NOT NULL DEFAULT nextval('sys_dept_id_seq'::regclass),
  "name" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "code" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "parent_id" int8 DEFAULT 0,
  "tree_path" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "sort" int2 DEFAULT 0,
  "status" int2 DEFAULT 1,
  "create_by" int8,
  "create_time" timestamp(6),
  "update_by" int8,
  "update_time" timestamp(6),
  "is_deleted" int2 DEFAULT 0,
  "plant_code" varchar(255) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_dept"."id" IS '主键';
COMMENT ON COLUMN "public"."sys_dept"."name" IS '部门名称';
COMMENT ON COLUMN "public"."sys_dept"."code" IS '部门编号';
COMMENT ON COLUMN "public"."sys_dept"."parent_id" IS '父节点id';
COMMENT ON COLUMN "public"."sys_dept"."tree_path" IS '父节点id路径';
COMMENT ON COLUMN "public"."sys_dept"."sort" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_dept"."status" IS '状态(1-正常 0-禁用)';
COMMENT ON COLUMN "public"."sys_dept"."create_by" IS '创建人ID';
COMMENT ON COLUMN "public"."sys_dept"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dept"."update_by" IS '修改人ID';
COMMENT ON COLUMN "public"."sys_dept"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dept"."is_deleted" IS '逻辑删除标识(1-已删除 0-未删除)';
COMMENT ON COLUMN "public"."sys_dept"."plant_code" IS '厂区编码（预留数据权限隔离）';
COMMENT ON TABLE "public"."sys_dept" IS '部门管理表';

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO "public"."sys_dept" VALUES (1, '九牧', 'JM001', 0, '0', 1, 1, 1, NULL, 1, '2026-07-14 03:34:21.291037', 0, NULL);
INSERT INTO "public"."sys_dept" VALUES (4, '开发测试', 'KFCS0001', 0, '0', 1, 1, 2, '2026-07-14 03:37:16.466877', NULL, '2026-07-14 03:41:57.239298', 0, NULL);
INSERT INTO "public"."sys_dept" VALUES (3, '厂区102', 'JMSC002', 1, '0,1', 2, 1, 2, NULL, 2, '2026-07-24 10:14:06.052958', 0, NULL);
INSERT INTO "public"."sys_dept" VALUES (5, '生产101', 'SC101', 2, '0,1,2', 1, 1, 2, '2026-07-24 10:14:21.669886', NULL, '2026-07-24 10:14:21.669886', 0, NULL);
INSERT INTO "public"."sys_dept" VALUES (6, '品检101', 'PJ101', 2, '0,1,2', 2, 1, 2, '2026-07-24 10:14:49.527165', NULL, '2026-07-24 10:14:49.527165', 0, NULL);
INSERT INTO "public"."sys_dept" VALUES (7, '生产102', 'SC102', 3, '0,1,3', 1, 1, 2, '2026-07-24 10:15:07.01695', NULL, '2026-07-24 10:15:07.01695', 0, NULL);
INSERT INTO "public"."sys_dept" VALUES (2, '厂区101', 'JMSC001', 1, '0,1', 1, 1, 2, NULL, 2, '2026-07-24 22:58:05.452137', 0, 'TEST101');

-- ----------------------------
-- Table structure for sys_dict
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dict";
CREATE TABLE "public"."sys_dict" (
  "id" int8 NOT NULL DEFAULT nextval('sys_dict_id_seq'::regclass),
  "dict_code" varchar(50) COLLATE "pg_catalog"."default",
  "name" varchar(50) COLLATE "pg_catalog"."default",
  "status" int2 DEFAULT 0,
  "remark" varchar(255) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6),
  "create_by" int8,
  "update_time" timestamp(6),
  "update_by" int8,
  "is_deleted" int2 DEFAULT 0
)
;
COMMENT ON COLUMN "public"."sys_dict"."id" IS '主键 ';
COMMENT ON COLUMN "public"."sys_dict"."dict_code" IS '类型编码';
COMMENT ON COLUMN "public"."sys_dict"."name" IS '类型名称';
COMMENT ON COLUMN "public"."sys_dict"."status" IS '状态(0:正常;1:禁用)';
COMMENT ON COLUMN "public"."sys_dict"."remark" IS '备注';
COMMENT ON COLUMN "public"."sys_dict"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dict"."create_by" IS '创建人ID';
COMMENT ON COLUMN "public"."sys_dict"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dict"."update_by" IS '修改人ID';
COMMENT ON COLUMN "public"."sys_dict"."is_deleted" IS '是否删除(1-删除，0-未删除)';
COMMENT ON TABLE "public"."sys_dict" IS '数据字典类型表';

-- ----------------------------
-- Records of sys_dict
-- ----------------------------
INSERT INTO "public"."sys_dict" VALUES (1, 'gender', '性别', 1, NULL, '2026-07-13 20:12:07.740195', 1, '2026-07-13 20:12:07.740195', 1, 0);
INSERT INTO "public"."sys_dict" VALUES (2, 'notice_type', '通知类型', 1, NULL, '2026-07-13 20:12:07.741068', 1, '2026-07-13 20:12:07.741068', 1, 0);
INSERT INTO "public"."sys_dict" VALUES (3, 'notice_level', '通知级别', 1, NULL, '2026-07-13 20:12:07.741823', 1, '2026-07-13 20:12:07.741823', 1, 0);

-- ----------------------------
-- Table structure for sys_dict_item
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dict_item";
CREATE TABLE "public"."sys_dict_item" (
  "id" int8 NOT NULL DEFAULT nextval('sys_dict_item_id_seq'::regclass),
  "dict_code" varchar(50) COLLATE "pg_catalog"."default",
  "value" varchar(50) COLLATE "pg_catalog"."default",
  "label" varchar(100) COLLATE "pg_catalog"."default",
  "tag_type" varchar(50) COLLATE "pg_catalog"."default",
  "status" int2 DEFAULT 0,
  "sort" int4 DEFAULT 0,
  "remark" varchar(255) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6),
  "create_by" int8,
  "update_time" timestamp(6),
  "update_by" int8
)
;
COMMENT ON COLUMN "public"."sys_dict_item"."id" IS '主键';
COMMENT ON COLUMN "public"."sys_dict_item"."dict_code" IS '关联字典编码，与sys_dict表中的dict_code对应';
COMMENT ON COLUMN "public"."sys_dict_item"."value" IS '字典项值';
COMMENT ON COLUMN "public"."sys_dict_item"."label" IS '字典项标签';
COMMENT ON COLUMN "public"."sys_dict_item"."tag_type" IS '标签类型，用于前端样式展示（如success、warning等）';
COMMENT ON COLUMN "public"."sys_dict_item"."status" IS '状态（1-正常，0-禁用）';
COMMENT ON COLUMN "public"."sys_dict_item"."sort" IS '排序';
COMMENT ON COLUMN "public"."sys_dict_item"."remark" IS '备注';
COMMENT ON COLUMN "public"."sys_dict_item"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dict_item"."create_by" IS '创建人ID';
COMMENT ON COLUMN "public"."sys_dict_item"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dict_item"."update_by" IS '修改人ID';
COMMENT ON TABLE "public"."sys_dict_item" IS '数据字典项表';

-- ----------------------------
-- Records of sys_dict_item
-- ----------------------------
INSERT INTO "public"."sys_dict_item" VALUES (1, 'gender', '1', '男', 'primary', 1, 1, NULL, '2026-07-13 20:12:07.755668', 1, '2026-07-13 20:12:07.755668', 1);
INSERT INTO "public"."sys_dict_item" VALUES (2, 'gender', '2', '女', 'danger', 1, 2, NULL, '2026-07-13 20:12:07.75661', 1, '2026-07-13 20:12:07.75661', 1);
INSERT INTO "public"."sys_dict_item" VALUES (3, 'gender', '0', '保密', 'info', 1, 3, NULL, '2026-07-13 20:12:07.757203', 1, '2026-07-13 20:12:07.757203', 1);
INSERT INTO "public"."sys_dict_item" VALUES (4, 'notice_type', '1', '系统升级', 'success', 1, 1, '', '2026-07-13 20:12:07.757765', 1, '2026-07-13 20:12:07.757765', 1);
INSERT INTO "public"."sys_dict_item" VALUES (5, 'notice_type', '2', '系统维护', 'primary', 1, 2, '', '2026-07-13 20:12:07.758881', 1, '2026-07-13 20:12:07.758881', 1);
INSERT INTO "public"."sys_dict_item" VALUES (6, 'notice_type', '3', '安全警告', 'danger', 1, 3, '', '2026-07-13 20:12:07.759681', 1, '2026-07-13 20:12:07.759681', 1);
INSERT INTO "public"."sys_dict_item" VALUES (7, 'notice_type', '4', '假期通知', 'success', 1, 4, '', '2026-07-13 20:12:07.760311', 1, '2026-07-13 20:12:07.760311', 1);
INSERT INTO "public"."sys_dict_item" VALUES (8, 'notice_type', '5', '公司新闻', 'primary', 1, 5, '', '2026-07-13 20:12:07.761131', 1, '2026-07-13 20:12:07.761131', 1);
INSERT INTO "public"."sys_dict_item" VALUES (9, 'notice_type', '99', '其他', 'info', 1, 99, '', '2026-07-13 20:12:07.761996', 1, '2026-07-13 20:12:07.761996', 1);
INSERT INTO "public"."sys_dict_item" VALUES (10, 'notice_level', 'L', '低', 'info', 1, 1, '', '2026-07-13 20:12:07.762855', 1, '2026-07-13 20:12:07.762855', 1);
INSERT INTO "public"."sys_dict_item" VALUES (11, 'notice_level', 'M', '中', 'warning', 1, 2, '', '2026-07-13 20:12:07.763617', 1, '2026-07-13 20:12:07.763617', 1);
INSERT INTO "public"."sys_dict_item" VALUES (12, 'notice_level', 'H', '高', 'danger', 1, 3, '', '2026-07-13 20:12:07.764404', 1, '2026-07-13 20:12:07.764404', 1);

-- ----------------------------
-- Table structure for sys_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_log";
CREATE TABLE "public"."sys_log" (
  "id" int8 NOT NULL DEFAULT nextval('sys_log_id_seq'::regclass),
  "module" int2 NOT NULL,
  "action_type" int2 NOT NULL,
  "title" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "content" text COLLATE "pg_catalog"."default",
  "operator_id" int8,
  "operator_name" varchar(50) COLLATE "pg_catalog"."default",
  "request_uri" text COLLATE "pg_catalog"."default",
  "request_method" varchar(10) COLLATE "pg_catalog"."default",
  "ip" varchar(45) COLLATE "pg_catalog"."default",
  "province" varchar(100) COLLATE "pg_catalog"."default",
  "city" varchar(100) COLLATE "pg_catalog"."default",
  "device" varchar(100) COLLATE "pg_catalog"."default",
  "os" varchar(100) COLLATE "pg_catalog"."default",
  "browser" varchar(100) COLLATE "pg_catalog"."default",
  "status" int2 DEFAULT 1,
  "error_msg" text COLLATE "pg_catalog"."default",
  "execution_time" int4,
  "create_time" timestamp(6)
)
;
COMMENT ON COLUMN "public"."sys_log"."id" IS '主键';
COMMENT ON COLUMN "public"."sys_log"."module" IS '模块，数字枚举，参考 LogModule 枚举';
COMMENT ON COLUMN "public"."sys_log"."action_type" IS '操作类型，数字枚举，参考 ActionType 枚举';
COMMENT ON COLUMN "public"."sys_log"."title" IS '前端显示标题';
COMMENT ON COLUMN "public"."sys_log"."content" IS '自定义日志内容';
COMMENT ON COLUMN "public"."sys_log"."operator_id" IS '操作人ID';
COMMENT ON COLUMN "public"."sys_log"."operator_name" IS '操作人名称';
COMMENT ON COLUMN "public"."sys_log"."request_uri" IS '请求路径';
COMMENT ON COLUMN "public"."sys_log"."request_method" IS '请求方法';
COMMENT ON COLUMN "public"."sys_log"."ip" IS 'IP地址';
COMMENT ON COLUMN "public"."sys_log"."province" IS '省份';
COMMENT ON COLUMN "public"."sys_log"."city" IS '城市';
COMMENT ON COLUMN "public"."sys_log"."device" IS '设备';
COMMENT ON COLUMN "public"."sys_log"."os" IS '操作系统';
COMMENT ON COLUMN "public"."sys_log"."browser" IS '浏览器';
COMMENT ON COLUMN "public"."sys_log"."status" IS '0失败 1成功';
COMMENT ON COLUMN "public"."sys_log"."error_msg" IS '错误信息';
COMMENT ON COLUMN "public"."sys_log"."execution_time" IS '执行时间(ms)';
COMMENT ON COLUMN "public"."sys_log"."create_time" IS '操作时间';
COMMENT ON TABLE "public"."sys_log" IS '系统操作日志表';

-- ----------------------------
-- Records of sys_log
-- ----------------------------
INSERT INTO "public"."sys_log" VALUES (1, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1197, '2026-07-14 01:51:28.187785');
INSERT INTO "public"."sys_log" VALUES (2, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-14 01:59:34.362838');
INSERT INTO "public"."sys_log" VALUES (3, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 98, '2026-07-14 01:59:39.866885');
INSERT INTO "public"."sys_log" VALUES (4, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-14 02:00:16.462156');
INSERT INTO "public"."sys_log" VALUES (5, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 02:13:52.47282');
INSERT INTO "public"."sys_log" VALUES (6, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 02:52:09.733198');
INSERT INTO "public"."sys_log" VALUES (7, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-14 02:52:13.927508');
INSERT INTO "public"."sys_log" VALUES (8, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-14 02:52:15.757418');
INSERT INTO "public"."sys_log" VALUES (9, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 02:52:17.198692');
INSERT INTO "public"."sys_log" VALUES (10, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 02:52:18.640994');
INSERT INTO "public"."sys_log" VALUES (11, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 02:52:19.901012');
INSERT INTO "public"."sys_log" VALUES (12, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 02:52:21.345865');
INSERT INTO "public"."sys_log" VALUES (13, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 02:57:23.8522');
INSERT INTO "public"."sys_log" VALUES (14, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 02:58:41.438198');
INSERT INTO "public"."sys_log" VALUES (15, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 02:58:42.524205');
INSERT INTO "public"."sys_log" VALUES (16, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 02:58:43.94827');
INSERT INTO "public"."sys_log" VALUES (17, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 02:58:44.874552');
INSERT INTO "public"."sys_log" VALUES (18, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-14 02:58:55.288366');
INSERT INTO "public"."sys_log" VALUES (19, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-14 03:02:08.972738');
INSERT INTO "public"."sys_log" VALUES (20, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-14 03:02:15.511055');
INSERT INTO "public"."sys_log" VALUES (21, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 03:02:16.418616');
INSERT INTO "public"."sys_log" VALUES (22, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 03:02:17.686454');
INSERT INTO "public"."sys_log" VALUES (23, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-14 03:02:18.351015');
INSERT INTO "public"."sys_log" VALUES (24, 2, 3, '用户管理-新增', '', 2, 'admin', '/api/v1/users', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 重复键违反唯一约束"sys_user_pkey"
  详细：键值"(id)=(5)" 已经存在
### The error may exist in com/youlai/boot/system/mapper/UserMapper.java (best guess)
### The error may involve com.youlai.boot.system.mapper.UserMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO sys_user  ( username, nickname, gender, password, dept_id,  mobile, status, email, create_by,   create_time, update_time )  VALUES (  ?, ?, ?, ?, ?,  ?, ?, ?, ?,   ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 重复键违反唯一约束"sys_user_pkey"
  详细：键值"(id)=(5)" 已经存在
; 错误: 重复键违反唯一约束"sys_user_pkey"
  详细：键值"(id)=(5)" 已经存在', 337, '2026-07-14 03:02:58.254152');
INSERT INTO "public"."sys_log" VALUES (25, 2, 3, '用户管理-新增', '', 2, 'admin', '/api/v1/users', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 重复键违反唯一约束"sys_user_pkey"
  详细：键值"(id)=(6)" 已经存在
### The error may exist in com/youlai/boot/system/mapper/UserMapper.java (best guess)
### The error may involve com.youlai.boot.system.mapper.UserMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO sys_user  ( username, nickname, gender, password, dept_id,  mobile, status, email, create_by,   create_time, update_time )  VALUES (  ?, ?, ?, ?, ?,  ?, ?, ?, ?,   ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 重复键违反唯一约束"sys_user_pkey"
  详细：键值"(id)=(6)" 已经存在
; 错误: 重复键违反唯一约束"sys_user_pkey"
  详细：键值"(id)=(6)" 已经存在', 77, '2026-07-14 03:03:03.429166');
INSERT INTO "public"."sys_log" VALUES (26, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-14 03:09:49.963151');
INSERT INTO "public"."sys_log" VALUES (27, 2, 3, '用户管理-新增', '', 2, 'admin', '/api/v1/users', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 109, '2026-07-14 03:11:53.875612');
INSERT INTO "public"."sys_log" VALUES (28, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 03:11:54.223443');
INSERT INTO "public"."sys_log" VALUES (29, 2, 5, '用户管理-删除', '', 2, 'admin', '/api/v1/users/8', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-14 03:11:58.468113');
INSERT INTO "public"."sys_log" VALUES (30, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 03:11:58.803444');
INSERT INTO "public"."sys_log" VALUES (31, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 03:12:00.214374');
INSERT INTO "public"."sys_log" VALUES (32, 3, 3, '角色管理-新增', '', 2, 'admin', '/api/v1/roles', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-14 03:12:09.423656');
INSERT INTO "public"."sys_log" VALUES (33, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:12:09.756141');
INSERT INTO "public"."sys_log" VALUES (34, 3, 5, '角色管理-删除', '', 2, 'admin', '/api/v1/roles/8', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-14 03:12:13.770783');
INSERT INTO "public"."sys_log" VALUES (35, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 03:12:14.09513');
INSERT INTO "public"."sys_log" VALUES (36, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-14 03:17:53.757697');
INSERT INTO "public"."sys_log" VALUES (37, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-14 03:18:23.569246');
INSERT INTO "public"."sys_log" VALUES (38, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-14 03:18:25.200293');
INSERT INTO "public"."sys_log" VALUES (39, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-14 03:18:26.753868');
INSERT INTO "public"."sys_log" VALUES (40, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-14 03:18:37.883471');
INSERT INTO "public"."sys_log" VALUES (48, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-14 03:33:17.779694');
INSERT INTO "public"."sys_log" VALUES (49, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:33:18.675077');
INSERT INTO "public"."sys_log" VALUES (50, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 03:33:54.459082');
INSERT INTO "public"."sys_log" VALUES (51, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:33:58.545484');
INSERT INTO "public"."sys_log" VALUES (52, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 03:33:59.930446');
INSERT INTO "public"."sys_log" VALUES (41, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-14 03:29:24.238983');
INSERT INTO "public"."sys_log" VALUES (42, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 03:29:25.517945');
INSERT INTO "public"."sys_log" VALUES (43, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-14 03:29:33.490921');
INSERT INTO "public"."sys_log" VALUES (44, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 64, '2026-07-14 03:29:35.803543');
INSERT INTO "public"."sys_log" VALUES (45, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-14 03:29:44.756989');
INSERT INTO "public"."sys_log" VALUES (46, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-14 03:30:11.112319');
INSERT INTO "public"."sys_log" VALUES (47, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-14 03:30:13.363284');
INSERT INTO "public"."sys_log" VALUES (53, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/1', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-14 03:34:21.301057');
INSERT INTO "public"."sys_log" VALUES (54, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 03:34:21.642945');
INSERT INTO "public"."sys_log" VALUES (55, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/2', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-14 03:34:42.493247');
INSERT INTO "public"."sys_log" VALUES (56, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 03:34:42.834497');
INSERT INTO "public"."sys_log" VALUES (57, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/3', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-14 03:35:03.360112');
INSERT INTO "public"."sys_log" VALUES (58, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 03:35:03.70544');
INSERT INTO "public"."sys_log" VALUES (59, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/2', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:35:10.468647');
INSERT INTO "public"."sys_log" VALUES (60, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 03:35:10.801542');
INSERT INTO "public"."sys_log" VALUES (61, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 03:35:16.122062');
INSERT INTO "public"."sys_log" VALUES (62, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/3', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 03:35:25.172803');
INSERT INTO "public"."sys_log" VALUES (63, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 03:35:25.504611');
INSERT INTO "public"."sys_log" VALUES (64, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 03:35:44.987132');
INSERT INTO "public"."sys_log" VALUES (65, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 03:35:51.583536');
INSERT INTO "public"."sys_log" VALUES (66, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-14 03:35:52.757258');
INSERT INTO "public"."sys_log" VALUES (67, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-14 03:35:53.604057');
INSERT INTO "public"."sys_log" VALUES (68, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 03:35:53.864235');
INSERT INTO "public"."sys_log" VALUES (69, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 03:35:54.788336');
INSERT INTO "public"."sys_log" VALUES (70, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 03:35:55.624899');
INSERT INTO "public"."sys_log" VALUES (71, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-14 03:35:56.338775');
INSERT INTO "public"."sys_log" VALUES (72, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 03:35:56.748593');
INSERT INTO "public"."sys_log" VALUES (73, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 03:35:59.220267');
INSERT INTO "public"."sys_log" VALUES (74, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 03:35:59.607851');
INSERT INTO "public"."sys_log" VALUES (75, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 03:36:00.288657');
INSERT INTO "public"."sys_log" VALUES (76, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 03:36:00.999044');
INSERT INTO "public"."sys_log" VALUES (77, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:36:01.385788');
INSERT INTO "public"."sys_log" VALUES (78, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 03:36:05.91556');
INSERT INTO "public"."sys_log" VALUES (79, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 03:36:08.04447');
INSERT INTO "public"."sys_log" VALUES (80, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 03:36:10.779979');
INSERT INTO "public"."sys_log" VALUES (81, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:36:18.246791');
INSERT INTO "public"."sys_log" VALUES (82, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:36:19.107597');
INSERT INTO "public"."sys_log" VALUES (83, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 03:36:23.53061');
INSERT INTO "public"."sys_log" VALUES (84, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 03:36:24.457665');
INSERT INTO "public"."sys_log" VALUES (85, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:36:27.808601');
INSERT INTO "public"."sys_log" VALUES (86, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 03:36:29.310016');
INSERT INTO "public"."sys_log" VALUES (87, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 2, '2026-07-14 03:36:33.141175');
INSERT INTO "public"."sys_log" VALUES (88, 4, 3, '部门管理-新增', '', 2, 'admin', '/api/v1/depts', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-14 03:37:16.473855');
INSERT INTO "public"."sys_log" VALUES (89, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 03:37:16.801599');
INSERT INTO "public"."sys_log" VALUES (90, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:37:45.947738');
INSERT INTO "public"."sys_log" VALUES (91, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 03:37:46.644147');
INSERT INTO "public"."sys_log" VALUES (92, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 03:38:58.25889');
INSERT INTO "public"."sys_log" VALUES (93, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:39:00.943258');
INSERT INTO "public"."sys_log" VALUES (94, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 03:39:46.302117');
INSERT INTO "public"."sys_log" VALUES (95, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 03:39:54.377692');
INSERT INTO "public"."sys_log" VALUES (96, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-14 03:40:39.171865');
INSERT INTO "public"."sys_log" VALUES (97, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 03:41:45.119941');
INSERT INTO "public"."sys_log" VALUES (98, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/4', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-14 03:41:57.241181');
INSERT INTO "public"."sys_log" VALUES (99, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 03:41:57.575733');
INSERT INTO "public"."sys_log" VALUES (100, 3, 3, '角色管理-新增', '', 2, 'admin', '/api/v1/roles', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 重复键违反唯一约束"uk_role_code"
  详细：键值"(code)=(1)" 已经存在
### The error may exist in com/youlai/boot/system/mapper/RoleMapper.java (best guess)
### The error may involve com.youlai.boot.system.mapper.RoleMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO sys_role  ( name, code, sort, status, data_scope,    create_time, update_time )  VALUES (  ?, ?, ?, ?, ?,    ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 重复键违反唯一约束"uk_role_code"
  详细：键值"(code)=(1)" 已经存在
; 错误: 重复键违反唯一约束"uk_role_code"
  详细：键值"(code)=(1)" 已经存在', 47, '2026-07-14 03:42:16.034799');
INSERT INTO "public"."sys_log" VALUES (101, 3, 3, '角色管理-新增', '', 2, 'admin', '/api/v1/roles', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 03:42:28.148958');
INSERT INTO "public"."sys_log" VALUES (102, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 03:42:28.492782');
INSERT INTO "public"."sys_log" VALUES (103, 3, 4, '角色管理-修改', '', 2, 'admin', '/api/v1/roles/10', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-14 03:43:10.87991');
INSERT INTO "public"."sys_log" VALUES (104, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 03:43:11.245637');
INSERT INTO "public"."sys_log" VALUES (105, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 03:43:22.942865');
INSERT INTO "public"."sys_log" VALUES (106, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 03:43:24.116355');
INSERT INTO "public"."sys_log" VALUES (107, 2, 3, '用户管理-新增', '', 2, 'admin', '/api/v1/users', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 104, '2026-07-14 03:44:35.865316');
INSERT INTO "public"."sys_log" VALUES (108, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-14 03:44:36.231749');
INSERT INTO "public"."sys_log" VALUES (109, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 03:44:39.024078');
INSERT INTO "public"."sys_log" VALUES (110, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 03:44:39.937728');
INSERT INTO "public"."sys_log" VALUES (111, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 03:44:40.506577');
INSERT INTO "public"."sys_log" VALUES (112, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 03:44:41.244775');
INSERT INTO "public"."sys_log" VALUES (113, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 03:44:42.964682');
INSERT INTO "public"."sys_log" VALUES (114, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-14 03:44:56.056357');
INSERT INTO "public"."sys_log" VALUES (115, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/10/menus', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 68, '2026-07-14 03:45:20.096877');
INSERT INTO "public"."sys_log" VALUES (116, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-14 03:45:20.431943');
INSERT INTO "public"."sys_log" VALUES (117, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 03:49:28.566773');
INSERT INTO "public"."sys_log" VALUES (118, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 454, '2026-07-14 03:50:52.078556');
INSERT INTO "public"."sys_log" VALUES (119, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-07-14 09:42:54.447058');
INSERT INTO "public"."sys_log" VALUES (120, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 09:42:54.47274');
INSERT INTO "public"."sys_log" VALUES (121, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-14 09:43:23.891882');
INSERT INTO "public"."sys_log" VALUES (122, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 09:43:44.760225');
INSERT INTO "public"."sys_log" VALUES (123, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-07-14 09:43:57.391406');
INSERT INTO "public"."sys_log" VALUES (124, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-14 09:44:00.323243');
INSERT INTO "public"."sys_log" VALUES (125, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 09:44:11.798363');
INSERT INTO "public"."sys_log" VALUES (126, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 09:44:20.299024');
INSERT INTO "public"."sys_log" VALUES (127, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 09:44:50.064965');
INSERT INTO "public"."sys_log" VALUES (128, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 09:44:53.972603');
INSERT INTO "public"."sys_log" VALUES (129, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 09:44:56.141842');
INSERT INTO "public"."sys_log" VALUES (130, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 09:45:31.270906');
INSERT INTO "public"."sys_log" VALUES (131, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 128, '2026-07-14 09:47:03.70555');
INSERT INTO "public"."sys_log" VALUES (132, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 09:47:04.610053');
INSERT INTO "public"."sys_log" VALUES (133, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-14 09:47:04.932846');
INSERT INTO "public"."sys_log" VALUES (134, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 09:49:47.500447');
INSERT INTO "public"."sys_log" VALUES (135, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 09:50:54.177166');
INSERT INTO "public"."sys_log" VALUES (136, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 09:52:17.432761');
INSERT INTO "public"."sys_log" VALUES (137, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-14 09:53:13.411465');
INSERT INTO "public"."sys_log" VALUES (138, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 09:53:22.451668');
INSERT INTO "public"."sys_log" VALUES (139, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 09:53:25.584285');
INSERT INTO "public"."sys_log" VALUES (140, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 09:53:26.561789');
INSERT INTO "public"."sys_log" VALUES (141, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 09:53:28.12675');
INSERT INTO "public"."sys_log" VALUES (142, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 09:53:30.334452');
INSERT INTO "public"."sys_log" VALUES (143, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 09:53:30.932099');
INSERT INTO "public"."sys_log" VALUES (144, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 09:53:35.112417');
INSERT INTO "public"."sys_log" VALUES (145, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 09:53:35.834892');
INSERT INTO "public"."sys_log" VALUES (146, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 09:53:37.700412');
INSERT INTO "public"."sys_log" VALUES (147, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 09:53:39.006004');
INSERT INTO "public"."sys_log" VALUES (148, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-14 09:55:04.581078');
INSERT INTO "public"."sys_log" VALUES (149, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 09:56:05.083961');
INSERT INTO "public"."sys_log" VALUES (150, 9, 3, '通知公告-新增', '', 2, 'admin', '/api/v1/notices', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 72, '2026-07-14 09:56:20.735525');
INSERT INTO "public"."sys_log" VALUES (151, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-14 09:56:21.09225');
INSERT INTO "public"."sys_log" VALUES (152, 9, 4, '通知公告-修改', '', 2, 'admin', '/api/v1/notices/11/publish', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 195, '2026-07-14 09:56:23.502821');
INSERT INTO "public"."sys_log" VALUES (153, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 09:56:23.844314');
INSERT INTO "public"."sys_log" VALUES (154, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-14 09:56:33.591866');
INSERT INTO "public"."sys_log" VALUES (155, 9, 4, '通知公告-修改', '', 2, 'admin', '/api/v1/notices/11/revoke', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 92, '2026-07-14 09:56:35.607288');
INSERT INTO "public"."sys_log" VALUES (156, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-14 09:56:35.931475');
INSERT INTO "public"."sys_log" VALUES (157, 9, 5, '通知公告-删除', '', 2, 'admin', '/api/v1/notices/11', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-14 09:56:38.997592');
INSERT INTO "public"."sys_log" VALUES (158, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-14 09:56:39.325742');
INSERT INTO "public"."sys_log" VALUES (159, 9, 5, '通知公告-删除', '', 2, 'admin', '/api/v1/notices/5,4,7,9,2,1,8,3,10', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 09:56:54.251468');
INSERT INTO "public"."sys_log" VALUES (160, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 09:56:54.581056');
INSERT INTO "public"."sys_log" VALUES (161, 9, 4, '通知公告-修改', '', 2, 'admin', '/api/v1/notices/6/revoke', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 09:57:04.840393');
INSERT INTO "public"."sys_log" VALUES (162, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 09:57:05.158841');
INSERT INTO "public"."sys_log" VALUES (163, 9, 5, '通知公告-删除', '', 2, 'admin', '/api/v1/notices/6', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 09:57:08.689477');
INSERT INTO "public"."sys_log" VALUES (164, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 09:57:09.010783');
INSERT INTO "public"."sys_log" VALUES (165, 9, 3, '通知公告-新增', '', 2, 'admin', '/api/v1/notices', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-14 09:57:45.272002');
INSERT INTO "public"."sys_log" VALUES (166, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-14 09:57:45.61587');
INSERT INTO "public"."sys_log" VALUES (167, 9, 4, '通知公告-修改', '', 2, 'admin', '/api/v1/notices/12/publish', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 09:57:46.93469');
INSERT INTO "public"."sys_log" VALUES (168, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-14 09:57:47.262743');
INSERT INTO "public"."sys_log" VALUES (169, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-14 10:27:23.291932');
INSERT INTO "public"."sys_log" VALUES (170, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 327, '2026-07-14 11:52:21.633765');
INSERT INTO "public"."sys_log" VALUES (171, 3, 3, '角色管理-新增', '', 2, 'admin', '/api/v1/roles', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 124, '2026-07-14 11:53:05.614781');
INSERT INTO "public"."sys_log" VALUES (172, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 11:53:05.960632');
INSERT INTO "public"."sys_log" VALUES (173, 3, 5, '角色管理-删除', '', 2, 'admin', '/api/v1/roles/11', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 52, '2026-07-14 11:53:20.62849');
INSERT INTO "public"."sys_log" VALUES (174, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 11:53:20.966266');
INSERT INTO "public"."sys_log" VALUES (175, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 119, '2026-07-14 14:48:29.668212');
INSERT INTO "public"."sys_log" VALUES (176, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-14 14:48:29.694577');
INSERT INTO "public"."sys_log" VALUES (177, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-14 14:48:44.175186');
INSERT INTO "public"."sys_log" VALUES (178, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 14:49:01.72684');
INSERT INTO "public"."sys_log" VALUES (179, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-14 16:41:28.902374');
INSERT INTO "public"."sys_log" VALUES (180, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 163, '2026-07-14 16:41:42.154429');
INSERT INTO "public"."sys_log" VALUES (181, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-14 16:41:51.415571');
INSERT INTO "public"."sys_log" VALUES (182, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-14 16:41:51.436743');
INSERT INTO "public"."sys_log" VALUES (183, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-14 16:42:25.729204');
INSERT INTO "public"."sys_log" VALUES (184, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-14 16:43:14.647417');
INSERT INTO "public"."sys_log" VALUES (185, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-14 16:43:16.860253');
INSERT INTO "public"."sys_log" VALUES (186, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-14 16:43:19.946595');
INSERT INTO "public"."sys_log" VALUES (187, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-14 16:43:20.461867');
INSERT INTO "public"."sys_log" VALUES (188, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-14 16:43:23.051155');
INSERT INTO "public"."sys_log" VALUES (189, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-14 16:43:29.971142');
INSERT INTO "public"."sys_log" VALUES (190, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-14 16:43:34.875594');
INSERT INTO "public"."sys_log" VALUES (191, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-15 10:27:34.745043');
INSERT INTO "public"."sys_log" VALUES (192, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-07-15 13:47:18.139859');
INSERT INTO "public"."sys_log" VALUES (193, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-15 15:19:00.226227');
INSERT INTO "public"."sys_log" VALUES (194, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 48, '2026-07-15 17:47:39.323294');
INSERT INTO "public"."sys_log" VALUES (195, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 45, '2026-07-15 17:47:43.048282');
INSERT INTO "public"."sys_log" VALUES (196, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-15 17:47:43.080422');
INSERT INTO "public"."sys_log" VALUES (197, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-15 17:50:55.747001');
INSERT INTO "public"."sys_log" VALUES (198, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 507, '2026-07-15 19:17:39.06064');
INSERT INTO "public"."sys_log" VALUES (199, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-15 19:17:39.829218');
INSERT INTO "public"."sys_log" VALUES (200, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-15 19:17:39.872878');
INSERT INTO "public"."sys_log" VALUES (201, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-15 19:18:23.534541');
INSERT INTO "public"."sys_log" VALUES (202, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-15 19:18:23.557056');
INSERT INTO "public"."sys_log" VALUES (203, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-15 19:20:33.18482');
INSERT INTO "public"."sys_log" VALUES (204, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 110, '2026-07-15 19:20:43.920395');
INSERT INTO "public"."sys_log" VALUES (205, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 263, '2026-07-15 20:11:41.240454');
INSERT INTO "public"."sys_log" VALUES (206, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 56, '2026-07-15 20:11:57.421455');
INSERT INTO "public"."sys_log" VALUES (207, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-15 20:11:57.769283');
INSERT INTO "public"."sys_log" VALUES (208, 2, 3, '用户管理-新增', '', 2, 'admin', '/api/v1/users', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 316, '2026-07-15 20:12:32.83294');
INSERT INTO "public"."sys_log" VALUES (209, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 69, '2026-07-15 20:12:33.242987');
INSERT INTO "public"."sys_log" VALUES (210, 2, 4, '用户管理-修改', '', 2, 'admin', '/api/v1/users/10', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-15 20:12:39.934735');
INSERT INTO "public"."sys_log" VALUES (211, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-15 20:12:40.294503');
INSERT INTO "public"."sys_log" VALUES (212, 2, 12, '用户管理-重置密码', '', 2, 'admin', '/api/v1/users/10/password/reset', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 77, '2026-07-15 20:12:56.538004');
INSERT INTO "public"."sys_log" VALUES (213, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-15 20:13:06.573263');
INSERT INTO "public"."sys_log" VALUES (214, 1, 1, '登录-登录', '', NULL, NULL, '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, 'Bad credentials', 86, '2026-07-15 20:13:12.211914');
INSERT INTO "public"."sys_log" VALUES (215, 1, 1, '登录-登录', '', NULL, NULL, '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, 'Bad credentials', 75, '2026-07-15 20:13:23.09527');
INSERT INTO "public"."sys_log" VALUES (216, 1, 1, '登录-登录', '', NULL, NULL, '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, 'Bad credentials', 75, '2026-07-15 20:13:37.323954');
INSERT INTO "public"."sys_log" VALUES (217, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 75, '2026-07-15 20:13:49.367256');
INSERT INTO "public"."sys_log" VALUES (218, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-15 20:13:50.746985');
INSERT INTO "public"."sys_log" VALUES (219, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-15 20:13:51.072976');
INSERT INTO "public"."sys_log" VALUES (220, 2, 12, '用户管理-重置密码', '', 2, 'admin', '/api/v1/users/10/password/reset', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 71, '2026-07-15 20:13:59.487681');
INSERT INTO "public"."sys_log" VALUES (221, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-15 20:14:10.264005');
INSERT INTO "public"."sys_log" VALUES (222, 1, 1, '登录-登录', '', 3, 'test', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 79, '2026-07-15 20:14:19.734457');
INSERT INTO "public"."sys_log" VALUES (223, 1, 1, '登录-登录', '', 3, 'test', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 96, '2026-07-15 20:15:10.391166');
INSERT INTO "public"."sys_log" VALUES (224, 1, 2, '登录-登出', '', 3, 'test', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-15 20:15:34.35423');
INSERT INTO "public"."sys_log" VALUES (225, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 79, '2026-07-15 20:15:38.403627');
INSERT INTO "public"."sys_log" VALUES (226, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-15 20:15:56.629798');
INSERT INTO "public"."sys_log" VALUES (227, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-15 20:16:24.774634');
INSERT INTO "public"."sys_log" VALUES (228, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-15 20:16:26.928565');
INSERT INTO "public"."sys_log" VALUES (229, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-15 20:16:28.814374');
INSERT INTO "public"."sys_log" VALUES (230, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-15 20:16:30.091161');
INSERT INTO "public"."sys_log" VALUES (231, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-15 20:16:33.346273');
INSERT INTO "public"."sys_log" VALUES (232, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-15 20:16:33.365067');
INSERT INTO "public"."sys_log" VALUES (233, 2, 4, '用户管理-修改', '', 2, 'admin', '/api/v1/users/10', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-15 20:16:55.739603');
INSERT INTO "public"."sys_log" VALUES (234, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-15 20:16:56.090975');
INSERT INTO "public"."sys_log" VALUES (235, 1, 2, '登录-登出', '', 3, 'test', '/api/v1/auth/logout', 'DELETE', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 0, '2026-07-15 20:17:09.105575');
INSERT INTO "public"."sys_log" VALUES (236, 1, 1, '登录-登录', '', NULL, NULL, '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 0, 'User is disabled', 8, '2026-07-15 20:17:16.220812');
INSERT INTO "public"."sys_log" VALUES (237, 1, 1, '登录-登录', '', NULL, NULL, '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 0, 'User is disabled', 5, '2026-07-15 20:17:27.174111');
INSERT INTO "public"."sys_log" VALUES (238, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 47, '2026-07-15 20:49:21.147632');
INSERT INTO "public"."sys_log" VALUES (239, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-15 20:49:21.178497');
INSERT INTO "public"."sys_log" VALUES (240, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 635, '2026-07-16 10:30:08.52773');
INSERT INTO "public"."sys_log" VALUES (241, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 288, '2026-07-16 12:39:30.872201');
INSERT INTO "public"."sys_log" VALUES (242, 2, 4, '用户管理-修改', '', 2, 'admin', '/api/v1/users/profile', 'PUT', '172.28.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-16 12:39:36.274471');
INSERT INTO "public"."sys_log" VALUES (243, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 263, '2026-07-20 12:30:05.364027');
INSERT INTO "public"."sys_log" VALUES (244, 11, 4, '代码生成-修改', '', 2, 'admin', '/api/v1/codegen/wms_location/config', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 56, '2026-07-20 12:42:23.222189');
INSERT INTO "public"."sys_log" VALUES (245, 11, 10, '代码生成-下载', '', 2, 'admin', '/api/v1/codegen/wms_location/download', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 112, '2026-07-20 12:44:45.502507');
INSERT INTO "public"."sys_log" VALUES (246, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 224, '2026-07-20 14:32:48.342629');
INSERT INTO "public"."sys_log" VALUES (247, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 42, '2026-07-20 14:33:03.147608');
INSERT INTO "public"."sys_log" VALUES (248, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 257, '2026-07-20 14:38:32.724494');
INSERT INTO "public"."sys_log" VALUES (249, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-20 14:38:33.098024');
INSERT INTO "public"."sys_log" VALUES (250, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-20 14:41:04.65662');
INSERT INTO "public"."sys_log" VALUES (251, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-20 14:41:05.018154');
INSERT INTO "public"."sys_log" VALUES (252, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-20 14:41:49.577142');
INSERT INTO "public"."sys_log" VALUES (253, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 14:41:50.011197');
INSERT INTO "public"."sys_log" VALUES (254, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-20 14:42:12.876749');
INSERT INTO "public"."sys_log" VALUES (255, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 14:42:13.329205');
INSERT INTO "public"."sys_log" VALUES (256, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-20 14:42:39.098338');
INSERT INTO "public"."sys_log" VALUES (257, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 14:42:39.542303');
INSERT INTO "public"."sys_log" VALUES (258, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-20 14:43:00.516175');
INSERT INTO "public"."sys_log" VALUES (259, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 14:43:00.94951');
INSERT INTO "public"."sys_log" VALUES (260, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-20 14:43:04.774105');
INSERT INTO "public"."sys_log" VALUES (261, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-20 14:43:16.508887');
INSERT INTO "public"."sys_log" VALUES (262, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 80, '2026-07-20 14:43:19.978301');
INSERT INTO "public"."sys_log" VALUES (263, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-20 14:43:20.712977');
INSERT INTO "public"."sys_log" VALUES (264, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-20 14:43:25.80586');
INSERT INTO "public"."sys_log" VALUES (265, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-20 14:43:25.826018');
INSERT INTO "public"."sys_log" VALUES (267, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/10/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 64, '2026-07-20 14:43:39.89047');
INSERT INTO "public"."sys_log" VALUES (268, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-20 14:43:40.094348');
INSERT INTO "public"."sys_log" VALUES (269, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-07-20 14:43:50.431209');
INSERT INTO "public"."sys_log" VALUES (270, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-20 14:43:50.663961');
INSERT INTO "public"."sys_log" VALUES (271, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-20 14:43:55.758042');
INSERT INTO "public"."sys_log" VALUES (272, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 14:44:25.998959');
INSERT INTO "public"."sys_log" VALUES (273, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2809', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-20 14:46:01.162934');
INSERT INTO "public"."sys_log" VALUES (274, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 14:46:01.583925');
INSERT INTO "public"."sys_log" VALUES (275, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-20 14:46:32.216416');
INSERT INTO "public"."sys_log" VALUES (276, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2809', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-20 14:47:03.003696');
INSERT INTO "public"."sys_log" VALUES (277, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-20 14:47:03.424011');
INSERT INTO "public"."sys_log" VALUES (278, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 14:47:06.831067');
INSERT INTO "public"."sys_log" VALUES (279, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-20 14:47:34.047628');
INSERT INTO "public"."sys_log" VALUES (280, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 78, '2026-07-20 14:47:36.853004');
INSERT INTO "public"."sys_log" VALUES (281, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-20 14:47:37.314127');
INSERT INTO "public"."sys_log" VALUES (266, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 14:43:32.221382');
INSERT INTO "public"."sys_log" VALUES (282, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 216, '2026-07-20 16:09:09.735892');
INSERT INTO "public"."sys_log" VALUES (283, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 230, '2026-07-20 17:34:57.726028');
INSERT INTO "public"."sys_log" VALUES (284, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-20 17:40:43.188953');
INSERT INTO "public"."sys_log" VALUES (285, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-20 17:40:43.222796');
INSERT INTO "public"."sys_log" VALUES (286, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 210, '2026-07-20 19:39:48.865802');
INSERT INTO "public"."sys_log" VALUES (287, 11, 4, '代码生成-修改', '', 2, 'admin', '/api/v1/codegen/wms_aisle/config', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 143, '2026-07-20 21:07:22.491915');
INSERT INTO "public"."sys_log" VALUES (288, 11, 10, '代码生成-下载', '', 2, 'admin', '/api/v1/codegen/wms_aisle/download', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 69, '2026-07-20 21:07:26.166324');
INSERT INTO "public"."sys_log" VALUES (289, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-20 21:07:39.956238');
INSERT INTO "public"."sys_log" VALUES (290, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2813', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 79, '2026-07-20 21:09:22.414915');
INSERT INTO "public"."sys_log" VALUES (291, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 21:09:22.785741');
INSERT INTO "public"."sys_log" VALUES (292, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 21:28:56.325657');
INSERT INTO "public"."sys_log" VALUES (293, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-20 21:31:28.859332');
INSERT INTO "public"."sys_log" VALUES (294, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-20 21:31:41.529164');
INSERT INTO "public"."sys_log" VALUES (295, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-20 21:38:29.327366');
INSERT INTO "public"."sys_log" VALUES (296, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 107, '2026-07-20 21:38:36.954494');
INSERT INTO "public"."sys_log" VALUES (297, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-20 21:38:37.302257');
INSERT INTO "public"."sys_log" VALUES (298, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 234, '2026-07-20 21:40:20.347845');
INSERT INTO "public"."sys_log" VALUES (299, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-20 21:40:21.125039');
INSERT INTO "public"."sys_log" VALUES (300, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2813', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 46, '2026-07-20 21:41:00.446341');
INSERT INTO "public"."sys_log" VALUES (301, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-20 21:41:00.647168');
INSERT INTO "public"."sys_log" VALUES (302, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2814', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-20 21:41:16.139262');
INSERT INTO "public"."sys_log" VALUES (303, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-20 21:41:16.620698');
INSERT INTO "public"."sys_log" VALUES (304, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2815', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-07-20 21:41:26.473411');
INSERT INTO "public"."sys_log" VALUES (305, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 21:41:26.899991');
INSERT INTO "public"."sys_log" VALUES (306, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2816', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-20 21:41:39.2511');
INSERT INTO "public"."sys_log" VALUES (307, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 21:41:39.510266');
INSERT INTO "public"."sys_log" VALUES (308, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2817', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-20 21:41:48.927693');
INSERT INTO "public"."sys_log" VALUES (309, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-20 21:41:49.367129');
INSERT INTO "public"."sys_log" VALUES (310, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2813', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-07-20 21:41:58.647094');
INSERT INTO "public"."sys_log" VALUES (311, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-20 21:41:59.003514');
INSERT INTO "public"."sys_log" VALUES (312, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-20 22:25:18.522711');
INSERT INTO "public"."sys_log" VALUES (313, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 74, '2026-07-20 22:25:43.803722');
INSERT INTO "public"."sys_log" VALUES (314, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-20 22:25:43.843292');
INSERT INTO "public"."sys_log" VALUES (315, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-20 22:25:49.41075');
INSERT INTO "public"."sys_log" VALUES (316, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 22:25:49.747131');
INSERT INTO "public"."sys_log" VALUES (317, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/3/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-20 22:25:57.2758');
INSERT INTO "public"."sys_log" VALUES (318, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-20 22:25:57.624818');
INSERT INTO "public"."sys_log" VALUES (319, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/4/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 48, '2026-07-20 22:26:08.233626');
INSERT INTO "public"."sys_log" VALUES (320, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 22:26:08.577712');
INSERT INTO "public"."sys_log" VALUES (321, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 22:26:13.419567');
INSERT INTO "public"."sys_log" VALUES (322, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 51, '2026-07-20 22:54:16.511031');
INSERT INTO "public"."sys_log" VALUES (323, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2813', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 87, '2026-07-20 22:54:27.946308');
INSERT INTO "public"."sys_log" VALUES (324, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-20 22:54:28.309914');
INSERT INTO "public"."sys_log" VALUES (325, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-20 22:54:33.326023');
INSERT INTO "public"."sys_log" VALUES (326, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-20 23:16:46.492339');
INSERT INTO "public"."sys_log" VALUES (327, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-20 23:16:55.376081');
INSERT INTO "public"."sys_log" VALUES (328, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 60, '2026-07-20 23:17:04.520526');
INSERT INTO "public"."sys_log" VALUES (329, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 23:17:04.860592');
INSERT INTO "public"."sys_log" VALUES (330, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-20 23:17:08.859562');
INSERT INTO "public"."sys_log" VALUES (331, 11, 4, '代码生成-修改', '', 2, 'admin', '/api/v1/codegen/wms_point/config', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 73, '2026-07-20 23:17:52.909827');
INSERT INTO "public"."sys_log" VALUES (332, 11, 10, '代码生成-下载', '', 2, 'admin', '/api/v1/codegen/wms_point/download', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 72, '2026-07-20 23:17:56.531573');
INSERT INTO "public"."sys_log" VALUES (333, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-20 23:21:14.144731');
INSERT INTO "public"."sys_log" VALUES (334, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-20 23:21:14.505492');
INSERT INTO "public"."sys_log" VALUES (335, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 207, '2026-07-20 23:43:13.625227');
INSERT INTO "public"."sys_log" VALUES (336, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 79, '2026-07-20 23:43:46.661555');
INSERT INTO "public"."sys_log" VALUES (337, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 78, '2026-07-20 23:44:04.903918');
INSERT INTO "public"."sys_log" VALUES (338, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 80, '2026-07-20 23:47:08.106797');
INSERT INTO "public"."sys_log" VALUES (339, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 78, '2026-07-20 23:47:43.672118');
INSERT INTO "public"."sys_log" VALUES (340, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 111, '2026-07-20 23:49:14.893748');
INSERT INTO "public"."sys_log" VALUES (341, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 228, '2026-07-20 23:53:36.433952');
INSERT INTO "public"."sys_log" VALUES (342, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 217, '2026-07-20 23:57:48.784805');
INSERT INTO "public"."sys_log" VALUES (343, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 198, '2026-07-21 00:01:06.335151');
INSERT INTO "public"."sys_log" VALUES (344, 1, 1, '登录-登录', '', NULL, NULL, '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 0, 'Bad credentials', 175, '2026-07-21 00:10:48.520791');
INSERT INTO "public"."sys_log" VALUES (345, 1, 1, '登录-登录', '', NULL, NULL, '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 0, 'Bad credentials', 77, '2026-07-21 00:12:09.854112');
INSERT INTO "public"."sys_log" VALUES (346, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 91, '2026-07-21 00:13:58.98202');
INSERT INTO "public"."sys_log" VALUES (347, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 158, '2026-07-21 00:40:26.04552');
INSERT INTO "public"."sys_log" VALUES (348, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-21 00:47:07.27707');
INSERT INTO "public"."sys_log" VALUES (349, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 42, '2026-07-21 00:57:44.866113');
INSERT INTO "public"."sys_log" VALUES (350, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2819', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 62, '2026-07-21 00:58:24.86218');
INSERT INTO "public"."sys_log" VALUES (351, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-21 00:58:25.287443');
INSERT INTO "public"."sys_log" VALUES (352, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2818', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 51, '2026-07-21 00:59:40.503722');
INSERT INTO "public"."sys_log" VALUES (353, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-21 00:59:40.875758');
INSERT INTO "public"."sys_log" VALUES (354, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-21 01:00:15.973627');
INSERT INTO "public"."sys_log" VALUES (355, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2818', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-21 01:01:32.863516');
INSERT INTO "public"."sys_log" VALUES (356, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-21 01:01:33.233615');
INSERT INTO "public"."sys_log" VALUES (357, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2820', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-21 01:01:45.83053');
INSERT INTO "public"."sys_log" VALUES (358, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-21 01:01:46.288335');
INSERT INTO "public"."sys_log" VALUES (359, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2821', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-21 01:01:56.100216');
INSERT INTO "public"."sys_log" VALUES (360, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-21 01:01:56.515334');
INSERT INTO "public"."sys_log" VALUES (361, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2822', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-21 01:02:06.629588');
INSERT INTO "public"."sys_log" VALUES (362, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-21 01:02:07.06633');
INSERT INTO "public"."sys_log" VALUES (363, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-21 01:02:10.73912');
INSERT INTO "public"."sys_log" VALUES (364, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 49, '2026-07-21 01:48:14.117009');
INSERT INTO "public"."sys_log" VALUES (365, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2808', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 75, '2026-07-21 01:48:47.39356');
INSERT INTO "public"."sys_log" VALUES (366, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-21 01:48:47.766242');
INSERT INTO "public"."sys_log" VALUES (367, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-21 01:51:00.090598');
INSERT INTO "public"."sys_log" VALUES (368, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-21 01:51:02.912679');
INSERT INTO "public"."sys_log" VALUES (369, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 44, '2026-07-21 01:51:15.910966');
INSERT INTO "public"."sys_log" VALUES (370, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-21 01:51:16.268156');
INSERT INTO "public"."sys_log" VALUES (371, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-21 01:51:19.472676');
INSERT INTO "public"."sys_log" VALUES (372, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-21 01:53:27.793632');
INSERT INTO "public"."sys_log" VALUES (373, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-21 01:53:39.73156');
INSERT INTO "public"."sys_log" VALUES (374, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-21 01:53:41.497125');
INSERT INTO "public"."sys_log" VALUES (375, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-21 01:53:44.935892');
INSERT INTO "public"."sys_log" VALUES (376, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-21 01:53:48.518982');
INSERT INTO "public"."sys_log" VALUES (377, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-21 01:55:02.97662');
INSERT INTO "public"."sys_log" VALUES (378, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-21 01:55:10.78204');
INSERT INTO "public"."sys_log" VALUES (379, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-21 01:55:26.468827');
INSERT INTO "public"."sys_log" VALUES (380, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-21 01:56:30.073253');
INSERT INTO "public"."sys_log" VALUES (381, 5, 5, '菜单管理-删除', '', 2, 'admin', '/api/v1/menus/4', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-21 01:56:36.874212');
INSERT INTO "public"."sys_log" VALUES (382, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-21 01:56:37.203738');
INSERT INTO "public"."sys_log" VALUES (383, 5, 5, '菜单管理-删除', '', 2, 'admin', '/api/v1/menus/5', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-21 01:56:42.640281');
INSERT INTO "public"."sys_log" VALUES (384, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-21 01:56:42.960005');
INSERT INTO "public"."sys_log" VALUES (385, 5, 5, '菜单管理-删除', '', 2, 'admin', '/api/v1/menus/6', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-21 01:56:51.365748');
INSERT INTO "public"."sys_log" VALUES (386, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-21 01:56:51.699642');
INSERT INTO "public"."sys_log" VALUES (387, 5, 5, '菜单管理-删除', '', 2, 'admin', '/api/v1/menus/9', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-21 01:56:59.303665');
INSERT INTO "public"."sys_log" VALUES (388, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-21 01:56:59.632332');
INSERT INTO "public"."sys_log" VALUES (389, 5, 5, '菜单管理-删除', '', 2, 'admin', '/api/v1/menus/8', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-21 01:57:03.56148');
INSERT INTO "public"."sys_log" VALUES (390, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-21 01:57:03.89302');
INSERT INTO "public"."sys_log" VALUES (391, 5, 5, '菜单管理-删除', '', 2, 'admin', '/api/v1/menus/7', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-21 01:57:06.660796');
INSERT INTO "public"."sys_log" VALUES (392, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-21 01:57:06.98019');
INSERT INTO "public"."sys_log" VALUES (393, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-21 01:57:12.122797');
INSERT INTO "public"."sys_log" VALUES (394, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 2, '2026-07-21 02:06:10.128034');
INSERT INTO "public"."sys_log" VALUES (395, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 363, '2026-07-21 02:06:18.258686');
INSERT INTO "public"."sys_log" VALUES (396, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 291, '2026-07-21 10:03:18.122291');
INSERT INTO "public"."sys_log" VALUES (397, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 333, '2026-07-21 12:40:30.130985');
INSERT INTO "public"."sys_log" VALUES (398, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-21 12:43:24.449364');
INSERT INTO "public"."sys_log" VALUES (399, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-21 12:43:24.47906');
INSERT INTO "public"."sys_log" VALUES (400, 2, 4, '用户管理-修改', '', 2, 'admin', '/api/v1/users/10', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 46, '2026-07-21 12:43:32.640133');
INSERT INTO "public"."sys_log" VALUES (401, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-21 12:43:32.995271');
INSERT INTO "public"."sys_log" VALUES (402, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-21 12:43:36.280993');
INSERT INTO "public"."sys_log" VALUES (403, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-21 12:43:37.82851');
INSERT INTO "public"."sys_log" VALUES (404, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-21 12:43:40.112947');
INSERT INTO "public"."sys_log" VALUES (405, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-21 12:43:41.645172');
INSERT INTO "public"."sys_log" VALUES (406, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-21 12:43:46.746125');
INSERT INTO "public"."sys_log" VALUES (407, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 51, '2026-07-21 12:59:24.112264');
INSERT INTO "public"."sys_log" VALUES (408, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2818', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 229, '2026-07-21 12:59:51.25748');
INSERT INTO "public"."sys_log" VALUES (409, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-21 12:59:51.632379');
INSERT INTO "public"."sys_log" VALUES (410, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-21 13:44:51.886082');
INSERT INTO "public"."sys_log" VALUES (411, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 163, '2026-07-21 16:02:52.45922');
INSERT INTO "public"."sys_log" VALUES (412, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 541, '2026-07-21 18:42:46.178618');
INSERT INTO "public"."sys_log" VALUES (413, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 56, '2026-07-21 19:01:04.86541');
INSERT INTO "public"."sys_log" VALUES (414, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-21 19:01:04.909116');
INSERT INTO "public"."sys_log" VALUES (415, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-21 19:01:16.581877');
INSERT INTO "public"."sys_log" VALUES (416, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-21 19:01:18.008879');
INSERT INTO "public"."sys_log" VALUES (417, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 50, '2026-07-21 19:01:19.66949');
INSERT INTO "public"."sys_log" VALUES (418, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-21 19:01:20.238387');
INSERT INTO "public"."sys_log" VALUES (419, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 275, '2026-07-22 10:16:28.47776');
INSERT INTO "public"."sys_log" VALUES (420, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-07-22 10:16:38.197357');
INSERT INTO "public"."sys_log" VALUES (421, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-22 10:16:38.249341');
INSERT INTO "public"."sys_log" VALUES (422, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-22 10:16:48.246549');
INSERT INTO "public"."sys_log" VALUES (423, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-22 10:16:49.146404');
INSERT INTO "public"."sys_log" VALUES (424, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-22 10:17:14.012486');
INSERT INTO "public"."sys_log" VALUES (425, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-22 10:17:22.91035');
INSERT INTO "public"."sys_log" VALUES (426, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-22 10:17:49.339105');
INSERT INTO "public"."sys_log" VALUES (427, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-22 10:18:00.369415');
INSERT INTO "public"."sys_log" VALUES (428, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-22 10:18:03.031109');
INSERT INTO "public"."sys_log" VALUES (429, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-22 10:18:13.211409');
INSERT INTO "public"."sys_log" VALUES (430, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 10:18:22.581227');
INSERT INTO "public"."sys_log" VALUES (431, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 10:18:25.951115');
INSERT INTO "public"."sys_log" VALUES (432, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 175, '2026-07-22 14:51:51.856024');
INSERT INTO "public"."sys_log" VALUES (433, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 185, '2026-07-22 17:43:31.29289');
INSERT INTO "public"."sys_log" VALUES (434, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-22 17:43:35.904014');
INSERT INTO "public"."sys_log" VALUES (435, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 55, '2026-07-22 17:44:09.046206');
INSERT INTO "public"."sys_log" VALUES (436, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-22 17:44:09.376113');
INSERT INTO "public"."sys_log" VALUES (437, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-22 17:44:49.857524');
INSERT INTO "public"."sys_log" VALUES (438, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-22 17:44:50.189601');
INSERT INTO "public"."sys_log" VALUES (439, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-22 17:45:13.96129');
INSERT INTO "public"."sys_log" VALUES (440, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-22 17:45:14.311537');
INSERT INTO "public"."sys_log" VALUES (441, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 17:54:47.811877');
INSERT INTO "public"."sys_log" VALUES (442, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-22 17:54:48.178715');
INSERT INTO "public"."sys_log" VALUES (443, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-22 17:56:06.611586');
INSERT INTO "public"."sys_log" VALUES (444, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 17:56:06.952737');
INSERT INTO "public"."sys_log" VALUES (445, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-22 17:56:41.282828');
INSERT INTO "public"."sys_log" VALUES (446, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-22 17:56:41.640569');
INSERT INTO "public"."sys_log" VALUES (447, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-22 17:57:03.671505');
INSERT INTO "public"."sys_log" VALUES (448, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-22 17:57:04.009897');
INSERT INTO "public"."sys_log" VALUES (449, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-22 17:57:27.097172');
INSERT INTO "public"."sys_log" VALUES (450, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-22 17:57:27.429916');
INSERT INTO "public"."sys_log" VALUES (451, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-22 17:57:52.253938');
INSERT INTO "public"."sys_log" VALUES (452, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-22 17:57:52.58553');
INSERT INTO "public"."sys_log" VALUES (453, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 18:18:45.491729');
INSERT INTO "public"."sys_log" VALUES (454, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-07-22 18:18:48.541812');
INSERT INTO "public"."sys_log" VALUES (455, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 489, '2026-07-22 18:19:50.401842');
INSERT INTO "public"."sys_log" VALUES (456, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-22 18:19:50.784633');
INSERT INTO "public"."sys_log" VALUES (457, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2823', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 45, '2026-07-22 18:20:00.660489');
INSERT INTO "public"."sys_log" VALUES (458, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-22 18:20:01.0254');
INSERT INTO "public"."sys_log" VALUES (459, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-22 18:21:26.131358');
INSERT INTO "public"."sys_log" VALUES (460, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-22 18:21:26.493721');
INSERT INTO "public"."sys_log" VALUES (461, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-22 18:21:30.083919');
INSERT INTO "public"."sys_log" VALUES (462, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 102, '2026-07-22 18:21:38.348121');
INSERT INTO "public"."sys_log" VALUES (463, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-22 18:21:38.700632');
INSERT INTO "public"."sys_log" VALUES (464, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-22 18:21:41.141066');
INSERT INTO "public"."sys_log" VALUES (465, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-22 18:25:18.550327');
INSERT INTO "public"."sys_log" VALUES (466, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2823', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 49, '2026-07-22 18:26:05.377443');
INSERT INTO "public"."sys_log" VALUES (467, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-22 18:26:05.766193');
INSERT INTO "public"."sys_log" VALUES (468, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2824', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-22 18:26:52.447074');
INSERT INTO "public"."sys_log" VALUES (469, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 18:26:52.82012');
INSERT INTO "public"."sys_log" VALUES (470, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-22 18:26:56.742088');
INSERT INTO "public"."sys_log" VALUES (471, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 43, '2026-07-22 18:36:25.300091');
INSERT INTO "public"."sys_log" VALUES (472, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-22 18:39:43.855476');
INSERT INTO "public"."sys_log" VALUES (473, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-22 18:42:21.902342');
INSERT INTO "public"."sys_log" VALUES (474, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 18:42:53.021194');
INSERT INTO "public"."sys_log" VALUES (475, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-22 18:43:18.099815');
INSERT INTO "public"."sys_log" VALUES (476, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 323, '2026-07-22 21:30:33.474798');
INSERT INTO "public"."sys_log" VALUES (477, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 79, '2026-07-22 22:09:38.945788');
INSERT INTO "public"."sys_log" VALUES (478, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2823', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 123, '2026-07-22 22:10:13.306267');
INSERT INTO "public"."sys_log" VALUES (479, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 22:10:13.682789');
INSERT INTO "public"."sys_log" VALUES (480, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-22 23:14:32.112858');
INSERT INTO "public"."sys_log" VALUES (481, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2823', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 164, '2026-07-22 23:15:05.635184');
INSERT INTO "public"."sys_log" VALUES (482, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-22 23:15:06.034736');
INSERT INTO "public"."sys_log" VALUES (483, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-22 23:15:09.822969');
INSERT INTO "public"."sys_log" VALUES (484, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 23:15:22.469249');
INSERT INTO "public"."sys_log" VALUES (485, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2824', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 52, '2026-07-22 23:16:09.128033');
INSERT INTO "public"."sys_log" VALUES (486, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-22 23:16:09.496202');
INSERT INTO "public"."sys_log" VALUES (487, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 23:16:35.265844');
INSERT INTO "public"."sys_log" VALUES (488, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2824', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 35, '2026-07-22 23:26:12.37599');
INSERT INTO "public"."sys_log" VALUES (489, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-22 23:26:12.733586');
INSERT INTO "public"."sys_log" VALUES (490, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 587, '2026-07-22 23:27:40.238018');
INSERT INTO "public"."sys_log" VALUES (491, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-22 23:27:40.608881');
INSERT INTO "public"."sys_log" VALUES (492, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-22 23:27:59.64753');
INSERT INTO "public"."sys_log" VALUES (493, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-22 23:28:02.517945');
INSERT INTO "public"."sys_log" VALUES (494, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 164, '2026-07-22 23:28:10.902862');
INSERT INTO "public"."sys_log" VALUES (495, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-22 23:28:11.253251');
INSERT INTO "public"."sys_log" VALUES (496, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-22 23:28:30.95824');
INSERT INTO "public"."sys_log" VALUES (497, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2825', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-22 23:28:45.962675');
INSERT INTO "public"."sys_log" VALUES (498, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-22 23:28:46.335365');
INSERT INTO "public"."sys_log" VALUES (499, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-22 23:28:50.294798');
INSERT INTO "public"."sys_log" VALUES (500, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2825', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-22 23:29:15.605027');
INSERT INTO "public"."sys_log" VALUES (501, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-22 23:29:15.969399');
INSERT INTO "public"."sys_log" VALUES (502, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2823', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-22 23:30:04.779267');
INSERT INTO "public"."sys_log" VALUES (503, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-22 23:30:05.141769');
INSERT INTO "public"."sys_log" VALUES (504, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 92, '2026-07-22 23:31:17.260012');
INSERT INTO "public"."sys_log" VALUES (505, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 87, '2026-07-22 23:31:24.616403');
INSERT INTO "public"."sys_log" VALUES (506, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 81, '2026-07-22 23:31:31.647396');
INSERT INTO "public"."sys_log" VALUES (507, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 75, '2026-07-22 23:31:44.290426');
INSERT INTO "public"."sys_log" VALUES (508, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 74, '2026-07-22 23:32:12.689578');
INSERT INTO "public"."sys_log" VALUES (509, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 306, '2026-07-22 23:38:23.465275');
INSERT INTO "public"."sys_log" VALUES (510, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 81, '2026-07-22 23:40:48.923635');
INSERT INTO "public"."sys_log" VALUES (511, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 214, '2026-07-22 23:53:00.246393');
INSERT INTO "public"."sys_log" VALUES (512, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 88, '2026-07-22 23:58:39.805318');
INSERT INTO "public"."sys_log" VALUES (513, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-22 23:59:02.91439');
INSERT INTO "public"."sys_log" VALUES (514, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-22 23:59:02.939902');
INSERT INTO "public"."sys_log" VALUES (515, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-23 01:32:50.233379');
INSERT INTO "public"."sys_log" VALUES (516, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 239, '2026-07-23 02:06:48.135573');
INSERT INTO "public"."sys_log" VALUES (517, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-23 02:06:48.922307');
INSERT INTO "public"."sys_log" VALUES (518, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-23 02:06:51.854017');
INSERT INTO "public"."sys_log" VALUES (519, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-23 02:31:29.103064');
INSERT INTO "public"."sys_log" VALUES (520, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-23 02:31:29.327253');
INSERT INTO "public"."sys_log" VALUES (521, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-23 02:32:10.341897');
INSERT INTO "public"."sys_log" VALUES (522, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-23 02:32:10.586721');
INSERT INTO "public"."sys_log" VALUES (523, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-23 02:33:02.480038');
INSERT INTO "public"."sys_log" VALUES (524, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-23 02:33:02.741657');
INSERT INTO "public"."sys_log" VALUES (525, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-23 02:33:44.759923');
INSERT INTO "public"."sys_log" VALUES (526, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-23 02:33:45.022014');
INSERT INTO "public"."sys_log" VALUES (527, 7, 3, '系统配置-新增', '', 2, 'admin', '/api/v1/configs', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-23 02:34:23.624956');
INSERT INTO "public"."sys_log" VALUES (528, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-23 02:34:23.861566');
INSERT INTO "public"."sys_log" VALUES (529, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-23 02:37:01.04269');
INSERT INTO "public"."sys_log" VALUES (530, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-23 02:37:03.390667');
INSERT INTO "public"."sys_log" VALUES (531, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-23 02:54:58.666126');
INSERT INTO "public"."sys_log" VALUES (532, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 440, '2026-07-23 10:38:45.048058');
INSERT INTO "public"."sys_log" VALUES (533, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-23 10:39:49.953083');
INSERT INTO "public"."sys_log" VALUES (534, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-23 10:39:54.428998');
INSERT INTO "public"."sys_log" VALUES (535, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2807', 'PUT', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 154, '2026-07-23 10:40:02.956984');
INSERT INTO "public"."sys_log" VALUES (536, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-23 10:40:03.338409');
INSERT INTO "public"."sys_log" VALUES (537, 9, 15, '通知公告-查询列表', '', 2, 'admin', '/api/v1/notices', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 70, '2026-07-23 11:16:39.543057');
INSERT INTO "public"."sys_log" VALUES (538, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 43, '2026-07-23 11:17:30.657186');
INSERT INTO "public"."sys_log" VALUES (539, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-23 11:17:30.687141');
INSERT INTO "public"."sys_log" VALUES (540, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-23 11:17:36.255703');
INSERT INTO "public"."sys_log" VALUES (541, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '172.23.64.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 241, '2026-07-23 17:40:33.696799');
INSERT INTO "public"."sys_log" VALUES (542, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 312, '2026-07-24 00:51:58.345485');
INSERT INTO "public"."sys_log" VALUES (543, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-24 00:56:14.970685');
INSERT INTO "public"."sys_log" VALUES (544, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 00:56:14.993829');
INSERT INTO "public"."sys_log" VALUES (545, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 00:56:17.586229');
INSERT INTO "public"."sys_log" VALUES (546, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 00:56:19.353574');
INSERT INTO "public"."sys_log" VALUES (547, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 00:56:20.601189');
INSERT INTO "public"."sys_log" VALUES (548, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 00:56:24.308185');
INSERT INTO "public"."sys_log" VALUES (549, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 00:56:25.476388');
INSERT INTO "public"."sys_log" VALUES (550, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 00:56:27.147954');
INSERT INTO "public"."sys_log" VALUES (551, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 00:56:33.809868');
INSERT INTO "public"."sys_log" VALUES (552, 10, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 00:56:34.610212');
INSERT INTO "public"."sys_log" VALUES (553, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-24 00:56:37.764014');
INSERT INTO "public"."sys_log" VALUES (554, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 00:56:37.781692');
INSERT INTO "public"."sys_log" VALUES (555, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 00:56:38.723014');
INSERT INTO "public"."sys_log" VALUES (556, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 00:59:23.134033');
INSERT INTO "public"."sys_log" VALUES (557, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-24 01:08:32.97944');
INSERT INTO "public"."sys_log" VALUES (558, 5, 5, '菜单管理-删除', '', 2, 'admin', '/api/v1/menus/280', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 59, '2026-07-24 01:08:44.896931');
INSERT INTO "public"."sys_log" VALUES (559, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 01:08:44.925771');
INSERT INTO "public"."sys_log" VALUES (560, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-24 01:12:53.128411');
INSERT INTO "public"."sys_log" VALUES (561, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 01:12:53.157506');
INSERT INTO "public"."sys_log" VALUES (562, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 338, '2026-07-24 02:01:02.284977');
INSERT INTO "public"."sys_log" VALUES (563, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-07-24 02:01:11.187196');
INSERT INTO "public"."sys_log" VALUES (564, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-24 02:01:11.216653');
INSERT INTO "public"."sys_log" VALUES (565, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-24 02:01:12.576741');
INSERT INTO "public"."sys_log" VALUES (566, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-24 02:01:14.031114');
INSERT INTO "public"."sys_log" VALUES (567, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 02:01:15.1715');
INSERT INTO "public"."sys_log" VALUES (568, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-24 02:01:16.139587');
INSERT INTO "public"."sys_log" VALUES (569, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 02:01:17.248229');
INSERT INTO "public"."sys_log" VALUES (570, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 02:01:23.565286');
INSERT INTO "public"."sys_log" VALUES (571, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-24 02:01:56.670828');
INSERT INTO "public"."sys_log" VALUES (572, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-24 02:59:48.737878');
INSERT INTO "public"."sys_log" VALUES (573, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 211, '2026-07-24 02:59:52.964739');
INSERT INTO "public"."sys_log" VALUES (574, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-24 02:59:59.787646');
INSERT INTO "public"."sys_log" VALUES (575, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 02:59:59.810093');
INSERT INTO "public"."sys_log" VALUES (576, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 03:00:05.945999');
INSERT INTO "public"."sys_log" VALUES (577, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 277, '2026-07-24 10:01:35.392709');
INSERT INTO "public"."sys_log" VALUES (578, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 10:01:41.929146');
INSERT INTO "public"."sys_log" VALUES (579, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-24 10:01:56.880947');
INSERT INTO "public"."sys_log" VALUES (580, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 10:01:59.813883');
INSERT INTO "public"."sys_log" VALUES (581, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-24 10:07:11.637773');
INSERT INTO "public"."sys_log" VALUES (582, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-24 10:07:13.897138');
INSERT INTO "public"."sys_log" VALUES (583, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 10:07:13.918122');
INSERT INTO "public"."sys_log" VALUES (584, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 10:07:19.060369');
INSERT INTO "public"."sys_log" VALUES (585, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-24 10:13:52.554035');
INSERT INTO "public"."sys_log" VALUES (586, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-24 10:13:52.8907');
INSERT INTO "public"."sys_log" VALUES (587, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 10:13:58.490792');
INSERT INTO "public"."sys_log" VALUES (588, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-24 10:13:58.824952');
INSERT INTO "public"."sys_log" VALUES (589, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/3', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-24 10:14:06.054479');
INSERT INTO "public"."sys_log" VALUES (590, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 10:14:06.387012');
INSERT INTO "public"."sys_log" VALUES (591, 4, 3, '部门管理-新增', '', 2, 'admin', '/api/v1/depts', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 261, '2026-07-24 10:14:21.672413');
INSERT INTO "public"."sys_log" VALUES (592, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 10:14:22.005974');
INSERT INTO "public"."sys_log" VALUES (593, 4, 3, '部门管理-新增', '', 2, 'admin', '/api/v1/depts', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 10:14:49.530167');
INSERT INTO "public"."sys_log" VALUES (594, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 10:14:49.863954');
INSERT INTO "public"."sys_log" VALUES (595, 4, 3, '部门管理-新增', '', 2, 'admin', '/api/v1/depts', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 10:15:07.019463');
INSERT INTO "public"."sys_log" VALUES (596, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 10:15:07.354196');
INSERT INTO "public"."sys_log" VALUES (597, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 10:38:15.709939');
INSERT INTO "public"."sys_log" VALUES (598, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 10:47:33.38439');
INSERT INTO "public"."sys_log" VALUES (599, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-24 10:47:42.597987');
INSERT INTO "public"."sys_log" VALUES (600, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-24 10:50:51.646634');
INSERT INTO "public"."sys_log" VALUES (601, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-24 10:50:59.23966');
INSERT INTO "public"."sys_log" VALUES (602, 5, 5, '菜单管理-删除', '', 2, 'admin', '/api/v1/menus/2', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 56, '2026-07-24 10:51:04.201929');
INSERT INTO "public"."sys_log" VALUES (603, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 10:51:04.232761');
INSERT INTO "public"."sys_log" VALUES (604, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-24 10:51:46.671611');
INSERT INTO "public"."sys_log" VALUES (605, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-24 10:51:46.700923');
INSERT INTO "public"."sys_log" VALUES (606, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-24 10:52:54.750691');
INSERT INTO "public"."sys_log" VALUES (607, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 245, '2026-07-24 10:53:09.952993');
INSERT INTO "public"."sys_log" VALUES (608, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 10:54:27.424108');
INSERT INTO "public"."sys_log" VALUES (609, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 10:57:36.96931');
INSERT INTO "public"."sys_log" VALUES (610, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 10:57:44.502149');
INSERT INTO "public"."sys_log" VALUES (611, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 10:58:21.954271');
INSERT INTO "public"."sys_log" VALUES (612, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-24 10:58:57.978518');
INSERT INTO "public"."sys_log" VALUES (613, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 310, '2026-07-24 13:21:56.506197');
INSERT INTO "public"."sys_log" VALUES (614, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 13:30:24.096156');
INSERT INTO "public"."sys_log" VALUES (615, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-24 13:30:25.560662');
INSERT INTO "public"."sys_log" VALUES (616, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-24 13:30:25.588575');
INSERT INTO "public"."sys_log" VALUES (617, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 13:30:39.886613');
INSERT INTO "public"."sys_log" VALUES (618, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/10/menus', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 65, '2026-07-24 13:30:53.870275');
INSERT INTO "public"."sys_log" VALUES (619, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:30:54.212636');
INSERT INTO "public"."sys_log" VALUES (620, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 13:31:04.12087');
INSERT INTO "public"."sys_log" VALUES (621, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-24 13:31:12.637851');
INSERT INTO "public"."sys_log" VALUES (622, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 13:31:27.356315');
INSERT INTO "public"."sys_log" VALUES (623, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:31:31.803987');
INSERT INTO "public"."sys_log" VALUES (624, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 13:31:46.026397');
INSERT INTO "public"."sys_log" VALUES (625, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 13:31:47.412453');
INSERT INTO "public"."sys_log" VALUES (626, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 13:31:52.448605');
INSERT INTO "public"."sys_log" VALUES (627, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:32:03.731118');
INSERT INTO "public"."sys_log" VALUES (628, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 13:32:12.046296');
INSERT INTO "public"."sys_log" VALUES (629, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 13:32:20.894288');
INSERT INTO "public"."sys_log" VALUES (630, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:32:29.639756');
INSERT INTO "public"."sys_log" VALUES (631, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:32:33.917163');
INSERT INTO "public"."sys_log" VALUES (632, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:35:06.605064');
INSERT INTO "public"."sys_log" VALUES (633, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:35:09.067139');
INSERT INTO "public"."sys_log" VALUES (634, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:35:16.039659');
INSERT INTO "public"."sys_log" VALUES (635, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 13:35:19.209258');
INSERT INTO "public"."sys_log" VALUES (636, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 13:36:02.851691');
INSERT INTO "public"."sys_log" VALUES (637, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 13:36:04.725934');
INSERT INTO "public"."sys_log" VALUES (638, 83, 99, '库位/区域管理-其他', '', 2, 'admin', '/api/v1/wms-location/status', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-07-24 13:36:09.885419');
INSERT INTO "public"."sys_log" VALUES (639, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 13:36:10.218128');
INSERT INTO "public"."sys_log" VALUES (640, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 13:36:12.146372');
INSERT INTO "public"."sys_log" VALUES (641, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 13:36:13.174009');
INSERT INTO "public"."sys_log" VALUES (642, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 13:36:14.289895');
INSERT INTO "public"."sys_log" VALUES (643, 83, 99, '库位/区域管理-其他', '', 2, 'admin', '/api/v1/wms-location/status', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 13:36:17.684387');
INSERT INTO "public"."sys_log" VALUES (644, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 13:36:18.022301');
INSERT INTO "public"."sys_log" VALUES (645, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:36:58.277067');
INSERT INTO "public"."sys_log" VALUES (646, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 13:37:59.834362');
INSERT INTO "public"."sys_log" VALUES (647, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 13:39:54.627323');
INSERT INTO "public"."sys_log" VALUES (648, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 13:39:55.664128');
INSERT INTO "public"."sys_log" VALUES (649, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-24 13:41:46.553121');
INSERT INTO "public"."sys_log" VALUES (650, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-24 13:41:52.84321');
INSERT INTO "public"."sys_log" VALUES (651, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-24 13:41:54.188448');
INSERT INTO "public"."sys_log" VALUES (652, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:41:59.460628');
INSERT INTO "public"."sys_log" VALUES (653, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 13:42:02.767108');
INSERT INTO "public"."sys_log" VALUES (654, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:42:05.689293');
INSERT INTO "public"."sys_log" VALUES (655, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:42:08.427772');
INSERT INTO "public"."sys_log" VALUES (656, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 13:46:29.3361');
INSERT INTO "public"."sys_log" VALUES (657, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 13:47:05.280932');
INSERT INTO "public"."sys_log" VALUES (658, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-24 13:48:31.336335');
INSERT INTO "public"."sys_log" VALUES (659, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-24 13:48:36.196232');
INSERT INTO "public"."sys_log" VALUES (660, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-24 13:48:57.256983');
INSERT INTO "public"."sys_log" VALUES (661, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 13:48:57.436572');
INSERT INTO "public"."sys_log" VALUES (662, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 13:49:06.11765');
INSERT INTO "public"."sys_log" VALUES (663, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-24 13:49:07.316281');
INSERT INTO "public"."sys_log" VALUES (664, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 13:49:07.977001');
INSERT INTO "public"."sys_log" VALUES (665, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 13:49:11.002701');
INSERT INTO "public"."sys_log" VALUES (666, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-24 13:49:54.896676');
INSERT INTO "public"."sys_log" VALUES (667, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 13:50:04.445577');
INSERT INTO "public"."sys_log" VALUES (668, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:50:08.229006');
INSERT INTO "public"."sys_log" VALUES (669, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 13:50:10.09079');
INSERT INTO "public"."sys_log" VALUES (670, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:50:17.898506');
INSERT INTO "public"."sys_log" VALUES (671, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:50:30.462731');
INSERT INTO "public"."sys_log" VALUES (672, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 13:50:37.17906');
INSERT INTO "public"."sys_log" VALUES (673, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 13:50:40.864513');
INSERT INTO "public"."sys_log" VALUES (674, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 13:50:43.023659');
INSERT INTO "public"."sys_log" VALUES (675, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:50:43.474806');
INSERT INTO "public"."sys_log" VALUES (676, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:50:46.717051');
INSERT INTO "public"."sys_log" VALUES (677, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-24 13:50:54.58644');
INSERT INTO "public"."sys_log" VALUES (678, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 13:50:54.934881');
INSERT INTO "public"."sys_log" VALUES (679, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:50:56.945452');
INSERT INTO "public"."sys_log" VALUES (680, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:51:14.259767');
INSERT INTO "public"."sys_log" VALUES (681, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 13:51:20.266581');
INSERT INTO "public"."sys_log" VALUES (682, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:51:21.374098');
INSERT INTO "public"."sys_log" VALUES (683, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:51:24.760031');
INSERT INTO "public"."sys_log" VALUES (684, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 13:51:40.596852');
INSERT INTO "public"."sys_log" VALUES (685, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:51:40.920101');
INSERT INTO "public"."sys_log" VALUES (686, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 13:55:54.632122');
INSERT INTO "public"."sys_log" VALUES (687, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 13:56:05.655587');
INSERT INTO "public"."sys_log" VALUES (688, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:56:09.591313');
INSERT INTO "public"."sys_log" VALUES (689, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:56:11.464853');
INSERT INTO "public"."sys_log" VALUES (690, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 13:56:15.53262');
INSERT INTO "public"."sys_log" VALUES (691, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 13:58:03.587624');
INSERT INTO "public"."sys_log" VALUES (692, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 13:58:09.29283');
INSERT INTO "public"."sys_log" VALUES (693, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 13:58:12.567643');
INSERT INTO "public"."sys_log" VALUES (694, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 13:58:12.786618');
INSERT INTO "public"."sys_log" VALUES (695, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-24 14:11:34.375901');
INSERT INTO "public"."sys_log" VALUES (696, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-24 14:11:34.510278');
INSERT INTO "public"."sys_log" VALUES (697, 2, 4, '用户管理-修改', '', 2, 'admin', '/api/v1/users/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 46, '2026-07-24 14:11:47.472799');
INSERT INTO "public"."sys_log" VALUES (698, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 246, '2026-07-24 14:11:52.838709');
INSERT INTO "public"."sys_log" VALUES (699, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 14:12:19.870099');
INSERT INTO "public"."sys_log" VALUES (700, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 14:12:22.113898');
INSERT INTO "public"."sys_log" VALUES (701, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 14:12:23.459915');
INSERT INTO "public"."sys_log" VALUES (702, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 14:12:41.909097');
INSERT INTO "public"."sys_log" VALUES (703, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 15:33:00.877333');
INSERT INTO "public"."sys_log" VALUES (704, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 15:33:04.458913');
INSERT INTO "public"."sys_log" VALUES (705, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 15:33:06.014603');
INSERT INTO "public"."sys_log" VALUES (706, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 15:33:09.476087');
INSERT INTO "public"."sys_log" VALUES (707, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 15:33:22.441876');
INSERT INTO "public"."sys_log" VALUES (708, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-24 15:33:29.113831');
INSERT INTO "public"."sys_log" VALUES (709, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2808', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 90, '2026-07-24 15:33:58.448751');
INSERT INTO "public"."sys_log" VALUES (710, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 15:33:58.500944');
INSERT INTO "public"."sys_log" VALUES (711, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 15:34:17.190352');
INSERT INTO "public"."sys_log" VALUES (712, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 15:34:18.049829');
INSERT INTO "public"."sys_log" VALUES (713, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 15:34:19.541195');
INSERT INTO "public"."sys_log" VALUES (714, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 15:34:20.586535');
INSERT INTO "public"."sys_log" VALUES (715, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 0, '2026-07-24 15:36:42.040466');
INSERT INTO "public"."sys_log" VALUES (716, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 114, '2026-07-24 15:36:46.613006');
INSERT INTO "public"."sys_log" VALUES (717, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 15:36:46.757156');
INSERT INTO "public"."sys_log" VALUES (718, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 15:48:35.507437');
INSERT INTO "public"."sys_log" VALUES (719, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 15:48:37.628138');
INSERT INTO "public"."sys_log" VALUES (720, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/2', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该区域下存在2条巷道，请先删除巷道后重试', 30, '2026-07-24 15:59:46.88483');
INSERT INTO "public"."sys_log" VALUES (721, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-24 15:59:53.074596');
INSERT INTO "public"."sys_log" VALUES (722, 82, 5, '巷道管理-删除', '', 2, 'admin', '/api/v1/wms-aisle/27', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该巷道下存在5个点位，请先删除点位后重试', 8, '2026-07-24 15:59:57.950146');
INSERT INTO "public"."sys_log" VALUES (723, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-24 16:00:03.423522');
INSERT INTO "public"."sys_log" VALUES (724, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 16:00:03.758315');
INSERT INTO "public"."sys_log" VALUES (725, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 16:00:04.717899');
INSERT INTO "public"."sys_log" VALUES (726, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 16:00:05.035702');
INSERT INTO "public"."sys_log" VALUES (727, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 16:00:27.039436');
INSERT INTO "public"."sys_log" VALUES (728, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 290, '2026-07-24 16:39:48.561572');
INSERT INTO "public"."sys_log" VALUES (729, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-24 16:39:51.002793');
INSERT INTO "public"."sys_log" VALUES (730, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-24 16:39:52.177668');
INSERT INTO "public"."sys_log" VALUES (731, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-24 16:39:53.220001');
INSERT INTO "public"."sys_log" VALUES (732, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 61, '2026-07-24 16:52:12.353802');
INSERT INTO "public"."sys_log" VALUES (733, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-24 16:56:09.244978');
INSERT INTO "public"."sys_log" VALUES (734, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-24 16:56:19.988482');
INSERT INTO "public"."sys_log" VALUES (735, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/2', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该区域下存在2条巷道，请先删除巷道后重试', 27, '2026-07-24 16:56:25.518252');
INSERT INTO "public"."sys_log" VALUES (736, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/2', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该区域下存在2条巷道，请先删除巷道后重试', 10, '2026-07-24 16:56:29.579922');
INSERT INTO "public"."sys_log" VALUES (737, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-24 16:56:31.392358');
INSERT INTO "public"."sys_log" VALUES (738, 82, 5, '巷道管理-删除', '', 2, 'admin', '/api/v1/wms-aisle/27', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该巷道下存在5个点位，请先删除点位后重试', 11, '2026-07-24 16:56:33.391515');
INSERT INTO "public"."sys_log" VALUES (739, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-24 16:57:18.380428');
INSERT INTO "public"."sys_log" VALUES (740, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 16:57:37.539687');
INSERT INTO "public"."sys_log" VALUES (741, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/4', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-24 16:57:58.138142');
INSERT INTO "public"."sys_log" VALUES (742, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 16:57:58.481415');
INSERT INTO "public"."sys_log" VALUES (743, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 272, '2026-07-24 16:58:46.574477');
INSERT INTO "public"."sys_log" VALUES (744, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 16:58:46.914799');
INSERT INTO "public"."sys_log" VALUES (745, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/3', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该区域下存在2条巷道，请先删除巷道后重试', 8, '2026-07-24 16:59:18.328201');
INSERT INTO "public"."sys_log" VALUES (746, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/57', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-24 16:59:23.729491');
INSERT INTO "public"."sys_log" VALUES (747, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 16:59:24.061126');
INSERT INTO "public"."sys_log" VALUES (748, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/4', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 16:59:37.031142');
INSERT INTO "public"."sys_log" VALUES (749, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 16:59:37.362947');
INSERT INTO "public"."sys_log" VALUES (750, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 16:59:50.70193');
INSERT INTO "public"."sys_log" VALUES (751, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 17:03:02.307537');
INSERT INTO "public"."sys_log" VALUES (752, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 17:11:40.939629');
INSERT INTO "public"."sys_log" VALUES (753, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 191, '2026-07-24 17:15:24.990024');
INSERT INTO "public"."sys_log" VALUES (754, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 79, '2026-07-24 17:15:31.467685');
INSERT INTO "public"."sys_log" VALUES (755, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 73, '2026-07-24 17:17:09.072464');
INSERT INTO "public"."sys_log" VALUES (756, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-24 17:17:12.723382');
INSERT INTO "public"."sys_log" VALUES (757, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-24 17:17:12.857128');
INSERT INTO "public"."sys_log" VALUES (758, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 17:17:18.638026');
INSERT INTO "public"."sys_log" VALUES (759, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 17:17:23.824395');
INSERT INTO "public"."sys_log" VALUES (760, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 17:17:26.402702');
INSERT INTO "public"."sys_log" VALUES (761, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 17:17:42.815471');
INSERT INTO "public"."sys_log" VALUES (762, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 17:17:50.535599');
INSERT INTO "public"."sys_log" VALUES (763, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 17:17:51.53784');
INSERT INTO "public"."sys_log" VALUES (764, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 17:18:01.031775');
INSERT INTO "public"."sys_log" VALUES (765, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 17:20:03.175219');
INSERT INTO "public"."sys_log" VALUES (766, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 17:20:03.977164');
INSERT INTO "public"."sys_log" VALUES (767, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-24 17:20:22.284875');
INSERT INTO "public"."sys_log" VALUES (768, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-24 17:20:32.158724');
INSERT INTO "public"."sys_log" VALUES (769, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 17:23:34.378426');
INSERT INTO "public"."sys_log" VALUES (770, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-24 17:23:41.463669');
INSERT INTO "public"."sys_log" VALUES (771, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 17:25:07.962239');
INSERT INTO "public"."sys_log" VALUES (772, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 17:25:16.447151');
INSERT INTO "public"."sys_log" VALUES (773, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 17:25:26.009493');
INSERT INTO "public"."sys_log" VALUES (774, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 17:28:59.68302');
INSERT INTO "public"."sys_log" VALUES (775, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-24 17:29:07.027411');
INSERT INTO "public"."sys_log" VALUES (776, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 186, '2026-07-24 17:29:10.192661');
INSERT INTO "public"."sys_log" VALUES (777, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 17:29:10.654509');
INSERT INTO "public"."sys_log" VALUES (778, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-24 17:29:25.551244');
INSERT INTO "public"."sys_log" VALUES (779, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 17:30:41.864633');
INSERT INTO "public"."sys_log" VALUES (780, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 17:30:54.96151');
INSERT INTO "public"."sys_log" VALUES (781, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-24 17:31:00.914686');
INSERT INTO "public"."sys_log" VALUES (782, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 17:31:00.942336');
INSERT INTO "public"."sys_log" VALUES (783, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 17:31:03.294336');
INSERT INTO "public"."sys_log" VALUES (784, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 17:31:31.650733');
INSERT INTO "public"."sys_log" VALUES (785, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 18:18:44.059135');
INSERT INTO "public"."sys_log" VALUES (786, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 183, '2026-07-24 22:53:11.976203');
INSERT INTO "public"."sys_log" VALUES (787, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-24 22:55:21.915575');
INSERT INTO "public"."sys_log" VALUES (788, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-24 22:55:23.693358');
INSERT INTO "public"."sys_log" VALUES (789, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 2, '2026-07-24 22:57:20.867141');
INSERT INTO "public"."sys_log" VALUES (790, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 22:57:45.231854');
INSERT INTO "public"."sys_log" VALUES (791, 4, 4, '部门管理-修改', '', 2, 'admin', '/api/v1/depts/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 22:58:05.455538');
INSERT INTO "public"."sys_log" VALUES (792, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 2, '2026-07-24 22:58:05.790687');
INSERT INTO "public"."sys_log" VALUES (793, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-24 22:58:11.928364');
INSERT INTO "public"."sys_log" VALUES (794, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 22:58:13.186394');
INSERT INTO "public"."sys_log" VALUES (795, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 22:58:13.204555');
INSERT INTO "public"."sys_log" VALUES (796, 2, 12, '用户管理-重置密码', '', 2, 'admin', '/api/v1/users/7/password/reset', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 71, '2026-07-24 22:58:32.229596');
INSERT INTO "public"."sys_log" VALUES (797, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 0, '2026-07-24 22:58:44.475416');
INSERT INTO "public"."sys_log" VALUES (798, 1, 1, '登录-登录', '', 7, 'custom_user', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 77, '2026-07-24 22:58:54.328002');
INSERT INTO "public"."sys_log" VALUES (799, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 22:59:08.783925');
INSERT INTO "public"."sys_log" VALUES (800, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-24 22:59:12.588677');
INSERT INTO "public"."sys_log" VALUES (801, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 22:59:16.570517');
INSERT INTO "public"."sys_log" VALUES (802, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 22:59:18.988832');
INSERT INTO "public"."sys_log" VALUES (803, 1, 2, '登录-登出', '', 7, 'custom_user', '/api/v1/auth/logout', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 0, '2026-07-24 22:59:46.966538');
INSERT INTO "public"."sys_log" VALUES (804, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 71, '2026-07-24 22:59:59.184426');
INSERT INTO "public"."sys_log" VALUES (805, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 23:00:04.280555');
INSERT INTO "public"."sys_log" VALUES (806, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-24 23:00:06.007141');
INSERT INTO "public"."sys_log" VALUES (807, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 23:00:07.850681');
INSERT INTO "public"."sys_log" VALUES (808, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 23:00:08.036263');
INSERT INTO "public"."sys_log" VALUES (809, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 23:00:08.05426');
INSERT INTO "public"."sys_log" VALUES (810, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/7/menus', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-24 23:00:25.27968');
INSERT INTO "public"."sys_log" VALUES (811, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-24 23:00:25.61653');
INSERT INTO "public"."sys_log" VALUES (814, 83, 15, '库位/区域管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 23:00:48.732143');
INSERT INTO "public"."sys_log" VALUES (815, 83, 15, '库位/区域管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-24 23:00:55.137723');
INSERT INTO "public"."sys_log" VALUES (816, 83, 15, '库位/区域管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 23:00:56.421886');
INSERT INTO "public"."sys_log" VALUES (817, 83, 15, '库位/区域管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 23:00:57.328687');
INSERT INTO "public"."sys_log" VALUES (818, 82, 15, '巷道管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 23:00:58.985652');
INSERT INTO "public"."sys_log" VALUES (819, 81, 15, '点位管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 23:00:59.796193');
INSERT INTO "public"."sys_log" VALUES (820, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 23:01:08.408888');
INSERT INTO "public"."sys_log" VALUES (821, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 23:01:24.214602');
INSERT INTO "public"."sys_log" VALUES (822, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 23:01:35.029972');
INSERT INTO "public"."sys_log" VALUES (823, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 23:01:38.696728');
INSERT INTO "public"."sys_log" VALUES (824, 1, 2, '登录-登出', '', 7, 'custom_user', '/api/v1/auth/logout', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 0, '2026-07-24 23:01:44.165008');
INSERT INTO "public"."sys_log" VALUES (825, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 75, '2026-07-24 23:02:23.128228');
INSERT INTO "public"."sys_log" VALUES (826, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 6, '2026-07-24 23:02:23.474226');
INSERT INTO "public"."sys_log" VALUES (827, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 4, '2026-07-24 23:02:44.486639');
INSERT INTO "public"."sys_log" VALUES (828, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 6, '2026-07-24 23:02:46.581779');
INSERT INTO "public"."sys_log" VALUES (829, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 11, '2026-07-24 23:02:46.598755');
INSERT INTO "public"."sys_log" VALUES (830, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 5, '2026-07-24 23:02:48.793611');
INSERT INTO "public"."sys_log" VALUES (831, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 6, '2026-07-24 23:02:50.005108');
INSERT INTO "public"."sys_log" VALUES (832, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 10, '2026-07-24 23:02:51.154662');
INSERT INTO "public"."sys_log" VALUES (833, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 6, '2026-07-24 23:02:51.413652');
INSERT INTO "public"."sys_log" VALUES (834, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 5, '2026-07-24 23:02:52.64577');
INSERT INTO "public"."sys_log" VALUES (835, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 4, '2026-07-24 23:02:58.007673');
INSERT INTO "public"."sys_log" VALUES (836, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 6, '2026-07-24 23:02:59.760218');
INSERT INTO "public"."sys_log" VALUES (837, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 7, '2026-07-24 23:03:02.129243');
INSERT INTO "public"."sys_log" VALUES (838, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 4, '2026-07-24 23:03:03.01372');
INSERT INTO "public"."sys_log" VALUES (839, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 5, '2026-07-24 23:03:03.632269');
INSERT INTO "public"."sys_log" VALUES (840, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 7, '2026-07-24 23:03:04.378357');
INSERT INTO "public"."sys_log" VALUES (841, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 6, '2026-07-24 23:03:04.643598');
INSERT INTO "public"."sys_log" VALUES (842, 1, 1, '登录-登录', '', 7, 'custom_user', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 72, '2026-07-24 23:03:36.24965');
INSERT INTO "public"."sys_log" VALUES (812, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-24 23:00:33.477358');
INSERT INTO "public"."sys_log" VALUES (813, 1, 1, '登录-登录', '', 7, 'custom_user', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 72, '2026-07-24 23:00:46.474041');
INSERT INTO "public"."sys_log" VALUES (843, 83, 15, '库位/区域管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-24 23:03:38.440017');
INSERT INTO "public"."sys_log" VALUES (844, 82, 15, '巷道管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-24 23:03:43.649625');
INSERT INTO "public"."sys_log" VALUES (845, 81, 15, '点位管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-24 23:03:45.12346');
INSERT INTO "public"."sys_log" VALUES (846, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 3, '2026-07-24 23:05:41.605162');
INSERT INTO "public"."sys_log" VALUES (847, 82, 15, '巷道管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-24 23:09:46.038226');
INSERT INTO "public"."sys_log" VALUES (848, 82, 15, '巷道管理-查询列表', '', 7, 'custom_user', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 23:09:51.382334');
INSERT INTO "public"."sys_log" VALUES (849, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-24 23:09:56.503708');
INSERT INTO "public"."sys_log" VALUES (850, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-24 23:09:56.519865');
INSERT INTO "public"."sys_log" VALUES (851, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 2, '2026-07-24 23:11:16.397754');
INSERT INTO "public"."sys_log" VALUES (852, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 1, '2026-07-24 23:11:16.967667');
INSERT INTO "public"."sys_log" VALUES (853, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 2, '2026-07-24 23:11:17.792227');
INSERT INTO "public"."sys_log" VALUES (854, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-24 23:13:01.377554');
INSERT INTO "public"."sys_log" VALUES (855, 2, 15, '用户管理-查询列表', '', 7, 'custom_user', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-24 23:13:01.42665');
INSERT INTO "public"."sys_log" VALUES (856, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 6, '2026-07-24 23:13:07.923515');
INSERT INTO "public"."sys_log" VALUES (857, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 12, '2026-07-24 23:13:17.829532');
INSERT INTO "public"."sys_log" VALUES (858, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 12, '2026-07-24 23:13:19.833499');
INSERT INTO "public"."sys_log" VALUES (859, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'Chrome', 1, NULL, 11, '2026-07-24 23:13:21.730381');
INSERT INTO "public"."sys_log" VALUES (860, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 294, '2026-07-25 12:33:20.708217');
INSERT INTO "public"."sys_log" VALUES (861, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-25 12:33:24.49143');
INSERT INTO "public"."sys_log" VALUES (862, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-25 12:33:33.224356');
INSERT INTO "public"."sys_log" VALUES (863, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 37, '2026-07-25 12:33:39.744894');
INSERT INTO "public"."sys_log" VALUES (864, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-25 12:34:01.28892');
INSERT INTO "public"."sys_log" VALUES (865, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Android', 'Android', 'Chrome', 1, NULL, 14, '2026-07-25 12:35:36.662802');
INSERT INTO "public"."sys_log" VALUES (866, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-25 14:29:44.247559');
INSERT INTO "public"."sys_log" VALUES (867, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 76, '2026-07-25 14:35:47.330733');
INSERT INTO "public"."sys_log" VALUES (868, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-25 14:35:59.296148');
INSERT INTO "public"."sys_log" VALUES (869, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-25 14:36:01.458029');
INSERT INTO "public"."sys_log" VALUES (870, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-25 14:36:03.926637');
INSERT INTO "public"."sys_log" VALUES (871, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-25 14:36:08.476305');
INSERT INTO "public"."sys_log" VALUES (872, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-25 14:36:10.345493');
INSERT INTO "public"."sys_log" VALUES (873, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-25 14:36:13.140415');
INSERT INTO "public"."sys_log" VALUES (874, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-25 14:36:15.666441');
INSERT INTO "public"."sys_log" VALUES (875, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 243, '2026-07-25 14:39:07.416423');
INSERT INTO "public"."sys_log" VALUES (876, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1145, '2026-07-27 10:38:28.377366');
INSERT INTO "public"."sys_log" VALUES (877, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 91, '2026-07-27 10:39:49.490127');
INSERT INTO "public"."sys_log" VALUES (878, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 446, '2026-07-27 13:19:24.960902');
INSERT INTO "public"."sys_log" VALUES (879, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 284, '2026-07-27 13:21:43.731201');
INSERT INTO "public"."sys_log" VALUES (880, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 323, '2026-07-27 13:21:54.808472');
INSERT INTO "public"."sys_log" VALUES (881, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 70, '2026-07-27 13:21:55.932441');
INSERT INTO "public"."sys_log" VALUES (882, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 13:21:57.646086');
INSERT INTO "public"."sys_log" VALUES (883, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/30,31,32,33,34,35,36,37,38', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该区域下存在2条巷道，请先删除巷道后重试', 1066, '2026-07-27 13:22:06.896854');
INSERT INTO "public"."sys_log" VALUES (884, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1071, '2026-07-27 13:22:11.646892');
INSERT INTO "public"."sys_log" VALUES (885, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 132, '2026-07-27 13:22:35.35849');
INSERT INTO "public"."sys_log" VALUES (886, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-27 13:28:00.282272');
INSERT INTO "public"."sys_log" VALUES (887, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 13:28:03.285417');
INSERT INTO "public"."sys_log" VALUES (888, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 13:28:09.639938');
INSERT INTO "public"."sys_log" VALUES (889, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 13:28:13.129331');
INSERT INTO "public"."sys_log" VALUES (890, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 13:28:13.786537');
INSERT INTO "public"."sys_log" VALUES (891, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 13:28:19.382739');
INSERT INTO "public"."sys_log" VALUES (892, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 13:28:22.01622');
INSERT INTO "public"."sys_log" VALUES (893, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 514, '2026-07-27 13:29:11.648182');
INSERT INTO "public"."sys_log" VALUES (894, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 13:29:13.884355');
INSERT INTO "public"."sys_log" VALUES (895, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 13:29:17.995025');
INSERT INTO "public"."sys_log" VALUES (896, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/30', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该区域下存在2条巷道，请先删除巷道后重试', 22, '2026-07-27 13:29:26.380368');
INSERT INTO "public"."sys_log" VALUES (897, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 13:29:29.014673');
INSERT INTO "public"."sys_log" VALUES (898, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 72, '2026-07-27 13:29:39.034211');
INSERT INTO "public"."sys_log" VALUES (899, 82, 5, '巷道管理-删除', '', 2, 'admin', '/api/v1/wms-aisle/69', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '该巷道下存在5个点位，请先删除点位后重试', 20, '2026-07-27 13:29:45.301681');
INSERT INTO "public"."sys_log" VALUES (900, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-07-27 13:29:47.705956');
INSERT INTO "public"."sys_log" VALUES (901, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/2,3,4,5,6,7,8,9,10,11', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 715, '2026-07-27 13:29:53.535167');
INSERT INTO "public"."sys_log" VALUES (902, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 13:29:54.058313');
INSERT INTO "public"."sys_log" VALUES (903, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/12,13,14,15,16,17,18,19,20,21', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 152, '2026-07-27 13:29:56.821121');
INSERT INTO "public"."sys_log" VALUES (904, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 67, '2026-07-27 13:29:57.449059');
INSERT INTO "public"."sys_log" VALUES (905, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/22,23,24,25,26,27,28,29,30,31', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 607, '2026-07-27 13:30:01.223595');
INSERT INTO "public"."sys_log" VALUES (906, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 13:30:01.599826');
INSERT INTO "public"."sys_log" VALUES (908, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-27 13:31:42.268287');
INSERT INTO "public"."sys_log" VALUES (909, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 13:40:46.994103');
INSERT INTO "public"."sys_log" VALUES (918, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 49, '2026-07-27 13:43:24.143128');
INSERT INTO "public"."sys_log" VALUES (919, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 13:43:34.518052');
INSERT INTO "public"."sys_log" VALUES (920, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-27 13:43:42.409005');
INSERT INTO "public"."sys_log" VALUES (921, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/32,33,34,35,36,37,38,43,44,45', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 163, '2026-07-27 13:43:49.006502');
INSERT INTO "public"."sys_log" VALUES (922, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 426, '2026-07-27 13:43:49.78761');
INSERT INTO "public"."sys_log" VALUES (923, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/46,47,48,49,50,51,52,53,54,55', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 233, '2026-07-27 13:43:53.798502');
INSERT INTO "public"."sys_log" VALUES (924, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-27 13:43:54.233613');
INSERT INTO "public"."sys_log" VALUES (925, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/56,61,62,63,64,65,66,67,68,69', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 298, '2026-07-27 13:43:58.502611');
INSERT INTO "public"."sys_log" VALUES (926, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 50, '2026-07-27 13:43:58.97145');
INSERT INTO "public"."sys_log" VALUES (907, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-27 13:30:59.363121');
INSERT INTO "public"."sys_log" VALUES (910, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-27 13:40:49.609455');
INSERT INTO "public"."sys_log" VALUES (911, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 13:40:51.28523');
INSERT INTO "public"."sys_log" VALUES (912, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 13:40:53.430275');
INSERT INTO "public"."sys_log" VALUES (913, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 54, '2026-07-27 13:40:56.518862');
INSERT INTO "public"."sys_log" VALUES (914, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 13:40:59.491308');
INSERT INTO "public"."sys_log" VALUES (915, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-27 13:41:05.012608');
INSERT INTO "public"."sys_log" VALUES (916, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 189, '2026-07-27 13:41:12.658363');
INSERT INTO "public"."sys_log" VALUES (917, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 47, '2026-07-27 13:41:13.742717');
INSERT INTO "public"."sys_log" VALUES (948, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 45, '2026-07-27 13:45:33.012524');
INSERT INTO "public"."sys_log" VALUES (949, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-07-27 13:45:33.991789');
INSERT INTO "public"."sys_log" VALUES (950, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-27 13:45:34.333201');
INSERT INTO "public"."sys_log" VALUES (951, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/39,40,41,42,57,58,59,60,75,76', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 121, '2026-07-27 13:45:37.379795');
INSERT INTO "public"."sys_log" VALUES (952, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 13:45:37.748624');
INSERT INTO "public"."sys_log" VALUES (953, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-07-27 13:45:39.089291');
INSERT INTO "public"."sys_log" VALUES (954, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/77,85,86,87,88,89,90,91,92,93,113,114,115,116,131,132,133,134,149,150,151,159,160,161,162,163,164,165,166,167,187,188,189,190,205,206,207,208,223,224,225,233,234,235,236,237,238,239,240,241', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1017, '2026-07-27 13:45:42.563198');
INSERT INTO "public"."sys_log" VALUES (955, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-27 13:45:42.921239');
INSERT INTO "public"."sys_log" VALUES (956, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/261,262,263,264,279,280,281,282,297,298,299,307,308,309,310,311,312,313,314,315,335,336,337,338,353,354,355,356', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 458, '2026-07-27 13:45:47.691529');
INSERT INTO "public"."sys_log" VALUES (957, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 13:45:48.092223');
INSERT INTO "public"."sys_log" VALUES (958, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 13:45:52.252714');
INSERT INTO "public"."sys_log" VALUES (959, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-07-27 13:49:27.933005');
INSERT INTO "public"."sys_log" VALUES (960, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-07-27 13:49:31.909626');
INSERT INTO "public"."sys_log" VALUES (961, 82, 5, '巷道管理-删除', '', 2, 'admin', '/api/v1/wms-aisle/27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59,61,63,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99,28,30,32,34,36,38,40,42,44,46,48,50,52', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 673, '2026-07-27 13:49:35.096973');
INSERT INTO "public"."sys_log" VALUES (962, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-27 13:49:35.560123');
INSERT INTO "public"."sys_log" VALUES (963, 82, 5, '巷道管理-删除', '', 2, 'admin', '/api/v1/wms-aisle/54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 316, '2026-07-27 13:49:38.275821');
INSERT INTO "public"."sys_log" VALUES (964, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 13:49:38.655907');
INSERT INTO "public"."sys_log" VALUES (965, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/2,30,39,48,3,31,40,49,4,32', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 166, '2026-07-27 13:49:44.482325');
INSERT INTO "public"."sys_log" VALUES (966, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 13:49:44.897383');
INSERT INTO "public"."sys_log" VALUES (967, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 13:49:49.611243');
INSERT INTO "public"."sys_log" VALUES (968, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/41,50,5,33,42,51,6,34,43,52,7,35,44,53,8,36,45,54,9,37,46,55,10,38,47,56,11', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 430, '2026-07-27 13:49:53.79235');
INSERT INTO "public"."sys_log" VALUES (969, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 13:49:54.148261');
INSERT INTO "public"."sys_log" VALUES (970, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-27 13:49:56.648927');
INSERT INTO "public"."sys_log" VALUES (971, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 13:49:57.17168');
INSERT INTO "public"."sys_log" VALUES (972, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-27 13:50:21.082665');
INSERT INTO "public"."sys_log" VALUES (927, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/70,71,72,73,74,78,79,80,81,82', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 138, '2026-07-27 13:44:03.978727');
INSERT INTO "public"."sys_log" VALUES (928, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 13:44:04.349864');
INSERT INTO "public"."sys_log" VALUES (929, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/83,84,94,95,96,97,98,99,100,101', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 166, '2026-07-27 13:44:09.688741');
INSERT INTO "public"."sys_log" VALUES (930, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-27 13:44:10.055963');
INSERT INTO "public"."sys_log" VALUES (931, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/102,103,104,105,106,107,108,109,110,111', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 166, '2026-07-27 13:44:27.723524');
INSERT INTO "public"."sys_log" VALUES (932, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 13:44:28.086041');
INSERT INTO "public"."sys_log" VALUES (933, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/112,117,118,119,120,121,122,123,124,125', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 169, '2026-07-27 13:44:34.630322');
INSERT INTO "public"."sys_log" VALUES (934, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-27 13:44:35.023965');
INSERT INTO "public"."sys_log" VALUES (935, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/126,127,128,129,130,135,136,137,138,139', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 150, '2026-07-27 13:44:38.985078');
INSERT INTO "public"."sys_log" VALUES (936, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 13:44:39.358121');
INSERT INTO "public"."sys_log" VALUES (937, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 41, '2026-07-27 13:44:43.187281');
INSERT INTO "public"."sys_log" VALUES (938, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/140,141,142,143,144,145,146,147,148,152,153,154,155,156,157,158,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,191,192,193,194,195,196,197,198,199,200,201,202,203,204,209', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 865, '2026-07-27 13:44:53.630158');
INSERT INTO "public"."sys_log" VALUES (939, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 13:44:54.029941');
INSERT INTO "public"."sys_log" VALUES (940, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/210,211,212,213,214,215,216,217,218,219,220,221,222,226,227,228,229,230,231,232,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,265,266,267,268,269,270,271,272,273,274,275', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 772, '2026-07-27 13:44:59.00452');
INSERT INTO "public"."sys_log" VALUES (941, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 13:44:59.37553');
INSERT INTO "public"."sys_log" VALUES (942, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/276,277,278,283,284,285,286,287,288,289,290,291,292,293,294,295,296,300,301,302,303,304,305,306,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,339,340,341,342,343,344,345', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1299, '2026-07-27 13:45:04.809904');
INSERT INTO "public"."sys_log" VALUES (943, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-27 13:45:05.212757');
INSERT INTO "public"."sys_log" VALUES (944, 81, 5, '点位管理-删除', '', 2, 'admin', '/api/v1/wms-point/346,347,348,349,350,351,352,357,358,359,360,361,362,363,364,365,366,367,368,369,370', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 208, '2026-07-27 13:45:09.587665');
INSERT INTO "public"."sys_log" VALUES (945, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 13:45:09.985795');
INSERT INTO "public"."sys_log" VALUES (946, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-27 13:45:13.699234');
INSERT INTO "public"."sys_log" VALUES (947, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-27 13:45:21.935265');
INSERT INTO "public"."sys_log" VALUES (973, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-27 13:50:21.924608');
INSERT INTO "public"."sys_log" VALUES (974, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-07-27 13:50:24.330265');
INSERT INTO "public"."sys_log" VALUES (975, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 13:50:26.873479');
INSERT INTO "public"."sys_log" VALUES (976, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 41, '2026-07-27 13:50:27.419364');
INSERT INTO "public"."sys_log" VALUES (977, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 13:50:29.042856');
INSERT INTO "public"."sys_log" VALUES (978, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-27 13:50:30.297724');
INSERT INTO "public"."sys_log" VALUES (979, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-27 13:50:32.040097');
INSERT INTO "public"."sys_log" VALUES (980, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-07-27 13:58:13.823766');
INSERT INTO "public"."sys_log" VALUES (981, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 13:58:18.16396');
INSERT INTO "public"."sys_log" VALUES (982, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 13:58:19.936839');
INSERT INTO "public"."sys_log" VALUES (983, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 13:58:22.122241');
INSERT INTO "public"."sys_log" VALUES (984, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 13:58:22.98461');
INSERT INTO "public"."sys_log" VALUES (985, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-07-27 13:58:23.39061');
INSERT INTO "public"."sys_log" VALUES (986, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 13:58:25.986236');
INSERT INTO "public"."sys_log" VALUES (987, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 14:05:11.380613');
INSERT INTO "public"."sys_log" VALUES (988, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1125, '2026-07-27 14:07:11.733049');
INSERT INTO "public"."sys_log" VALUES (989, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 14:07:12.159426');
INSERT INTO "public"."sys_log" VALUES (990, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/58', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-27 14:07:32.597777');
INSERT INTO "public"."sys_log" VALUES (991, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 14:07:32.978085');
INSERT INTO "public"."sys_log" VALUES (992, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 14:08:22.969818');
INSERT INTO "public"."sys_log" VALUES (993, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 14:08:29.809954');
INSERT INTO "public"."sys_log" VALUES (994, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-27 14:29:46.710178');
INSERT INTO "public"."sys_log" VALUES (995, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 54, '2026-07-27 14:33:11.711782');
INSERT INTO "public"."sys_log" VALUES (996, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 53, '2026-07-27 14:34:10.973272');
INSERT INTO "public"."sys_log" VALUES (997, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:34:11.738993');
INSERT INTO "public"."sys_log" VALUES (998, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 14:35:29.793761');
INSERT INTO "public"."sys_log" VALUES (999, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 14:35:30.162951');
INSERT INTO "public"."sys_log" VALUES (1000, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/59', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 14:35:37.631719');
INSERT INTO "public"."sys_log" VALUES (1001, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 14:35:37.994013');
INSERT INTO "public"."sys_log" VALUES (1002, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 14:36:35.762678');
INSERT INTO "public"."sys_log" VALUES (1003, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 14:36:36.312685');
INSERT INTO "public"."sys_log" VALUES (1004, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 14:36:43.492776');
INSERT INTO "public"."sys_log" VALUES (1005, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 57, '2026-07-27 14:36:50.630478');
INSERT INTO "public"."sys_log" VALUES (1006, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 14:36:59.882678');
INSERT INTO "public"."sys_log" VALUES (1007, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 14:37:48.554234');
INSERT INTO "public"."sys_log" VALUES (1008, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 14:37:48.985798');
INSERT INTO "public"."sys_log" VALUES (1009, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 14:38:27.389873');
INSERT INTO "public"."sys_log" VALUES (1010, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 14:38:27.778683');
INSERT INTO "public"."sys_log" VALUES (1011, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 14:39:14.125219');
INSERT INTO "public"."sys_log" VALUES (1012, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 14:39:14.492022');
INSERT INTO "public"."sys_log" VALUES (1013, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 14:40:15.670937');
INSERT INTO "public"."sys_log" VALUES (1014, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-07-27 14:40:16.076062');
INSERT INTO "public"."sys_log" VALUES (1015, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 14:40:51.617669');
INSERT INTO "public"."sys_log" VALUES (1016, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:40:51.995388');
INSERT INTO "public"."sys_log" VALUES (1017, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 14:41:18.369196');
INSERT INTO "public"."sys_log" VALUES (1018, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 14:41:18.760111');
INSERT INTO "public"."sys_log" VALUES (1019, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:41:44.011885');
INSERT INTO "public"."sys_log" VALUES (1020, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-27 14:41:44.589117');
INSERT INTO "public"."sys_log" VALUES (1021, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 14:41:48.690146');
INSERT INTO "public"."sys_log" VALUES (1022, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-27 14:42:21.905736');
INSERT INTO "public"."sys_log" VALUES (1023, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 14:42:22.270252');
INSERT INTO "public"."sys_log" VALUES (1024, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 14:42:41.600616');
INSERT INTO "public"."sys_log" VALUES (1025, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 14:42:41.997912');
INSERT INTO "public"."sys_log" VALUES (1026, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 14:43:07.883593');
INSERT INTO "public"."sys_log" VALUES (1027, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 14:43:08.270231');
INSERT INTO "public"."sys_log" VALUES (1028, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/71', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-07-27 14:44:11.409534');
INSERT INTO "public"."sys_log" VALUES (1029, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-27 14:44:11.936529');
INSERT INTO "public"."sys_log" VALUES (1030, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/70', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-27 14:44:15.225034');
INSERT INTO "public"."sys_log" VALUES (1031, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 14:44:15.619738');
INSERT INTO "public"."sys_log" VALUES (1032, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/69', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-27 14:44:31.34102');
INSERT INTO "public"."sys_log" VALUES (1033, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 14:44:31.712144');
INSERT INTO "public"."sys_log" VALUES (1034, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 14:45:33.499673');
INSERT INTO "public"."sys_log" VALUES (1035, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 14:45:33.891252');
INSERT INTO "public"."sys_log" VALUES (1036, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/66', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 14:45:47.908056');
INSERT INTO "public"."sys_log" VALUES (1037, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 14:45:48.279171');
INSERT INTO "public"."sys_log" VALUES (1038, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/67', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 60, '2026-07-27 14:45:56.138538');
INSERT INTO "public"."sys_log" VALUES (1039, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 14:45:56.525164');
INSERT INTO "public"."sys_log" VALUES (1040, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/68', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 14:46:02.257829');
INSERT INTO "public"."sys_log" VALUES (1041, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 14:46:02.721902');
INSERT INTO "public"."sys_log" VALUES (1042, 83, 5, '库位/区域管理-删除', '', 2, 'admin', '/api/v1/wms-location/72', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 14:46:20.074955');
INSERT INTO "public"."sys_log" VALUES (1043, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 14:46:20.44042');
INSERT INTO "public"."sys_log" VALUES (1044, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/66', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-27 14:46:33.917579');
INSERT INTO "public"."sys_log" VALUES (1045, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:46:34.357996');
INSERT INTO "public"."sys_log" VALUES (1046, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/67', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 14:46:53.428041');
INSERT INTO "public"."sys_log" VALUES (1047, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:46:53.79653');
INSERT INTO "public"."sys_log" VALUES (1048, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/66', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 14:47:01.191394');
INSERT INTO "public"."sys_log" VALUES (1049, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-27 14:47:01.615351');
INSERT INTO "public"."sys_log" VALUES (1050, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/67', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 14:47:06.472045');
INSERT INTO "public"."sys_log" VALUES (1051, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 14:47:07.599977');
INSERT INTO "public"."sys_log" VALUES (1052, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/68', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 14:47:13.407333');
INSERT INTO "public"."sys_log" VALUES (1053, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-27 14:47:13.78351');
INSERT INTO "public"."sys_log" VALUES (1054, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-27 14:48:19.340613');
INSERT INTO "public"."sys_log" VALUES (1055, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 14:48:19.714756');
INSERT INTO "public"."sys_log" VALUES (1056, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 14:49:07.741164');
INSERT INTO "public"."sys_log" VALUES (1057, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:49:14.104437');
INSERT INTO "public"."sys_log" VALUES (1058, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-27 14:49:37.90897');
INSERT INTO "public"."sys_log" VALUES (1059, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 14:49:47.436319');
INSERT INTO "public"."sys_log" VALUES (1060, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:50:04.644437');
INSERT INTO "public"."sys_log" VALUES (1061, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 14:51:00.718356');
INSERT INTO "public"."sys_log" VALUES (1062, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 155, '2026-07-27 14:51:01.247933');
INSERT INTO "public"."sys_log" VALUES (1063, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-27 14:51:06.211922');
INSERT INTO "public"."sys_log" VALUES (1064, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 130, '2026-07-27 14:51:48.255516');
INSERT INTO "public"."sys_log" VALUES (1065, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 14:51:48.634742');
INSERT INTO "public"."sys_log" VALUES (1066, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 14:52:38.079649');
INSERT INTO "public"."sys_log" VALUES (1067, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 14:52:38.547614');
INSERT INTO "public"."sys_log" VALUES (1068, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 54, '2026-07-27 14:52:43.630979');
INSERT INTO "public"."sys_log" VALUES (1069, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 14:52:58.676336');
INSERT INTO "public"."sys_log" VALUES (1070, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 14:53:06.462109');
INSERT INTO "public"."sys_log" VALUES (1071, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:53:31.011023');
INSERT INTO "public"."sys_log" VALUES (1072, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 35, '2026-07-27 14:53:54.655433');
INSERT INTO "public"."sys_log" VALUES (1073, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 14:55:06.324184');
INSERT INTO "public"."sys_log" VALUES (1074, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 53, '2026-07-27 14:55:52.188594');
INSERT INTO "public"."sys_log" VALUES (1075, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 41, '2026-07-27 14:55:52.296476');
INSERT INTO "public"."sys_log" VALUES (1076, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 14:56:24.7143');
INSERT INTO "public"."sys_log" VALUES (1077, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 14:56:25.093112');
INSERT INTO "public"."sys_log" VALUES (1078, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 64, '2026-07-27 14:57:11.311039');
INSERT INTO "public"."sys_log" VALUES (1079, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 14:57:11.701514');
INSERT INTO "public"."sys_log" VALUES (1080, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 37, '2026-07-27 14:57:40.486436');
INSERT INTO "public"."sys_log" VALUES (1081, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 14:57:40.914333');
INSERT INTO "public"."sys_log" VALUES (1082, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 60, '2026-07-27 14:58:23.325911');
INSERT INTO "public"."sys_log" VALUES (1083, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-27 14:58:23.779796');
INSERT INTO "public"."sys_log" VALUES (1084, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-07-27 14:58:38.078146');
INSERT INTO "public"."sys_log" VALUES (1085, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 14:58:38.480469');
INSERT INTO "public"."sys_log" VALUES (1086, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 14:58:51.95579');
INSERT INTO "public"."sys_log" VALUES (1087, 83, 4, '库位/区域管理-修改', '', 2, 'admin', '/api/v1/wms-location/61', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 14:59:15.734312');
INSERT INTO "public"."sys_log" VALUES (1088, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 14:59:16.111228');
INSERT INTO "public"."sys_log" VALUES (1089, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 48, '2026-07-27 15:00:08.514562');
INSERT INTO "public"."sys_log" VALUES (1090, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 15:00:08.902303');
INSERT INTO "public"."sys_log" VALUES (1091, 83, 3, '库位/区域管理-新增', '', 2, 'admin', '/api/v1/wms-location', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 15:00:36.374829');
INSERT INTO "public"."sys_log" VALUES (1092, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-27 15:00:36.770565');
INSERT INTO "public"."sys_log" VALUES (1093, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 45, '2026-07-27 15:00:56.514631');
INSERT INTO "public"."sys_log" VALUES (1094, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 48, '2026-07-27 15:01:48.492856');
INSERT INTO "public"."sys_log" VALUES (1095, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-27 15:01:48.918761');
INSERT INTO "public"."sys_log" VALUES (1096, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-27 15:02:05.571218');
INSERT INTO "public"."sys_log" VALUES (1097, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 15:02:05.945298');
INSERT INTO "public"."sys_log" VALUES (1098, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 149, '2026-07-27 15:02:25.446168');
INSERT INTO "public"."sys_log" VALUES (1099, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 15:02:25.850657');
INSERT INTO "public"."sys_log" VALUES (1100, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 55, '2026-07-27 15:02:41.691583');
INSERT INTO "public"."sys_log" VALUES (1101, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 15:02:42.257584');
INSERT INTO "public"."sys_log" VALUES (1102, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 317, '2026-07-27 15:03:09.376709');
INSERT INTO "public"."sys_log" VALUES (1103, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 15:03:09.770448');
INSERT INTO "public"."sys_log" VALUES (1104, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-27 15:03:23.4204');
INSERT INTO "public"."sys_log" VALUES (1105, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-07-27 15:03:23.858441');
INSERT INTO "public"."sys_log" VALUES (1106, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 15:03:52.142775');
INSERT INTO "public"."sys_log" VALUES (1107, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-07-27 15:03:52.554958');
INSERT INTO "public"."sys_log" VALUES (1108, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-27 15:04:13.361577');
INSERT INTO "public"."sys_log" VALUES (1109, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 42, '2026-07-27 15:04:13.798153');
INSERT INTO "public"."sys_log" VALUES (1110, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 98, '2026-07-27 15:04:31.510894');
INSERT INTO "public"."sys_log" VALUES (1111, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 15:04:31.890053');
INSERT INTO "public"."sys_log" VALUES (1112, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 15:04:48.138671');
INSERT INTO "public"."sys_log" VALUES (1113, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 15:04:48.521778');
INSERT INTO "public"."sys_log" VALUES (1114, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-27 15:04:52.94378');
INSERT INTO "public"."sys_log" VALUES (1115, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-27 15:05:15.022089');
INSERT INTO "public"."sys_log" VALUES (1116, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 15:05:15.394588');
INSERT INTO "public"."sys_log" VALUES (1117, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-27 15:05:32.354007');
INSERT INTO "public"."sys_log" VALUES (1118, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 15:05:32.739516');
INSERT INTO "public"."sys_log" VALUES (1119, 82, 4, '巷道管理-修改', '', 2, 'admin', '/api/v1/wms-aisle/118', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 15:06:04.552247');
INSERT INTO "public"."sys_log" VALUES (1120, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-27 15:06:04.956781');
INSERT INTO "public"."sys_log" VALUES (1121, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-27 15:06:34.484172');
INSERT INTO "public"."sys_log" VALUES (1122, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 42, '2026-07-27 15:06:34.912261');
INSERT INTO "public"."sys_log" VALUES (1123, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-27 15:06:48.496545');
INSERT INTO "public"."sys_log" VALUES (1124, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 15:06:48.891552');
INSERT INTO "public"."sys_log" VALUES (1125, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 513, '2026-07-27 15:07:08.418871');
INSERT INTO "public"."sys_log" VALUES (1126, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 15:07:08.927541');
INSERT INTO "public"."sys_log" VALUES (1127, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-27 15:07:22.745659');
INSERT INTO "public"."sys_log" VALUES (1128, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 15:07:23.127877');
INSERT INTO "public"."sys_log" VALUES (1129, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-07-27 15:07:42.615438');
INSERT INTO "public"."sys_log" VALUES (1130, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-27 15:07:43.034695');
INSERT INTO "public"."sys_log" VALUES (1131, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 15:07:58.57223');
INSERT INTO "public"."sys_log" VALUES (1132, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 15:07:58.943473');
INSERT INTO "public"."sys_log" VALUES (1133, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-07-27 15:08:12.822283');
INSERT INTO "public"."sys_log" VALUES (1134, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-27 15:08:13.205497');
INSERT INTO "public"."sys_log" VALUES (1135, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-27 15:08:26.871482');
INSERT INTO "public"."sys_log" VALUES (1136, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-27 15:08:27.247275');
INSERT INTO "public"."sys_log" VALUES (1137, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-27 15:08:51.542602');
INSERT INTO "public"."sys_log" VALUES (1138, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 15:08:51.936958');
INSERT INTO "public"."sys_log" VALUES (1139, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-27 15:09:05.40467');
INSERT INTO "public"."sys_log" VALUES (1140, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 15:09:05.796137');
INSERT INTO "public"."sys_log" VALUES (1141, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 15:09:28.662963');
INSERT INTO "public"."sys_log" VALUES (1142, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 15:09:37.250474');
INSERT INTO "public"."sys_log" VALUES (1143, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 47, '2026-07-27 15:09:52.920878');
INSERT INTO "public"."sys_log" VALUES (1144, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 47, '2026-07-27 15:09:53.546985');
INSERT INTO "public"."sys_log" VALUES (1145, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-27 15:10:05.943528');
INSERT INTO "public"."sys_log" VALUES (1146, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 15:10:06.353956');
INSERT INTO "public"."sys_log" VALUES (1147, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-27 15:10:20.570949');
INSERT INTO "public"."sys_log" VALUES (1148, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-27 15:10:20.977492');
INSERT INTO "public"."sys_log" VALUES (1149, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-27 15:10:33.744277');
INSERT INTO "public"."sys_log" VALUES (1150, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 15:10:34.153465');
INSERT INTO "public"."sys_log" VALUES (1151, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-27 15:10:38.716176');
INSERT INTO "public"."sys_log" VALUES (1152, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-27 15:11:00.948297');
INSERT INTO "public"."sys_log" VALUES (1153, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 35, '2026-07-27 15:11:01.352837');
INSERT INTO "public"."sys_log" VALUES (1154, 82, 3, '巷道管理-新增', '', 2, 'admin', '/api/v1/wms-aisle', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-07-27 15:11:14.03439');
INSERT INTO "public"."sys_log" VALUES (1155, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 15:11:14.455774');
INSERT INTO "public"."sys_log" VALUES (1156, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 15:11:47.437444');
INSERT INTO "public"."sys_log" VALUES (1157, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-27 15:12:30.96383');
INSERT INTO "public"."sys_log" VALUES (1158, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 15:13:12.314669');
INSERT INTO "public"."sys_log" VALUES (1159, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 15:13:13.235727');
INSERT INTO "public"."sys_log" VALUES (1160, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 15:13:13.595204');
INSERT INTO "public"."sys_log" VALUES (1161, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 15:13:21.885783');
INSERT INTO "public"."sys_log" VALUES (1162, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 15:13:24.856358');
INSERT INTO "public"."sys_log" VALUES (1163, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-27 15:13:26.466569');
INSERT INTO "public"."sys_log" VALUES (1164, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 15:13:41.191132');
INSERT INTO "public"."sys_log" VALUES (1165, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 15:14:24.948303');
INSERT INTO "public"."sys_log" VALUES (1166, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-27 15:14:31.866268');
INSERT INTO "public"."sys_log" VALUES (1167, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-07-27 15:16:17.824547');
INSERT INTO "public"."sys_log" VALUES (1168, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 15:16:21.636159');
INSERT INTO "public"."sys_log" VALUES (1169, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-27 15:16:44.932999');
INSERT INTO "public"."sys_log" VALUES (1170, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 15:16:47.032837');
INSERT INTO "public"."sys_log" VALUES (1171, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-27 15:16:57.842077');
INSERT INTO "public"."sys_log" VALUES (1172, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 15:17:06.907981');
INSERT INTO "public"."sys_log" VALUES (1173, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-27 15:17:18.440773');
INSERT INTO "public"."sys_log" VALUES (1174, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 15:20:57.345028');
INSERT INTO "public"."sys_log" VALUES (1175, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-27 15:20:59.97259');
INSERT INTO "public"."sys_log" VALUES (1176, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 47, '2026-07-27 15:27:27.95061');
INSERT INTO "public"."sys_log" VALUES (1177, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 43, '2026-07-27 15:27:29.455471');
INSERT INTO "public"."sys_log" VALUES (1178, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 94, '2026-07-27 15:27:31.479519');
INSERT INTO "public"."sys_log" VALUES (1179, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 35, '2026-07-27 15:27:33.238515');
INSERT INTO "public"."sys_log" VALUES (1180, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-27 15:30:11.574224');
INSERT INTO "public"."sys_log" VALUES (1181, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 43, '2026-07-27 15:30:13.568342');
INSERT INTO "public"."sys_log" VALUES (1182, 81, 3, '点位管理-新增', '', 2, 'admin', '/api/v1/wms-point', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 2259, '2026-07-27 15:30:37.775205');
INSERT INTO "public"."sys_log" VALUES (1183, 81, 3, '点位管理-新增', '', 2, 'admin', '/api/v1/wms-point', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '请勿重复提交', 9, '2026-07-27 15:30:38.044512');
INSERT INTO "public"."sys_log" VALUES (1184, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-27 15:30:38.228995');
INSERT INTO "public"."sys_log" VALUES (1185, 81, 3, '点位管理-新增', '', 2, 'admin', '/api/v1/wms-point', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 41, '2026-07-27 15:30:59.967427');
INSERT INTO "public"."sys_log" VALUES (1186, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 15:31:00.385402');
INSERT INTO "public"."sys_log" VALUES (1187, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 55, '2026-07-27 15:40:37.568917');
INSERT INTO "public"."sys_log" VALUES (1188, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-27 15:40:51.022164');
INSERT INTO "public"."sys_log" VALUES (1189, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 546, '2026-07-27 15:47:06.683201');
INSERT INTO "public"."sys_log" VALUES (1190, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 59, '2026-07-27 15:47:11.539968');
INSERT INTO "public"."sys_log" VALUES (1191, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 53, '2026-07-27 15:47:13.20729');
INSERT INTO "public"."sys_log" VALUES (1192, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 15:47:29.844315');
INSERT INTO "public"."sys_log" VALUES (1193, 81, 3, '点位管理-新增', '', 2, 'admin', '/api/v1/wms-point', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 956, '2026-07-27 15:48:07.188341');
INSERT INTO "public"."sys_log" VALUES (1194, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 15:48:07.733392');
INSERT INTO "public"."sys_log" VALUES (1195, 81, 3, '点位管理-新增', '', 2, 'admin', '/api/v1/wms-point', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 108, '2026-07-27 15:48:25.994725');
INSERT INTO "public"."sys_log" VALUES (1196, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 52, '2026-07-27 15:48:26.485204');
INSERT INTO "public"."sys_log" VALUES (1197, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 178, '2026-07-27 15:48:29.153679');
INSERT INTO "public"."sys_log" VALUES (1198, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-07-27 15:48:34.199924');
INSERT INTO "public"."sys_log" VALUES (1199, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 90, '2026-07-27 15:48:44.351267');
INSERT INTO "public"."sys_log" VALUES (1200, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-27 15:48:48.01904');
INSERT INTO "public"."sys_log" VALUES (1201, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 73, '2026-07-27 15:49:05.250748');
INSERT INTO "public"."sys_log" VALUES (1202, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 106, '2026-07-27 15:49:22.057359');
INSERT INTO "public"."sys_log" VALUES (1203, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 45, '2026-07-27 15:49:34.428734');
INSERT INTO "public"."sys_log" VALUES (1204, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 83, '2026-07-27 15:50:09.942295');
INSERT INTO "public"."sys_log" VALUES (1205, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 51, '2026-07-27 15:50:11.829051');
INSERT INTO "public"."sys_log" VALUES (1206, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 369, '2026-07-27 15:50:21.292043');
INSERT INTO "public"."sys_log" VALUES (1207, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 15:50:26.947903');
INSERT INTO "public"."sys_log" VALUES (1208, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-27 15:50:30.006686');
INSERT INTO "public"."sys_log" VALUES (1209, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-07-27 15:50:31.910538');
INSERT INTO "public"."sys_log" VALUES (1210, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-27 15:53:38.234436');
INSERT INTO "public"."sys_log" VALUES (1211, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-27 15:53:40.964886');
INSERT INTO "public"."sys_log" VALUES (1212, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 15:53:43.952867');
INSERT INTO "public"."sys_log" VALUES (1213, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 15:53:48.403342');
INSERT INTO "public"."sys_log" VALUES (1214, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 15:53:58.182639');
INSERT INTO "public"."sys_log" VALUES (1215, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 15:54:23.141913');
INSERT INTO "public"."sys_log" VALUES (1216, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 15:54:27.771915');
INSERT INTO "public"."sys_log" VALUES (1217, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 15:54:29.465997');
INSERT INTO "public"."sys_log" VALUES (1218, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-27 15:56:20.979567');
INSERT INTO "public"."sys_log" VALUES (1219, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 15:56:21.628116');
INSERT INTO "public"."sys_log" VALUES (1220, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-07-27 16:00:46.401214');
INSERT INTO "public"."sys_log" VALUES (1221, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 85, '2026-07-27 16:02:13.804674');
INSERT INTO "public"."sys_log" VALUES (1222, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 16:02:39.214171');
INSERT INTO "public"."sys_log" VALUES (1223, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 41, '2026-07-27 17:18:20.194809');
INSERT INTO "public"."sys_log" VALUES (1224, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-27 17:42:16.964784');
INSERT INTO "public"."sys_log" VALUES (1225, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 154, '2026-07-27 17:42:19.090318');
INSERT INTO "public"."sys_log" VALUES (1226, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 220, '2026-07-27 17:42:21.172192');
INSERT INTO "public"."sys_log" VALUES (1227, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 59, '2026-07-27 17:42:26.669281');
INSERT INTO "public"."sys_log" VALUES (1228, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-27 17:42:32.37086');
INSERT INTO "public"."sys_log" VALUES (1229, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-07-27 17:42:36.095422');
INSERT INTO "public"."sys_log" VALUES (1230, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 661, '2026-07-27 17:42:38.767229');
INSERT INTO "public"."sys_log" VALUES (1231, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 415, '2026-07-27 17:42:51.949995');
INSERT INTO "public"."sys_log" VALUES (1232, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 277, '2026-07-27 17:42:57.349677');
INSERT INTO "public"."sys_log" VALUES (1233, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 387, '2026-07-27 23:30:36.972638');
INSERT INTO "public"."sys_log" VALUES (1234, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-27 23:30:40.989398');
INSERT INTO "public"."sys_log" VALUES (1235, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 434, '2026-07-27 23:35:07.858094');
INSERT INTO "public"."sys_log" VALUES (1236, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-27 23:35:08.230627');
INSERT INTO "public"."sys_log" VALUES (1237, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2826', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 35, '2026-07-27 23:40:25.30073');
INSERT INTO "public"."sys_log" VALUES (1238, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 23:40:25.66914');
INSERT INTO "public"."sys_log" VALUES (1239, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 23:40:29.05938');
INSERT INTO "public"."sys_log" VALUES (1240, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-27 23:40:35.860502');
INSERT INTO "public"."sys_log" VALUES (1241, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 62, '2026-07-27 23:40:45.098937');
INSERT INTO "public"."sys_log" VALUES (1242, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-27 23:40:45.442656');
INSERT INTO "public"."sys_log" VALUES (1243, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-27 23:40:48.887497');
INSERT INTO "public"."sys_log" VALUES (1244, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-27 23:40:57.419124');
INSERT INTO "public"."sys_log" VALUES (1245, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2826', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-27 23:41:04.834242');
INSERT INTO "public"."sys_log" VALUES (1246, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-27 23:41:05.19475');
INSERT INTO "public"."sys_log" VALUES (1247, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2826', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-27 23:41:10.419532');
INSERT INTO "public"."sys_log" VALUES (1248, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-27 23:41:10.780633');
INSERT INTO "public"."sys_log" VALUES (1249, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2807', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 58, '2026-07-27 23:41:19.515517');
INSERT INTO "public"."sys_log" VALUES (1250, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-27 23:41:19.865451');
INSERT INTO "public"."sys_log" VALUES (1251, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2826', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-27 23:41:25.417415');
INSERT INTO "public"."sys_log" VALUES (1252, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-27 23:41:25.782981');
INSERT INTO "public"."sys_log" VALUES (1253, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-27 23:46:30.557997');
INSERT INTO "public"."sys_log" VALUES (1254, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-27 23:46:30.916469');
INSERT INTO "public"."sys_log" VALUES (1255, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2827', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-27 23:47:32.790713');
INSERT INTO "public"."sys_log" VALUES (1256, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-27 23:47:33.143824');
INSERT INTO "public"."sys_log" VALUES (1257, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 269, '2026-07-28 00:09:12.105077');
INSERT INTO "public"."sys_log" VALUES (1258, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-28 00:09:17.100578');
INSERT INTO "public"."sys_log" VALUES (1259, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 311, '2026-07-28 00:09:42.029066');
INSERT INTO "public"."sys_log" VALUES (1260, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-28 00:09:42.444656');
INSERT INTO "public"."sys_log" VALUES (1261, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-28 00:10:05.321549');
INSERT INTO "public"."sys_log" VALUES (1262, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-28 00:10:05.739874');
INSERT INTO "public"."sys_log" VALUES (1263, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 00:10:34.004671');
INSERT INTO "public"."sys_log" VALUES (1264, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-28 00:10:34.40632');
INSERT INTO "public"."sys_log" VALUES (1265, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-28 00:10:55.281948');
INSERT INTO "public"."sys_log" VALUES (1266, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-28 00:10:55.680178');
INSERT INTO "public"."sys_log" VALUES (1267, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 00:11:09.879993');
INSERT INTO "public"."sys_log" VALUES (1268, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2826', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 44, '2026-07-28 00:11:52.315124');
INSERT INTO "public"."sys_log" VALUES (1269, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-28 00:11:52.674474');
INSERT INTO "public"."sys_log" VALUES (1270, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-28 00:11:57.422133');
INSERT INTO "public"."sys_log" VALUES (1271, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-28 00:12:51.524961');
INSERT INTO "public"."sys_log" VALUES (1272, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-28 00:12:52.018343');
INSERT INTO "public"."sys_log" VALUES (1273, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2826', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-07-28 00:14:09.208886');
INSERT INTO "public"."sys_log" VALUES (1274, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-28 00:14:09.568829');
INSERT INTO "public"."sys_log" VALUES (1275, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-28 00:14:12.127134');
INSERT INTO "public"."sys_log" VALUES (1276, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-28 00:14:19.876936');
INSERT INTO "public"."sys_log" VALUES (1277, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 00:14:19.897204');
INSERT INTO "public"."sys_log" VALUES (1278, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 00:14:22.02138');
INSERT INTO "public"."sys_log" VALUES (1279, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 43, '2026-07-28 00:14:28.509558');
INSERT INTO "public"."sys_log" VALUES (1280, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-28 00:14:28.844326');
INSERT INTO "public"."sys_log" VALUES (1281, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-28 00:14:34.606802');
INSERT INTO "public"."sys_log" VALUES (1282, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-28 00:14:37.267232');
INSERT INTO "public"."sys_log" VALUES (1283, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 00:15:12.227503');
INSERT INTO "public"."sys_log" VALUES (1284, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-28 00:15:44.522495');
INSERT INTO "public"."sys_log" VALUES (1285, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2826', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-28 00:16:05.140037');
INSERT INTO "public"."sys_log" VALUES (1286, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-28 00:16:05.500738');
INSERT INTO "public"."sys_log" VALUES (1287, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-28 00:16:08.486648');
INSERT INTO "public"."sys_log" VALUES (1288, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-28 00:16:15.55742');
INSERT INTO "public"."sys_log" VALUES (1289, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-28 00:16:17.140126');
INSERT INTO "public"."sys_log" VALUES (1290, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2807', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 41, '2026-07-28 00:16:23.511038');
INSERT INTO "public"."sys_log" VALUES (1291, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-28 00:16:23.860565');
INSERT INTO "public"."sys_log" VALUES (1292, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-28 00:16:27.429533');
INSERT INTO "public"."sys_log" VALUES (1293, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/1', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 85, '2026-07-28 00:16:44.18313');
INSERT INTO "public"."sys_log" VALUES (1294, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-28 00:16:44.538422');
INSERT INTO "public"."sys_log" VALUES (1295, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-28 00:16:50.318062');
INSERT INTO "public"."sys_log" VALUES (1296, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-28 00:16:57.472362');
INSERT INTO "public"."sys_log" VALUES (1297, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-28 00:17:00.564539');
INSERT INTO "public"."sys_log" VALUES (1298, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 00:17:01.808137');
INSERT INTO "public"."sys_log" VALUES (1299, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-28 00:17:03.303238');
INSERT INTO "public"."sys_log" VALUES (1300, 84, 3, '料车型号配置-新增', '', 2, 'admin', '/api/v1/cart-model', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart_model" 的 "created_time" 字段不存在
  位置：31
### The error may exist in com/wms/carriermanagementsystem/cartmodel/mapper/CartModelMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO wms_cart_model  ( created_time, updated_time, model_code, model_name, max_capacity, layer_count,  created_by, updated_by )  VALUES (  ?, ?, ?, ?, ?, ?,  ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart_model" 的 "created_time" 字段不存在
  位置：31
; bad SQL grammar []', 116, '2026-07-28 00:20:43.355722');
INSERT INTO "public"."sys_log" VALUES (1301, 84, 3, '料车型号配置-新增', '', 2, 'admin', '/api/v1/cart-model', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '请勿重复提交', 1, '2026-07-28 00:20:46.442073');
INSERT INTO "public"."sys_log" VALUES (1302, 84, 3, '料车型号配置-新增', '', 2, 'admin', '/api/v1/cart-model', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart_model" 的 "created_time" 字段不存在
  位置：31
### The error may exist in com/wms/carriermanagementsystem/cartmodel/mapper/CartModelMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO wms_cart_model  ( created_time, updated_time, model_code, model_name, max_capacity, layer_count,  created_by, updated_by )  VALUES (  ?, ?, ?, ?, ?, ?,  ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart_model" 的 "created_time" 字段不存在
  位置：31
; bad SQL grammar []', 3, '2026-07-28 00:21:01.959899');
INSERT INTO "public"."sys_log" VALUES (1303, 84, 3, '料车型号配置-新增', '', 2, 'admin', '/api/v1/cart-model', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart_model" 的 "created_time" 字段不存在
  位置：31
### The error may exist in com/wms/carriermanagementsystem/cartmodel/mapper/CartModelMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO wms_cart_model  ( created_time, updated_time, model_code, model_name, max_capacity, layer_count,  created_by, updated_by )  VALUES (  ?, ?, ?, ?, ?, ?,  ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart_model" 的 "created_time" 字段不存在
  位置：31
; bad SQL grammar []', 4, '2026-07-28 00:21:13.930252');
INSERT INTO "public"."sys_log" VALUES (1304, 84, 3, '料车型号配置-新增', '', 2, 'admin', '/api/v1/cart-model', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-28 00:25:05.05879');
INSERT INTO "public"."sys_log" VALUES (1305, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 00:25:05.398835');
INSERT INTO "public"."sys_log" VALUES (1306, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 00:25:26.401966');
INSERT INTO "public"."sys_log" VALUES (1307, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-28 00:25:28.174085');
INSERT INTO "public"."sys_log" VALUES (1308, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-28 00:25:35.005191');
INSERT INTO "public"."sys_log" VALUES (1309, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-28 00:30:17.383919');
INSERT INTO "public"."sys_log" VALUES (1310, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 00:30:20.339245');
INSERT INTO "public"."sys_log" VALUES (1311, 84, 3, '料车型号配置-新增', '', 2, 'admin', '/api/v1/cart-model', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 302, '2026-07-28 00:30:46.484848');
INSERT INTO "public"."sys_log" VALUES (1312, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-28 00:30:46.51812');
INSERT INTO "public"."sys_log" VALUES (1313, 84, 4, '料车型号配置-修改', '', 2, 'admin', '/api/v1/cart-model/2', 'PUT', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 00:30:56.809465');
INSERT INTO "public"."sys_log" VALUES (1314, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-28 00:30:57.144824');
INSERT INTO "public"."sys_log" VALUES (1315, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE m.model_code LIKE CONCAT(''%'', ?, ''%'')
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 221, '2026-07-28 00:31:26.466019');
INSERT INTO "public"."sys_log" VALUES (1316, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE m.model_code LIKE CONCAT(''%'', ?, ''%'')
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 4, '2026-07-28 00:31:37.424331');
INSERT INTO "public"."sys_log" VALUES (1317, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE (m.model_code LIKE CONCAT(''%'', ?, ''%'') OR m.model_name LIKE CONCAT(''%'', ?, ''%''))
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 6, '2026-07-28 00:31:41.784444');
INSERT INTO "public"."sys_log" VALUES (1318, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 268, '2026-07-28 09:07:04.65992');
INSERT INTO "public"."sys_log" VALUES (1319, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-28 09:07:07.55156');
INSERT INTO "public"."sys_log" VALUES (1320, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE m.model_code LIKE CONCAT(''%'', ?, ''%'')
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 11, '2026-07-28 09:13:19.807017');
INSERT INTO "public"."sys_log" VALUES (1321, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE m.model_code LIKE CONCAT(''%'', ?, ''%'')
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 4, '2026-07-28 09:14:13.621625');
INSERT INTO "public"."sys_log" VALUES (1322, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE m.model_code LIKE CONCAT(''%'', ?, ''%'')
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 94, '2026-07-28 09:17:00.902698');
INSERT INTO "public"."sys_log" VALUES (1323, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-28 09:17:03.419589');
INSERT INTO "public"."sys_log" VALUES (1324, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE m.model_code LIKE CONCAT(''%'', ?, ''%'')
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 10, '2026-07-28 09:17:09.284465');
INSERT INTO "public"."sys_log" VALUES (1359, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 49, '2026-07-28 10:42:48.452815');
INSERT INTO "public"."sys_log" VALUES (1325, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE m.model_code LIKE CONCAT(''%'', ?, ''%'')
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 9, '2026-07-28 09:17:10.16363');
INSERT INTO "public"."sys_log" VALUES (1326, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\carriermanagementsystem\CartModelMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT COUNT(*) AS total FROM wms_cart_model m WHERE m.model_code LIKE CONCAT(''%'', ?, ''%'')
### Cause: org.postgresql.util.PSQLException: 错误: 无法确定参数 $1 的数据类型
; bad SQL grammar []', 8, '2026-07-28 09:17:23.975416');
INSERT INTO "public"."sys_log" VALUES (1327, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-07-28 09:27:03.472191');
INSERT INTO "public"."sys_log" VALUES (1328, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-28 09:27:08.35287');
INSERT INTO "public"."sys_log" VALUES (1329, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 09:27:18.133975');
INSERT INTO "public"."sys_log" VALUES (1330, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-28 09:27:28.50157');
INSERT INTO "public"."sys_log" VALUES (1331, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 09:27:29.142837');
INSERT INTO "public"."sys_log" VALUES (1332, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.102', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-28 09:27:29.674065');
INSERT INTO "public"."sys_log" VALUES (1333, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '172.29.192.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-28 10:21:52.805896');
INSERT INTO "public"."sys_log" VALUES (1334, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '172.29.192.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 149, '2026-07-28 10:21:59.489545');
INSERT INTO "public"."sys_log" VALUES (1335, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '172.29.192.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 42, '2026-07-28 10:22:03.154155');
INSERT INTO "public"."sys_log" VALUES (1336, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '172.29.192.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 45, '2026-07-28 10:22:06.171731');
INSERT INTO "public"."sys_log" VALUES (1337, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '172.29.192.1', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-07-28 10:22:16.535923');
INSERT INTO "public"."sys_log" VALUES (1338, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-28 10:30:51.347918');
INSERT INTO "public"."sys_log" VALUES (1339, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-28 10:37:09.871341');
INSERT INTO "public"."sys_log" VALUES (1340, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 62, '2026-07-28 10:37:13.210049');
INSERT INTO "public"."sys_log" VALUES (1341, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 2758, '2026-07-28 10:39:53.937582');
INSERT INTO "public"."sys_log" VALUES (1342, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 638, '2026-07-28 10:39:55.728641');
INSERT INTO "public"."sys_log" VALUES (1343, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2832', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 251, '2026-07-28 10:40:06.215279');
INSERT INTO "public"."sys_log" VALUES (1344, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 298, '2026-07-28 10:40:06.961394');
INSERT INTO "public"."sys_log" VALUES (1345, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 196, '2026-07-28 10:40:16.854105');
INSERT INTO "public"."sys_log" VALUES (1346, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 490, '2026-07-28 10:40:24.435946');
INSERT INTO "public"."sys_log" VALUES (1347, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-28 10:40:24.922431');
INSERT INTO "public"."sys_log" VALUES (1348, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-28 10:40:32.483197');
INSERT INTO "public"."sys_log" VALUES (1349, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-28 10:40:44.884642');
INSERT INTO "public"."sys_log" VALUES (1350, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2832', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 81, '2026-07-28 10:40:59.177703');
INSERT INTO "public"."sys_log" VALUES (1351, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-28 10:40:59.761552');
INSERT INTO "public"."sys_log" VALUES (1352, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 84, '2026-07-28 10:41:21.08794');
INSERT INTO "public"."sys_log" VALUES (1353, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-28 10:41:21.660035');
INSERT INTO "public"."sys_log" VALUES (1354, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2833', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 136, '2026-07-28 10:41:40.868573');
INSERT INTO "public"."sys_log" VALUES (1355, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 78, '2026-07-28 10:41:41.563366');
INSERT INTO "public"."sys_log" VALUES (1356, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 66, '2026-07-28 10:42:11.638469');
INSERT INTO "public"."sys_log" VALUES (1357, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 78, '2026-07-28 10:42:12.315512');
INSERT INTO "public"."sys_log" VALUES (1358, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 54, '2026-07-28 10:42:46.929312');
INSERT INTO "public"."sys_log" VALUES (1360, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-28 10:43:07.485234');
INSERT INTO "public"."sys_log" VALUES (1361, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-28 10:43:08.021494');
INSERT INTO "public"."sys_log" VALUES (1362, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-28 10:43:11.136652');
INSERT INTO "public"."sys_log" VALUES (1363, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-28 10:43:15.337623');
INSERT INTO "public"."sys_log" VALUES (1364, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-28 10:43:24.695992');
INSERT INTO "public"."sys_log" VALUES (1365, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-28 10:43:28.607597');
INSERT INTO "public"."sys_log" VALUES (1366, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2832', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 257, '2026-07-28 10:44:01.280686');
INSERT INTO "public"."sys_log" VALUES (1367, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 118, '2026-07-28 10:44:01.887565');
INSERT INTO "public"."sys_log" VALUES (1368, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-28 10:44:06.375048');
INSERT INTO "public"."sys_log" VALUES (1369, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-28 10:44:14.423005');
INSERT INTO "public"."sys_log" VALUES (1370, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 73, '2026-07-28 10:44:22.115142');
INSERT INTO "public"."sys_log" VALUES (1371, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-07-28 10:44:22.540459');
INSERT INTO "public"."sys_log" VALUES (1372, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-28 10:44:35.831089');
INSERT INTO "public"."sys_log" VALUES (1373, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-28 10:44:42.359203');
INSERT INTO "public"."sys_log" VALUES (1374, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 106, '2026-07-28 10:44:54.977097');
INSERT INTO "public"."sys_log" VALUES (1375, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-28 10:44:55.359694');
INSERT INTO "public"."sys_log" VALUES (1376, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 64, '2026-07-28 10:45:01.398641');
INSERT INTO "public"."sys_log" VALUES (1377, 1, 2, '登录-登出', '', 2, 'admin', '/api/v1/auth/logout', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1, '2026-07-28 10:45:08.468227');
INSERT INTO "public"."sys_log" VALUES (1378, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1120, '2026-07-28 10:45:12.906215');
INSERT INTO "public"."sys_log" VALUES (1379, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 185, '2026-07-28 10:46:26.021565');
INSERT INTO "public"."sys_log" VALUES (1380, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2833', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 56, '2026-07-28 10:46:36.23247');
INSERT INTO "public"."sys_log" VALUES (1381, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 171, '2026-07-28 10:46:36.916774');
INSERT INTO "public"."sys_log" VALUES (1382, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2834', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 58, '2026-07-28 10:46:48.97489');
INSERT INTO "public"."sys_log" VALUES (1383, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-28 10:46:49.492851');
INSERT INTO "public"."sys_log" VALUES (1384, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 56, '2026-07-28 10:47:01.42082');
INSERT INTO "public"."sys_log" VALUES (1385, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-28 10:47:21.898415');
INSERT INTO "public"."sys_log" VALUES (1386, 84, 3, '料车型号配置-新增', '', 2, 'admin', '/api/v1/cart-model', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-28 10:50:02.266332');
INSERT INTO "public"."sys_log" VALUES (1387, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-28 10:50:02.649497');
INSERT INTO "public"."sys_log" VALUES (1388, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-28 10:50:05.376052');
INSERT INTO "public"."sys_log" VALUES (1389, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart" 的 "created_time" 字段不存在
  位置：25
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO wms_cart  ( created_time, updated_time, cart_code, model_id, current_quantity, status,    created_by, updated_by )  VALUES (  ?, ?, ?, ?, ?, ?,    ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart" 的 "created_time" 字段不存在
  位置：25
; bad SQL grammar []', 423, '2026-07-28 11:00:14.124186');
INSERT INTO "public"."sys_log" VALUES (1390, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart" 的 "created_by" 字段不存在
  位置：103
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO wms_cart  ( created_time, updated_time, cart_code, model_id, current_quantity, status,    created_by, updated_by )  VALUES (  ?, ?, ?, ?, ?, ?,    ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart" 的 "created_by" 字段不存在
  位置：103
; bad SQL grammar []', 32, '2026-07-28 11:00:52.044168');
INSERT INTO "public"."sys_log" VALUES (1438, 3, 6, '角色管理-授权', '', 2, 'admin', '/api/v1/roles/2/menus', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 53, '2026-07-28 16:20:32.228291');
INSERT INTO "public"."sys_log" VALUES (1439, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-28 16:20:32.636799');
INSERT INTO "public"."sys_log" VALUES (1391, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart" 的 "created_by" 字段不存在
  位置：103
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.insert-Inline
### The error occurred while setting parameters
### SQL: INSERT INTO wms_cart  ( created_time, updated_time, cart_code, model_id, current_quantity, status,    created_by, updated_by )  VALUES (  ?, ?, ?, ?, ?, ?,    ?, ?  )
### Cause: org.postgresql.util.PSQLException: 错误: 关系 "wms_cart" 的 "created_by" 字段不存在
  位置：103
; bad SQL grammar []', 11, '2026-07-28 11:01:08.222127');
INSERT INTO "public"."sys_log" VALUES (1392, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 188, '2026-07-28 14:56:36.675841');
INSERT INTO "public"."sys_log" VALUES (1393, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-28 14:56:55.322796');
INSERT INTO "public"."sys_log" VALUES (1394, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-28 14:56:55.903303');
INSERT INTO "public"."sys_log" VALUES (1395, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-28 14:57:08.023141');
INSERT INTO "public"."sys_log" VALUES (1396, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-28 14:57:08.385947');
INSERT INTO "public"."sys_log" VALUES (1397, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 15:05:22.371389');
INSERT INTO "public"."sys_log" VALUES (1398, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-28 15:05:22.736428');
INSERT INTO "public"."sys_log" VALUES (1399, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 32, '2026-07-28 15:05:30.326237');
INSERT INTO "public"."sys_log" VALUES (1400, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-28 15:05:30.814881');
INSERT INTO "public"."sys_log" VALUES (1401, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.updateById-Inline
### The error occurred while setting parameters
### SQL: UPDATE wms_cart SET updated_time = ?, cart_code = ?, model_id = ?, updated_by = ? WHERE id = ?
### Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
; bad SQL grammar []', 169, '2026-07-28 15:05:51.148364');
INSERT INTO "public"."sys_log" VALUES (1402, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.updateById-Inline
### The error occurred while setting parameters
### SQL: UPDATE wms_cart SET updated_time = ?, cart_code = ?, model_id = ?, updated_by = ? WHERE id = ?
### Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
; bad SQL grammar []', 8, '2026-07-28 15:05:52.968841');
INSERT INTO "public"."sys_log" VALUES (1403, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.updateById-Inline
### The error occurred while setting parameters
### SQL: UPDATE wms_cart SET updated_time = ?, cart_code = ?, model_id = ?, updated_by = ? WHERE id = ?
### Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
; bad SQL grammar []', 6, '2026-07-28 15:06:07.202288');
INSERT INTO "public"."sys_log" VALUES (1404, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.updateById-Inline
### The error occurred while setting parameters
### SQL: UPDATE wms_cart SET updated_time = ?, cart_code = ?, model_id = ?, updated_by = ? WHERE id = ?
### Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
; bad SQL grammar []', 6, '2026-07-28 15:08:06.807403');
INSERT INTO "public"."sys_log" VALUES (1405, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.updateById-Inline
### The error occurred while setting parameters
### SQL: UPDATE wms_cart SET updated_time = ?, cart_code = ?, model_id = ?, updated_by = ? WHERE id = ?
### Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
; bad SQL grammar []', 5, '2026-07-28 15:08:26.5803');
INSERT INTO "public"."sys_log" VALUES (1440, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-28 16:20:35.565797');
INSERT INTO "public"."sys_log" VALUES (1406, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.updateById-Inline
### The error occurred while setting parameters
### SQL: UPDATE wms_cart SET updated_time = ?, cart_code = ?, model_id = ?, updated_by = ? WHERE id = ?
### Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
; bad SQL grammar []', 16, '2026-07-28 15:09:23.881082');
INSERT INTO "public"."sys_log" VALUES (1407, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-28 15:09:32.826686');
INSERT INTO "public"."sys_log" VALUES (1408, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error updating database.  Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
### The error may exist in com/wms/carriermanagementsystem/cart/mapper/CartMapper.java (best guess)
### The error may involve com.wms.carriermanagementsystem.cart.mapper.CartMapper.updateById-Inline
### The error occurred while setting parameters
### SQL: UPDATE wms_cart SET updated_time = ?, cart_code = ?, model_id = ?, updated_by = ? WHERE id = ?
### Cause: org.postgresql.util.PSQLException: 错误: 记录"new"没有字段"updated_at"
  在位置：PL/pgSQL assignment "NEW.updated_at = CURRENT_TIMESTAMP"
在赋值的第3行的PL/pgSQL函数update_updated_at_column()
; bad SQL grammar []', 7, '2026-07-28 15:09:38.440953');
INSERT INTO "public"."sys_log" VALUES (1409, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-28 15:10:32.894225');
INSERT INTO "public"."sys_log" VALUES (1410, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-28 15:10:33.275831');
INSERT INTO "public"."sys_log" VALUES (1411, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-28 15:10:38.101113');
INSERT INTO "public"."sys_log" VALUES (1412, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-07-28 15:10:38.528701');
INSERT INTO "public"."sys_log" VALUES (1413, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-28 15:11:05.846593');
INSERT INTO "public"."sys_log" VALUES (1414, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 22, '2026-07-28 15:11:06.248503');
INSERT INTO "public"."sys_log" VALUES (1415, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-28 15:11:12.895412');
INSERT INTO "public"."sys_log" VALUES (1416, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 15:11:13.257033');
INSERT INTO "public"."sys_log" VALUES (1417, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-28 16:03:56.130517');
INSERT INTO "public"."sys_log" VALUES (1418, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 43, '2026-07-28 16:12:59.648412');
INSERT INTO "public"."sys_log" VALUES (1419, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 50, '2026-07-28 16:14:17.226518');
INSERT INTO "public"."sys_log" VALUES (1420, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 226, '2026-07-28 16:14:18.321689');
INSERT INTO "public"."sys_log" VALUES (1421, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2837', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 178, '2026-07-28 16:14:33.212795');
INSERT INTO "public"."sys_log" VALUES (1422, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-28 16:14:33.62435');
INSERT INTO "public"."sys_log" VALUES (1423, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2837', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 66, '2026-07-28 16:15:22.637285');
INSERT INTO "public"."sys_log" VALUES (1424, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-07-28 16:15:23.063305');
INSERT INTO "public"."sys_log" VALUES (1425, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 79, '2026-07-28 16:15:51.286658');
INSERT INTO "public"."sys_log" VALUES (1426, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-07-28 16:15:51.814496');
INSERT INTO "public"."sys_log" VALUES (1427, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2837', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 87, '2026-07-28 16:16:04.398308');
INSERT INTO "public"."sys_log" VALUES (1428, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-28 16:16:04.861508');
INSERT INTO "public"."sys_log" VALUES (1429, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-28 16:19:24.64052');
INSERT INTO "public"."sys_log" VALUES (1430, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-28 16:19:25.169426');
INSERT INTO "public"."sys_log" VALUES (1431, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2839', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 395, '2026-07-28 16:19:38.042141');
INSERT INTO "public"."sys_log" VALUES (1432, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 47, '2026-07-28 16:19:38.566075');
INSERT INTO "public"."sys_log" VALUES (1433, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 48, '2026-07-28 16:20:03.175214');
INSERT INTO "public"."sys_log" VALUES (1434, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 43, '2026-07-28 16:20:04.013943');
INSERT INTO "public"."sys_log" VALUES (1435, 5, 3, '菜单管理-新增', '', 2, 'admin', '/api/v1/menus', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-28 16:20:20.336948');
INSERT INTO "public"."sys_log" VALUES (1436, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-28 16:20:20.84262');
INSERT INTO "public"."sys_log" VALUES (1437, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-28 16:20:23.848569');
INSERT INTO "public"."sys_log" VALUES (1441, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 16:20:48.074327');
INSERT INTO "public"."sys_log" VALUES (1442, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-28 16:20:50.598566');
INSERT INTO "public"."sys_log" VALUES (1443, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2837', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 484, '2026-07-28 16:21:17.555268');
INSERT INTO "public"."sys_log" VALUES (1444, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 16:21:17.988981');
INSERT INTO "public"."sys_log" VALUES (1445, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-28 16:21:23.21272');
INSERT INTO "public"."sys_log" VALUES (1446, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 575, '2026-07-28 17:03:15.910517');
INSERT INTO "public"."sys_log" VALUES (1447, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 67, '2026-07-28 17:03:19.988814');
INSERT INTO "public"."sys_log" VALUES (1448, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1722, '2026-07-28 17:03:35.935834');
INSERT INTO "public"."sys_log" VALUES (1449, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-28 17:03:36.043303');
INSERT INTO "public"."sys_log" VALUES (1450, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 37, '2026-07-28 17:03:41.785373');
INSERT INTO "public"."sys_log" VALUES (1451, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 69, '2026-07-28 17:05:24.059382');
INSERT INTO "public"."sys_log" VALUES (1452, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-07-28 17:05:46.001384');
INSERT INTO "public"."sys_log" VALUES (1453, 5, 4, '菜单管理-修改', '', 2, 'admin', '/api/v1/menus/2826', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 180, '2026-07-28 17:05:51.851989');
INSERT INTO "public"."sys_log" VALUES (1454, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 106, '2026-07-28 17:05:52.3474');
INSERT INTO "public"."sys_log" VALUES (1455, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/1/take', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-28 17:09:36.557345');
INSERT INTO "public"."sys_log" VALUES (1456, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 17:09:36.905748');
INSERT INTO "public"."sys_log" VALUES (1457, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-28 17:10:00.847223');
INSERT INTO "public"."sys_log" VALUES (1458, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 17:10:04.134048');
INSERT INTO "public"."sys_log" VALUES (1459, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-28 17:10:12.498047');
INSERT INTO "public"."sys_log" VALUES (1460, 86, 5, '料车物品管理-删除', '', 2, 'admin', '/api/v1/cart-item/1', 'DELETE', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-28 17:10:21.668558');
INSERT INTO "public"."sys_log" VALUES (1461, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-28 17:10:22.023831');
INSERT INTO "public"."sys_log" VALUES (1462, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-28 17:10:26.324187');
INSERT INTO "public"."sys_log" VALUES (1463, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-28 17:10:57.750944');
INSERT INTO "public"."sys_log" VALUES (1464, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 183, '2026-07-29 09:45:12.828911');
INSERT INTO "public"."sys_log" VALUES (1465, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 09:45:15.406476');
INSERT INTO "public"."sys_log" VALUES (1466, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 09:45:19.865806');
INSERT INTO "public"."sys_log" VALUES (1467, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 09:45:21.985819');
INSERT INTO "public"."sys_log" VALUES (1468, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-29 09:46:14.581185');
INSERT INTO "public"."sys_log" VALUES (1469, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 09:46:14.931503');
INSERT INTO "public"."sys_log" VALUES (1470, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 238, '2026-07-29 09:55:57.251171');
INSERT INTO "public"."sys_log" VALUES (1471, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-29 09:55:57.650069');
INSERT INTO "public"."sys_log" VALUES (1472, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-29 09:56:09.324255');
INSERT INTO "public"."sys_log" VALUES (1473, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 09:56:09.675235');
INSERT INTO "public"."sys_log" VALUES (1474, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 09:56:26.240465');
INSERT INTO "public"."sys_log" VALUES (1475, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 09:56:26.58299');
INSERT INTO "public"."sys_log" VALUES (1476, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 10:09:40.202256');
INSERT INTO "public"."sys_log" VALUES (1477, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 10:09:40.505373');
INSERT INTO "public"."sys_log" VALUES (1478, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-29 10:17:28.226097');
INSERT INTO "public"."sys_log" VALUES (1479, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 331, '2026-07-29 10:17:39.054958');
INSERT INTO "public"."sys_log" VALUES (1480, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 10:17:39.098067');
INSERT INTO "public"."sys_log" VALUES (1481, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 10:17:42.862912');
INSERT INTO "public"."sys_log" VALUES (1482, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 10:18:05.281349');
INSERT INTO "public"."sys_log" VALUES (1483, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 10:18:05.623509');
INSERT INTO "public"."sys_log" VALUES (1484, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 10:18:10.491416');
INSERT INTO "public"."sys_log" VALUES (1485, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 10:20:00.797236');
INSERT INTO "public"."sys_log" VALUES (1486, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 10:20:01.130976');
INSERT INTO "public"."sys_log" VALUES (1487, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-29 10:23:37.613805');
INSERT INTO "public"."sys_log" VALUES (1488, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 10:24:27.417401');
INSERT INTO "public"."sys_log" VALUES (1489, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 10:24:38.077543');
INSERT INTO "public"."sys_log" VALUES (1490, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-29 10:26:11.263282');
INSERT INTO "public"."sys_log" VALUES (1491, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-29 10:26:13.282042');
INSERT INTO "public"."sys_log" VALUES (1492, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 352, '2026-07-29 10:26:20.61125');
INSERT INTO "public"."sys_log" VALUES (1493, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 10:26:20.961571');
INSERT INTO "public"."sys_log" VALUES (1494, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 10:26:26.883456');
INSERT INTO "public"."sys_log" VALUES (1495, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 10:26:27.239158');
INSERT INTO "public"."sys_log" VALUES (1496, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 10:26:34.391246');
INSERT INTO "public"."sys_log" VALUES (1497, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 10:26:34.732846');
INSERT INTO "public"."sys_log" VALUES (1498, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 10:26:42.854417');
INSERT INTO "public"."sys_log" VALUES (1499, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 10:26:43.189875');
INSERT INTO "public"."sys_log" VALUES (1500, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 10:26:53.560475');
INSERT INTO "public"."sys_log" VALUES (1501, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 10:26:53.896992');
INSERT INTO "public"."sys_log" VALUES (1502, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 10:28:21.274239');
INSERT INTO "public"."sys_log" VALUES (1503, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 10:33:16.752356');
INSERT INTO "public"."sys_log" VALUES (1504, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 10:33:18.475606');
INSERT INTO "public"."sys_log" VALUES (1505, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 10:36:25.791127');
INSERT INTO "public"."sys_log" VALUES (1506, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 10:36:46.028854');
INSERT INTO "public"."sys_log" VALUES (1507, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 10:39:01.191299');
INSERT INTO "public"."sys_log" VALUES (1508, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 10:39:15.492469');
INSERT INTO "public"."sys_log" VALUES (1509, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 10:42:54.245158');
INSERT INTO "public"."sys_log" VALUES (1510, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 10:42:57.296364');
INSERT INTO "public"."sys_log" VALUES (1511, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 10:45:36.22814');
INSERT INTO "public"."sys_log" VALUES (1512, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 10:50:02.627017');
INSERT INTO "public"."sys_log" VALUES (1513, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 11:08:06.389474');
INSERT INTO "public"."sys_log" VALUES (1514, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 11:08:31.76379');
INSERT INTO "public"."sys_log" VALUES (1515, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 11:09:22.495907');
INSERT INTO "public"."sys_log" VALUES (1516, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 11:11:08.201924');
INSERT INTO "public"."sys_log" VALUES (1517, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 11:31:16.459314');
INSERT INTO "public"."sys_log" VALUES (1518, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 11:31:27.982959');
INSERT INTO "public"."sys_log" VALUES (1519, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 11:31:28.937211');
INSERT INTO "public"."sys_log" VALUES (1520, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 11:31:50.461015');
INSERT INTO "public"."sys_log" VALUES (1521, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 11:31:52.002207');
INSERT INTO "public"."sys_log" VALUES (1522, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 11:31:54.415617');
INSERT INTO "public"."sys_log" VALUES (1523, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 11:31:58.074954');
INSERT INTO "public"."sys_log" VALUES (1524, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 11:32:00.488181');
INSERT INTO "public"."sys_log" VALUES (1525, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 255, '2026-07-29 13:23:54.457641');
INSERT INTO "public"."sys_log" VALUES (1526, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 13:23:57.111616');
INSERT INTO "public"."sys_log" VALUES (1527, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 13:23:57.811749');
INSERT INTO "public"."sys_log" VALUES (1528, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 13:24:02.334743');
INSERT INTO "public"."sys_log" VALUES (1529, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 13:24:03.333237');
INSERT INTO "public"."sys_log" VALUES (1530, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 13:25:43.080774');
INSERT INTO "public"."sys_log" VALUES (1531, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 13:27:20.969309');
INSERT INTO "public"."sys_log" VALUES (1532, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-29 13:29:41.228377');
INSERT INTO "public"."sys_log" VALUES (1533, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 13:29:43.056079');
INSERT INTO "public"."sys_log" VALUES (1534, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-29 13:29:56.444927');
INSERT INTO "public"."sys_log" VALUES (1535, 1, 1, '登录-登录', '', NULL, NULL, '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 0, '
### Error querying database.  Cause: org.postgresql.util.PSQLException: An I/O error occurred while sending to the backend.
### The error may exist in file [D:\workcoding\wms20260712\wms\target\classes\mapper\system\UserMapper.xml]
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT t1.id userId, t1.username, t1.nickname, t1.PASSWORD, t1.STATUS, t1.dept_id, t3.CODE FROM sys_user t1 LEFT JOIN sys_user_role t2 ON t2.user_id = t1.id LEFT JOIN sys_role t3 ON t3.id = t2.role_id WHERE t1.username = ? AND t1.is_deleted = 0
### Cause: org.postgresql.util.PSQLException: An I/O error occurred while sending to the backend.
; An I/O error occurred while sending to the backend.', 265, '2026-07-29 13:30:50.197524');
INSERT INTO "public"."sys_log" VALUES (1536, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 120, '2026-07-29 13:30:58.193879');
INSERT INTO "public"."sys_log" VALUES (1537, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-29 13:31:02.038013');
INSERT INTO "public"."sys_log" VALUES (1538, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 13:31:09.250202');
INSERT INTO "public"."sys_log" VALUES (1539, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 13:31:16.239155');
INSERT INTO "public"."sys_log" VALUES (1540, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 13:31:19.946298');
INSERT INTO "public"."sys_log" VALUES (1541, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-29 13:34:34.782425');
INSERT INTO "public"."sys_log" VALUES (1542, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 13:34:39.244864');
INSERT INTO "public"."sys_log" VALUES (1543, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 13:34:43.401472');
INSERT INTO "public"."sys_log" VALUES (1544, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 13:34:52.976208');
INSERT INTO "public"."sys_log" VALUES (1545, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-29 13:38:20.927854');
INSERT INTO "public"."sys_log" VALUES (1546, 81, 4, '点位管理-修改', '', 2, 'admin', '/api/v1/wms-point/371', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-07-29 13:38:37.181143');
INSERT INTO "public"."sys_log" VALUES (1547, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-29 13:38:37.547867');
INSERT INTO "public"."sys_log" VALUES (1548, 81, 4, '点位管理-修改', '', 2, 'admin', '/api/v1/wms-point/373', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 13:38:50.673782');
INSERT INTO "public"."sys_log" VALUES (1549, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 13:38:51.028682');
INSERT INTO "public"."sys_log" VALUES (1550, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 13:38:56.77422');
INSERT INTO "public"."sys_log" VALUES (1551, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 13:39:06.54435');
INSERT INTO "public"."sys_log" VALUES (1552, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 13:39:17.344245');
INSERT INTO "public"."sys_log" VALUES (1553, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 13:39:19.952362');
INSERT INTO "public"."sys_log" VALUES (1554, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 13:39:36.224825');
INSERT INTO "public"."sys_log" VALUES (1555, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 13:39:43.411475');
INSERT INTO "public"."sys_log" VALUES (1556, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 13:40:04.204402');
INSERT INTO "public"."sys_log" VALUES (1557, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/2/take', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 337, '2026-07-29 13:40:16.980685');
INSERT INTO "public"."sys_log" VALUES (1558, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 13:40:17.004903');
INSERT INTO "public"."sys_log" VALUES (1559, 86, 5, '料车物品管理-删除', '', 2, 'admin', '/api/v1/cart-item/2', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-29 13:40:19.983067');
INSERT INTO "public"."sys_log" VALUES (1560, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 13:40:20.313291');
INSERT INTO "public"."sys_log" VALUES (1561, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 13:40:24.302471');
INSERT INTO "public"."sys_log" VALUES (1562, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 14:38:10.302678');
INSERT INTO "public"."sys_log" VALUES (1563, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-29 15:10:08.832529');
INSERT INTO "public"."sys_log" VALUES (1564, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 15:10:10.245607');
INSERT INTO "public"."sys_log" VALUES (1565, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:10:13.363323');
INSERT INTO "public"."sys_log" VALUES (1566, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 15:10:15.603647');
INSERT INTO "public"."sys_log" VALUES (1567, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 336, '2026-07-29 15:10:23.845367');
INSERT INTO "public"."sys_log" VALUES (1568, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 15:10:23.882807');
INSERT INTO "public"."sys_log" VALUES (1569, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:10:29.20577');
INSERT INTO "public"."sys_log" VALUES (1570, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:10:33.473116');
INSERT INTO "public"."sys_log" VALUES (1571, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/3/take', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-29 15:10:36.138221');
INSERT INTO "public"."sys_log" VALUES (1572, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 15:10:36.475506');
INSERT INTO "public"."sys_log" VALUES (1573, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 15:10:38.575596');
INSERT INTO "public"."sys_log" VALUES (1574, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 15:10:41.291181');
INSERT INTO "public"."sys_log" VALUES (1575, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 15:10:43.7498');
INSERT INTO "public"."sys_log" VALUES (1576, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-29 15:10:49.708366');
INSERT INTO "public"."sys_log" VALUES (1577, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:10:50.616521');
INSERT INTO "public"."sys_log" VALUES (1578, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 15:10:51.023188');
INSERT INTO "public"."sys_log" VALUES (1579, 86, 5, '料车物品管理-删除', '', 2, 'admin', '/api/v1/cart-item/3', 'DELETE', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 15:10:59.851345');
INSERT INTO "public"."sys_log" VALUES (1580, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 15:11:00.178433');
INSERT INTO "public"."sys_log" VALUES (1581, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 15:11:02.934');
INSERT INTO "public"."sys_log" VALUES (1582, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 15:13:06.484355');
INSERT INTO "public"."sys_log" VALUES (1583, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 15:13:09.360183');
INSERT INTO "public"."sys_log" VALUES (1584, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 15:13:11.361712');
INSERT INTO "public"."sys_log" VALUES (1585, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 15:13:13.007209');
INSERT INTO "public"."sys_log" VALUES (1586, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:22:08.97292');
INSERT INTO "public"."sys_log" VALUES (1587, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:26:22.119737');
INSERT INTO "public"."sys_log" VALUES (1588, 81, 4, '点位管理-修改', '', 2, 'admin', '/api/v1/wms-point/371', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:26:53.734557');
INSERT INTO "public"."sys_log" VALUES (1589, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 15:26:54.087622');
INSERT INTO "public"."sys_log" VALUES (1590, 81, 4, '点位管理-修改', '', 2, 'admin', '/api/v1/wms-point/373', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 15:27:13.844512');
INSERT INTO "public"."sys_log" VALUES (1591, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 15:27:14.189011');
INSERT INTO "public"."sys_log" VALUES (1592, 84, 4, '料车型号配置-修改', '', 2, 'admin', '/api/v1/cart-model/3', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 15:28:28.42971');
INSERT INTO "public"."sys_log" VALUES (1593, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 15:28:28.765808');
INSERT INTO "public"."sys_log" VALUES (1594, 84, 4, '料车型号配置-修改', '', 2, 'admin', '/api/v1/cart-model/1', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 15:28:33.814695');
INSERT INTO "public"."sys_log" VALUES (1595, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:28:34.15662');
INSERT INTO "public"."sys_log" VALUES (1596, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 277, '2026-07-29 15:32:34.701471');
INSERT INTO "public"."sys_log" VALUES (1597, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 15:32:37.851406');
INSERT INTO "public"."sys_log" VALUES (1598, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 15:32:38.561198');
INSERT INTO "public"."sys_log" VALUES (1599, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 15:32:48.242103');
INSERT INTO "public"."sys_log" VALUES (1600, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 15:32:51.295412');
INSERT INTO "public"."sys_log" VALUES (1601, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 15:35:44.058383');
INSERT INTO "public"."sys_log" VALUES (1602, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 15:38:58.488918');
INSERT INTO "public"."sys_log" VALUES (1603, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 15:39:00.110697');
INSERT INTO "public"."sys_log" VALUES (1604, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 15:39:08.967056');
INSERT INTO "public"."sys_log" VALUES (1605, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 15:39:14.225065');
INSERT INTO "public"."sys_log" VALUES (1606, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:16:51.058026');
INSERT INTO "public"."sys_log" VALUES (1607, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 16:16:53.214055');
INSERT INTO "public"."sys_log" VALUES (1608, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:16:54.236531');
INSERT INTO "public"."sys_log" VALUES (1609, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 16:16:56.17561');
INSERT INTO "public"."sys_log" VALUES (1610, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 16:17:00.161482');
INSERT INTO "public"."sys_log" VALUES (1611, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-29 16:17:05.338917');
INSERT INTO "public"."sys_log" VALUES (1612, 82, 4, '巷道管理-修改', '', 2, 'admin', '/api/v1/wms-aisle/113', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 16:17:17.899448');
INSERT INTO "public"."sys_log" VALUES (1613, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 16:17:18.248682');
INSERT INTO "public"."sys_log" VALUES (1614, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 16:17:20.588094');
INSERT INTO "public"."sys_log" VALUES (1615, 82, 4, '巷道管理-修改', '', 2, 'admin', '/api/v1/wms-aisle/114', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:17:26.735868');
INSERT INTO "public"."sys_log" VALUES (1616, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:17:27.079641');
INSERT INTO "public"."sys_log" VALUES (1617, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 16:17:29.841601');
INSERT INTO "public"."sys_log" VALUES (1618, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 16:17:33.064278');
INSERT INTO "public"."sys_log" VALUES (1619, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:17:35.785634');
INSERT INTO "public"."sys_log" VALUES (1620, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 16:17:41.172716');
INSERT INTO "public"."sys_log" VALUES (1621, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 16:17:45.119548');
INSERT INTO "public"."sys_log" VALUES (1622, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 16:18:23.257754');
INSERT INTO "public"."sys_log" VALUES (1623, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:18:23.59294');
INSERT INTO "public"."sys_log" VALUES (1624, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:18:35.564886');
INSERT INTO "public"."sys_log" VALUES (1625, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:18:35.905634');
INSERT INTO "public"."sys_log" VALUES (1626, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:18:42.348607');
INSERT INTO "public"."sys_log" VALUES (1627, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:18:42.677021');
INSERT INTO "public"."sys_log" VALUES (1628, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:20:26.559309');
INSERT INTO "public"."sys_log" VALUES (1629, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:23:45.590576');
INSERT INTO "public"."sys_log" VALUES (1630, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:23:47.00143');
INSERT INTO "public"."sys_log" VALUES (1631, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-29 16:38:36.577935');
INSERT INTO "public"."sys_log" VALUES (1632, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:38:36.921598');
INSERT INTO "public"."sys_log" VALUES (1633, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 16:39:03.170299');
INSERT INTO "public"."sys_log" VALUES (1681, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 17:16:52.471321');
INSERT INTO "public"."sys_log" VALUES (1634, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:39:03.502224');
INSERT INTO "public"."sys_log" VALUES (1635, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:47:09.690163');
INSERT INTO "public"."sys_log" VALUES (1636, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 16:50:49.864767');
INSERT INTO "public"."sys_log" VALUES (1637, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:51:07.964269');
INSERT INTO "public"."sys_log" VALUES (1638, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:52:09.334849');
INSERT INTO "public"."sys_log" VALUES (1639, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 16:52:40.744682');
INSERT INTO "public"."sys_log" VALUES (1640, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:52:41.907874');
INSERT INTO "public"."sys_log" VALUES (1641, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 16:53:10.057208');
INSERT INTO "public"."sys_log" VALUES (1642, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 16:53:10.38989');
INSERT INTO "public"."sys_log" VALUES (1643, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:53:33.75468');
INSERT INTO "public"."sys_log" VALUES (1644, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 16:53:38.322996');
INSERT INTO "public"."sys_log" VALUES (1645, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 16:54:12.054952');
INSERT INTO "public"."sys_log" VALUES (1646, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:54:12.389529');
INSERT INTO "public"."sys_log" VALUES (1647, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 16:54:38.287105');
INSERT INTO "public"."sys_log" VALUES (1648, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:54:38.621506');
INSERT INTO "public"."sys_log" VALUES (1649, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/8', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 16:54:44.52799');
INSERT INTO "public"."sys_log" VALUES (1650, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:54:44.85921');
INSERT INTO "public"."sys_log" VALUES (1651, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:54:53.204552');
INSERT INTO "public"."sys_log" VALUES (1652, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:54:59.843237');
INSERT INTO "public"."sys_log" VALUES (1653, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:55:00.458675');
INSERT INTO "public"."sys_log" VALUES (1654, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 16:55:02.751402');
INSERT INTO "public"."sys_log" VALUES (1655, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:55:46.477746');
INSERT INTO "public"."sys_log" VALUES (1656, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 16:56:13.155201');
INSERT INTO "public"."sys_log" VALUES (1657, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 16:56:17.366143');
INSERT INTO "public"."sys_log" VALUES (1658, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 16:57:57.962894');
INSERT INTO "public"."sys_log" VALUES (1659, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:57:58.29798');
INSERT INTO "public"."sys_log" VALUES (1660, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 16:58:09.130843');
INSERT INTO "public"."sys_log" VALUES (1661, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 16:59:38.647489');
INSERT INTO "public"."sys_log" VALUES (1662, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 16:59:38.982027');
INSERT INTO "public"."sys_log" VALUES (1663, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/10', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 16:59:56.745901');
INSERT INTO "public"."sys_log" VALUES (1664, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 16:59:57.081553');
INSERT INTO "public"."sys_log" VALUES (1665, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 17:03:07.505471');
INSERT INTO "public"."sys_log" VALUES (1666, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 17:03:07.836645');
INSERT INTO "public"."sys_log" VALUES (1667, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:05:09.709953');
INSERT INTO "public"."sys_log" VALUES (1668, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 17:05:19.042016');
INSERT INTO "public"."sys_log" VALUES (1669, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:05:20.475559');
INSERT INTO "public"."sys_log" VALUES (1670, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 17:05:21.380181');
INSERT INTO "public"."sys_log" VALUES (1671, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 17:14:08.162463');
INSERT INTO "public"."sys_log" VALUES (1672, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 17:14:30.750357');
INSERT INTO "public"."sys_log" VALUES (1673, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-07-29 17:15:06.779468');
INSERT INTO "public"."sys_log" VALUES (1674, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 17:15:07.126132');
INSERT INTO "public"."sys_log" VALUES (1675, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 17:15:38.477277');
INSERT INTO "public"."sys_log" VALUES (1676, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 17:15:38.814044');
INSERT INTO "public"."sys_log" VALUES (1677, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 17:16:16.470912');
INSERT INTO "public"."sys_log" VALUES (1678, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:16:16.817246');
INSERT INTO "public"."sys_log" VALUES (1679, 86, 3, '料车物品管理-新增', '', 2, 'admin', '/api/v1/cart-item', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 17:16:47.37179');
INSERT INTO "public"."sys_log" VALUES (1680, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 17:16:47.710799');
INSERT INTO "public"."sys_log" VALUES (1682, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:17:17.47188');
INSERT INTO "public"."sys_log" VALUES (1683, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:17:17.495275');
INSERT INTO "public"."sys_log" VALUES (1684, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 2, '2026-07-29 17:17:24.600812');
INSERT INTO "public"."sys_log" VALUES (1685, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:17:24.925768');
INSERT INTO "public"."sys_log" VALUES (1686, 85, 3, '料车管理-新增', '', 2, 'admin', '/api/v1/cart', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 17:17:30.362794');
INSERT INTO "public"."sys_log" VALUES (1687, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:17:30.690594');
INSERT INTO "public"."sys_log" VALUES (1688, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:17:36.121697');
INSERT INTO "public"."sys_log" VALUES (1689, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 17:17:37.741215');
INSERT INTO "public"."sys_log" VALUES (1690, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 176, '2026-07-29 19:03:07.044956');
INSERT INTO "public"."sys_log" VALUES (1691, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 19:03:14.159357');
INSERT INTO "public"."sys_log" VALUES (1692, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 19:04:16.595442');
INSERT INTO "public"."sys_log" VALUES (1693, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 19:05:01.54161');
INSERT INTO "public"."sys_log" VALUES (1694, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 19:20:14.175852');
INSERT INTO "public"."sys_log" VALUES (1695, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 19:24:43.607953');
INSERT INTO "public"."sys_log" VALUES (1696, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 19:36:43.25934');
INSERT INTO "public"."sys_log" VALUES (1697, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 19:37:13.084782');
INSERT INTO "public"."sys_log" VALUES (1698, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 19:37:21.369478');
INSERT INTO "public"."sys_log" VALUES (1699, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/batch-status', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 48, '2026-07-29 19:37:39.817604');
INSERT INTO "public"."sys_log" VALUES (1700, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 19:37:40.136688');
INSERT INTO "public"."sys_log" VALUES (1701, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/batch-status', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 3, '2026-07-29 19:37:45.104501');
INSERT INTO "public"."sys_log" VALUES (1702, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 19:37:45.432162');
INSERT INTO "public"."sys_log" VALUES (1703, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 19:37:52.205009');
INSERT INTO "public"."sys_log" VALUES (1704, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 5, '2026-07-29 19:37:59.035578');
INSERT INTO "public"."sys_log" VALUES (1705, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-07-29 19:39:14.474323');
INSERT INTO "public"."sys_log" VALUES (1706, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 4, '2026-07-29 19:48:27.473246');
INSERT INTO "public"."sys_log" VALUES (1707, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 40, '2026-07-29 20:03:22.342051');
INSERT INTO "public"."sys_log" VALUES (1708, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 20:03:27.187462');
INSERT INTO "public"."sys_log" VALUES (1709, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-29 20:03:29.983791');
INSERT INTO "public"."sys_log" VALUES (1710, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/31/take', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 312, '2026-07-29 20:03:43.800628');
INSERT INTO "public"."sys_log" VALUES (1711, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 20:03:43.834262');
INSERT INTO "public"."sys_log" VALUES (1712, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 23, '2026-07-29 20:03:48.964864');
INSERT INTO "public"."sys_log" VALUES (1713, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-07-29 20:04:24.560743');
INSERT INTO "public"."sys_log" VALUES (1714, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 20:04:35.142806');
INSERT INTO "public"."sys_log" VALUES (1715, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 20:04:38.828095');
INSERT INTO "public"."sys_log" VALUES (1716, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 20:04:54.88935');
INSERT INTO "public"."sys_log" VALUES (1717, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-07-29 20:07:11.235119');
INSERT INTO "public"."sys_log" VALUES (1718, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 20:07:14.182453');
INSERT INTO "public"."sys_log" VALUES (1719, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 20:07:21.186115');
INSERT INTO "public"."sys_log" VALUES (1720, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 20:07:26.648053');
INSERT INTO "public"."sys_log" VALUES (1721, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 20:07:33.845733');
INSERT INTO "public"."sys_log" VALUES (1722, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 20:13:46.735908');
INSERT INTO "public"."sys_log" VALUES (1723, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 20:14:29.233034');
INSERT INTO "public"."sys_log" VALUES (1724, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 20:14:41.003993');
INSERT INTO "public"."sys_log" VALUES (1725, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 20:14:44.161302');
INSERT INTO "public"."sys_log" VALUES (1730, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 20:15:58.854413');
INSERT INTO "public"."sys_log" VALUES (1726, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-29 20:15:40.027768');
INSERT INTO "public"."sys_log" VALUES (1727, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 20:15:42.762019');
INSERT INTO "public"."sys_log" VALUES (1728, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-29 20:15:44.195157');
INSERT INTO "public"."sys_log" VALUES (1729, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 20:15:57.580968');
INSERT INTO "public"."sys_log" VALUES (1731, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-07-29 20:25:32.305096');
INSERT INTO "public"."sys_log" VALUES (1732, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-07-29 20:25:37.104842');
INSERT INTO "public"."sys_log" VALUES (1733, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 20:25:39.860662');
INSERT INTO "public"."sys_log" VALUES (1734, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-29 20:25:41.939249');
INSERT INTO "public"."sys_log" VALUES (1735, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-29 20:25:43.508012');
INSERT INTO "public"."sys_log" VALUES (1736, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-29 20:25:44.726042');
INSERT INTO "public"."sys_log" VALUES (1737, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-29 20:28:55.315883');
INSERT INTO "public"."sys_log" VALUES (1738, 86, 4, '料车物品管理-修改', '', 2, 'admin', '/api/v1/cart-item/63', 'PUT', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 353, '2026-07-29 20:29:06.653728');
INSERT INTO "public"."sys_log" VALUES (1739, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-29 20:29:06.99844');
INSERT INTO "public"."sys_log" VALUES (1740, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-29 20:29:10.234448');
INSERT INTO "public"."sys_log" VALUES (1741, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.107', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-07-29 20:41:02.25244');
INSERT INTO "public"."sys_log" VALUES (1742, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 864, '2026-07-30 10:24:21.566558');
INSERT INTO "public"."sys_log" VALUES (1743, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 165, '2026-07-30 10:24:51.237108');
INSERT INTO "public"."sys_log" VALUES (1744, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 78, '2026-07-30 10:24:53.079039');
INSERT INTO "public"."sys_log" VALUES (1745, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 224, '2026-07-30 10:24:55.277481');
INSERT INTO "public"."sys_log" VALUES (1746, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-07-30 10:28:47.368021');
INSERT INTO "public"."sys_log" VALUES (1747, 7, 4, '系统配置-修改', '', 2, 'admin', '/api/v1/configs/refresh', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-07-30 10:29:52.574935');
INSERT INTO "public"."sys_log" VALUES (1748, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 64, '2026-07-30 10:30:43.283724');
INSERT INTO "public"."sys_log" VALUES (1749, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 105, '2026-07-30 10:30:58.051114');
INSERT INTO "public"."sys_log" VALUES (1750, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 189, '2026-07-30 21:02:14.721185');
INSERT INTO "public"."sys_log" VALUES (1751, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-30 21:02:17.474968');
INSERT INTO "public"."sys_log" VALUES (1752, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 21, '2026-07-30 21:02:18.616011');
INSERT INTO "public"."sys_log" VALUES (1753, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-30 21:02:19.938114');
INSERT INTO "public"."sys_log" VALUES (1754, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-30 21:02:23.075132');
INSERT INTO "public"."sys_log" VALUES (1755, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-07-30 21:02:25.105182');
INSERT INTO "public"."sys_log" VALUES (1756, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-07-30 21:02:29.204024');
INSERT INTO "public"."sys_log" VALUES (1757, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-30 21:02:29.937697');
INSERT INTO "public"."sys_log" VALUES (1758, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-07-30 21:02:43.064516');
INSERT INTO "public"."sys_log" VALUES (1759, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 159, '2026-07-31 11:06:34.628601');
INSERT INTO "public"."sys_log" VALUES (1760, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 30, '2026-07-31 11:06:38.687593');
INSERT INTO "public"."sys_log" VALUES (1761, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-07-31 11:06:38.810858');
INSERT INTO "public"."sys_log" VALUES (1762, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-31 11:06:42.182133');
INSERT INTO "public"."sys_log" VALUES (1763, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-07-31 11:06:43.356692');
INSERT INTO "public"."sys_log" VALUES (1764, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-31 11:06:44.633046');
INSERT INTO "public"."sys_log" VALUES (1765, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-07-31 11:06:46.885997');
INSERT INTO "public"."sys_log" VALUES (1766, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-07-31 11:06:48.510777');
INSERT INTO "public"."sys_log" VALUES (1767, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.110', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-07-31 11:06:49.926151');
INSERT INTO "public"."sys_log" VALUES (1768, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.108', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 248, '2026-08-03 10:39:55.665491');
INSERT INTO "public"."sys_log" VALUES (1769, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1263, '2026-08-03 16:41:25.842622');
INSERT INTO "public"."sys_log" VALUES (1770, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 1047, '2026-08-03 16:41:46.095515');
INSERT INTO "public"."sys_log" VALUES (1771, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 97, '2026-08-03 16:41:52.655455');
INSERT INTO "public"."sys_log" VALUES (1772, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 34, '2026-08-03 17:25:37.171839');
INSERT INTO "public"."sys_log" VALUES (1773, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.112', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 115, '2026-08-03 22:52:06.866735');
INSERT INTO "public"."sys_log" VALUES (1774, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.112', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-08-03 22:52:12.036178');
INSERT INTO "public"."sys_log" VALUES (1775, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.112', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-08-03 22:52:21.141031');
INSERT INTO "public"."sys_log" VALUES (1776, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.112', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-08-03 23:26:44.470034');
INSERT INTO "public"."sys_log" VALUES (1777, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 757, '2026-08-04 17:19:35.886891');
INSERT INTO "public"."sys_log" VALUES (1778, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 92, '2026-08-04 17:19:42.936646');
INSERT INTO "public"."sys_log" VALUES (1779, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 107, '2026-08-04 17:19:44.4677');
INSERT INTO "public"."sys_log" VALUES (1780, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 122, '2026-08-04 17:19:47.417436');
INSERT INTO "public"."sys_log" VALUES (1781, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 43, '2026-08-04 17:33:43.367584');
INSERT INTO "public"."sys_log" VALUES (1782, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 56, '2026-08-04 17:33:44.512876');
INSERT INTO "public"."sys_log" VALUES (1783, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-08-04 17:33:52.749993');
INSERT INTO "public"."sys_log" VALUES (1784, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 92, '2026-08-04 17:33:55.365669');
INSERT INTO "public"."sys_log" VALUES (1785, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-08-04 17:34:07.18013');
INSERT INTO "public"."sys_log" VALUES (1786, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-08-04 17:34:40.097653');
INSERT INTO "public"."sys_log" VALUES (1787, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 25, '2026-08-04 17:34:40.96531');
INSERT INTO "public"."sys_log" VALUES (1788, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 71, '2026-08-04 17:34:42.727791');
INSERT INTO "public"."sys_log" VALUES (1789, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-08-04 17:34:45.643757');
INSERT INTO "public"."sys_log" VALUES (1790, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 31, '2026-08-04 17:34:54.196719');
INSERT INTO "public"."sys_log" VALUES (1791, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 58, '2026-08-04 17:41:02.932307');
INSERT INTO "public"."sys_log" VALUES (1792, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 50, '2026-08-04 17:41:04.821809');
INSERT INTO "public"."sys_log" VALUES (1793, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-08-04 17:41:08.581417');
INSERT INTO "public"."sys_log" VALUES (1794, 84, 4, '料车型号配置-修改', '', 2, 'admin', '/api/v1/cart-model/3', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 39, '2026-08-04 17:41:27.164922');
INSERT INTO "public"."sys_log" VALUES (1795, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-08-04 17:41:27.520208');
INSERT INTO "public"."sys_log" VALUES (1796, 85, 4, '料车管理-修改', '', 2, 'admin', '/api/v1/cart/1', 'PUT', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-08-04 17:41:40.021582');
INSERT INTO "public"."sys_log" VALUES (1797, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 37, '2026-08-04 17:41:40.41558');
INSERT INTO "public"."sys_log" VALUES (1798, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 20, '2026-08-04 17:42:11.225924');
INSERT INTO "public"."sys_log" VALUES (1799, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-08-04 17:42:12.860628');
INSERT INTO "public"."sys_log" VALUES (1800, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 15, '2026-08-04 17:42:14.77813');
INSERT INTO "public"."sys_log" VALUES (1801, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 69, '2026-08-04 17:42:19.111597');
INSERT INTO "public"."sys_log" VALUES (1802, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-08-04 17:42:19.145101');
INSERT INTO "public"."sys_log" VALUES (1803, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-08-04 17:42:24.750469');
INSERT INTO "public"."sys_log" VALUES (1804, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.8', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-08-04 17:42:25.879707');
INSERT INTO "public"."sys_log" VALUES (1805, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 247, '2026-08-05 09:22:48.115879');
INSERT INTO "public"."sys_log" VALUES (1806, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-08-05 09:22:50.6087');
INSERT INTO "public"."sys_log" VALUES (1807, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-08-05 09:22:50.755467');
INSERT INTO "public"."sys_log" VALUES (1808, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-08-05 09:26:13.541837');
INSERT INTO "public"."sys_log" VALUES (1809, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-08-05 09:26:13.876411');
INSERT INTO "public"."sys_log" VALUES (1810, 3, 15, '角色管理-查询列表', '', 2, 'admin', '/api/v1/roles', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-08-05 09:26:49.012399');
INSERT INTO "public"."sys_log" VALUES (1811, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-08-05 09:26:51.191815');
INSERT INTO "public"."sys_log" VALUES (1812, 4, 15, '部门管理-查询列表', '', 2, 'admin', '/api/v1/depts', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-08-05 09:26:52.301472');
INSERT INTO "public"."sys_log" VALUES (1813, 6, 15, '字典管理-查询列表', '', 2, 'admin', '/api/v1/dicts', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-08-05 09:26:53.475707');
INSERT INTO "public"."sys_log" VALUES (1814, 9, 15, '日志管理-查询列表', '', 2, 'admin', '/api/v1/logs', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-08-05 09:26:54.725663');
INSERT INTO "public"."sys_log" VALUES (1815, 7, 15, '系统配置-查询列表', '', 2, 'admin', '/api/v1/configs', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-08-05 09:26:55.643802');
INSERT INTO "public"."sys_log" VALUES (1816, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-08-05 09:26:57.424616');
INSERT INTO "public"."sys_log" VALUES (1817, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 61, '2026-08-05 09:27:56.572154');
INSERT INTO "public"."sys_log" VALUES (1818, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 18, '2026-08-05 09:28:02.617257');
INSERT INTO "public"."sys_log" VALUES (1819, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-08-05 09:28:02.93529');
INSERT INTO "public"."sys_log" VALUES (1820, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-08-05 09:28:05.395036');
INSERT INTO "public"."sys_log" VALUES (1821, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-08-05 09:47:48.64946');
INSERT INTO "public"."sys_log" VALUES (1822, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-08-05 09:56:47.961812');
INSERT INTO "public"."sys_log" VALUES (1823, 5, 15, '菜单管理-查询列表', '', 2, 'admin', '/api/v1/menus', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-08-05 09:57:08.462756');
INSERT INTO "public"."sys_log" VALUES (1824, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-08-05 10:02:05.834919');
INSERT INTO "public"."sys_log" VALUES (1825, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 10, '2026-08-05 10:57:38.546049');
INSERT INTO "public"."sys_log" VALUES (1826, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 251, '2026-08-05 11:43:34.167677');
INSERT INTO "public"."sys_log" VALUES (1827, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 27, '2026-08-05 11:43:39.697509');
INSERT INTO "public"."sys_log" VALUES (1828, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-08-05 11:45:24.326164');
INSERT INTO "public"."sys_log" VALUES (1829, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.103', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-08-05 12:00:19.629793');
INSERT INTO "public"."sys_log" VALUES (1830, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.2.12', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 517, '2026-08-06 16:50:14.064552');
INSERT INTO "public"."sys_log" VALUES (1831, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.2.12', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-08-06 16:50:18.518177');
INSERT INTO "public"."sys_log" VALUES (1832, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.2.12', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-08-06 16:57:00.653422');
INSERT INTO "public"."sys_log" VALUES (1833, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.2.12', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 35, '2026-08-06 16:57:17.022054');
INSERT INTO "public"."sys_log" VALUES (1834, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.2.12', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 75, '2026-08-06 16:57:29.798829');
INSERT INTO "public"."sys_log" VALUES (1835, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.2.12', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-08-06 16:57:54.080284');
INSERT INTO "public"."sys_log" VALUES (1836, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.2.12', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 13, '2026-08-06 17:23:57.078661');
INSERT INTO "public"."sys_log" VALUES (1837, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '10.14.184.182', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 817, '2026-08-07 14:00:09.38304');
INSERT INTO "public"."sys_log" VALUES (1838, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '10.14.184.182', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-08-07 14:00:14.801032');
INSERT INTO "public"."sys_log" VALUES (1839, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '10.14.184.182', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 66, '2026-08-07 14:00:18.118017');
INSERT INTO "public"."sys_log" VALUES (1840, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '10.14.184.182', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 38, '2026-08-07 14:11:29.704436');
INSERT INTO "public"."sys_log" VALUES (1841, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 304, '2026-08-10 11:52:31.556867');
INSERT INTO "public"."sys_log" VALUES (1842, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-08-10 11:52:39.104106');
INSERT INTO "public"."sys_log" VALUES (1843, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 14, '2026-08-10 11:52:39.139104');
INSERT INTO "public"."sys_log" VALUES (1844, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 12, '2026-08-10 11:52:42.838087');
INSERT INTO "public"."sys_log" VALUES (1845, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-08-10 11:52:44.216917');
INSERT INTO "public"."sys_log" VALUES (1846, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-08-10 11:52:45.439214');
INSERT INTO "public"."sys_log" VALUES (1847, 84, 15, '料车型号配置-查询列表', '', 2, 'admin', '/api/v1/cart-model', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-08-10 11:52:46.792302');
INSERT INTO "public"."sys_log" VALUES (1848, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-08-10 11:52:48.000644');
INSERT INTO "public"."sys_log" VALUES (1849, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-08-10 11:52:49.309895');
INSERT INTO "public"."sys_log" VALUES (1850, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-08-10 11:52:52.893354');
INSERT INTO "public"."sys_log" VALUES (1851, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-08-10 11:52:54.610747');
INSERT INTO "public"."sys_log" VALUES (1852, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.104', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 6, '2026-08-10 11:52:56.16932');
INSERT INTO "public"."sys_log" VALUES (1853, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '10.14.184.115', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 335, '2026-08-10 14:39:35.617036');
INSERT INTO "public"."sys_log" VALUES (1854, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '10.14.184.115', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-08-10 14:39:39.508259');
INSERT INTO "public"."sys_log" VALUES (1855, 2, 15, '用户管理-查询列表', '', 2, 'admin', '/api/v1/users', 'GET', '10.14.184.115', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-08-10 14:39:39.606759');
INSERT INTO "public"."sys_log" VALUES (1856, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '10.14.184.115', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 33, '2026-08-10 14:39:43.089995');
INSERT INTO "public"."sys_log" VALUES (1857, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.9', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 16, '2026-08-10 15:44:04.692514');
INSERT INTO "public"."sys_log" VALUES (1858, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.43.9', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 643, '2026-08-10 16:52:40.189617');
INSERT INTO "public"."sys_log" VALUES (1859, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.43.9', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 59, '2026-08-10 16:52:43.775999');
INSERT INTO "public"."sys_log" VALUES (1860, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.9', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-08-10 16:52:45.450181');
INSERT INTO "public"."sys_log" VALUES (1861, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.43.9', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 36, '2026-08-10 16:52:50.859235');
INSERT INTO "public"."sys_log" VALUES (1862, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.9', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 28, '2026-08-10 16:52:51.728592');
INSERT INTO "public"."sys_log" VALUES (1863, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.43.9', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 29, '2026-08-10 16:52:54.502486');
INSERT INTO "public"."sys_log" VALUES (1864, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.43.9', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-08-10 16:52:56.729564');
INSERT INTO "public"."sys_log" VALUES (1865, 1, 1, '登录-登录', '', 2, 'admin', '/api/v1/auth/login', 'POST', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 382, '2026-08-11 14:34:50.776474');
INSERT INTO "public"."sys_log" VALUES (1866, 86, 15, '料车物品管理-查询列表', '', 2, 'admin', '/api/v1/cart-item', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 26, '2026-08-11 14:34:54.263436');
INSERT INTO "public"."sys_log" VALUES (1867, 85, 15, '料车管理-查询列表', '', 2, 'admin', '/api/v1/cart', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 24, '2026-08-11 14:34:55.312823');
INSERT INTO "public"."sys_log" VALUES (1868, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 11, '2026-08-11 14:35:08.296571');
INSERT INTO "public"."sys_log" VALUES (1869, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 17, '2026-08-11 14:35:09.23569');
INSERT INTO "public"."sys_log" VALUES (1870, 83, 15, '库位/区域管理-查询列表', '', 2, 'admin', '/api/v1/wms-location', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 19, '2026-08-11 14:36:02.608184');
INSERT INTO "public"."sys_log" VALUES (1871, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 9, '2026-08-11 14:36:05.390485');
INSERT INTO "public"."sys_log" VALUES (1872, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-08-11 14:36:06.256971');
INSERT INTO "public"."sys_log" VALUES (1873, 81, 15, '点位管理-查询列表', '', 2, 'admin', '/api/v1/wms-point', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 7, '2026-08-11 14:36:15.779682');
INSERT INTO "public"."sys_log" VALUES (1874, 82, 15, '巷道管理-查询列表', '', 2, 'admin', '/api/v1/wms-aisle', 'GET', '192.168.0.114', '0', '内网IP', 'Windows', 'Windows 10 or Windows Server 2016', 'MSEdge', 1, NULL, 8, '2026-08-11 14:36:18.355926');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_menu";
CREATE TABLE "public"."sys_menu" (
  "id" int8 NOT NULL DEFAULT nextval('sys_menu_id_seq'::regclass),
  "parent_id" int8 NOT NULL,
  "tree_path" varchar(255) COLLATE "pg_catalog"."default",
  "name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "type" varchar(1) COLLATE "pg_catalog"."default" NOT NULL,
  "route_name" varchar(255) COLLATE "pg_catalog"."default",
  "route_path" varchar(128) COLLATE "pg_catalog"."default",
  "component" varchar(128) COLLATE "pg_catalog"."default",
  "external_url" varchar(512) COLLATE "pg_catalog"."default",
  "perm" varchar(128) COLLATE "pg_catalog"."default",
  "always_show" int2 DEFAULT 0,
  "keep_alive" int2 DEFAULT 0,
  "visible" int2 DEFAULT 1,
  "sort" int4 DEFAULT 0,
  "icon" varchar(64) COLLATE "pg_catalog"."default",
  "redirect" varchar(128) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6),
  "update_time" timestamp(6),
  "params" jsonb
)
;
COMMENT ON COLUMN "public"."sys_menu"."id" IS 'ID';
COMMENT ON COLUMN "public"."sys_menu"."parent_id" IS '父菜单ID';
COMMENT ON COLUMN "public"."sys_menu"."tree_path" IS '父节点ID路径';
COMMENT ON COLUMN "public"."sys_menu"."name" IS '菜单名称';
COMMENT ON COLUMN "public"."sys_menu"."type" IS '菜单类型（C-目录 M-菜单 E-外链 B-按钮）';
COMMENT ON COLUMN "public"."sys_menu"."route_name" IS '路由名称（Vue Router 中用于命名路由）';
COMMENT ON COLUMN "public"."sys_menu"."route_path" IS '路由路径（Vue Router 中定义的 URL 路径）';
COMMENT ON COLUMN "public"."sys_menu"."component" IS '组件路径（组件页面完整路径，相对于 src/views/，缺省后缀 .vue）';
COMMENT ON COLUMN "public"."sys_menu"."external_url" IS '外链地址';
COMMENT ON COLUMN "public"."sys_menu"."perm" IS '【按钮】权限标识';
COMMENT ON COLUMN "public"."sys_menu"."always_show" IS '【目录】只有一个子路由是否始终显示（1-是 0-否）';
COMMENT ON COLUMN "public"."sys_menu"."keep_alive" IS '【菜单】是否开启页面缓存（1-是 0-否）';
COMMENT ON COLUMN "public"."sys_menu"."visible" IS '显示状态（1-显示 0-隐藏）';
COMMENT ON COLUMN "public"."sys_menu"."sort" IS '排序';
COMMENT ON COLUMN "public"."sys_menu"."icon" IS '菜单图标';
COMMENT ON COLUMN "public"."sys_menu"."redirect" IS '跳转路径';
COMMENT ON COLUMN "public"."sys_menu"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_menu"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_menu"."params" IS '路由参数';
COMMENT ON TABLE "public"."sys_menu" IS '系统菜单表';

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO "public"."sys_menu" VALUES (2832, 2826, '0,2826', '新增料车', 'M', 'Cart', '/cart', 'carriermanagementsystem/cart/index.vue', NULL, NULL, 0, 1, 1, 2, 'el-icon-Menu', NULL, '2026-07-28 10:39:53.892538', '2026-07-28 10:44:01.075553', NULL);
INSERT INTO "public"."sys_menu" VALUES (2833, 2832, '0,2826,2832', '料车查询', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart:list', 0, 0, 1, 1, NULL, NULL, '2026-07-28 10:41:21.050285', '2026-07-28 10:46:36.191774', NULL);
INSERT INTO "public"."sys_menu" VALUES (2834, 2832, '0,2826,2832', '料车创建', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart:create', 0, 0, 1, 2, NULL, NULL, '2026-07-28 10:42:11.593549', '2026-07-28 10:46:48.93355', NULL);
INSERT INTO "public"."sys_menu" VALUES (2835, 2832, '0,2826,2832', '料车更新', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart:update', 0, 0, 1, 3, NULL, NULL, '2026-07-28 10:42:46.901801', '2026-07-28 10:42:46.901801', NULL);
INSERT INTO "public"."sys_menu" VALUES (2836, 2832, '0,2826,2832', '料车删除', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart:delete', 0, 0, 1, 4, NULL, NULL, '2026-07-28 10:43:07.471866', '2026-07-28 10:43:07.471866', NULL);
INSERT INTO "public"."sys_menu" VALUES (1, 0, '0', '系统管理', 'C', '', '/system', 'Layout', NULL, NULL, 1, NULL, 1, 1, 'system', '/system/user', '2026-07-13 20:12:07.783678', '2026-07-28 00:16:44.100198', NULL);
INSERT INTO "public"."sys_menu" VALUES (210, 1, '0,1', '用户管理', 'M', 'User', 'user', 'system/user/index', NULL, NULL, NULL, 1, 1, 1, 'el-icon-User', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (220, 1, '0,1', '角色管理', 'M', 'Role', 'role', 'system/role/index', NULL, NULL, NULL, 1, 1, 2, 'role', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (230, 1, '0,1', '菜单管理', 'M', 'SysMenu', 'menu', 'system/menu/index', NULL, NULL, NULL, 1, 1, 3, 'menu', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (240, 1, '0,1', '部门管理', 'M', 'Dept', 'dept', 'system/dept/index', NULL, NULL, NULL, 1, 1, 4, 'tree', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (250, 1, '0,1', '字典管理', 'M', 'Dict', 'dict', 'system/dict/index', NULL, NULL, NULL, 1, 1, 5, 'dict', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (251, 1, '0,1', '字典项', 'M', 'DictItem', 'dict-item', 'system/dict/dict-item', NULL, NULL, 0, 1, 0, 6, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (260, 1, '0,1', '系统日志', 'M', 'Log', 'log', 'system/log/index', NULL, NULL, 0, 1, 1, 7, 'document', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (270, 1, '0,1', '系统配置', 'M', 'Config', 'config', 'system/config/index', NULL, NULL, 0, 1, 1, 8, 'setting', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2101, 210, '0,1,210', '用户查询', 'B', NULL, '', NULL, NULL, 'sys:user:list', NULL, NULL, 1, 1, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2102, 210, '0,1,210', '用户新增', 'B', NULL, '', NULL, NULL, 'sys:user:create', NULL, NULL, 1, 2, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2103, 210, '0,1,210', '用户编辑', 'B', NULL, '', NULL, NULL, 'sys:user:update', NULL, NULL, 1, 3, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2104, 210, '0,1,210', '用户删除', 'B', NULL, '', NULL, NULL, 'sys:user:delete', NULL, NULL, 1, 4, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2105, 210, '0,1,210', '重置密码', 'B', NULL, '', NULL, NULL, 'sys:user:reset-password', NULL, NULL, 1, 5, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2106, 210, '0,1,210', '用户导入', 'B', NULL, '', NULL, NULL, 'sys:user:import', NULL, NULL, 1, 6, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2107, 210, '0,1,210', '用户导出', 'B', NULL, '', NULL, NULL, 'sys:user:export', NULL, NULL, 1, 7, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2201, 220, '0,1,220', '角色查询', 'B', NULL, '', NULL, NULL, 'sys:role:list', NULL, NULL, 1, 1, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2202, 220, '0,1,220', '角色新增', 'B', NULL, '', NULL, NULL, 'sys:role:create', NULL, NULL, 1, 2, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2203, 220, '0,1,220', '角色编辑', 'B', NULL, '', NULL, NULL, 'sys:role:update', NULL, NULL, 1, 3, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2204, 220, '0,1,220', '角色删除', 'B', NULL, '', NULL, NULL, 'sys:role:delete', NULL, NULL, 1, 4, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2205, 220, '0,1,220', '角色分配权限', 'B', NULL, '', NULL, NULL, 'sys:role:assign', NULL, NULL, 1, 5, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2301, 230, '0,1,230', '菜单查询', 'B', NULL, '', NULL, NULL, 'sys:menu:list', NULL, NULL, 1, 1, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2302, 230, '0,1,230', '菜单新增', 'B', NULL, '', NULL, NULL, 'sys:menu:create', NULL, NULL, 1, 2, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2303, 230, '0,1,230', '菜单编辑', 'B', NULL, '', NULL, NULL, 'sys:menu:update', NULL, NULL, 1, 3, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2304, 230, '0,1,230', '菜单删除', 'B', NULL, '', NULL, NULL, 'sys:menu:delete', NULL, NULL, 1, 4, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2401, 240, '0,1,240', '部门查询', 'B', NULL, '', NULL, NULL, 'sys:dept:list', NULL, NULL, 1, 1, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2402, 240, '0,1,240', '部门新增', 'B', NULL, '', NULL, NULL, 'sys:dept:create', NULL, NULL, 1, 2, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2403, 240, '0,1,240', '部门编辑', 'B', NULL, '', NULL, NULL, 'sys:dept:update', NULL, NULL, 1, 3, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2404, 240, '0,1,240', '部门删除', 'B', NULL, '', NULL, NULL, 'sys:dept:delete', NULL, NULL, 1, 4, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2501, 250, '0,1,250', '字典查询', 'B', NULL, '', NULL, NULL, 'sys:dict:list', NULL, NULL, 1, 1, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2502, 250, '0,1,250', '字典新增', 'B', NULL, '', NULL, NULL, 'sys:dict:create', NULL, NULL, 1, 2, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2503, 250, '0,1,250', '字典编辑', 'B', NULL, '', NULL, NULL, 'sys:dict:update', NULL, NULL, 1, 3, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2504, 250, '0,1,250', '字典删除', 'B', NULL, '', NULL, NULL, 'sys:dict:delete', NULL, NULL, 1, 4, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2511, 251, '0,1,251', '字典项查询', 'B', NULL, '', NULL, NULL, 'sys:dict-item:list', NULL, NULL, 1, 1, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2512, 251, '0,1,251', '字典项新增', 'B', NULL, '', NULL, NULL, 'sys:dict-item:create', NULL, NULL, 1, 2, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2513, 251, '0,1,251', '字典项编辑', 'B', NULL, '', NULL, NULL, 'sys:dict-item:update', NULL, NULL, 1, 3, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2514, 251, '0,1,251', '字典项删除', 'B', NULL, '', NULL, NULL, 'sys:dict-item:delete', NULL, NULL, 1, 4, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2601, 260, '0,1,260', '日志查询', 'B', NULL, '', NULL, NULL, 'sys:log:list', NULL, NULL, 1, 1, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2701, 270, '0,1,270', '系统配置查询', 'B', NULL, '', NULL, NULL, 'sys:config:list', 0, 1, 1, 1, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2702, 270, '0,1,270', '系统配置新增', 'B', NULL, '', NULL, NULL, 'sys:config:create', 0, 1, 1, 2, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2703, 270, '0,1,270', '系统配置修改', 'B', NULL, '', NULL, NULL, 'sys:config:update', 0, 1, 1, 3, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2704, 270, '0,1,270', '系统配置删除', 'B', NULL, '', NULL, NULL, 'sys:config:delete', 0, 1, 1, 4, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2705, 270, '0,1,270', '系统配置刷新', 'B', NULL, '', NULL, NULL, 'sys:config:refresh', 0, 1, 1, 5, '', NULL, '2026-07-13 20:12:07.783678', '2026-07-13 20:12:07.783678', NULL);
INSERT INTO "public"."sys_menu" VALUES (2826, 0, '0', '载具管理', 'C', NULL, '/carriermanagementsystem', 'Layout', NULL, NULL, 1, 0, 1, 3, 'qr-code', '/carriermanagementsystem/cart-model', '2026-07-27 23:35:07.817806', '2026-07-28 17:05:51.688283', NULL);
INSERT INTO "public"."sys_menu" VALUES (2837, 2826, '0,2826', '料车物料', 'M', 'CartItem', '/cart-item', 'carriermanagementsystem/cart-item/index.vue', NULL, NULL, 0, 1, 1, 3, 'el-icon-Menu', NULL, '2026-07-28 16:14:17.212941', '2026-07-28 16:21:17.093756', NULL);
INSERT INTO "public"."sys_menu" VALUES (2827, 2826, '0,2826', '料车型号配置', 'M', 'CartModel', '/cart-model', 'carriermanagementsystem/cart-model/index', NULL, NULL, 0, 1, 1, 1, 'el-icon-Menu', NULL, '2026-07-27 23:46:30.553702', '2026-07-27 23:47:32.77372', NULL);
INSERT INTO "public"."sys_menu" VALUES (2838, 2837, '0,2826,2837', '物料查询', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart-item:list', 0, 0, 1, 1, NULL, NULL, '2026-07-28 16:15:51.256418', '2026-07-28 16:15:51.256418', NULL);
INSERT INTO "public"."sys_menu" VALUES (2839, 2837, '0,2826,2837', '物料创建', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart-item:create', 0, 0, 1, 2, NULL, NULL, '2026-07-28 16:19:24.628517', '2026-07-28 16:19:37.658593', NULL);
INSERT INTO "public"."sys_menu" VALUES (2840, 2837, '0,2826,2837', '物料更新', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart-item:update', 0, 0, 1, 3, NULL, NULL, '2026-07-28 16:20:03.15807', '2026-07-28 16:20:03.15807', NULL);
INSERT INTO "public"."sys_menu" VALUES (2841, 2837, '0,2826,2837', '物料删除', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart-item:delete', 0, 0, 1, 4, NULL, NULL, '2026-07-28 16:20:20.32834', '2026-07-28 16:20:20.32834', NULL);
INSERT INTO "public"."sys_menu" VALUES (2828, 2827, '0,2826,2827', '型号查询', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart-model:list', 0, 0, 1, 1, NULL, NULL, '2026-07-28 00:09:42.00401', '2026-07-28 00:09:42.00401', NULL);
INSERT INTO "public"."sys_menu" VALUES (2829, 2827, '0,2826,2827', '型号新增', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart-model:create', 0, 0, 1, 2, NULL, NULL, '2026-07-28 00:10:05.315897', '2026-07-28 00:10:05.315897', NULL);
INSERT INTO "public"."sys_menu" VALUES (2830, 2827, '0,2826,2827', '型号编辑', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart-model:update', 0, 0, 1, 3, NULL, NULL, '2026-07-28 00:10:34.000102', '2026-07-28 00:10:34.000102', NULL);
INSERT INTO "public"."sys_menu" VALUES (2831, 2827, '0,2826,2827', '型号删除', 'B', NULL, NULL, NULL, NULL, 'carriermanagementsystem:cart-model:delete', 0, 0, 1, 4, NULL, NULL, '2026-07-28 00:10:55.276299', '2026-07-28 00:10:55.276299', NULL);
INSERT INTO "public"."sys_menu" VALUES (2807, 0, '0', '仓库管理', 'C', NULL, '/warehouse', 'Layout', NULL, NULL, 1, 0, 1, 2, 'menu', '/warehouse/wms-location', '2026-07-20 14:38:32.697976', '2026-07-28 00:16:23.471839', NULL);
INSERT INTO "public"."sys_menu" VALUES (2818, 2807, '0,2807', '地标/点位', 'M', 'WmsPoint', 'wms-point', 'warehouse/wms-point/index', NULL, NULL, 0, 0, 1, 3, 'el-icon-Menu', NULL, '2026-07-20 23:17:52.860836', '2026-07-21 12:59:51.088471', NULL);
INSERT INTO "public"."sys_menu" VALUES (2813, 2807, '0,2807', '巷道管理', 'M', 'WmsAisle', 'wms-aisle', 'warehouse/wms-aisle', NULL, NULL, 0, 0, 1, 2, 'el-icon-Menu', NULL, '2026-07-20 21:07:22.390184', '2026-07-20 22:54:27.877384', NULL);
INSERT INTO "public"."sys_menu" VALUES (2808, 2807, '0,2807', '库区管理', 'M', 'WmsLocation', 'wms-location', 'warehouse/wms-location/index', NULL, NULL, 0, 1, 1, 1, 'el-icon-Menu', NULL, '2026-07-20 14:41:04.651568', '2026-07-24 15:33:58.381685', NULL);
INSERT INTO "public"."sys_menu" VALUES (2819, 2818, '0,2807,2818', '查询', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-point:list', 0, 0, 1, 1, NULL, NULL, '2026-07-20 23:17:52.870398', '2026-07-21 00:58:24.814313', NULL);
INSERT INTO "public"."sys_menu" VALUES (2820, 2818, '0,2807,2818', '新增', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-point:create', 0, 0, 1, 2, NULL, NULL, '2026-07-20 23:17:52.876763', '2026-07-21 01:01:45.811625', NULL);
INSERT INTO "public"."sys_menu" VALUES (2821, 2818, '0,2807,2818', '修改', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-point:update', 0, 0, 1, 3, NULL, NULL, '2026-07-20 23:17:52.880202', '2026-07-21 01:01:56.08268', NULL);
INSERT INTO "public"."sys_menu" VALUES (2822, 2818, '0,2807,2818', '删除', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-point:delete', 0, 0, 1, 4, NULL, NULL, '2026-07-20 23:17:52.884884', '2026-07-21 01:02:06.615357', NULL);
INSERT INTO "public"."sys_menu" VALUES (2814, 2813, '0,2807,2813', '查询', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-aisle:list', 0, 0, 1, 1, NULL, NULL, '2026-07-20 21:07:22.404302', '2026-07-20 21:41:16.121651', NULL);
INSERT INTO "public"."sys_menu" VALUES (2815, 2813, '0,2807,2813', '新增', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-aisle:create', 0, 0, 1, 2, NULL, NULL, '2026-07-20 21:07:22.408823', '2026-07-20 21:41:26.450421', NULL);
INSERT INTO "public"."sys_menu" VALUES (2816, 2813, '0,2807,2813', '修改', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-aisle:update', 0, 0, 1, 3, NULL, NULL, '2026-07-20 21:07:22.412937', '2026-07-20 21:41:39.234657', NULL);
INSERT INTO "public"."sys_menu" VALUES (2817, 2813, '0,2807,2813', '删除', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-aisle:delete', 0, 0, 1, 4, NULL, NULL, '2026-07-20 21:07:22.424448', '2026-07-20 21:41:48.913867', NULL);
INSERT INTO "public"."sys_menu" VALUES (2810, 2808, '0,2807,2808', '库区新增', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-location:create', 0, 0, 1, 2, NULL, NULL, '2026-07-20 14:42:12.869499', '2026-07-20 14:42:12.869499', NULL);
INSERT INTO "public"."sys_menu" VALUES (2811, 2808, '0,2807,2808', '库区编辑', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-location:update', 0, 0, 1, 3, NULL, NULL, '2026-07-20 14:42:39.093447', '2026-07-20 14:42:39.093447', NULL);
INSERT INTO "public"."sys_menu" VALUES (2812, 2808, '0,2807,2808', '库区删除', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-location:delete', 0, 0, 1, 1, NULL, NULL, '2026-07-20 14:43:00.510511', '2026-07-20 14:43:00.510511', NULL);
INSERT INTO "public"."sys_menu" VALUES (2809, 2808, '0,2807,2808', '库区查询', 'B', NULL, NULL, NULL, NULL, 'warehouse:wms-location:list', 0, 0, 1, 1, NULL, NULL, '2026-07-20 14:41:49.561405', '2026-07-20 14:47:02.987935', NULL);

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_notice";
CREATE TABLE "public"."sys_notice" (
  "id" int8 NOT NULL DEFAULT nextval('sys_notice_id_seq'::regclass),
  "title" varchar(50) COLLATE "pg_catalog"."default",
  "content" text COLLATE "pg_catalog"."default",
  "type" int2 NOT NULL,
  "level" varchar(5) COLLATE "pg_catalog"."default" NOT NULL,
  "target_type" int2 NOT NULL,
  "target_user_ids" varchar(255) COLLATE "pg_catalog"."default",
  "publisher_id" int8,
  "publish_status" int2 DEFAULT 0,
  "publish_time" timestamp(6),
  "revoke_time" timestamp(6),
  "create_by" int8 NOT NULL,
  "create_time" timestamp(6) NOT NULL,
  "update_by" int8,
  "update_time" timestamp(6),
  "is_deleted" int2 DEFAULT 0
)
;
COMMENT ON COLUMN "public"."sys_notice"."id" IS '主键';
COMMENT ON COLUMN "public"."sys_notice"."title" IS '通知标题';
COMMENT ON COLUMN "public"."sys_notice"."content" IS '通知内容';
COMMENT ON COLUMN "public"."sys_notice"."type" IS '通知类型（关联字典编码：notice_type）';
COMMENT ON COLUMN "public"."sys_notice"."level" IS '通知等级（字典code：notice_level）';
COMMENT ON COLUMN "public"."sys_notice"."target_type" IS '目标类型（1: 全体, 2: 指定）';
COMMENT ON COLUMN "public"."sys_notice"."target_user_ids" IS '目标人ID集合（多个使用英文逗号,分割）';
COMMENT ON COLUMN "public"."sys_notice"."publisher_id" IS '发布人ID';
COMMENT ON COLUMN "public"."sys_notice"."publish_status" IS '发布状态（0: 未发布, 1: 已发布, -1: 已撤回）';
COMMENT ON COLUMN "public"."sys_notice"."publish_time" IS '发布时间';
COMMENT ON COLUMN "public"."sys_notice"."revoke_time" IS '撤回时间';
COMMENT ON COLUMN "public"."sys_notice"."create_by" IS '创建人ID';
COMMENT ON COLUMN "public"."sys_notice"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_notice"."update_by" IS '更新人ID';
COMMENT ON COLUMN "public"."sys_notice"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_notice"."is_deleted" IS '是否删除（0: 未删除, 1: 已删除）';
COMMENT ON TABLE "public"."sys_notice" IS '系统通知公告表';

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO "public"."sys_notice" VALUES (6, 'v2.16.1 版本更新', '<p>✨ 版本更新</p><p>v2.16.1 版本已发布，主要修复内容：</p><p>1. 修复 WebSocket 重复连接导致的后台线程阻塞问题</p><p>2. 优化通知公告功能，提升用户体验</p><p>3. 修复部分已知bug</p><p>建议尽快更新到最新版本。</p>', 1, 'M', 1, NULL, 1, -1, '2024-12-05 15:30:00', '2026-07-14 09:57:04.833108', 1, '2024-12-05 15:30:00', 2, '2026-07-14 09:57:08.686076', 1);
INSERT INTO "public"."sys_notice" VALUES (11, 'zhenggai', '<p>sss</p>', 1, 'H', 1, '', 2, -1, '2026-07-14 09:56:23.337697', '2026-07-14 09:56:35.51694', 2, '2026-07-14 09:56:20.728912', 2, '2026-07-14 09:56:38.990843', 1);
INSERT INTO "public"."sys_notice" VALUES (1, 'v3.0.0 版本发布 - 多租户功能上线', '<p>🎉 新版本发布，主要更新内容：</p><p>1. 新增多租户功能，支持租户隔离和数据管理</p><p>2. 优化系统性能，提升响应速度</p><p>3. 完善权限管理，增强安全性</p><p>4. 修复已知问题，提升系统稳定性</p>', 1, 'H', 1, NULL, 1, 1, '2024-12-15 10:00:00', NULL, 1, '2024-12-15 10:00:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (2, '系统维护通知 - 2024年12月20日', '<p>⏰ 系统维护通知</p><p>系统将于 <strong>2024年12月20日（本周五）凌晨 2:00-4:00</strong> 进行例行维护升级。</p><p>维护期间系统将暂停服务，请提前做好数据备份工作。</p><p>给您带来的不便，敬请谅解！</p>', 2, 'H', 1, NULL, 1, 1, '2024-12-18 14:30:00', NULL, 1, '2024-12-18 14:30:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (3, '安全提醒 - 防范钓鱼邮件', '<p>⚠️ 安全提醒</p><p>近期发现有不法分子通过钓鱼邮件进行网络攻击，请大家提高警惕：</p><p>1. 不要点击来源不明的邮件链接</p><p>2. 不要下载可疑附件</p><p>3. 遇到可疑邮件请及时联系IT部门</p><p>4. 定期修改密码，使用强密码策略</p>', 3, 'H', 1, NULL, 1, 1, '2024-12-10 09:00:00', NULL, 1, '2024-12-10 09:00:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (4, '元旦假期安排通知', '<p>📅 元旦假期安排</p><p>根据国家法定节假日安排，公司元旦假期时间为：</p><p><strong>2024年12月30日（周一）至 2025年1月1日（周三）</strong>，共3天。</p><p>2024年12月29日（周日）正常上班。</p><p>祝大家元旦快乐，假期愉快！</p>', 4, 'M', 1, NULL, 1, 1, '2024-12-25 16:00:00', NULL, 1, '2024-12-25 16:00:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (5, '新产品发布会邀请', '<p>🎊 新产品发布会邀请</p><p>公司将于 <strong>2025年1月15日下午14:00</strong> 在总部会议室举办新产品发布会。</p><p>届时将展示最新研发的产品和技术成果，欢迎全体员工参加。</p><p>请各部门提前安排好工作，准时参加。</p>', 5, 'M', 1, NULL, 1, 1, '2024-12-28 11:00:00', NULL, 1, '2024-12-28 11:00:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (7, '年终总结会议通知', '<p>📋 年终总结会议通知</p><p>各部门年终总结会议将于 <strong>2024年12月30日上午9:00</strong> 召开。</p><p>请各部门负责人提前准备好年度工作总结和下年度工作计划。</p><p>会议地点：总部大会议室</p>', 5, 'M', 2, '1,2', 1, 1, '2024-12-22 10:00:00', NULL, 1, '2024-12-22 10:00:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (8, '系统功能优化完成', '<p>✅ 系统功能优化</p><p>已完成以下功能优化：</p><p>1. 优化用户管理界面，提升操作体验</p><p>2. 增强数据导出功能，支持更多格式</p><p>3. 优化搜索功能，提升查询效率</p><p>4. 修复部分界面显示问题</p>', 1, 'L', 1, NULL, 1, 1, '2024-12-12 14:20:00', NULL, 1, '2024-12-12 14:20:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (9, '员工培训计划', '<p>📚 员工培训计划</p><p>为提升员工专业技能，公司将于 <strong>2025年1月8日-10日</strong> 组织技术培训。</p><p>培训内容：</p><p>1. 新技术框架应用</p><p>2. 代码规范与最佳实践</p><p>3. 系统架构设计</p><p>请各部门合理安排工作，确保培训顺利进行。</p>', 5, 'M', 1, NULL, 1, 1, '2024-12-20 09:30:00', NULL, 1, '2024-12-20 09:30:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (10, '数据备份提醒', '<p>💾 数据备份提醒</p><p>请各部门注意定期备份重要数据，建议每周至少备份一次。</p><p>备份方式：</p><p>1. 使用系统自带备份功能</p><p>2. 手动导出重要数据</p><p>3. 联系IT部门协助备份</p><p>数据安全，人人有责！</p>', 3, 'L', 1, NULL, 1, 1, '2024-12-08 08:00:00', NULL, 1, '2024-12-08 08:00:00', 1, '2026-07-14 09:56:54.24373', 1);
INSERT INTO "public"."sys_notice" VALUES (12, '系统更新通知', '<p>对系统进行更新，新增xxx功能</p>', 1, 'L', 1, '', 2, 1, '2026-07-14 09:57:46.921743', NULL, 2, '2026-07-14 09:57:45.270076', NULL, '2026-07-14 09:57:45.270076', 0);

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role";
CREATE TABLE "public"."sys_role" (
  "id" int8 NOT NULL DEFAULT nextval('sys_role_id_seq'::regclass),
  "name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "code" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "sort" int4,
  "status" int2 DEFAULT 1,
  "data_scope" int2,
  "create_by" int8,
  "create_time" timestamp(6),
  "update_by" int8,
  "update_time" timestamp(6),
  "is_deleted" int2 DEFAULT 0
)
;
COMMENT ON COLUMN "public"."sys_role"."id" IS '主键';
COMMENT ON COLUMN "public"."sys_role"."name" IS '角色名称';
COMMENT ON COLUMN "public"."sys_role"."code" IS '角色编码';
COMMENT ON COLUMN "public"."sys_role"."sort" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_role"."status" IS '角色状态(1-正常 0-停用)';
COMMENT ON COLUMN "public"."sys_role"."data_scope" IS '数据权限(1-所有数据 2-部门及子部门数据 3-本部门数据 4-本人数据 5-自定义部门数据)';
COMMENT ON COLUMN "public"."sys_role"."create_by" IS '创建人 ID';
COMMENT ON COLUMN "public"."sys_role"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_role"."update_by" IS '更新人ID';
COMMENT ON COLUMN "public"."sys_role"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_role"."is_deleted" IS '逻辑删除标识(0-未删除 1-已删除)';
COMMENT ON TABLE "public"."sys_role" IS '系统角色表';

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO "public"."sys_role" VALUES (1, '超级管理员', 'ROOT', 1, 1, 1, NULL, '2026-07-13 20:12:07.803229', NULL, '2026-07-13 20:12:07.803229', 0);
INSERT INTO "public"."sys_role" VALUES (2, '系统管理员', 'ADMIN', 2, 1, 1, NULL, '2026-07-13 20:12:07.804588', NULL, NULL, 0);
INSERT INTO "public"."sys_role" VALUES (3, '访问游客', 'GUEST', 3, 1, 3, NULL, '2026-07-13 20:12:07.80533', NULL, '2026-07-13 20:12:07.80533', 0);
INSERT INTO "public"."sys_role" VALUES (4, '部门主管', 'DEPT_MANAGER', 4, 1, 2, NULL, '2026-07-13 20:12:07.805988', NULL, '2026-07-13 20:12:07.805988', 0);
INSERT INTO "public"."sys_role" VALUES (5, '部门成员', 'DEPT_MEMBER', 5, 1, 3, NULL, '2026-07-13 20:12:07.806632', NULL, '2026-07-13 20:12:07.806632', 0);
INSERT INTO "public"."sys_role" VALUES (6, '普通员工', 'EMPLOYEE', 6, 1, 4, NULL, '2026-07-13 20:12:07.807241', NULL, '2026-07-13 20:12:07.807241', 0);
INSERT INTO "public"."sys_role" VALUES (7, '自定义权限用户', 'CUSTOM_USER', 7, 1, 5, NULL, '2026-07-13 20:12:07.807817', NULL, '2026-07-13 20:12:07.807817', 0);
INSERT INTO "public"."sys_role" VALUES (8, 'dage', '1', 1, 1, 1, NULL, '2026-07-14 03:12:09.411139', NULL, '2026-07-14 03:12:13.75962', 1);
INSERT INTO "public"."sys_role" VALUES (10, '开发测试', 'Development Testing', 1, 1, 1, NULL, '2026-07-14 03:42:28.138924', NULL, '2026-07-14 03:43:10.86618', 0);
INSERT INTO "public"."sys_role" VALUES (11, 'sss', 's''s''s', 1, 1, 1, NULL, '2026-07-14 11:53:05.583657', NULL, '2026-07-14 11:53:20.61071', 1);

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role_dept";
CREATE TABLE "public"."sys_role_dept" (
  "role_id" int8 NOT NULL,
  "dept_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_role_dept"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role_dept"."dept_id" IS '部门ID';
COMMENT ON TABLE "public"."sys_role_dept" IS '角色部门关联表';

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO "public"."sys_role_dept" VALUES (7, 1);
INSERT INTO "public"."sys_role_dept" VALUES (7, 2);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role_menu";
CREATE TABLE "public"."sys_role_menu" (
  "role_id" int8 NOT NULL,
  "menu_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_role_menu"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role_menu"."menu_id" IS '菜单ID';
COMMENT ON TABLE "public"."sys_role_menu" IS '角色菜单关联表';

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO "public"."sys_role_menu" VALUES (10, 1);
INSERT INTO "public"."sys_role_menu" VALUES (10, 210);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2101);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2102);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2103);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2104);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2105);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2106);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2107);
INSERT INTO "public"."sys_role_menu" VALUES (10, 220);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2201);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2202);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2203);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2204);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2205);
INSERT INTO "public"."sys_role_menu" VALUES (10, 230);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2301);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2302);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2303);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2304);
INSERT INTO "public"."sys_role_menu" VALUES (10, 240);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2401);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2402);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2403);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2404);
INSERT INTO "public"."sys_role_menu" VALUES (10, 250);
INSERT INTO "public"."sys_role_menu" VALUES (5, 1);
INSERT INTO "public"."sys_role_menu" VALUES (5, 210);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2101);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2102);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2103);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2104);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2105);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2106);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2107);
INSERT INTO "public"."sys_role_menu" VALUES (5, 220);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2201);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2202);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2203);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2204);
INSERT INTO "public"."sys_role_menu" VALUES (5, 2205);
INSERT INTO "public"."sys_role_menu" VALUES (6, 1);
INSERT INTO "public"."sys_role_menu" VALUES (6, 210);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2101);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2102);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2103);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2104);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2105);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2106);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2107);
INSERT INTO "public"."sys_role_menu" VALUES (6, 220);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2201);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2202);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2203);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2204);
INSERT INTO "public"."sys_role_menu" VALUES (6, 2205);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2501);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2502);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2503);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2504);
INSERT INTO "public"."sys_role_menu" VALUES (10, 251);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2511);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2512);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2513);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2514);
INSERT INTO "public"."sys_role_menu" VALUES (10, 260);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2601);
INSERT INTO "public"."sys_role_menu" VALUES (10, 270);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2701);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2702);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2703);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2704);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2705);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2807);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2808);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2809);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2812);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2810);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2811);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2813);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2814);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2815);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2816);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2817);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2818);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2819);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2820);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2821);
INSERT INTO "public"."sys_role_menu" VALUES (10, 2822);
INSERT INTO "public"."sys_role_menu" VALUES (7, 1);
INSERT INTO "public"."sys_role_menu" VALUES (7, 210);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2101);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2102);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2103);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2104);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2105);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2106);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2107);
INSERT INTO "public"."sys_role_menu" VALUES (7, 220);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2201);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2202);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2203);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2204);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2205);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2807);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2808);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2809);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2812);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2810);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2811);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2813);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2814);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2815);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2816);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2817);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2818);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2819);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2820);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2821);
INSERT INTO "public"."sys_role_menu" VALUES (7, 2822);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1);
INSERT INTO "public"."sys_role_menu" VALUES (2, 210);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2101);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2102);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2103);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2104);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2105);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2106);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2107);
INSERT INTO "public"."sys_role_menu" VALUES (2, 220);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2201);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2202);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2203);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2204);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2205);
INSERT INTO "public"."sys_role_menu" VALUES (2, 230);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2301);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2302);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2303);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2304);
INSERT INTO "public"."sys_role_menu" VALUES (2, 240);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2401);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2402);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2403);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2404);
INSERT INTO "public"."sys_role_menu" VALUES (2, 250);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2501);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2502);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2503);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2504);
INSERT INTO "public"."sys_role_menu" VALUES (2, 251);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2511);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2512);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2513);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2514);
INSERT INTO "public"."sys_role_menu" VALUES (2, 260);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2601);
INSERT INTO "public"."sys_role_menu" VALUES (2, 270);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2701);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2702);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2703);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2704);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2705);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2807);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2808);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2812);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2809);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2810);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2811);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2813);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2814);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2815);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2816);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2817);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2818);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2819);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2820);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2821);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2822);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2826);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2827);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2828);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2829);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2830);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2831);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2832);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2833);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2834);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2835);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2836);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2837);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2838);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2839);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2840);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2841);
INSERT INTO "public"."sys_role_menu" VALUES (4, 1);
INSERT INTO "public"."sys_role_menu" VALUES (4, 210);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2101);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2102);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2103);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2104);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2105);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2106);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2107);
INSERT INTO "public"."sys_role_menu" VALUES (4, 220);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2201);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2202);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2203);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2204);
INSERT INTO "public"."sys_role_menu" VALUES (4, 2205);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user";
CREATE TABLE "public"."sys_user" (
  "id" int8 NOT NULL DEFAULT nextval('sys_user_id_seq'::regclass),
  "username" varchar(64) COLLATE "pg_catalog"."default",
  "nickname" varchar(64) COLLATE "pg_catalog"."default",
  "gender" int2 DEFAULT 1,
  "password" varchar(100) COLLATE "pg_catalog"."default",
  "dept_id" int8,
  "avatar" varchar(255) COLLATE "pg_catalog"."default",
  "mobile" varchar(20) COLLATE "pg_catalog"."default",
  "status" int2 DEFAULT 1,
  "email" varchar(128) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6),
  "create_by" int8,
  "update_time" timestamp(6),
  "update_by" int8,
  "is_deleted" int2 DEFAULT 0
)
;
COMMENT ON COLUMN "public"."sys_user"."id" IS '主键';
COMMENT ON COLUMN "public"."sys_user"."username" IS '用户名';
COMMENT ON COLUMN "public"."sys_user"."nickname" IS '昵称';
COMMENT ON COLUMN "public"."sys_user"."gender" IS '性别((1-男 2-女 0-保密)';
COMMENT ON COLUMN "public"."sys_user"."password" IS '密码';
COMMENT ON COLUMN "public"."sys_user"."dept_id" IS '部门ID';
COMMENT ON COLUMN "public"."sys_user"."avatar" IS '用户头像';
COMMENT ON COLUMN "public"."sys_user"."mobile" IS '联系方式';
COMMENT ON COLUMN "public"."sys_user"."status" IS '状态(1-正常 0-禁用)';
COMMENT ON COLUMN "public"."sys_user"."email" IS '用户邮箱';
COMMENT ON COLUMN "public"."sys_user"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_user"."create_by" IS '创建人ID';
COMMENT ON COLUMN "public"."sys_user"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_user"."update_by" IS '修改人ID';
COMMENT ON COLUMN "public"."sys_user"."is_deleted" IS '逻辑删除标识(0-未删除 1-已删除)';
COMMENT ON TABLE "public"."sys_user" IS '系统用户表';

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO "public"."sys_user" VALUES (1, 'root', '有来技术', 0, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', NULL, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345677', 1, 'youlaitech@163.com', '2026-07-13 20:12:07.841318', NULL, '2026-07-13 20:12:07.841318', NULL, 0);
INSERT INTO "public"."sys_user" VALUES (3, 'test', '测试小用户', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 3, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345679', 1, 'youlaitech@163.com', '2026-07-13 20:12:07.84285', NULL, '2026-07-13 20:12:07.84285', NULL, 0);
INSERT INTO "public"."sys_user" VALUES (4, 'dept_manager', '部门主管', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345680', 1, 'manager@youlaitech.com', '2026-07-13 20:12:07.843458', NULL, '2026-07-13 20:12:07.843458', NULL, 0);
INSERT INTO "public"."sys_user" VALUES (5, 'dept_member', '部门成员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345681', 1, 'member@youlaitech.com', '2026-07-13 20:12:07.844017', NULL, '2026-07-13 20:12:07.844017', NULL, 0);
INSERT INTO "public"."sys_user" VALUES (6, 'employee', '普通员工', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 2, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345682', 1, 'employee@youlaitech.com', '2026-07-13 20:12:07.844686', NULL, '2026-07-13 20:12:07.844686', NULL, 0);
INSERT INTO "public"."sys_user" VALUES (8, 'xd', 'xd', 1, '$2a$10$zqW4K2ZyWgk49s.bBzEoVOQ/CVP8iPguAM3CbbmOG2Jq6TsaaFKbW', 1, NULL, '18562365422', 1, 'lhy@lyun.edu.cn', '2026-07-14 03:11:53.843165', 2, '2026-07-14 03:11:58.456441', NULL, 1);
INSERT INTO "public"."sys_user" VALUES (9, 'KF', 'TEST', 0, '$2a$10$SjQ5nQXcgyGQ0JLf4EqiW./vEpllC/Yih18.bbjxdXB69.sUKHWHa', 4, NULL, '19999999999', 1, 'Yadmin@888.com', '2026-07-14 03:44:35.849159', 2, '2026-07-14 03:44:35.849159', NULL, 0);
INSERT INTO "public"."sys_user" VALUES (10, 'redistest', 'test', 0, '$2a$10$axnm6k7GWm71xgZfTFOrf.3HOloVkAR1absQfzEVqSqhGypFBYF1a', 4, NULL, '19777777777', 1, 'admin@qq.com', '2026-07-15 20:12:32.808313', 2, '2026-07-21 12:43:32.619842', 2, 0);
INSERT INTO "public"."sys_user" VALUES (7, 'custom_user', '自定义权限用户', 1, '$2a$10$vrN2SKxfijpFZM1KjBGwkeoLz5latIMaTEcR4a4Q1vhpPXt0bi4n.', 3, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345683', 1, 'custom@youlaitech.com', '2026-07-13 20:12:07.845293', NULL, '2026-07-13 20:12:07.845293', NULL, 0);
INSERT INTO "public"."sys_user" VALUES (2, 'admin', '系统管理员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, '\20260716\f4d990bc0942479783f64576a255414c.jpg', NULL, 1, NULL, '2026-07-13 20:12:07.842184', NULL, '2026-07-24 14:11:47.448754', 2, 0);

-- ----------------------------
-- Table structure for sys_user_notice
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_notice";
CREATE TABLE "public"."sys_user_notice" (
  "id" int8 NOT NULL DEFAULT nextval('sys_user_notice_id_seq'::regclass),
  "notice_id" int8 NOT NULL,
  "user_id" int8 NOT NULL,
  "is_read" int2 DEFAULT 0,
  "read_time" timestamp(6),
  "create_time" timestamp(6) NOT NULL,
  "update_time" timestamp(6),
  "is_deleted" int2 DEFAULT 0
)
;
COMMENT ON COLUMN "public"."sys_user_notice"."id" IS 'id';
COMMENT ON COLUMN "public"."sys_user_notice"."notice_id" IS '公共通知id';
COMMENT ON COLUMN "public"."sys_user_notice"."user_id" IS '用户id';
COMMENT ON COLUMN "public"."sys_user_notice"."is_read" IS '读取状态（0: 未读, 1: 已读）';
COMMENT ON COLUMN "public"."sys_user_notice"."read_time" IS '阅读时间';
COMMENT ON COLUMN "public"."sys_user_notice"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_user_notice"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_user_notice"."is_deleted" IS '逻辑删除(0: 未删除, 1: 已删除)';
COMMENT ON TABLE "public"."sys_user_notice" IS '用户通知公告关联表';

-- ----------------------------
-- Records of sys_user_notice
-- ----------------------------
INSERT INTO "public"."sys_user_notice" VALUES (30, 11, 1, 0, NULL, '2026-07-14 09:56:23.394016', '2026-07-14 09:56:23.394016', 1);
INSERT INTO "public"."sys_user_notice" VALUES (31, 11, 2, 0, NULL, '2026-07-14 09:56:23.395019', '2026-07-14 09:56:23.395019', 1);
INSERT INTO "public"."sys_user_notice" VALUES (32, 11, 3, 0, NULL, '2026-07-14 09:56:23.396017', '2026-07-14 09:56:23.396017', 1);
INSERT INTO "public"."sys_user_notice" VALUES (33, 11, 4, 0, NULL, '2026-07-14 09:56:23.396017', '2026-07-14 09:56:23.396017', 1);
INSERT INTO "public"."sys_user_notice" VALUES (34, 11, 5, 0, NULL, '2026-07-14 09:56:23.396017', '2026-07-14 09:56:23.396017', 1);
INSERT INTO "public"."sys_user_notice" VALUES (35, 11, 6, 0, NULL, '2026-07-14 09:56:23.398018', '2026-07-14 09:56:23.398018', 1);
INSERT INTO "public"."sys_user_notice" VALUES (36, 11, 7, 0, NULL, '2026-07-14 09:56:23.398018', '2026-07-14 09:56:23.398018', 1);
INSERT INTO "public"."sys_user_notice" VALUES (37, 11, 9, 0, NULL, '2026-07-14 09:56:23.399017', '2026-07-14 09:56:23.399017', 1);
INSERT INTO "public"."sys_user_notice" VALUES (1, 1, 2, 1, NULL, '2026-07-13 20:12:07.973507', '2026-07-13 20:12:07.973507', 1);
INSERT INTO "public"."sys_user_notice" VALUES (2, 2, 2, 0, NULL, '2026-07-13 20:12:07.97471', '2026-07-13 20:12:07.97471', 1);
INSERT INTO "public"."sys_user_notice" VALUES (3, 3, 2, 0, NULL, '2026-07-13 20:12:07.975336', '2026-07-13 20:12:07.975336', 1);
INSERT INTO "public"."sys_user_notice" VALUES (4, 4, 2, 1, NULL, '2026-07-13 20:12:07.975955', '2026-07-13 20:12:07.975955', 1);
INSERT INTO "public"."sys_user_notice" VALUES (5, 5, 2, 0, NULL, '2026-07-13 20:12:07.976513', '2026-07-13 20:12:07.976513', 1);
INSERT INTO "public"."sys_user_notice" VALUES (7, 7, 2, 0, NULL, '2026-07-13 20:12:07.977661', '2026-07-13 20:12:07.977661', 1);
INSERT INTO "public"."sys_user_notice" VALUES (8, 8, 2, 1, NULL, '2026-07-13 20:12:07.978258', '2026-07-13 20:12:07.978258', 1);
INSERT INTO "public"."sys_user_notice" VALUES (9, 9, 2, 0, NULL, '2026-07-13 20:12:07.978848', '2026-07-13 20:12:07.978848', 1);
INSERT INTO "public"."sys_user_notice" VALUES (10, 10, 2, 1, NULL, '2026-07-13 20:12:07.979439', '2026-07-13 20:12:07.979439', 1);
INSERT INTO "public"."sys_user_notice" VALUES (11, 1, 1, 0, NULL, '2026-07-13 20:12:07.98004', '2026-07-13 20:12:07.98004', 1);
INSERT INTO "public"."sys_user_notice" VALUES (12, 2, 1, 1, NULL, '2026-07-13 20:12:07.980627', '2026-07-13 20:12:07.980627', 1);
INSERT INTO "public"."sys_user_notice" VALUES (13, 3, 1, 0, NULL, '2026-07-13 20:12:07.98139', '2026-07-13 20:12:07.98139', 1);
INSERT INTO "public"."sys_user_notice" VALUES (14, 4, 1, 1, NULL, '2026-07-13 20:12:07.981982', '2026-07-13 20:12:07.981982', 1);
INSERT INTO "public"."sys_user_notice" VALUES (15, 5, 1, 0, NULL, '2026-07-13 20:12:07.982535', '2026-07-13 20:12:07.982535', 1);
INSERT INTO "public"."sys_user_notice" VALUES (17, 7, 1, 0, NULL, '2026-07-13 20:12:07.983659', '2026-07-13 20:12:07.983659', 1);
INSERT INTO "public"."sys_user_notice" VALUES (18, 8, 1, 1, NULL, '2026-07-13 20:12:07.984247', '2026-07-13 20:12:07.984247', 1);
INSERT INTO "public"."sys_user_notice" VALUES (19, 9, 1, 0, NULL, '2026-07-13 20:12:07.984843', '2026-07-13 20:12:07.984843', 1);
INSERT INTO "public"."sys_user_notice" VALUES (20, 10, 1, 1, NULL, '2026-07-13 20:12:07.985433', '2026-07-13 20:12:07.985433', 1);
INSERT INTO "public"."sys_user_notice" VALUES (21, 1, 3, 0, NULL, '2026-07-13 20:12:07.98602', '2026-07-13 20:12:07.98602', 1);
INSERT INTO "public"."sys_user_notice" VALUES (22, 2, 3, 1, NULL, '2026-07-13 20:12:07.987152', '2026-07-13 20:12:07.987152', 1);
INSERT INTO "public"."sys_user_notice" VALUES (23, 3, 3, 0, NULL, '2026-07-13 20:12:07.987833', '2026-07-13 20:12:07.987833', 1);
INSERT INTO "public"."sys_user_notice" VALUES (24, 4, 3, 1, NULL, '2026-07-13 20:12:07.988584', '2026-07-13 20:12:07.988584', 1);
INSERT INTO "public"."sys_user_notice" VALUES (25, 5, 3, 1, NULL, '2026-07-13 20:12:07.989338', '2026-07-13 20:12:07.989338', 1);
INSERT INTO "public"."sys_user_notice" VALUES (27, 8, 3, 1, NULL, '2026-07-13 20:12:07.990599', '2026-07-13 20:12:07.990599', 1);
INSERT INTO "public"."sys_user_notice" VALUES (28, 9, 3, 1, NULL, '2026-07-13 20:12:07.991173', '2026-07-13 20:12:07.991173', 1);
INSERT INTO "public"."sys_user_notice" VALUES (29, 10, 3, 0, NULL, '2026-07-13 20:12:07.991757', '2026-07-13 20:12:07.991757', 1);
INSERT INTO "public"."sys_user_notice" VALUES (6, 6, 2, 1, NULL, '2026-07-13 20:12:07.977057', '2026-07-13 20:12:07.977057', 1);
INSERT INTO "public"."sys_user_notice" VALUES (16, 6, 1, 1, NULL, '2026-07-13 20:12:07.983071', '2026-07-13 20:12:07.983071', 1);
INSERT INTO "public"."sys_user_notice" VALUES (26, 6, 3, 0, NULL, '2026-07-13 20:12:07.989957', '2026-07-13 20:12:07.989957', 1);
INSERT INTO "public"."sys_user_notice" VALUES (38, 12, 1, 0, NULL, '2026-07-14 09:57:46.928997', '2026-07-14 09:57:46.929009', 0);
INSERT INTO "public"."sys_user_notice" VALUES (40, 12, 3, 0, NULL, '2026-07-14 09:57:46.930528', '2026-07-14 09:57:46.930528', 0);
INSERT INTO "public"."sys_user_notice" VALUES (41, 12, 4, 0, NULL, '2026-07-14 09:57:46.93179', '2026-07-14 09:57:46.93179', 0);
INSERT INTO "public"."sys_user_notice" VALUES (42, 12, 5, 0, NULL, '2026-07-14 09:57:46.931813', '2026-07-14 09:57:46.931813', 0);
INSERT INTO "public"."sys_user_notice" VALUES (43, 12, 6, 0, NULL, '2026-07-14 09:57:46.931813', '2026-07-14 09:57:46.931813', 0);
INSERT INTO "public"."sys_user_notice" VALUES (44, 12, 7, 0, NULL, '2026-07-14 09:57:46.931813', '2026-07-14 09:57:46.931813', 0);
INSERT INTO "public"."sys_user_notice" VALUES (45, 12, 9, 0, NULL, '2026-07-14 09:57:46.931813', '2026-07-14 09:57:46.931813', 0);
INSERT INTO "public"."sys_user_notice" VALUES (39, 12, 2, 1, NULL, '2026-07-14 09:57:46.930528', '2026-07-14 09:57:46.930528', 0);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_role";
CREATE TABLE "public"."sys_user_role" (
  "user_id" int8 NOT NULL,
  "role_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_user_role"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user_role"."role_id" IS '角色ID';
COMMENT ON TABLE "public"."sys_user_role" IS '用户角色关联表';

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO "public"."sys_user_role" VALUES (1, 1);
INSERT INTO "public"."sys_user_role" VALUES (2, 2);
INSERT INTO "public"."sys_user_role" VALUES (3, 3);
INSERT INTO "public"."sys_user_role" VALUES (4, 4);
INSERT INTO "public"."sys_user_role" VALUES (5, 5);
INSERT INTO "public"."sys_user_role" VALUES (6, 6);
INSERT INTO "public"."sys_user_role" VALUES (7, 7);
INSERT INTO "public"."sys_user_role" VALUES (8, 2);
INSERT INTO "public"."sys_user_role" VALUES (9, 10);
INSERT INTO "public"."sys_user_role" VALUES (10, 10);
INSERT INTO "public"."sys_user_role" VALUES (2, 10);

-- ----------------------------
-- Table structure for sys_user_social
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_social";
CREATE TABLE "public"."sys_user_social" (
  "id" int8 NOT NULL DEFAULT nextval('sys_user_social_id_seq'::regclass),
  "user_id" int8 NOT NULL,
  "platform" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "openid" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "unionid" varchar(64) COLLATE "pg_catalog"."default",
  "nickname" varchar(64) COLLATE "pg_catalog"."default",
  "avatar" varchar(255) COLLATE "pg_catalog"."default",
  "session_key" varchar(128) COLLATE "pg_catalog"."default",
  "verified" int2 DEFAULT 1,
  "create_time" timestamp(6),
  "update_time" timestamp(6)
)
;
COMMENT ON COLUMN "public"."sys_user_social"."id" IS '主键ID';
COMMENT ON COLUMN "public"."sys_user_social"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user_social"."platform" IS '平台类型(WECHAT_MINI/WECHAT_MP/ALIPAY/QQ/APPLE)';
COMMENT ON COLUMN "public"."sys_user_social"."openid" IS '平台openid';
COMMENT ON COLUMN "public"."sys_user_social"."unionid" IS '微信unionid';
COMMENT ON COLUMN "public"."sys_user_social"."nickname" IS '第三方昵称';
COMMENT ON COLUMN "public"."sys_user_social"."avatar" IS '第三方头像URL';
COMMENT ON COLUMN "public"."sys_user_social"."session_key" IS '微信session_key';
COMMENT ON COLUMN "public"."sys_user_social"."verified" IS '是否已验证(1-已验证 0-未验证)';
COMMENT ON COLUMN "public"."sys_user_social"."create_time" IS '绑定时间';
COMMENT ON COLUMN "public"."sys_user_social"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."sys_user_social" IS '用户第三方账号绑定表';

-- ----------------------------
-- Records of sys_user_social
-- ----------------------------

-- ----------------------------
-- Table structure for wms_aisle
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_aisle";
CREATE TABLE "public"."wms_aisle" (
  "id" int8 NOT NULL,
  "plant_code" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "location_id" int8 NOT NULL,
  "aisle_code" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "aisle_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "floor" varchar(20) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "sort_order" int4 NOT NULL DEFAULT 0,
  "status" int4 NOT NULL DEFAULT 1,
  "remark" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "created_by" int8,
  "created_time" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" int8,
  "updated_time" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "aisle_purpose" varchar(20) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'MIXED'::character varying,
  "is_handover_point" int4 NOT NULL DEFAULT 0,
  "point_count" int4 NOT NULL DEFAULT 0
)
;
COMMENT ON COLUMN "public"."wms_aisle"."id" IS '主键（雪花算法生成）';
COMMENT ON COLUMN "public"."wms_aisle"."plant_code" IS '厂区编码（冗余字段，便于查询）';
COMMENT ON COLUMN "public"."wms_aisle"."location_id" IS '所属区域ID，关联 wms_location.id';
COMMENT ON COLUMN "public"."wms_aisle"."aisle_code" IS '巷道编码（厂区内唯一，如：A-01, B-02）';
COMMENT ON COLUMN "public"."wms_aisle"."aisle_name" IS '巷道名称（如：A区一号巷道）';
COMMENT ON COLUMN "public"."wms_aisle"."floor" IS '物理楼层（冗余字段，便于按楼层筛选）';
COMMENT ON COLUMN "public"."wms_aisle"."sort_order" IS '排序号，用于路径规划和界面展示';
COMMENT ON COLUMN "public"."wms_aisle"."status" IS '状态：1启用，0停用';
COMMENT ON COLUMN "public"."wms_aisle"."remark" IS '备注说明';
COMMENT ON COLUMN "public"."wms_aisle"."created_by" IS '创建人ID（关联sys_user.id）';
COMMENT ON COLUMN "public"."wms_aisle"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_aisle"."updated_by" IS '更新人ID（关联sys_user.id）';
COMMENT ON COLUMN "public"."wms_aisle"."updated_time" IS '更新时间';
COMMENT ON COLUMN "public"."wms_aisle"."aisle_purpose" IS '巷道用途：FULL-满架优先，EMPTY-空架优先，MIXED-混合（用于周转区优先存放规则）';
COMMENT ON COLUMN "public"."wms_aisle"."is_handover_point" IS '是否交接点巷道：0-否，1-是';
COMMENT ON COLUMN "public"."wms_aisle"."point_count" IS '绑定的点位数量（冗余计数，由业务代码维护，用于列表快速展示）';
COMMENT ON TABLE "public"."wms_aisle" IS '巷道/通道表：区域下一级物理划分，用于AGV路径规划和库存精细化管理';

-- ----------------------------
-- Records of wms_aisle
-- ----------------------------
INSERT INTO "public"."wms_aisle" VALUES (103, '101', 59, '101-002-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 14:57:11.286749', 2, '2026-07-27 14:57:11.287774', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (104, '101', 59, '101-002-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 14:57:40.478122', 2, '2026-07-27 14:57:40.478122', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (105, '101', 60, '101-003-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 14:58:23.314842', 2, '2026-07-27 14:58:23.314842', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (106, '101', 60, '101-003-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 14:58:38.047955', 2, '2026-07-27 14:58:38.047955', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (107, '101', 61, '101-004-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:01:48.475446', 2, '2026-07-27 15:01:48.475446', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (108, '101', 61, '101-004-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:02:05.563488', 2, '2026-07-27 15:02:05.564508', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (109, '101', 77, '101-020-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:02:25.440119', 2, '2026-07-27 15:02:25.440119', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (110, '101', 77, '101-020-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:02:41.669555', 2, '2026-07-27 15:02:41.669555', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (111, '101', 78, '101-021-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:03:09.370119', 2, '2026-07-27 15:03:09.370119', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (112, '101', 78, '101-021-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:03:23.414766', 2, '2026-07-27 15:03:23.414766', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (115, '101', 63, '101-006-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:04:31.497328', 2, '2026-07-27 15:04:31.497328', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (116, '101', 63, '101-006-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:04:48.132514', 2, '2026-07-27 15:04:48.132514', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (117, '101', 64, '101-007-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:05:15.015516', 2, '2026-07-27 15:05:15.01652', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (118, '101', 64, '101-007-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:05:32.344447', 2, '2026-07-27 15:06:04.545041', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (119, '101', 65, '101-008-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:06:34.480101', 2, '2026-07-27 15:06:34.480101', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (120, '101', 65, '101-008-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:06:48.485325', 2, '2026-07-27 15:06:48.486291', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (121, '101', 66, '101-009-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:07:07.937297', 2, '2026-07-27 15:07:07.937297', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (122, '101', 66, '101-009-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:07:22.738789', 2, '2026-07-27 15:07:22.738789', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (123, '101', 67, '101-010-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:07:42.607409', 2, '2026-07-27 15:07:42.607409', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (124, '101', 67, '101-010-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:07:58.568224', 2, '2026-07-27 15:07:58.568224', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (125, '101', 68, '101-011-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:08:12.815854', 2, '2026-07-27 15:08:12.815854', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (126, '101', 68, '101-011-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:08:26.867977', 2, '2026-07-27 15:08:26.867977', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (127, '101', 73, '101-012-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:08:51.53402', 2, '2026-07-27 15:08:51.53402', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (128, '101', 73, '101-012-A002', 'A01', '1F', 2, 1, NULL, 2, '2026-07-27 15:09:05.398561', 2, '2026-07-27 15:09:05.398561', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (129, '101', 74, '101-017-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:09:52.908633', 2, '2026-07-27 15:09:52.908633', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (130, '101', 74, '101-017-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:10:05.936049', 2, '2026-07-27 15:10:05.936049', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (131, '101', 75, '101-018-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:10:20.563362', 2, '2026-07-27 15:10:20.563362', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (132, '101', 75, '101-018-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:10:33.738007', 2, '2026-07-27 15:10:33.738007', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (133, '101', 76, '101-019-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:11:00.94127', 2, '2026-07-27 15:11:00.942279', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (134, '101', 76, '101-019-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:11:14.013612', 2, '2026-07-27 15:11:14.013612', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (101, '101', 58, '101-001-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 14:55:52.166486', 2, '2026-07-27 14:55:52.166486', 'MIXED', 0, 2);
INSERT INTO "public"."wms_aisle" VALUES (102, '101', 58, '101-001-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 14:56:24.705738', 2, '2026-07-27 14:56:24.705738', 'MIXED', 0, 2);
INSERT INTO "public"."wms_aisle" VALUES (113, '101', 62, '101-005-A001', 'A01', '1F', 1, 1, NULL, 2, '2026-07-27 15:03:52.136136', 2, '2026-07-29 16:17:17.895795', 'MIXED', 0, 0);
INSERT INTO "public"."wms_aisle" VALUES (114, '101', 62, '101-005-A002', 'A02', '1F', 2, 1, NULL, 2, '2026-07-27 15:04:13.354323', 2, '2026-07-29 16:17:26.734245', 'MIXED', 0, 0);

-- ----------------------------
-- Table structure for wms_cart
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_cart";
CREATE TABLE "public"."wms_cart" (
  "id" int8 NOT NULL,
  "cart_code" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "model_id" int4 NOT NULL,
  "current_quantity" int4 DEFAULT 0,
  "status" int2 DEFAULT 1,
  "area" varchar(50) COLLATE "pg_catalog"."default",
  "bind_worker" varchar(20) COLLATE "pg_catalog"."default",
  "actual_capacity" int4,
  "created_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "created_by" int8,
  "updated_by" int8
)
;
COMMENT ON COLUMN "public"."wms_cart"."id" IS '主键ID';
COMMENT ON COLUMN "public"."wms_cart"."cart_code" IS '料车编号';
COMMENT ON COLUMN "public"."wms_cart"."model_id" IS '型号ID';
COMMENT ON COLUMN "public"."wms_cart"."current_quantity" IS '当前装载数量';
COMMENT ON COLUMN "public"."wms_cart"."status" IS '状态：1-空闲 2-使用中 3-已满载 4-维修';
COMMENT ON COLUMN "public"."wms_cart"."area" IS '所在区域';
COMMENT ON COLUMN "public"."wms_cart"."bind_worker" IS '绑定操作工';
COMMENT ON COLUMN "public"."wms_cart"."actual_capacity" IS '实际容量（覆盖型号配置）';
COMMENT ON COLUMN "public"."wms_cart"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_cart"."updated_time" IS '更新时间';
COMMENT ON COLUMN "public"."wms_cart"."created_by" IS '创建者';
COMMENT ON COLUMN "public"."wms_cart"."updated_by" IS '更新者';
COMMENT ON TABLE "public"."wms_cart" IS '料车实例表';

-- ----------------------------
-- Records of wms_cart
-- ----------------------------
INSERT INTO "public"."wms_cart" VALUES (3, '003', 3, 0, 1, NULL, NULL, NULL, '2026-07-28 15:05:30.309773', '2026-07-28 15:11:12.871287', 2, 2);
INSERT INTO "public"."wms_cart" VALUES (4, '004', 2, 0, 1, NULL, NULL, NULL, '2026-07-29 16:18:23.255741', '2026-07-29 16:18:23.255741', 2, 2);
INSERT INTO "public"."wms_cart" VALUES (5, '005', 1, 0, 1, NULL, NULL, NULL, '2026-07-29 16:18:35.562972', '2026-07-29 16:18:35.562972', 2, 2);
INSERT INTO "public"."wms_cart" VALUES (6, '006', 3, 0, 1, NULL, NULL, NULL, '2026-07-29 16:18:42.346534', '2026-07-29 16:18:42.346534', 2, 2);
INSERT INTO "public"."wms_cart" VALUES (7, '007', 2, 0, 1, NULL, NULL, NULL, '2026-07-29 17:17:17.469353', '2026-07-29 17:17:17.469353', 2, 2);
INSERT INTO "public"."wms_cart" VALUES (8, '008', 1, 0, 1, NULL, NULL, NULL, '2026-07-29 17:17:24.597871', '2026-07-29 17:17:24.597871', 2, 2);
INSERT INTO "public"."wms_cart" VALUES (9, '009', 3, 0, 1, NULL, NULL, NULL, '2026-07-29 17:17:30.36079', '2026-07-29 17:17:30.36079', 2, 2);
INSERT INTO "public"."wms_cart" VALUES (2, '002', 1, 0, 1, NULL, NULL, NULL, '2026-07-28 15:05:22.365571', '2026-07-29 19:37:45.10298', 2, 2);
INSERT INTO "public"."wms_cart" VALUES (1, '001', 2, 12, 3, NULL, NULL, NULL, '2026-07-28 14:57:08.015065', '2026-08-04 17:41:39.986352', 2, 2);

-- ----------------------------
-- Table structure for wms_cart_item
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_cart_item";
CREATE TABLE "public"."wms_cart_item" (
  "id" int8 NOT NULL,
  "cart_id" int8 NOT NULL,
  "product_code" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "product_model" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "sort_order" int4 NOT NULL,
  "batch_no" varchar(50) COLLATE "pg_catalog"."default",
  "layer_no" int2 DEFAULT 1,
  "operator" varchar(20) COLLATE "pg_catalog"."default",
  "status" int2 DEFAULT 1,
  "loaded_at" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "taken_at" timestamp(6),
  "remark" varchar(255) COLLATE "pg_catalog"."default",
  "created_by" int8,
  "updated_by" int8,
  "created_time" timestamp(6),
  "updated_time" timestamp(6)
)
;
COMMENT ON COLUMN "public"."wms_cart_item"."id" IS '主键ID';
COMMENT ON COLUMN "public"."wms_cart_item"."cart_id" IS '料车ID';
COMMENT ON COLUMN "public"."wms_cart_item"."product_code" IS '货品条码（唯一码）';
COMMENT ON COLUMN "public"."wms_cart_item"."product_model" IS '货品型号';
COMMENT ON COLUMN "public"."wms_cart_item"."sort_order" IS '装货顺序号（从1开始，越大越晚装）';
COMMENT ON COLUMN "public"."wms_cart_item"."batch_no" IS '批次号/工单号';
COMMENT ON COLUMN "public"."wms_cart_item"."layer_no" IS '层号（多层料车使用）';
COMMENT ON COLUMN "public"."wms_cart_item"."operator" IS '装车操作人';
COMMENT ON COLUMN "public"."wms_cart_item"."status" IS '状态：1-在车 2-已取走';
COMMENT ON COLUMN "public"."wms_cart_item"."loaded_at" IS '装车时间';
COMMENT ON COLUMN "public"."wms_cart_item"."taken_at" IS '取走时间';
COMMENT ON COLUMN "public"."wms_cart_item"."remark" IS '备注';
COMMENT ON COLUMN "public"."wms_cart_item"."created_by" IS '创建者';
COMMENT ON COLUMN "public"."wms_cart_item"."updated_by" IS '更新者';
COMMENT ON COLUMN "public"."wms_cart_item"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_cart_item"."updated_time" IS '更新时间';
COMMENT ON TABLE "public"."wms_cart_item" IS '料车装载明细表';

-- ----------------------------
-- Records of wms_cart_item
-- ----------------------------
INSERT INTO "public"."wms_cart_item" VALUES (44, 4, '122607226830', 'GK420069-2', 1, '1', 1, NULL, 1, '2026-07-29 20:13:40.954854', NULL, NULL, 2, 2, '2026-07-29 20:13:40.954854', '2026-07-29 20:13:40.954854');
INSERT INTO "public"."wms_cart_item" VALUES (45, 4, '122607226831', 'GK420069-2', 2, '1', 1, NULL, 1, '2026-07-29 20:13:40.954854', NULL, NULL, 2, 2, '2026-07-29 20:13:40.954854', '2026-07-29 20:13:40.954854');
INSERT INTO "public"."wms_cart_item" VALUES (46, 4, '122607226832', 'GK420069-2', 3, '1', 1, NULL, 1, '2026-07-29 20:13:40.954854', NULL, NULL, 2, 2, '2026-07-29 20:13:40.954854', '2026-07-29 20:13:40.954854');
INSERT INTO "public"."wms_cart_item" VALUES (47, 4, '122607226833', 'GK420069-2', 4, '1', 1, NULL, 1, '2026-07-29 20:13:40.954854', NULL, NULL, 2, 2, '2026-07-29 20:13:40.954854', '2026-07-29 20:13:40.954854');
INSERT INTO "public"."wms_cart_item" VALUES (48, 4, '122607226834', 'GK420069-2', 5, '1', 2, NULL, 1, '2026-07-29 20:13:40.954854', NULL, NULL, 2, 2, '2026-07-29 20:13:40.954854', '2026-07-29 20:13:40.954854');
INSERT INTO "public"."wms_cart_item" VALUES (49, 4, '122607226835', 'GK420069-2', 6, '1', 2, NULL, 1, '2026-07-29 20:13:40.954854', NULL, NULL, 2, 2, '2026-07-29 20:13:40.954854', '2026-07-29 20:13:40.954854');
INSERT INTO "public"."wms_cart_item" VALUES (50, 5, '122607226836', 'GK420069-2', 1, '1', 1, NULL, 1, '2026-07-29 20:14:58.65443', NULL, NULL, 2, 2, '2026-07-29 20:14:58.65443', '2026-07-29 20:14:58.65443');
INSERT INTO "public"."wms_cart_item" VALUES (51, 5, '122607226837', 'GK420069-2', 2, '1', 1, NULL, 1, '2026-07-29 20:14:58.65443', NULL, NULL, 2, 2, '2026-07-29 20:14:58.65443', '2026-07-29 20:14:58.65443');
INSERT INTO "public"."wms_cart_item" VALUES (52, 5, '122607226838', 'GK420069-2', 3, '1', 1, NULL, 1, '2026-07-29 20:14:58.65443', NULL, NULL, 2, 2, '2026-07-29 20:14:58.65443', '2026-07-29 20:14:58.65443');
INSERT INTO "public"."wms_cart_item" VALUES (4, 1, '122607138810', 'GK420069-2', 1, '1', 1, NULL, 1, '2026-07-29 16:38:36.574331', NULL, NULL, 2, 2, '2026-07-29 16:38:36.574331', '2026-07-29 16:38:36.574331');
INSERT INTO "public"."wms_cart_item" VALUES (5, 1, '122607091820', 'GK420069-2', 2, '1', 1, NULL, 1, '2026-07-29 16:39:03.166059', NULL, NULL, 2, 2, '2026-07-29 16:39:03.166059', '2026-07-29 16:39:03.166059');
INSERT INTO "public"."wms_cart_item" VALUES (6, 1, '122607138816', 'GK420069-2', 3, '1', 1, NULL, 1, '2026-07-29 16:53:10.052578', NULL, NULL, 2, 2, '2026-07-29 16:53:10.052578', '2026-07-29 16:53:10.052578');
INSERT INTO "public"."wms_cart_item" VALUES (7, 1, '122607091723', 'GK420069-2', 4, '1', 1, NULL, 1, '2026-07-29 16:54:12.050382', NULL, NULL, 2, 2, '2026-07-29 16:54:12.051891', '2026-07-29 16:54:12.051891');
INSERT INTO "public"."wms_cart_item" VALUES (8, 1, '122607091865', 'GK420069-2', 5, '1', 2, NULL, 1, '2026-07-29 16:54:38.283591', NULL, NULL, 2, 2, '2026-07-29 16:54:38.283591', '2026-07-29 16:54:38.283591');
INSERT INTO "public"."wms_cart_item" VALUES (9, 1, '122607138702', 'GK420069-2', 6, '1', 2, NULL, 1, '2026-07-29 16:57:57.959354', NULL, NULL, 2, 2, '2026-07-29 16:57:57.959354', '2026-07-29 16:57:57.959354');
INSERT INTO "public"."wms_cart_item" VALUES (10, 1, '122607226801', 'GK420069-2', 7, '1', 2, NULL, 1, '2026-07-29 16:59:38.643743', NULL, NULL, 2, 2, '2026-07-29 16:59:38.644258', '2026-07-29 16:59:38.644258');
INSERT INTO "public"."wms_cart_item" VALUES (11, 1, '122607091880', 'GK420069-2', 8, '1', 2, NULL, 1, '2026-07-29 17:03:07.50096', NULL, NULL, 2, 2, '2026-07-29 17:03:07.50096', '2026-07-29 17:03:07.50096');
INSERT INTO "public"."wms_cart_item" VALUES (12, 1, '122607138895', 'GK420069-2', 9, '1', 3, NULL, 1, '2026-07-29 17:15:06.774846', NULL, NULL, 2, 2, '2026-07-29 17:15:06.774846', '2026-07-29 17:15:06.774846');
INSERT INTO "public"."wms_cart_item" VALUES (13, 1, '122607091556', 'GK420069-2', 10, '1', 3, NULL, 1, '2026-07-29 17:15:38.473197', NULL, NULL, 2, 2, '2026-07-29 17:15:38.473197', '2026-07-29 17:15:38.473197');
INSERT INTO "public"."wms_cart_item" VALUES (14, 1, '122607149719', 'GK420069-2', 11, '1', 3, NULL, 1, '2026-07-29 17:16:16.467376', NULL, NULL, 2, 2, '2026-07-29 17:16:16.467376', '2026-07-29 17:16:16.467376');
INSERT INTO "public"."wms_cart_item" VALUES (15, 1, '122607091690', 'GK420069-2', 12, '1', 3, NULL, 1, '2026-07-29 17:16:47.367792', NULL, NULL, 2, 2, '2026-07-29 17:16:47.368796', '2026-07-29 17:16:47.368796');
INSERT INTO "public"."wms_cart_item" VALUES (16, 2, '122607226802', 'GK420069-2', 1, '1', 1, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (17, 2, '122607226803', 'GK420069-2', 2, '1', 1, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (18, 2, '122607226804', 'GK420069-2', 3, '1', 1, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (19, 2, '122607226805', 'GK420069-2', 4, '1', 1, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (20, 2, '122607226806', 'GK420069-2', 5, '1', 2, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (21, 2, '122607226807', 'GK420069-2', 6, '1', 2, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (22, 2, '122607226808', 'GK420069-2', 7, '1', 2, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (23, 2, '122607226809', 'GK420069-2', 8, '1', 2, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (24, 2, '122607226810', 'GK420069-2', 9, '1', 3, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (25, 2, '122607226811', 'GK420069-2', 10, '1', 3, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (26, 2, '122607226812', 'GK420069-2', 11, '1', 3, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (27, 2, '122607226813', 'GK420069-2', 12, '1', 3, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (28, 2, '122607226814', 'GK420069-2', 13, '1', 4, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (29, 2, '122607226815', 'GK420069-2', 14, '1', 4, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (30, 2, '122607226816', 'GK420069-2', 15, '1', 4, NULL, 1, '2026-07-29 19:36:27.74182', NULL, NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (31, 2, '122607226817', 'GK420069-2', 16, '1', 4, NULL, 1, '2026-07-29 19:36:27.74182', '2026-07-29 20:03:43.786815', NULL, 2, 2, '2026-07-29 19:36:27.74182', '2026-07-29 19:36:27.74182');
INSERT INTO "public"."wms_cart_item" VALUES (32, 3, '122607226818', 'GK420069-2', 1, '1', 1, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (33, 3, '122607226819', 'GK420069-2', 2, '1', 1, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (34, 3, '122607226820', 'GK420069-2', 3, '1', 1, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (35, 3, '122607226821', 'GK420069-2', 4, '1', 1, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (36, 3, '122607226822', 'GK420069-2', 5, '1', 2, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (37, 3, '122607226823', 'GK420069-2', 6, '1', 2, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (38, 3, '122607226824', 'GK420069-2', 7, '1', 2, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (39, 3, '122607226825', 'GK420069-2', 8, '1', 2, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (40, 3, '122607226826', 'GK420069-2', 9, '1', 3, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (41, 3, '122607226827', 'GK420069-2', 10, '1', 3, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (42, 3, '122607226828', 'GK420069-2', 11, '1', 3, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (43, 3, '122607226829', 'GK420069-2', 12, '1', 3, NULL, 1, '2026-07-29 20:06:57.480165', NULL, NULL, 2, 2, '2026-07-29 20:06:57.480165', '2026-07-29 20:06:57.480165');
INSERT INTO "public"."wms_cart_item" VALUES (53, 5, '122607226839', 'GK420069-2', 4, '1', 1, NULL, 1, '2026-07-29 20:14:58.65443', NULL, NULL, 2, 2, '2026-07-29 20:14:58.65443', '2026-07-29 20:14:58.65443');
INSERT INTO "public"."wms_cart_item" VALUES (54, 5, '122607226840', 'GK420069-2', 5, '1', 2, NULL, 1, '2026-07-29 20:14:58.65443', NULL, NULL, 2, 2, '2026-07-29 20:14:58.65443', '2026-07-29 20:14:58.65443');
INSERT INTO "public"."wms_cart_item" VALUES (55, 5, '122607226841', 'GK420069-2', 6, '1', 2, NULL, 1, '2026-07-29 20:14:58.65443', NULL, NULL, 2, 2, '2026-07-29 20:14:58.65443', '2026-07-29 20:14:58.65443');
INSERT INTO "public"."wms_cart_item" VALUES (56, 5, '122607226842', 'GK420069-2', 7, '1', 2, NULL, 1, '2026-07-29 20:14:58.65443', NULL, NULL, 2, 2, '2026-07-29 20:14:58.65443', '2026-07-29 20:14:58.65443');
INSERT INTO "public"."wms_cart_item" VALUES (57, 5, '122607226843', 'GK420069-2', 8, '1', 2, NULL, 1, '2026-07-29 20:14:58.65443', NULL, NULL, 2, 2, '2026-07-29 20:14:58.65443', '2026-07-29 20:14:58.65443');
INSERT INTO "public"."wms_cart_item" VALUES (58, 6, '122607226844', 'GK420069-2', 1, '1', 1, NULL, 1, '2026-07-29 20:15:31.393442', NULL, NULL, 2, 2, '2026-07-29 20:15:31.393442', '2026-07-29 20:15:31.393442');
INSERT INTO "public"."wms_cart_item" VALUES (59, 6, '122607226845', 'GK420069-2', 2, '1', 1, NULL, 1, '2026-07-29 20:15:31.393442', NULL, NULL, 2, 2, '2026-07-29 20:15:31.393442', '2026-07-29 20:15:31.393442');
INSERT INTO "public"."wms_cart_item" VALUES (60, 6, '122607226846', 'GK420069-2', 3, '1', 1, NULL, 1, '2026-07-29 20:15:31.393442', NULL, NULL, 2, 2, '2026-07-29 20:15:31.393442', '2026-07-29 20:15:31.393442');
INSERT INTO "public"."wms_cart_item" VALUES (61, 6, '122607226847', 'GK420069-2', 4, '1', 1, NULL, 1, '2026-07-29 20:15:31.393442', NULL, NULL, 2, 2, '2026-07-29 20:15:31.393442', '2026-07-29 20:15:31.393442');
INSERT INTO "public"."wms_cart_item" VALUES (62, 6, '122607226848', 'GK420069-2', 5, '1', 2, NULL, 1, '2026-07-29 20:15:31.393442', NULL, NULL, 2, 2, '2026-07-29 20:15:31.393442', '2026-07-29 20:15:31.393442');
INSERT INTO "public"."wms_cart_item" VALUES (63, 6, '122607226849', 'GK420069-2', 6, '1', 2, NULL, 1, '2026-07-29 20:15:31.393442', NULL, NULL, 2, 2, '2026-07-29 20:15:31.393442', '2026-07-29 20:15:31.393442');

-- ----------------------------
-- Table structure for wms_cart_model
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_cart_model";
CREATE TABLE "public"."wms_cart_model" (
  "id" int8 NOT NULL,
  "model_code" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "model_name" varchar(50) COLLATE "pg_catalog"."default",
  "max_capacity" int4 NOT NULL,
  "layer_count" int2 DEFAULT 1,
  "remark" varchar(255) COLLATE "pg_catalog"."default",
  "created_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_time" timestamp(6),
  "created_by" int8,
  "updated_by" int8
)
;
COMMENT ON COLUMN "public"."wms_cart_model"."id" IS '主键ID';
COMMENT ON COLUMN "public"."wms_cart_model"."model_code" IS '型号代码，如：TC-100';
COMMENT ON COLUMN "public"."wms_cart_model"."model_name" IS '型号名称';
COMMENT ON COLUMN "public"."wms_cart_model"."max_capacity" IS '最大装载数量';
COMMENT ON COLUMN "public"."wms_cart_model"."layer_count" IS '层数';
COMMENT ON COLUMN "public"."wms_cart_model"."remark" IS '备注';
COMMENT ON COLUMN "public"."wms_cart_model"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_cart_model"."updated_time" IS '更新时间';
COMMENT ON COLUMN "public"."wms_cart_model"."created_by" IS '创建者';
COMMENT ON COLUMN "public"."wms_cart_model"."updated_by" IS '更新者';
COMMENT ON TABLE "public"."wms_cart_model" IS '料车型号配置表';

-- ----------------------------
-- Records of wms_cart_model
-- ----------------------------
INSERT INTO "public"."wms_cart_model" VALUES (2, 'TC-03', '3层货架', 12, 3, NULL, '2026-07-28 00:30:46.477494', '2026-07-28 00:30:56.801626', 2, 2);
INSERT INTO "public"."wms_cart_model" VALUES (1, 'TC-04', '4层货架', 16, 4, NULL, '2026-07-28 00:25:05.055739', '2026-07-29 15:28:33.809593', 2, 2);
INSERT INTO "public"."wms_cart_model" VALUES (3, 'LJ-01', '立浇货架', 12, 3, NULL, '2026-07-28 10:50:02.258876', '2026-08-04 17:41:27.142487', 2, 2);

-- ----------------------------
-- Table structure for wms_location
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_location";
CREATE TABLE "public"."wms_location" (
  "id" int8 NOT NULL,
  "plant_code" varchar(32) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'DEFAULT'::character varying,
  "location_code" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "location_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "location_type" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "parent_id" int8 NOT NULL DEFAULT 0,
  "floor" varchar(20) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "sort_order" int4 NOT NULL DEFAULT 0,
  "status" int4 NOT NULL DEFAULT 1,
  "remark" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "created_by" int8,
  "created_time" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" int8,
  "updated_time" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."wms_location"."id" IS '主键';
COMMENT ON COLUMN "public"."wms_location"."plant_code" IS '厂区编码';
COMMENT ON COLUMN "public"."wms_location"."location_code" IS '区域编码（厂区内唯一）';
COMMENT ON COLUMN "public"."wms_location"."location_name" IS '区域名称';
COMMENT ON COLUMN "public"."wms_location"."location_type" IS '区域用途类型（枚举值：湿坯下线/防干/干燥/立浇交接/检修交接/成型立浇交接/木板上线/木板下线/上线点/青坯上线/青坯下线/施釉上线/施釉下线，当前不参与业务逻辑）';
COMMENT ON COLUMN "public"."wms_location"."parent_id" IS '父级区域ID（0表示顶级），用于管理归属/树形结构';
COMMENT ON COLUMN "public"."wms_location"."floor" IS '物理楼层标识（如：1F, 2F, B1），用于快速按楼层筛选和AGV路径规划';
COMMENT ON COLUMN "public"."wms_location"."sort_order" IS '排序号';
COMMENT ON COLUMN "public"."wms_location"."status" IS '状态：1启用，0停用';
COMMENT ON COLUMN "public"."wms_location"."remark" IS '备注';
COMMENT ON COLUMN "public"."wms_location"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."wms_location"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_location"."updated_by" IS '更新人';
COMMENT ON COLUMN "public"."wms_location"."updated_time" IS '更新时间';
COMMENT ON TABLE "public"."wms_location" IS '库位/区域主表：plant_code为厂区主维度（多厂区扩展以厂区隔离），parent_id管归属，floor管物理楼层，location_type为用途类型（预留）';

-- ----------------------------
-- Records of wms_location
-- ----------------------------
INSERT INTO "public"."wms_location" VALUES (73, '101', '101-012', '青坯上线点', '青坯上线', 0, '1F', 12, 1, NULL, 2, '2026-07-27 14:48:19.330067', 2, '2026-07-27 14:48:19.330067');
INSERT INTO "public"."wms_location" VALUES (74, '101', '101-017', '青坯下线点', '青坯下线', 0, '1F', 13, 1, NULL, 2, '2026-07-27 14:51:00.711578', 2, '2026-07-27 14:51:00.711578');
INSERT INTO "public"."wms_location" VALUES (75, '101', '101-018', '施釉上线点', '施釉上线', 0, '1F', 14, 1, NULL, 2, '2026-07-27 14:51:48.131704', 2, '2026-07-27 14:51:48.131704');
INSERT INTO "public"."wms_location" VALUES (76, '101', '101-019', '施釉下线点', '施釉下线', 0, '1F', 15, 1, NULL, 2, '2026-07-27 14:52:38.068231', 2, '2026-07-27 14:52:38.068231');
INSERT INTO "public"."wms_location" VALUES (66, '101', '101-009', '木板上线点', '木板上线', 0, '1F', 9, 1, NULL, 2, '2026-07-27 14:40:51.605356', 2, '2026-07-27 14:47:01.182036');
INSERT INTO "public"."wms_location" VALUES (67, '101', '101-010', '木板下线点', '木板下线', 0, '1F', 10, 1, NULL, 2, '2026-07-27 14:41:18.363026', 2, '2026-07-27 14:47:06.463403');
INSERT INTO "public"."wms_location" VALUES (68, '101', '101-011', '上线点', '上线点', 0, '1F', 11, 1, NULL, 2, '2026-07-27 14:41:44.005762', 2, '2026-07-27 14:47:13.388831');
INSERT INTO "public"."wms_location" VALUES (61, '101', '101-004', '干燥房01', '干燥', 0, '1F', 4, 1, NULL, 2, '2026-07-27 14:36:35.744022', 2, '2026-07-27 14:59:15.725745');
INSERT INTO "public"."wms_location" VALUES (77, '101', '101-020', '干燥房02', '干燥', 0, '1F', 4, 1, NULL, 2, '2026-07-27 15:00:08.497412', 2, '2026-07-27 15:00:08.500401');
INSERT INTO "public"."wms_location" VALUES (78, '101', '101-021', '干燥房03', '干燥', 0, '1F', 4, 1, NULL, 2, '2026-07-27 15:00:36.369279', 2, '2026-07-27 15:00:36.369279');
INSERT INTO "public"."wms_location" VALUES (58, '101', '101-001', '湿坯下线区', '湿坯下线', 0, '1F', 1, 1, NULL, 2, '2026-07-27 14:07:11.691766', 2, '2026-07-27 14:07:32.590216');
INSERT INTO "public"."wms_location" VALUES (60, '101', '101-003', '防干室', '防干', 0, '1F', 3, 1, NULL, 2, '2026-07-27 14:35:29.786899', 2, '2026-07-27 14:35:29.786899');
INSERT INTO "public"."wms_location" VALUES (59, '101', '101-002', '防干区', '防干', 0, '1F', 2, 1, NULL, 2, '2026-07-27 14:34:10.947821', 2, '2026-07-27 14:35:37.617908');
INSERT INTO "public"."wms_location" VALUES (62, '101', '101-005', '周转区', '周转', 0, '1F', 5, 1, NULL, 2, '2026-07-27 14:37:48.545894', 2, '2026-07-27 14:37:48.545894');
INSERT INTO "public"."wms_location" VALUES (63, '101', '101-006', '立浇交接区', '立浇交接', 0, '1F', 5, 1, NULL, 2, '2026-07-27 14:38:27.383653', 2, '2026-07-27 14:38:27.383653');
INSERT INTO "public"."wms_location" VALUES (64, '101', '101-007', '检修/交接区', '检修/交接', 0, '1F', 7, 1, NULL, 2, '2026-07-27 14:39:14.115668', 2, '2026-07-27 14:39:14.115668');
INSERT INTO "public"."wms_location" VALUES (65, '101', '101-008', '成型/立浇交接区', '成型/立浇交接', 0, '1F', 8, 1, NULL, 2, '2026-07-27 14:40:15.662102', 2, '2026-07-27 14:40:15.662102');

-- ----------------------------
-- Table structure for wms_point
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_point";
CREATE TABLE "public"."wms_point" (
  "id" int8 NOT NULL,
  "plant_code" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "location_id" int8 NOT NULL,
  "aisle_id" int8 NOT NULL,
  "floor" varchar(20) COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::character varying,
  "point_code" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "point_name" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "barcode" varchar(64) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "coordinate" varchar(100) COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::character varying,
  "sort_order" int4 NOT NULL DEFAULT 0,
  "status" int4 NOT NULL DEFAULT 1,
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "created_by" int8,
  "created_time" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_by" int8,
  "updated_time" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."wms_point"."id" IS '主键（雪花算法生成）';
COMMENT ON COLUMN "public"."wms_point"."plant_code" IS '厂区编码（冗余，便于厂区隔离查询）';
COMMENT ON COLUMN "public"."wms_point"."location_id" IS '所属区域ID，关联 wms_location.id';
COMMENT ON COLUMN "public"."wms_point"."aisle_id" IS '所属巷道ID，关联 wms_aisle.id';
COMMENT ON COLUMN "public"."wms_point"."floor" IS '物理楼层（冗余，便于按楼层筛选点位）';
COMMENT ON COLUMN "public"."wms_point"."point_code" IS '点位编码（厂区内唯一，如 P-A01-001）';
COMMENT ON COLUMN "public"."wms_point"."point_name" IS '点位名称（如：A区一号巷入口点）';
COMMENT ON COLUMN "public"."wms_point"."barcode" IS '点位条码（PDA/AGV扫码识别用）';
COMMENT ON COLUMN "public"."wms_point"."coordinate" IS '地图坐标（格式由AGV引擎定义，如 "X=100,Y=200,Z=0"）';
COMMENT ON COLUMN "public"."wms_point"."sort_order" IS '巷道内优先级/顺序号（数字越小越优先）。用于：①AGV按此顺序经过各点位（路径导航）；②多可用点位时优先推荐该点位（作业调度）';
COMMENT ON COLUMN "public"."wms_point"."status" IS '状态：1启用，0停用（停用后AGV路径规划将避开该点）';
COMMENT ON COLUMN "public"."wms_point"."remark" IS '备注信息';
COMMENT ON COLUMN "public"."wms_point"."created_by" IS '创建人ID（关联sys_user.id）';
COMMENT ON COLUMN "public"."wms_point"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_point"."updated_by" IS '更新人ID（关联sys_user.id）';
COMMENT ON COLUMN "public"."wms_point"."updated_time" IS '更新时间';
COMMENT ON TABLE "public"."wms_point" IS '地标/点位表：仅作为AGV路径规划和人员导航的坐标点，不承载库存信息';

-- ----------------------------
-- Records of wms_point
-- ----------------------------
INSERT INTO "public"."wms_point" VALUES (372, '101', 58, 101, '1F', '101-001-A001-P002', 'D2', '000000000002', '368337XY063652', 2, 1, NULL, 2, '2026-07-27 15:30:59.951807', 2, '2026-07-27 15:30:59.951807');
INSERT INTO "public"."wms_point" VALUES (371, '101', 58, 101, '1F', '101-001-A001-P001', 'D1', '000000000001', '555967XY091908', 1, 1, NULL, 2, '2026-07-27 15:30:37.729126', 2, '2026-07-29 15:26:53.731317');
INSERT INTO "public"."wms_point" VALUES (373, '101', 58, 102, '1F', '101-001-A002-P001', 'D1', '000000000003', '356342XY735550', 1, 1, NULL, 2, '2026-07-27 15:48:07.151917', 2, '2026-07-29 15:27:13.841918');
INSERT INTO "public"."wms_point" VALUES (374, '101', 58, 102, '1F', '101-001-A002-P002', 'D2', '000000000004', '151588XY319243', 2, 1, NULL, 2, '2026-07-27 15:48:25.919363', 2, '2026-07-27 15:48:25.919363');
INSERT INTO "public"."wms_point" VALUES (375, '101', 59, 103, '1F', '101-002-A001-P001', 'A1', '000000000005', '493024XY283392', 1, 1, NULL, 2, '2026-07-27 15:53:32.94976', 2, '2026-07-27 15:53:32.94976');
INSERT INTO "public"."wms_point" VALUES (376, '101', 59, 103, '1F', '101-002-A001-P002', 'A2', '000000000006', '967737XY753094', 2, 1, NULL, 2, '2026-07-27 15:53:32.94976', 2, '2026-07-27 15:53:32.94976');
INSERT INTO "public"."wms_point" VALUES (377, '101', 59, 104, '1F', '101-002-A002-P001', 'B1', '000000000007', '833657XY600351', 1, 1, NULL, 2, '2026-07-27 15:53:32.957047', 2, '2026-07-27 15:53:32.957047');
INSERT INTO "public"."wms_point" VALUES (378, '101', 59, 104, '1F', '101-002-A002-P002', 'B2', '000000000008', '984603XY012876', 2, 1, NULL, 2, '2026-07-27 15:53:32.957047', 2, '2026-07-27 15:53:32.957047');
INSERT INTO "public"."wms_point" VALUES (379, '101', 60, 105, '1F', '101-003-A001-P001', 'C1', '000000000009', '503873XY315872', 1, 1, NULL, 2, '2026-07-27 15:53:32.958898', 2, '2026-07-27 15:53:32.958898');
INSERT INTO "public"."wms_point" VALUES (380, '101', 60, 105, '1F', '101-003-A001-P002', 'C2', '000000000010', '224059XY512620', 2, 1, NULL, 2, '2026-07-27 15:53:32.958898', 2, '2026-07-27 15:53:32.958898');
INSERT INTO "public"."wms_point" VALUES (381, '101', 60, 106, '1F', '101-003-A002-P001', 'D1', '000000000011', '086441XY651839', 1, 1, NULL, 2, '2026-07-27 15:53:32.960599', 2, '2026-07-27 15:53:32.960599');
INSERT INTO "public"."wms_point" VALUES (382, '101', 60, 106, '1F', '101-003-A002-P002', 'D2', '000000000012', '722502XY711211', 2, 1, NULL, 2, '2026-07-27 15:53:32.960599', 2, '2026-07-27 15:53:32.960599');
INSERT INTO "public"."wms_point" VALUES (383, '101', 61, 107, '1F', '101-004-A001-P001', 'E1', '000000000013', '209275XY117844', 1, 1, NULL, 2, '2026-07-27 15:53:32.961875', 2, '2026-07-27 15:53:32.961875');
INSERT INTO "public"."wms_point" VALUES (384, '101', 61, 107, '1F', '101-004-A001-P002', 'E2', '000000000014', '228418XY747100', 2, 1, NULL, 2, '2026-07-27 15:53:32.961875', 2, '2026-07-27 15:53:32.961875');
INSERT INTO "public"."wms_point" VALUES (385, '101', 61, 108, '1F', '101-004-A002-P001', 'F1', '000000000015', '848788XY077887', 1, 1, NULL, 2, '2026-07-27 15:53:32.96325', 2, '2026-07-27 15:53:32.96325');
INSERT INTO "public"."wms_point" VALUES (386, '101', 61, 108, '1F', '101-004-A002-P002', 'F2', '000000000016', '183173XY582825', 2, 1, NULL, 2, '2026-07-27 15:53:32.96325', 2, '2026-07-27 15:53:32.96325');
INSERT INTO "public"."wms_point" VALUES (387, '101', 77, 109, '1F', '101-020-A001-P001', 'G1', '000000000017', '644525XY404507', 1, 1, NULL, 2, '2026-07-27 15:53:32.971343', 2, '2026-07-27 15:53:32.971343');
INSERT INTO "public"."wms_point" VALUES (388, '101', 77, 109, '1F', '101-020-A001-P002', 'G2', '000000000018', '687487XY501593', 2, 1, NULL, 2, '2026-07-27 15:53:32.971343', 2, '2026-07-27 15:53:32.971343');
INSERT INTO "public"."wms_point" VALUES (389, '101', 77, 110, '1F', '101-020-A002-P001', 'H1', '000000000019', '275202XY755133', 1, 1, NULL, 2, '2026-07-27 15:53:32.974313', 2, '2026-07-27 15:53:32.974313');
INSERT INTO "public"."wms_point" VALUES (390, '101', 77, 110, '1F', '101-020-A002-P002', 'H2', '000000000020', '441052XY477560', 2, 1, NULL, 2, '2026-07-27 15:53:32.974313', 2, '2026-07-27 15:53:32.974313');
INSERT INTO "public"."wms_point" VALUES (391, '101', 78, 111, '1F', '101-021-A001-P001', 'I1', '000000000021', '432281XY918878', 1, 1, NULL, 2, '2026-07-27 15:53:32.977805', 2, '2026-07-27 15:53:32.977805');
INSERT INTO "public"."wms_point" VALUES (392, '101', 78, 111, '1F', '101-021-A001-P002', 'I2', '000000000022', '487510XY649089', 2, 1, NULL, 2, '2026-07-27 15:53:32.977805', 2, '2026-07-27 15:53:32.977805');
INSERT INTO "public"."wms_point" VALUES (393, '101', 78, 112, '1F', '101-021-A002-P001', 'J1', '000000000023', '867137XY473489', 1, 1, NULL, 2, '2026-07-27 15:53:32.98041', 2, '2026-07-27 15:53:32.98041');
INSERT INTO "public"."wms_point" VALUES (394, '101', 78, 112, '1F', '101-021-A002-P002', 'J2', '000000000024', '692166XY554166', 2, 1, NULL, 2, '2026-07-27 15:53:32.98041', 2, '2026-07-27 15:53:32.98041');
INSERT INTO "public"."wms_point" VALUES (395, '101', 62, 113, '1F', '101-005-A001-P001', 'K1', '000000000025', '465993XY080978', 1, 1, NULL, 2, '2026-07-27 15:53:32.983001', 2, '2026-07-27 15:53:32.983001');
INSERT INTO "public"."wms_point" VALUES (396, '101', 62, 113, '1F', '101-005-A001-P002', 'K2', '000000000026', '851759XY731698', 2, 1, NULL, 2, '2026-07-27 15:53:32.983001', 2, '2026-07-27 15:53:32.983001');
INSERT INTO "public"."wms_point" VALUES (397, '101', 62, 114, '1F', '101-005-A002-P001', 'L1', '000000000027', '961987XY840856', 1, 1, NULL, 2, '2026-07-27 15:53:32.985353', 2, '2026-07-27 15:53:32.985353');
INSERT INTO "public"."wms_point" VALUES (398, '101', 62, 114, '1F', '101-005-A002-P002', 'L2', '000000000028', '509038XY143710', 2, 1, NULL, 2, '2026-07-27 15:53:32.985353', 2, '2026-07-27 15:53:32.985353');
INSERT INTO "public"."wms_point" VALUES (399, '101', 63, 115, '1F', '101-006-A001-P001', 'M1', '000000000029', '047140XY767454', 1, 1, NULL, 2, '2026-07-27 15:53:32.987818', 2, '2026-07-27 15:53:32.987818');
INSERT INTO "public"."wms_point" VALUES (400, '101', 63, 115, '1F', '101-006-A001-P002', 'M2', '000000000030', '665240XY841367', 2, 1, NULL, 2, '2026-07-27 15:53:32.987818', 2, '2026-07-27 15:53:32.987818');
INSERT INTO "public"."wms_point" VALUES (401, '101', 63, 116, '1F', '101-006-A002-P001', 'N1', '000000000031', '658645XY381654', 1, 1, NULL, 2, '2026-07-27 15:53:32.990093', 2, '2026-07-27 15:53:32.990093');
INSERT INTO "public"."wms_point" VALUES (402, '101', 63, 116, '1F', '101-006-A002-P002', 'N2', '000000000032', '361917XY222540', 2, 1, NULL, 2, '2026-07-27 15:53:32.990093', 2, '2026-07-27 15:53:32.990093');
INSERT INTO "public"."wms_point" VALUES (403, '101', 64, 117, '1F', '101-007-A001-P001', 'O1', '000000000033', '965456XY256460', 1, 1, NULL, 2, '2026-07-27 15:53:32.992411', 2, '2026-07-27 15:53:32.992411');
INSERT INTO "public"."wms_point" VALUES (404, '101', 64, 117, '1F', '101-007-A001-P002', 'O2', '000000000034', '450620XY776094', 2, 1, NULL, 2, '2026-07-27 15:53:32.992411', 2, '2026-07-27 15:53:32.992411');
INSERT INTO "public"."wms_point" VALUES (405, '101', 64, 118, '1F', '101-007-A002-P001', 'P1', '000000000035', '237866XY379454', 1, 1, NULL, 2, '2026-07-27 15:53:32.997358', 2, '2026-07-27 15:53:32.997358');
INSERT INTO "public"."wms_point" VALUES (406, '101', 64, 118, '1F', '101-007-A002-P002', 'P2', '000000000036', '336529XY790313', 2, 1, NULL, 2, '2026-07-27 15:53:32.997358', 2, '2026-07-27 15:53:32.997358');
INSERT INTO "public"."wms_point" VALUES (407, '101', 65, 119, '1F', '101-008-A001-P001', 'Q1', '000000000037', '098145XY439539', 1, 1, NULL, 2, '2026-07-27 15:53:32.999554', 2, '2026-07-27 15:53:32.999554');
INSERT INTO "public"."wms_point" VALUES (408, '101', 65, 119, '1F', '101-008-A001-P002', 'Q2', '000000000038', '478937XY326766', 2, 1, NULL, 2, '2026-07-27 15:53:32.999554', 2, '2026-07-27 15:53:32.999554');
INSERT INTO "public"."wms_point" VALUES (409, '101', 65, 120, '1F', '101-008-A002-P001', 'R1', '000000000039', '982910XY921760', 1, 1, NULL, 2, '2026-07-27 15:53:33.001817', 2, '2026-07-27 15:53:33.001817');
INSERT INTO "public"."wms_point" VALUES (410, '101', 65, 120, '1F', '101-008-A002-P002', 'R2', '000000000040', '996508XY240090', 2, 1, NULL, 2, '2026-07-27 15:53:33.001817', 2, '2026-07-27 15:53:33.001817');
INSERT INTO "public"."wms_point" VALUES (411, '101', 66, 121, '1F', '101-009-A001-P001', 'S1', '000000000041', '534784XY585162', 1, 1, NULL, 2, '2026-07-27 15:53:33.00334', 2, '2026-07-27 15:53:33.00334');
INSERT INTO "public"."wms_point" VALUES (412, '101', 66, 121, '1F', '101-009-A001-P002', 'S2', '000000000042', '507531XY674468', 2, 1, NULL, 2, '2026-07-27 15:53:33.00334', 2, '2026-07-27 15:53:33.00334');
INSERT INTO "public"."wms_point" VALUES (413, '101', 66, 122, '1F', '101-009-A002-P001', 'T1', '000000000043', '006817XY343274', 1, 1, NULL, 2, '2026-07-27 15:53:33.004415', 2, '2026-07-27 15:53:33.004415');
INSERT INTO "public"."wms_point" VALUES (414, '101', 66, 122, '1F', '101-009-A002-P002', 'T2', '000000000044', '348993XY828206', 2, 1, NULL, 2, '2026-07-27 15:53:33.004415', 2, '2026-07-27 15:53:33.004415');
INSERT INTO "public"."wms_point" VALUES (415, '101', 67, 123, '1F', '101-010-A001-P001', 'U1', '000000000045', '717644XY679346', 1, 1, NULL, 2, '2026-07-27 15:53:33.005477', 2, '2026-07-27 15:53:33.005477');
INSERT INTO "public"."wms_point" VALUES (416, '101', 67, 123, '1F', '101-010-A001-P002', 'U2', '000000000046', '516126XY881792', 2, 1, NULL, 2, '2026-07-27 15:53:33.005477', 2, '2026-07-27 15:53:33.005477');
INSERT INTO "public"."wms_point" VALUES (417, '101', 67, 124, '1F', '101-010-A002-P001', 'V1', '000000000047', '563867XY654809', 1, 1, NULL, 2, '2026-07-27 15:53:33.006442', 2, '2026-07-27 15:53:33.006442');
INSERT INTO "public"."wms_point" VALUES (418, '101', 67, 124, '1F', '101-010-A002-P002', 'V2', '000000000048', '152267XY904730', 2, 1, NULL, 2, '2026-07-27 15:53:33.006442', 2, '2026-07-27 15:53:33.006442');
INSERT INTO "public"."wms_point" VALUES (419, '101', 68, 125, '1F', '101-011-A001-P001', 'W1', '000000000049', '579593XY044548', 1, 1, NULL, 2, '2026-07-27 15:53:33.007557', 2, '2026-07-27 15:53:33.007557');
INSERT INTO "public"."wms_point" VALUES (420, '101', 68, 125, '1F', '101-011-A001-P002', 'W2', '000000000050', '291797XY080164', 2, 1, NULL, 2, '2026-07-27 15:53:33.007557', 2, '2026-07-27 15:53:33.007557');
INSERT INTO "public"."wms_point" VALUES (421, '101', 68, 126, '1F', '101-011-A002-P001', 'X1', '000000000051', '457763XY478625', 1, 1, NULL, 2, '2026-07-27 15:53:33.008754', 2, '2026-07-27 15:53:33.008754');
INSERT INTO "public"."wms_point" VALUES (422, '101', 68, 126, '1F', '101-011-A002-P002', 'X2', '000000000052', '515671XY338076', 2, 1, NULL, 2, '2026-07-27 15:53:33.008754', 2, '2026-07-27 15:53:33.008754');
INSERT INTO "public"."wms_point" VALUES (423, '101', 73, 127, '1F', '101-012-A001-P001', 'Y1', '000000000053', '003439XY938639', 1, 1, NULL, 2, '2026-07-27 15:53:33.009747', 2, '2026-07-27 15:53:33.009747');
INSERT INTO "public"."wms_point" VALUES (424, '101', 73, 127, '1F', '101-012-A001-P002', 'Y2', '000000000054', '569092XY033827', 2, 1, NULL, 2, '2026-07-27 15:53:33.009747', 2, '2026-07-27 15:53:33.009747');
INSERT INTO "public"."wms_point" VALUES (425, '101', 73, 128, '1F', '101-012-A002-P001', 'Z1', '000000000055', '145136XY032965', 1, 1, NULL, 2, '2026-07-27 15:53:33.011434', 2, '2026-07-27 15:53:33.011434');
INSERT INTO "public"."wms_point" VALUES (426, '101', 73, 128, '1F', '101-012-A002-P002', 'Z2', '000000000056', '666370XY663580', 2, 1, NULL, 2, '2026-07-27 15:53:33.011434', 2, '2026-07-27 15:53:33.011434');
INSERT INTO "public"."wms_point" VALUES (427, '101', 74, 129, '1F', '101-017-A001-P001', 'AA1', '000000000057', '435787XY401529', 1, 1, NULL, 2, '2026-07-27 15:53:33.013803', 2, '2026-07-27 15:53:33.013803');
INSERT INTO "public"."wms_point" VALUES (428, '101', 74, 129, '1F', '101-017-A001-P002', 'AA2', '000000000058', '416082XY978973', 2, 1, NULL, 2, '2026-07-27 15:53:33.013803', 2, '2026-07-27 15:53:33.013803');
INSERT INTO "public"."wms_point" VALUES (429, '101', 74, 130, '1F', '101-017-A002-P001', 'AB1', '000000000059', '510600XY283525', 1, 1, NULL, 2, '2026-07-27 15:53:33.014774', 2, '2026-07-27 15:53:33.014774');
INSERT INTO "public"."wms_point" VALUES (430, '101', 74, 130, '1F', '101-017-A002-P002', 'AB2', '000000000060', '149870XY864728', 2, 1, NULL, 2, '2026-07-27 15:53:33.014774', 2, '2026-07-27 15:53:33.014774');
INSERT INTO "public"."wms_point" VALUES (431, '101', 75, 131, '1F', '101-018-A001-P001', 'AC1', '000000000061', '240342XY472321', 1, 1, NULL, 2, '2026-07-27 15:53:33.016841', 2, '2026-07-27 15:53:33.016841');
INSERT INTO "public"."wms_point" VALUES (432, '101', 75, 131, '1F', '101-018-A001-P002', 'AC2', '000000000062', '982471XY692543', 2, 1, NULL, 2, '2026-07-27 15:53:33.016841', 2, '2026-07-27 15:53:33.016841');
INSERT INTO "public"."wms_point" VALUES (433, '101', 75, 132, '1F', '101-018-A002-P001', 'AD1', '000000000063', '572425XY832697', 1, 1, NULL, 2, '2026-07-27 15:53:33.019252', 2, '2026-07-27 15:53:33.019252');
INSERT INTO "public"."wms_point" VALUES (434, '101', 75, 132, '1F', '101-018-A002-P002', 'AD2', '000000000064', '382003XY503235', 2, 1, NULL, 2, '2026-07-27 15:53:33.019252', 2, '2026-07-27 15:53:33.019252');
INSERT INTO "public"."wms_point" VALUES (435, '101', 76, 133, '1F', '101-019-A001-P001', 'AE1', '000000000065', '521210XY253511', 1, 1, NULL, 2, '2026-07-27 15:53:33.020589', 2, '2026-07-27 15:53:33.020589');
INSERT INTO "public"."wms_point" VALUES (436, '101', 76, 133, '1F', '101-019-A001-P002', 'AE2', '000000000066', '831948XY132932', 2, 1, NULL, 2, '2026-07-27 15:53:33.020589', 2, '2026-07-27 15:53:33.020589');
INSERT INTO "public"."wms_point" VALUES (437, '101', 76, 134, '1F', '101-019-A002-P001', 'AF1', '000000000067', '135692XY778688', 1, 1, NULL, 2, '2026-07-27 15:53:33.021577', 2, '2026-07-27 15:53:33.021577');
INSERT INTO "public"."wms_point" VALUES (438, '101', 76, 134, '1F', '101-019-A002-P002', 'AF2', '000000000068', '767845XY711681', 2, 1, NULL, 2, '2026-07-27 15:53:33.021577', 2, '2026-07-27 15:53:33.021577');

-- ----------------------------
-- Table structure for wms_rcs_task
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_rcs_task";
CREATE TABLE "public"."wms_rcs_task" (
  "id" int8 NOT NULL,
  "task_code" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "task_type" int4 NOT NULL,
  "task_title" varchar(128) COLLATE "pg_catalog"."default",
  "from_location" varchar(64) COLLATE "pg_catalog"."default",
  "to_location" varchar(64) COLLATE "pg_catalog"."default",
  "cart_code" varchar(64) COLLATE "pg_catalog"."default",
  "payload" jsonb,
  "status" int4 DEFAULT 0,
  "priority" int4 DEFAULT 2,
  "agv_code" varchar(64) COLLATE "pg_catalog"."default",
  "rcs_task_id" varchar(64) COLLATE "pg_catalog"."default",
  "submit_time" timestamp(6),
  "assigned_at" timestamp(6),
  "start_time" timestamp(6),
  "finish_time" timestamp(6),
  "error_msg" text COLLATE "pg_catalog"."default",
  "remark" varchar(500) COLLATE "pg_catalog"."default",
  "created_by" int8,
  "created_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_by" int8,
  "updated_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."wms_rcs_task"."id" IS '主键ID（自增）';
COMMENT ON COLUMN "public"."wms_rcs_task"."task_code" IS '任务编号（业务主键，全局唯一）';
COMMENT ON COLUMN "public"."wms_rcs_task"."task_type" IS '任务类型：1-搬运 2-充电 3-调度 4-巡检';
COMMENT ON COLUMN "public"."wms_rcs_task"."task_title" IS '任务标题（简要描述）';
COMMENT ON COLUMN "public"."wms_rcs_task"."from_location" IS '起点位置编码（关联 wms_point.point_code）';
COMMENT ON COLUMN "public"."wms_rcs_task"."to_location" IS '终点位置编码（关联 wms_point.point_code）';
COMMENT ON COLUMN "public"."wms_rcs_task"."cart_code" IS '关联料车编码（关联 wms_cart.cart_code）';
COMMENT ON COLUMN "public"."wms_rcs_task"."payload" IS '任务扩展参数（JSON格式，如物料信息、路径约束等）';
COMMENT ON COLUMN "public"."wms_rcs_task"."status" IS '任务状态：0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常';
COMMENT ON COLUMN "public"."wms_rcs_task"."priority" IS '优先级：1-低 2-中 3-高 4-紧急';
COMMENT ON COLUMN "public"."wms_rcs_task"."agv_code" IS '执行该任务的AGV编号';
COMMENT ON COLUMN "public"."wms_rcs_task"."rcs_task_id" IS 'RCS系统返回的外部任务ID';
COMMENT ON COLUMN "public"."wms_rcs_task"."submit_time" IS '任务提交时间';
COMMENT ON COLUMN "public"."wms_rcs_task"."assigned_at" IS '任务派发时间（派发给AGV）';
COMMENT ON COLUMN "public"."wms_rcs_task"."start_time" IS '任务开始执行时间';
COMMENT ON COLUMN "public"."wms_rcs_task"."finish_time" IS '任务完成时间';
COMMENT ON COLUMN "public"."wms_rcs_task"."error_msg" IS '异常信息（状态为异常时记录）';
COMMENT ON COLUMN "public"."wms_rcs_task"."remark" IS '备注';
COMMENT ON COLUMN "public"."wms_rcs_task"."created_by" IS '创建人ID';
COMMENT ON COLUMN "public"."wms_rcs_task"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_rcs_task"."updated_by" IS '更新人ID';
COMMENT ON COLUMN "public"."wms_rcs_task"."updated_time" IS '更新时间';
COMMENT ON TABLE "public"."wms_rcs_task" IS 'RCS任务表（AGV调度任务全生命周期管理）';

-- ----------------------------
-- Records of wms_rcs_task
-- ----------------------------

-- ----------------------------
-- Table structure for wms_rcs_task_lifecycle
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_rcs_task_lifecycle";
CREATE TABLE "public"."wms_rcs_task_lifecycle" (
  "id" int8 NOT NULL,
  "task_id" int8 NOT NULL,
  "status_from" int4,
  "status_to" int4 NOT NULL,
  "operator_type" varchar(20) COLLATE "pg_catalog"."default",
  "operator_id" varchar(64) COLLATE "pg_catalog"."default",
  "remark" text COLLATE "pg_catalog"."default",
  "created_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."id" IS '主键ID（自增）';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."task_id" IS '关联 wms_rcs_task.id';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."status_from" IS '变更前状态';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."status_to" IS '变更后状态';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."operator_type" IS '操作者类型：SYSTEM-系统自动、ADMIN-管理员、AGV-AGV自主、EXTERNAL-外部系统';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."operator_id" IS '操作者标识（如AGV编号或用户ID）';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."remark" IS '变更备注';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."created_time" IS '状态变更时间';
COMMENT ON TABLE "public"."wms_rcs_task_lifecycle" IS '任务状态变更历史表（记录任务状态全生命周期）';

-- ----------------------------
-- Records of wms_rcs_task_lifecycle
-- ----------------------------

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_config_id_seq"
OWNED BY "public"."sys_config"."id";
SELECT setval('"public"."sys_config_id_seq"', 37, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dept_id_seq"
OWNED BY "public"."sys_dept"."id";
SELECT setval('"public"."sys_dept_id_seq"', 7, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dict_id_seq"
OWNED BY "public"."sys_dict"."id";
SELECT setval('"public"."sys_dict_id_seq"', 3, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dict_item_id_seq"
OWNED BY "public"."sys_dict_item"."id";
SELECT setval('"public"."sys_dict_item_id_seq"', 12, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_log_id_seq"
OWNED BY "public"."sys_log"."id";
SELECT setval('"public"."sys_log_id_seq"', 1874, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_menu_id_seq"
OWNED BY "public"."sys_menu"."id";
SELECT setval('"public"."sys_menu_id_seq"', 2841, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_notice_id_seq"
OWNED BY "public"."sys_notice"."id";
SELECT setval('"public"."sys_notice_id_seq"', 12, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_role_id_seq"
OWNED BY "public"."sys_role"."id";
SELECT setval('"public"."sys_role_id_seq"', 11, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_user_id_seq"
OWNED BY "public"."sys_user"."id";
SELECT setval('"public"."sys_user_id_seq"', 10, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_user_notice_id_seq"
OWNED BY "public"."sys_user_notice"."id";
SELECT setval('"public"."sys_user_notice_id_seq"', 45, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_user_social_id_seq"
OWNED BY "public"."sys_user_social"."id";
SELECT setval('"public"."sys_user_social_id_seq"', 1, true);

-- ----------------------------
-- Indexes structure for table api_request_log
-- ----------------------------
CREATE INDEX "idx_api_request_log_module_time" ON "public"."api_request_log" USING btree (
  "module" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "req_time" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_api_request_log_req_time" ON "public"."api_request_log" USING btree (
  "req_time" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_api_request_log_success_time" ON "public"."api_request_log" USING btree (
  "is_success" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "req_time" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_api_request_log_trace_id" ON "public"."api_request_log" USING btree (
  "trace_id" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table api_request_log
-- ----------------------------
ALTER TABLE "public"."api_request_log" ADD CONSTRAINT "api_request_log_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_config
-- ----------------------------
ALTER TABLE "public"."sys_config" ADD CONSTRAINT "sys_config_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table sys_dept
-- ----------------------------
CREATE UNIQUE INDEX "uk_dept_code" ON "public"."sys_dept" USING btree (
  "code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_dept
-- ----------------------------
ALTER TABLE "public"."sys_dept" ADD CONSTRAINT "sys_dept_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table sys_dict
-- ----------------------------
CREATE INDEX "idx_dict_code" ON "public"."sys_dict" USING btree (
  "dict_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_dict
-- ----------------------------
ALTER TABLE "public"."sys_dict" ADD CONSTRAINT "sys_dict_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_dict_item
-- ----------------------------
ALTER TABLE "public"."sys_dict_item" ADD CONSTRAINT "sys_dict_item_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table sys_log
-- ----------------------------
CREATE INDEX "idx_module_action_time" ON "public"."sys_log" USING btree (
  "module" "pg_catalog"."int2_ops" ASC NULLS LAST,
  "action_type" "pg_catalog"."int2_ops" ASC NULLS LAST,
  "create_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_operator_time" ON "public"."sys_log" USING btree (
  "operator_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "create_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_time" ON "public"."sys_log" USING btree (
  "create_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_log
-- ----------------------------
ALTER TABLE "public"."sys_log" ADD CONSTRAINT "sys_log_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_menu
-- ----------------------------
ALTER TABLE "public"."sys_menu" ADD CONSTRAINT "sys_menu_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_notice
-- ----------------------------
ALTER TABLE "public"."sys_notice" ADD CONSTRAINT "sys_notice_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table sys_role
-- ----------------------------
CREATE UNIQUE INDEX "uk_role_code" ON "public"."sys_role" USING btree (
  "code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "uk_role_name" ON "public"."sys_role" USING btree (
  "name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_role
-- ----------------------------
ALTER TABLE "public"."sys_role" ADD CONSTRAINT "sys_role_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table sys_role_dept
-- ----------------------------
CREATE UNIQUE INDEX "uk_roleid_deptid" ON "public"."sys_role_dept" USING btree (
  "role_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "dept_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);

-- ----------------------------
-- Indexes structure for table sys_role_menu
-- ----------------------------
CREATE UNIQUE INDEX "uk_roleid_menuid" ON "public"."sys_role_menu" USING btree (
  "role_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "menu_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);

-- ----------------------------
-- Indexes structure for table sys_user
-- ----------------------------
CREATE UNIQUE INDEX "uk_user_mobile" ON "public"."sys_user" USING btree (
  "mobile" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "uk_user_username" ON "public"."sys_user" USING btree (
  "username" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_user
-- ----------------------------
ALTER TABLE "public"."sys_user" ADD CONSTRAINT "sys_user_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_user_notice
-- ----------------------------
ALTER TABLE "public"."sys_user_notice" ADD CONSTRAINT "sys_user_notice_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_user_role
-- ----------------------------
ALTER TABLE "public"."sys_user_role" ADD CONSTRAINT "sys_user_role_pkey" PRIMARY KEY ("user_id", "role_id");

-- ----------------------------
-- Indexes structure for table sys_user_social
-- ----------------------------
CREATE INDEX "idx_unionid" ON "public"."sys_user_social" USING btree (
  "unionid" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_user_id" ON "public"."sys_user_social" USING btree (
  "user_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "uk_platform_openid" ON "public"."sys_user_social" USING btree (
  "platform" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "openid" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_user_social
-- ----------------------------
ALTER TABLE "public"."sys_user_social" ADD CONSTRAINT "sys_user_social_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table wms_aisle
-- ----------------------------
CREATE INDEX "idx_aisle_floor" ON "public"."wms_aisle" USING btree (
  "floor" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_aisle_location_id" ON "public"."wms_aisle" USING btree (
  "location_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
CREATE INDEX "idx_aisle_plant_code" ON "public"."wms_aisle" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_aisle_status" ON "public"."wms_aisle" USING btree (
  "status" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "uk_aisle_plant_code" ON "public"."wms_aisle" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "aisle_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table wms_aisle
-- ----------------------------
ALTER TABLE "public"."wms_aisle" ADD CONSTRAINT "wms_aisle_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table wms_cart
-- ----------------------------
CREATE INDEX "idx_cart_cart_code" ON "public"."wms_cart" USING btree (
  "cart_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_wms_cart_area" ON "public"."wms_cart" USING btree (
  "area" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_wms_cart_status" ON "public"."wms_cart" USING btree (
  "status" "pg_catalog"."int2_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table wms_cart
-- ----------------------------
ALTER TABLE "public"."wms_cart" ADD CONSTRAINT "wms_cart_cart_code_key" UNIQUE ("cart_code");

-- ----------------------------
-- Primary Key structure for table wms_cart
-- ----------------------------
ALTER TABLE "public"."wms_cart" ADD CONSTRAINT "wms_cart_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table wms_cart_item
-- ----------------------------
CREATE INDEX "idx_cart_item_cart_status" ON "public"."wms_cart_item" USING btree (
  "cart_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "status" "pg_catalog"."int2_ops" ASC NULLS LAST
);
CREATE INDEX "idx_cart_item_product_code" ON "public"."wms_cart_item" USING btree (
  "product_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_item_batch_no" ON "public"."wms_cart_item" USING btree (
  "batch_no" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_item_cart_status_order" ON "public"."wms_cart_item" USING btree (
  "cart_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "status" "pg_catalog"."int2_ops" ASC NULLS LAST,
  "sort_order" "pg_catalog"."int4_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_item_loaded_at" ON "public"."wms_cart_item" USING btree (
  "loaded_at" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table wms_cart_item
-- ----------------------------
ALTER TABLE "public"."wms_cart_item" ADD CONSTRAINT "uk_item_cart_sort" UNIQUE ("cart_id", "sort_order");
ALTER TABLE "public"."wms_cart_item" ADD CONSTRAINT "uk_item_product_code" UNIQUE ("product_code");

-- ----------------------------
-- Primary Key structure for table wms_cart_item
-- ----------------------------
ALTER TABLE "public"."wms_cart_item" ADD CONSTRAINT "wms_cart_item_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table wms_cart_model
-- ----------------------------
ALTER TABLE "public"."wms_cart_model" ADD CONSTRAINT "wms_cart_model_model_code_key" UNIQUE ("model_code");

-- ----------------------------
-- Primary Key structure for table wms_cart_model
-- ----------------------------
ALTER TABLE "public"."wms_cart_model" ADD CONSTRAINT "wms_cart_model_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table wms_location
-- ----------------------------
CREATE INDEX "idx_location_floor" ON "public"."wms_location" USING btree (
  "floor" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_location_parent_id" ON "public"."wms_location" USING btree (
  "parent_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
CREATE INDEX "idx_location_plant_code" ON "public"."wms_location" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "uk_location_plant_code" ON "public"."wms_location" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "location_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table wms_location
-- ----------------------------
ALTER TABLE "public"."wms_location" ADD CONSTRAINT "wms_location_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table wms_point
-- ----------------------------
CREATE INDEX "idx_point_aisle_id" ON "public"."wms_point" USING btree (
  "aisle_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
CREATE INDEX "idx_point_aisle_sort" ON "public"."wms_point" USING btree (
  "aisle_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "sort_order" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_point_floor" ON "public"."wms_point" USING btree (
  "floor" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_point_location_id" ON "public"."wms_point" USING btree (
  "location_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
CREATE INDEX "idx_point_plant_code" ON "public"."wms_point" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_point_status" ON "public"."wms_point" USING btree (
  "status" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "uk_point_plant_code" ON "public"."wms_point" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "point_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "uk_point_barcode" ON "public"."wms_point" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "barcode" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table wms_point
-- ----------------------------
ALTER TABLE "public"."wms_point" ADD CONSTRAINT "wms_point_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table wms_rcs_task
-- ----------------------------
CREATE INDEX "idx_wms_rcs_task_agv_code" ON "public"."wms_rcs_task" USING btree (
  "agv_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_wms_rcs_task_cart_code" ON "public"."wms_rcs_task" USING btree (
  "cart_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_wms_rcs_task_status_time" ON "public"."wms_rcs_task" USING btree (
  "status" "pg_catalog"."int4_ops" ASC NULLS LAST,
  "submit_time" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_wms_rcs_task_submit_time" ON "public"."wms_rcs_task" USING btree (
  "submit_time" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE UNIQUE INDEX "uk_wms_rcs_task_task_code" ON "public"."wms_rcs_task" USING btree (
  "task_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table wms_rcs_task
-- ----------------------------
ALTER TABLE "public"."wms_rcs_task" ADD CONSTRAINT "wms_rcs_task_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table wms_rcs_task_lifecycle
-- ----------------------------
CREATE INDEX "idx_wms_rcs_task_lifecycle_create_time" ON "public"."wms_rcs_task_lifecycle" USING btree (
  "created_time" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_wms_rcs_task_lifecycle_task_id" ON "public"."wms_rcs_task_lifecycle" USING btree (
  "task_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table wms_rcs_task_lifecycle
-- ----------------------------
ALTER TABLE "public"."wms_rcs_task_lifecycle" ADD CONSTRAINT "wms_rcs_task_lifecycle_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Keys structure for table wms_aisle
-- ----------------------------
ALTER TABLE "public"."wms_aisle" ADD CONSTRAINT "fk_aisle_location_id" FOREIGN KEY ("location_id") REFERENCES "public"."wms_location" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table wms_cart
-- ----------------------------
ALTER TABLE "public"."wms_cart" ADD CONSTRAINT "fk_cart_model_id" FOREIGN KEY ("model_id") REFERENCES "public"."wms_cart_model" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table wms_cart_item
-- ----------------------------
ALTER TABLE "public"."wms_cart_item" ADD CONSTRAINT "fk_item_cart_id" FOREIGN KEY ("cart_id") REFERENCES "public"."wms_cart" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table wms_point
-- ----------------------------
ALTER TABLE "public"."wms_point" ADD CONSTRAINT "fk_point_aisle_id" FOREIGN KEY ("aisle_id") REFERENCES "public"."wms_aisle" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION;
ALTER TABLE "public"."wms_point" ADD CONSTRAINT "fk_point_location_id" FOREIGN KEY ("location_id") REFERENCES "public"."wms_location" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table wms_rcs_task_lifecycle
-- ----------------------------
ALTER TABLE "public"."wms_rcs_task_lifecycle" ADD CONSTRAINT "fk_wms_rcs_task_lifecycle_task" FOREIGN KEY ("task_id") REFERENCES "public"."wms_rcs_task" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;
COMMENT ON CONSTRAINT "fk_wms_rcs_task_lifecycle_task" ON "public"."wms_rcs_task_lifecycle" IS '外键：任务状态变更记录关联任务主表，删除任务时级联删除所有状态变更历史';
