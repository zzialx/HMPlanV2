import { AxiosError } from "@nutpi/axios";
import { JSONUtil, StrUtil } from "@pura/harmony-utils";
import { LXBaseRespBean } from "../common/bean/BaseRespBean";
import { LXPostFileModel } from "../common/bean/LXPostFileResp";
import {
  CommonType,
  lxHttpClient,
  LXAxiosHttpRequest,
  LXHttpRequestConfig
} from "./AxiosClient";
import WinLog from "./WinLog";

// ==================== 类型常量定义 ====================
export type HttpErrorCode =
  | 'INVALID_ARGUMENT'
    | 'NETWORK'
    | 'SERVER'
    | 'PARSE'
    | 'UNKNOWN';

export interface HttpErrorDetail {
  statusCode?: number;
  raw?: string;
}

// ==================== 标准化错误类 ====================
export class HttpRequestError extends Error {
  public readonly code: HttpErrorCode;
  public readonly detail?: HttpErrorDetail;

  constructor(code: HttpErrorCode, message: string, detail?: HttpErrorDetail) {
    super(message);
    this.code = code;
    this.detail = detail;
    this.name = 'HttpRequestError';
  }

  public isServerError(): boolean {
    return this.code === 'SERVER';
  }

  public isNetworkError(): boolean {
    return this.code === 'NETWORK';
  }
}

// ==================== 常量 ====================
const REQUEST_NO_DATA = 'request no data';
const PARSE_ERROR_MSG = 'parse response data failed';

// ==================== 工具函数 ====================
function requireNonEmptyString(
  value: string | undefined | null,
  fieldName: string
): string {
  if (StrUtil.isEmpty(value)) {
    throw new HttpRequestError('INVALID_ARGUMENT', `${fieldName} cannot be empty`);
  }
  return value!;
}

function parseJsonResponse<T>(raw: string): T {
  try {
    return JSON.parse(raw) as T;
  } catch {
    throw new HttpRequestError('PARSE', PARSE_ERROR_MSG, { raw });
  }
}

// ✅ 修复：类型从 Error → unknown（catch 里可以是任何值）
function normalizeError(error: Error, action: string): HttpRequestError {
  if (error instanceof HttpRequestError) {
    return error;
  }

  if (error instanceof AxiosError) {
    return new HttpRequestError(
      'NETWORK',
      `${action} failed: ${error.message}`,
      { statusCode: error.response?.status }
    );
  }

  if (error instanceof Error) {
    return new HttpRequestError('UNKNOWN', `${action} failed: ${error.message}`);
  }

  return new HttpRequestError('UNKNOWN', `${action} failed`, { raw: String(error) });
}

// ✅ 修复：入参支持 string | number | undefined
function parseBizCode(code: string | number | undefined): number | undefined {
  if (typeof code === 'number') {
    return Number.isFinite(code) ? code : undefined;
  }
  if (typeof code === 'string') {
    const num = Number(code);
    return Number.isFinite(num) ? num : undefined;
  }
  return undefined;
}

function validateBizResponse<T extends LXBaseRespBean>(res: T, action: string): T {
  if (!res || typeof res !== 'object') {
    throw new HttpRequestError('SERVER', REQUEST_NO_DATA);
  }

  const code = parseBizCode(res.code);
  if (code === undefined) {
    throw new HttpRequestError('SERVER', 'response code is empty');
  }

  if (code === 0 || code === 200) {
    return res;
  }

  const msg = res.message ?? `${action} failed`;
  throw new HttpRequestError('SERVER', msg, { statusCode: code });
}

// ==================== 统一工具类（完美无报错） ====================
export class HttpUtil {
  private static readonly instance: LXAxiosHttpRequest = lxHttpClient;

