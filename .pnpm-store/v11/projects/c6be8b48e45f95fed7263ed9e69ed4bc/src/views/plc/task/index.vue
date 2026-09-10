<template>
  <div class="page-container">
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="ID" prop="id">
          <el-input v-model="params.id" placeholder="数据库ID" clearable />
        </el-form-item>
        <el-form-item label="所属区域" prop="name">
          <el-input v-model="params.name" placeholder="所属区域" clearable />
        </el-form-item>
        <el-form-item label="PLC地址" prop="host">
          <el-input v-model="params.host" placeholder="PLC地址" clearable />
        </el-form-item>
        <el-form-item label="PLC型号" prop="plcType">
          <el-input v-model="params.plcType" placeholder="PLC型号" clearable />
        </el-form-item>
        <el-form-item label="启用状态" prop="enabled">
          <el-select v-model="params.enabled" placeholder="启用状态" clearable class="query-select">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="心跳检测地址" prop="heartbeatAddr">
          <el-input v-model="params.heartbeatAddr" placeholder="心跳检测地址" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">搜索</el-button>
          <el-button @click="handleResetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card ref="tableWrapperRef" class="page-content" shadow="never">
      <div class="page-toolbar">
        <div class="page-toolbar__left">
          <el-button
            v-hasPerm="['plc:task:create']"
            type="primary"
            @click="handleCreateClick"
          >
            新增PLC配置
          </el-button>
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
          v-loading="loading"
          class="page-table"
          :data="list"
          height="100%"
          border
          highlight-current-row
        >
          <el-table-column key="id" label="ID" prop="id" min-width="180" align="center" show-overflow-tooltip />
          <el-table-column key="name" label="所属区域" prop="name" min-width="130" align="center" show-overflow-tooltip />
          <el-table-column key="host" label="PLC地址" prop="host" min-width="150" align="center" show-overflow-tooltip />
          <el-table-column key="plcType" label="PLC型号" prop="plcType" min-width="130" align="center" show-overflow-tooltip />
          <el-table-column key="connected" label="PLC连接状态" min-width="120" align="center">
            <template #default="scope">
              <el-tag :type="scope.row.connected ? 'success' : 'info'">
                {{ scope.row.connected ? "连接中" : "未连接" }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column key="enabled" label="启用状态" min-width="110" align="center">
            <template #default="scope">
              <el-button
                v-hasPerm="['plc:task:update']"
                :type="scope.row.enabled === 1 ? 'warning' : 'success'"
                size="small"
                plain
                @click="handleEnabledClick(scope.row)"
              >
                {{ scope.row.enabled === 1 ? "禁用" : "启用" }}
              </el-button>
            </template>
          </el-table-column>
          <el-table-column
            key="heartbeatAddr"
            label="心跳检测地址"
            prop="heartbeatAddr"
            min-width="160"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column fixed="right" label="操作" width="180">
            <template #default="scope">
              <el-button
                type="primary"
                size="small"
                link
                @click="handleReconnect(scope.row)"
              >
                重新连接
              </el-button>
              <el-button
                v-hasPerm="['plc:task:delete']"
                type="danger"
                size="small"
                link
                @click="handleDelete(String(scope.row.id))"
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

    <el-dialog v-model="dialogVisible" title="新增PLC配置" width="520px" @close="closeDialog">
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="110px">
        <el-form-item label="区域选择" prop="name">
          <el-select
            v-model="formData.name"
            placeholder="请选择区域"
            filterable
            clearable
            class="w-full"
          >
            <el-option
              v-for="item in locationOptions"
              :key="item.locationName"
              :label="item.locationName"
              :value="item.locationName"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="PLC IP地址" prop="host">
          <el-input v-model="formData.host" placeholder="请输入PLC IP地址" clearable />
        </el-form-item>

        <el-form-item label="PLC类型" prop="plcType">
          <el-select v-model="formData.plcType" placeholder="请选择PLC类型" clearable class="w-full">
            <el-option v-for="item in plcTypeOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>

        <el-form-item label="心跳地址" prop="heartbeatAddr">
          <el-input v-model="formData.heartbeatAddr" placeholder="请输入心跳地址" clearable />
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="handleSubmit">确定</el-button>
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
  import PlcTaskAPI from "@/api/plc/task";
  import type {
    PlcLocationOption,
    PlcTaskCreateForm,
    PlcTaskItem,
    PlcTaskQueryParams,
  } from "@/api/plc/task";

  defineOptions({
    name: "PlcTask",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const dataFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  const dialogVisible = ref(false);
  const locationOptions = ref<PlcLocationOption[]>([]);
  const plcTypeOptions = [
    "S200",
    "S300",
    "S400",
    "S1200",
    "S1500",
    "S200_SMART",
    "SINUMERIK_828D",
  ];

  const initialFormData: PlcTaskCreateForm = {
    name: "",
    host: "",
    plcType: "",
    heartbeatAddr: "",
  };
  const formData = reactive<PlcTaskCreateForm>({ ...initialFormData });

  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    PlcTaskItem,
    PlcTaskQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as PlcTaskQueryParams,
    request: PlcTaskAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  const rules: FormRules = {
    name: [{ required: true, message: "请选择区域", trigger: "change" }],
    host: [{ required: true, message: "请输入PLC IP地址", trigger: "blur" }],
    plcType: [{ required: true, message: "请选择PLC类型", trigger: "change" }],
  };

  function handleCreateClick(): void {
    void openCreateDialog();
  }

  async function openCreateDialog(): Promise<void> {
    const loaded = await loadLocationOptions();
    if (!loaded) {
      ElMessage.error("区域选项加载失败");
      return;
    }

    resetForm();
    dialogVisible.value = true;
  }

  async function loadLocationOptions(): Promise<boolean> {
    try {
      const data = await PlcTaskAPI.getLocationOptions();
      locationOptions.value = data || [];
      return true;
    } catch {
      return false;
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

    const selectedLocation = locationOptions.value.find(
      (item) => item.locationName === formData.name
    );
    if (selectedLocation?.status === 0) {
      try {
        await ElMessageBox.confirm("所选区域已禁用，是否仍要配置？", "提示", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning",
        });
      } catch {
        ElMessage.info("已取消操作");
        return;
      }
    }

    loading.value = true;
    try {
      await PlcTaskAPI.create(formData);
      ElMessage.success("新增成功");
      closeDialog();
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  async function handleEnabledClick(row: PlcTaskItem): Promise<void> {
    if (!row.id) return;

    const nextEnabled = row.enabled === 1 ? 0 : 1;
    const actionText = nextEnabled === 1 ? "启用" : "禁用";

    try {
      await ElMessageBox.confirm(
        `确认${actionText}该PLC配置并${nextEnabled === 1 ? "建立" : "关闭"}连接吗？`,
        "提示",
        {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning",
        }
      );
    } catch {
      ElMessage.info("已取消操作");
      return;
    }

    loading.value = true;
    try {
      await PlcTaskAPI.updateEnabled(String(row.id), nextEnabled);
      ElMessage.success(`${actionText}成功`);
      await fetchData();
    } finally {
      loading.value = false;
    }
  }

  async function handleReconnect(row: PlcTaskItem): Promise<void> {
    if (!row.id) return;

    try {
      await ElMessageBox.confirm(`确认重新连接该PLC吗？`, "提示", {
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
      await PlcTaskAPI.reconnect(String(row.id));
      ElMessage.success("重连成功");
      await fetchData();
    } finally {
      loading.value = false;
    }
  }

  async function handleDelete(id?: string): Promise<void> {
    if (!id) return;

    try {
      await ElMessageBox.confirm("确认硬删除该PLC配置？删除后无法恢复。", "警告", {
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
      await PlcTaskAPI.deleteByIds(id);
      ElMessage.success("删除成功");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  onMounted(() => {
    handleQuery();
  });
</script>

<style scoped>
  .w-full {
    width: 100%;
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
  }

  .query-select {
    width: 120px;
    min-width: 120px;
    flex: 0 0 120px;
  }
</style>
