package com.wms.common.service;

import cn.hutool.core.collection.CollectionUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.common.constant.SystemConstants;
import com.wms.common.enums.DataScopeEnum;
import com.wms.framework.security.model.RoleDataScope;
import com.wms.framework.security.util.SecurityUtils;
import com.wms.system.mapper.DeptMapper;
import com.wms.system.model.entity.Dept;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 厂区编码数据权限服务
 * <p>
 * 根据当前用户登录态中已缓存的数据权限信息（{@link RoleDataScope}），
 * 解析用户可访问的 plantCode 列表。
 * 子部门自动继承父部门的 plantCode。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-24
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PlantCodeScopeService {

    private final DeptMapper deptMapper;

    /**
     * 获取当前用户可访问的 plantCode 列表。
     * <p>
     * 管理员/有 ALL 权限的角色返回 null（无限制）；
     * 非管理员根据角色数据范围解析可访问的 plantCode 集合（多角色并集）。
     * </p>
     *
     * @return 可访问的 plantCode 列表，null 表示全部可访问
     */
    public List<String> getAccessiblePlantCodes() {
        // 未登录或超级管理员 → 不限制
        if (SecurityUtils.getUserId() == null || SecurityUtils.isRoot()) {
            return null;
        }

        // 从当前用户的登录态中获取数据权限列表（已由认证服务缓存）
        List<RoleDataScope> dataScopes = SecurityUtils.getUser()
                .map(user -> user.getDataScopes())
                .orElse(List.of());

        if (CollectionUtil.isEmpty(dataScopes)) {
            return Collections.emptyList();
        }

        // 如果任一角色是 ALL，则跳过过滤（并集策略）
        boolean hasAll = dataScopes.stream()
                .anyMatch(ds -> DataScopeEnum.ALL.getValue().equals(ds.getDataScope()));
        if (hasAll) {
            return null;
        }

        // 并集：合并所有角色的数据权限
        Set<String> plantCodes = new LinkedHashSet<>();
        for (RoleDataScope scope : dataScopes) {
            List<String> rolePlantCodes = resolvePlantCodesByScope(scope);
            if (rolePlantCodes != null) {
                plantCodes.addAll(rolePlantCodes);
            }
        }

        return new ArrayList<>(plantCodes);
    }

    /**
     * 根据单个角色的数据范围解析 plantCode 列表
     */
    private List<String> resolvePlantCodesByScope(RoleDataScope scope) {
        if (scope == null || scope.getDataScope() == null) {
            return Collections.emptyList();
        }

        DataScopeEnum dataScopeEnum = DataScopeEnum.getByValue(scope.getDataScope());
        if (dataScopeEnum == null) {
            return Collections.emptyList();
        }

        return switch (dataScopeEnum) {
            case ALL -> null; // 由调用方处理
            case DEPT_AND_SUB -> resolveDeptAndSubPlantCodes();
            case DEPT -> resolveDeptPlantCodes();
            case SELF -> resolveSelfPlantCodes();
            case CUSTOM -> resolveCustomDeptPlantCodes(scope.getCustomDeptIds());
        };
    }

    /**
     * 本部门及子部门 → 获取部门树及所有子部门的 plantCode
     */
    private List<String> resolveDeptAndSubPlantCodes() {
        Long deptId = SecurityUtils.getDeptId();
        if (deptId == null) return Collections.emptyList();

        Set<Long> deptIds = new HashSet<>();
        deptIds.add(deptId);
        collectSubDeptIds(deptId, deptIds);
        List<Dept> depts = deptMapper.selectBatchIds(deptIds);
        return resolvePlantCodesFromDepts(depts);
    }

    /**
     * 本部门数据 → 当前部门的 plantCode
     */
    private List<String> resolveDeptPlantCodes() {
        Long deptId = SecurityUtils.getDeptId();
        if (deptId == null) return Collections.emptyList();

        Dept dept = deptMapper.selectById(deptId);
        return resolvePlantCodesFromDepts(List.of(dept));
    }

    /**
     * 本人数据 → 本人所属部门的 plantCode
     */
    private List<String> resolveSelfPlantCodes() {
        return resolveDeptPlantCodes();
    }

    /**
     * 自定义部门 → 角色分配的部门列表的 plantCode
     */
    private List<String> resolveCustomDeptPlantCodes(List<Long> customDeptIds) {
        if (CollectionUtil.isEmpty(customDeptIds)) {
            return Collections.emptyList();
        }
        List<Dept> depts = deptMapper.selectBatchIds(customDeptIds);
        return resolvePlantCodesFromDepts(depts);
    }

    /**
     * 从部门列表中解析所有有效的 plantCode（含向上递归到顶级部门）
     */
    private List<String> resolvePlantCodesFromDepts(List<Dept> depts) {
        if (CollectionUtil.isEmpty(depts)) {
            return Collections.emptyList();
        }

        Set<String> plantCodes = new LinkedHashSet<>();
        Set<Long> visited = new HashSet<>();

        for (Dept dept : depts) {
            if (dept == null) continue;
            resolvePlantCodeRecursive(dept, plantCodes, visited);
        }

        return new ArrayList<>(plantCodes);
    }

    /**
     * 递归向上查找部门的 plantCode
     * <p>
     * 如果当前部门有 plantCode 则直接使用；否则向父部门递归，直到找到有 plantCode 的部门。
     * </p>
     */
    private void resolvePlantCodeRecursive(Dept dept, Set<String> plantCodes, Set<Long> visited) {
        if (dept == null || visited.contains(dept.getId())) return;
        visited.add(dept.getId());

        if (StrUtil.isNotBlank(dept.getPlantCode())) {
            plantCodes.add(dept.getPlantCode());
            return;
        }

        // 当前部门没有 plantCode，向上找父部门
        if (dept.getParentId() != null && !SystemConstants.ROOT_NODE_ID.equals(dept.getParentId())) {
            Dept parent = deptMapper.selectById(dept.getParentId());
            if (parent != null) {
                resolvePlantCodeRecursive(parent, plantCodes, visited);
            }
        }
    }

    /**
     * 递归收集所有子部门 ID
     */
    private void collectSubDeptIds(Long parentId, Set<Long> result) {
        List<Dept> children = deptMapper.selectList(
                new LambdaQueryWrapper<Dept>()
                        .eq(Dept::getParentId, parentId)
                        .select(Dept::getId, Dept::getParentId)
        );
        for (Dept child : children) {
            if (result.add(child.getId())) {
                collectSubDeptIds(child.getId(), result);
            }
        }
    }
}
