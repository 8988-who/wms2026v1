<template>
  <div class="page-container">
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="状态" prop="status">
          <el-select v-model="params.status" placeholder="状态" clearable>
            <el-option label="启用" :value="1" />
            <el-option label="停用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="点位编码" prop="pointCode">
          <el-select v-model="params.pointCode" placeholder="点位编码" clearable filterable>
            <el-option v-for="item in filterOptions.pointCodes" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="区域编码" prop="locationCode">
          <el-select v-model="params.locationCode" placeholder="区域编码" clearable filterable>
            <el-option v-for="item in filterOptions.locationCodes" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="巷道编码" prop="aisleCode">
          <el-select v-model="params.aisleCode" placeholder="巷道编码" clearable filterable>
            <el-option v-for="item in filterOptions.aisleCodes" :key="item" :label="item" :value="item" />
          </el-select>
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
              v-hasPerm="['warehouse:wms-point:create']"
              type="primary"
              @click="handleCreateClick()"
          >新增</el-button>
          <el-dropdown
              v-hasPerm="['warehouse:wms-point:update','warehouse:wms-point:delete']"
              @command="handleBatchCommand"
              style="margin-left: 10px;"
          >
            <el-button @click="handleBatchClick">
              批量操作<el-icon class="el-icon--right"><ArrowDown /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="enable" v-hasPerm="['warehouse:wms-point:update']">启用</el-dropdown-item>
                <el-dropdown-item command="disable" v-hasPerm="['warehouse:wms-point:update']">停用</el-dropdown-item>
                <el-dropdown-item command="delete" v-hasPerm="['warehouse:wms-point:delete']" divided>删除</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
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
          @selection-change="handleSelectionChange"
        >
        <el-table-column type="selection" width="55" align="center" />
              <el-table-column
                key="locationCode"
                label="区域编码"
                prop="locationCode"
                min-width="120"
                align="center"
              />
              <el-table-column
                key="locationName"
                label="区域名称"
                prop="locationName"
                min-width="120"
                align="center"
              />
              <el-table-column
                key="aisleCode"
                label="巷道编码"
                prop="aisleCode"
                min-width="120"
                align="center"
              />
              <el-table-column
                key="aisleName"
                label="巷道名称"
                prop="aisleName"
                min-width="120"
                align="center"
              />
              <el-table-column
                key="pointCode"
                label="点位编码"
                prop="pointCode"
                min-width="140"
                align="center"
              />
              <el-table-column
                key="pointName"
                label="点位名称"
                prop="pointName"
                min-width="150"
                align="center"
              />
              <el-table-column
                key="barcode"
                label="点位条码"
                prop="barcode"
                min-width="120"
                align="center"
              />
              <el-table-column
                key="coordinate"
                label="地图坐标"
                prop="coordinate"
                min-width="120"
                align="center"
              />
              <el-table-column
                key="floor"
                label="楼层"
                prop="floor"
                min-width="80"
                align="center"
              />
              <el-table-column
                key="sortOrder"
                label="排序号"
                prop="sortOrder"
                min-width="80"
                align="center"
              />
              <el-table-column
                key="status"
                label="状态"
                min-width="80"
                align="center"
              >
                <template #default="scope">
                  <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">
                    {{ scope.row.status === 1 ? '启用' : '停用' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column
                key="remark"
                label="备注"
                prop="remark"
                min-width="150"
                align="center"
              />
              <el-table-column
                key="createdByName"
                label="创建人"
                prop="createdByName"
                min-width="100"
                align="center"
              />
              <el-table-column
                key="createdTime"
                label="创建时间"
                prop="createdTime"
                min-width="160"
                align="center"
              />
              <el-table-column
                key="updatedByName"
                label="修改人"
                prop="updatedByName"
                min-width="100"
                align="center"
              />
              <el-table-column
                key="updatedTime"
                label="修改时间"
                prop="updatedTime"
                min-width="160"
                align="center"
              />
        <el-table-column fixed="right" label="操作" width="180">
          <template #default="scope">
            <el-button
                v-hasPerm="['warehouse:wms-point:update']"
                type="primary"
                size="small"
                link
                @click="handleEditClick(String(scope.row.id))"
            >
              编辑
            </el-button>
            <el-button
                v-hasPerm="['warehouse:wms-point:delete']"
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

    <el-dialog
        v-model="dialog.visible"
        :title="dialog.title"
        width="700px"
        @close="closeDialog"
    >
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
                <el-form-item label="厂区编码" prop="plantCode">
                      <el-select
                          v-model="formData.plantCode"
                          placeholder="请选择厂区编码"
                          filterable
                          clearable
                          @change="handleFormPlantCodeChange"
                      >
                        <el-option v-for="item in formOptions.plantCodes" :key="item" :label="item" :value="item" />
                      </el-select>
                </el-form-item>

                <el-form-item label="所属区域" prop="locationId">
                      <el-select
                          v-model="formData.locationId"
                          placeholder="请选择所属区域"
                          filterable
                          clearable
                          @change="handleFormLocationChange"
                      >
                        <el-option
                            v-for="item in formOptions.filteredLocations"
                            :key="item.id"
                            :label="item.label"
                            :value="item.id"
                        />
                      </el-select>
                </el-form-item>

                <el-form-item label="所属巷道" prop="aisleId">
                      <el-select
                          v-model="formData.aisleId"
                          placeholder="请选择所属巷道"
                          filterable
                          clearable
                          @change="handleFormAisleChange"
                      >
                        <el-option
                            v-for="item in formOptions.filteredAisles"
                            :key="item.id"
                            :label="item.label"
                            :value="item.id"
                        />
                      </el-select>
                </el-form-item>

                <el-form-item label="点位编码" prop="pointCode">
                      <el-input
                          v-model="formData.pointCode"
                          placeholder="系统自动生成（巷道编码-P序号）"
                          readonly
                      />
                </el-form-item>

                <el-form-item label="点位名称" prop="pointName">
                      <el-input
                          v-model="formData.pointName"
                          placeholder="请输入点位名称"
                      />
                </el-form-item>

                <el-form-item label="点位条码" prop="barcode">
                      <el-input
                          v-model="formData.barcode"
                          placeholder="请输入点位条码（PDA/AGV扫码识别用）"
                      />
                </el-form-item>

                <el-form-item label="地图坐标" prop="coordinate">
                      <el-input
                          v-model="formData.coordinate"
                          placeholder="请输入地图坐标（如 X=100,Y=200,Z=0）"
                      />
                </el-form-item>

                <el-form-item label="楼层" prop="floor">
                      <el-input
                          v-model="formData.floor"
                          placeholder="选择区域后自动获取"
                          readonly
                      />
                </el-form-item>

                <el-form-item label="排序号" prop="sortOrder">
                      <el-input
                          v-model="formData.sortOrder"
                          type="number"
                          placeholder="请输入排序号"
                      />
                </el-form-item>

                <el-form-item label="状态" prop="status">
                      <el-select v-model="formData.status" placeholder="请选择状态">
                        <el-option label="启用" :value="1" />
                        <el-option label="停用" :value="0" />
                      </el-select>
                </el-form-item>

                <el-form-item label="备注" prop="remark">
                      <el-input
                          v-model="formData.remark"
                          placeholder="请输入备注"
                      />
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
  import { FullScreen, Refresh, ArrowDown } from "@element-plus/icons-vue";
  import { usePageTable, useTableSelection } from "@/composables";
  import WmsPointAPI from "@/api/warehouse/wms-point";
  import type { WmsPointItem, WmsPointForm, WmsPointQueryParams, WmsPointLocationOption, WmsPointAisleOption } from "@/api/warehouse/wms-point";

  defineOptions({
    name: "WmsPoint",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const dataFormRef = ref<FormInstance>();
  const dataTableRef = ref();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  const initialFormData = reactive({} as WmsPointForm);
  Object.assign(initialFormData, {} as WmsPointForm);

  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    WmsPointItem,
    WmsPointQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as WmsPointQueryParams,
    request: WmsPointAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  const { selectedIds, hasSelection, handleSelectionChange } = useTableSelection<WmsPointItem>();

  /** 点击批量操作时自动全选当前页 */
  function handleBatchClick(): void {
    if (!hasSelection.value) {
      dataTableRef.value?.toggleAllSelection();
    }
  }

  const formOptions = reactive({
    plantCodes: [] as string[],
    locations: [] as WmsPointLocationOption[],
    filteredLocations: [] as WmsPointLocationOption[],
    aisles: [] as WmsPointAisleOption[],
    filteredAisles: [] as WmsPointAisleOption[],
  });

  async function loadFormOptions(): Promise<void> {
    try {
      const data = await WmsPointAPI.getFormOptions();
      formOptions.plantCodes = data.plantCodes || [];
      formOptions.locations = data.locations || [];
      formOptions.filteredLocations = data.locations || [];
      formOptions.aisles = data.aisles || [];
      formOptions.filteredAisles = data.aisles || [];
    } catch {
      // 加载失败不影响主功能
    }
  }

  function handleFormPlantCodeChange(): void {
    formData.locationId = undefined;
    formData.aisleId = undefined;
    const selectedPlant = formData.plantCode;
    if (selectedPlant) {
      formOptions.filteredLocations = formOptions.locations.filter(
        (loc) => loc.code?.startsWith(selectedPlant)
      );
    } else {
      formOptions.filteredLocations = formOptions.locations;
    }
    handleFormLocationChange();
  }

  function handleFormLocationChange(): void {
    formData.aisleId = undefined;
    const selectedId = formData.locationId;
    if (selectedId) {
      const selected = formOptions.filteredLocations.find((loc) => loc.id === selectedId);
      formData.floor = selected?.floor || '';
      formOptions.filteredAisles = formOptions.aisles.filter(
        (aisle) => aisle.locationId === selectedId
      );
    } else {
      formData.floor = '';
      formOptions.filteredAisles = formOptions.aisles;
    }
  }

  function handleFormAisleChange(): void {
    const selectedId = formData.aisleId;
    if (selectedId) {
      const selected = formOptions.filteredAisles.find((aisle) => aisle.id === selectedId);
      if (selected) {
        const location = formOptions.filteredLocations.find((loc) => loc.id === selected.locationId);
        formData.floor = location?.floor || '';
        formData.plantCode = location?.code?.split('-')[0] || '';
      }
    }
  }

  const filterOptions = reactive({
    pointCodes: [] as string[],
    locationCodes: [] as string[],
    aisleCodes: [] as string[],
  });

  async function loadFilterOptions(): Promise<void> {
    try {
      const data = await WmsPointAPI.getFilterOptions();
      filterOptions.pointCodes = data.pointCodes || [];
      filterOptions.locationCodes = data.locationCodes || [];
      filterOptions.aisleCodes = data.aisleCodes || [];
    } catch {
      // 加载失败不影响主功能
    }
  }

  const dialog = reactive({
    title: "",
    visible: false,
  });

  const formData = reactive<WmsPointForm>({} as WmsPointForm);

  const rules: FormRules = {
    plantCode: [{ required: true, message: "请选择厂区编码", trigger: "change" }],
    locationId: [{ required: true, message: "请选择所属区域", trigger: "change" }],
    aisleId: [{ required: true, message: "请选择所属巷道", trigger: "change" }],
    pointName: [{ required: true, message: "请输入点位名称", trigger: "blur" }],
    sortOrder: [{ required: true, message: "请输入排序号", trigger: "blur" }],
    status: [{ required: true, message: "请选择状态", trigger: "change" }],
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
    dialog.title = "新增点位";
    openDialog();
  }

  async function handleEditClick(id: string): Promise<void> {
    dialog.title = "修改点位";
    const data = await WmsPointAPI.getFormData(id);
    Object.assign(formData, data);
    openDialog();
    handleFormPlantCodeChange();
    if (formData.locationId) {
      handleFormLocationChange();
    }
  }

  async function handleSubmit(): Promise<void> {
    const valid = await dataFormRef.value?.validate().then(
      () => true,
      () => false
    );
    if (!valid) return;

    loading.value = true;
    try {
      const id = formData.id;
      if (id) {
        await WmsPointAPI.update(String(id), formData);
        ElMessage.success("修改成功");
      } else {
        await WmsPointAPI.create(formData);
        ElMessage.success("新增成功");
      }
      closeDialog();
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  function handleBatchDelete(): void {
    handleDelete();
  }

  async function handleBatchCommand(command: string): Promise<void> {
    switch (command) {
      case "enable":
        await handleBatchStatus(1, "启用");
        break;
      case "disable":
        await handleBatchStatus(0, "停用");
        break;
      case "delete":
        await handleBatchDelete();
        break;
    }
  }

  async function handleBatchStatus(status: number, actionText: string): Promise<void> {
    const ids = selectedIds.value;
    if (!ids || ids.length === 0) {
      ElMessage.warning("请勾选需要操作的数据项");
      return;
    }

    try {
      await ElMessageBox.confirm(
        `确认${actionText}已选中的 ${ids.length} 个点位?`,
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
      await WmsPointAPI.updateStatus({ ids, status });
      ElMessage.success(`${actionText}成功`);
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  async function handleDelete(id?: string): Promise<void> {
    const ids = id || selectedIds.value.join(",");
    if (!ids) {
      ElMessage.warning("请勾选删除项");
      return;
    }

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
      await WmsPointAPI.deleteByIds(ids);
      ElMessage.success("删除成功");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  onMounted(async () => {
    await loadFormOptions();
    loadFilterOptions();
    handleQuery();
  });
</script>