import { checkLogin } from "@/utils/auth";

interface NavItem {
  url?: string;
  [key: string]: any;
}

export function useNavigation() {
  const handleNavClick = (item: NavItem) => {
    if (!item.url) {
      uni.showToast({ title: "功能开发中", icon: "none" });
      return;
    }

    if (!checkLogin()) return;

    if (item.url.startsWith("http://") || item.url.startsWith("https://")) {
      // #ifdef H5
      window.open(item.url, "_blank");
      // #endif
      // #ifndef H5
      uni.navigateTo({
        url: `/pages/webview/index?url=${encodeURIComponent(item.url)}`,
      });
      // #endif
      return;
    }

    uni.navigateTo({
      url: item.url,
      fail: () => {
        uni.showToast({ title: "页面不存在", icon: "none" });
      },
    });
  };

  return { handleNavClick };
}
