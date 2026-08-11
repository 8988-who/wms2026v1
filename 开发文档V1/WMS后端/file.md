# 文件模块（file）

## 1. 模块概述

本模块提供**文件上传与删除**能力，抽象为统一的 `FileService` 接口，并通过 `@ConditionalOnProperty(oss.type=...)` 在**三种存储后端**间条件装配切换：MinIO、本地磁盘、阿里云 OSS。

核心业务能力：

- **统一接口**：`FileService.uploadFile(MultipartFile)` / `FileService.deleteFile(String filePath)`，各实现类在 `@PostConstruct` 中初始化各自的存储客户端；
- **策略切换**：同一接口多个实现，由配置项 `oss.type`（`minio` / `local` / `aliyun`）决定激活哪一个 Bean，无需改动业务调用方；
- **文件命名策略**：三个实现均采用"**日期分目录 + UUID 重命名**"（`yyyyMMdd/{uuid}.{suffix}`），避免文件名冲突与中文名乱码；
- **接口状态（C-03 整改）**：`FileController` 中上传/删除接口**已整体注释下线**。原因：① MinIO 桶被 `createBucketIfAbsent` 自动设为**公共读写**，任意匿名者可读/写/删桶内文件（严重漏洞）；② 上传无类型/大小/文件名校验，删除接口无权限校验且存在路径穿越（C-04）。当前该能力仅用于"用户头像上传"，核心 WMS 业务未使用，故整体下线以消除风险。恢复前置条件：先完成 C-03（桶改私有 + 预签名 URL）与 C-04（上传/删除加固）再取消注释；本次仅下线接口，未改动 MinIO 桶策略与已上传文件，存量头像 URL 不受影响。

> 本模块不建任何表：文件实体存于外部对象存储，业务侧仅通过 `sys_user.avatar` 记录文件访问 URL。

---

## 2. 数据表设计（来源 public.sql）

**无独立建表**，文件本身存于外部存储（MinIO / 本地磁盘 / 阿里云 OSS），数据库侧仅 `sys_user.avatar` 承载头像 URL。

### 2.1 `sys_user.avatar` —— 用户头像字段（[public.sql](../../wms/sql/public.sql)）

