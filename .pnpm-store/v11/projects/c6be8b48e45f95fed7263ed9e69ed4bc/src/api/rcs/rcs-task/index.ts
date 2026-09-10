import request from "@/utils/request";
import type { RcsTaskForm, RcsTaskItem, RcsTaskQueryParams } from "./types";
import type { PageResult } from "@/api/common";

export type { RcsTaskForm, RcsTaskItem, RcsTaskQueryParams, RcsTaskLifecycle } from "./types";

const RCS_TASK_BASE_URL = "/api/v1/rcs-task";

const RcsTaskAPI = {
  /** 获取 RCS 任务分页数据 */
  getPage(queryParams?: RcsTaskQueryParams) {
    return request<unknown, PageResult<RcsTaskItem>>({
      url: `${RCS_TASK_BASE_URL}`,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取 RCS 任务详情（含状态变更时间线 lifecycles） */
  getDetail(id: string) {
    return request<unknown, RcsTaskItem>({
      url: `${RCS_TASK_BASE_URL}/${id}`,
      method: "get",
    });
  },
  /** 新增 RCS 任务并自动下发（返回新任务 id，雪花字符串） */
  create(data: RcsTaskForm) {
    return request<unknown, string>({
      url: `${RCS_TASK_BASE_URL}`,
      method: "post",
      data,
    });
  },
  /** 下发 / 重新下发 RCS 任务（联动 RCS） */
  submit(id: string) {
    return request({
      url: `${RCS_TASK_BASE_URL}/${id}/submit`,
      method: "post",
    });
  },
  /** 取消 RCS 任务（联动 RCS，reason 走 query 参数，可空） */
  cancel(id: string, reason?: string) {
    return request({
      url: `${RCS_TASK_BASE_URL}/${id}/cancel`,
      method: "post",
      params: { reason },
    });
  },
  /** 修改 RCS 任务 */
  update(id: string, data: RcsTaskForm) {
    return request({
      url: `${RCS_TASK_BASE_URL}/${id}`,
      method: "put",
      data,
    });
  },
  /** 批量删除 RCS 任务（ids 多个以英文逗号分割） */
  deleteByIds(ids: string) {
    return request({
      url: `${RCS_TASK_BASE_URL}/${ids}`,
      method: "delete",
    });
  },
};

export default RcsTaskAPI;
