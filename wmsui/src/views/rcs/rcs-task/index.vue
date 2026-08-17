<template>
  <div class="page-container">
    <!-- 搜索 -->
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="任务编号" prop="taskCode">
          <el-input v-model="params.taskCode" placeholder="任务编号" clearable style="width: 160px" />
        </el-form-item>
        <el-form-item label="任务类型" prop="taskType">
          <el-select v-model="params.taskType" placeholder="任务类型" clearable style="width: 120px">
            <el-option v-for="opt in TASK_TYPE_OPTIONS" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="params.status" placeholder="任务状态" clearable style="width: 120px">
            <el-option v-for="opt in STATUS_OPTIONS" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="params.priority" placeholder="优先级" clearable style="width: 120px">
            <el-option v-for="opt in PRIORITY_OPTIONS" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="AGV 编号" prop="agvCode">
          <el-input v-model="params.agvCode" placeholder="AGV 编号" clearable style="width: 140px" />
        </el-form-item>
        <el-form-item label="料车编码" prop="cartCode">
          <el-input v-model="params.cartCode" placeholder="料车编码" clearable style="width: 140px" />
        </el-form-item>
        <el-form-item label="提交时间" prop="submitTime">
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 360px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">搜索</el-button>
          <el-button @click="handleResetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格 -->
    <el-card ref="tableWrapperRef" class="page-content" shadow="never">
      <div class="page-toolbar">
        <div class="page-toolbar__left">
          <el-button
            v-hasPerm="['rcs:task:create']"
            type="primary"
            @click="handleCreateClick()"
          >新增任务</el-button>
          <el-button
            v-hasPerm="['rcs:task:delete']"
            type="danger"
            :disabled="selectedIds.length === 0"
            @click="handleDelete(selectedIds.join(','))"
          >批量删除</el-button>
        </div>
        <div class="page-toolbar__right">
          <el-tooltip content="刷新" placement="top">
            <el-button class="page-icon-btn" @click="fetchData">
              <el-icon><Refresh /></el-icon>
            </el-button>
          </el-tooltip>
          <el-tooltip content="全屏" placement="top">
            <el-button class="page-icon-btn" @click="toggleFullscreen">
              <el-icon><FullScreen /></el-icon>
            </el-button>
          </el-tooltip>
        </div>
      </div>

      <div class="page-table-wrapper">
        <el-table
          ref="dataTableRef"
          v-loading="loading"
          class="page-table"
          :data="list"
          height="100%"
          border
          highlight-current-row
          @selection-change="(rows) => { selectedIds = (rows as RcsTaskItem[]).map((r) => r.id!); }"
        >
          <el-table-column type="selection" width="50" align="center" />
          <el-table-column key="taskCode" label="任务编号" prop="taskCode" min-width="150" align="center" />
          <el-table-column key="taskTypeLabel" label="类型" prop="taskTypeLabel" min-width="80" align="center">
            <template #default="scope">
              <el-tag>{{ scope.row.taskTypeLabel || scope.row.taskType }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column key="taskTitle" label="标题" prop="taskTitle" min-width="140" align="center" show-overflow-tooltip />
          <el-table-column label="起→止" min-width="140" align="center">
            <template #default="scope">
              {{ scope.row.fromLocation || "-" }} → {{ scope.row.toLocation || "-" }}
            </template>
          </el-table-column>
          <el-table-column key="cartCode" label="料车" prop="cartCode" min-width="100" align="center" />
          <el-table-column key="status" label="状态" prop="status" min-width="90" align="center">
            <template #default="scope">
              <el-tag :type="statusTagType(scope.row.status)">{{ scope.row.statusLabel || scope.row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column key="priority" label="优先级" prop="priority" min-width="80" align="center">
            <template #default="scope">
              <el-tag :type="priorityTagType(scope.row.priority)">{{ scope.row.priorityLabel || scope.row.priority }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column key="agvCode" label="AGV 编号" prop="agvCode" min-width="110" align="center" />
          <el-table-column key="submitTime" label="提交时间" prop="submitTime" min-width="155" align="center" />
          <el-table-column key="createdByName" label="创建人" prop="createdByName" min-width="100" align="center" />
          <el-table-column fixed="right" label="操作" width="240">
            <template #default="scope">
              <el-button type="info" size="small" link @click="handleDetail(String(scope.row.id))">详情</el-button>
              <el-button
                v-if="canSubmit(scope.row.status)"
                v-hasPerm="['rcs:task:submit']"
                type="primary"
                size="small"
                link
                @click="handleSubmitTask(scope.row)"
              >{{ scope.row.status === 5 ? "重新下发" : "下发" }}</el-button>
              <el-button
                v-if="canCancel(scope.row.status)"
                v-hasPerm="['rcs:task:cancel']"
                type="warning"
                size="small"
                link
                @click="handleCancelTask(scope.row)"
              >取消</el-button>
              <el-button
                v-if="canUpdate(scope.row.status)"
                v-hasPerm="['rcs:task:update']"
                type="primary"
                size="small"
                link
                @click="handleEditClick(String(scope.row.id))"
              >修改</el-button>
              <el-button
                v-if="canDelete(scope.row.status)"
                v-hasPerm="['rcs:task:delete']"
                type="danger"
                size="small"
                link
                @click="handleDelete(String(scope.row.id))"
              >删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <pagination
        v-if="total > 0"
        v-model:total="total"
        v-model:page="params.pageNum"
        v-model:limit="params.pageSize"
        class="page-pagination"
        @pagination="fetchData"
      />
    </el-card>

    <!-- 表单弹窗（新增自动下发 / 修改） -->
    <el-dialog
      v-model="dialog.visible"
      :title="dialog.title"
      width="600px"
      @close="closeDialog"
    >
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="110px">
        <el-form-item label="任务类型" prop="taskType">
          <el-select v-model="formData.taskType" placeholder="请选择任务类型" style="width: 100%">
            <el-option v-for="opt in TASK_TYPE_OPTIONS" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="任务标题" prop="taskTitle">
          <el-input v-model="formData.taskTitle" placeholder="请输入任务标题" />
        </el-form-item>
        <el-form-item label="源位置" prop="fromLocation">
          <el-input v-model="formData.fromLocation" placeholder="请输入源位置编码" />
        </el-form-item>
        <el-form-item label="目标位置" prop="toLocation">
          <el-input v-model="formData.toLocation" placeholder="请输入目标位置编码" />
        </el-form-item>
        <el-form-item label="关联料车" prop="cartCode">
          <el-input v-model="formData.cartCode" placeholder="请输入关联料车编码" />
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="formData.priority" placeholder="留空使用默认优先级" clearable style="width: 100%">
            <el-option v-for="opt in PRIORITY_OPTIONS" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="扩展参数" prop="payloadText">
          <el-input
            v-model="payloadText"
            type="textarea"
            :rows="3"
            placeholder='JSON 格式，如 {"material":"M001"}，可留空'
          />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="formData.remark" type="textarea" :rows="2" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="handleSubmit">确定</el-button>
          <el-button @click="closeDialog">取消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 详情抽屉（状态时间线） -->
    <task-detail-drawer ref="detailDrawerRef" />
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, watch, onMounted } from "vue";
  import { useFullscreen } from "@vueuse/core";
  import {
    ElMessage,
    ElMessageBox,
    type FormInstance,
    type FormRules,
  } from "element-plus";
  import { FullScreen, Refresh } from "@element-plus/icons-vue";
  import { usePageTable } from "@/composables";
  import RcsTaskAPI from "@/api/rcs/rcs-task";
  import type { RcsTaskItem, RcsTaskForm, RcsTaskQueryParams } from "@/api/rcs/rcs-task";
  import TaskDetailDrawer from "./components/TaskDetailDrawer.vue";

  defineOptions({
    name: "RcsTask",
    inheritAttrs: false,
  });

  // ===== 枚举字典（对齐后端 RcsTaskStatusEnum 与 DTO Schema）=====
  const TASK_TYPE_OPTIONS = [
    { value: 1, label: "搬运" },
    { value: 2, label: "充电" },
    { value: 3, label: "调度" },
    { value: 4, label: "巡检" },
  ];
  const STATUS_OPTIONS = [
    { value: 0, label: "待执行" },
    { value: 1, label: "已派发" },
    { value: 2, label: "执行中" },
    { value: 3, label: "已完成" },
    { value: 4, label: "已取消" },
    { value: 5, label: "异常" },
  ];
  const PRIORITY_OPTIONS = [
    { value: 1, label: "低" },
    { value: 2, label: "中" },
    { value: 3, label: "高" },
    { value: 4, label: "紧急" },
  ];

  const queryFormRef = ref<FormInstance>();
  const dataFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const detailDrawerRef = ref<InstanceType<typeof TaskDetailDrawer>>();
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  // 雪花 ID 为字符串，保持字符串避免 Number 丢精度
  const selectedIds = ref<string[]>([]);
  // 提交时间区间（映射到 submitTimeStart/submitTimeEnd）
  const dateRange = ref<[string, string] | null>(null);

  // 表格数据
  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    RcsTaskItem,
    RcsTaskQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as RcsTaskQueryParams,
    request: RcsTaskAPI.getPage,
    onBeforeReset: () => {
      queryFormRef.value?.resetFields();
      dateRange.value = null;
    },
  });

  // 时间区间同步到查询参数
  watch(dateRange, (val) => {
    params.submitTimeStart = val?.[0];
    params.submitTimeEnd = val?.[1];
  });

  // 弹窗
  const dialog = reactive({
    title: "",
    visible: false,
  });

  // 表单数据 + payload 文本
  const formData = reactive<RcsTaskForm>({} as RcsTaskForm);
  const payloadText = ref("");

  // 表单校验规则（taskType 为唯一必填）
  const rules: FormRules = {
    taskType: [{ required: true, message: "请选择任务类型", trigger: "change" }],
  };

  // ===== 状态驱动的行操作显隐（P1-1 口径落地后仅改此处白名单）=====
  /** 可下发 / 重新下发：待执行(0) 或 异常(5，取决于 P1-1 后端口径） */
  function canSubmit(status?: number): boolean {
    return status === 0 || status === 5;
  }
  /** 可取消：已派发(1)、执行中(2)、异常(5，取决于 P1-1 后端口径） */
  function canCancel(status?: number): boolean {
    return status === 1 || status === 2 || status === 5;
  }
  /** 可修改：仅待执行(0) */
  function canUpdate(status?: number): boolean {
    return status === 0;
  }
  /** 可删除：非进行中（待执行/已完成/已取消/异常，即 !=1 且 !=2） */
  function canDelete(status?: number): boolean {
    return status !== 1 && status !== 2;
  }

  /** 状态 tag 颜色 */
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
  /** 优先级 tag 颜色 */
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

  function openDialog(): void {
    dialog.visible = true;
  }

  function closeDialog(): void {
    dialog.visible = false;
    resetForm();
  }

  function resetForm(): void {
    dataFormRef.value?.resetFields();
    dataFormRef.value?.clearValidate();
    Object.keys(formData).forEach((key) => {
      delete (formData as Record<string, unknown>)[key];
    });
    payloadText.value = "";
  }

  function handleCreateClick(): void {
    dialog.title = "新增任务";
    openDialog();
  }

  async function handleEditClick(id: string): Promise<void> {
    dialog.title = "修改任务";
    const data = await RcsTaskAPI.getDetail(id);
    Object.assign(formData, {
      id: data.id,
      taskType: data.taskType,
      taskTitle: data.taskTitle,
      fromLocation: data.fromLocation,
      toLocation: data.toLocation,
      cartCode: data.cartCode,
      priority: data.priority,
      remark: data.remark,
      payload: data.payload,
    });
    payloadText.value = data.payload ? JSON.stringify(data.payload) : "";
    openDialog();
  }

  async function handleSubmit(): Promise<void> {
    const valid = await dataFormRef.value?.validate().then(
      () => true,
      () => false,
    );
    if (!valid) return;

    // 解析 payload 文本
    if (payloadText.value.trim()) {
      try {
        formData.payload = JSON.parse(payloadText.value) as Record<string, unknown>;
      } catch {
        ElMessage.error("扩展参数不是合法 JSON");
        return;
      }
    } else {
      formData.payload = undefined;
    }

    loading.value = true;
    try {
      const id = formData.id;
      if (id) {
        await RcsTaskAPI.update(String(id), formData);
        ElMessage.success("修改成功");
      } else {
        await RcsTaskAPI.create(formData);
        // 下发成败不在返回体，刷新列表后按状态判断（P2-6）
        ElMessage.success("任务已创建并下发");
      }
      closeDialog();
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  function handleDetail(id: string): void {
    detailDrawerRef.value?.open(id);
  }

  async function handleSubmitTask(row: RcsTaskItem): Promise<void> {
    try {
      await ElMessageBox.confirm(`确认下发任务「${row.taskCode}」至 RCS？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      });
    } catch {
      return;
    }

    loading.value = true;
    try {
      await RcsTaskAPI.submit(String(row.id));
      ElMessage.success("下发成功");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  async function handleCancelTask(row: RcsTaskItem): Promise<void> {
    let reason: string | undefined;
    try {
      const { value } = await ElMessageBox.prompt("请输入取消原因（可选）", "取消任务", {
        confirmButtonText: "确定",
        cancelButtonText: "关闭",
        inputPlaceholder: "取消原因",
      });
      reason = value || undefined;
    } catch {
      return;
    }

    loading.value = true;
    try {
      await RcsTaskAPI.cancel(String(row.id), reason);
      ElMessage.success("已取消");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  async function handleDelete(ids?: string): Promise<void> {
    if (!ids) return;

    try {
      await ElMessageBox.confirm(
        "删除将同时清除该任务的状态变更历史，不可恢复，确认删除？",
        "警告",
        { confirmButtonText: "确定", cancelButtonText: "取消", type: "warning" },
      );
    } catch {
      ElMessage.info("已取消删除");
      return;
    }

    loading.value = true;
    try {
      await RcsTaskAPI.deleteByIds(ids);
      ElMessage.success("删除成功");
      selectedIds.value = [];
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  onMounted(() => {
    handleQuery();
  });
</script>
