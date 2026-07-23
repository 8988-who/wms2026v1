# WMS 仓储管理系统 - 完整项目结构

> 文件版本：v1.0
> 最后更新：2026-07-21

---

## 一、项目根目录

```
e:\wms20260712/
├── develop/                              # 开发文档与工具
│   ├── WMS系统架构与功能说明.md
│   ├── WMS系统完整项目结构.md              ← 本文档
│   ├── postgresql-migration-db-only-scripts.sql
│   ├── postgresql-migration-problems-checklist.md
│   ├── mysql-to-postgresql-migration.md
│   ├── postgresql-column-migration-evaluation.md
│   ├── 新增数据主键冲突重复键违反唯一约束问题排查与修复.md
│   ├── WMS系统A_S主备模式双机热备实施方案.md
│   └── WMS系统双机热备软件层面准备清单.md
│
├── wms/                                  # 后端项目 (Spring Boot)
│   ├── .gitignore
│   ├── Dockerfile
│   ├── LICENSE
│   ├── README.en.md
│   ├── README.md
│   ├── pom.xml
│   ├── docker/
│   ├── docs/
│   ├── sql/
│   └── src/
│
└── wmsui/                                # 前端项目 (Vue 3)
    ├── .editorconfig
    ├── .env.development
    ├── .env.production
    ├── index.html
    ├── package.json
    ├── vite.config.ts
    ├── .husky/
    ├── .vscode/
    ├── mock/
    ├── public/
    ├── types/
    └── src/
```

---

## 二、后端项目结构 (Spring Boot)

