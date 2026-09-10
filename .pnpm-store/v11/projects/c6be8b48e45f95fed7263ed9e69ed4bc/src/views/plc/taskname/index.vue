<template>
  <div class="page-container">
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="id" prop="id">
          <el-input v-model="params.id" placeholder="id" clearable />
        </el-form-item>
        <el-form-item label="方法名" prop="methodName">
          <el-input v-model="params.methodName" placeholder="方法名" clearable />
        </el-form-item>
        <el-form-item label="方法描述" prop="methodDescription">
          <el-input v-model="params.methodDescription" placeholder="方法描述" clearable />
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
            key="methodName"
            label="方法名"
            prop="methodName"
            min-width="150"
            align="center"
            show-overflow-tooltip
          />
          <el-table-column
            key="methodDescription"
            label="方法描述"
            prop="methodDescription"
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

    <el-dialog v-model="dialogVisible" title="新增方法名配置" width="520px" @close="closeDialog">
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="方法名" prop="methodName">
          <el-input v-model="formData.methodName" placeholder="请输入方法名" clearable />
        </el-form-item>
        <el-form-item label="方法描述" prop="methodDescription">
          <el-input v-model="formData.methodDescription" placeholder="请输入方法描述" clearable />
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
  import PlcTaskNameAPI from "@/api/plc/taskname";
  import type { PlcTaskNameCreateForm, PlcTaskNameItem, PlcTaskNameQueryParams } from "@/api/plc/taskname";

  defineOptions({
    name: "PlcTaskName",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    PlcTaskNameItem,
    PlcTaskNameQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as PlcTaskNameQueryParams,
    request: PlcTaskNameAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  const dataFormRef = ref<FormInstance>();
  const dialogVisible = ref(false);
  const submitLoading = ref(false);
  const initialFormData: PlcTaskNameCreateForm = {
    methodName: "",
    methodDescription: "",
  };
  const formData = reactive<PlcTaskNameCreateForm>({ ...initialFormData });

  const rules: FormRules = {
    methodName: [{ required: true, message: "请输入方法名", trigger: "blur" }],
    methodDescription: [{ required: true, message: "请输入方法描述", trigger: "blur" }],
  };

  function handleCreateClick(): void {
    resetForm();
    dialogVisible.value = true;
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
      await PlcTaskNameAPI.create(formData);
      ElMessage.success("新增成功");
      closeDialog();
      handleQuery();
    } finally {
      submitLoading.value = false;
    }
  }

  async function handleDelete(row: PlcTaskNameItem): Promise<void> {
    if (!row.id) return;

    try {
      await ElMessageBox.confirm("确认删除该方法名配置吗？", "警告", {
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
      await PlcTaskNameAPI.deleteById(String(row.id));
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
  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
  }
</style>
