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

 Date: 01/09/2026 21:02:46
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
  "http_code" varchar(500) COLLATE "pg_catalog"."default",
  "res_code" varchar(500) COLLATE "pg_catalog"."default",
  "duration" int8,
  "retry_count" int4 DEFAULT 0,
  "trace_id" varchar(64) COLLATE "pg_catalog"."default",
  "created_by" int8,
  "created_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_by" int8,
  "updated_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "remark" varchar(500) COLLATE "pg_catalog"."default",
  "create_name" varchar(50) COLLATE "pg_catalog"."default",
  "update_name" varchar(50) COLLATE "pg_catalog"."default"
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
  "model_code" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
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
COMMENT ON COLUMN "public"."wms_aisle"."model_code" IS '货架型号编码（关联 wms_cart_model.model_code）';
COMMENT ON COLUMN "public"."wms_aisle"."created_by" IS '创建人ID（关联sys_user.id）';
COMMENT ON COLUMN "public"."wms_aisle"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_aisle"."updated_by" IS '更新人ID（关联sys_user.id）';
COMMENT ON COLUMN "public"."wms_aisle"."updated_time" IS '更新时间';
COMMENT ON COLUMN "public"."wms_aisle"."aisle_purpose" IS '巷道用途：FULL-满架优先，EMPTY-空架优先，MIXED-混合（用于周转区优先存放规则）';
COMMENT ON COLUMN "public"."wms_aisle"."is_handover_point" IS '是否交接点巷道：0-否，1-是';
COMMENT ON COLUMN "public"."wms_aisle"."point_count" IS '绑定的点位数量（冗余计数，由业务代码维护，用于列表快速展示）';
COMMENT ON TABLE "public"."wms_aisle" IS '巷道/通道表：区域下一级物理划分，用于AGV路径规划和库存精细化管理';

