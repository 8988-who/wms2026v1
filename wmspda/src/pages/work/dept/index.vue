<template>
  <view class="page page--padding">
    <view>
      <wd-search
        v-model="queryParams.keywords"
        placeholder="搜索部门名称"
        hide-cancel
        @search="handleSearch"
      />
    </view>

    <!-- 部门树形列表 -->
    <view class="mt-16rpx">
      <CustomTree
        :data="treeData"
        :default-expand-all="true"
        :show-action="true"
        @action="handleNodeAction"
      >
        <!-- 自定义节点内容：ID + 名称 + 状态 -->
        <template #content="{ node }">
          <view class="dept-node">
            <text class="dept-node__id">{{ node.id }}</text>
            <text class="dept-node__name">{{ node.name }}</text>
            <wd-tag :type="node.status === 1 ? 'success' : 'danger'" size="small">
              {{ node.status === 1 ? "正常" : "禁用" }}
            </wd-tag>
          </view>
        </template>
      </CustomTree>

      <wd-empty v-if="deptList.length === 0" icon="search" tip="暂无数据" />
    </view>

    <!-- 弹窗表单 -->
    <wd-popup
      v-model="dialog.visible"
      position="bottom"
      custom-class="popup-bottom"
      @close="closeDeptDialog"
    >
      <view class="p-4">
        <view class="popup-title">
          {{ formData.id ? "编辑部门" : "新增部门" }}
        </view>
        <wd-form ref="formRef" :model="formData" :schema="rules">
          <!-- 上级部门选择：触发交 wd-form-item，选择器只负责弹出 -->
          <wd-form-item
            title="上级部门"
            prop="parentId"
            required
            is-link
            :value="parentLabel"
            placeholder="请选择上级部门"
            @click="showParentPicker = true"
          />
          <wd-cascader
            v-model="parentSelected"
            v-model:visible="showParentPicker"
            :options="parentOptions"
            :lazy-load="handleParentLazyLoad"
            :display-format="displayParentFormat"
            @confirm="handleParentConfirm"
          />
          <wd-form-item prop="name" title="部门名称" required>
            <wd-input v-model="formData.name" placeholder="请输入部门名称" />
          </wd-form-item>
          <wd-form-item prop="code" title="部门编号" required>
            <wd-input v-model="formData.code" placeholder="请输入部门编号" />
          </wd-form-item>
          <wd-form-item prop="sort" title="排序">
            <wd-input-number v-model="formData.sort!" :min="0" />
          </wd-form-item>
          <wd-form-item prop="status" title="状态">
            <wd-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
          </wd-form-item>
        </wd-form>
        <view class="popup-actions">
          <wd-button type="info" variant="plain" @click="closeDeptDialog">取消</wd-button>
          <wd-button type="primary" :loading="isSubmitting" @click="submitDeptForm">保存</wd-button>
        </view>
      </view>
    </wd-popup>

    <!-- 浮动新增按钮 -->
    <wd-fab
      v-if="hasPermission('sys:dept:create') && !dialog.visible"
      :expandable="false"
      :gap="{ bottom: 32 }"
      @click="openDeptDialog()"
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
import { onLoad } from "@dcloudio/uni-app";
import { toFormSchema } from "@/utils/form";
import { useToast, useDialog } from "@wot-ui/ui";
import DeptAPI, { type DeptQuery, DeptItem, DeptForm } from "@/api/dept";
import { hasPermission } from "@/utils/permission";
import CustomTree from "@/components/custom-tree/index.vue";

definePage({
  name: "dept",
  style: { navigationBarTitleText: "部门管理" },
});

const toast = useToast();
const { confirm } = useDialog();
const formRef = ref();
const isSubmitting = ref(false);

const queryParams = reactive<DeptQuery>({ keywords: "" });
const deptList = ref<DeptItem[]>([]);
const dialog = reactive({ visible: false });

const actionSheetVisible = ref(false);
const actionSheetActions = ref<{ name: string; color?: string }[]>([]);
const currentActionItem = ref<any>(null);

const initialFormData: DeptForm = {
  id: undefined,
  parentId: 0,
  name: undefined,
  code: undefined,
  sort: 1,
  status: 1,
};

const formData = reactive<DeptForm>({ ...initialFormData });

// 转换为树组件数据格式
const treeData = computed(() => deptList.value.map((dept) => transformDeptToTree(dept)));

function transformDeptToTree(dept: DeptItem): any {
  return {
    value: String(dept.id),
    label: dept.name,
    id: dept.id,
    name: dept.name,
    status: dept.status,
    children: dept.children?.map((child) => transformDeptToTree(child)) || [],
  };
}

// 上级部门选择器
const showParentPicker = ref(false);
const parentSelected = ref<(string | number)[]>([]);
const parentOptions = ref<OptionType[]>([]);
const parentLabel = ref("");

// 格式化上级部门展示
const displayParentFormat = (selectedItems: OptionType[]) => {
  if (!selectedItems || selectedItems.length === 0) return "";
  return selectedItems
    .map((item) => item?.label)
    .filter((label) => !!label)
    .join("/");
};

