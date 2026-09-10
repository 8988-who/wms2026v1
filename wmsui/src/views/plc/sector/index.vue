<template>
  <div class="page-container">
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="id" prop="id">
          <el-input v-model="params.id" placeholder="id" clearable />
        </el-form-item>
        <el-form-item label="信号类型" prop="signalType">
          <el-select v-model="params.signalType" placeholder="信号类型" clearable class="query-select">
            <el-option
              v-for="item in signalTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="信号地址" prop="signalAddress">
          <el-input v-model="params.signalAddress" placeholder="信号地址" clearable />
        </el-form-item>
        <el-form-item label="信号描述" prop="signalDescription">
          <el-input v-model="params.signalDescription" placeholder="信号描述" clearable />
        </el-form-item>
        <el-form-item label="信号ID" prop="signalId">
          <el-input v-model="params.signalId" placeholder="信号ID" clearable />
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
          <el-table-column key="signalType" label="信号类型" min-width="120" align="center">
            <template #default="scope">
              {{ formatSignalType(scope.row.signalType) }}
            </template>
          </el-table-column>
          <el-table-column
            key="number"
            label="排序号"
            prop="number"
            min-width="100"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column
            key="signalAddress"
            label="信号地址"
            prop="signalAddress"
            min-width="150"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column
            key="signalDescription"
            label="信号描述"
            prop="signalDescription"
            min-width="200"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column key="signalId" label="信号ID" prop="signalId" min-width="150" align="center" show-overflow-tooltip />
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

    <el-dialog v-model="dialogVisible" title="新增配置" width="520px" @close="closeDialog">
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="信号类型" prop="signalType">
          <el-select
            v-model="formData.signalType"
            placeholder="请选择信号类型"
            clearable
            class="w-full"
            @change="handleSignalTypeChange"
          >
            <el-option
              v-for="item in signalTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item
          v-if="formData.signalType !== undefined && formData.signalType !== 1"
          label="排序号"
          prop="number"
        >
          <el-input-number
            v-model="formData.number"
            :precision="0"
            :step="1"
            :controls="true"
            class="w-full"
            placeholder="请输入排序号"
          />
        </el-form-item>
        <el-form-item label="信号地址" prop="signalAddress">
          <el-input v-model="formData.signalAddress" placeholder="请输入信号地址" clearable />
        </el-form-item>
        <el-form-item label="信号描述" prop="signalDescription">
          <el-input v-model="formData.signalDescription" placeholder="请输入信号描述" clearable />
        </el-form-item>
        <el-form-item label="信号块" prop="signalId">
          <el-select
            v-model="formData.signalId"
            placeholder="请选择信号块"
            filterable
            clearable
            class="w-full"
            :loading="signalBlockOptionsLoading"
          >
            <el-option
              v-for="item in signalBlockOptions"
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
  import { onMounted, reactive, ref } from "vue";
  import { useFullscreen } from "@vueuse/core";
  import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
  import { FullScreen, Refresh } from "@element-plus/icons-vue";
  import { usePageTable } from "@/composables";
  import PlcSectorSignalsAPI from "@/api/plc/sector";
  import type {
    PlcSectorSignalsCreateForm,
    PlcSectorSignalsItem,
    PlcSectorSignalsQueryParams,
    SignalBlockOption,
  } from "@/api/plc/sector";

  defineOptions({
    name: "PlcSectorSignals",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  /** 信号类型选项: 1=货架号 2=产品条码 3=产品型号 */
  const signalTypeOptions = [
    { value: 1, label: "货架号" },
    { value: 2, label: "产品条码" },
    { value: 3, label: "产品型号" },
  ];

  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    PlcSectorSignalsItem,
    PlcSectorSignalsQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as PlcSectorSignalsQueryParams,
    request: PlcSectorSignalsAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  function formatSignalType(signalType?: number | string): string {
    // 后端将 Long 全局序列化为字符串，需兼容字符串/数字两种取值
    return signalTypeOptions.find((item) => String(item.value) === String(signalType))?.label ?? "";
  }

  const dataFormRef = ref<FormInstance>();
  const dialogVisible = ref(false);
  const submitLoading = ref(false);
  const signalBlockOptionsLoading = ref(false);
  const signalBlockOptions = ref<SignalBlockOption[]>([]);
  const initialFormData: PlcSectorSignalsCreateForm = {
    signalType: undefined,
    number: undefined,
    signalAddress: "",
    signalDescription: "",
    signalId: "",
  };
  const formData = reactive<PlcSectorSignalsCreateForm>({ ...initialFormData });

  const rules: FormRules = {
    signalType: [{ required: true, message: "请选择信号类型", trigger: "change" }],
    number: [
      {
        validator: (_rule, value, callback) => {
          // 信号类型为1(货架号)时可空，其余类型必填
          const needNumber = formData.signalType !== undefined && formData.signalType !== 1;
          if (needNumber && (value === undefined || value === null)) {
            callback(new Error("请输入排序号"));
            return;
          }
          callback();
        },
        trigger: "blur",
      },
    ],
    signalAddress: [{ required: true, message: "请输入信号地址", trigger: "blur" }],
    signalId: [{ required: true, message: "请选择信号块", trigger: "change" }],
  };

  function handleSignalTypeChange(): void {
    if (formData.signalType === 1) {
      formData.number = undefined;
      dataFormRef.value?.clearValidate("number");
    }
  }

  function handleCreateClick(): void {
    void openCreateDialog();
  }

  async function openCreateDialog(): Promise<void> {
    resetForm();
    dialogVisible.value = true;
    const loaded = await loadSignalBlockOptions();
    if (!loaded) {
      ElMessage.error("信号块选项加载失败");
    }
  }

  async function loadSignalBlockOptions(): Promise<boolean> {
    signalBlockOptionsLoading.value = true;
    try {
      signalBlockOptions.value = await PlcSectorSignalsAPI.getSignalBlockOptions();
      return true;
    } catch {
      return false;
    } finally {
      signalBlockOptionsLoading.value = false;
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
      await PlcSectorSignalsAPI.create(formData);
      ElMessage.success("新增成功");
      closeDialog();
      handleQuery();
    } finally {
      submitLoading.value = false;
    }
  }

  async function handleDelete(row: PlcSectorSignalsItem): Promise<void> {
    if (!row.id) return;

    try {
      await ElMessageBox.confirm("确认删除该PLC信号块读写信号配置吗？", "警告", {
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
      await PlcSectorSignalsAPI.deleteById(String(row.id));
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
