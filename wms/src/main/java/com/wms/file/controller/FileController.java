package com.wms.file.controller;

import com.wms.common.result.Result;
import com.wms.file.service.FileService;
import com.wms.file.model.FileInfo;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * 文件控制层
 *
 * @author Ray.Hao
 * @since 2022/10/16
 */
@Tag(name = "10.文件接口")
@RestController
@RequestMapping("/api/v1/files")
@RequiredArgsConstructor
public class FileController {

    private final FileService fileService;

    // ⚠️ 文件上传/删除接口已下线（C-03）：
    //   1. MinIO 桶被 MinioFileServiceImpl.createBucketIfAbsent 自动设为「公共读写」，任意匿名者可读/写/删桶内文件（严重漏洞）；
    //   2. 上传无类型/大小/文件名校验，删除接口无权限校验且存在路径穿越（C-04）。
    // 当前该功能仅用于「用户头像上传」，核心 WMS 业务未使用，故整体下线以消除风险。
    // 恢复前置条件：先完成 C-03（桶改私有 + 预签名 URL）与 C-04（上传/删除加固）后，再取消以下注释。
    // 注：本次仅下线接口，未改动 MinIO 桶策略与已上传文件，存量头像 URL 不受影响（不会图裂）。

    // @PostMapping
    // @Operation(summary = "文件上传")
    // public Result<FileInfo> uploadFile(
    //         @Parameter(
    //                 name = "file",
    //                 description = "表单文件对象",
    //                 required = true,
    //                 in = ParameterIn.DEFAULT,
    //                 schema = @Schema(name = "file", format = "binary")
    //         )
    //         @RequestPart(value = "file") MultipartFile file
    // ) {
    //     FileInfo fileInfo = fileService.uploadFile(file);
    //     return Result.success(fileInfo);
    // }

    // @DeleteMapping
    // @Operation(summary = "文件删除")
    // @SneakyThrows
    // public Result<?> deleteFile(
    //         @Parameter(description = "文件路径") @RequestParam String filePath
    // ) {
    //     boolean result = fileService.deleteFile(filePath);
    //     return Result.judge(result);
    // }
}