```
wms/
├── .gitignore
├── Dockerfile
├── LICENSE
├── README.en.md
├── README.md
├── pom.xml                               # Maven 项目配置
│
├── docker/                               # Docker 部署配置
│   ├── docker-compose.yml
│   ├── run.md
│   ├── minio/
│   │   └── README.md
│   ├── mysql/
│   │   └── conf/
│   │       └── my.cnf
│   ├── redis/
│   │   └── config/
│   │       └── redis.conf
│   └── xxljob/
│       └── README.md
│
├── docs/                                 # 项目文档图片
│   ├── README.md
│   └── images/
│       ├── logo/
│       ├── preview/
│       └── qrcode/
│
├── sql/
│   └── admin-postgresql.sql              # PostgreSQL 建表+种子数据（仅此一个SQL文件）
│
└── src/
    ├── main/
    │   ├── java/com/youlai/boot/
    │   │   ├── YouLaiBootApplication.java    # Spring Boot 启动类
    │   │   │
    │   │   ├── auth/                         # ===== 认证模块 =====
    │   │   │   ├── controller/
    │   │   │   │   └── AuthController.java       # 登录/登出/Token刷新
    │   │   │   ├── model/
    │   │   │   │   ├── form/
    │   │   │   │   │   └── LoginForm.java
    │   │   │   │   └── vo/                       # （无独立VO）
    │   │   │   ├── security/
    │   │   │   │   ├── config/
    │   │   │   │   │   └── SecurityConfig.java
    │   │   │   │   ├── exception/
    │   │   │   │   ├── filter/
    │   │   │   │   ├── handler/
    │   │   │   │   ├── model/
    │   │   │   │   └── provider/
    │   │   │   └── service/
    │   │   │       ├── AuthService.java
    │   │   │       └── impl/
    │   │   │           └── AuthServiceImpl.java
    │   │   │
    │   │   ├── system/                       # ===== 系统管理模块 =====
    │   │   │   ├── controller/
    │   │   │   │   ├── UserController.java      # 用户管理
    │   │   │   │   ├── RoleController.java      # 角色管理
    │   │   │   │   ├── MenuController.java      # 菜单管理
    │   │   │   │   ├── DeptController.java      # 部门管理
    │   │   │   │   ├── DictController.java      # 字典管理
    │   │   │   │   ├── ConfigController.java    # 系统配置
    │   │   │   │   └── LogController.java       # 操作日志
    │   │   │   ├── converter/                      # MapStruct 对象转换
    │   │   │   │   ├── UserConverter.java              # 用户实体转换
    │   │   │   │   ├── RoleConverter.java              # 角色实体转换
    │   │   │   │   ├── MenuConverter.java              # 菜单实体转换
    │   │   │   │   ├── DeptConverter.java              # 部门实体转换
    │   │   │   │   ├── DictConverter.java              # 字典实体转换
    │   │   │   │   ├── DictItemConverter.java          # 字典项实体转换
    │   │   │   │   ├── ConfigConverter.java            # 配置实体转换
    │   │   │   ├── enums/                              # 系统业务枚举
    │   │   │   │   ├── DictCodeEnum.java               # 字典编码枚举
    │   │   │   │   └── MenuTypeEnum.java               # 菜单类型枚举（目录/菜单/按钮）
    │   │   │   ├── handler/
    │   │   │   │   └── XxlJobSampleHandler.java
    │   │   │   ├── listener/
    │   │   │   │   └── UserImportListener.java     # EasyExcel 导入监听器
    │   │   │   ├── mapper/                             # MyBatis-Plus Mapper
    │   │   │   │   ├── UserMapper.java                 # 用户
    │   │   │   │   ├── RoleMapper.java                 # 角色
    │   │   │   │   ├── RoleMenuMapper.java             # 角色-菜单关联
    │   │   │   │   ├── RoleDeptMapper.java             # 角色-部门关联（数据权限）
    │   │   │   │   ├── MenuMapper.java                 # 菜单
    │   │   │   │   ├── DeptMapper.java                 # 部门
    │   │   │   │   ├── DictMapper.java                 # 字典
    │   │   │   │   ├── DictItemMapper.java             # 字典项
    │   │   │   │   ├── ConfigMapper.java               # 系统配置
    │   │   │   │   ├── LogMapper.java                  # 操作日志
    │   │   │   │   ├── UserRoleMapper.java             # 用户-角色关联
    │   │   │   │   └── UserSocialMapper.java           # 第三方账号绑定
    │   │   │   ├── model/
    │   │   │   │   ├── dto/                             # 数据传输对象
    │   │   │   │   │   ├── RolePermsDTO.java            # 角色权限标识集合
    │   │   │   │   │   └── VisitCountDTO.java           # 访问统计数据
    │   │   │   │   ├── entity/                          # 数据库实体
    │   │   │   │   │   ├── SysUser.java                 # 系统用户
    │   │   │   │   │   ├── Role.java                    # 角色
    │   │   │   │   │   ├── RoleMenu.java                # 角色菜单关联
    │   │   │   │   │   ├── RoleDept.java                # 角色部门关联（数据权限范围）
    │   │   │   │   │   ├── Menu.java                    # 菜单/权限
    │   │   │   │   │   ├── Dept.java                    # 部门
    │   │   │   │   │   ├── Dict.java                    # 字典
    │   │   │   │   │   ├── DictItem.java                # 字典项
    │   │   │   │   │   ├── Config.java                  # 系统参数配置
    │   │   │   │   │   ├── UserRole.java                # 用户-角色关联
    │   │   │   │   │   ├── UserSocial.java              # 第三方账号绑定
    │   │   │   │   │   └── SysLog.java                  # 操作日志
    │   │   │   │   ├── form/                            # 表单对象（新增/修改）
    │   │   │   │   │   ├── UserForm.java                # 用户新增/修改
    │   │   │   │   │   ├── UserImportForm.java          # 用户导入
    │   │   │   │   │   ├── UserProfileForm.java         # 个人资料修改
    │   │   │   │   │   ├── PasswordUpdateForm.java      # 修改密码
    │   │   │   │   │   ├── PasswordVerifyForm.java      # 验证密码
    │   │   │   │   │   ├── MobileUpdateForm.java        # 修改手机号
    │   │   │   │   │   ├── EmailUpdateForm.java         # 修改邮箱
    │   │   │   │   │   ├── RoleForm.java                # 角色新增/修改
    │   │   │   │   │   ├── MenuForm.java                # 菜单新增/修改
    │   │   │   │   │   ├── DeptForm.java                # 部门新增/修改
    │   │   │   │   │   ├── DictForm.java                # 字典新增/修改
    │   │   │   │   │   ├── DictItemForm.java            # 字典项新增/修改
    │   │   │   │   │   ├── ConfigForm.java              # 配置新增/修改
    │   │   │   │   ├── query/                           # 查询参数
    │   │   │   │   │   ├── UserQuery.java               # 用户分页查询
    │   │   │   │   │   ├── RoleQuery.java               # 角色分页查询
    │   │   │   │   │   ├── MenuQuery.java               # 菜单查询
    │   │   │   │   │   ├── DeptQuery.java               # 部门查询
    │   │   │   │   │   ├── DictQuery.java               # 字典分页查询
    │   │   │   │   │   ├── DictItemQuery.java           # 字典项分页查询
    │   │   │   │   │   ├── ConfigQuery.java             # 配置分页查询
    │   │   │   │   │   └── LogQuery.java                # 日志分页查询
    │   │   │   │   └── vo/                              # 视图对象（响应体）
    │   │   │   │       ├── CurrentUserVO.java           # 当前登录用户信息
    │   │   │   │       ├── UserPageVO.java              # 用户分页列表项
    │   │   │   │       ├── UserExportVO.java            # 用户导出
    │   │   │   │       ├── UserProfileVO.java           # 用户个人信息
    │   │   │   │       ├── RolePageVO.java              # 角色分页列表项
    │   │   │   │       ├── MenuVO.java                  # 菜单树节点
    │   │   │   │       ├── RouteVO.java                 # 前端路由
    │   │   │   │       ├── DeptVO.java                  # 部门树节点
    │   │   │   │       ├── DictPageVO.java              # 字典分页列表项
    │   │   │   │       ├── DictItemPageVO.java          # 字典项分页列表项
    │   │   │   │       ├── DictItemOptionVO.java        # 字典项下拉选项
    │   │   │   │       ├── ConfigVO.java                # 配置分页列表项
    │   │   │   │       ├── LogPageVO.java               # 日志分页列表项
    │   │   │   │       ├── VisitOverviewVO.java         # 访问概览统计
    │   │   │   │       └── VisitTrendVO.java            # 访问趋势统计
    │   │   │   ├── security/
    │   │   │   │   └── adapter/                         # 适配器（六边形架构）
    │   │   │   │       ├── PermissionAdapter.java       # 权限适配器→框架层
    │   │   │   │       └── UserAuthenticationAdapter.java # 用户认证适配器→框架层
    │   │   │   └── service/                             # 业务逻辑接口
    │   │   │       ├── UserService.java                 # 用户管理
    │   │   │       ├── RoleService.java                 # 角色管理
    │   │   │       ├── MenuService.java                 # 菜单管理
    │   │   │       ├── DeptService.java                 # 部门管理
    │   │   │       ├── DictService.java                 # 字典管理
    │   │   │       ├── DictItemService.java             # 字典项管理
    │   │   │       ├── ConfigService.java               # 参数配置
    │   │   │       ├── LogService.java                  # 操作日志
    │   │   │       ├── UserRoleService.java             # 用户-角色关联
    │   │   │       ├── UserSocialService.java           # 第三方账号绑定
    │   │   │       ├── RoleMenuService.java             # 角色-菜单关联
    │   │   │       ├── RoleDeptService.java             # 角色-部门关联
    │   │   │       └── impl/                            # Service 实现类
    │   │   │
    │   │   ├── warehouse/                      # ===== 仓储管理模块（核心业务）=====
    │   │   │   ├── controller/
    │   │   │   │   ├── WmsLocationController.java  # 库区/区域管理
    │   │   │   │   ├── WmsAisleController.java     # 巷道管理
    │   │   │   │   └── WmsPointController.java     # 点位管理
    │   │   │   ├── converter/                      # MapStruct 对象转换
    │   │   │   │   ├── WmsLocationConverter.java       # 库区实体转换
    │   │   │   │   ├── WmsAisleConverter.java          # 巷道实体转换
    │   │   │   │   └── WmsPointConverter.java          # 点位实体转换
    │   │   │   ├── mapper/                             # MyBatis-Plus Mapper
    │   │   │   │   ├── WmsLocationMapper.java          # 库区
    │   │   │   │   ├── WmsAisleMapper.java             # 巷道
    │   │   │   │   └── WmsPointMapper.java             # 点位
    │   │   │   ├── model/
    │   │   │   │   ├── entity/                          # 数据库实体
    │   │   │   │   │   ├── WmsLocation.java             # 库区
    │   │   │   │   │   ├── WmsAisle.java                # 巷道（含 point_count 冗余）
    │   │   │   │   │   └── WmsPoint.java                # 点位
    │   │   │   │   ├── form/                            # 表单对象
    │   │   │   │   │   ├── WmsLocationForm.java         # 库区新增/修改
    │   │   │   │   │   ├── WmsAisleForm.java            # 巷道新增/修改
    │   │   │   │   │   └── WmsPointForm.java            # 点位新增/修改
    │   │   │   │   ├── query/                           # 查询参数
    │   │   │   │   │   ├── WmsLocationQuery.java        # 库区分页查询
    │   │   │   │   │   ├── WmsAisleQuery.java           # 巷道分页查询
    │   │   │   │   │   └── WmsPointQuery.java           # 点位分页查询
    │   │   │   │   └── vo/                              # 视图对象
    │   │   │   │       ├── WmsLocationVO.java           # 库区列表项
    │   │   │   │       ├── WmsAisleVO.java              # 巷道列表项（含 pointCount）
    │   │   │   │       └── WmsPointVO.java              # 点位列表项
    │   │   │   └── service/                             # 业务逻辑
    │   │   │       ├── WmsLocationService.java          # 库区业务接口
    │   │   │       ├── WmsAisleService.java             # 巷道业务接口
    │   │   │       ├── WmsPointService.java             # 点位业务接口
    │   │   │       ├── WmsCascadeService.java           # 级联停用（避免循环依赖）
    │   │   │       └── impl/
    │   │   │           ├── WmsLocationServiceImpl.java  # 库区业务实现（含级联停用）
    │   │   │           ├── WmsAisleServiceImpl.java     # 巷道业务实现（含编码生成+point_count维护）
    │   │   │           └── WmsPointServiceImpl.java     # 点位业务实现（含编码生成）
    │   │   │
    │   │   ├── rcs/                           # ===== RCS-AGV 调度管理（待开发）=====
    │   │   │   ├── controller/
    │   │   │   │   └── RcsTaskController.java        # AGV 任务 REST API（接收Req，返回VO，调用Service）
    │   │   │   ├── service/
    │   │   │   │   ├── RcsTaskService.java           # AGV 任务服务接口
    │   │   │   │   └── impl/
    │   │   │   │       └── RcsTaskServiceImpl.java   # AGV 任务服务实现（含RCS API调用，事务注解加在此处）
    │   │   │   ├── mapper/
    │   │   │   │   └── RcsTaskMapper.java            # AGV 任务 Mapper（仅负责与XML映射，继承Mybatis-Plus BaseMapper）
    │   │   │   ├── model/
    │   │   │   │   ├── entity/
    │   │   │   │   │   └── RcsTask.java              # AGV 任务实体（任务ID/类型/状态/点位/AGV编号等）
    │   │   │   │   ├── dto/
    │   │   │   │   │   ├── RcsTaskDTO.java           # AGV 任务数据传输对象（合并原Form+Query）
    │   │   │   │   │   └── RcsAgvStatusDTO.java      # AGV 状态数据传输对象
    │   │   │   │   └── vo/
    │   │   │   │       ├── RcsTaskVO.java            # AGV 任务列表项（出参）
    │   │   │   │       └── RcsAgvStatusVO.java       # AGV 实时状态（位置/电量/状态）（出参）
    │   │   │   ├── config/
    │   │   │   │   └── RcsProperties.java            # RCS 服务器连接配置（地址/API Key/超时等）
    │   │   │   ├── enums/
    │   │   │   │   ├── RcsTaskStatusEnum.java        # 任务状态枚举（待执行/执行中/已完成/异常）
    │   │   │   │   └── RcsTaskTypeEnum.java          # 任务类型枚举（托盘搬运/空车调度/充电等）
    │   │   │   ├── utils/
    │   │   │   │   └── RcsApiClient.java             # RCS HTTP API 客户端（发送任务/查询状态等，私有工具类）
    │   │   │   └── ...
    │   │   │
    │   │   ├── codegen/                        # ===== 代码生成器 =====
    │   │   │   ├── config/
    │   │   │   │   └── CodegenProperties.java       # 代码生成配置属性
    │   │   │   ├── controller/
    │   │   │   │   └── CodegenController.java       # 代码生成 REST API
    │   │   │   ├── converter/
    │   │   │   │   └── CodegenConverter.java        # 代码生成实体转换
    │   │   │   ├── enums/
    │   │   │   │   ├── FormTypeEnum.java            # 表单类型枚举
    │   │   │   │   ├── JavaTypeEnum.java            # Java 数据类型枚举
    │   │   │   │   └── QueryTypeEnum.java           # 查询条件类型枚举
    │   │   │   ├── mapper/
    │   │   │   │   ├── DatabaseMapper.java          # 数据库元数据查询
    │   │   │   │   ├── GenTableMapper.java          # 代码生成表配置
    │   │   │   │   └── GenTableColumnMapper.java    # 代码生成表字段配置
    │   │   │   ├── model/
    │   │   │   │   ├── entity/                      # GenTable, GenTableColumn
    │   │   │   │   ├── form/                        # GenConfigForm
    │   │   │   │   ├── query/                       # TablePageQuery, TableQuery
    │   │   │   │   └── vo/                          # CodegenPreviewVO, TableMetaVO 等
    │   │   │   └── service/
    │   │   │       ├── CodegenService.java          # 代码生成主服务
    │   │   │       ├── GenTableService.java         # 生成表配置管理
    │   │   │       ├── GenTableColumnService.java   # 生成表字段管理
    │   │   │       └── impl/
    │   │   │
    │   │   ├── common/                         # ===== 公共基础设施 =====
    │   │   │   ├── annotation/
    │   │   │   │   ├── DataPermission.java         # 数据权限注解
    │   │   │   │   ├── Log.java                    # 操作日志注解
    │   │   │   │   ├── RateLimit.java              # 接口限流注解
    │   │   │   │   ├── RepeatSubmit.java           # 防重复提交注解
    │   │   │   │   └── ValidField.java             # 字段校验注解
    │   │   │   ├── base/
    │   │   │   │   ├── BaseEntity.java             # 实体基类（id/创建人/创建时间/更新人/更新时间）
    │   │   │   │   ├── BaseQuery.java              # 查询参数基类（pageNum/pageSize）
    │   │   │   │   └── IBaseEnum.java              # 枚举接口（getValue/getLabel）
    │   │   │   ├── constant/
    │   │   │   │   ├── JwtClaimConstants.java      # JWT 声明常量
    │   │   │   │   ├── RedisConstants.java         # Redis Key 常量
    │   │   │   │   ├── SecurityConstants.java      # 安全相关常量
    │   │   │   │   └── SystemConstants.java        # 系统通用常量
    │   │   │   ├── enums/
    │   │   │   │   ├── ActionTypeEnum.java         # 操作类型枚举（增/删/改/导）
    │   │   │   │   ├── DataScopeEnum.java          # 数据权限范围枚举
    │   │   │   │   ├── EnvEnum.java                # 环境枚举（dev/prod）
    │   │   │   │   ├── LogModuleEnum.java          # 日志模块枚举
    │   │   │   │   ├── SocialPlatformEnum.java     # 第三方平台枚举
    │   │   │   │   └── StatusEnum.java             # 通用状态枚举（启用/停用）
    │   │   │   ├── exception/
    │   │   │   │   ├── BusinessException.java      # 业务异常
    │   │   │   │   └── DataPermissionException.java # 数据权限异常
    │   │   │   ├── model/
    │   │   │   │   ├── BatchStatusForm.java        # 批量状态更新 DTO
    │   │   │   │   ├── KeyValue.java               # 键值对
    │   │   │   │   └── Option.java                 # 下拉选项
    │   │   │   ├── result/
    │   │   │   │   ├── Result.java                 # 统一响应体（code/msg/data）
    │   │   │   │   ├── PageResult.java             # 分页响应体
    │   │   │   │   ├── ResultCode.java             # 响应码枚举
    │   │   │   │   ├── IResultCode.java            # 响应码接口
    │   │   │   │   └── ExcelResult.java            # Excel 导入结果
    │   │   │   ├── util/
    │   │   │   │   ├── ExcelUtils.java             # EasyExcel 工具
    │   │   │   │   └── IPUtils.java                # IP 地址工具
    │   │   │   └── validator/
    │   │   │       └── FieldValidator.java         # 字段校验器
    │   │   │
    │   │   ├── framework/                       # ===== 框架核心层 =====
    │   │   │   ├── apidoc/
    │   │   │   │   ├── OpenApiConfig.java           # Knife4j/Swagger API 文档配置
    │   │   │   │   └── Knife4jOpenApiCustomizer.java # API 文档自定义
    │   │   │   ├── cache/
    │   │   │   │   ├── CaffeineConfig.java          # Caffeine 本地缓存配置
    │   │   │   │   ├── RedisCacheConfig.java        # Redis 缓存配置
    │   │   │   │   └── RedisConfig.java             # Redis 连接配置
    │   │   │   ├── captcha/
    │   │   │   │   ├── config/                      # 验证码配置
    │   │   │   │   ├── enums/                       # 验证码类型枚举
    │   │   │   │   ├── exception/                   # 验证码异常
    │   │   │   │   ├── model/                       # 验证码响应
    │   │   │   │   └── service/                     # 验证码生成服务
    │   │   │   ├── integration/
    │   │   │   │   ├── mail/                        # 邮件服务
    │   │   │   │   └── sms/                         # 短信服务（阿里云）
    │   │   │   ├── job/
    │   │   │   │   ├── XxlJobConfig.java            # XXL-Job 分布式调度配置
    │   │   │   │   └── handler/                     # 任务处理器
    │   │   │   ├── mybatis/
    │   │   │   │   ├── config/                      # MyBatis-Plus 配置
    │   │   │   │   ├── exception/                   # 数据权限异常
    │   │   │   │   ├── handler/                     # 自动填充处理器
    │   │   │   │   └── interceptor/                 # MyBatis 拦截器
    │   │   │   │       └── MyDataPermissionHandler.java  # 数据权限拦截器
    │   │   │   ├── security/
    │   │   │   │   ├── config/                      # 安全配置
    │   │   │   │   ├── exception/                   # Token 失效异常
    │   │   │   │   ├── filter/                      # JWT 认证过滤器
    │   │   │   │   │   └── TokenAuthenticationFilter.java # JWT 认证过滤器
    │   │   │   │   ├── model/                       # SecurityUser, AuthenticationToken 等
    │   │   │   │   ├── port/                        # 六边形架构端口（接口）
    │   │   │   │   ├── service/                     # 权限/用户详情服务
    │   │   │   │   ├── token/                       # Token 管理（JWT + Redis）
    │   │   │   │   └── util/                        # SecurityUtils
    │   │   │   └── web/
    │   │   │       ├── advice/
    │   │   │       │   └── GlobalExceptionHandler.java  # 全局异常处理器
    │   │   │       ├── aspect/
    │   │   │       │   ├── LogAspect.java               # 操作日志切面
    │   │   │       │   ├── RateLimitAspect.java         # 接口限流切面
    │   │   │       │   └── RepeatSubmitAspect.java      # 防重复提交切面
    │   │   │       ├── config/                      # CORS, Jackson, 线程池等
    │   │   │       ├── exception/                   # RateLimitException
    │   │   │       ├── filter/                      # 请求日志过滤器, IP限流
    │   │   │       └── util/                        # ResponseWriter
    │   │   │
    │   │   ├── file/                            # ===== 文件服务 =====
    │   │   │   ├── config/
    │   │   │   │   ├── LocalFileProperties.java      # 本地上传配置
    │   │   │   │   ├── MinioProperties.java          # MinIO 对象存储配置
    │   │   │   │   └── AliyunOssProperties.java      # 阿里云 OSS 配置
    │   │   │   ├── controller/
    │   │   │   │   └── FileController.java           # 文件上传 REST API
    │   │   │   ├── model/
    │   │   │   │   └── FileInfo.java                 # 文件信息
    │   │   │   └── service/
    │   │   │       ├── FileService.java              # 文件服务接口
    │   │   │       └── impl/
    │   │   │           ├── LocalFileServiceImpl.java # 本地文件存储实现
    │   │   │           ├── MinioFileServiceImpl.java # MinIO 存储实现
    │   │   │           └── AliyunFileServiceImpl.java # 阿里云 OSS 实现
    │   │   │
    │   │   └── message/                         # ===== 消息推送（SSE）=====
    │   │       ├── controller/
    │   │       │   └── SseController.java           # SSE 长连接端点
    │   │       ├── dto/                             # DictChangeEvent, OnlineUserDTO
    │   │       ├── event/                           # 字典变更事件
    │   │       ├── job/                             # 在线人数统计定时任务
    │   │       ├── registry/                        # SSE 会话注册表
    │   │       ├── service/                         # SSE 推送服务
    │   │       └── topic/                           # SSE 主题常量
    │   │
    │   └── resources/                           # ===== 资源文件 =====
    │       ├── application.yml                  # 主配置
    │       ├── application-dev.yml              # 开发环境配置
    │       ├── application-prod.yml             # 生产环境配置
    │       ├── banner.txt
    │       ├── codegen.yml                      # 代码生成配置
    │       ├── logback-spring.xml               # 日志配置
    │       ├── META-INF/
    │       ├── data/
    │       │   └── ip2region.xdb                # IP 地理库
    │       ├── mapper/
    │       │   ├── system/                      # 14 个 Mapper XML
    │       │   └── warehouse/                   # 3 个 Mapper XML
    │       │       ├── WmsLocationMapper.xml
    │       │       ├── WmsAisleMapper.xml
    │       │       └── WmsPointMapper.xml
    │       └── templates/
    │           ├── codegen/                     # 代码生成 Velocity 模板
    │           │   ├── backend/                 # 10 个后端模板
    │           │   └── frontend/                # 6 个前端模板（JS+TS）
    │           └── excel/
    │               └── 用户导入模板.xlsx
    │
    └── test/
        └── java/com/youlai/boot/
            ├── auth/service/impl/
            │   └── AuthServiceImplTest.java
            ├── framework/web/
            │   ├── advice/
            │   └── config/
            ├── generator/
            │   └── SystemCodeGenerator.java
            └── security/
                ├── filter/
                └── token/
```

