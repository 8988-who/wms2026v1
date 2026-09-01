-- =============================================================
-- 变更：点位地图坐标(wms_point.coordinate)收紧为业务必填
-- 日期：2026-08-31
-- 背景：RCS 下发 targetRoute.code 通过 point_code 反查 wms_point.coordinate
--       作为站点编码（toRcsSiteCode），坐标为空会退化为下发点位编码导致 RCS 无法识别。
-- 说明：该列 DDL 本身为 NOT NULL DEFAULT ''，空字符串仍可写入；
--       此处补充 CHECK 约束禁止空串（幂等，已存在同名约束时跳过）。
-- 执行前请先确认存量数据无空坐标：
--   SELECT id, point_code FROM wms_point WHERE coordinate IS NULL OR coordinate = '';
-- =============================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_wms_point_coordinate_not_blank'
          AND conrelid = 'wms_point'::regclass
    ) THEN
        ALTER TABLE wms_point
            ADD CONSTRAINT ck_wms_point_coordinate_not_blank
            CHECK (coordinate <> '');
    END IF;
END
$$;
