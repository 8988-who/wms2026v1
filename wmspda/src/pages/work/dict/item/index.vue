<template>
  <view class="page page--padding">
    <view>
      <wd-search
        v-model="queryParams.keywords"
        placeholder="搜索字典标签/字典值"
        hide-cancel
        @search="handleSearch"
      />
    </view>

    <view class="mt-16rpx">
      <wd-card
        v-for="item in pageData"
        :key="item.id"
        custom-class="item-card"
        @click="openItemDialog(item.id)"
      >
        <view class="flex-start">
          <view class="flex-1">
            <view class="flex-start">
              <text class="font-bold text-32rpx">{{ item.label }}</text>
            </view>
            <text class="text-24rpx color-text-secondary">
              字典值：{{ item.value }} · 排序：{{ item.sort }}
            </text>
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
            @click.stop="showItemActions(item)"
          >
            <wd-icon name="more" size="18" class="color-text-secondary" />
          </view>
        </view>
      </wd-card>

      <wd-loadmore v-if="total > 0" :state="loadMoreState" @reload="fetchItemList" />
      <wd-empty v-else-if="total === 0" icon="search" tip="暂无数据" />
    </view>

    <wd-popup
      v-model="dialog.visible"
      position="bottom"
      custom-class="popup-bottom"
      @close="closeItemDialog"
    >
      <view class="p-4">
        <view class="popup-title">
          {{ formData.id ? "编辑字典数据" : "新增字典数据" }}
        </view>
        <wd-form ref="formRef" :model="formData" :schema="rules">
          <wd-form-item prop="label" title="字典项标签" required>
            <wd-input v-model="formData.label" placeholder="请输入字典项标签" />
          </wd-form-item>
          <wd-form-item prop="value" title="字典项值" required>
            <wd-input v-model="formData.value" placeholder="请输入字典项值" />
          </wd-form-item>
          <wd-form-item prop="status" title="状态">
            <wd-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
          </wd-form-item>
          <wd-form-item prop="sort" title="排序">
            <wd-input-number v-model="formData.sort" :min="0" />
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
          <wd-button type="info" variant="plain" @click="closeItemDialog">取消</wd-button>
          <wd-button type="primary" :loading="isSubmitting" @click="submitItemForm">保存</wd-button>
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
      v-if="hasPermission('sys:dict-item:create') && !dialog.visible"
      :expandable="false"
      :gap="{ bottom: 32 }"
      @click="openItemDialog()"
    />
  </view>
</template>

<script lang="ts" setup>
import { onLoad, onReachBottom } from "@dcloudio/uni-app";
import { LoadMoreState } from "@wot-ui/ui/components/wd-loadmore/types";
import { toFormSchema } from "@/utils/form";
import { useToast, useDialog } from "@wot-ui/ui";
import DictAPI, { type DictItemForm, type DictItemPageQuery, type DictDataItem } from "@/api/dict";
import { hasPermission } from "@/utils/permission";

definePage({
  name: "dict-item",
  style: { navigationBarTitleText: "字典数据" },
});

const toast = useToast();
const { confirm } = useDialog();

const dictCode = ref<string>("");
const pageTitle = ref<string>("字典数据");

const loadMoreState = ref<LoadMoreState>("loading");
const formRef = ref();
const isSubmitting = ref(false);

const queryParams = reactive<DictItemPageQuery>({ pageNum: 1, pageSize: 10, keywords: "" });
const total = ref(0);
const pageData = ref<DictDataItem[]>([]);
const dialog = reactive({ visible: false });

const initialFormData: DictItemForm = {
  id: undefined,
  dictCode: undefined,
  label: undefined,
  value: undefined,
  sort: 1,
  status: 1,
  remark: undefined,
};

const formData = reactive<DictItemForm>({ ...initialFormData });

const rules = toFormSchema({
  label: [{ required: true, message: "请输入字典项标签" }],
  value: [{ required: true, message: "请输入字典项值" }],
});

const handleSearch = () => loadItemList();

function loadItemList() {
  queryParams.pageNum = 1;
  fetchItemList();
}

function fetchItemList() {
  if (!dictCode.value) {
    pageData.value = [];
    total.value = 0;
    loadMoreState.value = "finished";
    return;
  }

  loadMoreState.value = "loading";
  DictAPI.getItemPage(dictCode.value, queryParams)
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

async function openItemDialog(id?: string) {
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
  dialog.visible = true;
  formData.dictCode = dictCode.value;

  if (id) {
    formData.id = id;
    const data = await DictAPI.getItemFormData(dictCode.value, id);
    Object.assign(formData, data, { id });
  }
}

function submitItemForm() {
  formRef.value.validate().then(({ valid }: { valid: boolean }) => {
    if (!valid) return;
    if (!dictCode.value) {
      toast.error("缺少字典编码");
      return;
    }

    isSubmitting.value = true;
    const id = formData.id;
    const action = id
      ? DictAPI.updateItem(dictCode.value, id, formData)
      : DictAPI.createItem(dictCode.value, formData);

    action
      .then(() => {
        toast.success("操作成功");
        closeItemDialog();
        loadItemList();
      })
      .finally(() => {
        isSubmitting.value = false;
      });
  });
}

function closeItemDialog() {
  dialog.visible = false;
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
}

const actionSheetVisible = ref(false);
const actionSheetActions = ref<{ name: string; color?: string }[]>([]);
const pendingAction = ref<Record<string, () => void>>({});

function showItemActions(item: DictDataItem) {
  const actions: { name: string; color?: string }[] = [];
  const actionMap: Record<string, () => void> = {};

  if (hasPermission("sys:dict-item:update")) {
    actions.push({ name: "编辑" });
    actionMap["编辑"] = () => openItemDialog(item.id);
  }

  if (hasPermission("sys:dict-item:delete")) {
    actions.push({ name: "删除", color: "var(--color-danger)" });
    actionMap["删除"] = async () => {
      try {
        await confirm({
          title: "确认删除",
          msg: `确定要删除字典数据「${item.label}」吗？`,
          headerImage: "warning",
        });
        if (item.id) {
          await DictAPI.deleteItems(dictCode.value, String(item.id));
          toast.success("删除成功");
          loadItemList();
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
    fetchItemList();
  } else {
    loadMoreState.value = "finished";
  }
});

onLoad((query: any) => {
  dictCode.value = String((query as any)?.dictCode || "");
  pageTitle.value = String((query as any)?.title || "字典数据");
  if (pageTitle.value) {
    uni.setNavigationBarTitle({ title: pageTitle.value });
  }
  loadItemList();
});
</script>

<script lang="ts">
export default { options: { styleIsolation: "shared" } };
</script>
