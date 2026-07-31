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