---

## 三、前端项目结构 (Vue 3 + TypeScript)

```
wmsui/
├── .editorconfig
├── .env.development                      # 开发环境变量
├── .env.production                       # 生产环境变量
├── .eslintrc-auto-import.json
├── .gitattributes
├── .gitignore
├── .prettierignore
├── .prettierrc.yaml
├── .stylelintignore
├── .stylelintrc.cjs
├── LICENSE
├── README.md
├── README.en-US.md
├── commitlint.config.cjs
├── deploy.mjs
├── eslint.config.ts
├── index.html
├── package.json
├── pnpm-lock.yaml
├── tsconfig.json
├── tsconfig.eslint.json
├── uno.config.ts
├── vite.config.ts
│
├── .husky/
│   ├── commit-msg
│   └── pre-commit
│
├── .vscode/
│   ├── extensions.json
│   └── settings.json
│
├── mock/                                  # Mock 数据（开发环境）
│   ├── base.ts                            # Mock 基础配置
│   ├── auth.mock.ts                       # 认证相关 Mock
│   ├── user.mock.ts                       # 用户管理 Mock
│   ├── role.mock.ts                       # 角色管理 Mock
│   ├── menu.mock.ts                       # 菜单管理 Mock
│   ├── dept.mock.ts                       # 部门管理 Mock
│   ├── dict.mock.ts                       # 字典管理 Mock
│   ├── log.mock.ts                        # 操作日志 Mock
│   ├── tenant.mock.ts                     # 租户管理 Mock
│   └── tenant-plan.mock.ts                # 租户套餐 Mock
│
├── public/
│   ├── favicon.ico
│   └── images/
│       ├── preview/
│       └── qrcode/
│
├── types/                                # 全局类型定义
│   ├── auto-imports.d.ts
│   ├── components.d.ts
│   ├── env.d.ts
│   ├── modules.d.ts
│   └── router.d.ts
│
└── src/
    ├── App.vue
    ├── main.ts
    ├── settings.ts
    │
    ├── api/                               # ==== API 接口层 ====
    │   ├── common.ts                      # 通用类型（ApiResult/PageResult/OptionItem）
    │   ├── auth/
    │   │   ├── index.ts                   # 登录/注册/重置密码
    │   │   └── types.ts
    │   ├── codegen/
    │   │   ├── index.ts
    │   │   └── types.ts
    │   ├── file/
    │   │   ├── index.ts
    │   │   └── types.ts
    │   ├── system/                        # 系统管理 API
    │   │   ├── app/                       # 应用管理
    │   │   ├── config/                    # 参数配置
    │   │   ├── dept/                      # 部门管理
    │   │   ├── dict/                      # 字典管理
    │   │   ├── log/                       # 操作日志
    │   │   ├── menu/                      # 菜单管理
    │   │   ├── role/                      # 角色管理
    │   │   ├── tenant/                    # 租户管理
    │   │   ├── tenant-plan/               # 租户套餐
    │   │   └── user/                      # 用户管理
    │   └── warehouse/                     # 仓储管理 API
    │       ├── wms-location/              # 库区/区域管理
    │       │   ├── index.ts
    │       │   └── types.ts
    │       ├── wms-aisle/                 # 巷道管理
    │       │   ├── index.ts
    │       │   └── types.ts
    │       └── wms-point/                 # 点位管理
    │           ├── index.ts
    │           └── types.ts
    │
    ├── views/                             # ==== 页面组件 ====
    │   ├── iframe.vue                     # 内嵌 iframe 容器
    │   ├── redirect.vue                   # 重定向页面
    │   ├── dashboard/
    │   │   └── index.vue                  # 仪表盘首页
    │   ├── login/
    │   │   ├── index.vue                  # 登录页
    │   │   └── components/
    │   │       ├── Register.vue           # 注册
    │   │       └── ResetPwd.vue           # 重置密码
    │   ├── error/
    │   │   ├── 401.vue                      # 无权限页面
    │   │   ├── 404.vue                      # 页面不存在
    │   │   └── components/
    │   │       └── ErrorPage.vue            # 错误页通用组件
    │   ├── profile/
    │   │   └── index.vue                  # 个人中心
    │   ├── codegen/
    │   │   ├── index.vue                  # 代码生成器
    │   │   ├── components/
    │   │   │   ├── BasicConfigStep.vue      # 基本配置步骤
    │   │   │   ├── FieldConfigStep.vue      # 字段配置步骤
    │   │   │   ├── GeneratorDrawer.vue      # 生成代码抽屉
    │   │   │   ├── PreviewStep.vue          # 代码预览步骤
    │   │   │   ├── TableList.vue            # 数据表选择列表
    │   │   │   └── WriteLocalDialog.vue     # 写入本地对话框
    │   │   ├── composables/
    │   │   │   ├── useCodePreview.ts        # 代码预览逻辑
    │   │   │   ├── useGenConfig.ts          # 生成配置逻辑
    │   │   │   └── useLocalWrite.ts         # 写入本地文件逻辑
    │   │   └── utils/
    │   │       └── tree-builder.ts
    │   ├── system/                        # 系统管理页面
    │   │   ├── app/index.vue              # 应用管理（多租户应用）
    │   │   ├── config/index.vue           # 参数配置
    │   │   ├── dept/index.vue             # 部门管理（树形表格）
    │   │   ├── dict/
    │   │   │   ├── index.vue              # 字典管理
    │   │   │   └── dict-item.vue          # 字典项管理
    │   │   ├── log/index.vue              # 操作日志
    │   │   ├── menu/index.vue             # 菜单管理（树形表格）
    │   │   ├── role/index.vue             # 角色管理
    │   │   ├── tenant/
    │   │   │   ├── index.vue              # 租户管理
    │   │   │   └── plan.vue               # 租户套餐
    │   │   └── user/
    │   │       ├── index.vue              # 用户管理
    │   │       └── components/
    │   │           ├── UserDeptTree.vue        # 用户部门树
    │   │           └── UserImportDialog.vue    # 用户导入对话框
    │   ├── demo/
    │   │   └── detail.vue                 # 详情页缓存演示
    │   └── warehouse/                     # 仓储管理页面（核心业务）
    │       ├── wms-location/index.vue     # 库区/区域管理
    │       ├── wms-aisle/index.vue        # 巷道管理
    │       └── wms-point/index.vue        # 点位管理
    │
    ├── router/                            # ==== 路由 ====
    │   ├── index.ts                       # 静态路由配置
    │   └── guards/
    │       └── permission.ts              # 路由守卫（动态路由生成）
    │
    ├── stores/                            # ==== Pinia 状态管理 ====
    │   ├── index.ts
    │   ├── app.ts                         # 应用状态
    │   ├── dict.ts                        # 字典缓存
    │   ├── permission.ts                  # 权限/动态路由
    │   ├── settings.ts                    # 系统设置
    │   ├── tags-view.ts                   # 多标签页
    │   ├── tenant.ts                      # 租户
    │   └── user.ts                        # 用户信息
    │
    ├── components/                        # ==== 公共组件 ====
    │   ├── AppLink/index.vue
    │   ├── Breadcrumb/index.vue           # 面包屑
    │   ├── CURD/                          # 通用 CRUD 组件
    │   │   ├── PageContent.vue
    │   │   ├── PageModal.vue
    │   │   ├── PageSearch.vue
    │   │   ├── types.ts
    │   │   └── usePage.ts
    │   ├── CommandPalette/                # 命令面板
    │   ├── CopyButton/                    # 复制按钮
    │   ├── DictSelect/                    # 字典下拉选择
    │   ├── DictTag/                       # 字典标签
    │   ├── ECharts/                       # 图表封装
    │   ├── Fullscreen/                    # 全屏
    │   ├── GithubCorner/
    │   ├── Hamburger/                     # 菜单折叠
    │   ├── IconSelect/                    # 图标选择器
    │   ├── InputTag/                      # 标签输入
    │   ├── LangSelect/                    # 语言切换
    │   ├── OperationColumn/               # 自适应操作列
    │   ├── Pagination/                    # 分页组件
    │   ├── SizeSelect/                    # 尺寸切换
    │   ├── TableSelect/                   # 表格选择器
    │   ├── TenantSwitcher/                # 租户切换
    │   ├── TextScroll/                    # 滚动文本
    │   ├── ThemeSwitch/                   # 主题切换
    │   ├── Upload/                        # 文件上传
    │   └── WangEditor/                    # 富文本编辑器
    │
    ├── composables/                       # ==== 组合式函数 ====
    │   ├── index.ts
    │   ├── usePageTable.ts                # 分页表格通用逻辑
    │   ├── useTableSelection.ts           # 表格多选逻辑
    │   └── sse/
    │       ├── index.ts
    │       ├── useDictSync.ts             # 字典实时同步
    │       ├── useOnlineCount.ts          # 在线人数
    │       └── useSse.ts                  # SSE 连接
    │
    ├── layouts/                           # ==== 布局组件 ====
    │   ├── index.vue                      # 布局入口
    │   ├── BaseLayout.vue                 # 基础布局框架
    │   ├── components/
    │   │   ├── LayoutLogo.vue            # 侧边栏 Logo
    │   │   ├── LayoutMain.vue            # 主内容区
    │   │   ├── LayoutMenuIcon.vue        # 菜单图标组件
    │   │   ├── LayoutNavbar.vue          # 顶部导航栏
    │   │   ├── LayoutSettings.vue        # 布局设置面板
    │   │   ├── LayoutSidebar.vue         # 侧边栏
    │   │   ├── LayoutSidebarItem.vue     # 侧边栏菜单项
    │   │   ├── LayoutTagsView.vue        # 多标签页
    │   │   └── LayoutToolbar.vue         # 工具栏（搜索/全屏/通知等）
    │   ├── composables/
    │   │   ├── useLayout.ts              # 布局状态逻辑
    │   │   ├── useLayoutDevice.ts        # 设备类型检测
    │   │   └── useMixMenu.ts             # 混合菜单模式逻辑
    │   └── modes/                        # 四种布局模式
    │       ├── DoubleLayout.vue          # 双栏布局
    │       ├── LeftLayout.vue            # 左侧布局
    │       ├── MixLayout.vue             # 混合布局
    │       └── TopLayout.vue             # 顶部布局
    │
    ├── utils/                             # ==== 工具函数 ====
    │   ├── index.ts                      # 通用工具函数
    │   ├── auth.ts                       # Token 管理
    │   ├── download.ts                   # 文件下载
    │   ├── format.ts                     # 格式化
    │   ├── request.ts                    # Axios 封装
    │   ├── storage.ts                    # 本地存储
    │   ├── tenant.ts                     # 租户工具
    │   ├── theme.ts                      # 主题工具
    │   └── validate.ts                   # 校验工具
    │
    ├── assets/                            # 静态资源
    │   ├── icons/                         # SVG 图标（约48个）
    │   └── images/
    │
    ├── constants/                         # 常量
    │   └── index.ts
    │
    ├── directives/                        # 自定义指令
    │   ├── index.ts
    │   └── permission/
    │       └── index.ts                   # v-hasPerm 权限指令
    │
    ├── enums/                             # 枚举定义
    │   ├── index.ts                      # 枚举导出
    │   ├── api.ts                        # API 相关枚举
    │   ├── business.ts                   # 业务枚举
    │   ├── codegen.ts                    # 代码生成枚举
    │   ├── common.ts                     # 通用枚举
    │   └── settings.ts                   # 设置枚举
    │
    ├── lang/                              # 国际化（i18n）
    │   ├── index.ts                      # i18n 初始化
    │   ├── utils.ts                      # 国际化工具
    │   └── package/
    │       ├── en.json                   # 英文语言包
    │       └── zh-cn.json                # 中文语言包
    │
    ├── plugins/                           # 插件初始化
    │   ├── nprogress.ts                  # 进度条插件
    │   └── vxe-table.ts                  # VxeTable 表格插件
    │
    └── styles/                            # 样式
        ├── index.scss                    # 样式入口
        ├── element-plus-overrides.scss   # Element Plus 样式覆盖
        ├── element-plus-vars.scss        # Element Plus 变量
        ├── layout.scss                   # 布局样式
        ├── mixins.scss                   # SCSS 混合宏
        ├── page.scss                     # 页面通用样式
        ├── reset.scss                    # 样式重置
        ├── theme.scss                    # 主题变量
        ├── variables.module.scss         # 变量模块（可被 JS 引用）
        ├── variables.scss                # SCSS 变量
        └── vendors.scss                  # 第三方样式
```

