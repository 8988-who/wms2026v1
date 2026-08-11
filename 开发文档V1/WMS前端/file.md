# 文件上传模块（file）

## 1. 模块概述

文件上传模块提供统一的上传/下载/删除能力，包含以下内容：

- **三个通用上传组件**（[components/Upload](../../wmsui/src/components/Upload) 下）：
  - `FileUpload.vue`：通用文件上传（按钮触发、多文件、上传进度、下载、删除）；
  - `SingleImageUpload.vue`：单张图片上传（picture-card 卡片式、预览、删除、格式/大小校验）；
  - `MultiImageUpload.vue`：多张图片上传（图片墙、批量预览（`el-image-viewer`）、删除、格式/大小校验）；
- **API 封装**（[api/file/index.ts](../../wmsui/src/api/file/index.ts)）：`upload`（FormData + 进度回调）/ `uploadFile`（直接传 File）/ `delete`（删除）/ `download`（blob 下载）；
- **使用场景**：用户头像上传（[views/profile/index.vue](../../wmsui/src/views/profile/index.vue) 中直接使用 `FileAPI.uploadFile` + `UserAPI.updateProfile` 保存 avatar）。

> ⚠️ **后端接口状态**：后端 `FileController`（`/api/v1/files`）的上传/删除接口当前已整体**下线**（代码整体注释），原因为安全整改：C-03（MinIO 桶被设为公共读写，任意匿名者可读写删桶内文件）、C-04（上传无类型/大小/文件名校验、删除无权限校验且存在路径穿越）。当前头像上传功能实际依赖前端直传调用，恢复接口需先完成桶改私有（预签名 URL）与上传/删除加固。

> 说明：代码中**没有**硬编码 `oss.type`、目录前缀等上传参数——上传组件通过 `data` prop 透传任意附加字段到 FormData（如 `oss.type`、`prefix` 等由调用方决定），后端从表单字段解析；当前业务页面均未传附加参数。

## 2. 能力清单

| 能力 | 组件/API | 功能概述 |
| --- | --- | --- |
| 通用文件上传 | [components/Upload/FileUpload.vue](../../wmsui/src/components/Upload/FileUpload.vue) | 多文件选择、上传进度条、成功/失败提示、文件列表删除（同步调后端 delete）、点击文件名下载；`v-model` 双向绑定 `FileInfo[]` |
| 单图上传 | [components/Upload/SingleImageUpload.vue](../../wmsui/src/components/Upload/SingleImageUpload.vue) | picture-card 卡片样式，选中后显示图片并可点击预览（`el-image` preview）、右上角删除（仅清空本地 modelValue，不调后端）；`v-model` 绑定图片 URL 字符串 |
| 多图上传 | [components/Upload/MultiImageUpload.vue](../../wmsui/src/components/Upload/MultiImageUpload.vue) | 图片墙多选，支持缩放预览（`el-image-viewer`）、删除（调后端 delete）、数量限制；`v-model` 绑定 URL 数组 |
| 头像上传 | [views/profile/index.vue](../../wmsui/src/views/profile/index.vue) | 隐藏的原生 `<input type="file">` + `FileAPI.uploadFile(file)` 直传，成功后 `UserAPI.updateProfile({avatar: url})` 保存并同步刷新 store 与页面显示 |
| 文件下载 | `FileAPI.download` | `responseType: "blob"` 获取二进制，创建 `<a>` 标签触发下载 |

> 说明：`SingleImageUpload.vue` / `MultiImageUpload.vue` / `FileUpload.vue` 目前**未被任何业务页面 import**（已全库检索确认），属于可复用的通用组件库；当前唯一的上传落地场景是 profile 页面的头像上传（原生 input 方案）。

## 3. 后端接口

### 3.1 FileAPI（[api/file/index.ts](../../wmsui/src/api/file/index.ts)）

| API 函数名 | HTTP 方法与路径 | 说明 |
| --- | --- | --- |
| `upload(formData: FormData, onProgress?)` | POST `/api/v1/files` | 上传文件；请求头 `Content-Type: multipart/form-data`；可选 `onUploadProgress` 进度回调（返回 0-100 百分比）；返回 `FileInfo{name, url}` |
| `uploadFile(file: File)` | POST `/api/v1/files` | 简化版：内部构造 FormData（字段名 `file`）后走 `upload`，无进度回调 |
| `delete(filePath?: string)` | DELETE `/api/v1/files?filePath=xxx` | 按文件路径删除已上传文件 |
| `download(url: string, fileName?)` | GET `{url}`（任意文件 URL） | `responseType: "blob"` 下载，`Blob` 包装后通过 `<a download>` 触发浏览器下载 |

