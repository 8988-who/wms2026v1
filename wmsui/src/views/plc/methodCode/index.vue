<template>
  <div class="page-container">
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="id" prop="id">
          <el-input v-model="params.id" placeholder="id" clearable />
        </el-form-item>
        <el-form-item label="信号块id" prop="signalId">
          <el-input v-model="params.signalId" placeholder="信号块id" clearable />
        </el-form-item>
        <el-form-item label="信号值" prop="signalCode">
          <el-input v-model="params.signalCode" placeholder="信号值" clearable />
        </el-form-item>
        <el-form-item label="方法id" prop="methodId">
          <el-input v-model="params.methodId" placeholder="方法id" clearable />
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
          <el-table-column key="id" label="id" prop="id" min-width="200" align="center" show-overflow-tooltip />
          <el-table-column
            key="signalId"
            label="信号块id"
            prop="signalId"
            min-width="200"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column
            key="signalCode"
            label="信号值"
            prop="signalCode"
            min-width="150"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column
            key="methodId"
            label="方法id"
            prop="methodId"
            min-width="200"
            align="center"
            show-overflow-tooltip
          />
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

    <el-dialog v-model="dialogVisible" title="新增信号值方法配置" width="520px" @close="closeDialog">
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="PLC" prop="plcIp">
          <el-select
            v-model="formData.plcIp"
            placeholder="请选择PLC"
            filterable
            clearable
            class="w-full"
            :loading="plcOptionsLoading"
          >
            <el-option
              v-for="item in plcOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="信号块地址" prop="signalId">
          <el-select
            v-model="formData.signalId"
            placeholder="请选择信号块地址"
            filterable
            clearable
            class="w-full"
            :disabled="!formData.plcIp"
            :loading="signalOptionsLoading"
          >
            <el-option
              v-for="item in signalOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="信号值" prop="signalCode">
          <el-input v-model="formData.signalCode" placeholder="请输入信号值" clearable />
        </el-form-item>
        <el-form-item label="方法" prop="methodId">
          <el-select
            v-model="formData.methodId"
            placeholder="请选择方法"
            filterable
            clearable
            class="w-full"
            :loading="methodOptionsLoading"
          >
            <el-option
              v-for="item in methodOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
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
  import { onMounted, reactive, ref, watch } from "vue";
  import { useFullscreen } from "@vueuse/core";
  import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
  import { FullScreen, Refresh } from "@element-plus/icons-vue";
  import { usePageTable } from "@/composables";
  import PlcMethodCodeAPI from "@/api/plc/methodCode";
  import type {
    PlcMethodCodeCreateForm,
    PlcMethodCodeItem,
    PlcMethodCodeOption,
    PlcMethodCodeQueryParams,
  } from "@/api/plc/methodCode";

  defineOptions({
    name: "PlcMethodCode",
    inheritAttrs: false,
  });

  /** 新增弹窗表单模型(plcIp 仅用于联动，不随提交入参) */
  interface MethodCodeCreateDialogForm extends PlcMethodCodeCreateForm {
    plcIp?: string;
  }

  const queryFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    PlcMethodCodeItem,
    PlcMethodCodeQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as PlcMethodCodeQueryParams,
    request: PlcMethodCodeAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  const dataFormRef = ref<FormInstance>();
  const dialogVisible = ref(false);
  const submitLoading = ref(false);
  const plcOptionsLoading = ref(false);
  const signalOptionsLoading = ref(false);
  const methodOptionsLoading = ref(false);
  const plcOptions = ref<PlcMethodCodeOption[]>([]);
  const signalOptions = ref<PlcMethodCodeOption[]>([]);
  const methodOptions = ref<PlcMethodCodeOption[]>([]);

  const initialFormData: MethodCodeCreateDialogForm = {
    plcIp: "",
    signalId: "",
    signalCode: "",
    methodId: "",
  };
  const formData = reactive<MethodCodeCreateDialogForm>({ ...initialFormData });

  const rules: FormRules = {
    plcIp: [{ required: true, message: "请选择PLC", trigger: "change" }],
    signalId: [{ required: true, message: "请选择信号块地址", trigger: "change" }],
    signalCode: [{ required: true, message: "请输入信号值", trigger: "blur" }],
    methodId: [{ required: true, message: "请选择方法", trigger: "change" }],
  };

  function handleCreateClick(): void {
    void openCreateDialog();
  }

  async function openCreateDialog(): Promise<void> {
    resetForm();
    dialogVisible.value = true;
    const [plcLoaded, methodLoaded] = await Promise.all([loadPlcOptions(), loadMethodOptions()]);
    if (!plcLoaded) {
      ElMessage.error("PLC选项加载失败");
    }
    if (!methodLoaded) {
      ElMessage.error("方法选项加载失败");
    }
  }

  async function loadPlcOptions(): Promise<boolean> {
    plcOptionsLoading.value = true;
    try {
      plcOptions.value = await PlcMethodCodeAPI.getPlcOptions();
      return true;
    } catch {
      return false;
    } finally {
      plcOptionsLoading.value = false;
    }
  }

  async function loadSignalOptions(plcId: string): Promise<boolean> {
    signalOptionsLoading.value = true;
    try {
      signalOptions.value = await PlcMethodCodeAPI.getSignalOptions(plcId);
      return true;
    } catch {
      return false;
    } finally {
      signalOptionsLoading.value = false;
    }
  }

  async function loadMethodOptions(): Promise<boolean> {
    methodOptionsLoading.value = true;
    try {
      methodOptions.value = await PlcMethodCodeAPI.getMethodOptions();
      return true;
    } catch {
      return false;
    } finally {
      methodOptionsLoading.value = false;
    }
  }

  // PLC 联动信号块地址
  watch(
    () => formData.plcIp,
    async (plcId?: string) => {
      signalOptions.value = [];
      formData.signalId = "";
      if (!plcId) {
        return;
      }
      const loaded = await loadSignalOptions(plcId);
      if (!loaded) {
        ElMessage.error("信号块地址选项加载失败");
      }
    }
  );

  function resetForm(): void {
    dataFormRef.value?.clearValidate();
    Object.assign(formData, initialFormData);
  }

  function closeDialog(): void {
    dialogVisible.value = false;
    resetForm();
    signalOptions.value = [];
  }

  async function handleSubmit(): Promise<void> {
    const valid = await dataFormRef.value?.validate().then(
      () => true,
      () => false
    );
    if (!valid) return;

    submitLoading.value = true;
    try {
      const payload: PlcMethodCodeCreateForm = {
        signalId: formData.signalId,
        signalCode: formData.signalCode,
        methodId: formData.methodId,
      };
      await PlcMethodCodeAPI.create(payload);
      ElMessage.success("新增成功");
      closeDialog();
      handleQuery();
    } finally {
      submitLoading.value = false;
    }
  }

  async function handleDelete(row: PlcMethodCodeItem): Promise<void> {
    if (!row.id) return;

    try {
      await ElMessageBox.confirm("确认删除该信号值方法配置吗？", "警告", {
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
      await PlcMethodCodeAPI.deleteById(String(row.id));
      ElMessage.success("删除成功");
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
  .w-full {
    width: 100%;
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
  }
</style>
