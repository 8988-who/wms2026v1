<template>
  <div class="page-container">
    <!-- 搜索 -->
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="状态" prop="status">
          <el-select v-model="params.status" placeholder="状态" clearable>
            <el-option label="开启" :value="1" />
            <el-option label="关闭" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="厂区编码" prop="plantCode">
          <el-select v-model="params.plantCode" placeholder="厂区编码" clearable filterable @change="handlePlantCodeChange">
            <el-option v-for="item in filterOptions.plantCodes" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="楼层" prop="floor">
          <el-select v-model="params.floor" placeholder="如：1F, B1" clearable filterable @change="handleFloorChange">
            <el-option v-for="item in filterOptions.floors" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="区域编码" prop="locationCode">
          <el-select v-model="params.locationCode" placeholder="区域编码" clearable filterable>
            <el-option v-for="item in filterOptions.locationCodes" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="区域名称" prop="locationName">
          <el-input v-model="params.locationName" placeholder="请输入区域名称" clearable />
        </el-form-item>
        <el-form-item label="更新人" prop="updatedBy">
          <el-select v-model="params.updatedBy" placeholder="更新人" clearable filterable>
            <el-option v-for="item in filterOptions.updatedByNames" :key="item" :label="item" :value="item" />
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
              v-hasPerm="['warehouse:wms-location:create']"
              type="primary"
              @click="handleCreateClick()"
          >新增</el-button>
          <el-dropdown
              v-hasPerm="['warehouse:wms-location:update','warehouse:wms-location:delete']"
              :disabled="!hasSelection"
              @command="handleBatchCommand"
              style="margin-left: 10px;"
          >
            <el-button :disabled="!hasSelection">
              批量操作<el-icon class="el-icon--right"><ArrowDown /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="enable" v-hasPerm="['warehouse:wms-location:update']">启用</el-dropdown-item>
                <el-dropdown-item command="disable" v-hasPerm="['warehouse:wms-location:update']">停用</el-dropdown-item>
                <el-dropdown-item command="delete" v-hasPerm="['warehouse:wms-location:delete']" divided>删除</el-dropdown-item>
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
                key="plantCode"
                label="厂区编码"
                prop="plantCode"
                min-width="120"
                align="center"
              />
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
                key="locationType"
                label="区域类型"
                prop="locationType"
                min-width="100"
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
                    {{ scope.row.status === 1 ? '开启' : '关闭' }}
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
                v-hasPerm="['warehouse:wms-location:update']"
                type="primary"
                size="small"
                link
                @click="handleEditClick(String(scope.row.id))"
            >
              编辑
            </el-button>
            <el-button
                v-hasPerm="['warehouse:wms-location:delete']"
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

    <!-- 表单弹窗 -->
    <el-dialog
        v-model="dialog.visible"
        :title="dialog.title"
        width="600px"
        @close="closeDialog"
    >
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
                <el-form-item label="厂区编码" prop="plantCode">
                      <el-input
                          v-model="formData.plantCode"
                          placeholder="请输入厂区编码"
                          :readonly="!!formData.id"
                          :disabled="!!formData.id"
                      />
                </el-form-item>

                <el-form-item label="区域编码" prop="locationCode">
                      <el-input
                          v-model="formData.locationCode"
                          placeholder="系统自动生成"
                          readonly
                          disabled
                      />
                </el-form-item>

                <el-form-item label="区域名称" prop="locationName">
                      <el-input
                          v-model="formData.locationName"
                          placeholder="请输入区域名称"
                      />
                </el-form-item>

                <el-form-item label="区域类型" prop="locationType">
                      <el-select
                          v-model="formData.locationType"
                          placeholder="请选择区域类型（如：TURNOVER、DRY_ZONE、DRY_ROOM、BUFFER、PROD_LINE）"
                          clearable
                      >
                        <el-option
                            v-for="item in formOptions.locationTypes"
                            :key="item"
                            :label="item"
                            :value="item"
                        />
                      </el-select>
                </el-form-item>

                <el-form-item label="父级区域" prop="parentId">
                      <el-input
                          v-model="formData.parentId"
                          type="number"
                          :disabled="true"
                          placeholder="0表示顶级"
                      />
                </el-form-item>

                <el-form-item label="楼层" prop="floor">
                      <el-input
                          v-model="formData.floor"
                          placeholder="如：1F, 2F, B1"
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
                        <el-option label="开启" :value="1" />
                        <el-option label="关闭" :value="0" />
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
  import { useFullscreen } from "@vueuse/core";
  import {
    ElMessage,
    ElMessageBox,
    type FormInstance,
    type FormRules,
  } from "element-plus";
  import { FullScreen, Refresh, ArrowDown } from "@element-plus/icons-vue";
  import { usePageTable, useTableSelection } from "@/composables";
  import WmsLocationAPI from "@/api/warehouse/wms-location";
  import type { WmsLocationItem, WmsLocationForm, WmsLocationQueryParams } from "@/api/warehouse/wms-location";

  defineOptions({
    name: "WmsLocation",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const dataFormRef = ref<FormInstance>();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  const initialFormData = reactive({} as WmsLocationForm);
  // R-6 业务固化：区域仅单层使用（parent_id 恒为 0，不建子区域），表单父级区域固定 0 只读
  Object.assign(initialFormData, { parentId: "0" } as WmsLocationForm);

  // 库位/区域表格数据
  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    WmsLocationItem,
    WmsLocationQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as WmsLocationQueryParams,
    request: WmsLocationAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  const { selectedIds, hasSelection, handleSelectionChange } = useTableSelection<WmsLocationItem>();

  // 搜索下拉选项
  const filterOptions = reactive({
    plantCodes: [] as string[],
    locationCodes: [] as string[],
    floors: [] as string[],
    updatedByNames: [] as string[],
  });

  // R-7 启用：表单下拉选项（区域类型，来自后端 form-options，与 P1-3 用途语义固化一致）
  const formOptions = reactive({
    locationTypes: [] as string[],
  });

  async function loadFormOptions(): Promise<void> {
    try {
      const data = await WmsLocationAPI.getFormOptions();
      formOptions.locationTypes = data.locationTypes || [];
    } catch {
      // 加载失败不影响主功能
    }
  }

  async function loadFilterOptions(plantCode?: string, floor?: string): Promise<void> {
    try {
      const data = await WmsLocationAPI.getFilterOptions(plantCode, floor);
      // 厂区编码始终全量（后端保证），只在首次加载或重置时更新
      if (!plantCode && !floor) {
        filterOptions.plantCodes = data.plantCodes || [];
        filterOptions.floors = data.floors || [];
      }
      // 楼层只在未选楼层时更新（选厂区时刷新楼层列表）
      if (!floor) {
        filterOptions.floors = data.floors || [];
      }
      filterOptions.locationCodes = data.locationCodes || [];
      filterOptions.updatedByNames = data.updatedByNames || [];
    } catch {
      // 加载失败时使用空数组，不影响主功能
    }
  }

  /** 厂区编码变更：重置楼层和区域编码，重新加载楼层和区域编码选项 */
  function handlePlantCodeChange(): void {
    params.floor = undefined;
    params.locationCode = undefined;
    loadFilterOptions(params.plantCode);
  }

  /** 楼层变更：重置区域编码，重新加载区域编码选项 */
  function handleFloorChange(): void {
    params.locationCode = undefined;
    loadFilterOptions(params.plantCode, params.floor);
  }

  // 弹窗
  const dialog = reactive({
    title: "",
    visible: false,
  });

  // 库位/区域表单数据
  const formData = reactive<WmsLocationForm>({} as WmsLocationForm);

  // 库位/区域表单校验规则
  const rules: FormRules = {
                      plantCode: [{ required: true, message: "请输入厂区编码", trigger: "blur" }],
                      locationName: [{ required: true, message: "请输入区域名称", trigger: "blur" }],
                      locationType: [{ required: true, message: "请选择区域类型", trigger: "change" }],
                      parentId: [{ required: true, message: "请输入父级区域ID", trigger: "blur" }],
                      sortOrder: [{ required: true, message: "请输入排序号", trigger: "blur" }],
                      status: [{ required: true, message: "请选择状态", trigger: "change" }],

  };

  /**
   * 打开表单弹窗
   */
  function openDialog(): void {
    dialog.visible = true;
  }

  /**
   * 关闭弹窗并重置表单
   */
  function closeDialog(): void {
    dialog.visible = false;
    resetForm();
  }

  /**
   * 重置表单
   */
  function resetForm(): void {
    dataFormRef.value?.resetFields();
    dataFormRef.value?.clearValidate();
    Object.keys(formData).forEach((key) => {
      delete (formData as Record<string, unknown>)[key];
    });
    Object.assign(formData, initialFormData);
  }

  /**
   * 打开新增弹窗
   */
  async function handleCreateClick(): Promise<void> {
    dialog.title = "新增库位/区域";
    openDialog();
  }

  /**
   * 打开编辑弹窗并回填数据
   */
  async function handleEditClick(id: string): Promise<void> {
    dialog.title = "修改库位/区域";
    const data = await WmsLocationAPI.getFormData(id);
    Object.assign(formData, data);
    openDialog();
  }

  /**
   * 提交库位/区域表单
   */
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
        await WmsLocationAPI.update(String(id), formData);
        ElMessage.success("修改成功");
      } else {
        await WmsLocationAPI.create(formData);
        ElMessage.success("新增成功");
      }
      closeDialog();
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  /**
   * 批量删除库位/区域
   */
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
    // 统一 ids 为 number 类型（selectedIds 为 string | number，map(Number) 收敛）
    const ids = selectedIds.value.map(Number);
    if (!ids || ids.length === 0) {
      ElMessage.warning("请勾选需要操作的数据项");
      return;
    }

    try {
      await ElMessageBox.confirm(
        `确认${actionText}已选中的 ${ids.length} 个库位/区域?`,
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
      await WmsLocationAPI.updateStatus({ ids, status });
      ElMessage.success(`${actionText}成功`);
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  /**
   * 删除库位/区域
   */
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
      await WmsLocationAPI.deleteByIds(ids);
      ElMessage.success("删除成功");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  onMounted(() => {
    loadFormOptions();
    loadFilterOptions();
    handleQuery();
  });
</script>
