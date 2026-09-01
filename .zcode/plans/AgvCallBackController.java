package com.wms.business.agv.controller;

import com.wms.business.agv.service.IAgvService;
import com.wms.business.agv.vo.AgvBackResVo;
import com.wms.common.core.controller.BaseController;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * AGVController
 *
 * @author Josh Xu
 * @date 2024-07-03
 */
@Api(tags = "AGV回调接口")
@RestController
@RequestMapping("/business/agv/agvCallbackService")
public class AgvCallBackController extends BaseController {

    @Resource
    private IAgvService iAgvService;

    @PostMapping("/agvCallBack")
    @ApiOperation("AGV任务执行通知回调")
    public AgvBackResVo agvCallback(HttpServletRequest request, @RequestBody Map<String, Object> params) {
        System.out.println("================AGV任务执行通知回调====================");
        System.out.println("params = " + params);
        return iAgvService.agvCallback(request, params);
    }

    @PostMapping("/warnCallback")
    @ApiOperation("AGV告警推送通知回调")
    public AgvBackResVo warnCallback(HttpServletRequest request, @RequestBody Map<String, Object> params) {
        return iAgvService.warnCallback(request, params);
    }

}