`sys_user` 表完整结构见 [auth.md](./auth.md#21-sys_user--系统用户表publicsql)，与本模块相关字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| avatar | varchar(255) | 用户头像 URL（文件模块上传后返回的访问地址，如 `https://{bucket}.{endpoint}/yyyyMMdd/{uuid}.jpg` 或本地相对路径 `/yyyyMMdd/{uuid}.jpg`） |

---

## 3. 数据库交互

**无直接业务表读写**。文件模块只负责对象存储（本地磁盘 / MinIO / 阿里云 OSS），文件元数据不落库：

- 上传成功返回可访问 URL，由**调用方**决定是否写入业务表（如用户头像写入 `sys_user.avatar`，见 2.1）；
- 当前上传/删除接口已整体注释下线（C-03/C-04 整改），`FileService` 仅保留供头像等场景直接调用；
- 无 Mapper、无 `@Transactional`，不占用任何数据库资源。

---

## 4. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/file/...`；以下"引用的包"为该文件 import 中的主要部分。

### 4.1 控制器层（controller）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [FileController.java](../../wms/src/main/java/com/wms/file/controller/FileController.java) | 文件接口入口：`/api/v1/files`（上传 / 删除） | `com.wms.common.result.Result`、`com.wms.file.service.FileService`、`com.wms.file.model.FileInfo`、`io.swagger.v3.oas.annotations.*`、`org.springframework.web.multipart.MultipartFile`、`org.springframework.web.bind.annotation.*`、`lombok.RequiredArgsConstructor/SneakyThrows` | `@Tag(name="10.文件接口")`；**上传（@PostMapping）与删除（@DeleteMapping）接口已整体注释下线（C-03/C-04）**，仅保留类骨架与整改说明注释 |

### 4.2 服务层（service）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [FileService.java](../../wms/src/main/java/com/wms/file/service/FileService.java) | 对象存储服务接口 | `com.wms.file.model.FileInfo`、`org.springframework.web.multipart.MultipartFile` | 声明 `uploadFile`（上传返回 FileInfo{name,url}）与 `deleteFile`（按完整 URL 删除） |
| [MinioFileServiceImpl.java](../../wms/src/main/java/com/wms/file/service/impl/MinioFileServiceImpl.java) | MinIO 存储实现（`oss.type=minio`） | `io.minio.*`（**MinioClient**、PutObjectArgs、BucketExistsArgs、MakeBucketArgs、SetBucketPolicyArgs、GetPresignedObjectUrlArgs、RemoveObjectArgs）、`io.minio.http.Method`、`cn.hutool.core.util.IdUtil/StrUtil`、`cn.hutool.core.io.FileUtil`、`cn.hutool.core.date.DateUtil`、`com.wms.common.exception.BusinessException`、`com.wms.common.result.ResultCode`、`com.wms.file.model.FileInfo`、`org.springframework.boot.autoconfigure.condition.ConditionalOnProperty`、`org.springframework.boot.context.properties.ConfigurationProperties`、`jakarta.annotation.PostConstruct` | `@Component + @ConditionalOnProperty(value="oss.type", havingValue="minio")` 条件装配；`@ConfigurationProperties(prefix="oss.minio")` + `@Data` 直接绑定 endpoint/accessKey/secretKey/bucketName/customDomain；`@PostConstruct init()` 构建 **MinioClient**；上传前 `createBucketIfAbsent` **自动建桶并设置公共读写策略**（publicBucketPolicy，C-03 风险点）；按 `yyyyMMdd/{uuid}.{suffix}` 存储；无 customDomain 时生成 GET 预签名 URL 并截掉查询串，有则拼 `customDomain/bucket/object`；删除时按 URL 前缀截取 object key 后 `removeObject` |
| [LocalFileServiceImpl.java](../../wms/src/main/java/com/wms/file/service/impl/LocalFileServiceImpl.java) | 本地磁盘存储实现（`oss.type=local`） | `cn.hutool.core.io.FileUtil`、`cn.hutool.core.util.IdUtil`、`cn.hutool.core.date.DateUtil/DatePattern`、`com.wms.file.model.FileInfo`、`org.springframework.beans.factory.annotation.Value`、`org.springframework.boot.autoconfigure.condition.ConditionalOnProperty`、`org.springframework.boot.context.properties.ConfigurationProperties`、`org.springframework.web.multipart.MultipartFile` | `@ConditionalOnProperty(value="oss.type", havingValue="local")`；`@Value("${oss.local.storage-path}")` 注入根目录（另 `@ConfigurationProperties(prefix="oss.local")` 预留）；按 `{storagePath}/{yyyyMMdd}/{uuid}.{suffix}` 落盘，返回相对 URL `/yyyyMMdd/{uuid}.{suffix}`；删除时拼接路径，目录拒绝删除（防误删整目录） |
| [AliyunFileServiceImpl.java](../../wms/src/main/java/com/wms/file/service/impl/AliyunFileServiceImpl.java) | 阿里云 OSS 存储实现（`oss.type=aliyun`） | `com.aliyun.oss.OSS` / **`OSSClientBuilder`** / `com.aliyun.oss.model.ObjectMetadata/PutObjectRequest`、`cn.hutool.core.date.DateUtil`、`cn.hutool.core.io.FileUtil`、`cn.hutool.core.util.IdUtil`、`cn.hutool.core.lang.Assert`、`com.wms.file.service.FileService`、`org.springframework.boot.autoconfigure.condition.ConditionalOnProperty`、`org.springframework.boot.context.properties.ConfigurationProperties`、`jakarta.annotation.PostConstruct` | `@ConditionalOnProperty(value="oss.type", havingValue="aliyun")`；`@ConfigurationProperties(prefix="oss.aliyun")` + `@Data` 绑定 endpoint/accessKeyId/accessKeySecret/bucketName；`@PostConstruct init()` 用 **OSSClientBuilder** 构建 OSS 客户端；按 `yyyyMMdd/{uuid}.{suffix}` 上传（带 content-type 元数据）；返回 URL 固定为 **`https://{bucket}.{endpoint}/{objectKey}`**；删除时从 URL 截取 objectKey 后 `deleteObject` |

### 4.3 模型层（model）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [FileInfo.java](../../wms/src/main/java/com/wms/file/model/FileInfo.java) | 文件信息对象 | `io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data` | 两个字段：name（原始文件名）/ url（访问 URL），上传成功后的统一返回载体 |

### 4.4 配置层（config）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [MinioProperties.java](../../wms/src/main/java/com/wms/file/config/MinioProperties.java) / [LocalFileProperties.java](../../wms/src/main/java/com/wms/file/config/LocalFileProperties.java) / [AliyunOssProperties.java](../../wms/src/main/java/com/wms/file/config/AliyunOssProperties.java) | 存储配置属性类（占位） | 无（空文件） | **当前为空文件**：三个存储实现的配置属性并未使用这些独立 Properties 类，而是直接在各自 ServiceImpl 上通过 `@ConfigurationProperties(prefix="oss.minio/local/aliyun")` + `@Data` 字段绑定（LocalFile 的 storage-path 用 `@Value` 注入） |

---

## 5. 核心实现逻辑

### 5.1 三种存储后端的条件装配（策略切换）

```
配置项 oss.type
   ├─ minio  ──► MinioFileServiceImpl   （@ConditionalOnProperty havingValue="minio"）
   ├─ local  ──► LocalFileServiceImpl   （@ConditionalOnProperty havingValue="local"）
   └─ aliyun ──► AliyunFileServiceImpl  （@ConditionalOnProperty havingValue="aliyun"）
                        │
                        ▼
             统一注入 FileService 接口（业务侧零改动切换）
```

- 三个实现均为 `@Component`，靠 `@ConditionalOnProperty` 保证同一时刻只装配一个 Bean；
- 客户端初始化统一放在 `@PostConstruct`：MinIO 用 `MinioClient.builder()`、OSS 用 `OSSClientBuilder().build()`、本地无客户端。

### 5.2 上传流程（以 MinIO 为例，三个实现结构一致）

```
MultipartFile ─► uploadFile
  ① 取原始文件名后缀 suffix（FileUtil.getSuffix），UUID 生成新文件名（IdUtil.simpleUUID）
  ② 按当前日期建目录 yyyyMMdd
  ③ MinIO：createBucketIfAbsent 自动建桶（不存在则 makeBucket + setBucketPolicy 设为公共读写 ← C-03 风险点）
     上传 putObject(object=yyyyMMdd/{uuid}.{suffix}, contentType)
     生成 URL：
       ├─ 配置了 customDomain：customDomain/bucketName/yyyyMMdd/{uuid}.{suffix}
       └─ 未配置：getPresignedObjectUrl(GET) 后截取 "?" 之前的部分
  ④ 组装 FileInfo{name=原始文件名, url=访问地址} 返回
```

- **本地**：`FileUtil.writeFromStream` 落盘至 `{storagePath}/{yyyyMMdd}/{uuid}.{suffix}`，URL 为相对路径；
- **OSS**：`putObject` 至 `yyyyMMdd/{uuid}.{suffix}`，URL 固定为 `https://{bucket}.{endpoint}/{objectKey}`（任务描述要点）；
- 三种实现均无文件类型/大小校验（C-04 整改点）。

### 5.3 删除流程

```
filePath（完整 URL 或相对路径）
  ① MinIO：customDomain 存在则截 customDomain/bucket 前缀，否则截 endpoint/bucket 前缀 → 得到 object key
           └─ minioClient.removeObject(bucket, objectKey)
  ② OSS：  filePath 截去 "https://{bucket}.{endpoint}" 前缀 → objectKey
           └─ aliyunOssClient.deleteObject(bucket, objectKey)
  ③ 本地： storagePath + filePath 拼接（目录直接拒绝），FileUtil.del 删除
```

> 注：删除接口已随 C-03/C-04 下线，上述逻辑当前不可通过 HTTP 触发，仅保留实现供整改后恢复。

---

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| MinIO Java SDK（`io.minio.MinioClient`） | MinIO 对象存储客户端：putObject / removeObject / bucketExists / makeBucket / setBucketPolicy / getPresignedObjectUrl |
| 阿里云 OSS SDK（`com.aliyun.oss.OSS` / `OSSClientBuilder`） | OSS 对象存储客户端：putObject / deleteObject，ObjectMetadata 设置 content-type |
| 本地文件系统（Hutool `FileUtil`） | 本地磁盘落盘 / 删除（writeFromStream / del / isDirectory） |
| Spring Boot 条件装配（`@ConditionalOnProperty`） | 按 `oss.type`（minio / local / aliyun）切换存储后端实现 |
| `@ConfigurationProperties` + `@Data` | 绑定 `oss.minio` / `oss.aliyun` 配置；`@Value` 注入 `oss.local.storage-path` |
| Hutool（`IdUtil` / `DateUtil` / `FileUtil`） | UUID 文件名、日期目录、文件读写工具 |
| `MultipartFile` | 文件上传表单载体 |
| Knife4j / Swagger 注解 | 接口文档（`@Tag` / `@Operation` / `@Schema`） |
