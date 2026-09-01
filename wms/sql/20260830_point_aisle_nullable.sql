-- =============================================================
-- 变更：点位支持"无巷道（离散点位）"，直接归属区域
-- 日期：2026-08-30
-- 说明：
--   1) wms_point.aisle_id 由 NOT NULL 改为可空，NULL 表示离散点位
--      （不挂巷道，直接与区域 location_id 匹配）；
--   2) wms_cart_inventory.aisle_id 为自 wms_point.aisle_id 的冗余列，
--      同步放开可空（该表建表晚于 publicall.sql 全量 dump，若列存在
--      NOT NULL 约束则需执行；已可空时语句不会生效报错）。
-- 注意：PostgreSQL 的 ALTER ... DROP NOT NULL 对已可空列执行不报错，
--       可重复执行；COMMENT 语句覆盖原注释。
-- =============================================================

ALTER TABLE wms_point ALTER COLUMN aisle_id DROP NOT NULL;

COMMENT ON COLUMN wms_point.aisle_id IS '所属巷道ID，关联 wms_aisle.id；NULL 表示离散点位（不挂巷道，直接归属区域）';

ALTER TABLE wms_cart_inventory ALTER COLUMN aisle_id DROP NOT NULL;
