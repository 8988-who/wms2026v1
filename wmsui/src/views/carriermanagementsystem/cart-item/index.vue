<template>
  <div class="page-container">
    <!-- 搜索 -->
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="料车编号" prop="cartCode">
          <el-select v-model="params.cartCode" placeholder="选择料车" clearable filterable style="width: 150px">
            <el-option v-for="item in carts" :key="item.id" :label="item.cartCode" :value="item.cartCode" />
          </el-select>
        </el-form-item>
        <el-form-item label="批次号" prop="batchNo">
          <el-input v-model="params.batchNo" placeholder="批次号" clearable style="width: 140px" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="params.status" placeholder="状态" clearable style="width: 120px">
            <el-option label="在车" :value="1" />
            <el-option label="已取走" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="装车时间">
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            value-format="YYYY-MM-DD HH:mm:ss"
            range-separator="-"
            start-placeholder="开始"
            end-placeholder="结束"
            style="width: 320px"
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
            v-hasPerm="['carriermanagementsystem:cart-item:create']"
            type="primary"
            @click="handleCreateClick()"
          >装车</el-button>
          <el-button
            v-hasPerm="['carriermanagementsystem:cart-item:update']"
            :disabled="selectedIds.length === 0"
            @click="handleBatchTake"
          >批量取走</el-button>
          <el-button
            v-hasPerm="['carriermanagementsystem:cart-item:delete']"
            :disabled="selectedIds.length === 0"
            type="danger"
            @click="handleBatchDelete"
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
          @selection-change="(rows) => {
            selectedRows = rows as CartItemRecord[];
            selectedIds = rows.map((r) => r.id!);
          }"
        >
          <el-table-column type="selection" width="50" align="center" />
          <el-table-column key="sortOrder" label="装货顺序" prop="sortOrder" width="60" align="center" />
          <el-table-column key="productCode" label="货品条码" prop="productCode" min-width="140" align="center" />
          <el-table-column key="productModel" label="货品型号" prop="productModel" min-width="120" align="center" />
          <el-table-column key="batchNo" label="批次号" prop="batchNo" min-width="120" align="center" />
          <el-table-column key="layerNo" label="层号" prop="layerNo" width="60" align="center" />
          <el-table-column key="cartCode" label="所在料车" prop="cartCode" min-width="120" align="center" />
          <el-table-column key="status" label="状态" width="80" align="center">
            <template #default="scope">
              <el-tag v-if="scope.row.status === 1" type="success">在车</el-tag>
              <el-tag v-else-if="scope.row.status === 2" type="info">已取走</el-tag>
              <span v-else>{{ scope.row.status }}</span>
            </template>
          </el-table-column>
          <el-table-column key="operator" label="操作人" prop="operator" width="100" align="center" />
          <el-table-column key="loadedAt" label="装车时间" prop="loadedAt" width="155" align="center" />
          <el-table-column key="takenAt" label="取走时间" prop="takenAt" width="155" align="center">
            <template #default="scope">
              <span v-if="scope.row.takenAt">{{ scope.row.takenAt }}</span>
              <span v-else class="text-muted">—</span>
            </template>
          </el-table-column>
          <el-table-column key="createdByName" label="创建人" prop="createdByName" width="100" align="center" />
          <el-table-column key="remark" label="备注" prop="remark" min-width="120" align="center">
            <template #default="scope">
              <span v-if="scope.row.remark">{{ scope.row.remark }}</span>
              <span v-else class="text-muted">—</span>
            </template>
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="200">
            <template #default="scope">
              <el-button
                v-if="scope.row.status === 1"
                v-hasPerm="['carriermanagementsystem:cart-item:update']"
                type="success"
                size="small"
                link
                @click="handleEdit(scope.row)"
              >编辑</el-button>
              <el-button
                v-if="scope.row.status === 1"
                v-hasPerm="['carriermanagementsystem:cart-item:update']"
                type="primary"
                size="small"
                link
                @click="handleTake(scope.row)"
              >取走</el-button>
              <el-button
                v-if="scope.row.status === 2"
                v-hasPerm="['carriermanagementsystem:cart-item:delete']"
                type="danger"
                size="small"
                link
                @click="handleDelete(scope.row)"
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

    <!-- 装车弹窗 -->
    <el-dialog
      v-model="dialog.visible"
      :title="dialog.title"
      width="550px"
      @close="closeDialog"
    >
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="料车编号" prop="cartId">
          <!-- 编辑态禁用：后端 updateCartItem 不支持修改 cartId（硬约束），避免"以为换车实际没换" -->
          <el-select v-model="formData.cartId" placeholder="请选择料车" filterable style="width: 100%" :disabled="dialog.isEdit">
            <el-option
              v-for="item in carts"
              :key="item.id"
              :label="item.cartCode"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="货品条码" prop="productCode">
          <el-input v-model="formData.productCode" placeholder="输入或扫描货品条码" />
        </el-form-item>
        <el-form-item label="货品型号" prop="productModel">
          <el-input v-model="formData.productModel" placeholder="输入货品型号" />
        </el-form-item>
        <el-form-item label="装货顺序" prop="sortOrder">
          <el-input-number v-model="formData.sortOrder" :min="1" :max="99999" style="width: 100%" />
        </el-form-item>
        <el-form-item label="批次号" prop="batchNo">
          <el-input v-model="formData.batchNo" placeholder="批次号/工单号" />
        </el-form-item>
        <el-form-item label="层号" prop="layerNo">
          <el-input-number v-model="formData.layerNo" :min="1" :max="20" :step="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="操作人" prop="operator">
          <el-input v-model="formData.operator" placeholder="装车操作人" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="formData.remark" type="textarea" :rows="2" placeholder="备注信息" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定装车</el-button>
          <el-button @click="closeDialog">取消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 取走确认弹窗 -->
    <el-dialog
      v-model="takeDialog.visible"
      title="确认取走"
      width="400px"
    >
      <div style="padding: 10px 0">
        <p>确认将以下物品取走？</p>
        <p style="margin-top: 10px; font-size: 14px">
          条码：<strong>{{ takeDialog.item?.productCode }}</strong><br>
          料车：<strong>{{ takeDialog.item?.cartCode }}</strong>
          （第 {{ takeDialog.item?.layerNo || 1 }} 层）
        </p>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="submitLoading" @click="confirmTake">确定取走</el-button>
          <el-button @click="takeDialog.visible = false">取消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, onMounted, watch } from "vue";
  import { useFullscreen } from "@vueuse/core";
  import {
    ElMessage,
    ElMessageBox,
    type FormInstance,
    type FormRules,
  } from "element-plus";
  import { FullScreen, Refresh } from "@element-plus/icons-vue";
  import { usePageTable } from "@/composables";
  import CartItemAPI from "@/api/carriermanagementsystem/cart-item";
  import type {
    CartItemRecord,
    CartItemForm,
    CartItemQueryParams,
    AvailableCart,
  } from "@/api/carriermanagementsystem/cart-item";

  defineOptions({
    name: "CartItem",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const dataFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  // 雪花 ID 为字符串（后端 Long 序列化为 string），保持字符串避免 Number 丢精度
  const selectedIds = ref<string[]>([]);
  // 勾选行对象（用于批量操作按目标状态过滤：取走=在车(1)、删除=已取走(2)）
  const selectedRows = ref<CartItemRecord[]>([]);
  const submitLoading = ref(false);

  // 下拉选项
  const carts = ref<AvailableCart[]>([]);
  const dateRange = ref<string[]>([]);

  // 表格数据
  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    CartItemRecord,
    CartItemQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as CartItemQueryParams,
    request: CartItemAPI.getPage,
    onBeforeReset: () => {
      queryFormRef.value?.resetFields();
      dateRange.value = [];
    },
  });

  // 时间范围联动（CartItemQueryParams 已声明 loadedAtStart/loadedAtEnd，直接赋值）
  watch(dateRange, ([start, end]) => {
    params.loadedAtStart = start;
    params.loadedAtEnd = end;
  });

  // 弹窗
  const dialog = reactive({
    title: "",
    visible: false,
    isEdit: false,
    editId: null as string | null,
  });

  const takeDialog = reactive({
    visible: false,
    item: null as CartItemRecord | null,
  });

  // 表单数据
  const formData = reactive<CartItemForm>({
    layerNo: 1,
  } as CartItemForm);

  // 表单校验规则
  const rules: FormRules = {
    cartId: [{ required: true, message: "请选择料车", trigger: "change" }],
    productCode: [{ required: true, message: "请输入货品条码", trigger: "blur" }],
    productModel: [{ required: true, message: "请输入货品型号", trigger: "blur" }],
    sortOrder: [{ required: true, message: "请输入装货顺序", trigger: "blur" }],
  };

  async function loadOptions(): Promise<void> {
    try {
      carts.value = await CartItemAPI.getFormOptions();
    } catch {
      carts.value = [];
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
    formData.layerNo = 1;
  }

  function handleCreateClick(): void {
    dialog.title = "装车";
    dialog.isEdit = false;
    dialog.editId = null;
    openDialog();
  }

  async function handleEdit(row: CartItemRecord): Promise<void> {
    if (!row.id) return;
    try {
      const data = await CartItemAPI.getFormData(String(row.id));
      Object.assign(formData, data || {});
      dialog.title = "编辑明细";
      dialog.isEdit = true;
      dialog.editId = row.id;
      openDialog();
    } catch {
      ElMessage.error("加载数据失败");
    }
  }

  async function handleSubmit(): Promise<void> {
    const valid = await dataFormRef.value?.validate().then(
      () => true,
      () => false,
    );
    if (!valid) return;

    submitLoading.value = true;
    try {
      if (dialog.isEdit && dialog.editId) {
        await CartItemAPI.update(dialog.editId, formData);
        ElMessage.success("修改成功");
      } else {
        await CartItemAPI.create(formData);
        ElMessage.success("装车成功");
      }
      closeDialog();
      handleQuery();
    } catch (e: unknown) {
      const msg = (e as { msg?: string })?.msg || "操作失败";
      ElMessage.error(msg);
    } finally {
      submitLoading.value = false;
    }
  }

  function handleTake(item: CartItemRecord): void {
    takeDialog.item = item;
    takeDialog.visible = true;
  }

  async function confirmTake(): Promise<void> {
    if (!takeDialog.item?.id) return;
    submitLoading.value = true;
    try {
      await CartItemAPI.take(takeDialog.item.id);
      ElMessage.success("取走成功");
      takeDialog.visible = false;
      handleQuery();
    } catch (e: unknown) {
      const msg = (e as { msg?: string })?.msg || "取走失败";
      ElMessage.error(msg);
    } finally {
      submitLoading.value = false;
    }
  }

  async function handleBatchTake(): Promise<void> {
    // 方案 A：前端过滤目标状态（在车 status=1），已取走/无关行自动忽略
    const takeIds = selectedRows.value
      .filter((r) => r.status === 1)
      .map((r) => r.id!)
      .filter((id): id is string => Boolean(id));
    if (takeIds.length === 0) {
      ElMessage.warning("勾选中没有可批量取走的在车明细");
      return;
    }
    const skipped = selectedRows.value.length - takeIds.length;

    try {
      await ElMessageBox.confirm(
        skipped > 0
          ? `将取走勾选中 ${takeIds.length} 件在车物品，另有 ${skipped} 件已取走记录将被忽略。`
          : `确认将选中的 ${takeIds.length} 件物品取走？`,
        "警告",
        { confirmButtonText: "确定", cancelButtonText: "取消", type: "warning" },
      );
    } catch {
      ElMessage.info("已取消操作");
      return;
    }

    submitLoading.value = true;
    try {
      await CartItemAPI.batchTake(takeIds);
      ElMessage.success("批量取走成功");
      selectedIds.value = [];
      selectedRows.value = [];
      handleQuery();
    } catch (e: unknown) {
      const msg = (e as { msg?: string })?.msg || "批量取走失败";
      ElMessage.error(msg);
    } finally {
      submitLoading.value = false;
    }
  }

  async function handleDelete(item: CartItemRecord): Promise<void> {
    if (!item.id) return;

    try {
      await ElMessageBox.confirm("确认删除该记录？", "警告", {
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
      await CartItemAPI.deleteByIds(String(item.id));
      ElMessage.success("删除成功");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  async function handleBatchDelete(): Promise<void> {
    // 方案 A：前端过滤目标状态（已取走 status=2），在车记录自动忽略
    const delIds = selectedRows.value
      .filter((r) => r.status === 2)
      .map((r) => r.id!)
      .filter((id): id is string => Boolean(id));
    if (delIds.length === 0) {
      ElMessage.warning("勾选中没有可删除的已取走记录");
      return;
    }
    const skipped = selectedRows.value.length - delIds.length;

    try {
      await ElMessageBox.confirm(
        skipped > 0
          ? `将删除勾选中 ${delIds.length} 条已取走记录，另有 ${skipped} 条在车记录将被忽略（不允许删除）。`
          : `确认删除选中的 ${delIds.length} 条记录？仅允许删除已取走的记录。`,
        "警告",
        { confirmButtonText: "确定", cancelButtonText: "取消", type: "warning" },
      );
    } catch {
      ElMessage.info("已取消删除");
      return;
    }

    loading.value = true;
    try {
      await CartItemAPI.deleteByIds(delIds.join(","));
      ElMessage.success("删除成功");
      selectedIds.value = [];
      selectedRows.value = [];
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

<style scoped>
.text-muted {
  color: #c0c4cc;
}
</style>