-- ----------------------------
-- Table structure for wms_cart
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_cart";
CREATE TABLE "public"."wms_cart" (
  "id" int8 NOT NULL,
  "cart_code" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "model_id" int8 NOT NULL,
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
-- Table structure for wms_cart_inventory
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_cart_inventory";
CREATE TABLE "public"."wms_cart_inventory" (
  "id" int8 NOT NULL,
  "point_id" int8 NOT NULL,
  "cart_id" int8,
  "point_code" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "location_id" int8 NOT NULL,
  "aisle_id" int8,
  "arrive_time" timestamp(6),
  "arrive_quantity" int4,
  "last_task_code" varchar(64) COLLATE "pg_catalog"."default",
  "lock_status" int2 DEFAULT 0,
  "remark" varchar(255) COLLATE "pg_catalog"."default",
  "created_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "created_by" int8,
  "updated_by" int8
)
;
COMMENT ON COLUMN "public"."wms_cart_inventory"."id" IS '主键ID（雪花算法）';
COMMENT ON COLUMN "public"."wms_cart_inventory"."point_id" IS '点位ID，关联 wms_point.id（每个点位一条）';
COMMENT ON COLUMN "public"."wms_cart_inventory"."cart_id" IS '当前停靠料车ID，关联 wms_cart.id；NULL 表示该点位空闲';
COMMENT ON COLUMN "public"."wms_cart_inventory"."point_code" IS '点位编码（冗余自 wms_point.point_code，点位属性，搬运不变，免 JOIN 展示）';
COMMENT ON COLUMN "public"."wms_cart_inventory"."location_id" IS '点位所属区域ID（冗余自 wms_point.location_id，点位属性，搬运不变，区域定时扫描用）';
COMMENT ON COLUMN "public"."wms_cart_inventory"."aisle_id" IS '点位所属巷道ID（冗余自 wms_point.aisle_id，点位属性，搬运不变，按巷道筛选/调度用）';
COMMENT ON COLUMN "public"."wms_cart_inventory"."arrive_time" IS '料车进入当前点位的时刻（cart_id 为空时为空）';
COMMENT ON COLUMN "public"."wms_cart_inventory"."arrive_quantity" IS '落位时装载量快照：料车绑定/落到该点位的时刻，实时统计 wms_cart_item(status=1) 的在车货品数写入，之后不随装/取货变化';
COMMENT ON COLUMN "public"."wms_cart_inventory"."last_task_code" IS '最近一次搬运任务编号（溯源用）';
COMMENT ON COLUMN "public"."wms_cart_inventory"."lock_status" IS '库存锁定：0-正常 1-锁定（锁定期不参与任务分配/定时搬运；料车故障时先锁库存再解绑料车维修，解除后重新绑定再解锁）';
COMMENT ON COLUMN "public"."wms_cart_inventory"."remark" IS '备注';
COMMENT ON COLUMN "public"."wms_cart_inventory"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_cart_inventory"."updated_time" IS '更新时间';
COMMENT ON COLUMN "public"."wms_cart_inventory"."created_by" IS '创建者ID';
COMMENT ON COLUMN "public"."wms_cart_inventory"."updated_by" IS '最后更新者ID';
COMMENT ON TABLE "public"."wms_cart_inventory" IS '料车占用表（点位-料车绑定关系）：每个点位一条记录，cart_id 为 NULL 表示该点位空闲';

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
COMMENT ON COLUMN "public"."wms_location"."id" IS '主键（雪花算法生成）';
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
COMMENT ON TABLE "public"."wms_location" IS '库位/区域主表：多厂区隔离，parent_id管归属，floor管物理楼层';

-- ----------------------------
-- Table structure for wms_point
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_point";
CREATE TABLE "public"."wms_point" (
  "id" int8 NOT NULL,
  "plant_code" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "location_id" int8 NOT NULL,
  "aisle_id" int8,
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
-- Table structure for wms_rcs_bind_record
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_rcs_bind_record";
CREATE TABLE "public"."wms_rcs_bind_record" (
  "id" int8 NOT NULL,
  "req_code" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "slot_category" varchar(32) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "slot_code" varchar(100) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "carrier_category" varchar(32) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "carrier_code" varchar(64) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "invoke" varchar(16) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "handle_status" varchar(20) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'PROCESSING'::character varying,
  "handle_msg" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "raw_params" text COLLATE "pg_catalog"."default",
  "created_time" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_time" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."id" IS '主键（雪花算法生成）';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."req_code" IS 'RCS侧请求编号（重复回调沿用同一编号），幂等键';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."slot_category" IS '存储对象类别: SITE(站点)/BIN(仓位)';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."slot_code" IS '存储对象编号（站点口径=wms_point.coordinate 地图坐标）';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."carrier_category" IS '搬运对象类别: POD(货架)/PALLET(托盘)/BOX(料箱)/MAT(物料)';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."carrier_code" IS '载具编号（对应 wms_cart.cart_code）';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."invoke" IS '操作类型: BIND(绑定)/UNBIND(解绑)';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."handle_status" IS '处理状态: PROCESSING处理中/SUCCESS成功/UNMATCHED_POINT点位未匹配/UNMATCHED_CART料车未匹配/FAILED处理异常';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."handle_msg" IS '处理结果说明';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."raw_params" IS '回调报文原文（JSON）';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."created_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_rcs_bind_record"."updated_time" IS '更新时间';
COMMENT ON TABLE "public"."wms_rcs_bind_record" IS 'RCS绑定解绑回调台账：记录RCS推送的每次绑定/解绑通知原文及处理结果';

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
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_config_id_seq"
OWNED BY "public"."sys_config"."id";
SELECT setval('"public"."sys_config_id_seq"', 42, true);

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
SELECT setval('"public"."sys_log_id_seq"', 5360, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_menu_id_seq"
OWNED BY "public"."sys_menu"."id";
SELECT setval('"public"."sys_menu_id_seq"', 2858, true);

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
SELECT setval('"public"."sys_role_id_seq"', 13, true);

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
-- Indexes structure for table wms_cart_inventory
-- ----------------------------
CREATE INDEX "idx_inventory_aisle" ON "public"."wms_cart_inventory" USING btree (
  "aisle_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
COMMENT ON INDEX "public"."idx_inventory_aisle" IS '按巷道筛选在库料车索引';
CREATE INDEX "idx_inventory_aisle_point" ON "public"."wms_cart_inventory" USING btree (
  "aisle_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "point_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_inventory_location" ON "public"."wms_cart_inventory" USING btree (
  "location_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
COMMENT ON INDEX "public"."idx_inventory_location" IS '区域定时搬运按区域筛选索引';
CREATE UNIQUE INDEX "uk_inventory_cart" ON "public"."wms_cart_inventory" USING btree (
  "cart_id" "pg_catalog"."int8_ops" ASC NULLS LAST
) WHERE cart_id IS NOT NULL;
COMMENT ON INDEX "public"."uk_inventory_cart" IS '一车一位：一台料车只能停一个点位（仅约束有车的记录）';
CREATE UNIQUE INDEX "uk_inventory_point" ON "public"."wms_cart_inventory" USING btree (
  "point_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
COMMENT ON INDEX "public"."uk_inventory_point" IS '每个点位一条记录';

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
CREATE UNIQUE INDEX "uk_item_cart_sort" ON "public"."wms_cart_item" USING btree (
  "cart_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "sort_order" "pg_catalog"."int4_ops" ASC NULLS LAST
) WHERE status = 1;

-- ----------------------------
-- Uniques structure for table wms_cart_item
-- ----------------------------
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
CREATE UNIQUE INDEX "uk_point_barcode" ON "public"."wms_point" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "barcode" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "uk_point_plant_code" ON "public"."wms_point" USING btree (
  "plant_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "point_code" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table wms_point
-- ----------------------------
ALTER TABLE "public"."wms_point" ADD CONSTRAINT "wms_point_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table wms_rcs_bind_record
-- ----------------------------
ALTER TABLE "public"."wms_rcs_bind_record" ADD CONSTRAINT "uk_rcs_bind_req" UNIQUE ("req_code");

-- ----------------------------
-- Primary Key structure for table wms_rcs_bind_record
-- ----------------------------
ALTER TABLE "public"."wms_rcs_bind_record" ADD CONSTRAINT "pk_wms_rcs_bind_record" PRIMARY KEY ("id");

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

-- ----------------------------
-- wms_rcs_task 增加巷道/阶段字段（任务编排 P2/P8 同批 DDL）
-- ----------------------------
ALTER TABLE "public"."wms_rcs_task"
    ADD COLUMN "aisle_id" int8;

COMMENT ON COLUMN "public"."wms_rcs_task"."aisle_id"
    IS '所属巷道ID（关联 wms_aisle.id，可空；粗/精确任务创建时写入，按巷道统计在途任务，严格串行 P2）';

ALTER TABLE "public"."wms_rcs_task"
    ADD COLUMN "task_stage" varchar(20);

COMMENT ON COLUMN "public"."wms_rcs_task"."task_stage"
    IS '任务阶段：ROUTING-粗任务（空车到判断点）/ PRECISE-精确任务（搬货架到最后目标点）（P8）';

CREATE INDEX IF NOT EXISTS "idx_rcs_task_aisle_status" ON "public"."wms_rcs_task" USING btree (
  "aisle_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "status" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ============================================================
-- taskscheduling 模块新表（任务模板 / 编排流程 / 调度会话）
-- ============================================================

-- ------------------------------------------------------------
-- Table structure for wms_task_template
-- ------------------------------------------------------------
DROP TABLE IF EXISTS "public"."wms_task_template";
CREATE TABLE "public"."wms_task_template" (
  "id"               int8 NOT NULL,
  "template_code"    varchar(50)  NOT NULL,
  "template_name"    varchar(100),
  "task_type"        varchar(20)  NOT NULL,
  "task_stage"       varchar(20),
  "from_rule"        varchar(20)  NOT NULL,
  "from_point_code"  varchar(50),
  "to_rule"          varchar(20)  NOT NULL,
  "to_point_code"    varchar(50),
  "payload"          jsonb,
  "priority"         int2         DEFAULT 5,
  "next_template_id" int8,
  "status"           int2         DEFAULT 1,
  "plant_code"       varchar(20),
  "remark"           varchar(500),
  "created_by"       int8,
  "created_time"     timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_by"       int8,
  "updated_time"     timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "wms_task_template_pkey" PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."wms_task_template"."template_code" IS '模板编码（业务唯一）';
COMMENT ON COLUMN "public"."wms_task_template"."template_name" IS '模板名称（如"空车到判断点"）';
COMMENT ON COLUMN "public"."wms_task_template"."task_type" IS '任务类型（复用 RcsTaskTypeEnum：TRANSPORT-搬运等）';
COMMENT ON COLUMN "public"."wms_task_template"."task_stage" IS '任务阶段：ROUTING-粗任务（空车到判断点）/ PRECISE-精确任务（搬货架到最后目标点）';
COMMENT ON COLUMN "public"."wms_task_template"."from_rule" IS '起点规则：FIXED-固定点位 / JUDGE_POINT-判断点（巷道内sort_order最大）/ PREV_TO-上一步任务终点';
COMMENT ON COLUMN "public"."wms_task_template"."from_point_code" IS '起点点位（from_rule=FIXED 时填写）';
COMMENT ON COLUMN "public"."wms_task_template"."to_rule" IS '终点规则：FIXED-固定点位 / TARGET_POINT-会话目标点（计划开始时确定）/ JUDGE_POINT-判断点';
COMMENT ON COLUMN "public"."wms_task_template"."to_point_code" IS '终点点位（to_rule=FIXED 时填写）';
COMMENT ON COLUMN "public"."wms_task_template"."payload" IS '载荷（RCS 任务透传 JSON，可空）';
COMMENT ON COLUMN "public"."wms_task_template"."priority" IS '优先级 1-9（复用 RcsTaskPriorityEnum，默认 5）';
COMMENT ON COLUMN "public"."wms_task_template"."next_template_id" IS '下一步模板ID（链式衔接：上一步任务FINISHED回调后执行）';
COMMENT ON COLUMN "public"."wms_task_template"."status" IS '状态：1-启用 0-停用';
COMMENT ON COLUMN "public"."wms_task_template"."plant_code" IS '厂区编码（数据权限隔离）';
COMMENT ON COLUMN "public"."wms_task_template"."remark" IS '备注';
COMMENT ON TABLE "public"."wms_task_template" IS '任务模板表（固化 RCS 任务参数，供编排流程步骤引用）';

-- ----------------------------
-- Indexes structure for table wms_task_template
-- ----------------------------
CREATE UNIQUE INDEX "uk_task_template_plant_code" ON "public"."wms_task_template" USING btree (
  "plant_code" "pg_catalog"."text_ops" ASC NULLS LAST,
  "template_code" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ------------------------------------------------------------
-- Table structure for wms_dispatch_process
-- ------------------------------------------------------------
DROP TABLE IF EXISTS "public"."wms_dispatch_process";
CREATE TABLE "public"."wms_dispatch_process" (
  "id"               int8 NOT NULL,
  "process_code"     varchar(50)  NOT NULL,
  "process_name"     varchar(100),
  "step_no"          int4          NOT NULL,
  "filter_condition" jsonb         NOT NULL,
  "template_id"      int8          NOT NULL,
  "next_step_no"     int4,
  "status"           int2          DEFAULT 1,
  "plant_code"       varchar(20),
  "remark"           varchar(500),
  "created_by"       int8,
  "created_time"     timestamp(6)  DEFAULT CURRENT_TIMESTAMP,
  "updated_by"       int8,
  "updated_time"     timestamp(6)  DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "wms_dispatch_process_pkey" PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."wms_dispatch_process"."process_code" IS '流程编码（业务唯一，如 PROC_AISLE_MOVE）';
COMMENT ON COLUMN "public"."wms_dispatch_process"."process_name" IS '流程名称（如"巷道清空搬运"）';
COMMENT ON COLUMN "public"."wms_dispatch_process"."step_no" IS '步骤序号（1,2,3...），同流程内唯一';
COMMENT ON COLUMN "public"."wms_dispatch_process"."filter_condition" IS '本步筛选条件 JSON（与4.2 SQL 维度一致：location_id/load_type/aisle_purpose/model_code/point_type 等）';
COMMENT ON COLUMN "public"."wms_dispatch_process"."template_id" IS '本步执行的任务模板ID（关联 wms_task_template.id）';
COMMENT ON COLUMN "public"."wms_dispatch_process"."next_step_no" IS '下一步步骤序号（空=流程终点，触发方式：上一步 RCS 任务 FINISHED 回调）';
COMMENT ON COLUMN "public"."wms_dispatch_process"."status" IS '状态：1-启用 0-停用';
COMMENT ON COLUMN "public"."wms_dispatch_process"."plant_code" IS '厂区编码';
COMMENT ON COLUMN "public"."wms_dispatch_process"."remark" IS '备注';
COMMENT ON TABLE "public"."wms_dispatch_process" IS '编排流程定义表（步骤链：筛选条件+任务模板，信号驱动逐步骤执行）';

-- ----------------------------
-- Indexes structure for table wms_dispatch_process
-- ----------------------------
CREATE INDEX "idx_process_plant_status" ON "public"."wms_dispatch_process" USING btree (
  "plant_code" "pg_catalog"."text_ops" ASC NULLS LAST,
  "status" "pg_catalog"."int2_ops" ASC NULLS LAST
);

-- ------------------------------------------------------------
-- Table structure for wms_dispatch_session
-- ------------------------------------------------------------
DROP TABLE IF EXISTS "public"."wms_dispatch_session";
CREATE TABLE "public"."wms_dispatch_session" (
  "id"                int8 NOT NULL,
  "session_code"      varchar(50)  NOT NULL,
  "process_id"        int8,
  "current_step_no"   int4,
  "location_id"       int8          NOT NULL,
  "load_type"         varchar(10)  NOT NULL,
  "aisle_purpose"     varchar(20),
  "model_code"        varchar(20),
  "point_type"        varchar(10)  DEFAULT 'AISLE',
  "target_point_code" varchar(50),
  "running"           int2         DEFAULT 0,
  "created_by"        int8,
  "created_time"      timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "updated_time"      timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "wms_dispatch_session_pkey" PRIMARY KEY ("id")
);
COMMENT ON COLUMN "public"."wms_dispatch_session"."session_code" IS '会话编码（如 SESS_20260902_0001）';
COMMENT ON COLUMN "public"."wms_dispatch_session"."process_id" IS '关联编排流程ID（多步编排；单段搬运可不填）';
COMMENT ON COLUMN "public"."wms_dispatch_session"."current_step_no" IS '当前步骤序号（对应 wms_dispatch_process.step_no，信号驱动推进）';
COMMENT ON COLUMN "public"."wms_dispatch_session"."location_id" IS '区域（筛选条件）';
COMMENT ON COLUMN "public"."wms_dispatch_session"."load_type" IS 'FULL-满车 / EMPTY-空车';
COMMENT ON COLUMN "public"."wms_dispatch_session"."aisle_purpose" IS '巷道用途（筛选维度）';
COMMENT ON COLUMN "public"."wms_dispatch_session"."model_code" IS '料车型号（筛选维度）';
COMMENT ON COLUMN "public"."wms_dispatch_session"."point_type" IS '点位归属：AISLE-巷道（本期）/ DISCRETE-离散（V2预留）';
COMMENT ON COLUMN "public"."wms_dispatch_session"."target_point_code" IS '最后目标点（计划开始时确定并持久化，第二阶段精确任务才下发 RCS）';
COMMENT ON COLUMN "public"."wms_dispatch_session"."running" IS '调度开关：0-停止 1-运行（前端启动/停止写此字段）';
COMMENT ON TABLE "public"."wms_dispatch_session" IS '调度会话表（运行态：持久化筛选条件，调度器定时循环读）';

-- ----------------------------
-- Indexes structure for table wms_dispatch_session
-- ----------------------------
CREATE INDEX "idx_session_running" ON "public"."wms_dispatch_session" USING btree (
  "running" "pg_catalog"."int2_ops" ASC NULLS LAST
);
