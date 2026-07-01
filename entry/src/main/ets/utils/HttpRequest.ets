import {
  AxiosError, AxiosHeaders, AxiosRequestHeaders, AxiosProgressEvent, FormData
} from '@ohos/axios'
import axiosClient, { AxiosHttpRequest } from './AxioHttp'
import { JSON } from '@kit.ArkTS'
import { deviceInfo, zlib } from '@kit.BasicServicesKit'
import { i18n } from '@kit.LocalizationKit'
import { AES, CryptoHelper, CryptoUtil, MD5, StrUtil } from '@pura/harmony-utils'
import fs from '@ohos.file.fs'
import { FileUtil, NumberUtil } from '@pura/harmony-utils'
import { DownLoadCallback, DownLoadErrorCallback, WinDownloadFileModel } from '../common/bean/WinDownloadFileModel'
import CommonRequestConstants from '../common/constants/CommonRequestConstants'
import CommonUserInfoConstants from '../common/constants/CommonUserInfoConstants'
import WinCommonUtils from '../common/utils/WinCommonUtils'
import WinLog from './WinLog'
import { DialogHelperMgr } from '../common/tool/DialogHelperMgr'
import { PreferenceMgrTool } from '../common/tool/PreferenceMgrTool'
import { secretKey } from './SecretKey'
import { ZlibUtils } from '../common/utils/ZlibUtils'

// ============================================================
// 类型定义
// ============================================================

export type CommonType = number | string | boolean | Array<number> | Array<string> | Array<boolean> | object | Object | ArrayBuffer

/** Map 嵌套结构或 JSON 字符串 */
export type RequestBodyParam = Map<string, string | object | Map<string, string | object> | Map<string, string>[]> | string

export type GetRequestBodyParam = Map<string, string | object | Map<string, string | object> | Map<string, string>[]>

// ============================================================
// 常量
// ============================================================

const REQUEST_NO_DATA = 'request no data'
const FORM_DATA_NAME = 'form-data; name=\'150564\''
const LOG_TAG = 'HttpRequest'

// ============================================================
// 请求配置接口
// ============================================================

export interface WinPostConfig {
  url: string
  params: RequestBodyParam
  showLoading?: boolean
}

export interface WinGetConfig {
  url: string
  params: GetRequestBodyParam
  showLoading?: boolean
}

export interface WinPostFormConfig {
  url: string
  params: Map<string, string>
  showLoading?: boolean
}

export interface WinUploadImagesConfig {
  url: string
  filePathList: string[]
  headParams: Map<string, string>
  bodyParams: Map<string, string | Map<string, string>>
  showLoading?: boolean
}

export interface WinDownloadConfig {
  url: string
  filePath: string
  /** 下载进度回调（可选，用于中间状态通知） */
  onProgress?: (model: WinDownloadFileModel) => void
}

// ============================================================
// 响应模型
// ============================================================

/** 泛型 API 响应 */
export interface ApiResponse<T = Object> {
  result?: boolean | string
  data?: T
  status?: string
  msg?: string
  flag?: number
}

/** 向后兼容旧代码 */
export class PostFileModel {
  result?: boolean | string
  message?: string
}

/** 向后兼容旧代码 */
export class PostModel {
  x?: boolean
  data?: string
  status?: string
  msg?: string
  flag?: number
  empid?: string
  timeUpdate?: string
  bizDate?: string
  result?: boolean | string
}

// ============================================================
// 工具函数（模块级）
// ============================================================

function getCommonParams(): Record<string, string> {
  return {
    "platform": deviceInfo.deviceType,
    "osVersion": CommonRequestConstants.App_Version,
    "language": i18n.System.getSystemLanguage(),
    "os": deviceInfo.deviceType,
    "compress": CommonRequestConstants.RES_COMPRESS,
    "imei": deviceInfo.serial
  }
}

function getCommonHeaders(): AxiosHeaders {
  const headers = new AxiosHeaders()
  headers.set('Accept-Language', i18n.System.getSystemLanguage())
  headers.set('User-Agent', WinCommonUtils.getUserAgent())
  return headers
}

function safeJsonParse<T>(data: string, label: string): T {
  try {
    // //需要先 AES128解密，在 unzip解压
    // const smyKeyBase64Str = secretKey();
    // let symKey = CryptoUtil.getConvertSymKeySync('AES128', smyKeyBase64Str, 'utf-8');
    // let dataBlob = CryptoHelper.strToDataBlob(data, 'utf-8'); //待加密数据
    // const decryptData = AES.decryptECBSync(dataBlob,symKey,'AES128|ECB|PKCS7')
    // //解压
    // const resultData = ZlibUtils.decompressBuffer(decryptData.data,decryptData.data.length);

    return JSON.parse(data) as T
  } catch (e) {
    const msg = `${label} JSON parse failed: ${JSON.stringify(e)}`
    WinLog.error(msg)
    throw new Error(msg)
  }
}

