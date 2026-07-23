<template>
  <view class="page page--padding">
    <view>
      <wd-search
        v-model="queryParams.keywords"
        placeholder="搜索字典名称/编码"
        hide-cancel
        @search="handleSearch"
      />
    </view>

    <view class="mt-16rpx">
      <wd-card
        v-for="item in pageData"
        :key="item.id"
        custom-class="item-card"
        @click="openDictItemPage(item)"
      >
        <view class="flex-start">
          <view class="flex-1">
            <view class="flex-start">
              <text class="font-bold text-32rpx">{{ item.name }}</text>
            </view>
            <text class="text-24rpx color-text-secondary">字典编码：{{ item.dictCode }}</text>
          </view>
          <wd-tag :type="item.status === 1 ? 'success' : 'danger'" variant="plain">
            {{ item.status === 1 ? "启用" : "禁用" }}
          </wd-tag>
        </view>

        <view class="flex-between mt-16rpx">
          <text class="text-24rpx color-text-placeholder">{{ item.remark || "暂无备注" }}</text>
          <view
            class="w-88rpx h-88rpx flex-center rounded-full"
            hover-class="bg-[var(--color-text-placeholder)]/16"
            @click.stop="showDictActions(item)"
          >
            <wd-icon name="more" size="18" class="color-text-secondary" />
          </view>
        </view>
      </wd-card>

      <wd-loadmore v-if="total > 0" :state="loadMoreState" @reload="fetchDictTypeList" />
      <wd-empty v-else-if="total === 0" icon="search" tip="暂无数据" />
    </view>

    <wd-popup
      v-model="dialog.visible"
      position="bottom"
      custom-class="popup-bottom"
      @close="closeDictDialog"
    >
      <view class="p-4">
        <view class="popup-title">
          {{ formData.id ? "编辑字典" : "新增字典" }}
        </view>
        <wd-form ref="formRef" :model="formData" :schema="rules">
          <wd-form-item prop="name" title="字典名称" required>
            <wd-input v-model="formData.name" placeholder="请输入字典名称" />
          </wd-form-item>
          <wd-form-item prop="dictCode" title="字典编码" required>
            <wd-input v-model="formData.dictCode" placeholder="请输入字典编码" />
          </wd-form-item>
          <wd-form-item prop="status" title="状态">
            <wd-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
          </wd-form-item>
          <wd-form-item prop="remark" title="备注">
            <wd-textarea
              v-model="formData.remark"
              placeholder="请输入备注"
              :maxlength="100"
              show-word-limit
            />
          </wd-form-item>
        </wd-form>
        <view class="popup-actions">
          <wd-button type="info" variant="plain" @click="closeDictDialog">取消</wd-button>
          <wd-button type="primary" :loading="isSubmitting" @click="submitDictForm">保存</wd-button>
        </view>
      </view>
    </wd-popup>

    <wd-action-sheet
      v-model="actionSheetVisible"
      :actions="actionSheetActions"
      cancel-text="取消"
      @select="handleActionSelect"
    />

    <wd-fab
      v-if="hasPermission('sys:dict:create') && !dialog.visible"
      :expandable="false"
      :gap="{ bottom: 32 }"
      @click="openDictDialog()"
    />
  </view>
</template>

<script lang="ts" setup>
import { onLoad, onReachBottom } from "@dcloudio/uni-app";
import { useRouter } from "uni-mini-router";
import { LoadMoreState } from "@wot-ui/ui/components/wd-loadmore/types";
import { toFormSchema } from "@/utils/form";
import { useToast, useDialog } from "@wot-ui/ui";
import DictAPI, { type DictTypeForm, type DictTypePageQuery, type DictTypeItem } from "@/api/dict";
import { hasPermission } from "@/utils/permission";

definePage({
  name: "dict",
  style: { navigationBarTitleText: "字典管理" },
});

const router = useRouter();
const toast = useToast();
const { confirm } = useDialog();
const loadMoreState = ref<LoadMoreState>("loading");
const formRef = ref();
const isSubmitting = ref(false);

const queryParams = reactive<DictTypePageQuery>({ pageNum: 1, pageSize: 10, keywords: "" });
const total = ref(0);
const pageData = ref<DictTypeItem[]>([]);
const dialog = reactive({ visible: false });

const initialFormData: DictTypeForm = {
  id: undefined,
  name: undefined,
  dictCode: undefined,
  status: 1,
  remark: undefined,
};

const formData = reactive<DictTypeForm>({ ...initialFormData });

const rules = toFormSchema({
  name: [{ required: true, message: "请输入字典名称" }],
  dictCode: [{ required: true, message: "请输入字典编码" }],
});

const handleSearch = () => loadDictTypeList();

function loadDictTypeList() {
  queryParams.pageNum = 1;
  fetchDictTypeList();
}

function fetchDictTypeList() {
  loadMoreState.value = "loading";
  DictAPI.getPage(queryParams)
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

function openDictItemPage(item: DictTypeItem) {
  if (!item.dictCode) return;
  router.push({
    path: "/pages/work/dict/item/index",
    query: { dictCode: item.dictCode, title: `【${item.name}】字典数据` },
  });
}

async function openDictDialog(id?: string) {
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
  dialog.visible = true;
  if (id) {
    formData.id = id;
    const data = await DictAPI.getFormData(id);
    Object.assign(formData, data, { id });
  }
}

function submitDictForm() {
  formRef.value.validate().then(({ valid }: { valid: boolean }) => {
    if (!valid) return;
    isSubmitting.value = true;
    const id = formData.id;
    const action = id ? DictAPI.update(id, formData) : DictAPI.create(formData);
    action
      .then(() => {
        toast.success("操作成功");
        closeDictDialog();
        loadDictTypeList();
      })
      .finally(() => {
        isSubmitting.value = false;
      });
  });
}

function closeDictDialog() {
  dialog.visible = false;
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
}

const actionSheetVisible = ref(false);
const actionSheetActions = ref<{ name: string; color?: string }[]>([]);
const pendingAction = ref<Record<string, () => void>>({});

function showDictActions(item: DictTypeItem) {
  const actions: { name: string; color?: string }[] = [];
  const actionMap: Record<string, () => void> = {};

  actions.push({ name: "字典数据" });
  actionMap["字典数据"] = () => openDictItemPage(item);

  if (hasPermission("sys:dict:update")) {
    actions.push({ name: "编辑" });
    actionMap["编辑"] = () => openDictDialog(item.id);
  }

  if (hasPermission("sys:dict:delete")) {
    actions.push({ name: "删除", color: "var(--color-danger)" });
    actionMap["删除"] = async () => {
      try {
        await confirm({
          title: "确认删除",
          msg: `确定要删除字典「${item.name}」吗？`,
          headerImage: "warning",
        });
        if (item.id) {
          await DictAPI.deleteByIds(String(item.id));
          toast.success("删除成功");
          loadDictTypeList();
        }
      } catch {
        // 用户取消操作
      }
    };
  }

  if (actions.length === 0) {
    toast.warning("暂无操作权限");
    return;
  }

  actionSheetActions.value = actions;
  pendingAction.value = actionMap;
  actionSheetVisible.value = true;
}

function handleActionSelect({ item }: { item: any }) {
  pendingAction.value[item.name]?.();
}

onReachBottom(() => {
  if (queryParams.pageNum * queryParams.pageSize < total.value) {
    fetchDictTypeList();
  } else {
    loadMoreState.value = "finished";
  }
});

onLoad(() => {
  loadDictTypeList();
});
</script>

<script lang="ts">
export default { options: { styleIsolation: "shared" } };
</script>
