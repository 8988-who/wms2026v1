-- ============================================================
-- 转换自 YouLai_Admin MySQL 脚本，适配 PostgreSQL 16.14
-- 原版权 Copyright (c) 2021-present, youlai.tech
-- ============================================================

-- 1. 创建数据库（若需使用，请确保有创建权限）
-- DROP DATABASE IF EXISTS youlai_admin;
-- CREATE DATABASE youlai_admin
--     WITH ENCODING='UTF8'
--     LC_COLLATE='en_US.UTF-8'
--     LC_CTYPE='en_US.UTF-8'
--     TEMPLATE=template0;
-- ============================================================
-- 2. 创建表 & 数据初始化
-- ============================================================

-- ----------------------------
-- 表：sys_dept (部门管理)
-- ----------------------------
DROP TABLE IF EXISTS sys_dept;
CREATE TABLE sys_dept (
                          id BIGSERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          code VARCHAR(100) NOT NULL,
                          parent_id BIGINT DEFAULT 0,
                          tree_path VARCHAR(255) NOT NULL,
                          sort SMALLINT DEFAULT 0,
                          status SMALLINT DEFAULT 1,
                          create_by BIGINT,
                          create_time TIMESTAMP,
                          update_by BIGINT,
                          update_time TIMESTAMP,
                          is_deleted SMALLINT DEFAULT 0
);

COMMENT ON TABLE sys_dept IS '部门管理表';
COMMENT ON COLUMN sys_dept.id IS '主键';
COMMENT ON COLUMN sys_dept.name IS '部门名称';
COMMENT ON COLUMN sys_dept.code IS '部门编号';
COMMENT ON COLUMN sys_dept.parent_id IS '父节点id';
COMMENT ON COLUMN sys_dept.tree_path IS '父节点id路径';
COMMENT ON COLUMN sys_dept.sort IS '显示顺序';
COMMENT ON COLUMN sys_dept.status IS '状态(1-正常 0-禁用)';
COMMENT ON COLUMN sys_dept.create_by IS '创建人ID';
COMMENT ON COLUMN sys_dept.create_time IS '创建时间';
COMMENT ON COLUMN sys_dept.update_by IS '修改人ID';
COMMENT ON COLUMN sys_dept.update_time IS '更新时间';
COMMENT ON COLUMN sys_dept.is_deleted IS '逻辑删除标识(1-已删除 0-未删除)';

CREATE UNIQUE INDEX uk_dept_code ON sys_dept(code);

-- 数据
INSERT INTO sys_dept VALUES (1, '有来技术', 'YOULAI', 0, '0', 1, 1, 1, NULL, 1, now(), 0);
INSERT INTO sys_dept VALUES (2, '研发部门', 'RD001', 1, '0,1', 1, 1, 2, NULL, 2, now(), 0);
INSERT INTO sys_dept VALUES (3, '测试部门', 'QA001', 1, '0,1', 1, 1, 2, NULL, 2, now(), 0);

-- ----------------------------
-- 表：sys_dict (数据字典类型)
-- ----------------------------
DROP TABLE IF EXISTS sys_dict;
CREATE TABLE sys_dict (
                          id BIGSERIAL PRIMARY KEY,
                          dict_code VARCHAR(50),
                          name VARCHAR(50),
                          status SMALLINT DEFAULT 0,
                          remark VARCHAR(255),
                          create_time TIMESTAMP,
                          create_by BIGINT,
                          update_time TIMESTAMP,
                          update_by BIGINT,
                          is_deleted SMALLINT DEFAULT 0
);
CREATE INDEX idx_dict_code ON sys_dict(dict_code);

COMMENT ON TABLE sys_dict IS '数据字典类型表';
COMMENT ON COLUMN sys_dict.id IS '主键 ';
COMMENT ON COLUMN sys_dict.dict_code IS '类型编码';
COMMENT ON COLUMN sys_dict.name IS '类型名称';
COMMENT ON COLUMN sys_dict.status IS '状态(0:正常;1:禁用)';
COMMENT ON COLUMN sys_dict.remark IS '备注';
COMMENT ON COLUMN sys_dict.create_time IS '创建时间';
COMMENT ON COLUMN sys_dict.create_by IS '创建人ID';
COMMENT ON COLUMN sys_dict.update_time IS '更新时间';
COMMENT ON COLUMN sys_dict.update_by IS '修改人ID';
COMMENT ON COLUMN sys_dict.is_deleted IS '是否删除(1-删除，0-未删除)';

INSERT INTO sys_dict VALUES (1, 'gender', '性别', 1, NULL, now(), 1, now(), 1, 0);

-- ----------------------------
-- 表：sys_dict_item (数据字典项)
-- ----------------------------
DROP TABLE IF EXISTS sys_dict_item;
CREATE TABLE sys_dict_item (
                               id BIGSERIAL PRIMARY KEY,
                               dict_code VARCHAR(50),
                               value VARCHAR(50),
                               label VARCHAR(100),
                               tag_type VARCHAR(50),
                               status SMALLINT DEFAULT 0,
                               sort INT DEFAULT 0,
                               remark VARCHAR(255),
                               create_time TIMESTAMP,
                               create_by BIGINT,
                               update_time TIMESTAMP,
                               update_by BIGINT
);

