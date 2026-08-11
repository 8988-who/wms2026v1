# 系统管理模块（system）

## 1. 模块概述

`sys_*` 系列表及 `com.wms.system` 包为**第三方脚手架**（RuoYi 系风格，源码作者 `haoxr` / `Ray.Hao` / `Theo`）迁移而来，本模块按 **"使用方"视角**描述其对外能力：围绕 RBAC 提供用户 / 角色 / 菜单 / 部门 / 字典 / 配置 / 操作日志 / 通知公告的完整管理能力，并作为认证授权的数据源（用户名/手机号/第三方 openid 三种方式反查认证凭证）。

**能力清单**：

| 能力 | 说明 |
|------|------|
| 用户管理 | 分页/增删改查、状态启停、重置密码、个人中心（资料/改密/绑定换绑手机号、邮箱）、导入导出（EasyExcel） |
| 角色管理 | 分页/增删改查、状态启停、**菜单权限分配**、**数据权限分级**（所有/部门及子部门/本部门/本人/自定义部门） |
| 菜单管理 | 菜单树（C-目录/M-菜单/E-外链/B-按钮）、**动态生成前端 Vue Router 路由**（RouteVO） |
| 部门管理 | 部门树（tree_path 级联删除）、下拉选项 |
| 字典管理 | 字典类型 + 字典项两级维护，**变更后 SSE 实时推送**（`SseService.sendDictChange`） |
| 系统配置 | key-value 配置，**启动全量加载 Redis Hash**、按 key 读取、手动刷新 |
| 操作日志 | `@Log` AOP 落库（模块/动作/IP 归属地/设备/耗时），**PV/UV 访问统计**（今日/累计/环比增长率、趋势） |
| 认证适配 | 实现 framework 层 `UserAuthenticationPort` / `PermissionPort` 两个端口，供 auth 模块登录鉴权复用 |
| 通知公告 | 表已建（sys_notice / sys_user_notice），**当前无 Java 代码使用**（脚手架预留表） |

---

## 2. 数据表设计（来源 [public.sql](../../wms/sql/public.sql)）

`sys_*` 共 14 张表：**主表类 9 张**（承载业务数据）+ **关联表类 5 张**（用户-角色、角色-菜单、角色-部门、用户-通知、用户-第三方绑定）。

### 2.1 主表类

#### `sys_user` —— 系统用户表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| username | varchar(64) | 用户名（登录账号，唯一校验） |
| nickname | varchar(64) | 昵称 |
| gender | int2 DEFAULT 1 | 性别（1-男 2-女 0-保密，关联字典 gender） |
| password | varchar(100) | 密码（BCrypt 密文，默认 123456） |
| dept_id | int8 | 部门ID（关联 sys_dept.id） |
| avatar / mobile / email | varchar | 头像 / 手机号（认证方式之一）/ 邮箱 |
| status | int2 DEFAULT 1 | 状态（1-正常 0-禁用，禁用即失效会话） |
| create_time / create_by / update_time / update_by / is_deleted | timestamp / int8 / int2 | 审计字段（is_deleted 全局逻辑删除） |

#### `sys_role` —— 系统角色表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| name | varchar(64) | 角色名称 |
| code | varchar(32) | 角色编码（`ROOT` 为超级管理员，非 ROOT 用户不可见/不可分配） |
| sort | int4 | 显示顺序 |
| status | int2 DEFAULT 1 | 角色状态（1-正常 0-停用，停用失效关联用户会话） |
| data_scope | int2 | 数据权限（1-所有数据 2-部门及子部门 3-本部门 4-本人 5-自定义部门数据） |
| create_time / create_by / update_time / update_by / is_deleted | — | 审计字段 |

#### `sys_menu` —— 系统菜单表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| parent_id | int8 NOT NULL | 父菜单ID（顶级为 0） |
| tree_path | varchar(255) | 父节点ID路径（逗号分隔，如 `0,1`，删除/权限过滤用） |
| name | varchar(64) | 菜单名称 |
| type | varchar(1) | 菜单类型（C-目录 M-菜单 E-外链 B-按钮） |
| route_name / route_path | varchar | Vue Router 路由名称 / 路径 |
| component | varchar(128) | 组件路径（相对 src/views/，省略 .vue；`iframe` 表示内嵌外链） |
| external_url | varchar(512) | 外链地址 |
| perm | varchar(128) | 【按钮】权限标识（如 `sys:user:create`） |
| always_show / keep_alive / visible / sort / icon / redirect | int2 / varchar | 前端展示属性（始终显示 / 页面缓存 / 显隐 / 排序 / 图标 / 跳转） |
| params | jsonb | 路由参数（实体用 JacksonTypeHandler 映射 `Map<String,Object>`） |
| create_time / update_time | timestamp | 审计字段（**该表无 is_deleted，删除为物理删除**） |

#### `sys_dept` —— 部门管理表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| name / code | varchar(100) | 部门名称 / 部门编号（编号唯一校验） |
| parent_id | int8 DEFAULT 0 | 父节点id |
| tree_path | varchar(255) | 父节点id路径（删除时 `CONCAT(',',tree_path,',') LIKE` 级联逻辑删除子部门） |
| sort | int2 DEFAULT 0 | 显示顺序 |
| status | int2 DEFAULT 1 | 状态（1-正常 0-禁用） |
| plant_code | varchar(255) | 厂区编码（预留数据权限隔离） |
| create_time / create_by / update_time / update_by / is_deleted | — | 审计字段 |

#### `sys_dict` —— 数据字典类型表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| dict_code | varchar(50) | 类型编码（唯一校验，如 gender / notice_type / notice_level） |
| name | varchar(50) | 类型名称 |
| status | int2 DEFAULT 0 | 状态（0-正常 1-禁用） |
| remark | varchar(255) | 备注 |
| create_time / create_by / update_time / update_by / is_deleted | — | 审计字段 |

#### `sys_dict_item` —— 数据字典项表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| dict_code | varchar(50) | 关联字典编码（与 sys_dict.dict_code 对应） |
| value / label | varchar | 字典项值 / 字典项标签 |
| tag_type | varchar(50) | 标签类型（前端样式：success、warning 等） |
| status | int2 DEFAULT 0 | 状态（1-正常 0-禁用） |
| sort | int4 DEFAULT 0 | 排序 |
| remark | varchar(255) | 备注 |
| create_time / create_by / update_time / update_by | — | 审计字段（无 is_deleted，物理删除） |

#### `sys_config` —— 系统配置表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| config_name | varchar(50) | 配置名称 |
| config_key | varchar(50) | 配置key（唯一校验，Redis Hash 的 field） |
| config_value | varchar(100) | 配置值 |
| remark | varchar(255) | 备注 |
| create_time / create_by / update_time / update_by / is_deleted | — | 审计字段 |

