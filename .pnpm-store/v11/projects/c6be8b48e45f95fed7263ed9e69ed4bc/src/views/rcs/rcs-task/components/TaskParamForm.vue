<template>
  <div class="task-param-form">
    <el-collapse v-model="activeNames">
      <el-collapse-item name="advanced" title="高级选项（可缺省）">
        <el-tabs v-model="mode" class="param-tabs">
          <!-- 表单模式 -->
          <el-tab-pane label="表单模式" name="form">
            <el-form label-width="100px" class="param-inner-form">
              <el-form-item v-for="field in ADVANCED_FIELDS" :key="field.key" :label="field.label">
                <!-- 数字 -->
                <el-input-number
                  v-if="field.type === 'number'"
                  v-model="advancedModel[field.key] as number"
                  :min="field.min"
                  :max="field.max"
                  :placeholder="field.placeholder"
                  style="width: 100%"
                />
                <!-- 日期时间 -->
                <el-date-picker
                  v-else-if="field.type === 'datetime'"
                  v-model="advancedModel[field.key] as string"
                  type="datetime"
                  value-format="YYYY-MM-DDTHH:mm:ss[Z]"
                  :placeholder="field.placeholder"
                  style="width: 100%"
                />
                <!-- 单选 -->
                <el-select
                  v-else-if="field.type === 'select'"
                  v-model="advancedModel[field.key] as string"
                  clearable
                  :placeholder="field.placeholder"
                  style="width: 100%"
                >
                  <el-option v-for="opt in field.options" :key="opt.value" :label="opt.label" :value="opt.value" />
                </el-select>
                <!-- 多选/自由输入 -->
                <el-select
                  v-else-if="field.type === 'multiselect'"
                  v-model="advancedModel[field.key] as string[]"
                  multiple
                  filterable
                  allow-create
                  default-first-option
                  clearable
                  :placeholder="field.placeholder"
                  style="width: 100%"
                />
                <!-- 开关 -->
                <el-switch
                  v-else-if="field.type === 'switch'"
                  v-model="advancedModel[field.key] as boolean"
                />
                <!-- 文本 -->
                <el-input
                  v-else
                  v-model="advancedModel[field.key] as string"
                  clearable
                  :placeholder="field.placeholder"
                />
              </el-form-item>

              <!-- extra 键值对 -->
              <el-form-item label="扩展对象">
                <div class="extra-rows">
                  <div v-for="(row, idx) in extraRows" :key="idx" class="extra-row">
                    <el-select
                      v-model="row.key"
                      filterable
                      allow-create
                      default-first-option
                      placeholder="键"
                      style="width: 160px"
                    >
                      <el-option v-for="k in EXTRA_KNOWN_KEYS" :key="k" :label="k" :value="k" />
                    </el-select>
                    <el-input v-model="row.value" placeholder="值" style="flex: 1; margin: 0 8px" />
                    <el-button type="danger" link @click="removeExtraRow(idx)">删除</el-button>
                  </div>
                  <el-button type="primary" link @click="addExtraRow">+ 添加扩展字段</el-button>
                </div>
              </el-form-item>
            </el-form>
          </el-tab-pane>

          <!-- JSON 模式 -->
          <el-tab-pane label="JSON 模式" name="json">
            <el-input
              v-model="jsonText"
              type="textarea"
              :rows="8"
              placeholder='完整 payload JSON，如 {"targetRoute":[...],"initPriority":50}'
              @blur="syncFromJson"
            />
            <div v-if="jsonError" class="json-error">{{ jsonError }}</div>
            <el-button type="primary" link style="margin-top: 6px" @click="formatJson">格式化</el-button>
          </el-tab-pane>
        </el-tabs>
      </el-collapse-item>
    </el-collapse>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, watch } from "vue";
  import { ADVANCED_FIELDS, EXTRA_KNOWN_KEYS } from "../constants";

  defineOptions({ name: "TaskParamForm" });

  /** extra 键值对行 */
  interface ExtraRow {
    key: string;
    value: string;
  }

  const mode = ref<"form" | "json">("form");
  const activeNames = ref<string[]>([]);

  // 高级字段模型（key -> 值）
  const advancedModel = reactive<Record<string, unknown>>({});
  // extra 键值对
  const extraRows = ref<ExtraRow[]>([]);
  // JSON 模式文本 + 错误
  const jsonText = ref("");
  const jsonError = ref("");

  // 由外部注入的基础 payload 片段（targetRoute），组装时合并
  const props = defineProps<{
    /** 由源/目标位置生成的 targetRoute，父组件维护 */
    targetRoute?: unknown[];
  }>();

  const emit = defineEmits<{
    /** 向父组件抛出完整 payload（不含 undefined 时抛 undefined） */
    (e: "change", payload: Record<string, unknown> | undefined): void;
  }>();

  /** 添加/删除 extra 行 */
  function addExtraRow(): void {
    extraRows.value.push({ key: "", value: "" });
  }
  function removeExtraRow(idx: number): void {
    extraRows.value.splice(idx, 1);
  }

  /** 组装完整 payload：targetRoute + 高级字段 + extra */
  function buildPayload(): Record<string, unknown> | undefined {
    const payload: Record<string, unknown> = {};

    // targetRoute（父组件根据源/目标位置生成）
    if (Array.isArray(props.targetRoute) && props.targetRoute.length > 0) {
      payload.targetRoute = props.targetRoute;
    }

    // 高级字段（去空）
    for (const field of ADVANCED_FIELDS) {
      const val = advancedModel[field.key];
      if (val === undefined || val === null || val === "" || (Array.isArray(val) && val.length === 0)) {
        continue;
      }
      payload[field.key] = val;
    }

    // extra 键值对
    const extra: Record<string, string> = {};
    for (const row of extraRows.value) {
      if (row.key && row.value !== "") extra[row.key] = row.value;
    }
    if (Object.keys(extra).length > 0) payload.extra = extra;

    return Object.keys(payload).length > 0 ? payload : undefined;
  }

  /** 表单模式变更 → 通知父组件 */
  function notifyChange(): void {
    const payload = buildPayload();
    // 同步到 JSON 文本（保持两模式一致）
    jsonText.value = payload ? JSON.stringify(payload, null, 2) : "";
    jsonError.value = "";
    emit("change", payload);
  }

  watch([advancedModel, extraRows], notifyChange, { deep: true });
  watch(() => props.targetRoute, notifyChange, { deep: true });

  /** JSON 模式失焦 → 解析回写到表单模型 */
  function syncFromJson(): void {
    if (!jsonText.value.trim()) {
      jsonError.value = "";
      resetModel();
      emit("change", undefined);
      return;
    }
    try {
      const parsed = JSON.parse(jsonText.value) as Record<string, unknown>;
      jsonError.value = "";
      applyPayload(parsed);
      // 抛出（去掉 targetRoute 由父组件回填的语义，这里直接整体抛出）
      emit("change", Object.keys(parsed).length > 0 ? parsed : undefined);
    } catch (e) {
      jsonError.value = `JSON 格式不正确：${(e as Error).message}`;
    }
  }

  /** 格式化 JSON */
  function formatJson(): void {
    if (!jsonText.value.trim()) return;
    try {
      jsonText.value = JSON.stringify(JSON.parse(jsonText.value), null, 2);
      jsonError.value = "";
    } catch (e) {
      jsonError.value = `JSON 格式不正确：${(e as Error).message}`;
    }
  }

  /** 清空表单模型 */
  function resetModel(): void {
    Object.keys(advancedModel).forEach((k) => delete advancedModel[k]);
    extraRows.value = [];
  }

  /** 将 payload 回填到表单模型（编辑回显 / JSON 同步用；targetRoute 交给父组件反推，此处忽略） */
  function applyPayload(payload?: Record<string, unknown>): void {
    resetModel();
    if (!payload) {
      jsonText.value = "";
      return;
    }
    const advancedKeys = ADVANCED_FIELDS.map((f) => f.key);
    for (const [k, v] of Object.entries(payload)) {
      if (k === "targetRoute") continue;
      if (k === "extra" && v && typeof v === "object") {
        extraRows.value = Object.entries(v as Record<string, unknown>).map(([ek, ev]) => ({
          key: ek,
          value: String(ev),
        }));
      } else if (advancedKeys.includes(k)) {
        advancedModel[k] = v;
      } else {
        // 未知顶层键：以 extra 行兜底展示，避免丢失
        extraRows.value.push({ key: k, value: typeof v === "object" ? JSON.stringify(v) : String(v) });
      }
    }
    jsonText.value = Object.keys(payload).length > 0 ? JSON.stringify(payload, null, 2) : "";
  }

  /** 编辑回显：父组件调用，回填 payload 到表单，并自动展开高级选项 */
  function setPayload(payload?: Record<string, unknown>): void {
    applyPayload(payload);
    // 若有非 targetRoute 的高级参数，自动展开
    const hasAdvanced = payload
      && Object.keys(payload).some((k) => k !== "targetRoute");
    if (hasAdvanced) activeNames.value = ["advanced"];
  }

  /** 重置：父组件关闭弹窗时调用 */
  function reset(): void {
    resetModel();
    jsonText.value = "";
    jsonError.value = "";
    mode.value = "form";
    activeNames.value = [];
  }

  defineExpose({ setPayload, reset, buildPayload });
</script>

<style scoped>
  .param-inner-form {
    padding-top: 4px;
  }
  .extra-rows {
    width: 100%;
  }
  .extra-row {
    display: flex;
    align-items: center;
    margin-bottom: 8px;
  }
  .json-error {
    margin-top: 4px;
    color: var(--el-color-danger);
    font-size: 12px;
  }
</style>