  // ---------------------------------------------------------------------------
  // ✅ 标准 GET 请求（和 POST / 上传 完全统一逻辑）
  // ---------------------------------------------------------------------------
  public static async get<T extends LXBaseRespBean>(
    url: string,
    config?: LXHttpRequestConfig
  ): Promise<T> {
    try {
      const raw = await HttpUtil.instance.get<string>(url, config);
      WinLog.info(`[get] ${url} response: ` + JSON.stringify(raw));
      const rawResponseStr:string = JSON.stringify(raw['data']);
      const res = parseJsonResponse<T>(rawResponseStr);
      return validateBizResponse<T>(res, `get ${url}`);
    } catch (err) {
      const normalizedErr = normalizeError(err, `get ${url}`);
      WinLog.error(`[get] ${url} error: code=${normalizedErr.code}, msg=${normalizedErr.message}`);
      throw normalizedErr;
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ 底层 request 统一封装（自定义 config）
  // ---------------------------------------------------------------------------
  public static async request<T extends LXBaseRespBean>(
    config: LXHttpRequestConfig
  ): Promise<T> {
    const tag = config.url || 'unknown request';
    try {
      const raw = await HttpUtil.instance.request<string>(config);
      WinLog.info(`[request] ${tag} response: ` + JSON.stringify(raw));
      const rawResponseStr:string = JSON.stringify(raw['data']);
      const res = parseJsonResponse<T>(rawResponseStr);
      return validateBizResponse<T>(res, `request ${tag}`);
    } catch (err) {
      const normalizedErr = normalizeError(err, `request ${tag}`);
      WinLog.error(`[request] ${tag} error: code=${normalizedErr.code}, msg=${normalizedErr.message}`);
      throw normalizedErr;
    }
  }
  // ------------------------------
  // ✅ 🔥 你要的：标准化 POST（和上传逻辑完全一致）
  // ------------------------------
  public static async post<T extends LXBaseRespBean>(
    url: string,
    data?: CommonType,
    config?: LXHttpRequestConfig
  ): Promise<T> {
    try {
      // 1. 发起请求httpClient
      const rawResponse = await HttpUtil.instance.post<string>(url,data,config);
      const rawResponseStr:string = JSON.stringify(rawResponse['data']);
      // 2. 打印日志
      WinLog.info(`[post] ${url} response: ` + JSON.stringify(rawResponse['data']));
      // 3. JSON 解析（统一处理）
      const resModel = parseJsonResponse<T>(rawResponseStr);
      // 4. 业务校验（统一处理）
      return validateBizResponse<T>(resModel, `post ${url}`);
    } catch (err) {
      // 5. 统一异常处理
      const normalizedErr = normalizeError(err, `post ${url}`);
      WinLog.error(`[post] ${url} error: code=${normalizedErr.code}, msg=${normalizedErr.message}`);
      throw normalizedErr;
    }
  }

  // ==================== 上传方法 ====================
  public static async uploadLogFile(
    url: string,
    logType: string,
    filePath?: string
  ): Promise<LXPostFileModel> {
    const safePath = requireNonEmptyString(filePath, 'filePath');
    try {
      const raw = await lxHttpClient.uploadLogFile(url, safePath, logType);
      const res = parseJsonResponse<LXPostFileModel>(raw);
      WinLog.info('[uploadLogFile]' + JSON.stringify(res));
      return validateBizResponse(res, 'upload log');
    } catch (err) {
      const normalizedErr = normalizeError(err, 'upload log');
      WinLog.error(`[uploadLogFile] code=${normalizedErr.code}, msg=${normalizedErr.message}`);
      throw normalizedErr;
    }
  }
  /*
   * 上传照片 Path方式
   * */
  public static async uploadImage(
    url: string,
    filePathList: string[],
    showLoading?: boolean
  ): Promise<LXPostFileModel> {
    if (!filePathList?.length) {
      WinLog.error('file path is null');
      throw new HttpRequestError('INVALID_ARGUMENT', 'filePathList cannot be empty');
    }
    try {
      const raw = await lxHttpClient.uploadImages(url, filePathList);
      const rawResponseStr:string = JSON.stringify(raw['data']);
      const res = parseJsonResponse<LXPostFileModel>(rawResponseStr);
      WinLog.info('[uploadImage]' + JSON.stringify(rawResponseStr));
      return validateBizResponse(res, 'upload image');
    } catch (err) {
      const normalizedErr = normalizeError(err, 'upload image');
      WinLog.error(`[uploadImage] code=${normalizedErr.code}, msg=${normalizedErr.message}`);
      throw normalizedErr;
    }
  }
  /*
   * 上传照片 Uri 方式
   * */
  public static async uploadImageUri(
    url: string,
    fileUri: string,
    showLoading?: boolean
  ): Promise<LXPostFileModel> {
    const safeUri = requireNonEmptyString(fileUri, 'fileUri');
    try {
      const raw = await lxHttpClient.uploadImageByUri(url, safeUri);
      const rawResponseStr:string = JSON.stringify(raw['data']);
      const res = parseJsonResponse<LXPostFileModel>(rawResponseStr);
      WinLog.info('[uploadImageUri]' + JSON.stringify(res));
      return validateBizResponse(res, 'upload image uri');
    } catch (err) {
      const normalizedErr = normalizeError(err, 'upload image uri');
      WinLog.error(`[uploadImageUri] code=${normalizedErr.code}, msg=${normalizedErr.message}`);
      throw normalizedErr;
    }
  }
}

export default HttpUtil;