### 3.2 后端实现（[FileController.java](../../wms/src/main/java/com/wms/file/controller/FileController.java)）

| 端点 | 状态 | 说明 |
| --- | --- | --- |
| `POST /api/v1/files` | ⚠️ 已注释下线 | 原为 multipart 上传（`@RequestPart("file") MultipartFile`），因 C-03/C-04 安全问题整体下线 |
| `DELETE /api/v1/files?filePath=` | ⚠️ 已注释下线 | 原为按路径删除，因无权限校验 + 路径穿越漏洞下线 |
| 存储后端 | — | `MinioFileServiceImpl` / `AliyunFileServiceImpl`（MinIO / 阿里云 OSS 双实现，通过 FileService 接口切换） |

> 前端 API 方法仍保留调用（未删除），接口恢复后即可直接使用。

## 4. 文件清单

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
| --- | --- | --- | --- |
| [components/Upload/FileUpload.vue](../../wmsui/src/components/Upload/FileUpload.vue) | 通用文件上传组件 | `element-plus`（el-upload/el-button/el-progress/el-icon、UploadFile/UploadFiles/UploadRawFile/UploadRequestOptions 类型）、`@element-plus/icons-vue`（Document/Close）、`@/api/file`（FileAPI/FileInfo） | ①`http-request` 自定义上传：FormData 组装（文件 + `props.data` 附加字段）→ `FileAPI.upload`，按 `file.uid` 回写进度百分比；②`before-upload` 校验单文件大小（默认 10MB）；③`on-success`：全部完成才合并 `FileInfo[]` 到 modelValue，失败项从 fileList 剔除；④删除调用 `FileAPI.delete(fileUrl)` 后过滤 modelValue；⑤下载调用 `FileAPI.download(url, name)`；⑥`watch` modelValue 同步显示（url 无 name 时取最后一段路径）；`getUid()` 生成 64 位随机 uid |
| [components/Upload/SingleImageUpload.vue](../../wmsui/src/components/Upload/SingleImageUpload.vue) | 单图上传组件 | `element-plus`（el-upload/el-image/el-icon、UploadRawFile/UploadRequestOptions）、`@element-plus/icons-vue`（Plus/CircleCloseFilled）、`@/api/file`（FileAPI/FileInfo） | ①`list-type="picture-card"` + `show-file-list=false`，未上传显示加号、已上传显示缩略图 + 角标删除按钮；②`before-upload` 严格校验：`image/*` 按 MIME 前缀、`.png` 按扩展名、具体 MIME 全等匹配，超限 `maxFileSize`（默认 10MB）拦截；③上传成功 `modelValue = fileInfo.url`；④删除仅置空 modelValue（不调后端）；⑤样式宽高通过 `props.style` 用 CSS `v-bind` 动态注入 |
| [components/Upload/MultiImageUpload.vue](../../wmsui/src/components/Upload/MultiImageUpload.vue) | 多图上传组件 | `element-plus`（el-upload/el-icon/el-image-viewer、UploadRawFile/UploadRequestOptions/UploadUserFile）、`@element-plus/icons-vue`（Plus/ZoomIn/Delete）、`@/api/file`（FileAPI/FileInfo） | ①图片墙 + `limit`（默认 10 张）；②`before-upload` 与单图相同的类型/大小双校验；③上传成功按 uid 定位索引，同步回写 fileList 与 modelValue 对应下标；④删除调 `FileAPI.delete` 后 splice 双向移除；⑤`el-image-viewer` 预览（记录 `previewImageIndex`）；⑥`onMounted`/`watch` 将 URL 数组映射为 UploadUserFile 显示 |
| [api/file/index.ts](../../wmsui/src/api/file/index.ts) | 文件 API 封装 | `@/utils/request`（axios）、`./types`（FileInfo） | 4 个方法：upload（multipart + onUploadProgress 百分比）、uploadFile（封装 FormData）、delete（query 传 filePath）、download（blob + `<a>` 触发） |
| [api/file/types.ts](../../wmsui/src/api/file/types.ts) | 文件类型定义 | 无（纯类型） | `FileInfo{name, url}`：上传返回的统一文件信息 |
| [views/profile/index.vue](../../wmsui/src/views/profile/index.vue) | 个人中心（头像上传场景） | `element-plus`（el-avatar/el-button/el-dialog/el-form/el-input/el-tag/el-icon 等）、`@element-plus/icons-vue`（Camera/UserFilled 等）、`@/api/system/user`（UserAPI）、`@/api/file`（FileAPI）、`@/stores`（useUserStoreHook）、`@/utils/auth`（redirectToLogin） | ①`triggerFileUpload()` 触发隐藏 input；②`handleFileChange`：`FileAPI.uploadFile(file)` 上传 → `UserAPI.updateProfile({avatar: data.url})` → 更新 `userProfile.avatar` 与 `userStore.userInfo.avatar` → `ElMessage.success("头像更新成功")`；③页面还包含资料编辑、修改密码、手机/邮箱绑定解绑、近期登录等能力（非 file 模块范围） |

