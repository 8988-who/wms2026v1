package com.wms.warehouse.utils;

import cn.hutool.core.util.StrUtil;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.function.Supplier;

/**
 * 仓库编码生成服务（基于 Redis INCR 原子自增）
 * <p>
 * 使用 Redis 的 INCR 命令保证高并发下编码不重复。
 * 首次使用某个前缀时，会从数据库查询最大已有序号并初始化，
 * 后续直接原子递增，无需重复查库。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-24
 */
@Slf4j
@Service
public class WmsCodeGeneratorService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    private static final String REDIS_KEY_PREFIX = "code:seq:";

    /**
     * 编码序列初始化 CAS 脚本（R-5 修复）：仅当序列仍为初始值 "0" 时，才覆写为库内最大序号。
     * 若序号已被其他线程 INCR 分发过（值 != "0"）则放弃覆写，避免已分发的序号被覆盖回退，
     * 消除"SETNX("0") 后再 set(maxSeq)"两段式非原子的竞态窗口。
     */
    private static final DefaultRedisScript<Boolean> INIT_SEQ_CAS_SCRIPT = new DefaultRedisScript<>(
            "if redis.call('get', KEYS[1]) == '0' then redis.call('set', KEYS[1], ARGV[1]) return 1 else return 0 end",
            Boolean.class);

    /**
     * 生成库位/区域编码
     * <p>
     * 格式：{plantCode}-{3位序号}（如 PLANT001-001）
     *
     * @param plantCode         厂区编码
     * @param maxSeqSupplier    最大已有序号供应器（首次初始化时使用）
     * @return 库位编码
     */
    public String generateLocationCode(String plantCode, Supplier<Integer> maxSeqSupplier) {
        String key = REDIS_KEY_PREFIX + "location:" + plantCode;
        initSeqIfAbsent(key, maxSeqSupplier);
        long seq = stringRedisTemplate.opsForValue().increment(key);
        log.debug("生成库位编码: plantCode={}, key={}, seq={}", plantCode, key, seq);
        return plantCode + "-" + String.format("%03d", seq);
    }

    /**
     * 生成巷道编码
     * <p>
     * 格式：{locationCode}-{prefix}{3位序号}（如 PLANT001-001-A001）
     *
     * @param locationCode      所属区域编码
     * @param prefix            巷道前缀（如 "A"）
     * @param maxSeqSupplier    最大已有序号供应器（首次初始化时使用）
     * @return 巷道编码
     */
    public String generateAisleCode(String locationCode, String prefix, Supplier<Integer> maxSeqSupplier) {
        String key = REDIS_KEY_PREFIX + "aisle:" + locationCode + ":" + prefix;
        initSeqIfAbsent(key, maxSeqSupplier);
        long seq = stringRedisTemplate.opsForValue().increment(key);
        log.debug("生成巷道编码: locationCode={}, prefix={}, key={}, seq={}", locationCode, prefix, key, seq);
        return locationCode + "-" + prefix + String.format("%03d", seq);
    }

    /**
     * 生成点位编码
     * <p>
     * 格式：{前缀}-P{3位序号}（如巷道点位 PLANT001-A001-P001，离散点位 PLANT001-001-P001）
     *
     * @param codePrefix        编码前缀：巷道点位传巷道编码，离散点位传区域编码
     * @param maxSeqSupplier    最大已有序号供应器（首次初始化时使用）
     * @return 点位编码
     */
    public String generatePointCode(String codePrefix, Supplier<Integer> maxSeqSupplier) {
        String key = REDIS_KEY_PREFIX + "point:" + codePrefix;
        initSeqIfAbsent(key, maxSeqSupplier);
        long seq = stringRedisTemplate.opsForValue().increment(key);
        log.debug("生成点位编码: codePrefix={}, key={}, seq={}", codePrefix, key, seq);
        return codePrefix + "-P" + String.format("%03d", seq);
    }

    /**
     * 如果 Redis key 不存在，则从数据库初始化序号
     * <p>
     * setIfAbsent 是原子操作，多线程并发时只有一个线程会初始化成功；
     * 初始化成功后以 Lua CAS 将序号覆写为库内最大值（仅当仍为初始值 "0" 时），
     * 与并发 INCR 竞态时放弃覆写（R-5 修复）。
     * </p>
     */
    private void initSeqIfAbsent(String key, Supplier<Integer> maxSeqSupplier) {
        Boolean notExist = stringRedisTemplate.opsForValue().setIfAbsent(key, "0");
        if (Boolean.TRUE.equals(notExist) && maxSeqSupplier != null) {
            Integer maxSeq = maxSeqSupplier.get();
            if (maxSeq != null && maxSeq > 0) {
                // R-5 修复：Lua CAS 原子覆写，杜绝"并发线程已 INCR 分发后又被 set 覆盖"的窗口
                stringRedisTemplate.execute(INIT_SEQ_CAS_SCRIPT, List.of(key), String.valueOf(maxSeq));
                log.debug("初始化编码序列: key={}, maxSeq={}", key, maxSeq);
            }
        }
    }

    /**
     * 清理指定前缀的编码序列缓存（修改厂区编码时使用）
     *
     * @param key Redis key
     */
    public void deleteSeqCache(String key) {
        stringRedisTemplate.delete(REDIS_KEY_PREFIX + key);
        log.debug("删除编码序列缓存: key={}", key);
    }

    /**
     * 从编码中提取最大序号，用于初始化 Redis 序列
     * <p>
     * 例如：extractSeq("PLANT001-005", "PLANT001-") → 5
     *
     * @param code   编码字符串
     * @param prefix 编码前缀（不含序号部分）
     * @return 序号；如果编码为空或格式不对返回 0
     */
    public static int extractSeq(String code, String prefix) {
        if (StrUtil.isBlank(code) || !code.startsWith(prefix)) {
            return 0;
        }
        try {
            return Integer.parseInt(code.substring(prefix.length()));
        } catch (NumberFormatException e) {
            log.warn("编码格式异常: code={}, prefix={}", code, prefix);
            return 0;
        }
    }

}
