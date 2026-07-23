<template>
  <view class="page page--padding">
    <view>
      <wd-search
        v-model="queryParams.keywords"
        placeholder="搜索用户名/手机号"
        hide-cancel
        @search="handleSearch"
      />
    </view>

    <!-- 排序筛选：搜索框→筛选 12rpx -->
    <view class="filter-bar" @click="closeOutside">
      <view class="flex-1">
        <wd-drop-menu>
          <wd-drop-menu-item
            v-model="sortValue"
            title="排序"
            :options="sortOptions"
            @change="handleSortChange"
          />
        </wd-drop-menu>
      </view>
      <wd-divider vertical />
      <view class="flex-1">
        <wd-drop-menu>
          <wd-drop-menu-item title="筛选" @open="handleFilterOpen">
            <view class="p-4">
              <wd-input
                v-model="queryParams.keywords"
                label="关键字"
                placeholder="用户名/昵称/手机号"
              />
              <cu-date-query v-model="queryParams.createTime" label="创建时间" />
              <view class="popup-actions">
                <wd-button type="info" variant="plain" @click="resetUserFilter">重置</wd-button>
                <wd-button type="primary" @click="applyUserFilter">查询</wd-button>
              </view>
            </view>
          </wd-drop-menu-item>
        </wd-drop-menu>
      </view>
    </view>

    <!-- 用户列表：筛选→列表 16rpx -->
    <view class="mt-16rpx">
      <wd-card
        v-for="item in pageData"
        :key="item.id"
        custom-class="item-card"
        @click="openUserDialog(item.id)"
      >
        <!-- 主信息行 -->
        <view class="flex-start">
          <image class="user-card__avatar" :src="item.avatar" mode="aspectFill" lazy-load />
          <view class="user-card__main">
            <view class="flex-start mt-12rpx">
              <text class="user-card__name">{{ item.nickname }}</text>
              <wd-icon
                v-if="item.gender === 1"
                name="gender-male"
                color="var(--color-primary)"
                class="ml-8rpx"
              />
              <wd-icon
                v-else-if="item.gender === 2"
                name="gender-female"
                color="var(--color-danger)"
                class="ml-8rpx"
              />
            </view>
            <text class="user-card__role">{{ item.roleNames }} · {{ item.deptName }}</text>
          </view>
          <wd-tag :type="item.status === 1 ? 'success' : 'danger'" variant="plain">
            {{ item.status === 1 ? "正常" : "禁用" }}
          </wd-tag>
        </view>

        <!-- 辅助信息行 -->
        <view class="user-card__meta">
          <view v-if="item.mobile" class="user-card__contact">
            <wd-icon name="mobile" size="16" class="color-text-secondary" />
            <text class="user-card__contact-text">{{ item.mobile }}</text>
          </view>
          <view v-if="item.email" class="user-card__contact">
            <wd-icon name="mail" size="16" class="color-text-secondary" />
            <text class="user-card__contact-text">{{ item.email }}</text>
          </view>
        </view>

        <!-- 元信息行 -->
        <view class="user-card__footer">
          <text class="user-card__time">{{ item.createTime }}</text>
          <view
            class="user-card__action"
            hover-class="user-card__action--hover"
            @click.stop="showUserActions(item)"
          >
            <wd-icon name="more" size="18" class="color-text-secondary" />
          </view>
        </view>
      </wd-card>

      <wd-loadmore v-if="total > 0" :state="loadMoreState" @reload="fetchUserList" />
      <wd-empty v-else-if="total === 0" icon="search" tip="暂无数据" />
    </view>

    <!-- 弹窗表单 -->
    <wd-popup
      v-model="dialog.visible"
      position="bottom"
      custom-class="popup-bottom"
      @close="closeUserDialog"
    >
      <view class="p-4">
        <view class="popup-title">
          {{ formData.id ? "编辑用户" : "新增用户" }}
        </view>
        <wd-form ref="formRef" :model="formData" :schema="rules">
          <wd-form-item prop="username" title="用户名" required>
            <wd-input
              v-model="formData.username"
              placeholder="请输入用户名"
              :readonly="!!formData.id"
            />
          </wd-form-item>
          <wd-form-item prop="nickname" title="昵称" required>
            <wd-input v-model="formData.nickname" placeholder="请输入昵称" />
          </wd-form-item>
          <!-- 部门选择：触发交 wd-form-item，选择器只负责弹出 -->
          <wd-form-item
            title="部门"
            prop="deptId"
            required
            is-link
            :value="deptLabel"
            placeholder="请选择部门"
            @click="showDeptPicker = true"
          />
          <wd-cascader
            v-model="deptSelected"
            v-model:visible="showDeptPicker"
            :options="deptOptions"
            :lazy-load="handleDeptLazyLoad"
            :display-format="displayDeptFormat"
            @confirm="handleDeptConfirm"
          />

          <!-- 角色选择：触发交 wd-form-item，选择器只负责弹出 -->
          <wd-form-item
            title="角色"
            prop="roleIds"
            required
            is-link
            :value="roleLabel"
            placeholder="请选择角色"
            @click="showRolePicker = true"
          />
          <wd-select-picker
            v-model="formData.roleIds"
            v-model:visible="showRolePicker"
            :columns="roleOptions"
            @confirm="handleRoleConfirm"
          />
          <wd-form-item prop="mobile" title="手机号">
            <wd-input v-model="formData.mobile" placeholder="请输入手机号" />
          </wd-form-item>
          <wd-form-item prop="email" title="邮箱">
            <wd-input v-model="formData.email" placeholder="请输入邮箱" />
          </wd-form-item>
          <wd-form-item prop="status" title="状态">
            <wd-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
          </wd-form-item>
        </wd-form>
        <view class="popup-actions">
          <wd-button type="info" variant="plain" @click="closeUserDialog">取消</wd-button>
          <wd-button type="primary" :loading="isSubmitting" @click="submitUserForm">保存</wd-button>
        </view>
      </view>
    </wd-popup>

    <!-- 浮动新增按钮 -->
    <wd-fab :expandable="false" :gap="{ bottom: 100 }" @click="openUserDialog()" />

    <!-- 操作菜单 -->
    <wd-action-sheet
      v-model="actionSheetVisible"
      :actions="actionSheetActions"
      cancel-text="取消"
      @select="handleActionSelect"
    />

    <!-- 重置密码弹窗 -->
    <wd-popup v-model="resetPwdDialog.visible" position="bottom" custom-class="popup-bottom">
      <view class="p-4">
        <view class="popup-title">重置密码</view>
        <wd-form ref="resetPwdFormRef" :model="resetPwdForm">
          <wd-form-item prop="password" title="新密码" required>
            <wd-input v-model="resetPwdForm.password" placeholder="请输入新密码（至少6位）" />
          </wd-form-item>
        </wd-form>
        <view class="popup-actions">
          <wd-button type="info" variant="plain" @click="resetPwdDialog.visible = false">
            取消
          </wd-button>
          <wd-button
            type="primary"
            :loading="resetPwdDialog.isSubmitting"
            @click="handleResetPassword"
          >
            确认
          </wd-button>
        </view>
      </view>
    </wd-popup>
  </view>
