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
          <span class="page-toolbar__title">库存状况</span>
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
          <el-table-column key="cartStatus" label="料车状态" prop="cartStatus" min-width="90" align="center">
            <template #default="scope">
              <el-tag v-if="scope.row.cartStatus === 1" type="success">空闲</el-tag>
              <el-tag v-else-if="scope.row.cartStatus === 2" type="primary">使用中</el-tag>
              <el-tag v-else-if="scope.row.cartStatus === 3" type="warning">已满载</el-tag>
              <el-tag v-else-if="scope.row.cartStatus === 4" type="danger">维修</el-tag>
              <span v-else>-</span>
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
          <el-table-column key="currentQuantity" label="装载(当前)" prop="currentQuantity" min-width="90" align="center">
            <template #default="scope">
              <span v-if="scope.row.cartId">{{ scope.row.currentQuantity ?? 0 }}</span>
              <span v-else>-</span>
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
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted } from "vue";
  import { useFullscreen } from "@vueuse/core";
  import type { FormInstance } from "element-plus";
  import { FullScreen, Refresh } from "@element-plus/icons-vue";
  import { usePageTable } from "@/composables";
  import CartInventoryAPI from "@/api/inventory/cart-inventory";
  import type {
    AisleOption,
    CartInventoryItem,
    CartInventoryQueryParams,
  } from "@/api/inventory/cart-inventory";

  defineOptions({
    name: "InventoryView",
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

  onMounted(async () => {
    await loadFilterOptions();
    handleQuery();
  });
</script>
