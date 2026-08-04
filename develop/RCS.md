新增跟warehous同级包：RCS管理系统（rcsmanagementsystem），下面分别有以下几个功能：
1、系统互联配置（integrationconfig）用于配置接口的信息url等
2、任务指令中心（taskdispatchcenter）用于调用RCSapi，发送任务指令等
3、任务历史追溯（taskHistoryAndTrace）用于记录任务的历史指令和执行记录

com.wms.rcsmanagementsystem
├── common/                          # 公共模块
│   ├── constant/
│   │   └── RcsConstants.java        # 常量定义
│   └── enums/
│       ├── RcsTaskStatusEnum.java   # 任务状态枚举
│       ├── RcsTaskTypeEnum.java     # 任务类型枚举
│       └── IntegrationConfigTypeEnum.java  # 配置类型枚举
│
├── integrationconfig/               # 1. 系统互联配置
│   ├── controller/
│   │   └── IntegrationConfigController.java
│   ├── mapper/
│   │   └── IntegrationConfigMapper.java
│   ├── model/
│   │   ├── dto/
│   │   │   ├── IntegrationConfigDTO.java
│   │   │   └── IntegrationConfigQueryDTO.java
│   │   ├── entity/
│   │   │   └── IntegrationConfig.java
│   │   └── vo/
│   │       └── IntegrationConfigVO.java
│   ├── service/
│   │   ├── IntegrationConfigService.java
│   │   └── impl/
│   │       └── IntegrationConfigServiceImpl.java
│   └── IntegrationConfigConverter.java
│
├── taskdispatchcenter/              # 2. 任务指令中心
│   ├── controller/
│   │   └── TaskDispatchController.java
│   ├── mapper/
│   │   └── RcsTaskMapper.java
│   ├── model/
│   │   ├── dto/
│   │   │   ├── RcsTaskDTO.java
│   │   │   ├── RcsTaskQueryDTO.java
│   │   │   └── RcsTaskDispatchDTO.java  # 下发任务专用
│   │   ├── entity/
│   │   │   └── RcsTask.java
│   │   └── vo/
│   │       └── RcsTaskVO.java
│   ├── service/
│   │   ├── RcsTaskService.java
│   │   ├── RcsApiClient.java        # RCS API 客户端
│   │   └── impl/
│   │       ├── RcsTaskServiceImpl.java
│   │       └── RcsApiClientImpl.java
│   └── RcsTaskConverter.java
│
└── taskHistoryAndTrace/             # 3. 任务历史追溯
    ├── controller/
    │   └── TaskHistoryController.java
    ├── mapper/
    │   └── RcsTaskHistoryMapper.java
    ├── model/
    │   ├── dto/
    │   │   ├── TaskHistoryQueryDTO.java
    │   │   └── TaskHistoryTraceDTO.java  # 追溯查询
    │   ├── entity/
    │   │   └── RcsTaskHistory.java
    │   └── vo/
    │       ├── TaskHistoryVO.java
    │       └── TaskTraceVO.java        # 追溯详情
    ├── service/
    │   ├── TaskHistoryService.java
    │   └── impl/
    │       └── TaskHistoryServiceImpl.java
    └── TaskHistoryConverter.java

---

## 代码审查整改清单
### 🟡 P2 - ApiRequestUtils 职责过重

#### 6. MES 业务逻辑已移除

**处理方案**：由于项目未涉及 MES 功能，已将所有 MES 相关代码删除，保持代码干净。

**删除内容**：
- `getMesBarcode(String code)` 方法
- `doPostSoap(String postUrl, String soapXml, String soapAction)` 方法
- `execute()` 中的 `WebServiceMesCode` 分支判断
- `handleByModule()` 中的 `mes` 模块解析逻辑
- 相关 import（`MapUtil`、`XML`、`JSON`、`StringEscapeUtils`、`HttpEntity`、`RequestConfig`、`CloseableHttpResponse`、`HttpPost`、`StringEntity`、`CloseableHttpClient`、`HttpClientBuilder`、`EntityUtils`、`Document`、`Element`、`NodeList`、`DocumentBuilder`、`DocumentBuilderFactory`、`ByteArrayInputStream`、`Charset`）

**优点**：
- ✅ 代码干净：移除未使用的 MES 功能代码
- ✅ 降低复杂度：`handleByModule()` 逻辑简化
- ✅ 减少依赖：移除不需要的 import

---

#### 7. handleByModule 硬编码 ✅

**文件**：`com.wms.common.util.ApiRequestUtils`

**原问题**：
```java
private static void handleByModule(TWmsApiRequestLog requestLog) {
    if ("agv".equals(module)) { ... }
    else if ("mes".equals(module)) { ... }
    else { ... }  // 默认逻辑
}
```

