package com.wms.business.plc.controller;

import com.wms.business.plc.PlcAdapterService;
import com.wms.business.plc.domain.TWmsPlcConnection;
import com.wms.business.plc.domain.TWmsPlcLocationConfig;
import com.wms.business.plc.domain.TWmsPlcReplenishmentConfig;
import com.wms.business.plc.domain.TWmsPlcSignalConfig;
import com.wms.business.plc.manager.PlcConnectionManager;
import com.wms.business.plc.service.PlcLocationConfigService;
import com.wms.business.plc.service.PlcReplenishmentConfigService;
import com.wms.common.core.controller.BaseController;
import com.wms.common.core.domain.R;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

/**
 * PLC 连接管理接口
 * <p>
 * 提供前端面板所需的 PLC 增删改查、信号配置和状态查询功能。
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.controller
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC管理Controller
 * @Version: 1.0
 */
@RestController
@RequestMapping("/plc")
public class PlcController extends BaseController {

    @Resource
    private PlcAdapterService plcAdapterService;

    @Resource
    private PlcLocationConfigService plcLocationConfigService;

    @Resource
    private PlcReplenishmentConfigService plcReplenishmentConfigService;

    // ==================== 连接管理 ====================

    /** 查询所有 PLC 连接状态 */
    @GetMapping("/list")
    public R<List<PlcConnectionManager.PlcStatusVO>> list() {
        return R.ok(plcAdapterService.listStatus());
    }

    /** 新增 PLC 连接 */
    @PostMapping("/add")
    public R<Void> add(@RequestBody TWmsPlcConnection config) {
        plcAdapterService.addConnection(config);
        return R.ok();
    }

    /** 更新 PLC 配置 */
    @PutMapping("/update")
    public R<Void> update(@RequestBody TWmsPlcConnection config) {
        plcAdapterService.updateConnection(config);
        return R.ok();
    }

    /** 启用指定 PLC */
    @PutMapping("/{plcId}/enable")
    public R<Void> enable(@PathVariable String plcId) {
        plcAdapterService.enableConnection(plcId);
        return R.ok();
    }

    /** 禁用指定 PLC */
    @PutMapping("/{plcId}/disable")
    public R<Void> disable(@PathVariable String plcId) {
        plcAdapterService.disableConnection(plcId);
        return R.ok();
    }

    /** 删除 PLC 配置 */
    @DeleteMapping("/{plcId}")
    public R<Void> delete(@PathVariable String plcId) {
        plcAdapterService.deleteConnection(plcId);
        return R.ok();
    }

    /** 重连指定 PLC */
    @PostMapping("/{plcId}/reconnect")
    public R<Void> reconnect(@PathVariable String plcId) {
        plcAdapterService.reconnect(plcId);
        return R.ok();
    }

    // ==================== 信号配置 ====================

    /** 查询指定 PLC 的信号配置列表 */
    @GetMapping("/{plcId}/signal/list")
    public R<List<TWmsPlcSignalConfig>> signalList(@PathVariable String plcId) {
        return R.ok(plcAdapterService.listSignals(plcId));
    }

    /** 新增信号配置 */
    @PostMapping("/signal/add")
    public R<TWmsPlcSignalConfig> signalAdd(@RequestBody TWmsPlcSignalConfig config) {
        return R.ok(plcAdapterService.addSignal(config));
    }

    /** 更新信号配置 */
    @PutMapping("/signal/update")
    public R<Void> signalUpdate(@RequestBody TWmsPlcSignalConfig config) {
        plcAdapterService.updateSignal(config);
        return R.ok();
    }

    /** 启用信号 */
    @PutMapping("/signal/{signalId}/enable")
    public R<Void> signalEnable(@PathVariable String signalId) {
        plcAdapterService.enableSignal(signalId);
        return R.ok();
    }

    /** 禁用信号 */
    @PutMapping("/signal/{signalId}/disable")
    public R<Void> signalDisable(@PathVariable String signalId) {
        plcAdapterService.disableSignal(signalId);
        return R.ok();
    }

    /** 删除信号 */
    @DeleteMapping("/signal/{signalId}")
    public R<Void> signalDelete(@PathVariable String signalId) {
        plcAdapterService.deleteSignal(signalId);
        return R.ok();
    }

    // ==================== 工位地标码配置 ====================

    /** 查询工位地标码列表（可按 PLC 筛选） */
    @GetMapping("/location/list")
    public R<List<TWmsPlcLocationConfig>> locationList(@RequestParam(required = false) String plcId) {
        return R.ok(plcLocationConfigService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<TWmsPlcLocationConfig>()
                        .eq(plcId != null, TWmsPlcLocationConfig::getPlcId, plcId)
                        .orderByAsc(TWmsPlcLocationConfig::getAddress, TWmsPlcLocationConfig::getArrIdx)));
    }

    /** 新增工位地标码 */
    @PostMapping("/location/add")
    public R<TWmsPlcLocationConfig> locationAdd(@RequestBody TWmsPlcLocationConfig config) {
        plcLocationConfigService.save(config);
        return R.ok(config);
    }

    /** 更新工位地标码 */
    @PutMapping("/location/update")
    public R<Void> locationUpdate(@RequestBody TWmsPlcLocationConfig config) {
        plcLocationConfigService.updateById(config);
        return R.ok();
    }

    /** 删除工位地标码 */
    @DeleteMapping("/location/{id}")
    public R<Void> locationDelete(@PathVariable String id) {
        plcLocationConfigService.removeById(id);
        return R.ok();
    }

    // ==================== 补料参数配置 ====================

    /** 查询补料参数列表（可按 PLC 筛选） */
    @GetMapping("/replenishment/list")
    public R<List<TWmsPlcReplenishmentConfig>> replenishmentList(@RequestParam(required = false) String plcId) {
        return R.ok(plcReplenishmentConfigService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<TWmsPlcReplenishmentConfig>()
                        .eq(plcId != null, TWmsPlcReplenishmentConfig::getPlcId, plcId)
                        .orderByAsc(TWmsPlcReplenishmentConfig::getAddress, TWmsPlcReplenishmentConfig::getTriggerValue)));
    }

    /** 新增补料参数 */
    @PostMapping("/replenishment/add")
    public R<TWmsPlcReplenishmentConfig> replenishmentAdd(@RequestBody TWmsPlcReplenishmentConfig config) {
        plcReplenishmentConfigService.save(config);
        return R.ok(config);
    }

    /** 更新补料参数 */
    @PutMapping("/replenishment/update")
    public R<Void> replenishmentUpdate(@RequestBody TWmsPlcReplenishmentConfig config) {
        plcReplenishmentConfigService.updateById(config);
        return R.ok();
    }

    /** 删除补料参数 */
    @DeleteMapping("/replenishment/{id}")
    public R<Void> replenishmentDelete(@PathVariable String id) {
        plcReplenishmentConfigService.removeById(id);
        return R.ok();
    }
}
