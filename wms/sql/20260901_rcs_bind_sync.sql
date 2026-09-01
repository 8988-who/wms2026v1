-- =============================================================
-- 变更：RCS 绑定/解绑回调（/bind）同步落地
-- 日期：2026-09-01
-- 说明：
--   RCS 侧开启 BIND 业务通知后，绑定/解绑事实发生即推送本表记录，
--   WMS 按 req_code 幂等处理并同步 wms_cart_inventory 绑定状态。
--   req_code 唯一索引为幂等闸门：重复推送直接拒绝插入，按已处理状态回应。
-- =============================================================

CREATE TABLE "wms_rcs_bind_record" (
  "id"               int8 NOT NULL,
  "req_code"         varchar(64)  NOT NULL,
  "slot_category"    varchar(32)  DEFAULT NULL,
  "slot_code"        varchar(100) DEFAULT NULL,
  "carrier_category" varchar(32)  DEFAULT NULL,
  "carrier_code"     varchar(64)  DEFAULT NULL,
  "invoke"           varchar(16)  DEFAULT NULL,
  "handle_status"    varchar(20)  NOT NULL DEFAULT 'PROCESSING',
  "handle_msg"       varchar(500) DEFAULT NULL,
  "raw_params"       text         DEFAULT NULL,
  "created_time"     timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_time"     timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "pk_wms_rcs_bind_record" PRIMARY KEY ("id"),
  CONSTRAINT "uk_rcs_bind_req" UNIQUE ("req_code")
)
;

COMMENT ON TABLE  "wms_rcs_bind_record" IS 'RCS绑定解绑回调台账：记录RCS推送的每次绑定/解绑通知原文及处理结果';
COMMENT ON COLUMN "wms_rcs_bind_record"."id"               IS '主键（雪花算法生成）';
COMMENT ON COLUMN "wms_rcs_bind_record"."req_code"         IS 'RCS侧请求编号（重复回调沿用同一编号），幂等键';
COMMENT ON COLUMN "wms_rcs_bind_record"."slot_category"    IS '存储对象类别: SITE(站点)/BIN(仓位)';
COMMENT ON COLUMN "wms_rcs_bind_record"."slot_code"        IS '存储对象编号（站点口径=wms_point.coordinate 地图坐标）';
COMMENT ON COLUMN "wms_rcs_bind_record"."carrier_category" IS '搬运对象类别: POD(货架)/PALLET(托盘)/BOX(料箱)/MAT(物料)';
COMMENT ON COLUMN "wms_rcs_bind_record"."carrier_code"     IS '载具编号（对应 wms_cart.cart_code）';
COMMENT ON COLUMN "wms_rcs_bind_record"."invoke"           IS '操作类型: BIND(绑定)/UNBIND(解绑)';
COMMENT ON COLUMN "wms_rcs_bind_record"."handle_status"    IS '处理状态: PROCESSING处理中/SUCCESS成功/UNMATCHED_POINT点位未匹配/UNMATCHED_CART料车未匹配/FAILED处理异常';
COMMENT ON COLUMN "wms_rcs_bind_record"."handle_msg"       IS '处理结果说明';
COMMENT ON COLUMN "wms_rcs_bind_record"."raw_params"       IS '回调报文原文（JSON）';
COMMENT ON COLUMN "wms_rcs_bind_record"."created_time"     IS '创建时间';
COMMENT ON COLUMN "wms_rcs_bind_record"."updated_time"     IS '更新时间';
