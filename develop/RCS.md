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

---

### 🟡 P1 - 异常体系混乱

#### 3. GlobalException 与 BusinessException 重复

**文件**：
- `com.wms.common.exception.GlobalException`（新增）
- `com.wms.common.exception.BusinessException`（已存在）

**问题描述**：
项目已有 `BusinessException`，新增的 `GlobalException` 是冗余的，导致异常体系混乱。

**修复方案**：
- 删除 `GlobalException` 类
- 将 `ValidatorUtils` 中使用 `GlobalException` 的地方改为使用 `BusinessException`
- 修改 `ApiRequestUtils` 中异常处理逻辑，统一抛出 `BusinessException`

---

### 🟡 P2 - 性能问题

#### 4. ValidatorUtils 每次创建新实例

**文件**：`com.wms.common.util.ValidatorUtils`

**问题描述**：
`validateEntity()` 方法每次调用都通过 `Validation.byDefaultProvider()` 创建新的 Validator 实例，性能开销大。

**修复方案**：
```java
public class ValidatorUtils {
    // 缓存 Validator 实例
    private static final Validator VALIDATOR;
    
    static {
        VALIDATOR = Validation.byDefaultProvider()
            .configure()
            .messageInterpolator(new ResourceBundleMessageInterpolator(...))
            .buildValidatorFactory()
            .getValidator();
    }
    
    public static void validateEntity(Object object, Class<?>... groups) {
        Set<ConstraintViolation<Object>> violations = VALIDATOR.validate(object, groups);
        // ...
    }
}
```

---

### 🟡 P2 - 数据类型不一致

#### 5. TWmsApiRequestLog 时间类型不统一

**文件**：`com.wms.business.log.domain.TWmsApiRequestLog`

**问题描述**：
```java
private Date reqTime;           // Date 类型
private LocalDateTime createTime; // LocalDateTime 类型
```
同一个实体类中混用 `Date` 和 `LocalDateTime`，容易造成混乱。

**修复方案**：
- 统一使用 `LocalDateTime`
- 修改 `ApiRequestUtils` 中设置时间的代码：`requestLog.setReqTime(DateUtils.getNowDate())` → `requestLog.setReqTime(LocalDateTime.now())`

---

### 🟡 P2 - ApiRequestUtils 职责过重

#### 6. MES 业务逻辑混入工具类

**文件**：`com.wms.common.util.ApiRequestUtils`

**问题描述**：
`getMesBarcode()` 方法包含硬编码的 XML 模板和 MES 解析逻辑，业务逻辑不应混入通用工具类。

**修复方案**：
- 将 `getMesBarcode()` 和 `doPostSoap()` 方法抽取到独立的 `com.wms.rcs.service.MesService` 或 `com.wms.common.integration.MesClient` 类中
- `ApiRequestUtils` 只保留通用 HTTP/SOAP 调用逻辑

#### 7. handleByModule 硬编码

**文件**：`com.wms.common.util.ApiRequestUtils`

**问题描述**：
```java
private static void handleByModule(TWmsApiRequestLog requestLog) {
    if ("agv".equals(module)) { ... }
    else if ("mes".equals(module)) { ... }
    else { ... }  // 默认逻辑
}
```
每新增一个模块都要修改此方法，违反开闭原则。

**修复方案**：
使用策略模式，定义解析接口：
```java
public interface ModuleResponseParser {
    boolean supports(String module);
    void parse(TWmsApiRequestLog log);
}

// RCS 解析器
@Component
public class RcsResponseParser implements ModuleResponseParser { ... }

// MES 解析器
@Component
public class MesResponseParser implements ModuleResponseParser { ... }
```

---

### 🟡 P3 - Controller 注解缺失

#### 8. AgvController 缺少必要注解

**文件**：`com.wms.rcs.controller.AgvController`

**问题描述**：
缺少以下注解：
- ❌ `@PreAuthorize` 权限注解
- ❌ `@Log` 日志注解（操作日志）
- ❌ 参数校验注解 `@Valid`

**修复方案**：
```java
@PostMapping("/commonRequest/{methodName}")
@Operation(summary = "通用请求接口")
@PreAuthorize("@ss.hasPermi('agv:common:request')")
@Log(title = "AGV通用请求", businessType = BusinessType.OTHER)
public Result<Object> commonRequest(@PathVariable String methodName, 
                                     @RequestBody Map<String, Object> params) {
    return iAgvService.commonRequest(methodName, params);
}
```

---

### 🟢 P3 - 建议改进

#### 9. StringUtils 继承冲突

**文件**：`com.wms.common.util.StringUtils`

**问题描述**：
项目中新增加的 `StringUtils` 继承自 `org.apache.commons.lang3.StringUtils`，而原有代码中 `CartItemServiceImpl` 等使用的是 `cn.hutool.core.util.StrUtil`，可能导致混乱。

**建议**：
- 保留新增的 `StringUtils`（功能更全）
- 逐步将原有使用 `StrUtil` 的地方迁移到 `StringUtils`
- 或者反之，删除新增的 `StringUtils`，统一使用 `StrUtil`

#### 10. SpringUtils 重复

**文件**：`com.wms.common.util.spring.SpringUtils`

**问题描述**：
项目 `framework` 包中可能已有类似实现，需检查是否冲突。

**建议**：
- 如果 `framework` 包中已有 `SpringUtils`，删除新增的
- 如果没有，保留新增的

#### 11. Constants 类过于笼统

**文件**：`com.wms.common.constant.Constants`

**问题描述**：
项目已有 `SecurityConstants`、`SystemConstants`、`JwtClaimConstants`、`RedisConstants` 等细分类，新增的 `Constants` 类职责不清晰。

**建议**：
- 将 `Constants` 中的常量拆分到对应的细分类中
- 例如：`TOKEN_PREFIX` → `SecurityConstants`，`HTTP`/`HTTPS` → `SystemConstants`

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