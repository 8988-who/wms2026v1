package com.wms.rcs.controller;

import com.wms.rcs.service.AgvService;
import com.wms.common.result.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.rcs.controller
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 10:20
 * @Description: AGVController
 * @Version: 1.0
 */
@Tag(name = "AGV")
@RestController
@RequestMapping("/api/v1/agv")
public class AgvController {
    @Autowired
    private AgvService agvService;

    @PostMapping("/commonRequest/{methodName}")
    @Operation(method = "通用请求接口")
    public Result<Object> commonRequest(@PathVariable String methodName, @RequestBody Map<String ,Object> params) {
        return agvService.commonRequest(methodName, params);
    }
}