#### `sys_log` —— 系统操作日志表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| module | int2 NOT NULL | 模块（数字枚举，对应 LogModuleEnum） |
| action_type | int2 NOT NULL | 操作类型（数字枚举，对应 ActionTypeEnum） |
| title | varchar(100) | 前端显示标题 |
| content | text | 自定义日志内容 |
| operator_id / operator_name | int8 / varchar(50) | 操作人ID / 名称 |
| request_uri / request_method | text / varchar(10) | 请求路径 / 请求方法 |
| ip / province / city | varchar | IP 地址 / 省份 / 城市（ip2region 归属地） |
| device / os / browser | varchar(100) | 设备 / 操作系统 / 浏览器（UA 解析） |
| status | int2 DEFAULT 1 | 0失败 1成功 |
| error_msg | text | 错误信息 |
| execution_time | int4 | 执行时间(ms) |
| create_time | timestamp(6) | 操作时间（PV/UV 统计按此字段分组） |

#### `sys_notice` —— 系统通知公告表（预留，无代码）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| title / content | varchar(50) / text | 通知标题 / 内容 |
| type | int2 NOT NULL | 通知类型（关联字典编码 notice_type） |
| level | varchar(5) NOT NULL | 通知等级（字典 code：notice_level） |
| target_type / target_user_ids | int2 / varchar(255) | 目标类型（1-全体 2-指定）/ 目标人ID集合（逗号分隔） |
| publisher_id / publish_status | int8 / int2 | 发布人ID / 发布状态（0-未发布 1-已发布 -1-已撤回） |
| publish_time / revoke_time | timestamp | 发布时间 / 撤回时间 |
| create_by / create_time / update_by / update_time / is_deleted | — | 审计字段 |

### 2.2 关联表类

| 表名 | 结构 | 说明 |
|------|------|------|
| `sys_user_role` | user_id, role_id（均 NOT NULL） | 用户-角色关联（用户表单的 roleIds 集合、角色删除前校验是否已分配用户） |
| `sys_role_menu` | role_id, menu_id（均 NOT NULL） | 角色-菜单关联（角色分配菜单、权限标识 perm 的来源） |
| `sys_role_dept` | role_id, dept_id（均 NOT NULL） | 角色-部门关联（data_scope=5 自定义数据权限时生效） |
| `sys_user_notice` | id, notice_id, user_id, is_read, read_time, create_time, update_time, is_deleted | 用户-通知关联（已读状态） |
| `sys_user_social` | id, user_id, platform(varchar20), openid(varchar64), unionid, nickname, avatar, session_key, verified, create_time, update_time | 用户第三方账号绑定（platform：WECHAT_MINI/WECHAT_MP/ALIPAY/QQ/APPLE，认证适配器经 openid 反查用户） |

> **审计字段差异**：`sys_*` 统一为 `create_time / update_time / is_deleted`（实体继承 [BaseEntity.java](../../wms/src/main/java/com/wms/common/base/BaseEntity.java)，`createTime/updateTime` 由 MyBatis-Plus `FieldFill` 自动填充；`isDeleted` 由全局配置 `logic-delete-field: isDeleted` 实现逻辑删除）；而业务自建 `wms_*` 表统一为 `created_time / updated_time / created_by / updated_by`（默认 `CURRENT_TIMESTAMP`），与业务表刻意区分，两套风格并存。

---

## 3. 数据库交互

本模块全部持久层基于 **MyBatis-Plus**，无 JDBC 原生操作。

### 3.1 数据访问方式总览

| 方式 | 说明 | 典型用法 |
|------|------|---------|
| `BaseMapper` / `ServiceImpl` | 单表 CRUD 零 SQL | `getById` / `save` / `saveOrUpdate` / `updateById` / `removeById` / `count` / `exists` |
| `LambdaQueryWrapper` / `LambdaUpdateWrapper` | 类型安全条件构造 | 用户名唯一校验、字典项查询、`set` 局部更新 |
| `Page` 分页 | MyBatis-Plus 分页插件拦截改写 | `new Page<>(pageNum, pageSize)` |
| 自定义 XML SQL | 多表 JOIN、聚合统计 | [UserMapper.xml](../../wms/src/main/resources/mapper/system/UserMapper.xml)、[LogMapper.xml](../../wms/src/main/resources/mapper/system/LogMapper.xml) 等 12 个 system 下 XML |
| `@DataPermission` | 框架数据权限切面（jsqlparser 改写 SQL） | `UserMapper.getUserPage`（deptAlias="u"）、`DeptMapper.selectList`（deptIdColumnName="id"） |

### 3.2 关键交互点

| 交互点 | 位置 | 说明 |
|--------|------|------|
| 用户导入 | [UserController.java](../../wms/src/main/java/com/wms/system/controller/UserController.java) → [UserImportListener.java](../../wms/src/main/java/com/wms/system/listener/UserImportListener.java) | EasyExcel `AnalysisEventListener` 逐行校验（用户名非空且唯一、昵称/手机号非空、手机号格式），构造器中一次性预载角色/部门/性别字典避免逐行查库 |
| 用户导出 | UserController → [UserServiceImpl.listExportUsers](../../wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java) | XML 查导出列表，性别值经字典 label 反查翻译，EasyExcel `doWrite` 写出 |
| 菜单递归建树 | [MenuServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/MenuServiceImpl.java) | 父节点ID集合与菜单ID集合差集求根节点，`buildMenuTree` / `buildRoutes` 递归组装 |
| 字典变更 SSE 通知 | [DictController.java](../../wms/src/main/java/com/wms/system/controller/DictController.java) → `com.wms.message.service.SseService.sendDictChange(dictCode)` | 字典/字典项新增、修改、删除后推送变更事件，前端实时刷新选项 |
| 配置启动全量加载 | [ConfigServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/ConfigServiceImpl.java) `@PostConstruct init()` | 启动后 `refreshCache()`：清空 Redis Hash `system:config`，全表查 `sys_config` 写入 |
| 权限缓存 Read-Through | [RoleMenuServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/RoleMenuServiceImpl.java) | Redis Hash `system:role:perms`（field=角色编码，value=权限集合）；未命中回源 DB（空集也写，防穿透） |
| 角色数据权限合并 | [RoleServiceImpl.getRoleDataScopes](../../wms/src/main/java/com/wms/system/service/impl/RoleServiceImpl.java) | 按角色编码查 data_scope，CUSTOM(5) 再查 sys_role_dept，构造 `RoleDataScope` 列表供框架数据权限并集使用 |

---

## 4. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/system/...`；以下"引用的主要包"为该文件 import 中真实出现的部分；XML 位于 `wms/src/main/resources/mapper/system/`。

