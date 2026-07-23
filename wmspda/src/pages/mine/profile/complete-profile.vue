<template>
  <view class="page">
    <!-- 头部 -->
    <view class="complete-profile__hero">
      <view class="complete-profile__hero-title">完善个人信息</view>
      <view class="complete-profile__hero-subtitle">为了给您提供更好的服务，请完善以下信息</view>
    </view>

    <!-- 表单 -->
    <view class="profile-form">
      <wd-form ref="profileFormRef" :model="profileForm">
        <!-- 头像 -->
        <view class="profile-form__section">
          <view class="profile-form__label">头像</view>
          <view class="avatar-picker">
            <!-- #ifdef MP-WEIXIN -->
            <button
              class="avatar-picker__trigger"
              open-type="chooseAvatar"
              @chooseavatar="onChooseAvatar"
            >
              <image
                v-if="profileForm.avatar"
                :src="profileForm.avatar"
                class="avatar-picker__img"
                mode="aspectFill"
              />
              <view v-else class="avatar-picker__placeholder">
                <wd-icon name="camera" size="40" color="var(--color-text-placeholder)" />
                <text class="avatar-picker__hint">选择头像</text>
              </view>
            </button>
            <!-- #endif -->

            <!-- #ifndef MP-WEIXIN -->
            <view class="avatar-picker__trigger" @click="chooseAvatar">
              <image
                v-if="profileForm.avatar"
                :src="profileForm.avatar"
                class="avatar-picker__img"
                mode="aspectFill"
              />
              <view v-else class="avatar-picker__placeholder">
                <wd-icon name="camera" size="40" color="var(--color-text-placeholder)" />
                <text class="avatar-picker__hint">选择头像</text>
              </view>
            </view>
            <!-- #endif -->
          </view>
        </view>

        <!-- 昵称 -->
        <view class="profile-form__section">
          <view class="profile-form__label">
            昵称
            <text class="profile-form__required">*</text>
          </view>
          <!-- #ifdef MP-WEIXIN -->
          <input
            v-model="profileForm.nickname"
            type="nickname"
            class="profile-form__nickname-input"
            placeholder="请输入昵称"
            :maxlength="20"
          />
          <!-- #endif -->
          <!-- #ifndef MP-WEIXIN -->
          <wd-input
            v-model="profileForm.nickname"
            placeholder="请输入昵称"
            prop="nickname"
            :rules="rules.nickname"
            custom-class="profile-form__nickname-input"
          />
          <!-- #endif -->
        </view>

        <!-- 性别 -->
        <view class="profile-form__section">
          <view class="profile-form__label">性别</view>
          <wd-radio-group v-model="profileForm.gender" type="button" class="gender-group">
            <wd-radio :value="1" class="gender-radio">男</wd-radio>
            <wd-radio :value="2" class="gender-radio">女</wd-radio>
          </wd-radio-group>
        </view>

        <!-- 手机号 -->
        <view class="profile-form__section">
          <view class="profile-form__label">
            手机号
            <text class="profile-form__required">*</text>
          </view>
          <wd-input
            v-model="profileForm.mobile"
            placeholder="请输入手机号"
            prop="mobile"
            custom-class="profile-form__nickname-input"
          />
        </view>
      </wd-form>
    </view>

    <!-- 底部 -->
    <view class="profile-footer">
      <wd-button
        class="profile-footer__submit"
        type="primary"
        size="large"
        block
        :disabled="!canComplete || isLoading"
        :loading="isLoading"
        @click="handleComplete"
      >
        完成
      </wd-button>
      <view class="profile-footer__skip" @click="handleSkip">
        <text>暂时跳过</text>
      </view>
    </view>

    <!-- 头像裁剪 -->
    <wd-img-cropper
      v-model="cropperVisible"
      :img-src="originalImageSrc"
      @confirm="handleAvatarConfirm"
    />

    <wd-toast />
  </view>
</template>

<script lang="ts" setup>
import { ref, reactive, computed } from "vue";
import { onLoad } from "@dcloudio/uni-app";
import { useDialog, useToast } from "@wot-ui/ui";
import { useUserStore } from "@/store";
import UserAPI, { type UserProfileForm } from "@/api/user";
import FileAPI, { type FileInfo } from "@/api/file";

const toast = useToast();
const { confirm } = useDialog();
const userStore = useUserStore();

const redirect = ref("/pages/index/index");

const profileForm = reactive<UserProfileForm & { mobile?: string }>({
  nickname: "",
  avatar: "",
  gender: 1,
  mobile: "",
});

const rules = {
  nickname: [
    { required: true, message: "请输入昵称" },
    { required: true, min: 2, max: 20, message: "昵称长度为2-20个字符" },
  ],
};

const isLoading = ref(false);
const cropperVisible = ref(false);
const originalImageSrc = ref("");
const profileFormRef = ref();

const canComplete = computed(() => {
  return profileForm.nickname && profileForm.mobile;
});

onLoad((options: any) => {
  if (options?.redirect) {
    redirect.value = decodeURIComponent(options.redirect);
  }
  const userInfo = userStore.userInfo;
  if (userInfo) {
    profileForm.nickname = userInfo.nickname || "";
    profileForm.avatar = userInfo.avatar || "";
    profileForm.gender = (userInfo as any).gender || 1;
  }
});