function mergeInto(target: Record<string, Object>, source: Record<string, string>): Record<string, Object> {
  const keys = Object.keys(source)
  for (let i = 0; i < keys.length; i++) {
    target[keys[i]] = source[keys[i]]
  }
  return target
}

function mapToJsonObject(
  params: Map<string, string | object | Map<string, string | object> | Map<string, string>[]>
): Record<string, Object> {
  const result: Record<string, Object> = {}
  params.forEach((value, key) => {
    if (key == undefined || value == undefined) return
    if (value instanceof Map) {
      const sub: Record<string, Object> = {}
      value.forEach((sv, sk) => {
        if (sv instanceof Array) {
          sub[sk] = (sv as Map<string, string>[]).map(innerMap => {
            const item: Record<string, Object> = {}
            innerMap.forEach((gv, gk) => { item[gk] = gv })
            return item
          }) as object
        } else {
          sub[sk] = sv as object
        }
      })
      result[key] = sub
    } else {
      result[key] = value
    }
  })
  return result
}

function buildRequestBody(params: RequestBodyParam): string {
  if (typeof params === 'string') return params
  const obj = mapToJsonObject(params)
  mergeInto(obj, getCommonParams())
  return JSON.stringify(obj)
}

function buildImageRequestBody(params: Map<string, string | Map<string, string>>): string {
  const obj = mapToJsonObject(params)
  mergeInto(obj, getCommonParams())
  return JSON.stringify(obj)
}

function showLoading(): void {
  try { DialogHelperMgr.showLoading() } catch (e) { WinLog.error(`${LOG_TAG} showLoading failed`) }
}

function dismissLoading(): void {
  try { DialogHelperMgr.closeLoading() } catch (e) { WinLog.error(`${LOG_TAG} closeLoading failed`) }
}

function toError(err: Object): Error {
  return new Error(err instanceof Error ? err.message : JSON.stringify(err))
}

// ---- 文件 I/O 工具 ----

function closeFile(f: fs.File): void {
  try { fs.closeSync(f.fd) } catch (e) { /* already closed */ }
}

function readFileToBuffer(path: string): ArrayBuffer {
  const f = fs.openSync(path, 0o2)
  try {
    const stat = fs.lstatSync(path)
    const buf = new ArrayBuffer(stat.size)
    fs.readSync(f.fd, buf)
    fs.fsyncSync(f.fd)
    return buf
  } finally {
    closeFile(f)
  }
}

// ============================================================
// 核心服务类
// ============================================================

export class HttpRequestService {
  private client: AxiosHttpRequest

  constructor(client: AxiosHttpRequest = axiosClient) {
    this.client = client
  }

  // ---- JSON POST ----

  async post<T = Object>(config: WinPostConfig): Promise<ApiResponse<T>> {
    const headers = getCommonHeaders()
    headers.set('Content-Type', CommonRequestConstants.Content_Type_Value)
    WinLog.debug(`${LOG_TAG} post headers: ${JSON.stringify(headers)}`)

    const body = buildRequestBody(config.params)
    WinLog.debug(`${LOG_TAG} post params: ${body}`)

    if (config.showLoading) showLoading()

    try {
      const raw = await this.client.asyncPost({
        url: config.url,
        data: body,
        headers,
        showLoading: config.showLoading ?? false,
      })
      if (config.showLoading) dismissLoading()
      const res = safeJsonParse<ApiResponse<T>>(raw, 'post')
      WinLog.debug(`${LOG_TAG} post response: ${JSON.stringify(res)}`)
      if (!res) throw new Error(REQUEST_NO_DATA)
      return res
    } catch (err) {
      if (config.showLoading) dismissLoading()
      WinLog.error(`${LOG_TAG} post error: ${JSON.stringify(err)}`)
      throw toError(err)
    } finally {
      if (config.showLoading) dismissLoading()
    }
  }
  // ---- JSON GET ----

