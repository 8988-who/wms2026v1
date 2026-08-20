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
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="任务类型" prop="taskType">
          <el-select v-model="formData.taskType" placeholder="请选择任务类型" style="width: 100%" @change="handleTaskTypeChange">
            <el-option v-for="opt in TASK_TYPE_OPTIONS" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="任务标题" prop="taskTitle">
          <el-input v-model="formData.taskTitle" placeholder="留空自动生成，如「搬运：P001 → P002」" />
        </el-form-item>
        <el-form-item label="源位置" prop="fromLocation">
          <el-select
            v-model="formData.fromLocation"
            filterable
            clearable
            placeholder="请选择源位置"
            style="width: 100%"
          >
            <el-option v-for="p in pointOptions" :key="p.value" :label="p.label" :value="p.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="目标位置" prop="toLocation">
          <el-select
            v-model="formData.toLocation"
            filterable
            clearable
            placeholder="请选择目标位置"
            style="width: 100%"
          >
            <el-option v-for="p in pointOptions" :key="p.value" :label="p.label" :value="p.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="关联料车" prop="cartCode">
          <el-select
            v-model="formData.cartCode"
            filterable
            clearable
            placeholder="请选择关联料车"
            style="width: 100%"
          >
            <el-option v-for="c in cartOptions" :key="c.value" :label="c.label" :value="c.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="formData.priority" placeholder="留空使用默认优先级" clearable style="width: 100%">
            <el-option v-for="opt in PRIORITY_OPTIONS" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </el-form-item>
        <!-- 扩展参数：高级选项折叠 + JSON 模式（非技术人员默认无需展开） -->
        <task-param-form ref="paramFormRef" :target-route="targetRoute" @change="handlePayloadChange" />
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
  import { ref, reactive, computed, watch, onMounted } from "vue";
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
  import WmsPointAPI from "@/api/warehouse/wms-point";
  import CartAPI from "@/api/carriermanagementsystem/cart";
  import TaskDetailDrawer from "./components/TaskDetailDrawer.vue";
  import TaskParamForm from "./components/TaskParamForm.vue";
  import {
    TASK_TYPE_OPTIONS,
    STATUS_OPTIONS,
    PRIORITY_OPTIONS,
    buildTargetRoute,
    parseTargetRoute,
  } from "./constants";

  defineOptions({
    name: "RcsTask",
    inheritAttrs: false,
  });

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

  // 扩展参数子组件
  const paramFormRef = ref<InstanceType<typeof TaskParamForm>>();

  // 表单数据
  const formData = reactive<RcsTaskForm>({} as RcsTaskForm);

  // ===== 下拉数据源（点位 / 料车编码，复用分页接口取全量）=====
  const pointOptions = ref<{ label: string; value: string }[]>([]);
  const cartOptions = ref<{ label: string; value: string }[]>([]);

  /** 加载点位编码下拉（启用状态优先，数据量小一次性取） */
  async function loadPointOptions(): Promise<void> {
    if (pointOptions.value.length > 0) return;
    const res = await WmsPointAPI.getPage({ pageNum: 1, pageSize: 1000 } as never);
    pointOptions.value = (res.list ?? [])
      .filter((p) => p.pointCode)
      .map((p) => ({
        value: p.pointCode!,
        label: p.pointName ? `${p.pointCode}（${p.pointName}）` : p.pointCode!,
      }));
  }

  /** 加载料车编码下拉 */
  async function loadCartOptions(): Promise<void> {
    if (cartOptions.value.length > 0) return;
    const res = await CartAPI.getPage({ pageNum: 1, pageSize: 1000 } as never);
    cartOptions.value = (res.list ?? [])
      .filter((c) => c.cartCode)
      .map((c) => ({ value: c.cartCode!, label: c.cartCode! }));
  }

  // ===== targetRoute：由源/目标位置自动生成（搬运主场景，用户无感）=====
  const targetRoute = computed(() =>
    buildTargetRoute(formData.fromLocation, formData.toLocation),
  );

  // ===== 任务标题自动生成（用户手动改过则不再覆盖）=====
  const titleManuallyEdited = ref(false);
  const autoTitle = computed(() => {
    const typeLabel = TASK_TYPE_OPTIONS.find((t) => t.value === formData.taskType)?.label ?? "任务";
    const from = formData.fromLocation;
    const to = formData.toLocation;
    return from || to ? `${typeLabel}：${from || "?"} → ${to || "?"}` : `${typeLabel}任务`;
  });
  watch(autoTitle, (val) => {
    if (!titleManuallyEdited.value) formData.taskTitle = val;
  });
  // 用户手动改标题后停止自动覆盖
  watch(
    () => formData.taskTitle,
    (val) => {
      if (val && val !== autoTitle.value) titleManuallyEdited.value = true;
    },
  );

  /** 子组件抛出的 payload 缓存（提交时合并 targetRoute 后使用） */
  const payloadCache = ref<Record<string, unknown> | undefined>(undefined);
  function handlePayloadChange(payload: Record<string, unknown> | undefined): void {
    payloadCache.value = payload;
  }

  /** 切换任务类型：清空扩展参数，避免类型间串值 */
  function handleTaskTypeChange(): void {
    if (payloadCache.value && Object.keys(payloadCache.value).some((k) => k !== "targetRoute")) {
      ElMessage.info("已清空高级扩展参数，请按新任务类型重新填写");
    }
    paramFormRef.value?.reset();
    payloadCache.value = undefined;
  }

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
    paramFormRef.value?.reset();
    payloadCache.value = undefined;
    titleManuallyEdited.value = false;
  }

  function handleCreateClick(): void {
    dialog.title = "新增任务";
    void loadPointOptions();
    void loadCartOptions();
    openDialog();
  }

  async function handleEditClick(id: string): Promise<void> {
    dialog.title = "修改任务";
    void loadPointOptions();
    void loadCartOptions();
    const data = await RcsTaskAPI.getDetail(id);
    // targetRoute 优先反推源/目标位置，缺失时回退实体 fromLocation/toLocation
    const parsed = parseTargetRoute(data.payload?.targetRoute);
    Object.assign(formData, {
      id: data.id,
      taskType: data.taskType,
      taskTitle: data.taskTitle,
      fromLocation: parsed.fromLocation ?? data.fromLocation,
      toLocation: parsed.toLocation ?? data.toLocation,
      cartCode: data.cartCode,
      priority: data.priority,
      remark: data.remark,
    });
    // 回显后标题按已有值处理（视为手动，不被自动生成覆盖）
    titleManuallyEdited.value = true;
    openDialog();
    // 弹窗打开后回填扩展参数（子组件已挂载）
    await Promise.resolve();
    paramFormRef.value?.setPayload(data.payload);
  }

  async function handleSubmit(): Promise<void> {
    const valid = await dataFormRef.value?.validate().then(
      () => true,
      () => false,
    );
    if (!valid) return;

    // 组装 payload：子组件缓存（含 targetRoute/高级字段/extra）为准，为空则不传
    formData.payload = paramFormRef.value?.buildPayload();

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
