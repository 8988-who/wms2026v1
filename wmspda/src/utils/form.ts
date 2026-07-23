import type { FormSchema } from "@wot-ui/ui/components/wd-form/types";

/**
 * v1 FormRules → v2 FormSchema 适配器
 * 将旧版 rules 格式转换为 v2 的 schema 格式
 */
export function toFormSchema(
  rules: Record<string, { required?: boolean; message?: string; pattern?: RegExp }[]>
): FormSchema {
  return {
    validate(model: Record<string, any>) {
      const issues: { path: Array<string | number>; message: string }[] = [];
      for (const [field, fieldRules] of Object.entries(rules)) {
        const value = model[field];
        for (const rule of fieldRules) {
          if (rule.required) {
            const isEmpty =
              value === undefined ||
              value === null ||
              (typeof value === "string" && value.trim() === "") ||
              (Array.isArray(value) && value.length === 0);
            if (isEmpty) {
              issues.push({ path: [field], message: rule.message || `${field} 为必填项` });
              break;
            }
          }
          if (rule.pattern && typeof value === "string" && !rule.pattern.test(value)) {
            issues.push({ path: [field], message: rule.message || `${field} 格式不正确` });
            break;
          }
        }
      }
      return issues;
    },
  };
}