COMMENT ON TABLE sys_dict_item IS '数据字典项表';
COMMENT ON COLUMN sys_dict_item.id IS '主键';
COMMENT ON COLUMN sys_dict_item.dict_code IS '关联字典编码，与sys_dict表中的dict_code对应';
COMMENT ON COLUMN sys_dict_item.value IS '字典项值';
COMMENT ON COLUMN sys_dict_item.label IS '字典项标签';
COMMENT ON COLUMN sys_dict_item.tag_type IS '标签类型，用于前端样式展示（如success、warning等）';
COMMENT ON COLUMN sys_dict_item.status IS '状态（1-正常，0-禁用）';
COMMENT ON COLUMN sys_dict_item.sort IS '排序';
COMMENT ON COLUMN sys_dict_item.remark IS '备注';
COMMENT ON COLUMN sys_dict_item.create_time IS '创建时间';
COMMENT ON COLUMN sys_dict_item.create_by IS '创建人ID';
COMMENT ON COLUMN sys_dict_item.update_time IS '更新时间';
COMMENT ON COLUMN sys_dict_item.update_by IS '修改人ID';

INSERT INTO sys_dict_item VALUES (1, 'gender', '1', '男', 'primary', 1, 1, NULL, now(), 1, now(), 1);
INSERT INTO sys_dict_item VALUES (2, 'gender', '2', '女', 'danger', 1, 2, NULL, now(), 1, now(), 1);
INSERT INTO sys_dict_item VALUES (3, 'gender', '0', '保密', 'info', 1, 3, NULL, now(), 1, now(), 1);

-- ----------------------------
-- 表：sys_menu (系统菜单)
-- ----------------------------
DROP TABLE IF EXISTS sys_menu;
CREATE TABLE sys_menu (
                          id BIGSERIAL PRIMARY KEY,
                          parent_id BIGINT NOT NULL,
                          tree_path VARCHAR(255),
                          name VARCHAR(64) NOT NULL,
                          type CHAR(1) NOT NULL,
                          route_name VARCHAR(255),
                          route_path VARCHAR(128),
                          component VARCHAR(128),
                          external_url VARCHAR(512),
                          perm VARCHAR(128),
                          always_show SMALLINT DEFAULT 0,
                          keep_alive SMALLINT DEFAULT 0,
                          visible SMALLINT DEFAULT 1,
                          sort INT DEFAULT 0,
                          icon VARCHAR(64),
                          redirect VARCHAR(128),
                          create_time TIMESTAMP,
                          update_time TIMESTAMP,
                          params JSONB
);

COMMENT ON TABLE sys_menu IS '系统菜单表';
COMMENT ON COLUMN sys_menu.id IS 'ID';
COMMENT ON COLUMN sys_menu.parent_id IS '父菜单ID';
COMMENT ON COLUMN sys_menu.tree_path IS '父节点ID路径';
COMMENT ON COLUMN sys_menu.name IS '菜单名称';
COMMENT ON COLUMN sys_menu.type IS '菜单类型（C-目录 M-菜单 E-外链 B-按钮）';
COMMENT ON COLUMN sys_menu.route_name IS '路由名称（Vue Router 中用于命名路由）';
COMMENT ON COLUMN sys_menu.route_path IS '路由路径（Vue Router 中定义的 URL 路径）';
COMMENT ON COLUMN sys_menu.component IS '组件路径（组件页面完整路径，相对于 src/views/，缺省后缀 .vue）';
COMMENT ON COLUMN sys_menu.external_url IS '外链地址';
COMMENT ON COLUMN sys_menu.perm IS '【按钮】权限标识';
COMMENT ON COLUMN sys_menu.always_show IS '【目录】只有一个子路由是否始终显示（1-是 0-否）';
COMMENT ON COLUMN sys_menu.keep_alive IS '【菜单】是否开启页面缓存（1-是 0-否）';
COMMENT ON COLUMN sys_menu.visible IS '显示状态（1-显示 0-隐藏）';
COMMENT ON COLUMN sys_menu.sort IS '排序';
COMMENT ON COLUMN sys_menu.icon IS '菜单图标';
COMMENT ON COLUMN sys_menu.redirect IS '跳转路径';
COMMENT ON COLUMN sys_menu.create_time IS '创建时间';
COMMENT ON COLUMN sys_menu.update_time IS '更新时间';
COMMENT ON COLUMN sys_menu.params IS '路由参数';

-- 数据插入（省略所有字段默认值，直接指定）
INSERT INTO sys_menu (id, parent_id, tree_path, name, type, route_name, route_path, component, external_url, perm, always_show, keep_alive, visible, sort, icon, redirect, create_time, update_time, params) VALUES
                                                                                                                                                                                                                 (1, 0, '0', '系统管理', 'C', '', '/system', 'Layout', NULL, NULL, NULL, NULL, 1, 1, 'system', '/system/user', now(), now(), NULL),
                                                                                                                                                                                                                 (2, 0, '0', '代码生成', 'C', '', '/codegen', 'Layout', NULL, NULL, NULL, NULL, 1, 2, 'code', '/codegen/index', now(), now(), NULL),