## 5. 核心实现逻辑

### 5.1 三种上传组件的差异

| 维度 | FileUpload | SingleImageUpload | MultiImageUpload |
| --- | --- | --- | --- |
| modelValue 类型 | `FileInfo[]` | `string`（图片 URL） | `string[]`（URL 数组） |
| 上传样式 | 按钮 + 文件列表 | picture-card 单卡片 | picture-card 图片墙 |
| 多文件 | 支持（multiple） | 单张 | 支持（multiple + limit） |
| 进度显示 | el-progress 百分比 | 无（上传中按钮 loading 态由 el-upload 管理） | 无 |
| 删除行为 | 调 `FileAPI.delete` | 仅本地置空 | 调 `FileAPI.delete` |
| 下载能力 | 支持（点击文件名） | 无 | 无 |
| 预览 | 无 | el-image 单击预览 | el-image-viewer（可缩放） |
| 类型校验 | 仅大小 | 大小 + 格式（image/*、扩展名、MIME 三类） | 大小 + 格式（同左） |
| 附加参数 | `props.data` 透传 FormData | 同左 | 同左 |

### 5.2 上传参数与回显

- **上传参数**：`props.name`（表单字段名，默认 `file`）+ `props.data`（任意附加字段，如 `oss.type`、目录前缀等，透传到 FormData，由后端解析——当前代码无硬编码参数）；
- **回显机制**：
  - FileUpload：`watch(modelValue)` 将 `FileInfo[]` 映射为 `UploadFile[]`（`status: "success"`）展示；上传完成后只合并带 `response` 的新文件，避免重复；
  - SingleImageUpload：直接绑定图片 URL，`v-if="modelValue"` 控制缩略图与删除按钮；
  - MultiImageUpload：`onMounted` + `watch(modelValue)` 将 URL 数组映射为 `{url}` 列表展示，上传成功按 uid 同步下标更新。

### 5.3 头像上传链路（profile 页）

```
点击相机按钮 → triggerFileUpload() → 隐藏 input.click()
        ↓
handleFileChange（input[type=file].change）：
  ① FileAPI.uploadFile(file) → POST /api/v1/files（multipart，字段名 file）
  ② UserAPI.updateProfile({ avatar: data.url }) → PATCH/PUT /api/v1/users/profile
  ③ userProfile.avatar = data.url；userStore.userInfo.avatar = data.url（全局即时生效）
  ④ ElMessage.success("头像更新成功")；重置 input.value 以便再次选择同一文件
```

## 6. 技术栈

- **框架**：Vue 3.5（`<script setup>`、`defineModel`、`v-bind` CSS 变量注入）+ TypeScript
- **UI**：Element Plus（el-upload 的 `http-request` 自定义上传模式、el-image/el-image-viewer、el-progress、el-icon）+ `@element-plus/icons-vue`
- **HTTP**：axios（multipart/form-data 请求、`onUploadProgress` 进度回调、blob 响应下载），封装于 `@/utils/request`
- **存储方案**：后端 MinIO / 阿里云 OSS（`FileService` 接口双实现，前端无感知）
- **构建**：Vite（`@` 别名）