---

## 四、文件统计总览

### 4.1 后端统计（wms/）

| 模块 | Controller | Mapper | Entity | Form | Query | VO | Service | Converter | 合计 |
|------|-----------|--------|--------|------|-------|-----|---------|-----------|------|
| auth | 1 | - | - | 1 | - | 0 | 1+1 | - | **4** |
| system | 8 | 14 | 14 | 14 | 9 | 18 | 14+14 | 8 | **113** |
| warehouse | 3 | 3 | 3 | 3 | 3 | 3 | 4+3 | 3 | **28** |
| rcs（规划中） | 1 | 1 | 1 | 1 | 1 | 2 | 1+1 | 1 | **10** |
| codegen | 1 | 3 | 2 | 1 | 2 | 4 | 3+3 | 1 | **20** |
| common | - | - | - | - | - | - | - | - | **22** |
| framework | - | - | - | - | - | - | - | - | **36** |
| file | 1 | - | 1 | - | - | - | 1+3 | - | **6** |
| message | 1 | - | - | - | - | - | 1 | - | **2** |
| **小计** | **16** | **20** | **20** | **21** | **14** | **26** | **44** | **12** | **~237** |

资源文件：application.yml, application-dev.yml, application-prod.yml, 17 个 Mapper XML, 16 个代码生成模板

