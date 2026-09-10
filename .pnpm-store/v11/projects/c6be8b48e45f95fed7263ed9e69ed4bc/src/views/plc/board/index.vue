<template>
  <div class="page-container">
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="ID" prop="id">
          <el-input v-model="params.id" placeholder="ID" clearable />
        </el-form-item>
        <el-form-item label="plcId" prop="plcId">
          <el-input v-model="params.plcId" placeholder="plcId" clearable />
        </el-form-item>
        <el-form-item label="信号块地址" prop="plcAddress">
          <el-input v-model="params.plcAddress" placeholder="信号块地址" clearable />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="params.description" placeholder="描述" clearable />
        </el-form-item>
        <el-form-item label="启用状态" prop="enabled">
          <el-select v-model="params.enabled" placeholder="启用状态" clearable class="query-select">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button v-hasPerm="['plc:board:list']" type="primary" @click="handleQuery">搜索</el-button>
          <el-button v-hasPerm="['plc:board:list']" @click="handleResetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card ref="tableWrapperRef" class="page-content" shadow="never">
      <div class="page-toolbar">
        <div class="page-toolbar__left">
          <el-button v-hasPerm="['plc:board:list']" type="primary" @click="handleCreateClick">
            新增
          </el-button>
        </div>
        <div class="page-toolbar__right">
          <el-tooltip content="刷新" placement="top">
            <el-button v-hasPerm="['plc:board:list']" class="page-icon-btn" @click="fetchData">
              <el-icon><Refresh /></el-icon>
            </el-button>
          </el-tooltip>
          <el-tooltip content="全屏" placement="top">
            <el-button v-hasPerm="['plc:board:list']" class="page-icon-btn" @click="toggleFullscreen">
              <el-icon><FullScreen /></el-icon>
            </el-button>
          </el-tooltip>
        </div>
      </div>

      <div class="page-table-wrapper">
        <el-table
          v-loading="loading"
          class="page-table"
          :data="list"
          height="100%"
          border
          highlight-current-row
        >
          <el-table-column key="id" label="id" prop="id" min-width="180" align="center" show-overflow-tooltip />
          <el-table-column key="plcId" label="plcId" prop="plcId" min-width="180" align="center" show-overflow-tooltip />
          <el-table-column
            key="plcAddress"
            label="信号块地址"
            prop="plcAddress"
            min-width="180"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column
            key="description"
            label="描述"
            prop="description"
            min-width="200"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column
            key="pointId"
            label="储位id"
            prop="pointId"
            min-width="180"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column key="enabled" label="启用状态" min-width="110" align="center">
            <template #default="scope">
              <el-button
                v-hasPerm="['plc:board:list']"
                :type="scope.row.enabled === 1 ? 'warning' : 'success'"
                size="small"
                plain
                @click="handleEnabledClick(scope.row)"
              >
                {{ scope.row.enabled === 1 ? "禁用" : "启用" }}
              </el-button>
            </template>
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="120" align="center">
            <template #default="scope">
              <el-button
                v-hasPerm="['plc:board:list']"
                type="danger"
                size="small"
                link
                @click="handleDelete(scope.row)"
              >
                删除
              </el-button>
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

    <el-dialog v-model="dialogVisible" title="新增plc板块" width="520px" @close="closeDialog">
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="选择plc" prop="plcId">
          <el-select
            v-model="formData.plcId"
            placeholder="请选择plc"
            filterable
            clearable
            class="w-full"
            :loading="plcOptionsLoading"
          >
            <el-option
              v-for="item in plcOptions"
              :key="item.id"
              :label="item.host"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="板块地址" prop="plcAddress">
          <el-input v-model="formData.plcAddress" placeholder="请输入板块地址" clearable />
        </el-form-item>
        <el-form-item label="板块描述" prop="description">
          <el-input v-model="formData.description" placeholder="请输入板块描述" clearable />
        </el-form-item>
        <el-form-item label="储位id" prop="pointId">
          <el-select
            v-model="formData.pointId"
            placeholder="请选择储位"
            filterable
            clearable
            class="w-full"
            :loading="pointOptionsLoading"
          >
            <el-option
              v-for="item in pointOptions"
              :key="item.id"
              :label="item.pointName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
          <el-button @click="closeDialog">取消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
  import { onMounted, reactive, ref } from "vue";
  import { useFullscreen } from "@vueuse/core";
  import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
  import { FullScreen, Refresh } from "@element-plus/icons-vue";
  import { usePageTable } from "@/composables";
  import PlcBoardAPI from "@/api/plc/board";
  import type {
    PlcBoardCreateForm,
    PlcBoardItem,
    PlcBoardQueryParams,
    PlcConnectionOption,
    PlcPointOption,
  } from "@/api/plc/board";

  defineOptions({
    name: "PlcBoard",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const dataFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);
  const dialogVisible = ref(false);
  const submitLoading = ref(false);
  const plcOptionsLoading = ref(false);
  const plcOptions = ref<PlcConnectionOption[]>([]);
  const pointOptionsLoading = ref(false);
  const pointOptions = ref<PlcPointOption[]>([]);
  const initialFormData: PlcBoardCreateForm = {
    plcId: "",
    plcAddress: "",
    description: "",
    pointId: "",
  };
  const formData = reactive<PlcBoardCreateForm>({ ...initialFormData });

  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    PlcBoardItem,
    PlcBoardQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as PlcBoardQueryParams,
    request: PlcBoardAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  const rules: FormRules = {
    plcId: [{ required: true, message: "请选择plc", trigger: "change" }],
    plcAddress: [{ required: true, message: "请输入板块地址", trigger: "blur" }],
    pointId: [{ required: true, message: "请选择储位", trigger: "change" }],
  };

  function handleCreateClick(): void {
    void openCreateDialog();
  }

  async function openCreateDialog(): Promise<void> {
    const [plcLoaded, pointLoaded] = await Promise.all([loadPlcOptions(), loadPointOptions()]);
    if (!plcLoaded) {
      ElMessage.error("PLC选项加载失败");
      return;
    }
    if (!pointLoaded) {
      ElMessage.error("储位选项加载失败");
      return;
    }

    resetForm();
    dialogVisible.value = true;
  }

  async function loadPlcOptions(): Promise<boolean> {
    plcOptionsLoading.value = true;
    try {
      plcOptions.value = await PlcBoardAPI.getPlcOptions();
      return true;
    } catch {
      return false;
    } finally {
      plcOptionsLoading.value = false;
    }
  }

  async function loadPointOptions(): Promise<boolean> {
    pointOptionsLoading.value = true;
    try {
      pointOptions.value = await PlcBoardAPI.getPointOptions();
      return true;
    } catch {
      return false;
    } finally {
      pointOptionsLoading.value = false;
    }
  }

  function resetForm(): void {
    dataFormRef.value?.clearValidate();
    Object.assign(formData, initialFormData);
  }

  function closeDialog(): void {
    dialogVisible.value = false;
    resetForm();
  }

  async function handleSubmit(): Promise<void> {
    const valid = await dataFormRef.value?.validate().then(
      () => true,
      () => false
    );
    if (!valid) return;

    submitLoading.value = true;
    try {
      await PlcBoardAPI.create(formData);
      ElMessage.success("新增成功");
      closeDialog();
      handleQuery();
    } finally {
      submitLoading.value = false;
    }
  }

  async function handleDelete(row: PlcBoardItem): Promise<void> {
    if (!row.id) return;

    try {
      await ElMessageBox.confirm("确认删除该PLC信号块配置吗？", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      });
    } catch {
      ElMessage.info("已取消删除");
      return;
    }

    loading.value = true;
    try {
      await PlcBoardAPI.deleteById(String(row.id));
      ElMessage.success("删除成功");
      await fetchData();
    } finally {
      loading.value = false;
    }
  }

  async function handleEnabledClick(row: PlcBoardItem): Promise<void> {
    if (!row.id) return;

    const nextEnabled = row.enabled === 1 ? 0 : 1;
    const actionText = nextEnabled === 1 ? "启用" : "禁用";

    try {
      await ElMessageBox.confirm(`确认${actionText}该PLC信号块配置吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      });
    } catch {
      ElMessage.info("已取消操作");
      return;
    }

    loading.value = true;
    try {
      await PlcBoardAPI.updateEnabled(String(row.id), nextEnabled);
      ElMessage.success(`${actionText}成功`);
      await fetchData();
    } finally {
      loading.value = false;
    }
  }

  onMounted(() => {
    handleQuery();
  });
</script>

<style scoped>
  .query-select {
    width: 120px;
    min-width: 120px;
    flex: 0 0 120px;
  }

  .w-full {
    width: 100%;
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
  }
</style>
