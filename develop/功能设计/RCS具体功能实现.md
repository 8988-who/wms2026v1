数据表：
-- ----------------------------
-- Table structure for api_request_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."api_request_log";
CREATE TABLE "public"."api_request_log" (
  "id" int8 NOT NULL DEFAULT nextval('api_request_log_id_seq'::regclass),
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
  "create_by" int8,
  "create_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "update_by" int8,
  "update_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
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
COMMENT ON COLUMN "public"."api_request_log"."create_by" IS '创建人ID';
COMMENT ON COLUMN "public"."api_request_log"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."api_request_log"."update_by" IS '更新人ID';
COMMENT ON COLUMN "public"."api_request_log"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."api_request_log"."remark" IS '备注';
COMMENT ON TABLE "public"."api_request_log" IS '接口请求日志表（记录所有外部系统接口调用，支持链路追踪与性能监控）';

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
-- Table structure for wms_rcs_task
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_rcs_task";
CREATE TABLE "public"."wms_rcs_task" (
  "id" int8 NOT NULL DEFAULT nextval('wms_rcs_task_id_seq'::regclass),
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
  "create_by" int8,
  "create_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP,
  "update_by" int8,
  "update_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP
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
COMMENT ON COLUMN "public"."wms_rcs_task"."create_by" IS '创建人ID';
COMMENT ON COLUMN "public"."wms_rcs_task"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."wms_rcs_task"."update_by" IS '更新人ID';
COMMENT ON COLUMN "public"."wms_rcs_task"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."wms_rcs_task" IS 'RCS任务表（AGV调度任务全生命周期管理）';

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
-- Table structure for wms_rcs_task_lifecycle
-- ----------------------------
DROP TABLE IF EXISTS "public"."wms_rcs_task_lifecycle";
CREATE TABLE "public"."wms_rcs_task_lifecycle" (
  "id" int8 NOT NULL DEFAULT nextval('wms_rcs_task_lifecycle_id_seq'::regclass),
  "task_id" int8 NOT NULL,
  "status_from" int4,
  "status_to" int4 NOT NULL,
  "operator_type" varchar(20) COLLATE "pg_catalog"."default",
  "operator_id" varchar(64) COLLATE "pg_catalog"."default",
  "remark" varchar(255) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6) DEFAULT CURRENT_TIMESTAMP
)
;
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."id" IS '主键ID（自增）';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."task_id" IS '关联 wms_rcs_task.id';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."status_from" IS '变更前状态';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."status_to" IS '变更后状态';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."operator_type" IS '操作者类型：SYSTEM-系统自动、ADMIN-管理员、AGV-AGV自主、EXTERNAL-外部系统';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."operator_id" IS '操作者标识（如AGV编号或用户ID）';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."remark" IS '变更备注';
COMMENT ON COLUMN "public"."wms_rcs_task_lifecycle"."create_time" IS '状态变更时间';
COMMENT ON TABLE "public"."wms_rcs_task_lifecycle" IS '任务状态变更历史表（记录任务状态全生命周期）';

-- ----------------------------
-- Indexes structure for table wms_rcs_task_lifecycle
-- ----------------------------
CREATE INDEX "idx_wms_rcs_task_lifecycle_create_time" ON "public"."wms_rcs_task_lifecycle" USING btree (
  "create_time" "pg_catalog"."timestamp_ops" DESC NULLS FIRST
);
CREATE INDEX "idx_wms_rcs_task_lifecycle_task_id" ON "public"."wms_rcs_task_lifecycle" USING btree (
  "task_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table wms_rcs_task_lifecycle
-- ----------------------------
ALTER TABLE "public"."wms_rcs_task_lifecycle" ADD CONSTRAINT "wms_rcs_task_lifecycle_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Keys structure for table wms_rcs_task_lifecycle
-- ----------------------------
ALTER TABLE "public"."wms_rcs_task_lifecycle" ADD CONSTRAINT "fk_wms_rcs_task_lifecycle_task" FOREIGN KEY ("task_id") REFERENCES "public"."wms_rcs_task" ("id") ON DELETE CASCADE ON UPDATE NO ACTION;
COMMENT ON CONSTRAINT "fk_wms_rcs_task_lifecycle_task" ON "public"."wms_rcs_task_lifecycle" IS '外键：任务状态变更记录关联任务主表，删除任务时级联删除所有状态变更历史';