const onChooseAvatar = async (e: any) => {
  try {
    const { avatarUrl } = e.detail;
    toast.loading("上传中...");
    const fileInfo: FileInfo = await FileAPI.upload(avatarUrl);
    profileForm.avatar = fileInfo.url;
    toast.success("头像上传成功");
  } catch {
    toast.error("头像上传失败");
  }
};

const chooseAvatar = () => {
  // #ifdef MP-WEIXIN
  uni.chooseMedia({
    count: 1,
    mediaType: ["image"],
    sourceType: ["album", "camera"],
    success: (res) => {
      originalImageSrc.value = res.tempFiles[0].tempFilePath;
      cropperVisible.value = true;
    },
    fail: () => {
      toast.error("选择图片失败");
    },
  });
  // #endif

  // #ifndef MP-WEIXIN
  uni.chooseImage({
    count: 1,
    sourceType: ["album", "camera"],
    success: (res) => {
      originalImageSrc.value = res.tempFilePaths[0];
      cropperVisible.value = true;
    },
    fail: () => {
      toast.error("选择图片失败");
    },
  });
  // #endif
};

const handleAvatarConfirm = async (event: any) => {
  try {
    const { tempFilePath } = event;
    toast.loading("上传中...");
    const fileInfo: FileInfo = await FileAPI.upload(tempFilePath);
    profileForm.avatar = fileInfo.url;
    toast.success("头像上传成功");
  } catch {
    toast.error("头像上传失败");
  }
};

const handleComplete = async () => {
  try {
    const { valid } = await profileFormRef.value.validate();
    if (!valid) return;

    if (!profileForm.mobile) {
      toast.error("请输入手机号");
      return;
    }

    isLoading.value = true;

    await UserAPI.updateProfile({
      nickname: profileForm.nickname,
      avatar: profileForm.avatar,
      gender: profileForm.gender,
    });

    if (profileForm.mobile) {
      await UserAPI.bindMobile({ mobile: profileForm.mobile });
    }

    await userStore.getInfo();
    toast.success("信息完善成功");

    setTimeout(() => {
      uni.reLaunch({ url: redirect.value });
    }, 1000);
  } catch (error: any) {
    toast.error(error?.message || "完善信息失败");
  } finally {
    isLoading.value = false;
  }
};

const handleSkip = async () => {
  try {
    await confirm({
      title: "提示",
      msg: "跳过信息完善可能会影响部分功能使用，确定要跳过吗？",
      headerImage: "warning",
    });
    uni.reLaunch({ url: redirect.value });
  } catch {
    // 用户取消
  }
};
</script>

<style lang="scss" scoped>
.complete-profile__hero {
  margin-bottom: 60rpx;
  text-align: center;
}

.complete-profile__hero-title {
  margin-bottom: 20rpx;
  font-size: 48rpx;
  font-weight: bold;
  color: var(--color-text-inverse);
}

.complete-profile__hero-subtitle {
  font-size: 28rpx;
  line-height: 1.5;
  color: rgba(255, 255, 255, 0.8);
}

.profile-form {
  padding: 40rpx;
  margin-bottom: 40rpx;
  background: var(--color-bg);
  border-radius: 24rpx;
  box-shadow: 0 8rpx 40rpx rgba(0, 0, 0, 0.1);

  &__section {
    margin-bottom: 40rpx;

    &:last-child {
      margin-bottom: 0;
    }
  }

  &__label {
    margin-bottom: 20rpx;
    font-size: 32rpx;
    font-weight: 600;
    color: var(--color-text);
  }

  &__required {
    color: var(--color-danger);
  }

  &__nickname-input {
    :deep(.wd-input__inner) {
      padding: 24rpx 20rpx;
      background: var(--color-bg-tertiary);
      border: 1rpx solid var(--color-border-light);
      border-radius: 12rpx;
    }
  }
}

.avatar-picker {
  display: flex;
  justify-content: center;

  &__trigger {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 160rpx;
    height: 160rpx;
    padding: 0;
    margin: 0 auto;
    overflow: hidden;
    background: transparent;
    border: none;
    border-radius: 50%;

    &::after {
      border: none;
    }
  }

  &__img {
    width: 100%;
    height: 100%;
    border: 4rpx solid var(--color-border-light);
    border-radius: 50%;
  }

  &__placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 160rpx;
    height: 160rpx;
    background: var(--color-bg-tertiary);
    border: 2rpx dashed var(--color-border);
    border-radius: 50%;
  }

  &__hint {
    margin-top: 10rpx;
    font-size: 24rpx;
    color: var(--color-text-placeholder);
  }
}

.gender-group {
  display: flex;
  gap: 20rpx;

  .gender-radio {
    flex: 1;

    :deep(.wd-radio) {
      justify-content: center;
      width: 100%;
    }
  }
}

.profile-footer {
  &__submit {
    margin-bottom: 30rpx;

    :deep(.wd-button) {
      height: 88rpx;
      font-size: 32rpx;
      font-weight: 600;
      border-radius: 44rpx;
    }
  }

  &__skip {
    text-align: center;

    text {
      font-size: 28rpx;
      color: rgba(255, 255, 255, 0.8);
      text-decoration: underline;
    }
  }
}
</style>