### 4.2 前端统计（wmsui/）

| 模块 | 文件数 | 说明 |
|------|--------|------|
| api/ | 27 | 13 组 API (index.ts + types.ts) + common.ts |
| views/ | 23 | 17 个 .vue + 6 个 .ts |
| router/ | 2 | 静态路由 + 路由守卫 |
| stores/ | 8 | Pinia 状态模块 |
| components/ | 34 | 22 个组件目录 |
| composables/ | 7 | 组合式函数 |
| layouts/ | 18 | 4 种布局 + 公共组件 |
| utils/ | 9 | 工具函数 |
| 其他 | ~73 | assets, enums, lang, styles, directives, plugins |
| **总计** | **~200** | 含 mock 文件 |

---

## 五、关键路径速查

### 5.1 后端

| 用途 | 路径 |
|------|------|
| 启动类 | `src/main/java/com/youlai/boot/YouLaiBootApplication.java` |
| 主配置 | `src/main/resources/application.yml` |
| 开发配置 | `src/main/resources/application-dev.yml` |
| 生产配置 | `src/main/resources/application-prod.yml` |
| 数据库SQL | `sql/admin-postgresql.sql` |
| 仓储Mapper XML | `src/main/resources/mapper/warehouse/` |
| 系统Mapper XML | `src/main/resources/mapper/system/` |
| 代码生成模板 | `src/main/resources/templates/codegen/` |

### 5.2 前端

| 用途 | 路径 |
|------|------|
| 入口文件 | `src/main.ts` |
| 静态路由 | `src/router/index.ts` |
| 路由守卫 | `src/router/guards/permission.ts` |
| 仓储页面 | `src/views/warehouse/` |
| 系统管理页面 | `src/views/system/` |
| 仓储 API | `src/api/warehouse/` |
| 系统管理 API | `src/api/system/` |
| 公共组件 | `src/components/` |
| 布局组件 | `src/layouts/` |
