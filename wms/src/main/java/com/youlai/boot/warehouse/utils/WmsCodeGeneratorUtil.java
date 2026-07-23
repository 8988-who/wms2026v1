package com.youlai.boot.warehouse.utils;

import cn.hutool.core.util.StrUtil;
import lombok.extern.slf4j.Slf4j;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.function.Supplier;

/**
 * 仓库编码生成工具类
 * <p>
 * 提供库位/区域、巷道、点位编码的自动生成功能，基于前缀+3位递增序号规则，
 * 支持查询已有编码避免重复。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Slf4j
public final class WmsCodeGeneratorUtil {

    private WmsCodeGeneratorUtil() {
    }

    /**
     * 生成库位/区域编码
     * <p>
     * 格式：厂区编码-3位序号（如 PLANT001-001），序号从001开始递增，跳过已存在的编码。
     *
     * @param plantCode            厂区编码
     * @param existingCodesSupplier 已有编码列表供应器
     * @return 生成的库位/区域编码
     */
    public static String generateLocationCode(String plantCode, Supplier<List<String>> existingCodesSupplier) {
        int nextSeq = findNextSequence(plantCode, existingCodesSupplier.get());
        return plantCode + "-" + String.format("%03d", nextSeq);
    }

    /**
     * 生成巷道编码
     * <p>
     * 格式：厂区编码-巷道前缀+3位序号（如 PLANT001-A001），序号从001开始递增，跳过已存在的编码。
     *
     * @param plantCode            厂区编码
     * @param aislePrefix          巷道前缀（如 "A"）
     * @param existingCodesSupplier 已有编码列表供应器
     * @return 生成的巷道编码
     */
    public static String generateAisleCode(String plantCode, String aislePrefix, Supplier<List<String>> existingCodesSupplier) {
        int nextSeq = findNextSequence(plantCode + "-" + aislePrefix, existingCodesSupplier.get());
        return plantCode + "-" + aislePrefix + String.format("%03d", nextSeq);
    }

    /**
     * 生成点位编码
     * <p>
     * 格式：巷道编码-P+3位序号（如 PLANT001-A001-P001），序号从001开始递增，跳过已存在的编码。
     *
     * @param plantCode            巷道编码（实际传入的是巷道编码）
     * @param existingCodesSupplier 已有编码列表供应器
     * @return 生成的点位编码
     */
    public static String generatePointCode(String plantCode, Supplier<List<String>> existingCodesSupplier) {
        int nextSeq = findNextSequence(plantCode + "-P", existingCodesSupplier.get());
        return plantCode + "-P" + String.format("%03d", nextSeq);
    }

    private static int findNextSequence(String prefix, List<String> existingCodes) {
        Set<Integer> usedSeqs = new HashSet<>();
        int prefixLen = prefix.length();
        for (String code : existingCodes) {
            if (StrUtil.isNotBlank(code) && code.startsWith(prefix)) {
                try {
                    int seq = Integer.parseInt(code.substring(prefixLen));
                    usedSeqs.add(seq);
                } catch (NumberFormatException e) {
                    log.warn("Invalid code format: {}", code);
                }
            }
        }
        int seq = 1;
        while (usedSeqs.contains(seq)) {
            seq++;
        }
        return seq;
    }

}