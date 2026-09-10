<template>
  <el-drawer
    v-model="visible"
    title="任务详情"
    size="620px"
    :destroy-on-close="true"
  >
    <div v-loading="loading">
      <!-- 异常信息醒目提示 -->
      <el-alert
        v-if="detail.errorMsg"
        :title="`异常信息：${detail.errorMsg}`"
        type="error"
        :closable="false"
        show-icon
        style="margin-bottom: 16px"
      />

      <!-- 任务全字段 -->
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="任务编号">{{ detail.taskCode || "-" }}</el-descriptions-item>
        <el-descriptions-item label="任务标题">{{ detail.taskTitle || "-" }}</el-descriptions-item>
        <el-descriptions-item label="任务类型">{{ detail.taskTypeLabel || "-" }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="statusTagType(detail.status)">{{ detail.statusLabel || detail.status }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="优先级">
          <el-tag :type="priorityTagType(detail.priority)">{{ detail.priorityLabel || detail.priority }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="AGV 编号">{{ detail.agvCode || "-" }}</el-descriptions-item>
        <el-descriptions-item label="源位置">{{ detail.fromLocation || "-" }}</el-descriptions-item>
        <el-descriptions-item label="目标位置">{{ detail.toLocation || "-" }}</el-descriptions-item>
        <el-descriptions-item label="关联料车">{{ detail.cartCode || "-" }}</el-descriptions-item>
        <el-descriptions-item label="RCS 任务ID">{{ detail.rcsTaskId || "-" }}</el-descriptions-item>
        <el-descriptions-item label="提交时间">{{ detail.submitTime || "-" }}</el-descriptions-item>
        <el-descriptions-item label="派发时间">{{ detail.assignedAt || "-" }}</el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ detail.startTime || "-" }}</el-descriptions-item>
        <el-descriptions-item label="完成时间">{{ detail.finishTime || "-" }}</el-descriptions-item>
        <el-descriptions-item label="创建人">{{ detail.createdByName || "-" }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ detail.createdTime || "-" }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ detail.remark || "-" }}</el-descriptions-item>
        <el-descriptions-item label="扩展参数" :span="2">
          <span v-if="payloadText">{{ payloadText }}</span>
          <span v-else>-</span>
        </el-descriptions-item>
      </el-descriptions>

      <!-- 状态变更时间线 -->
      <el-divider content-position="left">状态变更历史</el-divider>
      <el-timeline v-if="detail.lifecycles && detail.lifecycles.length > 0">
        <el-timeline-item
          v-for="(item, index) in detail.lifecycles"
          :key="item.id ?? index"
          :timestamp="item.createTime"
          :type="timelineNodeType(item.statusTo)"
        >
          <div class="lifecycle-line">
            {{ item.statusFromLabel ?? "—" }} → <strong>{{ item.statusToLabel ?? item.statusTo }}</strong>
          </div>
          <div class="lifecycle-meta">
            操作者：{{ item.operatorType || "-" }}
            <span v-if="item.operatorId">（{{ item.operatorId }}）</span>
            <span v-if="item.remark"> · {{ item.remark }}</span>
          </div>
        </el-timeline-item>
      </el-timeline>
      <el-empty v-else description="暂无状态变更记录" :image-size="80" />
    </div>
  </el-drawer>
</template>

<script setup lang="ts">
  import { ref, reactive, computed } from "vue";
  import RcsTaskAPI, { type RcsTaskItem } from "@/api/rcs/rcs-task";

  defineOptions({
    name: "TaskDetailDrawer",
    inheritAttrs: false,
  });

  const visible = ref(false);
  const loading = ref(false);
  const detail = reactive<RcsTaskItem>({} as RcsTaskItem);

  const payloadText = computed(() => {
    if (!detail.payload || Object.keys(detail.payload).length === 0) return "";
    try {
      return JSON.stringify(detail.payload);
    } catch {
      return "";
    }
  });

  /** 状态 tag 颜色（0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常） */
  function statusTagType(status?: number): "primary" | "success" | "warning" | "info" | "danger" {
    switch (status) {
      case 1:
        return "primary";
      case 2:
        return "warning";
      case 3:
        return "success";
      case 5:
        return "danger";
      default:
        return "info";
    }
  }

  /** 优先级 tag 颜色（1-低 2-中 3-高 4-紧急） */
  function priorityTagType(priority?: number): "primary" | "warning" | "info" | "danger" {
    switch (priority) {
      case 2:
        return "primary";
      case 3:
        return "warning";
      case 4:
        return "danger";
      default:
        return "info";
    }
  }

  /** 时间线节点色（按变更后状态：异常 danger / 完成 success / 其余 primary） */
  function timelineNodeType(statusTo?: number): "primary" | "success" | "danger" {
    if (statusTo === 5) return "danger";
    if (statusTo === 3) return "success";
    return "primary";
  }

  /** 打开抽屉并加载详情 */
  async function open(id: string): Promise<void> {
    visible.value = true;
    // 清空上一条详情
    Object.keys(detail).forEach((key) => {
      delete (detail as Record<string, unknown>)[key];
    });
    loading.value = true;
    try {
      const data = await RcsTaskAPI.getDetail(id);
      Object.assign(detail, data);
    } finally {
      loading.value = false;
    }
  }

  defineExpose({ open });
</script>

<style scoped>
  .lifecycle-line {
    font-size: 14px;
  }

  .lifecycle-meta {
    margin-top: 4px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }
</style>