**修复方案**：由于删除 MES 后，所有模块的解析逻辑统一（都是解析 JSON → 取 `code` → 判断 `"0"` 为成功），简化为单一实现，同时预留扩展点：

```java
private static void handleByModule(ApiRequestLog requestLog) {
    if (StringUtils.isNotEmpty(requestLog.getResParams())) {
        JSONObject resParams = JSONObject.parse(requestLog.getResParams());
        String resCode = resParams.getString("code");
        // 如需按模块定制解析逻辑，可在此添加 if-else 分支
        requestLog.setResCode(resCode);
        requestLog.setIsSuccess("0".equals(resCode) ? "Y" : "N");
    }
}
```

**说明**：
- ✅ 代码量从 20+ 行减到 7 行
- ✅ 统一实现，避免重复逻辑
- ✅ 预留扩展点：后续对接条码机/MES 等特殊模块时，可在注释处添加 if-else 分支

---

### 🟡 P3 - Controller 注解缺失

#### 8. AgvController 缺少必要注解 ✅

**文件**：`com.wms.rcs.controller.AgvController`

**原问题**：
缺少以下注解：
- ❌ `@PreAuthorize` 权限注解
- ❌ `@Log` 日志注解（操作日志）
- ❌ 参数校验注解 `@Valid`

**修复方案**：按项目实际注解规范（`@ss.hasPerm` + `LogModuleEnum`/`ActionTypeEnum` 枚举）添加权限和日志注解；参数为 `Map<String, Object>`，`@Valid` 无法校验 Map 内容，故不添加。

```java
@PostMapping("/commonRequest/{methodName}")
@Operation(summary = "通用请求接口")
@PreAuthorize("@ss.hasPerm('rcs:agv:request')")
@Log(module = LogModuleEnum.RCS_AGV, value = ActionTypeEnum.OTHER)
public Result<Object> commonRequest(@PathVariable String methodName, @RequestBody Map<String ,Object> params) {
    return agvService.commonRequest(methodName, params);
}
```

**配套变更**：
- `LogModuleEnum` 新增 `RCS_AGV(88, "AGV调度管理")` 枚举值

**说明**：
- ✅ 权限标识格式 `rcs:agv:request` 遵循项目 `模块:资源:操作` 规范
- ✅ `@Log` 使用项目枚举（`LogModuleEnum.RCS_AGV` + `ActionTypeEnum.OTHER`），非 RuoYi 风格的 `title`/`businessType`
- ℹ️ `@Valid` 未添加：`Map<String, Object>` 类型无法触发 JSR303 校验，如需校验应改用具体 DTO

---

### 🟢 P3 - 建议改进

#### 9. StringUtils 继承冲突（技术决策：暂不修改）

**文件**：`com.wms.common.util.StringUtils`

**问题描述**：
项目中新增加的 `StringUtils` 继承自 `org.apache.commons.lang3.StringUtils`，而原有代码中 `CartItemServiceImpl` 等使用的是 `cn.hutool.core.util.StrUtil`，可能导致混乱。

**使用情况调研**：
| 工具类 | 使用文件数 | 说明 |
|--------|:----------:|------|
| `cn.hutool.core.util.StrUtil` | 28 | 项目主流，遍布 system/warehouse/carrier 等模块 |
| `org.apache.commons.lang3.StringUtils` | 3 | JwtTokenManager、ConfigServiceImpl、MenuServiceImpl |
| `com.wms.common.util.StringUtils`（新增自定义） | 1 | 仅 `AgvServiceImpl`，且只用了 `isEmpty()` |

**行为差异提醒**：
自定义 `StringUtils.isEmpty(str)` 内部执行 `str.trim()` 后比较，行为等同 `StrUtil.isBlank()`，**不是** `StrUtil.isEmpty()`。如后续迁移，需用 `StrUtil.isBlank()` 替换，否则纯空白字符串处理行为不一致。

**技术决策**：暂不修改，保持现状。
- 理由 1：功能正常，三种工具类并存不影响运行结果
- 理由 2：自定义类仅 1 个文件使用，影响范围极小
- 理由 3：属于 P3 级代码规范问题，非必须修复
- 如后续需统一，推荐方案：删除自定义 `StringUtils`，`AgvServiceImpl` 改用 `StrUtil.isBlank()`

---

#### 10. SpringUtils 重复（技术决策：暂不修改）

**文件**：`com.wms.common.util.spring.SpringUtils`

**问题描述**：
项目 `framework` 包中可能已有类似实现，需检查是否冲突。

**调研结果**：
| 工具类 | 使用文件 | 调用次数 | 是否有 @Component | 能否正常工作 |
|--------|---------|:--------:|:-----------------:|:------------:|
| `com.wms.common.util.spring.SpringUtils`（新增自定义） | `ApiRequestUtils` | 2 | ✅ 有 | ✅ 正常 |
| `cn.hutool.extra.spring.SpringUtil`（Hutool） | `UserImportListener` | 7 | ❌ 无 | ⚠️ 可能 NPE |

