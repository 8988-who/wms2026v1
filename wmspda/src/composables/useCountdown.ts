import { ref, onUnmounted } from "vue";

export function useCountdown(duration = 60) {
  const countdown = ref(0);
  const isRunning = ref(false);
  let timer: ReturnType<typeof setInterval> | null = null;

  const start = () => {
    if (isRunning.value) return;

    countdown.value = duration;
    isRunning.value = true;

    timer = setInterval(() => {
      countdown.value--;
      if (countdown.value <= 0) {
        stop();
      }
    }, 1000);
  };

  const stop = () => {
    if (timer) {
      clearInterval(timer);
      timer = null;
    }
    countdown.value = 0;
    isRunning.value = false;
  };

  onUnmounted(() => stop());

  return {
    countdown,
    isRunning,
    start,
    stop,
  };
}
