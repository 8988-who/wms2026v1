<template>
  <view class="page">
    <view class="profile-content">
      <view class="profile-content__card-area">
        <wd-card v-if="userProfile">
          <wd-cell-group border>
            <wd-cell class="avatar-cell" title="头像" center is-link>
              <view class="avatar-cell__avatar">
                <view
                  v-if="!userProfile.avatar"
                  class="avatar-cell__img"
                  @click="handleAvatarUpload"
                >
                  <wd-icon name="fill-camera" custom-class="avatar-cell__img-icon" />
                </view>
                <image
                  v-if="userProfile.avatar"
                  class="avatar-cell__img"
                  :src="userProfile.avatar"
                  mode="aspectFit"
                  @click="handleAvatarUpload"
                />
              </view>
            </wd-cell>
            <wd-cell title="昵称" :value="userProfile.nickname" is-link @click="openDialog()" />
            <wd-cell
              title="性别"
              :value="userProfile.gender === 1 ? '男' : userProfile.gender === 2 ? '女' : '未知'"
              is-link
              @click="openDialog()"
            />
            <wd-cell title="用户名" :value="userProfile.username" />
            <wd-cell title="部门" :value="userProfile.deptName" />
            <wd-cell title="角色" :value="userProfile.roleNames" />
            <view class="profile-last-cell-wrap">
              <wd-cell title="创建日期" :value="userProfile.createTime" />
            </view>
          </wd-cell-group>
        </wd-card>
      </view>
    </view>

    <!--头像裁剪-->
    <wd-img-cropper
      v-if="avatarShow"
      v-model="avatarShow"
      :img-src="originalSrc"
      @confirm="handleAvatarConfirm"
    />

    <!--用户信息编辑弹出框-->
    <wd-popup v-if="dialogState.visible" v-model="dialogState.visible" position="bottom">
      <wd-form ref="userProfileFormRef" :model="userProfileForm" custom-class="edit-form">
        <wd-cell-group border>
          <wd-input
            v-model="userProfileForm.nickname"
            label="昵称"
            label-width="160rpx"
            placeholder="请输入昵称"
            prop="nickname"
            :rules="rules.nickname"
          />
          <wd-cell title="性别" title-width="160rpx" center prop="gender" :rules="rules.gender">
            <wd-radio-group v-model="userProfileForm.gender" type="button" class="ef-radio-group">
              <wd-radio :value="1">男</wd-radio>
              <wd-radio :value="2">女</wd-radio>
            </wd-radio-group>
          </wd-cell>
        </wd-cell-group>
        <view class="edit-form__submit">
          <wd-button type="primary" size="large" block @click="handleSubmit">提交</wd-button>
        </view>
      </wd-form>
    </wd-popup>
  </view>
</template>
<script setup lang="ts">
import UserAPI, { type UserProfile, UserProfileForm } from "@/api/user";
import FileAPI, { type FileInfo } from "@/api/file";
import { checkLogin } from "@/utils/auth";

const originalSrc = ref<string>(""); //选取的原图路径
const avatarShow = ref<boolean>(false); //显示头像裁剪
const userProfile = ref<UserProfile>(); //用户信息

/** 加载用户信息 */
const loadUserProfile = async () => {
  userProfile.value = await UserAPI.getProfile();
};

// 头像选择
function handleAvatarUpload() {
  uni.chooseImage({
    count: 1,
    success: (res) => {
      originalSrc.value = res.tempFilePaths[0];
      avatarShow.value = true;
    },
  });
}
// 头像裁剪完成
function handleAvatarConfirm(event: any) {
  const { tempFilePath } = event;
  FileAPI.upload(tempFilePath).then((fileInfo: FileInfo) => {
    const avatarForm: UserProfileForm = {
      avatar: fileInfo.url,
    };
    // 头像路径保存至后端
    UserAPI.updateProfile(avatarForm).then(() => {
      uni.showToast({ title: "头像上传成功", icon: "none" });
      loadUserProfile();
    });
  });
}

// 本页面中所有的校验规则
const rules = reactive({
  nickname: [{ required: true, message: "请填写昵称" }],
  gender: [{ required: true, message: "请选择性别" }],
});

const dialogState = reactive({
  visible: false,
});

const userProfileForm = reactive<UserProfileForm>({});
const userProfileFormRef = ref();

/**
 * 打开弹窗
 * @param type 弹窗类型 ACCOUNT: 账号资料 PASSWORD: 修改密码 MOBILE: 绑定手机 EMAIL: 绑定邮箱
 */
const openDialog = () => {
  dialogState.visible = true;
  // 初始化表单数据
  userProfileForm.nickname = userProfile.value?.nickname;
  userProfileForm.gender = userProfile.value?.gender;
};

// 提交表单
function handleSubmit() {
  userProfileFormRef.value.validate().then(({ valid }: { valid: boolean }) => {
    if (valid) {
      UserAPI.updateProfile(userProfileForm).then(() => {
        uni.showToast({ title: "账号资料修改成功", icon: "none" });
        dialogState.visible = false;
        loadUserProfile();
      });
    }
  });
}

// 检查登录状态
onLoad(() => {
  if (!checkLogin()) return;

  // #ifdef H5
  document.addEventListener("touchstart", handleTouchStart, { passive: false });
  document.addEventListener("touchmove", handleTouchMove, { passive: false });
  // #endif
  loadUserProfile();
});

// 页面销毁前移除事件监听
onBeforeUnmount(() => {
  // #ifdef H5
  document.removeEventListener("touchstart", handleTouchStart);
  document.removeEventListener("touchmove", handleTouchMove);
  // #endif
});
// 禁用浏览器双指缩放，使头像裁剪时双指缩放能够起作用
function handleTouchStart(event: TouchEvent) {
  if (event.touches.length > 1) {
    event.preventDefault();
  }
}
// 禁用浏览器下拉刷新，使头像裁剪时能够移动图片
function handleTouchMove(event: TouchEvent) {
  event.preventDefault();
}
</script>
<style lang="scss" scoped>
.avatar-cell {
  :deep(.wd-cell__body) {
    align-items: center;
  }
}

.avatar-cell__avatar {
  display: flex;
  align-items: center;
  justify-content: right;
}

.avatar-cell__img {
  position: relative;
  width: 160rpx;
  height: 160rpx;
  background-color: rgba(0, 0, 0, 0.04);
  border-radius: 50%;
}

.profile-content__card-area {
  padding-top: 20rpx;
}

.avatar-cell__img-icon {
  position: absolute;
  top: 50%;
  left: 50%;
  color: var(--color-text-inverse);
}

.edit-form {
  padding-top: 40rpx;

  &__submit {
    padding: 24rpx;
  }

  .ef-radio-group {
    line-height: 1;
    text-align: left;
  }
}
</style>
