<template>
  <div class="page-container">
    <!-- 搜索 -->
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="关键词" prop="keyword">
          <el-input v-model="params.keyword" placeholder="料车编号/操作工" clearable />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="params.status" placeholder="料车状态" clearable style="width: 140px">
            <el-option label="空闲" :value="1" />
            <el-option label="使用中" :value="2" />
            <el-option label="已满载" :value="3" />
            <el-option label="维修" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="型号" prop="modelId">
          <el-select v-model="params.modelId" placeholder="选择型号" clearable filterable style="width: 160px">
            <el-option
              v-for="item in formOptions"
              :key="item.id"
              :label="item.modelCode + '-' + item.modelName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="区域" prop="area">
          <el-select v-model="params.area" placeholder="选择区域" clearable filterable style="width: 140px">
            <el-option v-for="item in areaList" :key="item" :label="item" :value="item" />
          </el-select>
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
            v-hasPerm="['carriermanagementsystem:cart:create']"
            type="primary"
            @click="handleCreateClick()"
          >新增</el-button>
          <el-button
            v-hasPerm="['carriermanagementsystem:cart:update']"
            :disabled="selectedIds.length === 0"
            @click="handleBatchStatus(2)"
          >标记使用中</el-button>
          <el-button
            v-hasPerm="['carriermanagementsystem:cart:update']"
            :disabled="selectedIds.length === 0"
            @click="handleBatchStatus(1)"
          >标记空闲</el-button>
          <el-button
            v-hasPerm="['carriermanagementsystem:cart:update']"
            :disabled="selectedIds.length === 0"
            @click="handleBatchStatus(4)"
          >标记维修</el-button>
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
          @selection-change="(rows) => (selectedIds = rows.map((r) => r.id!))"
        >
          <el-table-column type="selection" width="50" align="center" />
          <el-table-column key="cartCode" label="料车编号" prop="cartCode" min-width="130" align="center" />
          <el-table-column key="modelCode" label="型号代码" prop="modelCode" min-width="120" align="center" />
          <el-table-column key="modelName" label="型号名称" prop="modelName" min-width="130" align="center" />
          <el-table-column key="maxCapacity" label="有效容量" prop="maxCapacity" min-width="80" align="center" />
          <el-table-column key="currentQuantity" label="当前装载" prop="currentQuantity" min-width="80" align="center" />
          <el-table-column key="status" label="状态" prop="status" min-width="80" align="center">
            <template #default="scope">
              <el-tag v-if="scope.row.status === 1" type="success">空闲</el-tag>
              <el-tag v-else-if="scope.row.status === 2" type="primary">使用中</el-tag>
              <el-tag v-else-if="scope.row.status === 3" type="warning">已满载</el-tag>
              <el-tag v-else-if="scope.row.status === 4" type="danger">维修</el-tag>
              <span v-else>{{ scope.row.status }}</span>
            </template>
          </el-table-column>
          <el-table-column key="area" label="所在区域" prop="area" min-width="100" align="center" />
          <el-table-column key="bindWorker" label="绑定操作工" prop="bindWorker" min-width="100" align="center" />
          <el-table-column key="createdByName" label="创建人" prop="createdByName" min-width="100" align="center" />
          <el-table-column key="createdTime" label="创建时间" prop="createdTime" min-width="155" align="center" />
          <el-table-column key="updatedByName" label="修改人" prop="updatedByName" min-width="100" align="center" />
          <el-table-column key="updatedTime" label="修改时间" prop="updatedTime" min-width="155" align="center" />
          <el-table-column fixed="right" label="操作" width="170">
            <template #default="scope">
              <el-button
                v-hasPerm="['carriermanagementsystem:cart:update']"
                type="primary"
                size="small"
                link
                @click="handleEditClick(String(scope.row.id))"
              >编辑</el-button>
              <el-button
                v-hasPerm="['carriermanagementsystem:cart:delete']"
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

    <!-- 表单弹窗 -->
    <el-dialog
      v-model="dialog.visible"
      :title="dialog.title"
      width="600px"
      @close="closeDialog"
    >
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="120px">
        <el-form-item label="料车编号" prop="cartCode">
          <el-input v-model="formData.cartCode" placeholder="请输入料车编号" />
        </el-form-item>
        <el-form-item label="所属型号" prop="modelId">
          <el-select v-model="formData.modelId" placeholder="请选择型号" filterable style="width: 100%">
            <el-option
              v-for="item in formOptions"
              :key="item.id"
              :label="item.modelCode + '-' + item.modelName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="所在区域" prop="area">
          <el-input v-model="formData.area" placeholder="请输入所在区域" />
        </el-form-item>
        <el-form-item label="绑定操作工" prop="bindWorker">
          <el-input v-model="formData.bindWorker" placeholder="请输入绑定操作工" />
        </el-form-item>
        <el-form-item label="实际容量" prop="actualCapacity">
          <el-input-number v-model="formData.actualCapacity" :min="1" :max="9999" placeholder="留空则使用型号默认容量" style="width: 100%" />
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
  import { ref, reactive, onMounted } from "vue";
  import { useFullscreen } from "@vueuse/core";
  import {
    ElMessage,
    ElMessageBox,
    type FormInstance,
    type FormRules,
  } from "element-plus";
  import { FullScreen, Refresh } from "@element-plus/icons-vue";
  import { usePageTable } from "@/composables";
  import CartAPI from "@/api/carriermanagementsystem/cart";
  import type { CartItem, CartForm, CartQueryParams, CartModelOption } from "@/api/carriermanagementsystem/cart";

  defineOptions({
    name: "Cart",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const dataFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  const selectedIds = ref<number[]>([]);

  // 下拉选项
  const formOptions = ref<CartModelOption[]>([]);
  const areaList = ref<string[]>([]);

  // 表格数据
  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    CartItem,
    CartQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as CartQueryParams,
    request: CartAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  // 弹窗
  const dialog = reactive({
    title: "",
    visible: false,
  });

  // 表单数据
  const formData = reactive<CartForm>({} as CartForm);

  // 表单校验规则
  const rules: FormRules = {
    cartCode: [{ required: true, message: "请输入料车编号", trigger: "blur" }],
    modelId: [{ required: true, message: "请选择所属型号", trigger: "change" }],
  };

  async function loadOptions(): Promise<void> {
    const [models, areas] = await Promise.all([
      CartAPI.getFormOptions(),
      CartAPI.getAreas(),
    ]);
    formOptions.value = models;
    areaList.value = areas;
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
  }

  async function handleCreateClick(): Promise<void> {
    dialog.title = "新增料车";
    openDialog();
  }

  async function handleEditClick(id: string): Promise<void> {
    dialog.title = "修改料车";
    const data = await CartAPI.getFormData(id);
    Object.assign(formData, data);
    openDialog();
  }

  async function handleSubmit(): Promise<void> {
    const valid = await dataFormRef.value?.validate().then(
      () => true,
      () => false,
    );
    if (!valid) return;

    loading.value = true;
    try {
      const id = formData.id;
      if (id) {
        await CartAPI.update(String(id), formData);
        ElMessage.success("修改成功");
      } else {
        await CartAPI.create(formData);
        ElMessage.success("新增成功");
      }
      closeDialog();
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  async function handleDelete(id?: string): Promise<void> {
    if (!id) return;

    try {
      await ElMessageBox.confirm("确认删除已选中的数据项?", "警告", {
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
      await CartAPI.deleteByIds(id);
      ElMessage.success("删除成功");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  async function handleBatchStatus(status: number): Promise<void> {
    if (selectedIds.value.length === 0) return;

    const statusMap: Record<number, string> = { 1: "空闲", 2: "使用中", 4: "维修" };
    try {
      await ElMessageBox.confirm(
        `确认将选中的 ${selectedIds.value.length} 辆料车标记为「${statusMap[status]}」？`,
        "警告",
        { confirmButtonText: "确定", cancelButtonText: "取消", type: "warning" },
      );
    } catch {
      ElMessage.info("已取消操作");
      return;
    }

    loading.value = true;
    try {
      await CartAPI.batchUpdateStatus(selectedIds.value, status);
      ElMessage.success("状态更新成功");
      selectedIds.value = [];
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  onMounted(async () => {
    await loadOptions();
    handleQuery();
  });
</script>