// 查找部门在树中的完整路径
function findDeptPath(data: OptionType[], targetId: string, path: string[] = []): string[] | null {
  for (const item of data) {
    const currentPath = [...path, String(item.value)];
    if (String(item.value) === targetId) {
      return currentPath;
    }
    if (item.children && item.children.length > 0) {
      const found = findDeptPath(item.children, targetId, currentPath);
      if (found) return found;
    }
  }
  return null;
}

// v2 Cascader 懒加载
const handleParentLazyLoad = ({ selectedItem, resolve, finish }: any) => {
  if (String(selectedItem?.value) === "0") {
    finish();
    return;
  }
  const children = selectedItem.children;
  if (children && children.length > 0) {
    resolve(children);
  } else {
    finish();
  }
};

// 上级部门确认选择
const handleParentConfirm = ({ value, selectedItems }: any) => {
  parentSelected.value = value;
  formData.parentId = Number(value[value.length - 1]) || 0;
  parentLabel.value = selectedItems.map((item: any) => item.label).join("/");
};

const rules = toFormSchema({
  name: [{ required: true, message: "请输入部门名称" }],
  code: [{ required: true, message: "请输入部门编号" }],
  parentId: [{ required: true, message: "请选择上级部门" }],
});

// 搜索触发
const handleSearch = () => loadDeptList();

// 加载列表
function loadDeptList() {
  DeptAPI.getList(queryParams)
    .then((data) => {
      deptList.value = data;
    })
    .catch(() => {
      // API 层已处理错误提示
    });
}

// 操作菜单分发
function handleActionSelect({ item }: { item: any }) {
  const value = item.name;
  const dept = currentActionItem.value;
  if (value === "新增子部门") {
    handleAddChild(dept);
  } else if (value === "编辑") {
    openDeptDialog(dept);
  } else if (value === "删除") {
    confirm({
      title: "确认删除",
      msg: `确定要删除部门「${dept.name}」吗？`,
      headerImage: "warning",
    }).then(async () => {
      await DeptAPI.deleteByIds(String(dept.id));
      toast.success("删除成功");
      loadDeptList();
    });
  }
}

// 处理节点操作按钮点击
function handleNodeAction(node: any) {
  const dept: DeptItem = {
    id: node.id,
    name: node.label,
    status: node.status,
    children: node.children,
  } as DeptItem;

  const actions: { name: string; color?: string }[] = [];

  if (hasPermission("sys:dept:create")) {
    actions.push({ name: "新增子部门" });
  }

  if (hasPermission("sys:dept:update")) {
    actions.push({ name: "编辑" });
  }

  if (hasPermission("sys:dept:delete")) {
    actions.push({ name: "删除", color: "var(--color-danger)" });
  }

  if (actions.length === 0) {
    toast.warning("暂无操作权限");
    return;
  }

  currentActionItem.value = dept;
  actionSheetActions.value = actions;
  actionSheetVisible.value = true;
}

// 打开弹窗（新增/编辑）
async function openDeptDialog(dept?: DeptItem) {
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
  parentSelected.value = [];
  parentLabel.value = "";
  dialog.visible = true;

  const data = await DeptAPI.getOptions();
  parentOptions.value = [{ value: "0", label: "顶级部门" }, ...data];

  if (dept) {
    formData.id = dept.id;
    const form = await DeptAPI.getFormData(dept.id!);
    Object.assign(formData, form, { id: dept.id });

    if (form.parentId && form.parentId !== 0) {
      const path = findDeptPath(data, String(form.parentId));
      if (path) {
        parentSelected.value = path;
      } else {
        parentSelected.value = [String(form.parentId)];
      }
    }
  }
}

// 新增子部门
function handleAddChild(dept: DeptItem) {
  openDeptDialog({ id: undefined, parentId: dept.id } as DeptItem);
  formData.parentId = dept.id!;
  parentSelected.value = [String(dept.id)];
}

// 提交表单
function submitDeptForm() {
  formRef.value.validate().then(({ valid }: { valid: boolean }) => {
    if (!valid) return;
    isSubmitting.value = true;
    const action = formData.id ? DeptAPI.update(formData.id, formData) : DeptAPI.add(formData);
    action
      .then(() => {
        toast.success("操作成功");
        closeDeptDialog();
        loadDeptList();
      })
      .finally(() => {
        isSubmitting.value = false;
      });
  });
}

// 关闭弹窗
function closeDeptDialog() {
  dialog.visible = false;
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
}

onLoad(() => {
  loadDeptList();
});
</script>

<script lang="ts">
export default { options: { styleIsolation: "shared" } };
</script>

<style lang="scss" scoped>
.dept-node {
  display: flex;
  flex: 1;
  gap: 16rpx;
  align-items: center;
}

.dept-node__id {
  width: 120rpx;
  font-size: 24rpx;
  color: var(--color-text-secondary);
}

.dept-node__name {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