</template>

<script lang="ts" setup>
import { onLoad, onReachBottom } from "@dcloudio/uni-app";
import { LoadMoreState } from "@wot-ui/ui/components/wd-loadmore/types";
import { toFormSchema } from "@/utils/form";
import { useQueue, useToast, useDialog } from "@wot-ui/ui";
import UserAPI, { type UserPageQuery, UserItem, UserForm } from "@/api/user";
import RoleAPI from "@/api/role";
import DeptAPI from "@/api/dept";
import { hasPermission } from "@/utils/permission";

definePage({
  name: "user",
  style: { navigationBarTitleText: "用户管理" },
});

const toast = useToast();
const { confirm } = useDialog();
const { closeOutside } = useQueue();
const loadMoreState = ref<LoadMoreState>("loading");
const formRef = ref();
const isSubmitting = ref(false);

const sortValue = ref(0);
const sortOptions = ref([
  { label: "默认排序", value: 0 },
  { label: "最近创建", value: 1 },
  { label: "最近更新", value: 2 },
]);

const queryParams = reactive<UserPageQuery>({ pageNum: 1, pageSize: 10, keywords: "" });
const total = ref(0);
const pageData = ref<UserItem[]>([]);
const dialog = reactive({ visible: false });

const initialFormData: UserForm = {
  id: undefined,
  roleIds: [],
  username: undefined,
  nickname: undefined,
  deptId: undefined,
  mobile: undefined,
  email: undefined,
  status: 1,
};

