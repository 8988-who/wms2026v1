<template>
  <div class="page-container">
    <el-card class="page-search" shadow="never">
      <el-form ref="queryFormRef" :model="params" :inline="true">
        <el-form-item label="区域" prop="locationId">
          <el-select
            v-model="params.locationId"
            placeholder="全部区域"
            clearable
            filterable
            @change="handleLocationChange"
          >
            <el-option
              v-for="item in filterOptions.locations"
              :key="item.id"
              :label="item.locationName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="巷道" prop="aisleId">
          <el-select v-model="params.aisleId" placeholder="全部巷道" clearable filterable>
            <el-option
              v-for="item in filteredAisles"
              :key="item.id"
              :label="item.aisleName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="点位编码" prop="pointCode">
          <el-input v-model="params.pointCode" placeholder="点位编码" clearable />
        </el-form-item>
        <el-form-item label="料车编号" prop="cartCode">
          <el-input v-model="params.cartCode" placeholder="料车编号" clearable />
        </el-form-item>
        <el-form-item label="库存锁定" prop="lockStatus">
          <el-select v-model="params.lockStatus" placeholder="全部" clearable>
            <el-option label="正常" :value="0" />
            <el-option label="锁定" :value="1" />
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
          <el-button v-hasPerm="['inventory:cart-inventory:bind']" type="primary" @click="handleBindClick()">
            <el-icon style="margin-right: 4px"><Plus /></el-icon>绑定
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
          ref="dataTableRef"
          v-loading="loading"
          class="page-table"
          :data="list"
          height="100%"
          border
        >
          <el-table-column key="locationName" label="区域名称" prop="locationName" min-width="120" align="center" />
          <el-table-column key="aisleName" label="巷道名称" prop="aisleName" min-width="120" align="center" />
          <el-table-column key="pointName" label="点位名称" prop="pointName" min-width="140" align="center" />
          <el-table-column key="cartCode" label="料车编号" prop="cartCode" min-width="140" align="center">
            <template #default="scope">
              <span>{{ scope.row.cartCode || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column key="arriveTime" label="料车进入时刻" prop="arriveTime" min-width="150" align="center">
            <template #default="scope">
              <span>{{ scope.row.arriveTime || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column key="lastTaskCode" label="最近任务" min-width="150" align="center" show-overflow-tooltip>
            <template #default="scope">
              <span>{{ scope.row.lastTaskCode || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column key="lockStatus" label="库存锁定" min-width="90" align="center">
            <template #default="scope">
              <el-tag :type="scope.row.lockStatus === 1 ? 'danger' : 'success'">
                {{ scope.row.lockStatus === 1 ? '锁定' : '正常' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column key="remark" label="备注" prop="remark" min-width="150" align="center" show-overflow-tooltip>
            <template #default="scope">
              <span>{{ scope.row.remark || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column key="updatedByName" label="最后更新者" prop="updatedByName" min-width="110" align="center">
            <template #default="scope">
              <span>{{ scope.row.updatedByName || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column fixed="right" label="操作" width="220" align="center">
            <template #default="scope">
              <template v-if="!scope.row.cartId">
                <el-button
                  v-hasPerm="['inventory:cart-inventory:bind']"
                  type="primary"
                  size="small"
                  link
                  @click="handleBindClick(scope.row)"
                >
                  绑定
                </el-button>
              </template>
              <template v-else>
                <el-button
                  v-hasPerm="['inventory:cart-inventory:unbind']"
                  type="danger"
                  size="small"
                  link
                  @click="handleUnbind(scope.row)"
                >
                  解绑
                </el-button>
                <el-button
                  v-hasPerm="['inventory:cart-inventory:lock']"
                  :type="scope.row.lockStatus === 1 ? 'warning' : 'primary'"
                  size="small"
                  link
                  @click="handleLockToggle(scope.row)"
                >
                  {{ scope.row.lockStatus === 1 ? '解锁' : '锁定' }}
                </el-button>
              </template>
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

    <!-- 绑定弹窗：可从空位行进入（点位固定），也可从「绑定」按钮进入（点位+料车都选） -->
    <el-dialog v-model="dialog.visible" title="绑定料车" width="520px" @close="closeBindDialog">
      <el-form ref="bindFormRef" :model="bindForm" :rules="bindRules" label-width="100px">
        <el-form-item label="区域" prop="pointLocationId">
          <el-select
            v-model="pointFilter.locationId"
            placeholder="全部区域"
            clearable
            filterable
            @change="handlePointLocationChange"
          >
            <el-option
              v-for="item in filterOptions.locations"
              :key="item.id"
              :label="item.locationName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="巷道" prop="pointAisleId">
          <el-select v-model="pointFilter.aisleId" placeholder="全部巷道" clearable filterable @change="loadAvailablePoints">
            <el-option
              v-for="item in filteredPointAisles"
              :key="item.id"
              :label="item.aisleName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="点位" prop="pointId">
          <el-select
            v-model="bindForm.pointId"
            placeholder="请选择空位点位"
            filterable
            clearable
            :disabled="!!bindForm.fixedPointId"
            :loading="pointsLoading"
          >
            <el-option
              v-for="item in availablePoints"
              :key="item.pointId"
              :label="`${item.pointCode}${item.pointName ? ' - ' + item.pointName : ''}（${item.locationName} / ${item.aisleName}）`"
              :value="item.pointId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="料车" prop="cartId">
          <el-select v-model="bindForm.cartId" placeholder="请选择可用料车" filterable clearable>
            <el-option
              v-for="item in availableCarts"
              :key="item.id"
              :label="item.cartCode"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="handleBindSubmit">确定</el-button>
          <el-button @click="closeBindDialog">取消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted } from "vue";
  import { useFullscreen } from "@vueuse/core";
  import {
    ElMessage,
    ElMessageBox,
    type FormInstance,
    type FormRules,
  } from "element-plus";
  import { FullScreen, Plus, Refresh } from "@element-plus/icons-vue";
  import { usePageTable } from "@/composables";
  import CartInventoryAPI from "@/api/inventory/cart-inventory";
  import type {
    AisleOption,
    AvailableCartOption,
    AvailablePointOption,
    CartInventoryItem,
    CartInventoryQueryParams,
  } from "@/api/inventory/cart-inventory";

  defineOptions({
    name: "InventoryManage",
    inheritAttrs: false,
  });

  const queryFormRef = ref<FormInstance>();
  const dataTableRef = ref();
  const tableWrapperRef = ref<HTMLElement | null>(null);
  const { toggle: toggleFullscreen } = useFullscreen(tableWrapperRef);

  const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
    CartInventoryItem,
    CartInventoryQueryParams
  >({
    initialParams: {
      pageNum: 1,
      pageSize: 10,
    } as CartInventoryQueryParams,
    request: CartInventoryAPI.getPage,
    onBeforeReset: () => queryFormRef.value?.resetFields(),
  });

  const filterOptions = reactive({
    locations: [] as { id?: string; locationName?: string }[],
    aisles: [] as AisleOption[],
  });

  const filteredAisles = computed(() => {
    if (!params.locationId) {
      return filterOptions.aisles;
    }
    return filterOptions.aisles.filter((aisle) => aisle.locationId === params.locationId);
  });

  /** 切换区域时联动清空巷道 */
  function handleLocationChange(): void {
    params.aisleId = undefined;
  }

  async function loadFilterOptions(): Promise<void> {
    try {
      const data = await CartInventoryAPI.getFilterOptions();
      filterOptions.locations = data.locations || [];
      filterOptions.aisles = data.aisles || [];
    } catch {
      // 加载失败不影响主功能
    }
  }

  // ---------------- 绑定弹窗 ----------------
  const dialog = reactive({ visible: false });

  const bindFormRef = ref<FormInstance>();
  const bindForm = reactive<{
    pointId?: string;
    cartId?: string;
    fixedPointId?: string;
  }>({});

  const availableCarts = ref<AvailableCartOption[]>([]);
  const availablePoints = ref<AvailablePointOption[]>([]);
  const pointsLoading = ref(false);

  /** 点位下拉的区域/巷道联动筛选条件 */
  const pointFilter = reactive<{ locationId?: string; aisleId?: string }>({});
  const filteredPointAisles = computed(() => {
    if (!pointFilter.locationId) {
      return filterOptions.aisles;
    }
    return filterOptions.aisles.filter((aisle) => aisle.locationId === pointFilter.locationId);
  });

  const bindRules: FormRules = {
    pointId: [{ required: true, message: "请选择点位", trigger: "change" }],
    cartId: [{ required: true, message: "请选择料车", trigger: "change" }],
  };

  function closeBindDialog(): void {
    dialog.visible = false;
    bindFormRef.value?.resetFields();
    Object.keys(bindForm).forEach((key) => {
      delete (bindForm as Record<string, unknown>)[key];
    });
    pointFilter.locationId = undefined;
    pointFilter.aisleId = undefined;
  }

  /** 按当前区域/巷道筛选条件局部加载可用点位 */
  async function loadAvailablePoints(): Promise<void> {
    pointsLoading.value = true;
    try {
      availablePoints.value =
        (await CartInventoryAPI.getAvailablePoints({
          locationId: pointFilter.locationId,
          aisleId: pointFilter.aisleId,
        })) || [];
    } catch {
      ElMessage.error("加载可用点位失败");
    } finally {
      pointsLoading.value = false;
    }
  }

  /** 切换区域时联动清空巷道并重新加载点位 */
  function handlePointLocationChange(): void {
    pointFilter.aisleId = undefined;
    void loadAvailablePoints();
  }

  /** 打开绑定弹窗：row 为空表示从「绑定」按钮进入（点位+料车都选）；有 row 表示从空位行进入（点位固定） */
  async function handleBindClick(row?: CartInventoryItem): Promise<void> {
    try {
      const [carts] = await Promise.all([CartInventoryAPI.getAvailableCarts()]);
      availableCarts.value = carts || [];
      await loadAvailablePoints();
    } catch {
      ElMessage.error("加载可绑定数据失败");
      return;
    }
    if (row) {
      bindForm.fixedPointId = row.pointId;
      bindForm.pointId = row.pointId;
    }
    dialog.visible = true;
  }

  async function handleBindSubmit(): Promise<void> {
    const valid = await bindFormRef.value?.validate().then(
      () => true,
      () => false
    );
    if (!valid) return;
    if (!bindForm.pointId || !bindForm.cartId) return;

    loading.value = true;
    try {
      await CartInventoryAPI.bind({ pointId: bindForm.pointId, cartId: bindForm.cartId });
      ElMessage.success("绑定成功");
      closeBindDialog();
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  // ---------------- 解绑 / 锁定 / 解锁 ----------------
  async function handleUnbind(row: CartInventoryItem): Promise<void> {
    if (!row.pointId) return;
    try {
      await ElMessageBox.confirm(
        `确认将料车「${row.cartCode}」从点位「${row.pointName || row.pointCode}」解绑?`,
        "解绑确认",
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
      await CartInventoryAPI.unbind({ pointId: row.pointId });
      ElMessage.success("解绑成功");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  async function handleLockToggle(row: CartInventoryItem): Promise<void> {
    if (!row.pointId) return;
    const locking = row.lockStatus !== 1;
    try {
      await ElMessageBox.confirm(
        locking
          ? `确认锁定点位「${row.pointName || row.pointCode}」？锁定后该点位不再参与任务分配/定时搬运。`
          : `确认解锁点位「${row.pointName || row.pointCode}」？`,
        locking ? "锁定确认" : "解锁确认",
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
      if (locking) {
        await CartInventoryAPI.lock({ pointId: row.pointId });
      } else {
        await CartInventoryAPI.unlock({ pointId: row.pointId });
      }
      ElMessage.success(locking ? "锁定成功" : "解锁成功");
      handleQuery();
    } finally {
      loading.value = false;
    }
  }

  onMounted(async () => {
    await loadFilterOptions();
    handleQuery();
  });
</script>