-- 系统管理子菜单
                                                                                                                                                                                                                 (210, 1, '0,1', '用户管理', 'M', 'User', 'user', 'system/user/index', NULL, NULL, NULL, 1, 1, 1, 'el-icon-User', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2101, 210, '0,1,210', '用户查询', 'B', NULL, '', NULL, NULL, 'sys:user:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2102, 210, '0,1,210', '用户新增', 'B', NULL, '', NULL, NULL, 'sys:user:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2103, 210, '0,1,210', '用户编辑', 'B', NULL, '', NULL, NULL, 'sys:user:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2104, 210, '0,1,210', '用户删除', 'B', NULL, '', NULL, NULL, 'sys:user:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2105, 210, '0,1,210', '重置密码', 'B', NULL, '', NULL, NULL, 'sys:user:reset-password', NULL, NULL, 1, 5, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2106, 210, '0,1,210', '用户导入', 'B', NULL, '', NULL, NULL, 'sys:user:import', NULL, NULL, 1, 6, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2107, 210, '0,1,210', '用户导出', 'B', NULL, '', NULL, NULL, 'sys:user:export', NULL, NULL, 1, 7, '', NULL, now(), now(), NULL),

                                                                                                                                                                                                                 (220, 1, '0,1', '角色管理', 'M', 'Role', 'role', 'system/role/index', NULL, NULL, NULL, 1, 1, 2, 'role', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2201, 220, '0,1,220', '角色查询', 'B', NULL, '', NULL, NULL, 'sys:role:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2202, 220, '0,1,220', '角色新增', 'B', NULL, '', NULL, NULL, 'sys:role:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2203, 220, '0,1,220', '角色编辑', 'B', NULL, '', NULL, NULL, 'sys:role:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2204, 220, '0,1,220', '角色删除', 'B', NULL, '', NULL, NULL, 'sys:role:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2205, 220, '0,1,220', '角色分配权限', 'B', NULL, '', NULL, NULL, 'sys:role:assign', NULL, NULL, 1, 5, '', NULL, now(), now(), NULL),

                                                                                                                                                                                                                 (230, 1, '0,1', '菜单管理', 'M', 'SysMenu', 'menu', 'system/menu/index', NULL, NULL, NULL, 1, 1, 3, 'menu', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2301, 230, '0,1,230', '菜单查询', 'B', NULL, '', NULL, NULL, 'sys:menu:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2302, 230, '0,1,230', '菜单新增', 'B', NULL, '', NULL, NULL, 'sys:menu:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2303, 230, '0,1,230', '菜单编辑', 'B', NULL, '', NULL, NULL, 'sys:menu:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2304, 230, '0,1,230', '菜单删除', 'B', NULL, '', NULL, NULL, 'sys:menu:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL),

                                                                                                                                                                                                                 (240, 1, '0,1', '部门管理', 'M', 'Dept', 'dept', 'system/dept/index', NULL, NULL, NULL, 1, 1, 4, 'tree', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2401, 240, '0,1,240', '部门查询', 'B', NULL, '', NULL, NULL, 'sys:dept:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2402, 240, '0,1,240', '部门新增', 'B', NULL, '', NULL, NULL, 'sys:dept:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2403, 240, '0,1,240', '部门编辑', 'B', NULL, '', NULL, NULL, 'sys:dept:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2404, 240, '0,1,240', '部门删除', 'B', NULL, '', NULL, NULL, 'sys:dept:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL),

                                                                                                                                                                                                                 (250, 1, '0,1', '字典管理', 'M', 'Dict', 'dict', 'system/dict/index', NULL, NULL, NULL, 1, 1, 5, 'dict', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2501, 250, '0,1,250', '字典查询', 'B', NULL, '', NULL, NULL, 'sys:dict:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2502, 250, '0,1,250', '字典新增', 'B', NULL, '', NULL, NULL, 'sys:dict:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2503, 250, '0,1,250', '字典编辑', 'B', NULL, '', NULL, NULL, 'sys:dict:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2504, 250, '0,1,250', '字典删除', 'B', NULL, '', NULL, NULL, 'sys:dict:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL),

                                                                                                                                                                                                                 (251, 1, '0,1', '字典项', 'M', 'DictItem', 'dict-item', 'system/dict/dict-item', NULL, NULL, 0, 1, 0, 6, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2511, 251, '0,1,251', '字典项查询', 'B', NULL, '', NULL, NULL, 'sys:dict-item:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2512, 251, '0,1,251', '字典项新增', 'B', NULL, '', NULL, NULL, 'sys:dict-item:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2513, 251, '0,1,251', '字典项编辑', 'B', NULL, '', NULL, NULL, 'sys:dict-item:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2514, 251, '0,1,251', '字典项删除', 'B', NULL, '', NULL, NULL, 'sys:dict-item:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL),

                                                                                                                                                                                                                 (260, 1, '0,1', '系统日志', 'M', 'Log', 'log', 'system/log/index', NULL, NULL, 0, 1, 1, 7, 'document', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2601, 260, '0,1,260', '日志查询', 'B', NULL, '', NULL, NULL, 'sys:log:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),

                                                                                                                                                                                                                 (270, 1, '0,1', '系统配置', 'M', 'Config', 'config', 'system/config/index', NULL, NULL, 0, 1, 1, 8, 'setting', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2701, 270, '0,1,270', '系统配置查询', 'B', NULL, '', NULL, NULL, 'sys:config:list', 0, 1, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2702, 270, '0,1,270', '系统配置新增', 'B', NULL, '', NULL, NULL, 'sys:config:create', 0, 1, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2703, 270, '0,1,270', '系统配置修改', 'B', NULL, '', NULL, NULL, 'sys:config:update', 0, 1, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2704, 270, '0,1,270', '系统配置删除', 'B', NULL, '', NULL, NULL, 'sys:config:delete', 0, 1, 1, 4, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (2705, 270, '0,1,270', '系统配置刷新', 'B', NULL, '', NULL, NULL, 'sys:config:refresh', 0, 1, 1, 5, '', NULL, now(), now(), NULL),

-- 代码生成
                                                                                                                                                                                                                 (310, 2, '0,2', '代码生成', 'M', 'Codegen', 'codegen', 'codegen/index', NULL, NULL, NULL, 1, 1, 1, 'code', NULL, now(), now(), NULL),

-- 仓储管理
                                                                                                                                                                                                                 (3, 0, '0', '仓储管理', 'C', '', '/warehouse', 'Layout', NULL, NULL, NULL, NULL, 1, 3, 'warehouse', '/warehouse/wms-location', now(), now(), NULL),
                                                                                                                                                                                                                 (310, 3, '0,3', '库位/区域管理', 'M', 'WmsLocation', 'wms-location', 'warehouse/wms-location/index', NULL, NULL, NULL, 1, 1, 1, 'warehouse', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3101, 310, '0,3,310', '库位/区域查询', 'B', NULL, '', NULL, NULL, 'warehouse:wms-location:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3102, 310, '0,3,310', '库位/区域新增', 'B', NULL, '', NULL, NULL, 'warehouse:wms-location:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3103, 310, '0,3,310', '库位/区域编辑', 'B', NULL, '', NULL, NULL, 'warehouse:wms-location:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3104, 310, '0,3,310', '库位/区域删除', 'B', NULL, '', NULL, NULL, 'warehouse:wms-location:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (320, 3, '0,3', '巷道管理', 'M', 'WmsAisle', 'wms-aisle', 'warehouse/wms-aisle/index', NULL, NULL, NULL, 1, 1, 2, 'warehouse', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3201, 320, '0,3,320', '巷道查询', 'B', NULL, '', NULL, NULL, 'warehouse:wms-aisle:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3202, 320, '0,3,320', '巷道新增', 'B', NULL, '', NULL, NULL, 'warehouse:wms-aisle:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3203, 320, '0,3,320', '巷道编辑', 'B', NULL, '', NULL, NULL, 'warehouse:wms-aisle:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3204, 320, '0,3,320', '巷道删除', 'B', NULL, '', NULL, NULL, 'warehouse:wms-aisle:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (330, 3, '0,3', '点位管理', 'M', 'WmsPoint', 'wms-point', 'warehouse/wms-point/index', NULL, NULL, NULL, 1, 1, 3, 'warehouse', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3301, 330, '0,3,330', '点位查询', 'B', NULL, '', NULL, NULL, 'warehouse:wms-point:list', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3302, 330, '0,3,330', '点位新增', 'B', NULL, '', NULL, NULL, 'warehouse:wms-point:create', NULL, NULL, 1, 2, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3303, 330, '0,3,330', '点位编辑', 'B', NULL, '', NULL, NULL, 'warehouse:wms-point:update', NULL, NULL, 1, 3, '', NULL, now(), now(), NULL),
                                                                                                                                                                                                                 (3304, 330, '0,3,330', '点位删除', 'B', NULL, '', NULL, NULL, 'warehouse:wms-point:delete', NULL, NULL, 1, 4, '', NULL, now(), now(), NULL);

-- ----------------------------
-- 表：sys_role (系统角色)
-- ----------------------------
DROP TABLE IF EXISTS sys_role;
CREATE TABLE sys_role (
                          id BIGSERIAL PRIMARY KEY,
                          name VARCHAR(64) NOT NULL,
                          code VARCHAR(32) NOT NULL,
                          sort INT,
                          status SMALLINT DEFAULT 1,
                          data_scope SMALLINT,
                          create_by BIGINT,
                          create_time TIMESTAMP,
                          update_by BIGINT,
                          update_time TIMESTAMP,
                          is_deleted SMALLINT DEFAULT 0
);

COMMENT ON TABLE sys_role IS '系统角色表';
COMMENT ON COLUMN sys_role.id IS '主键';
COMMENT ON COLUMN sys_role.name IS '角色名称';
COMMENT ON COLUMN sys_role.code IS '角色编码';
COMMENT ON COLUMN sys_role.sort IS '显示顺序';
COMMENT ON COLUMN sys_role.status IS '角色状态(1-正常 0-停用)';
COMMENT ON COLUMN sys_role.data_scope IS '数据权限(1-所有数据 2-部门及子部门数据 3-本部门数据 4-本人数据 5-自定义部门数据)';
COMMENT ON COLUMN sys_role.create_by IS '创建人 ID';
COMMENT ON COLUMN sys_role.create_time IS '创建时间';
COMMENT ON COLUMN sys_role.update_by IS '更新人ID';
COMMENT ON COLUMN sys_role.update_time IS '更新时间';
COMMENT ON COLUMN sys_role.is_deleted IS '逻辑删除标识(0-未删除 1-已删除)';

CREATE UNIQUE INDEX uk_role_name ON sys_role(name);
CREATE UNIQUE INDEX uk_role_code ON sys_role(code);

INSERT INTO sys_role VALUES (1, '超级管理员', 'ROOT', 1, 1, 1, NULL, now(), NULL, now(), 0);
INSERT INTO sys_role VALUES (2, '系统管理员', 'ADMIN', 2, 1, 1, NULL, now(), NULL, NULL, 0);
INSERT INTO sys_role VALUES (3, '访问游客', 'GUEST', 3, 1, 3, NULL, now(), NULL, now(), 0);
INSERT INTO sys_role VALUES (4, '部门主管', 'DEPT_MANAGER', 4, 1, 2, NULL, now(), NULL, now(), 0);
INSERT INTO sys_role VALUES (5, '部门成员', 'DEPT_MEMBER', 5, 1, 3, NULL, now(), NULL, now(), 0);
INSERT INTO sys_role VALUES (6, '普通员工', 'EMPLOYEE', 6, 1, 4, NULL, now(), NULL, now(), 0);
INSERT INTO sys_role VALUES (7, '自定义权限用户', 'CUSTOM_USER', 7, 1, 5, NULL, now(), NULL, now(), 0);

-- ----------------------------
-- 表：sys_role_menu (角色菜单关联)
-- ----------------------------
DROP TABLE IF EXISTS sys_role_menu;
CREATE TABLE sys_role_menu (
                               role_id BIGINT NOT NULL,
                               menu_id BIGINT NOT NULL
);
CREATE UNIQUE INDEX uk_roleid_menuid ON sys_role_menu(role_id, menu_id);

COMMENT ON TABLE sys_role_menu IS '角色菜单关联表';
COMMENT ON COLUMN sys_role_menu.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_menu.menu_id IS '菜单ID';

-- 使用 ON CONFLICT 代替 INSERT IGNORE
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
                                                 (2, 1), (2, 2), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9),
                                                 (2, 210), (2, 2101), (2, 2102), (2, 2103), (2, 2104), (2, 2105), (2, 2106), (2, 2107),
                                                 (2, 220), (2, 2201), (2, 2202), (2, 2203), (2, 2204), (2, 2205),
                                                 (2, 230), (2, 2301), (2, 2302), (2, 2303), (2, 2304),
                                                 (2, 240), (2, 2401), (2, 2402), (2, 2403), (2, 2404),
                                                 (2, 250), (2, 2501), (2, 2502), (2, 2503), (2, 2504),
                                                 (2, 251), (2, 2511), (2, 2512), (2, 2513), (2, 2514),
                                                 (2, 260), (2, 2601),
                                                 (2, 270), (2, 2701), (2, 2702), (2, 2703), (2, 2704), (2, 2705),
                                                 (2, 280), (2, 2801), (2, 2802), (2, 2803), (2, 2804), (2, 2805), (2, 2806),
                                                 (2, 310),
                                                 (2, 501), (2, 502), (2, 503), (2, 504),
                                                 (2, 601),
                                                 (2, 701), (2, 702), (2, 703), (2, 704), (2, 705), (2, 706), (2, 707), (2, 708), (2, 709),
                                                 (2, 801), (2, 802), (2, 803), (2, 804),
                                                 (2, 910), (2, 911), (2, 912), (2, 913),
                                                 (2, 1001), (2, 1002)
    ON CONFLICT (role_id, menu_id) DO NOTHING;

-- 其他角色的 INSERT IGNORE 也转换
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
                                                 (4, 1),
                                                 (4, 210), (4, 2101), (4, 2102), (4, 2103), (4, 2104), (4, 2105), (4, 2106), (4, 2107),
                                                 (4, 220), (4, 2201), (4, 2202), (4, 2203), (4, 2204), (4, 2205)
    ON CONFLICT (role_id, menu_id) DO NOTHING;

INSERT INTO sys_role_menu (role_id, menu_id) VALUES
                                                 (5, 1),
                                                 (5, 210), (5, 2101), (5, 2102), (5, 2103), (5, 2104), (5, 2105), (5, 2106), (5, 2107),
                                                 (5, 220), (5, 2201), (5, 2202), (5, 2203), (5, 2204), (5, 2205)
    ON CONFLICT (role_id, menu_id) DO NOTHING;

INSERT INTO sys_role_menu (role_id, menu_id) VALUES
                                                 (6, 1),
                                                 (6, 210), (6, 2101), (6, 2102), (6, 2103), (6, 2104), (6, 2105), (6, 2106), (6, 2107),
                                                 (6, 220), (6, 2201), (6, 2202), (6, 2203), (6, 2204), (6, 2205)
    ON CONFLICT (role_id, menu_id) DO NOTHING;

INSERT INTO sys_role_menu (role_id, menu_id) VALUES
                                                 (7, 1),
                                                 (7, 210), (7, 2101), (7, 2102), (7, 2103), (7, 2104), (7, 2105), (7, 2106), (7, 2107),
                                                 (7, 220), (7, 2201), (7, 2202), (7, 2203), (7, 2204), (7, 2205)
    ON CONFLICT (role_id, menu_id) DO NOTHING;

-- ----------------------------
-- 表：sys_role_dept (角色部门关联)
-- ----------------------------
DROP TABLE IF EXISTS sys_role_dept;
CREATE TABLE sys_role_dept (
                               role_id BIGINT NOT NULL,
                               dept_id BIGINT NOT NULL
);
CREATE UNIQUE INDEX uk_roleid_deptid ON sys_role_dept(role_id, dept_id);

COMMENT ON TABLE sys_role_dept IS '角色部门关联表';
COMMENT ON COLUMN sys_role_dept.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_dept.dept_id IS '部门ID';

INSERT INTO sys_role_dept (role_id, dept_id) VALUES (7, 1), (7, 2)
    ON CONFLICT (role_id, dept_id) DO NOTHING;

-- ----------------------------
-- 表：sys_user (系统用户)
-- ----------------------------
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
                          id BIGSERIAL PRIMARY KEY,
                          username VARCHAR(64),
                          nickname VARCHAR(64),
                          gender SMALLINT DEFAULT 1,
                          password VARCHAR(100),
                          dept_id BIGINT,
                          avatar VARCHAR(255),
                          mobile VARCHAR(20),
                          status SMALLINT DEFAULT 1,
                          email VARCHAR(128),
                          create_time TIMESTAMP,
                          create_by BIGINT,
                          update_time TIMESTAMP,
                          update_by BIGINT,
                          is_deleted SMALLINT DEFAULT 0
);

COMMENT ON TABLE sys_user IS '系统用户表';
COMMENT ON COLUMN sys_user.id IS '主键';
COMMENT ON COLUMN sys_user.username IS '用户名';
COMMENT ON COLUMN sys_user.nickname IS '昵称';
COMMENT ON COLUMN sys_user.gender IS '性别((1-男 2-女 0-保密)';
COMMENT ON COLUMN sys_user.password IS '密码';
COMMENT ON COLUMN sys_user.dept_id IS '部门ID';
COMMENT ON COLUMN sys_user.avatar IS '用户头像';
COMMENT ON COLUMN sys_user.mobile IS '联系方式';
COMMENT ON COLUMN sys_user.status IS '状态(1-正常 0-禁用)';
COMMENT ON COLUMN sys_user.email IS '用户邮箱';
COMMENT ON COLUMN sys_user.create_time IS '创建时间';
COMMENT ON COLUMN sys_user.create_by IS '创建人ID';
COMMENT ON COLUMN sys_user.update_time IS '更新时间';
COMMENT ON COLUMN sys_user.update_by IS '修改人ID';
COMMENT ON COLUMN sys_user.is_deleted IS '逻辑删除标识(0-未删除 1-已删除)';

INSERT INTO sys_user VALUES (1, 'root', '有来技术', 0, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', NULL, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345677', 1, 'youlaitech@163.com', now(), NULL, now(), NULL, 0);
INSERT INTO sys_user VALUES (2, 'admin', '系统管理员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18888888888', 1, 'youlaitech@163.com', now(), NULL, now(), NULL, 0);
INSERT INTO sys_user VALUES (3, 'test', '测试小用户', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 3, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345679', 1, 'youlaitech@163.com', now(), NULL, now(), NULL, 0);
INSERT INTO sys_user VALUES (4, 'dept_manager', '部门主管', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345680', 1, 'manager@youlaitech.com', now(), NULL, now(), NULL, 0);
INSERT INTO sys_user VALUES (5, 'dept_member', '部门成员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345681', 1, 'member@youlaitech.com', now(), NULL, now(), NULL, 0);
INSERT INTO sys_user VALUES (6, 'employee', '普通员工', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 2, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345682', 1, 'employee@youlaitech.com', now(), NULL, now(), NULL, 0);
INSERT INTO sys_user VALUES (7, 'custom_user', '自定义权限用户', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 3, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345683', 1, 'custom@youlaitech.com', now(), NULL, now(), NULL, 0);

-- ----------------------------
-- 表：sys_user_role (用户角色关联)
-- ----------------------------
DROP TABLE IF EXISTS sys_user_role;
CREATE TABLE sys_user_role (
                               user_id BIGINT NOT NULL,
                               role_id BIGINT NOT NULL,
                               PRIMARY KEY (user_id, role_id)
);

COMMENT ON TABLE sys_user_role IS '用户角色关联表';
COMMENT ON COLUMN sys_user_role.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_role.role_id IS '角色ID';

INSERT INTO sys_user_role (user_id, role_id) VALUES
                                                 (1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7)
    ON CONFLICT (user_id, role_id) DO NOTHING;

-- ----------------------------
-- 表：sys_log (系统操作日志)
-- ----------------------------
DROP TABLE IF EXISTS sys_log;
CREATE TABLE sys_log (
                         id BIGSERIAL PRIMARY KEY,
                         module SMALLINT NOT NULL,
                         action_type SMALLINT NOT NULL,
                         title VARCHAR(100) NOT NULL,
                         content TEXT,
                         operator_id BIGINT,
                         operator_name VARCHAR(50),
                         request_uri VARCHAR(255),
                         request_method VARCHAR(10),
                         ip VARCHAR(45),
                         province VARCHAR(100),
                         city VARCHAR(100),
                         device VARCHAR(100),
                         os VARCHAR(100),
                         browser VARCHAR(100),
                         status SMALLINT DEFAULT 1,
                         error_msg VARCHAR(255),
                         execution_time INT,
                         create_time TIMESTAMP
);

COMMENT ON TABLE sys_log IS '系统操作日志表';
COMMENT ON COLUMN sys_log.id IS '主键';
COMMENT ON COLUMN sys_log.module IS '模块，数字枚举，参考 LogModule 枚举';
COMMENT ON COLUMN sys_log.action_type IS '操作类型，数字枚举，参考 ActionType 枚举';
COMMENT ON COLUMN sys_log.title IS '前端显示标题';
COMMENT ON COLUMN sys_log.content IS '自定义日志内容';
COMMENT ON COLUMN sys_log.operator_id IS '操作人ID';
COMMENT ON COLUMN sys_log.operator_name IS '操作人名称';
COMMENT ON COLUMN sys_log.request_uri IS '请求路径';
COMMENT ON COLUMN sys_log.request_method IS '请求方法';
COMMENT ON COLUMN sys_log.ip IS 'IP地址';
COMMENT ON COLUMN sys_log.province IS '省份';
COMMENT ON COLUMN sys_log.city IS '城市';
COMMENT ON COLUMN sys_log.device IS '设备';
COMMENT ON COLUMN sys_log.os IS '操作系统';
COMMENT ON COLUMN sys_log.browser IS '浏览器';
COMMENT ON COLUMN sys_log.status IS '0失败 1成功';
COMMENT ON COLUMN sys_log.error_msg IS '错误信息';
COMMENT ON COLUMN sys_log.execution_time IS '执行时间(ms)';
COMMENT ON COLUMN sys_log.create_time IS '操作时间';

CREATE INDEX idx_module_action_time ON sys_log(module, action_type, create_time);
CREATE INDEX idx_operator_time ON sys_log(operator_id, create_time);
CREATE INDEX idx_time ON sys_log(create_time);

-- ----------------------------
-- 表：gen_table (代码生成配置)
-- ----------------------------
DROP TABLE IF EXISTS gen_table;
CREATE TABLE gen_table (
                           id BIGSERIAL PRIMARY KEY,
                           table_name VARCHAR(100) NOT NULL,
                           module_name VARCHAR(100),
                           package_name VARCHAR(255) NOT NULL,
                           business_name VARCHAR(100) NOT NULL,
                           entity_name VARCHAR(100) NOT NULL,
                           author VARCHAR(50) NOT NULL,
                           parent_menu_id BIGINT,
                           remove_table_prefix VARCHAR(20),
                           page_type VARCHAR(20),
                           create_time TIMESTAMP,
                           update_time TIMESTAMP,
                           is_deleted SMALLINT DEFAULT 0
);

COMMENT ON TABLE gen_table IS '代码生成配置表';
COMMENT ON COLUMN gen_table.id IS '主键';
COMMENT ON COLUMN gen_table.table_name IS '表名';
COMMENT ON COLUMN gen_table.module_name IS '模块名';
COMMENT ON COLUMN gen_table.package_name IS '包名';
COMMENT ON COLUMN gen_table.business_name IS '业务名';
COMMENT ON COLUMN gen_table.entity_name IS '实体类名';
COMMENT ON COLUMN gen_table.author IS '作者';
COMMENT ON COLUMN gen_table.parent_menu_id IS '上级菜单ID，对应sys_menu的id';
COMMENT ON COLUMN gen_table.remove_table_prefix IS '要移除的表前缀，如: sys_';
COMMENT ON COLUMN gen_table.page_type IS '页面类型(classic|curd)';
COMMENT ON COLUMN gen_table.create_time IS '创建时间';
COMMENT ON COLUMN gen_table.update_time IS '更新时间';
COMMENT ON COLUMN gen_table.is_deleted IS '是否删除';

CREATE UNIQUE INDEX uk_tablename ON gen_table(table_name);

-- ----------------------------
-- 表：gen_table_column (代码生成字段配置)
-- ----------------------------
DROP TABLE IF EXISTS gen_table_column;
CREATE TABLE gen_table_column (
                                  id BIGSERIAL PRIMARY KEY,
                                  table_id BIGINT NOT NULL,
                                  column_name VARCHAR(100),
                                  column_type VARCHAR(50),
                                  column_length INT,
                                  field_name VARCHAR(100) NOT NULL,
                                  field_type VARCHAR(100),
                                  field_sort INT,
                                  field_comment VARCHAR(255),
                                  max_length INT,
                                  is_required SMALLINT,
                                  is_show_in_list SMALLINT DEFAULT 0,
                                  is_show_in_form SMALLINT DEFAULT 0,
                                  is_show_in_query SMALLINT DEFAULT 0,
                                  query_type SMALLINT,
                                  form_type SMALLINT,
                                  dict_type VARCHAR(50),
                                  create_time TIMESTAMP,
                                  update_time TIMESTAMP
);

COMMENT ON TABLE gen_table_column IS '代码生成字段配置表';
COMMENT ON COLUMN gen_table_column.id IS '主键';
COMMENT ON COLUMN gen_table_column.table_id IS '关联的表配置ID';
COMMENT ON COLUMN gen_table_column.column_name IS '列名';
COMMENT ON COLUMN gen_table_column.column_type IS '列类型';
COMMENT ON COLUMN gen_table_column.column_length IS '列长度';
COMMENT ON COLUMN gen_table_column.field_name IS '字段名称';
COMMENT ON COLUMN gen_table_column.field_type IS '字段类型';
COMMENT ON COLUMN gen_table_column.field_sort IS '字段排序';
COMMENT ON COLUMN gen_table_column.field_comment IS '字段描述';
COMMENT ON COLUMN gen_table_column.max_length IS '最大长度';
COMMENT ON COLUMN gen_table_column.is_required IS '是否必填';
COMMENT ON COLUMN gen_table_column.is_show_in_list IS '是否在列表显示';
COMMENT ON COLUMN gen_table_column.is_show_in_form IS '是否在表单显示';
COMMENT ON COLUMN gen_table_column.is_show_in_query IS '是否在查询条件显示';
COMMENT ON COLUMN gen_table_column.query_type IS '查询方式';
COMMENT ON COLUMN gen_table_column.form_type IS '表单类型';
COMMENT ON COLUMN gen_table_column.dict_type IS '字典类型';
COMMENT ON COLUMN gen_table_column.create_time IS '创建时间';
COMMENT ON COLUMN gen_table_column.update_time IS '更新时间';

CREATE INDEX idx_table_id ON gen_table_column(table_id);

-- ----------------------------
-- 表：sys_config (系统配置)
-- ----------------------------
DROP TABLE IF EXISTS sys_config;
CREATE TABLE sys_config (
                            id BIGSERIAL PRIMARY KEY,
                            config_name VARCHAR(50) NOT NULL,
                            config_key VARCHAR(50) NOT NULL,
                            config_value VARCHAR(100) NOT NULL,
                            remark VARCHAR(255),
                            create_time TIMESTAMP,
                            create_by BIGINT,
                            update_time TIMESTAMP,
                            update_by BIGINT,
                            is_deleted SMALLINT DEFAULT 0 NOT NULL
);

COMMENT ON TABLE sys_config IS '系统配置表';
COMMENT ON COLUMN sys_config.id IS '主键';
COMMENT ON COLUMN sys_config.config_name IS '配置名称';
COMMENT ON COLUMN sys_config.config_key IS '配置key';
COMMENT ON COLUMN sys_config.config_value IS '配置值';
COMMENT ON COLUMN sys_config.remark IS '备注';
COMMENT ON COLUMN sys_config.create_time IS '创建时间';
COMMENT ON COLUMN sys_config.create_by IS '创建人ID';
COMMENT ON COLUMN sys_config.update_time IS '更新时间';
COMMENT ON COLUMN sys_config.update_by IS '更新人ID';
COMMENT ON COLUMN sys_config.is_deleted IS '逻辑删除标识(0-未删除 1-已删除)';

INSERT INTO sys_config VALUES (1, '系统限流QPS', 'IP_QPS_THRESHOLD_LIMIT', '10', '单个IP请求的最大每秒查询数（QPS）阈值Key', now(), 1, NULL, NULL, 0);

-- ----------------------------
-- 表：sys_user_social (第三方账号绑定)
-- ----------------------------
DROP TABLE IF EXISTS sys_user_social;
CREATE TABLE sys_user_social (
                                 id BIGSERIAL PRIMARY KEY,
                                 user_id BIGINT NOT NULL,
                                 platform VARCHAR(20) NOT NULL,
                                 openid VARCHAR(64) NOT NULL,
                                 unionid VARCHAR(64),
                                 nickname VARCHAR(64),
                                 avatar VARCHAR(255),
                                 session_key VARCHAR(128),
                                 verified SMALLINT DEFAULT 1,
                                 create_time TIMESTAMP,
                                 update_time TIMESTAMP
);

COMMENT ON TABLE sys_user_social IS '用户第三方账号绑定表';
COMMENT ON COLUMN sys_user_social.id IS '主键ID';
COMMENT ON COLUMN sys_user_social.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_social.platform IS '平台类型(WECHAT_MINI/WECHAT_MP/ALIPAY/QQ/APPLE)';
COMMENT ON COLUMN sys_user_social.openid IS '平台openid';
COMMENT ON COLUMN sys_user_social.unionid IS '微信unionid';
COMMENT ON COLUMN sys_user_social.nickname IS '第三方昵称';
COMMENT ON COLUMN sys_user_social.avatar IS '第三方头像URL';
COMMENT ON COLUMN sys_user_social.session_key IS '微信session_key';
COMMENT ON COLUMN sys_user_social.verified IS '是否已验证(1-已验证 0-未验证)';
COMMENT ON COLUMN sys_user_social.create_time IS '绑定时间';
COMMENT ON COLUMN sys_user_social.update_time IS '更新时间';

CREATE UNIQUE INDEX uk_platform_openid ON sys_user_social(platform, openid);
CREATE INDEX idx_user_id ON sys_user_social(user_id);
CREATE INDEX idx_unionid ON sys_user_social(unionid);
