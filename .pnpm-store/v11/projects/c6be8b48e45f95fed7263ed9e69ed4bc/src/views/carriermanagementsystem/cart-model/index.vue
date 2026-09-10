<template>
  <div class="page-container">
    <!-- 搜索 -->
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="型号代码" prop="modelCode">
          <el-input v-model="params.modelCode" placeholder="型号代码" clearable />
        </el-form-item>
        <el-form-item label="型号名称" prop="modelName">
          <el-input v-model="params.modelName" placeholder="型号名称" clearable />
        </el-form-item>
        <el-form-item label="关键词" prop="keyword">
          <el-input v-model="params.keyword" placeholder="型号代码/名称" clearable />
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
            v-hasPerm="['carriermanagementsystem:cart-model:create']"
            type="primary"
            @click="handleCreateClick()"
          >新增</el-button>
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
        >
          <el-table-column key="modelCode" label="型号代码" prop="modelCode" min-width="120" align="center" />
          <el-table-column key="modelName" label="型号名称" prop="modelName" min-width="150" align="center" />
          <el-table-column key="maxCapacity" label="最大装载数量" prop="maxCapacity" min-width="110" align="center" />
          <el-table-column key="layerCount" label="层数" prop="layerCount" min-width="60" align="center" />
          <el-table-column key="cartCount" label="关联料车" prop="cartCount" min-width="80" align="center" />
          <el-table-column key="remark" label="备注" prop="remark" min-width="150" align="center" show-overflow-tooltip />
          <el-table-column key="createdByName" label="创建人" prop="createdByName" min-width="100" align="center" />
          <el-table-column key="createdTime" label="创建时间" prop="createdTime" min-width="160" align="center" />
          <el-table-column key="updatedByName" label="修改人" prop="updatedByName" min-width="100" align="center" />
          <el-table-column key="updatedTime" label="修改时间" prop="updatedTime" min-width="160" align="center" />
          <el-table-column fixed="right" label="操作" width="180">
            <template #default="scope">
              <el-button
                v-hasPerm="['carriermanagementsystem:cart-model:update']"
                type="primary"
                size="small"
                link
                @click="handleEditClick(String(scope.row.id))"
              >编辑</el-button>
              <el-button
                v-hasPerm="['carriermanagementsystem:cart-model:delete']"
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
        <el-form-item label="型号代码" prop="modelCode">
          <el-input v-model="formData.modelCode" placeholder="请输入型号代码，如 TC-100" />
        </el-form-item>
        <el-form-item label="型号名称" prop="modelName">
          <el-input v-model="formData.modelName" placeholder="请输入型号名称" />
        </el-form-item>
        <el-form-item label="最大装载数量" prop="maxCapacity">
          <el-input-number v-model="formData.maxCapacity" :min="1" :max="9999" placeholder="请输入" style="width: 100%" />
        </el-form-item>
        <el-form-item label="层数" prop="layerCount">
          <el-input-number v-model="formData.layerCount" :min="1" :max="99" placeholder="默认为1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="formData.remark" type="textarea" :rows="3" placeholder="请输入备注" />
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
  import CartModelAPI from "@/api/carriermanagementsystem/cart-model";
  import type { CartModelItem, CartModelForm, CartModelQueryParams } from "@/api/carriermanagementsystem/cart-model";

  defineOptions({
    name: "CartModel",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const dataFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  const initialFormData = reactive({} as CartModelForm);
  Object.assign(initialFormData, {} as CartModelForm);

  // 料车型号表格数据
  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    CartModelItem,
    CartModelQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as CartModelQueryParams,
    request: CartModelAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  // 弹窗
  const dialog = reactive({
    title: "",
    visible: false,
  });

  // 表单数据
  const formData = reactive<CartModelForm>({} as CartModelForm);

  // 表单校验规则
  const rules: FormRules = {
    modelCode: [{ required: true, message: "请输入型号代码", trigger: "blur" }],
    maxCapacity: [{ required: true, message: "请输入最大装载数量", trigger: "blur" }],
  };

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
    Object.assign(formData, initialFormData);
  }

  async function handleCreateClick(): Promise<void> {
    dialog.title = "新增料车型号";
    openDialog();
  }

  async function handleEditClick(id: string): Promise<void> {
    dialog.title = "修改料车型号";
    const data = await CartModelAPI.getFormData(id);
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
        await CartModelAPI.update(String(id), formData);
        ElMessage.success("修改成功");
      } else {
        await CartModelAPI.create(formData);
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
      await CartModelAPI.deleteByIds(id);
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