### 4.1 控制器层（controller）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [UserController.java](../../wms/src/main/java/com/wms/system/controller/UserController.java) | 用户接口：列表/增删改/状态/重置密码/当前用户信息/个人中心/改密/手机邮箱绑定解绑/导入导出/模板下载 | `cn.idev.excel.EasyExcel/ExcelWriter`、`com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum/StatusEnum`、`com.wms.common.result.PageResult/Result/ExcelResult`、`com.wms.common.util.ExcelUtils`、`com.wms.framework.security.util.SecurityUtils`、`com.wms.framework.security.token.TokenManager`、`com.wms.system.listener.UserImportListener`、`io.swagger.v3.oas.annotations.*`、`org.springframework.security.access.prepost.PreAuthorize` | 权限标识 `sys:user:create/update/delete/import/export/reset-password`；新增与导入加 `@RepeatSubmit` 防重；禁用用户后 `tokenManager.invalidateUserSessions(userId)` 立即踢下线；模板下载用 `EasyExcel.write(...).withTemplate(...)`；**短信/邮箱验证码发送接口已注释下线**（服务内验证码为固定测试值 "123456"） |
| [RoleController.java](../../wms/src/main/java/com/wms/system/controller/RoleController.java) | 角色接口：分页/下拉/增删改/状态/菜单ID集合/分配菜单/自定义部门ID集合 | `com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.model.Option`、`com.wms.common.result.PageResult/Result`、`io.swagger.v3.oas.annotations.*`、`org.springframework.security.access.prepost.PreAuthorize`、`jakarta.validation.Valid` | 权限标识 `sys:role:create/update/delete/assign`；分配菜单 `PUT /{roleId}/menus` 记 `ActionTypeEnum.GRANT` 日志 |
| [MenuController.java](../../wms/src/main/java/com/wms/system/controller/MenuController.java) | 菜单接口：菜单树/下拉/当前用户路由/表单/增删改/显隐 | `com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.model.Option`、`com.wms.common.result.Result`、`io.swagger.v3.oas.annotations.*`、`org.springframework.security.access.prepost.PreAuthorize` | `GET /routes` 返回当前用户 RouteVO 路由树（无权限要求，登录即可）；权限标识 `sys:menu:*` |
| [DeptController.java](../../wms/src/main/java/com/wms/system/controller/DeptController.java) | 部门接口：树/下拉/增删改/表单 | `com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.model.Option`、`com.wms.common.result.Result`、`io.swagger.v3.oas.annotations.*`、`org.springframework.security.access.prepost.PreAuthorize`、`jakarta.validation.Valid` | 权限标识 `sys:dept:create/update/delete`；删除返回 `Result.success()` |
| [DictController.java](../../wms/src/main/java/com/wms/system/controller/DictController.java) | 字典接口：字典/字典项分页、下拉、增删改、表单 | `com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.model.Option`、`com.wms.common.result.PageResult/Result`、`com.wms.message.service.SseService`、`org.springframework.security.access.prepost.PreAuthorize`、`io.swagger.v3.oas.annotations.*` | **所有增删改成功路径均调用 `sseService.sendDictChange(dictCode)`**（删除前先取编码再删，SSE 推送用旧编码）；权限标识 `sys:dict:*` / `sys:dict-item:*` |
| [ConfigController.java](../../wms/src/main/java/com/wms/system/controller/ConfigController.java) | 系统配置接口：分页/增删改/表单/刷新缓存 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.wms.common.annotation.Log`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.result.PageResult/Result`、`io.swagger.v3.oas.annotations.*`、`org.springdoc.core.annotations.ParameterObject`、`org.springframework.security.access.prepost.PreAuthorize` | 权限标识 `sys:config:list/create/update/delete/refresh`；`PUT /refresh` 手动触发 `configService.refreshCache()` |
| [LogController.java](../../wms/src/main/java/com/wms/system/controller/LogController.java) | 日志接口：分页/访问趋势/访问概览/最近登录记录 | `com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.common.annotation.Log`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.result.PageResult/Result`、`com.wms.framework.security.util.SecurityUtils`、`java.time.LocalDate`、`io.swagger.v3.oas.annotations.*` | 趋势/概览/登录记录按当前登录人（SecurityUtils.getUserId()）查询 |

### 4.2 服务层接口（service）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [UserService.java](../../wms/src/main/java/com/wms/system/service/UserService.java) | 用户业务接口 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.baomidou.mybatisplus.extension.service.IService`、`com.wms.framework.security.model.SecurityUser`、`com.wms.common.model.Option`、`com.wms.system.model.form.*/query/vo/entity` | 继承 `IService<SysUser>`；含认证查询（getAuthInfoByUsername/Mobile）、导入导出、个人中心、改密、手机/邮箱绑定解绑等方法 |
| [RoleService.java](../../wms/src/main/java/com/wms/system/service/RoleService.java) | 角色业务接口 | `com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`IService`、`com.wms.framework.security.model.RoleDataScope`、`com.wms.common.model.Option` | 声明数据权限相关：getMaximumDataScope / getRoleDataScopes（多角色并集） |
| [MenuService.java](../../wms/src/main/java/com/wms/system/service/MenuService.java) | 菜单业务接口 | `IService`、`com.wms.common.model.Option`、`com.wms.system.model.form/query/vo` | listMenus / listMenuOptions / saveMenu / listCurrentUserRoutes（含 datasource 重载，实现忽略参数） |
| [DeptService.java](../../wms/src/main/java/com/wms/system/service/DeptService.java) | 部门业务接口 | `IService`、`com.wms.common.model.Option` | getDeptList（树）/ listDeptOptions / saveDept / updateDept / deleteByIds |
| [DictService.java](../../wms/src/main/java/com/wms/system/service/DictService.java) / [DictItemService.java](../../wms/src/main/java/com/wms/system/service/DictItemService.java) | 字典/字典项业务接口 | `Page`、`IService`、`com.wms.common.model.Option` | 字典项增删改、getDictItems（按 dictCode 查启用项排序返回 label/value/tagType） |
| [ConfigService.java](../../wms/src/main/java/com/wms/system/service/ConfigService.java) | 系统配置业务接口 | `IPage`、`IService` | page/save/edit/delete/refreshCache |
| [ISysConfigService.java](../../wms/src/main/java/com/wms/system/service/ISysConfigService.java) | 参数配置查询接口（对外） | 无（纯接口） | 仅声明 `String selectConfigByKey(String configKey)`，供其他模块按 key 读配置 |
| [LogService.java](../../wms/src/main/java/com/wms/system/service/LogService.java) | 日志业务接口 | `Page`、`IService`、`java.time.LocalDate` | getLogPage / getVisitTrend / getVisitStats / getRecentLoginRecords |
| [UserRoleService.java](../../wms/src/main/java/com/wms/system/service/UserRoleService.java) / [RoleMenuService.java](../../wms/src/main/java/com/wms/system/service/RoleMenuService.java) / [RoleDeptService.java](../../wms/src/main/java/com/wms/system/service/RoleDeptService.java) | 关联业务接口 | `IService`、`java.util.List/Set` | 用户-角色差量保存；角色-菜单权限缓存刷新（3 个重载）；角色-部门自定义数据权限 |
| [UserSocialService.java](../../wms/src/main/java/com/wms/system/service/UserSocialService.java) | 第三方账号绑定接口 | `IService`、`com.wms.framework.security.model.SecurityUser`、`com.wms.common.enums.SocialPlatformEnum` | 按平台+openid 查询 / unionid 查询 / 绑定或更新 / 解绑 / 按 openid 取认证信息 / 更新 session_key |

### 4.3 服务实现（service/impl）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [UserServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java) | 用户核心实现 | `cn.hutool.core.collection.CollectionUtil`、`cn.hutool.core.lang.Assert`、`cn.hutool.core.util.StrUtil`、`com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper`、`com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper`、`com.baomidou.mybatisplus.extension.service.impl.ServiceImpl`、`com.wms.common.constant.RedisConstants/SystemConstants`、`com.wms.common.exception.BusinessException`、`com.wms.common.model.Option`、`com.wms.framework.integration.sms.service.SmsService`、`com.wms.framework.integration.mail.service.MailService`、`com.wms.framework.security.model.SecurityUser/RoleDataScope`、`com.wms.framework.security.token.TokenManager`、`com.wms.framework.security.util.SecurityUtils`、`com.wms.system.converter.UserConverter`、`com.wms.system.enums.DictCodeEnum`、`org.springframework.security.crypto.password.PasswordEncoder`、`org.springframework.data.redis.core.StringRedisTemplate`、`org.springframework.transaction.annotation.Transactional` | 详见 [5. 核心实现逻辑](#5-核心实现逻辑)：新增默认密码 `passwordEncoder.encode("123456")`；改密/重置后 `tokenManager.invalidateUserSessions`；短信/邮箱验证码固定 "123456" 且 5 分钟缓存（接口已下线）；导出性别字典翻译 |
| [RoleServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/RoleServiceImpl.java) | 角色核心实现 | `cn.hutool.core.collection.CollectionUtil`、`cn.hutool.core.lang.Assert`、`cn.hutool.core.util.ObjectUtil/StrUtil`、`com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`ServiceImpl`、`com.wms.common.constant.SystemConstants`、`com.wms.common.enums.DataScopeEnum`、`com.wms.common.exception.BusinessException`、`com.wms.framework.security.model.RoleDataScope`、`com.wms.framework.security.token.TokenManager`、`com.wms.framework.security.util.SecurityUtils`、`com.wms.system.converter.RoleConverter`、`com.wms.system.service.RoleDeptService/RoleMenuService/UserRoleService`、`org.springframework.cache.annotation.CacheEvict`、`org.springframework.transaction.annotation.Transactional` | 非 ROOT 用户隐藏超级管理员角色；保存时角色名/编码唯一校验；**角色编码或状态变更→`refreshRolePermsCache`；数据权限或自定义部门变更→失效该角色全部用户会话**；`assignMenusToRole` 加 `@CacheEvict(cacheNames="menu", key="'routes'")` |
| [MenuServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/MenuServiceImpl.java) | 菜单核心实现 | `cn.hutool.core.collection.CollectionUtil`、`cn.hutool.core.lang.Assert`、`cn.hutool.core.util.ObjectUtil/StrUtil`、`LambdaQueryWrapper/LambdaUpdateWrapper`、`ServiceImpl`、`com.wms.framework.security.util.SecurityUtils`、`com.wms.common.constant.SystemConstants`、`com.wms.common.enums.StatusEnum`、`com.wms.common.model.KeyValue/Option`、`com.wms.system.converter.MenuConverter`、`com.wms.system.enums.MenuTypeEnum`、`com.wms.system.model.vo.RouteVO`、`org.apache.commons.lang3.StringUtils`、`org.springframework.cache.annotation.CacheEvict` | 详见 [5. 核心实现逻辑](#5-核心实现逻辑)：路由构建 RouteVO（外链新标签/iframe 内嵌、keepAlive、alwaysShow、params）；tree_path 递归生成与子菜单级联更新；删除菜单按 `CONCAT(',',tree_path,',') LIKE` 级联删子树；菜单增删改 `@CacheEvict(cacheNames="menu")` |
| [DeptServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/DeptServiceImpl.java) | 部门核心实现 | `cn.hutool.core.collection.CollectionUtil`、`cn.hutool.core.lang.Assert`、`cn.hutool.core.util.StrUtil`、`LambdaQueryWrapper/LambdaUpdateWrapper`、`ServiceImpl`、`com.wms.framework.security.util.SecurityUtils`、`com.wms.common.constant.SystemConstants`、`com.wms.common.enums.StatusEnum`、`com.wms.common.model.Option`、`com.wms.system.converter.DeptConverter` | 树构建：父ID集合与部门ID集合差集求根；新增/修改生成 tree_path；修改父部门禁止选自己或子孙（FIND_IN_SET 查子树）；删除按 tree_path 级联逻辑删除（手动 set isDeleted=1） |
| [DictServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/DictServiceImpl.java) | 字典实现 | `cn.hutool.core.lang.Assert`、`LambdaQueryWrapper`、`Page`、`ServiceImpl`、`com.wms.common.exception.BusinessException`、`com.wms.common.model.Option`、`com.wms.system.converter.DictConverter`、`com.wms.system.service.DictItemService`、`org.springframework.transaction.annotation.Transactional` | dict_code 唯一校验；修改字典时级联更新字典项 dict_code；删除字典前**先取编码再删，再按 dict_code 级联删字典项**（避免孤儿数据） |
| [DictItemServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/DictItemServiceImpl.java) | 字典项实现 | `LambdaQueryWrapper`、`Page`、`ServiceImpl`、`com.wms.system.converter.DictItemConverter` | getDictItems 只返回启用项（status=1，按 sort 排序） |
| [ConfigServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/ConfigServiceImpl.java) | 系统配置实现 | `LambdaQueryWrapper`、`IPage`、`Page`、`ServiceImpl`、`com.wms.common.constant.RedisConstants`、`com.wms.system.converter.ConfigConverter`、`com.wms.framework.security.util.SecurityUtils`、`jakarta.annotation.PostConstruct`、`org.springframework.data.redis.core.RedisTemplate`、`org.apache.commons.lang3.StringUtils`、`org.springframework.util.Assert` | `@PostConstruct init()` 启动全量加载；`selectConfigByKey` 走 Redis Hash `system:config` 读取；`refreshCache` 先 delete 再 `opsForHash().putAll`；新增/修改配置键唯一校验 |
| [LogServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/LogServiceImpl.java) | 日志实现（PV/UV 统计） | `Page`、`ServiceImpl`、`com.wms.system.mapper.LogMapper`、`com.wms.system.model.dto.VisitCountDTO`、`com.wms.system.model.vo.VisitOverviewVO/VisitTrendVO/LoginRecordVO/LogPageVO`、`com.wms.system.model.query.LogQuery`、`java.time.LocalDate`、`java.util.stream.Collectors` | getVisitTrend：补全日期序列，PV（COUNT）与 UV（COUNT DISTINCT ip）按日 Map 对齐成数组；getVisitStats：今日/累计/环比增长率由 XML SQL 计算 |
| [UserRoleServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/UserRoleServiceImpl.java) | 用户-角色关联实现 | `cn.hutool.core.collection.CollectionUtil`、`LambdaQueryWrapper`、`ServiceImpl`、`com.wms.framework.security.token.TokenManager` | `saveUserRoles` 差量更新（新旧 Set 求差，新增 saveBatch、删除 remove）；**角色变更时 `tokenManager.invalidateUserSessions(userId)`** |
| [RoleMenuServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/RoleMenuServiceImpl.java) | 角色-菜单关联 + 权限缓存 | `cn.hutool.core.collection.CollectionUtil`、`ServiceImpl`、`com.wms.common.constant.RedisConstants`、`com.wms.system.model.dto.RolePermsDTO`、`com.wms.system.mapper.RoleMenuMapper`、`org.springframework.data.redis.core.RedisTemplate`、`lombok.extern.slf4j.Slf4j` | 3 个 `refreshRolePermsCache` 重载（全量/单角色/编码变更）；`getRolePermsByRoleCodes` Read-Through：`multiGet` 批量读 → 未命中回源 `listRolePerms` → 空集也写缓存防穿透 |
| [RoleDeptServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/RoleDeptServiceImpl.java) | 角色-部门关联实现 | `cn.hutool.core.collection.CollectionUtil`、`LambdaQueryWrapper`、`ServiceImpl`、`org.springframework.transaction.annotation.Transactional` | saveRoleDepts：先删后批插；getDeptIdsByRoleId / getDeptIdsByRoleCodes |
| [UserSocialServiceImpl.java](../../wms/src/main/java/com/wms/system/service/impl/UserSocialServiceImpl.java) | 第三方账号绑定实现 | `cn.hutool.core.util.StrUtil`、`LambdaQueryWrapper`、`ServiceImpl`、`com.wms.framework.security.model.SecurityUser`、`com.wms.common.enums.SocialPlatformEnum`、`org.springframework.transaction.annotation.Transactional` | bindOrUpdate 存在即更新、不存在新建（verified=1）；getAuthInfoByOpenid 经 user_id 反查认证信息 |

### 4.4 安全适配器（security/adapter）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [UserAuthenticationAdapter.java](../../wms/src/main/java/com/wms/system/security/adapter/UserAuthenticationAdapter.java) | 认证信息查询适配器 | `com.wms.common.enums.SocialPlatformEnum`、`com.wms.framework.security.model.SecurityUser`、`com.wms.framework.security.port.UserAuthenticationPort`、`com.wms.system.service.UserService/UserSocialService`、`org.springframework.stereotype.Component` | 实现 framework 层 `UserAuthenticationPort` 端口，委托 system 层按用户名/手机号/openid 查认证凭证（供 auth 模块登录复用） |
| [PermissionAdapter.java](../../wms/src/main/java/com/wms/system/security/adapter/PermissionAdapter.java) | 权限查询适配器 | `com.wms.framework.security.port.PermissionPort`、`com.wms.system.service.RoleMenuService`、`org.springframework.stereotype.Component` | 实现 `PermissionPort.getRolePerms(roleCodes)`，委托 `RoleMenuService.getRolePermsByRoleCodes`（带 Redis 缓存） |

> **放行配置**：安全放行（permitAll/ignore）不在本模块，而由使用方 [SecurityConfig.java](../../wms/src/main/java/com/wms/auth/security/config/SecurityConfig.java) 依据 `security.ignore-urls` / `security.unsecured-urls` 配置加载（见 auth 模块文档）。

### 4.5 持久层（mapper + XML）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [UserMapper.java](../../wms/src/main/java/com/wms/system/mapper/UserMapper.java) | 用户持久层 | `BaseMapper`、`Page`、`com.wms.common.annotation.DataPermission`、`com.wms.framework.security.model.SecurityUser`、`com.wms.system.model.vo.UserPageVO/UserExportVO/UserProfileVO`、`org.apache.ibatis.annotations.*` | `getUserPage`/`listExportUsers` 加 `@DataPermission(deptAlias="u", userAlias="u")`；认证查询 2 个（username/mobile）+ default 别名方法 |
| [UserMapper.xml](../../wms/src/main/resources/mapper/system/UserMapper.xml) | 用户 SQL | MyBatis XML | getUserPage：LEFT JOIN sys_dept/sys_user_role/sys_role，`STRING_AGG(r.name,',')` 拼角色名，`NOT EXISTS` 屏蔽 ROOT 用户，deptId 按 tree_path 包含匹配，创建时间区间 bind 拼接；排序 `u.${sortBy}` 经 `@ValidField` 白名单收敛；getUserFormData 用 `<collection select="UserRoleMapper.listRoleIdsByUserId">` 嵌套查 roleIds；AuthCredentialsMap 收集角色编码 Set |
| [RoleMapper.java](../../wms/src/main/java/com/wms/system/mapper/RoleMapper.java) | 角色持久层 | `BaseMapper`、`org.apache.ibatis.annotations.*` | `getMaximumDataScope(roles)`、`getRoleDataScopeList(roleCodes)`（返回 `[{code,data_scope}]`） |
| [MenuMapper.java](../../wms/src/main/java/com/wms/system/mapper/MenuMapper.java) | 菜单持久层 | `BaseMapper` | `getMenusByRoleCodes(roleCodes)` 按角色查菜单列表 |
| [DeptMapper.java](../../wms/src/main/java/com/wms/system/mapper/DeptMapper.java) | 部门持久层 | `BaseMapper`、`Wrapper`、`com.wms.common.annotation.DataPermission`、`Constants` | 覆写 `selectList` 加 `@DataPermission(deptIdColumnName="id")`（部门树按数据权限过滤） |
| [DictMapper.java](../../wms/src/main/java/com/wms/system/mapper/DictMapper.java) / [DictItemMapper.java](../../wms/src/main/java/com/wms/system/mapper/DictItemMapper.java) | 字典/字典项持久层 | `BaseMapper`、`Page` | 各自一个分页查询 getDictPage / getDictItemPage |
| [ConfigMapper.java](../../wms/src/main/java/com/wms/system/mapper/ConfigMapper.java) | 配置持久层 | `BaseMapper` | 仅继承，无自定义 SQL |
| [LogMapper.java](../../wms/src/main/java/com/wms/system/mapper/LogMapper.java) | 日志持久层 | `BaseMapper`、`Page`、`com.wms.system.model.dto.VisitCountDTO`、`com.wms.system.model.vo.*` | getLogPage + 4 个统计方法（getPvCounts/getIpCounts/getPvStats/getUvStats）+ getRecentLoginRecords；SQL 见 [LogMapper.xml](../../wms/src/main/resources/mapper/system/LogMapper.xml)（`COUNT(DISTINCT ip)` 算 UV，环比增长率 ROUND 2 位） |
| [UserRoleMapper.java](../../wms/src/main/java/com/wms/system/mapper/UserRoleMapper.java) | 用户-角色持久层 | `BaseMapper` | `countUsersByRoleId`（角色删除前校验）、`listUserIdsByRoleId`（会话失效用）、`listRoleIdsByUserId`（UserMapper.xml 嵌套引用） |
| [RoleMenuMapper.java](../../wms/src/main/java/com/wms/system/mapper/RoleMenuMapper.java) | 角色-菜单持久层 | `BaseMapper`、`com.wms.system.model.dto.RolePermsDTO` | `listMenuIdsByRoleId`、`getRolePermsList(roleCode)`、`listRolePerms(roles)` |
| [RoleDeptMapper.java](../../wms/src/main/java/com/wms/system/mapper/RoleDeptMapper.java) | 角色-部门持久层 | `BaseMapper`、`org.apache.ibatis.annotations.Param` | `getDeptIdsByRoleId`、`getDeptIdsByRoleCodes` |
| [UserSocialMapper.java](../../wms/src/main/java/com/wms/system/mapper/UserSocialMapper.java) | 第三方绑定持久层 | `BaseMapper`、`com.wms.framework.security.model.SecurityUser` | `getAuthInfoByUserId(userId)` |

### 4.6 实体层（model/entity）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [SysUser.java](../../wms/src/main/java/com/wms/system/model/entity/SysUser.java) | 用户实体 | `com.baomidou.mybatisplus.annotation.TableName`、`com.wms.common.base.BaseEntity`、`lombok.Data/EqualsAndHashCode` | `@TableName("sys_user")`，继承 BaseEntity（id/createTime/updateTime），补充 createBy/updateBy/isDeleted |
| [Role.java](../../wms/src/main/java/com/wms/system/model/entity/Role.java) / [Dept.java](../../wms/src/main/java/com/wms/system/model/entity/Dept.java) / [Dict.java](../../wms/src/main/java/com/wms/system/model/entity/Dict.java) / [Config.java](../../wms/src/main/java/com/wms/system/model/entity/Config.java) | 角色/部门/字典/配置实体 | 同 SysUser（BaseEntity + `com.fasterxml.jackson.annotation.JsonInclude`） | 均继承 BaseEntity，字段与建表一一对应 |
| [Menu.java](../../wms/src/main/java/com/wms/system/model/entity/Menu.java) | 菜单实体 | `com.baomidou.mybatisplus.annotation.*`（TableName/TableField/FieldStrategy）、`com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler`、`com.wms.common.base.BaseEntity` | `@TableName(value="sys_menu", autoResultMap=true)`；`params` 用 `@TableField(updateStrategy=FieldStrategy.ALWAYS, typeHandler=JacksonTypeHandler.class)` 映射 jsonb（**改 null 也会更新**） |
| [DictItem.java](../../wms/src/main/java/com/wms/system/model/entity/DictItem.java) | 字典项实体 | `TableName`、`BaseEntity` | 继承 BaseEntity + createBy/updateBy（表无 is_deleted） |
| [SysLog.java](../../wms/src/main/java/com/wms/system/model/entity/SysLog.java) | 日志实体 | `com.baomidou.mybatisplus.annotation.*`（TableId/IdType/TableField）、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`lombok.Data` | **不继承 BaseEntity**；module/actionType 字段直接用枚举类型（`@EnumValue` 映射数字）；createTime 即操作时间 |
| [UserRole.java](../../wms/src/main/java/com/wms/system/model/entity/UserRole.java) / [RoleMenu.java](../../wms/src/main/java/com/wms/system/model/entity/RoleMenu.java) / [RoleDept.java](../../wms/src/main/java/com/wms/system/model/entity/RoleDept.java) | 关联实体 | `TableName`、`lombok.AllArgsConstructor/NoArgsConstructor/Data` | 仅 userId/roleId（或 roleId/menuId、roleId/deptId）组合字段，无主键 |
| [UserSocial.java](../../wms/src/main/java/com/wms/system/model/entity/UserSocial.java) | 第三方绑定实体 | `TableName`、`TableId/IdType`、`com.wms.common.enums.SocialPlatformEnum`、`lombok.Getter/Setter` | platform 用 `SocialPlatformEnum` 枚举映射；自带 createTime/updateTime（不继承 BaseEntity） |

### 4.7 转换器（converter，MapStruct）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [UserConverter.java](../../wms/src/main/java/com/wms/system/converter/UserConverter.java) | 用户转换器 | `com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.common.model.Option`、`org.mapstruct.Mapper/InheritInverseConfiguration/Mapping/Mappings` | `@Mapper(componentModel="spring")`；`toForm` ↔ `toEntity` 用 `@InheritInverseConfiguration` 双向复用；`toCurrentUserVo` 将 id 映射为 userId；UserImportForm/UserProfileForm 均可转实体 |
| [RoleConverter.java](../../wms/src/main/java/com/wms/system/converter/RoleConverter.java) | 角色转换器 | `Page`、`Option`、`org.mapstruct.*` | `@Mapping(expression="java(...DataScopeEnum.getByValue(...).getLabel())")` 编译期表达式补 dataScopeLabel |
| [MenuConverter.java](../../wms/src/main/java/com/wms/system/converter/MenuConverter.java) | 菜单转换器 | `org.mapstruct.Mapper/Mapping` | toForm/toEntity 均 `@Mapping(target="params", ignore=true)`（params 由服务层手工转换 KeyValue↔Map） |
| [DeptConverter.java](../../wms/src/main/java/com/wms/system/converter/DeptConverter.java) / [DictConverter.java](../../wms/src/main/java/com/wms/system/converter/DictConverter.java) / [DictItemConverter.java](../../wms/src/main/java/com/wms/system/converter/DictItemConverter.java) / [ConfigConverter.java](../../wms/src/main/java/com/wms/system/converter/ConfigConverter.java) | 部门/字典/字典项/配置转换器 | `Page`、`Option`、`org.mapstruct.Mapper` | 均为简单 `@Mapper(componentModel="spring")` 接口，含 toForm/toEntity/toPageVo 等 |

### 4.8 导入监听器 / 任务 / 枚举

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [UserImportListener.java](../../wms/src/main/java/com/wms/system/listener/UserImportListener.java) | 用户导入监听器 | `cn.hutool.core.convert.Convert`、`cn.hutool.core.lang.Validator`、`cn.hutool.extra.spring.SpringUtil`、`cn.hutool.json.JSONUtil`、`cn.idev.excel.context.AnalysisContext`、`cn.idev.excel.event.AnalysisEventListener`、`LambdaQueryWrapper`、`com.wms.common.constant.SystemConstants`、`com.wms.common.enums.StatusEnum`、`com.wms.common.result.ExcelResult`、`com.wms.system.converter.UserConverter`、`com.wms.system.enums.DictCodeEnum`、`com.wms.system.service.*`、`org.springframework.security.crypto.password.PasswordEncoder` | 详见 [5. 核心实现逻辑](#5-核心实现逻辑)；构造器 `SpringUtil.getBean` 预载角色/部门/性别字典；invoke 逐行校验失败计入 `ExcelResult.messageList`，不中断 |
| [XxlJobSampleHandler.java](../../wms/src/main/java/com/wms/system/handler/XxlJobSampleHandler.java) | XXL-Job 测试示例 | `com.xxl.job.core.handler.annotation.XxlJob`、`lombok.extern.slf4j.Slf4j`、`org.springframework.stereotype.Component` | `@XxlJob("demoJobHandler")` Bean 模式，仅打日志（占位示例） |
| [MenuTypeEnum.java](../../wms/src/main/java/com/wms/system/enums/MenuTypeEnum.java) | 菜单类型枚举 | `com.baomidou.mybatisplus.annotation.EnumValue`、`com.wms.common.base.IBaseEnum`、`lombok.Getter` | C-目录/M-菜单/E-外链/B-按钮，`@EnumValue` 存 char |
| [DictCodeEnum.java](../../wms/src/main/java/com/wms/system/enums/DictCodeEnum.java) | 字典编码枚举 | `com.wms.common.base.IBaseEnum`、`lombok.Getter` | 当前仅 GENDER("gender","性别")，供导入性别翻译使用 |

### 4.9 传输对象（model/form、model/query、model/vo、model/dto）

**form（13 个）**：`UserForm`（jakarta.validation + hibernate Range）、`UserImportForm`（`cn.idev.excel.annotation.ExcelProperty` 表头映射）、`UserProfileForm`、`PasswordUpdateForm`、`PasswordVerifyForm`、`MobileUpdateForm`/`EmailUpdateForm`（@Pattern/@Email 校验）、`RoleForm`（含 deptIds 自定义数据权限）、`MenuForm`（`com.wms.common.model.KeyValue` 路由参数列表）、`DeptForm`、`DictForm`、`DictItemForm`、`ConfigForm`（@NotBlank）。

**query（8 个）**：均继承 `com.wms.common.base.BaseQuery`（pageNum/pageSize/sortBy/order，`@ValidField` 白名单校验）；`UserQuery`（keywords/status/deptId/roleIds/createTime/isRoot），`RoleQuery`/`LogQuery`（关键字+时间范围），`DictQuery`/`ConfigQuery`/`DictItemQuery`（keywords），`MenuQuery`/`DeptQuery`（keywords/status，不继承 BaseQuery）。

**vo（16 个）**：`CurrentUserVO`（userId/roles/roleNames/perms）、`UserPageVO`（deptName/roleNames）、`UserExportVO`（`@ExcelProperty`/`@ColumnWidth`/`@DateTimeFormat` 导出注解）、`UserProfileVO`、`RolePageVO`（dataScopeLabel）、`MenuVO`（children 递归）、`RouteVO`（**前端路由 VO**，内置 Meta：title/icon/hidden/keepAlive/alwaysShow/externalUrl/params，`@JsonInclude(NON_EMPTY)`）、`DeptVO`、`DictPageVO`、`DictItemPageVO`、`DictItemOptionVO`（label/value/tagType）、`ConfigVO`（`@Builder`）、`LogPageVO`（module/actionType 枚举 + region）、`LoginRecordVO`、`VisitTrendVO`（dates/pvList/uvList）、`VisitOverviewVO`（今日/累计/增长率 BigDecimal）。

**dto（2 个）**：`RolePermsDTO`（roleCode + perms Set）、`VisitCountDTO`（date + count）。

---

## 5. 核心实现逻辑

### 5.1 用户导入导出流程

**导入**（POST `/api/v1/users/import`，权限 `sys:user:import`）：

```
Excel 上传 ─► new UserImportListener() ─► ExcelUtils.importExcel(stream, UserImportForm.class, listener)
                │ 构造器：SpringUtil 预载 roleList / deptList / genderList（只查一次）
                ▼
         invoke(行) ── 逐行校验：
                    │  username 非空 且 库中不重复
                    │  nickname 非空；mobile 非空 且 Validator.isMobile 合法
                    ├─ 通过 ─► toEntity → 密码 BCrypt(默认 123456)
                    │         性别 label→value（genderList 翻译）
                    │         角色 roleCodes→roleIds（编码或名称匹配 roleList）
                    │         部门 deptCode→deptId（编码或名称匹配 deptList）
                    │         save 用户 → saveBatch 用户角色 → validCount++
                    └─ 失败 ─► invalidCount++，errorMsg 记录到 ExcelResult.messageList（不中断后续行）
         doAfterAllAnalysed ── 仅打日志；Controller 返回 listener.getExcelResult()（有效/无效行数 + 错误明细）
```

**导出**（GET `/api/v1/users/export`，权限 `sys:user:export`）：

```
UserQuery(isRoot 由 SecurityUtils.isRoot 注入) ─► UserMapper.listExportUsers
    ─► 性别值 → genderMap（字典 gender 的 value→label 翻译）→ 替换为中文
    ─► EasyExcel.write(response.getOutputStream(), UserExportVO.class).sheet("用户列表").doWrite(list)
```

> 导入/导出均受 `@DataPermission` 数据权限约束；导出性别翻译用 `DictCodeEnum.GENDER`。

### 5.2 菜单树构建与前端路由生成（RouteVO）

**菜单树（管理端表格）**：`listMenus` 一次性查出全部菜单（按 sort 升序）→ 父节点ID集合与菜单ID集合差集求**根节点**（不取顶级 0，因关键字筛选时顶级可能被过滤）→ `buildMenuTree` 递归组装 `MenuVO.children`。

**前端路由（登录后 /menus/routes）**：`listCurrentUserRoutes`：

```
SecurityUtils.getRoles() 为空 ──► 返回空列表
├─ isRoot（ROOT 角色）：查全部非按钮菜单
└─ 普通用户：MenuMapper.getMenusByRoleCodes(roleCodes)（按角色关联过滤）
       └─ 双重保障：识别 route_path="/support" 且 parent_id=0 的"平台管理"目录，
          按 tree_path 前缀（0,{platformId} 或 0,{platformId},...）过滤其子菜单
        ─► buildRoutes(0L, menuList) 递归 → toRouteVo(menu)
```

**toRouteVo 关键规则**：
- **外链（E）**：`component=iframe` 表示系统内嵌（path 用内部 route_path、component 置 "iframe"、externalUrl 放 Meta）；否则新标签页（path 直接用 externalUrl、component 置 null、**不设 name**，前端 filterRoutes 过滤）；
- **路由名称**：routeName 为空且非外链时用 `StringUtils.capitalize(StrUtil.toCamelCase(path,'-'))` 自动生成；
- **Meta 组装**：title=菜单名、icon、hidden=visible==0、keepAlive（仅菜单/内嵌外链且 keep_alive=1）、alwaysShow、params（jsonb `params` 经 `JacksonTypeHandler` 读出 Map，value 统一转 String）；
- **jsonb 写**：`saveMenu` 把表单 `List<KeyValue>` 转 `Map` 存入 `Menu.params`；树路径 `tree_path` 保存后递归更新全部子菜单。

### 5.3 角色权限变更后的缓存 / 会话失效策略

```
角色保存 saveRole / 状态 updateRoleStatus / 删除 deleteRoles / 分配菜单 assignMenusToRole
   │
   ├─ 权限标识缓存（Redis Hash system:role:perms）
   │     roleMenuService.refreshRolePermsCache(roleCode)：
   │       删除 hash field → getRolePermsList 回源 DB → 写回（编码变更时同时删新旧两个 field）
   │     菜单增删改 saveMenu/deleteMenu/updateMenuVisible：refreshRolePermsCache() 全量刷新 + @CacheEvict("menu")
   │
   ├─ 路由缓存：assignMenusToRole / saveMenu / deleteMenu 均标注
   │     @CacheEvict(cacheNames="menu", key="'routes'") 使 /menus/routes 路由树失效
   │
   └─ 会话失效（JWT tokenVersion 递增，tokenManager.invalidateUserSessions）
         角色编码/状态变更 → 不踢会话（仅刷新缓存）
         数据权限 dataScope 变更 或 自定义部门 deptIds 变更 → 踢该角色全部用户
         角色停用（status=0）→ 踢该角色全部用户
         用户角色变更（saveUserRoles 差量非空）→ 踢该用户
         用户改密/重置密码/禁用 → 踢该用户（TokenManager 使旧 token 立即失效）
```

> 数据权限并集：`RoleService.getRoleDataScopes` 将用户全部角色的 data_scope 与自定义部门列表组装为 `List<RoleDataScope>`，由框架数据权限切面按**并集策略**合并生效。

### 5.4 字典变更 SSE 通知

```
DictController 增删改（字典 saveDict/updateDict/deleteDictByIds，
                  字典项 saveDictItem/updateDictItem/deleteDictItemByIds）
        └─ 操作成功 ─► sseService.sendDictChange(dictCode)
                            └─（com.wms.message.service.SseService，见 message 模块）
                              向订阅该字典编码的前端 SSE 连接推送变更事件
                              ─► 前端收到后重新拉取该字典选项，实现字典实时生效
```

> 删除字典时**先 `getDictCodesByIds` 取编码再删除**，SSE 推送用旧编码，保证通知事件能准确指向已删除的字典。

### 5.5 配置缓存（ConfigService）

```
启动 ─► @PostConstruct init() ─► refreshCache()
         │  1. redisTemplate.delete(system:config)
         │  2. 全表查 sys_config → 按 configKey → configValue 转 Map
         └─ 3. opsForHash().putAll(system:config, map)
运行 ─► selectConfigByKey(key)：直接读 Redis Hash 对应 field（不落库）
管理 ─► 增删改走 DB（key 唯一校验）+ 手动 PUT /configs/refresh 触发 refreshCache()
```

### 5.6 操作日志与 PV/UV 统计

- **落库**：`@Log(module, value)` 注解由框架日志切面（见 framework 模块）在请求结束后写入 `sys_log`（含 IP 归属地 province/city、UA 解析 device/os/browser、耗时 execution_time）；
- **PV/UV**：[LogMapper.xml](../../wms/src/main/resources/mapper/system/LogMapper.xml) 按 `create_time` 分组 `COUNT(1)`（PV）与 `COUNT(DISTINCT ip)`（UV）；`getVisitTrend` 在服务层**补全日期序列**，缺数据日补 0；
- **环比增长率**：`getPvStats/getUvStats` 用昨日同时刻口径（`create_time::TIME <= CURRENT_TIMESTAMP::TIME`）对比今日，`ROUND(...,2)` 百分比。

---

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| MyBatis-Plus | `BaseMapper`/`ServiceImpl` 通用 CRUD、`LambdaQueryWrapper` 条件构造、`Page` 分页插件、`JacksonTypeHandler` 处理 jsonb、全局逻辑删除（`logic-delete-field: isDeleted`） |
| MapStruct | Entity/Form/VO 编译期转换（`@Mapper(componentModel="spring")`、`@InheritInverseConfiguration`、`@Mapping(expression)` 补枚举描述） |
| EasyExcel（fastexcel `cn.idev.excel`） | 用户导入（`AnalysisEventListener` 监听器 + `ExcelProperty` 表头映射）、导出（模板下载 `withTemplate`、`doWrite`） |
| Spring Security | 接口级权限 `@PreAuthorize("@ss.hasPerm('sys:xxx:*')")`；认证数据源经 `UserAuthenticationPort` 适配器提供 |
| Redis（RedisTemplate） | 权限缓存 Hash `system:role:perms`（Read-Through）、系统配置 Hash `system:config`、短信/邮箱验证码、路由缓存 `@CacheEvict("menu")` |
| JWT TokenManager | 权限/角色/密码变更后的会话失效（`invalidateUserSessions` 递增 tokenVersion） |
| Hutool | `Assert` 断言、`StrUtil/ObjectUtil/CollectionUtil`、`SpringUtil`（监听器取 Bean）、`Validator`（手机号校验）、`Convert` |
| `@DataPermission`（jsqlparser） | 用户分页/导出、部门列表的数据权限 SQL 改写 |
| SSE（message 模块 SseService） | 字典变更实时推送（`sendDictChange`） |
| XXL-Job | `@XxlJob("demoJobHandler")` Bean 模式示例 |
| Knife4j / springdoc | OpenAPI 注解（`@Tag`/`@Operation`/`@Schema`） |
| BCrypt（PasswordEncoder） | 用户密码加密存储（默认密码 123456）与校验 |