const formData = reactive<UserForm>({ ...initialFormData });
const roleOptions = ref<Record<string, any>[]>([]);
const deptOptions = ref<OptionType[]>([]);

// 部门选择器状态
const showDeptPicker = ref(false);
const deptSelected = ref<(string | number)[]>([]);
const deptLabel = ref("");

// 角色选择器状态
const showRolePicker = ref(false);
const roleLabel = ref("");

// 格式化部门展示
const displayDeptFormat = (selectedItems: Record<string, any>[]) => {
  return selectedItems.map((item) => item.label).join("/");
};

// 查找部门在树中的完整路径
function findDeptPath(data: any[], targetId: string, path: string[] = []): string[] | null {
  for (const item of data) {
    const currentPath = [...path, item.value];
    if (item.value === targetId) {
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
const handleDeptLazyLoad = ({ selectedItem, resolve, finish }: any) => {
  const children = selectedItem.children;
  if (children && children.length > 0) {
    resolve(children);
  } else {
    finish();
  }
};

// 部门确认选择
const handleDeptConfirm = ({ value, selectedItems }: any) => {
  deptSelected.value = value;
  formData.deptId = value[value.length - 1];
  deptLabel.value = selectedItems.map((item: any) => item.label).join("/");
};

// 角色确认选择
const handleRoleConfirm = ({ selectedItems }: any) => {
  roleLabel.value = selectedItems.map((item: any) => item.label).join("、");
};

const rules = toFormSchema({
  username: [{ required: true, message: "请输入用户名" }],
  nickname: [{ required: true, message: "请输入昵称" }],
  roleIds: [{ required: true, message: "请选择角色" }],
  deptId: [{ required: true, message: "请选择部门" }],
});

// 排序切换
const handleSortChange = ({ value }: { value: string | number }) => {
  const num = Number(value);
  if (num === 1) {
    queryParams.field = "create_time";
    queryParams.direction = "desc";
  } else if (num === 2) {
    queryParams.field = "update_time";
    queryParams.direction = "desc";
  } else {
    queryParams.field = "";
    queryParams.direction = "";
  }
  loadUserList();
};

const handleFilterOpen = () => {};

// 搜索触发
const handleSearch = () => loadUserList();

// 加载列表
function loadUserList() {
  queryParams.pageNum = 1;
  fetchUserList();
}
// 应用筛选并刷新
function applyUserFilter() {
  closeOutside();
  loadUserList();
}
// 重置筛选并刷新
function resetUserFilter() {
  queryParams.keywords = "";
  delete queryParams.createTime;
  queryParams.field = "";
  queryParams.direction = "";
  sortValue.value = 0;
  applyUserFilter();
}

// 分页加载列表
function fetchUserList() {
  loadMoreState.value = "loading";
  UserAPI.getPage(queryParams)
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
async function openUserDialog(id?: number) {
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
  deptSelected.value = [];
  deptLabel.value = "";
  roleLabel.value = "";
  dialog.visible = true;
  roleOptions.value = await RoleAPI.getOptions();
  const deptData = await DeptAPI.getOptions();
  deptOptions.value = deptData;

  if (id) {
    formData.id = id;
    const data = await UserAPI.getFormData(id);
    Object.assign(formData, data, { id });
    // 编辑时回显部门
    if (data.deptId) {
      const path = findDeptPath(deptData, String(data.deptId));
      if (path) {
        deptSelected.value = path;
      } else {
        deptSelected.value = [String(data.deptId)];
      }
    }
    // 回显角色
    if (data.roleIds && data.roleIds.length > 0) {
      const names = roleOptions.value
        .filter((r: any) => data.roleIds.includes(r.value))
        .map((r: any) => r.label);
      roleLabel.value = names.join("、");
    }
  }
}

// 提交表单
function submitUserForm() {
  formRef.value.validate().then(({ valid }: { valid: boolean }) => {
    if (!valid) return;
    isSubmitting.value = true;
    const action = formData.id ? UserAPI.update(formData.id, formData) : UserAPI.add(formData);
    action
      .then(() => {
        toast.success("操作成功");
        closeUserDialog();
        loadUserList();
      })
      .finally(() => {
        isSubmitting.value = false;
      });
  });
}

// 关闭弹窗
function closeUserDialog() {
  dialog.visible = false;
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
}

const actionSheetVisible = ref(false);
const actionSheetActions = ref<{ name: string; color?: string }[]>([]);
const pendingAction = ref<Record<string, () => void>>({});

const resetPwdDialog = reactive({
  visible: false,
  isSubmitting: false,
  userId: undefined as number | undefined,
});
const resetPwdForm = reactive({ password: "" });
const resetPwdFormRef = ref();

// 更多操作
function showUserActions(item: UserItem) {
  const actions: { name: string; color?: string }[] = [];
  const actionMap: Record<string, () => void> = {};

  // 重置密码
  if (hasPermission("sys:user:reset-password")) {
    actions.push({ name: "重置密码" });
    actionMap["重置密码"] = () => openResetPwdDialog(item);
  }

  // 编辑
  if (hasPermission("sys:user:update")) {
    actions.push({ name: "编辑" });
    actionMap["编辑"] = () => openUserDialog(item.id);
  }

  // 删除
  if (hasPermission("sys:user:delete")) {
    actions.push({ name: "删除", color: "var(--color-danger)" });
    actionMap["删除"] = async () => {
      try {
        await confirm({
          title: "确认删除",
          msg: `确定要删除用户「${item.nickname}」吗？`,
          headerImage: "warning",
        });
        await UserAPI.deleteByIds(String(item.id));
        toast.success("删除成功");
        loadUserList();
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

// 打开重置密码弹窗
function openResetPwdDialog(item: UserItem) {
  resetPwdForm.password = "";
  resetPwdDialog.userId = item.id;
  resetPwdDialog.visible = true;
  nextTick(() => {
    resetPwdFormRef.value?.reset();
  });
}

// 重置密码
async function handleResetPassword() {
  const valid = await resetPwdFormRef.value?.validate();
  if (!valid || valid.valid === false) return;
  if (!resetPwdDialog.userId) return;

  resetPwdDialog.isSubmitting = true;
  try {
    await UserAPI.resetPassword(resetPwdDialog.userId, resetPwdForm.password);
    toast.success("密码重置成功");
    resetPwdDialog.visible = false;
  } catch (error) {
    // API 已处理错误提示
  } finally {
    resetPwdDialog.isSubmitting = false;
  }
}

onReachBottom(() => {
  if (queryParams.pageNum * queryParams.pageSize < total.value) {
    fetchUserList();
  } else {
    loadMoreState.value = "finished";
  }
});

onLoad(() => {
  loadUserList();
});
</script>

<script lang="ts">
export default { options: { styleIsolation: "shared" } };
</script>

<style lang="scss" scoped>
.user-card__avatar {
  flex-shrink: 0;
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
}

.user-card__main {
  flex: 1;
  margin-left: 16rpx;
}

.user-card__name {
  font-size: 32rpx;
  font-weight: 700;
}

.user-card__role {
  font-size: 24rpx;
  color: var(--color-text-secondary);
}

.user-card__meta {
  display: flex;
  gap: 24rpx;
  margin-top: 12rpx;
}

.user-card__contact {
  display: flex;
  align-items: flex-start;
  min-width: 0;
}

.user-card__contact-text {
  margin-left: 8rpx;
  overflow: hidden;
  font-size: 24rpx;
  color: var(--color-text-secondary);
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user-card__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16rpx;
}

.user-card__time {
  font-size: 24rpx;
  color: var(--color-text-placeholder);
}

.user-card__action {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 88rpx;
  height: 88rpx;
  border-radius: 50%;
}

.user-card__action--hover {
  background: rgba(var(--color-text-placeholder-rgb, 148, 163, 184), 0.16);
}
</style>
