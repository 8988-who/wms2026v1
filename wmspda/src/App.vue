<script setup lang="ts">
import { onLaunch, onShow } from "@dcloudio/uni-app";
import { useThemeStore } from "@/store";

onLaunch(() => {
  const themeStore = useThemeStore();
  themeStore.initTheme();
});

onShow(() => {});
</script>

<style lang="scss">
@use "@wot-ui/ui/styles/theme/index.scss" as *;
</style>
