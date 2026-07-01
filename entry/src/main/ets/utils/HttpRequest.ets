import { AxiosError } from '@ohos/axios'
import { JSON } from '@kit.ArkTS'
import { StrUtil } from '@pura/harmony-utils'
import { lxHttpClient } from './AxiosClient'
import WinLog from './WinLog'
import { LXPostFileModel } from '../common/bean/LXPostFileResp'

// ==================== 类型常量定义 ====================
export type HttpErrorCode = 'INVALID_ARGUMENT' | 'NETWORK' | 'SERVER' | 'PARSE' | 'UNKNOWN'

export interface HttpErrorDetail {
  statusCode?: number
  raw?: string
}

// ==================== 标准化错误类 ====================
export class HttpRequestError extends Error {
  public readonly code: HttpErrorCode
  public readonly detail?: HttpErrorDetail

  constructor(code: HttpErrorCode, message: string, detail?: HttpErrorDetail) {
    super(message)
    this.code = code
    this.detail = detail
    this.name = 'HttpRequestError'

    // 标准 Error 继承修复
    // Object.setPrototypeOf(this, HttpRequestError.prototype)
  }

  /** 判断是否为业务异常 */
  public isServerError(): boolean {
    return this.code === 'SERVER'
  }

  /** 判断是否为网络异常 */
  public isNetworkError(): boolean {
    return this.code === 'NETWORK'
  }
}

// ==================== 常量 ====================
const REQUEST_NO_DATA = 'request no data'
const PARSE_ERROR_MSG = 'parse response data failed'

// ==================== 工具函数（纯函数·无副作用） ====================
/**
 * 校验字符串非空
 */
function requireNonEmptyString(value: string | undefined | null, fieldName: string): string {
  if (StrUtil.isEmpty(value)) {
    throw new HttpRequestError('INVALID_ARGUMENT', `${fieldName} cannot be empty`)
  }
  return value as string
}

/**
 * JSON 解析·标准化异常
 */
function parseJsonResponse<T>(raw: string): T {
  try {
    return JSON.parse(raw) as T
  } catch {
    throw new HttpRequestError('PARSE', PARSE_ERROR_MSG, { raw })
  }
}

/**
 * 统一异常转换
 */
function normalizeError(error: Error, action: string): HttpRequestError {
  if (error instanceof HttpRequestError) {
    return error
  }

  if (error instanceof AxiosError) {
    return new HttpRequestError(
      'NETWORK',
      `${action} failed: ${error.message}`,
      { statusCode: error.response?.status }
    )
  }

  if (error instanceof Error) {
    return new HttpRequestError('UNKNOWN', `${action} failed: ${error.message}`)
  }

  return new HttpRequestError('UNKNOWN', `${action} failed`, { raw: String(error) })
}

/**
 * 解析业务 code
 */
function parseBizCode(code:string): number | undefined {
  if (typeof code === 'number') {
    return Number.isFinite(code) ? code : undefined
  }
  if (typeof code === 'string') {
    const num = Number(code)
    return Number.isFinite(num) ? num : undefined
  }
  return undefined
}

/**
 * 统一业务结果校验
 */
function validateBizResponse<T extends LXPostFileModel>(res: T, action: string): T {
  if (!res) {
    throw new HttpRequestError('SERVER', REQUEST_NO_DATA)
  }
  if (!res.code) {
    throw new HttpRequestError('SERVER', REQUEST_NO_DATA)
  }
  const code = parseBizCode(res.code)
  if (code === 0 || code === 200) {
    return res
  }

  const msg = res.message ? `${action} failed: ${res.message}` : `${action} failed`
  throw new HttpRequestError('SERVER', msg, { statusCode: code })
}

// ==================== 统一请求入口（大厂标准·静态类） ====================
export class HttpRequest {
  private constructor() {}

  /**
   * 上传日志文件
   */
  public static async uploadLogFile(
    url: string,
    logType: string,
    filePath?: string
  ): Promise<LXPostFileModel> {
    const safePath = requireNonEmptyString(filePath, 'filePath')

    try {
      const raw = await lxHttpClient.uploadLogFile(url, safePath, logType)
      const res = parseJsonResponse<LXPostFileModel>(raw)
      WinLog.info('[上传日志响应]'+ JSON.stringify(res))
      return validateBizResponse(res, 'upload log')
    } catch (err) {
      const normalizedErr = normalizeError(err, 'upload log')
      WinLog.error(`[上传日志异常] code=${normalizedErr.code}, msg=${normalizedErr.message}`)
      throw normalizedErr
    }
  }

  /**
   * 批量上传图片（路径模式）
   */
  public static async uploadImage(
    url: string,
    filePathList: string[],
    showLoading?: boolean
  ): Promise<LXPostFileModel> {
    if (!filePathList || filePathList.length === 0) {
      WinLog.error('上传照片为空');
      throw new HttpRequestError('INVALID_ARGUMENT', 'filePathList cannot be empty')
    }

    try {
      const raw = await lxHttpClient.uploadImages(url, filePathList)
      const res = parseJsonResponse<LXPostFileModel>(raw)
      WinLog.info('[上传图片响应]'+ JSON.stringify(res))
      return validateBizResponse(res, 'upload image')
    } catch (err) {
      const normalizedErr = normalizeError(err, 'upload image')
      WinLog.error(`[上传图片异常] code=${normalizedErr.code}, msg=${normalizedErr.message}`)
      throw normalizedErr
    }
  }

  /**
   * 上传图片（URI模式）
   */
  public static async uploadImageUri(
    url: string,
    fileUri: string,
    showLoading?: boolean
  ): Promise<LXPostFileModel> {
    const safeUri = requireNonEmptyString(fileUri, 'fileUri')

    try {
      const raw = await lxHttpClient.uploadImageByUri(url, safeUri)
      const res = parseJsonResponse<LXPostFileModel>(raw)
      WinLog.info('[URI上传响应]' + JSON.stringify(res))
      return validateBizResponse(res, 'upload image uri')
    } catch (err) {
      const normalizedErr = normalizeError(err, 'upload image uri')
      WinLog.error(`[URI上传异常] code=${normalizedErr.code}, msg=${normalizedErr.message}`)
      throw normalizedErr
    }
  }
}