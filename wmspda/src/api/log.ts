import request from "@/utils/request";

const LOG_BASE_URL = "/api/v1/logs";

const LogAPI = {
  /**
   * 获取日志分页列表
   *
   * @param queryParams 查询参数
   */
  getPage(queryParams?: LogPageQuery) {
    return request<PageResult<LogItem>>({
      url: `${LOG_BASE_URL}`,
      method: "GET",
      data: queryParams,
    });
  },

  /**
   * 获取访问趋势统计
   *
   * @param queryParams 查询参数
   * @returns 访问趋势数据
   */
  getVisitTrend(queryParams: VisitTrendQuery) {
    return request<VisitTrend>({
      url: `${LOG_BASE_URL}/analytics/trend`,
      method: "GET",
      data: queryParams,
    });
  },

  /**
   * 获取访问概览统计
   *
   * @returns 访问概览数据
   */
  getVisitOverview() {
    return request<VisitOverview>({
      url: `${LOG_BASE_URL}/analytics/overview`,
      method: "GET",
    });
  },
};

export default LogAPI;

/**
 * 日志分页查询对象
 */
export interface LogPageQuery extends PageQuery {
  /** 搜索关键字 */
  keywords?: string;
  /** 操作时间 */
  createTime?: [string, string] | string;
}

/**
 * 系统日志分页对象
 */
export interface LogItem {
  /** 主键 */
  id?: number;
  /** 模块 */
  module?: number;
  /** 操作类型 */
  actionType?: number;
  /** 操作标题 */
  title?: string;
  /** 自定义日志内容 */
  content?: string;
  /** 操作人ID */
  operatorId?: number;
  /** 操作人名称 */
  operatorName?: string;
  /** 请求路径 */
  requestUri?: string;
  /** 请求方法 */
  requestMethod?: string;
  /** IP 地址 */
  ip?: string;
  /** 地区 */
  region?: string;
  /** 浏览器 */
  browser?: string;
  /** 终端系统 */
  os?: string;
  /** 状态：0失败 1成功 */
  status?: number;
  /** 错误信息 */
  errorMsg?: string;
  /** 执行时间(毫秒) */
  executionTime?: number;
  /** 操作时间 */
  createTime?: string;
}

/**  访问趋势 */
export interface VisitTrend {
  /** 日期列表 */
  dates: string[];
  /** 浏览量(PV) */
  pvList: number[];
  /** 访客数(UV) */
  uvList: number[];
}

/** 访问趋势查询参数 */
export interface VisitTrendQuery {
  /** 开始日期 */
  startDate: string;
  /** 结束日期 */
  endDate: string;
}

/**  访问统计 */
export interface VisitOverview {
  /** 今日访客数(UV) */
  todayUvCount: number;
  /** 总访客数 */
  totalUvCount: number;
  /** 访客数同比增长率（相对于昨天同一时间段的增长率） */
  uvGrowthRate: number;
  /** 今日浏览量(PV) */
  todayPvCount: number;
  /** 总浏览量 */
  totalPvCount: number;
  /** 同比增长率（相对于昨天同一时间段的增长率） */
  pvGrowthRate: number;
}