**关键风险**：
- 项目使用 `hutool-all`（非 `hutool-spring-boot-starter`），**无自动配置机制**
- Hutool `SpringUtil` 类**没有 `@Component` 注解**，且项目中**无任何地方注册它为 Bean**
- `UserImportListener` 中的 `SpringUtil.getBean()` 调用**可能已存在潜在 NPE 风险**（`applicationContext` 为 null），仅因用户导入功能未被触发而未暴露
- 如果删除自定义 `SpringUtils` 直接替换为 Hutool `SpringUtil`，`ApiRequestUtils` 中的 `getBean()` 调用将**必然 NPE**

**技术决策**：暂不修改，保持现状。
- 理由 1：自定义 `SpringUtils` 有 `@Component` 注解，功能正常
- 理由 2：直接替换为 Hutool `SpringUtil` 有运行时 NPE 风险
- 理由 3：如需统一，必须先在配置类中注册 Hutool `SpringUtil`（如 `@Import(SpringUtil.class)`），再迁移，成本较高
- ⚠️ 附带发现：`UserImportListener` 中的 Hutool `SpringUtil` 调用可能存在潜在 NPE，建议后续验证用户导入功能是否正常

---

#### 11. Constants 类过于笼统

**文件**：`com.wms.common.constant.Constants`（已删除）

**问题描述**：
项目已有 `SecurityConstants`、`SystemConstants`、`JwtClaimConstants`、`RedisConstants` 等细分类，新增的 `Constants` 类职责不清晰，且 `TOKEN_PREFIX` 与 `SecurityConstants.BEARER_TOKEN_PREFIX` 值重复。

**调研结果**：
Constants 类定义了 15 个常量，但实际只有 2 个被使用：

| 常量 | 使用文件 | 使用位置 |
|------|---------|---------|
| `HTTP` | `StringUtils.java` | `ishttp()` 方法 |
| `HTTPS` | `StringUtils.java` | `ishttp()` 方法 |
| `TOKEN_PREFIX = "Bearer "` | **无** | 与 `SecurityConstants.BEARER_TOKEN_PREFIX` 重复 |
| 其余 12 个 | **无** | 项目中无任何文件使用 |

**修复方案**：将 `HTTP`/`HTTPS` 并入 `SystemConstants`，删除 `Constants` 类。

变更文件：
| 文件 | 操作 |
|------|------|
| `SystemConstants.java` | 新增 `HTTP`、`HTTPS` 常量 |
| `StringUtils.java` | import 从 `Constants` 改为 `SystemConstants`；`Constants.HTTP` → `SystemConstants.HTTP`、`Constants.HTTPS` → `SystemConstants.HTTPS` |
| `Constants.java` | **已删除** |

```java
// SystemConstants.java（最终结果）
public interface SystemConstants {
    Long ROOT_NODE_ID = 0L;
    String DEFAULT_PASSWORD = "123456";
    String ROOT_ROLE_CODE = "ROOT";
    String HTTP = "http://";      // ← 从 Constants 并入
    String HTTPS = "https://";    // ← 从 Constants 并入
}
```

**说明**：
- ✅ 删除了 13 个未被使用的常量，消除冗余
- ✅ 消除了 `TOKEN_PREFIX` 与 `SecurityConstants.BEARER_TOKEN_PREFIX` 的重复定义
- ✅ `HTTP`/`HTTPS` 并入 `SystemConstants`，与项目按作用命名的风格一致
- ✅ 删除 `Constants` 类，减少一个职责不清的常量类

---

## 修复优先级总览

| 优先级 | 问题编号 | 问题 | 影响范围 |
|:---:|:---:|------|------|
| **P0** | #1 | module 匹配不一致 | RCS/MES 接口解析 |
| **P1** | #2 | IAgvServiceImpl 命名不规范 | 代码规范 |
| **P1** | #3 | GlobalException 重复 | 异常体系 |
| **P2** | #4 | ValidatorUtils 性能问题 | 性能 |
| **P2** | #5 | 时间类型不统一 | 数据一致性 |
| **P2** | #6 | MES 业务逻辑混入工具类 | 代码结构 |
| **P2** | #7 | handleByModule 硬编码 | 可扩展性 |
| **P3** | #8 | Controller 注解缺失 | 安全性/可追溯性 |
| **P3** | #9-11 | 公共类重复/混乱 | 代码规范 |

---

## 建议修复顺序

1. **第一步**：修复 P0 级 Bug（module 匹配不一致）
2. **第二步**：修复 P1 级问题（命名、异常体系）
3. **第三步**：修复 P2 级问题（性能、数据类型、代码结构）
4. **第四步**：修复 P3 级问题（注解、公共类整理）