  async get<T = Object>(config: WinGetConfig): Promise<ApiResponse<T>> {
    const headers = getCommonHeaders()
    WinLog.debug(`${LOG_TAG} get headers: ${JSON.stringify(headers)}`)
    const  obj = mapToJsonObject(config.params)
    mergeInto(obj, getCommonParams())
    WinLog.debug(`${LOG_TAG} get params: ${JSON.stringify(obj)}`)

    if (config.showLoading) showLoading()

    try {
      const raw = await this.client.asyncGet({
        url: config.url,
        headers,
        showLoading: config.showLoading ?? false,
      })
      if (config.showLoading) dismissLoading()
      const res = safeJsonParse<ApiResponse<T>>(raw, 'get')
      WinLog.debug(`${LOG_TAG} get response: ${JSON.stringify(res)}`)
      if (!res) throw new Error(REQUEST_NO_DATA)
      return res
    } catch (err) {
      if (config.showLoading) dismissLoading()
      WinLog.error(`${LOG_TAG} get error: ${JSON.stringify(err)}`)
      throw toError(err)
    } finally {
      if (config.showLoading) dismissLoading()
    }
  }

  // ---- Form URL-encoded POST ----

  async postForm(config: WinPostFormConfig): Promise<string> {
    const headers = new AxiosHeaders()
    headers.set('Content-Type', 'application/x-www-form-urlencoded')

    const parts: string[] = []
    config.params.forEach((v, k) => {
      if (k != undefined && v != undefined) {
        parts.push(`${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
      }
    })
    if (!parts.length) throw new Error('postForm: params must not be empty')

    const encoded = parts.join('&')
    const body = StrUtil.strToUint8Array(encoded)
    WinLog.debug(`${LOG_TAG} postForm params: ${encoded}`)

    try {
      return await this.client.asyncPostResHeaders({
        url: config.url,
        data: body,
        headers,
        showLoading: config.showLoading ?? false,
      })
    } catch (err) {
      WinLog.error(`${LOG_TAG} postForm error: ${JSON.stringify(err)}`)
      throw toError(err)
    }
  }

  // ---- 上传日志文件 ----
  // 文件 I/O 在此完成，HTTP 委托给 client.upload()

  async uploadFile(url: string, filePath: string): Promise<PostFileModel> {
    const formData = new FormData()
    let fileCreated: fs.File | null = null

    try {
      // 确保日志文件存在（不截断原有内容）
      fileCreated = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)
      fs.fsyncSync(fileCreated.fd)
      closeFile(fileCreated)
      fileCreated = null

      // 读取文件到 FormData
      const buf = readFileToBuffer(filePath)
      formData.append('winlog', buf, { filename: 'winchannel.zip' })
    } catch (err) {
      WinLog.error(`${LOG_TAG} uploadFile read error: ${JSON.stringify(err)}`)
      throw new Error('Failed to read log file: ' + JSON.stringify(err))
    } finally {
      if (fileCreated) closeFile(fileCreated)
    }

    try {
      const raw = await this.client.upload(url, formData)
      const res = safeJsonParse<PostFileModel>(raw, 'uploadFile')
      WinLog.debug(`${LOG_TAG} uploadFile response: ${JSON.stringify(res)}`)
      if (!res) throw new Error(REQUEST_NO_DATA)
      return res
    } catch (err) {
      WinLog.error(`${LOG_TAG} uploadFile error: ${JSON.stringify(err)}`)
      throw toError(err)
    }
  }

  // ---- 批量上传图片 ----
  // 文件 I/O 在此完成，HTTP 委托给 client.upload()

  async uploadImages(config: WinUploadImagesConfig): Promise<PostFileModel> {
    const headers = getCommonHeaders()
    headers.set('Content-Disposition', FORM_DATA_NAME)
    headers.set('Content-Type', 'multipart/form-data')
    headers.set('Charset', 'UTF-8')
    headers.set('extension', 'JPEG')
    headers.set('connection', 'keep-alive')
    headers.set('method', 'F_PHOTO')

    const empId = PreferenceMgrTool.get(CommonRequestConstants.UserInfo_EMPID) as string
    headers.set('account', empId)
    config.headParams.forEach((v, k) => { headers.set(k, v, true) })
    const serverRequire = PreferenceMgrTool.get(CommonRequestConstants.SERVER_REQUIRE) as string
    headers.set('serverRequire', serverRequire, true)
    WinLog.debug(`${LOG_TAG} uploadImages headers: ${JSON.stringify(headers)}`)

    const body = buildImageRequestBody(config.bodyParams)
    WinLog.debug(`${LOG_TAG} uploadImages params: ${body}`)

    if (config.showLoading) showLoading()

    // 读取图片文件 → FormData
    const formData = new FormData()
    try {
      for (let i = 0; i < config.filePathList.length; i++) {
        const path = config.filePathList[i]
        const fileName = path.split('/').pop() || `image_${i}`
        const buf = readFileToBuffer(path)
        formData.append('image', buf, { filename: fileName })
      }
    } catch (err) {
      WinLog.error(`${LOG_TAG} uploadImages read error: ${JSON.stringify(err)}`)
      throw new Error('Failed to read image files: ' + JSON.stringify(err))
    }

    // 独立 client：upload header 与常规请求差异大，避免污染共享 client
    const uploadClient = new AxiosHttpRequest({
      baseURL: CommonRequestConstants.Base_Url_Test,
      timeout: CommonRequestConstants.TimeOut,
      checkResultCode: false,
      headers: headers as AxiosRequestHeaders,
    })

    try {
      const raw = await uploadClient.upload(config.url, formData,{
        data:body,
        headers,
        showLoading: config.showLoading ?? false,
      })
      const res = safeJsonParse<PostFileModel>(raw, 'uploadImages')
      WinLog.debug(`${LOG_TAG} uploadImages response: ${raw}`)
      return res
    } catch (err) {
      WinLog.error(`${LOG_TAG} uploadImages error: ${JSON.stringify(err)}`)
      throw toError(err)
    } finally {
      if (config.showLoading) dismissLoading()
    }
  }

  // ---- 文件下载 ----
  // 进度模型转换在此完成，HTTP 委托给 client.download()

  async downloadFile(config: WinDownloadConfig): Promise<WinDownloadFileModel> {
    const headers = getCommonHeaders()
    headers.set('Content-Type', 'application/x-www-form-urlencoded')

    const model = new WinDownloadFileModel()

    return new Promise<WinDownloadFileModel>((resolve, reject) => {
      this.client.download(
        config.url,
        config.filePath,
        (loaded: number, total: number) => {
          if (total > 0) {
            model.fileDownLoadStatus = '2'
            model.fileDownProgress = NumberUtil.toFloat((loaded / total * 100).toFixed(2).toString())
            model.fileLength = total
          } else {
            model.fileDownLoadStatus = '1'
            model.fileDownProgress = 0
          }
          if (config.onProgress) {
            config.onProgress(model)
          }
        },
        headers
      ).then(() => {
        model.fileDownLoadStatus = '3'
        model.fileDownProgress = 100
        model.fileLength = FileUtil.getFileDirSize(config.filePath)
        resolve(model)
      }).catch((err: string) => {
        reject(new Error(err))
      })
    })
  }
}

// ============================================================
// 默认单例
// ============================================================
const httpService = new HttpRequestService(axiosClient)
export default httpService

// ============================================================
// 向后兼容的静态包装类
// ============================================================
export class HttpRequest {

  /** @deprecated 请使用 httpService.post({ url, params, showLoading }) */
  static async postRequest<T = CommonType>(
    url: string,
    params: RequestBodyParam,
    showLoading?: boolean,
  ): Promise<PostModel> {
    return httpService.post<T>({ url, params, showLoading }) as Promise<PostModel>
  }

  /** @deprecated 请使用 httpService.get({ url, params, showLoading }) */
  static async getRequest<T = CommonType>(
    url: string,
    params: GetRequestBodyParam,
    showLoading?: boolean,
  ): Promise<ApiResponse<T>> {
    return httpService.get<T>({ url, params, showLoading })
  }

  /** @deprecated 请使用 httpService.postForm({ url, params, showLoading }) */
  static async postBodyRequest(
    url: string,
    params: Map<string, string>,
    showLoading?: boolean,
  ): Promise<string> {
    return httpService.postForm({ url, params, showLoading })
  }

  /** @deprecated 请使用 httpService.uploadFile(url, filePath) */
  static async postFile(url: string, filePath: string): Promise<PostFileModel> {
    return httpService.uploadFile(url, filePath)
  }

  /** @deprecated 请使用 httpService.uploadImages(...) */
  static async uploadImage(
    url: string,
    filePathList: string[],
    headParams: Map<string, string>,
    bodyParams: Map<string, string | Map<string, string>>,
    showLoading?: boolean,
  ): Promise<PostFileModel> {
    return httpService.uploadImages({ url, filePathList, headParams, bodyParams, showLoading })
  }

  /** @deprecated 请使用 httpService.downloadFile({ url, filePath, onProgress }) */
  static dowLoadFileCallBack(
    url: string,
    filePath: string,
    successCallBack?: DownLoadCallback,
    failureCallBack?: DownLoadErrorCallback,
  ): void {
    httpService.downloadFile({
      url,
      filePath,
      onProgress: (m) => { if (successCallBack?.onResult) successCallBack.onResult(m) }
    }).then((m) => {
      if (successCallBack?.onResult) successCallBack.onResult(m)
    }).catch((err: Error) => {
      if (failureCallBack?.onError) failureCallBack.onError(err.message)
    })
  }
}
