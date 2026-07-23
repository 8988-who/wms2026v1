<template>
  <view class="page page--padding">
    <view>
      <wd-search
        v-model="queryParams.keywords"
        placeholder="搜索配置名称/键名"
        hide-cancel
        @search="handleSearch"
      />
    </view>

    <view class="mt-16rpx">
      <wd-card
        v-for="item in pageData"
        :key="item.id"
        custom-class="item-card"
        @click="openConfigDialog(item.id)"
      >
        <view class="flex-between">
          <text class="font-bold text-32rpx">{{ item.configName }}</text>
          <view
            class="w-88rpx h-88rpx flex-center rounded-full"
            hover-class="bg-[var(--color-text-placeholder)]/16"
            @click.stop="showConfigActions(item)"
          >
            <wd-icon name="more" size="18" class="color-text-secondary" />
          </view>
        </view>

        <view class="mt-12rpx">
          <wd-cell-group border>
            <wd-cell title="配置项" :value="item.configKey" ellipsis />
            <wd-cell title="配置值" :value="item.configValue" ellipsis />
            <wd-cell title="描述" :value="item.remark || '暂无描述'" ellipsis />
          </wd-cell-group>
        </view>
      </wd-card>

      <wd-loadmore v-if="total > 0" :state="loadMoreState" @reload="fetchConfigList" />
      <wd-empty v-else-if="total === 0" icon="search" tip="暂无数据" />
    </view>

    <!-- 弹窗表单 -->
    <wd-popup
      v-model="dialog.visible"
      position="bottom"
      custom-class="popup-bottom"
      @close="closeConfigDialog"
    >
      <view class="p-4">
        <view class="popup-title">
          {{ formData.id ? "编辑配置" : "新增配置" }}
        </view>
        <wd-form ref="formRef" :model="formData" :schema="rules">
          <wd-form-item prop="configName" title="配置名称" required>
            <wd-input v-model="formData.configName" placeholder="请输入配置名称" />
          </wd-form-item>
          <wd-form-item prop="configKey" title="配置键名" required>
            <wd-input v-model="formData.configKey" placeholder="请输入配置键名" />
          </wd-form-item>
          <wd-form-item prop="configValue" title="配置键值" required>
            <wd-input v-model="formData.configValue" placeholder="请输入配置键值" />
          </wd-form-item>
          <wd-form-item prop="remark" title="描述">
            <wd-textarea
              v-model="formData.remark"
              placeholder="请输入配置描述"
              :maxlength="100"
              show-word-limit
            />
          </wd-form-item>
        </wd-form>
        <view class="popup-actions">
          <wd-button type="info" variant="plain" @click="closeConfigDialog">取消</wd-button>
          <wd-button type="primary" :loading="isSubmitting" @click="submitConfigForm">
            保存
          </wd-button>
        </view>
      </view>
    </wd-popup>

    <!-- 浮动新增按钮 -->
    <wd-fab
      v-if="hasPermission('sys:config:create') && !dialog.visible"
      :expandable="false"
      :gap="{ bottom: 32 }"
      @click="openConfigDialog()"
    />

    <!-- 操作菜单 -->
    <wd-action-sheet
      v-model="actionSheetVisible"
      :actions="actionSheetActions"
      cancel-text="取消"
      @select="handleActionSelect"
    />
  </view>
</template>

<script lang="ts" setup>
import { onLoad, onReachBottom } from "@dcloudio/uni-app";
import { LoadMoreState } from "@wot-ui/ui/components/wd-loadmore/types";
import { toFormSchema } from "@/utils/form";
import { useToast, useDialog } from "@wot-ui/ui";
import ConfigAPI, { type ConfigPageQuery, ConfigItem, ConfigForm } from "@/api/config";
import { hasPermission } from "@/utils/permission";

definePage({
  name: "config",
  style: { navigationBarTitleText: "系统配置" },
});

const toast = useToast();
const { confirm } = useDialog();
const loadMoreState = ref<LoadMoreState>("loading");
const formRef = ref();
const isSubmitting = ref(false);

const queryParams = reactive<ConfigPageQuery>({ pageNum: 1, pageSize: 10, keywords: "" });
const total = ref(0);
const pageData = ref<ConfigItem[]>([]);
const dialog = reactive({ visible: false });

const actionSheetVisible = ref(false);
const actionSheetActions = ref<{ name: string; color?: string }[]>([]);
const currentActionItem = ref<any>(null);

const initialFormData: ConfigForm = {
  id: undefined,
  configName: undefined,
  configKey: undefined,
  configValue: undefined,
  remark: undefined,
};

const formData = reactive<ConfigForm>({ ...initialFormData });

const rules = toFormSchema({
  configName: [{ required: true, message: "请输入配置名称" }],
  configKey: [{ required: true, message: "请输入配置键名" }],
  configValue: [{ required: true, message: "请输入配置键值" }],
});

// 搜索触发
const handleSearch = () => loadConfigList();

// 加载列表
function loadConfigList() {
  queryParams.pageNum = 1;
  fetchConfigList();
}

// 分页加载列表
function fetchConfigList() {
  loadMoreState.value = "loading";
  ConfigAPI.getPage(queryParams)
    .then((data: any) => {
      pageData.value = data.list;
      total.value = data.total;
      queryParams.pageNum++;
    })
    .catch(() => {
      pageData.value = [];
    })
    .finally(() => {
      loadMoreState.value = "finished";
    });
}

// 打开弹窗（新增/编辑）
async function openConfigDialog(id?: number) {
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
  dialog.visible = true;
  if (id) {
    formData.id = id;
    const data = await ConfigAPI.getFormData(id);
    Object.assign(formData, data, { id });
  }
}

// 提交表单
function submitConfigForm() {
  formRef.value.validate().then(({ valid }: { valid: boolean }) => {
    if (!valid) return;
    isSubmitting.value = true;
    const action = formData.id ? ConfigAPI.update(formData.id, formData) : ConfigAPI.add(formData);
    action
      .then(() => {
        toast.success("操作成功");
        closeConfigDialog();
        loadConfigList();
      })
      .finally(() => {
        isSubmitting.value = false;
      });
  });
}

// 关闭弹窗
function closeConfigDialog() {
  dialog.visible = false;
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
}

// 操作菜单分发
function handleActionSelect({ item }: { item: any }) {
  const value = item.name;
  const configItem = currentActionItem.value;
  if (value === "编辑") {
    openConfigDialog(configItem.id);
  } else if (value === "删除") {
    confirm({
      title: "确认删除",
      msg: `确定要删除配置「${configItem.configName}」吗？`,
      headerImage: "warning",
    }).then(async () => {
      await ConfigAPI.deleteById(configItem.id!);
      toast.success("删除成功");
      loadConfigList();
    });
  }
}

// 更多操作
function showConfigActions(item: ConfigItem) {
  const actions: { name: string; color?: string }[] = [];

  if (hasPermission("sys:config:update")) {
    actions.push({ name: "编辑" });
  }

  if (hasPermission("sys:config:delete")) {
    actions.push({ name: "删除", color: "var(--color-danger)" });
  }

  if (actions.length === 0) {
    toast.warning("暂无操作权限");
    return;
  }

  currentActionItem.value = item;
  actionSheetActions.value = actions;
  actionSheetVisible.value = true;
}

onReachBottom(() => {
  if (queryParams.pageNum * queryParams.pageSize < total.value) {
    fetchConfigList();
  } else {
    loadMoreState.value = "finished";
  }
});

onLoad(() => {
  loadConfigList();
});
</script>

<script lang="ts">
export default { options: { styleIsolation: "shared" } };
</script>
