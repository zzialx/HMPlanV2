import axios, {
  AxiosError,
  AxiosResponse,
  AxiosProgressEvent,
  InternalAxiosRequestConfig,
  AxiosInstance,
  AxiosRequestHeaders,
  FormData
} from '@ohos/axios'
import { JSON, util } from '@kit.ArkTS';
import { AES, AppUtil, CryptoHelper, CryptoUtil } from '@pura/harmony-utils';
import WinLog from './WinLog';
import CommonRequestConstants from '../common/constants/CommonRequestConstants';
import { secretKey } from './SecretKey';
import { ZlibUtils } from '../common/utils/ZlibUtils';

// ============================================================
// 类型定义
// ============================================================

/** 通用数据类型 */
export type CommonType = number | string | boolean | Array<number> | Array<string> | Array<boolean> | object | Object | ArrayBuffer

interface InterceptorHooks {
  requestInterceptor?: (config: HttpRequestConfig) => Promise<HttpRequestConfig>;
  requestInterceptorCatch?: (error: CommonType) => CommonType;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: CommonType) => CommonType;
}

export interface HttpRequestConfig extends InternalAxiosRequestConfig {
  showLoading?: boolean;
  checkResultCode?: boolean;
  checkLoginState?: boolean;
  needJumpToLogin?: boolean;
  interceptorHooks?: InterceptorHooks;
}

// ============================================================
// Axios 实例封装
// ============================================================

export class AxiosHttpRequest {
  config: HttpRequestConfig;
  interceptorHooks?: InterceptorHooks;
  instance: AxiosInstance;

  constructor(options: HttpRequestConfig) {
    this.config = options;
    this.interceptorHooks = options.interceptorHooks;
    this.instance = axios.create(options);
    this.setupInterceptor()
  }

  setupInterceptor(): void {
    this.instance.interceptors.request.use(
      this.interceptorHooks?.requestInterceptor,
      this.interceptorHooks?.requestInterceptorCatch,
    );
    this.instance.interceptors.response.use(
      this.interceptorHooks?.responseInterceptor,
      this.interceptorHooks?.responseInterceptorCatch,
    );
  }

  // ---- 核心 HTTP 方法 ----

  /** 通用请求 */
  request<T = CommonType>(config: HttpRequestConfig): Promise<T> {
    WinLog.debug('request params:' + JSON.stringify(config))
    return this.instance.request(config) as Promise<T>
  }

  /** Post 内部公共方法 */
  private async postWithConfig<T = CommonType>(
    config: HttpRequestConfig | undefined,
    responseHandler: (res: AxiosResponse<string>) => string
  ): Promise<string> {
    const res = await this.instance.request({
      url: config?.url,
      method: CommonRequestConstants.Request_Method,
      data: config?.data,
      headers: config?.headers,
    }) as AxiosResponse<string,T>
    return responseHandler(res)
  }

  /** Post 请求 — 返回响应体 data */
  asyncPost<T = CommonType>(config?: HttpRequestConfig): Promise<string> {
    return this.postWithConfig<T>(config, (res: AxiosResponse<string>): string => {
      return JSON.stringify(res['data'])
    })
  }

  /** Get 请求 — 返回响应体 data，解析逻辑与 post 保持一致 */
  async asyncGet<T = CommonType>(config?: HttpRequestConfig): Promise<string> {
    const res = await this.instance.request({
      url: config?.url,
      method: 'get',
      params: config?.params,
      headers: config?.headers,
    }) as AxiosResponse<string, T>
    const resData = res.data;
    //需要先 AES128解密，在 unzip解压
    const smyKeyBase64Str = secretKey();
    // CryptoUtil.getConvertSymKey('AES256', smyKeyBase64Str, 'hex').then((key)=>{
    //   WinLog.info('---->' + JSON.stringify(key));
    // }).catch((error:BusinessError)=>{
    //   WinLog.error('---->' + JSON.stringify(error));
    // })
    let symKey = CryptoUtil.getConvertSymKeySync('AES256', smyKeyBase64Str, 'hex');
    let dataBlob = CryptoHelper.strToDataBlob(resData, 'hex'); //待解密数据
    const decryptData = AES.decryptECBSync(dataBlob,symKey)
    // //解压
    const resultData = ZlibUtils.decompressBuffer(decryptData.data,decryptData.data.length);
    return JSON.stringify(res['data'])
  }

  /** Post 请求 — 返回响应头 set-cookie */
  asyncPostResHeaders<T = CommonType>(config?: HttpRequestConfig): Promise<string> {
    return this.postWithConfig<T>(config, (res: AxiosResponse<string>): string => {
      WinLog.debug(`cookie------->${res.headers['set-cookie']}`)
      if (res.headers) {
        return JSON.stringify(res.headers['set-cookie'])
      }
      return ''
    })
  }

  /** Form URL-encoded 请求（获取 cookie） */
  async asyncPostBody(config?: HttpRequestConfig, bodyParams?: string): Promise<string> {
    if (!bodyParams || bodyParams.length === 0) {
      throw new Error('asyncPostBody: bodyParams is required')
    }
    let textEncoder = new util.TextEncoder('utf-8')
    let encodeResult = textEncoder.encode(bodyParams)
    if (config) {
      config.data = encodeResult
    }
    const res = await this.instance.post(
      CommonRequestConstants.Base_Url_Cookie,
      config?.data,
      {
        headers: {
          'Accept-Language': "zh-Hans-CN;q=1, en-CN;q=0.9, zh-Hant-CN;q=0.8",
          'Content-Type': "application/x-www-form-urlencoded",
          'User-Agent': "WinSFA/2.6 (iPhone; iOS 12.3.1; Scale/2.00)",
        }
      }
    ) as AxiosResponse<string, Object>
    WinLog.debug(`asyncPostBody response------->${res}`)
    WinLog.debug(`cookie------->${res.headers['set-cookie']}`)
    if (res.headers) {
      return JSON.stringify(res.headers['set-cookie'])
    }
    throw new Error('asyncPostBody: no response headers')
  }

  // ---- 文件传输原语（不含文件 I/O，不含业务模型） ----

  /**
   * 上传 multipart/form-data
   * @param url      上传地址
   * @param formData 已构建好的 FormData（调用方负责文件 I/O）
   * @param data     附加 JSON 参数（混入 multipart 请求体）
   * @param headers  请求头
   * @returns 响应体原始字符串
   */
  upload(url: string, formData: FormData, config?: HttpRequestConfig): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      this.instance.post(url, formData, {
          context: AppUtil.getContext(),
          data: config?.data,
          headers: config?.headers,
          onUploadProgress: (progressEvent: AxiosProgressEvent): void => {
            WinLog.info('文件上传进度：')
            WinLog.info(progressEvent && progressEvent.loaded && progressEvent.total ? Math.ceil(progressEvent.loaded / progressEvent.total * 100) + '%' : '0%');
          },
      }).then((res: AxiosResponse) => {
        resolve(JSON.stringify(res.data));
      }).catch((error: AxiosError) => {
        reject("error:" + JSON.stringify(error));
      })
    })
  }

  /**
   * 下载文件到本地路径
   * @param url       下载地址
   * @param filePath  保存路径
   * @param onProgress 进度回调 (loaded, total)
   * @param headers   请求头
   * @returns 响应体原始字符串
   */
  download(
    url: string,
    filePath: string,
    onProgress?: (loaded: number, total: number) => void,
    headers?: AxiosRequestHeaders
  ): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      this.instance.request({
        url: url,
        method: 'get',
        context: AppUtil.getContext(),
        filePath: filePath,
        headers: headers,
        onDownloadProgress: onProgress ? (e: AxiosProgressEvent): void => {
          onProgress(e.loaded, e.total)
        } : undefined,
      }).then((res: AxiosResponse<string>) => {
        resolve(JSON.stringify(res.data));
      }).catch((error: AxiosError) => {
        reject(JSON.stringify(error));
      })
    })
  }
}

// ============================================================
// 默认客户端单例
// ============================================================

const axiosClient = new AxiosHttpRequest({
  baseURL: CommonRequestConstants.Base_Url_Test,
  timeout: CommonRequestConstants.TimeOut,
  checkResultCode: false,
  headers: {
    'Content-Type': 'application/octet-stream',
  } as AxiosRequestHeaders,
  interceptorHooks: {
    requestInterceptor: async (config: HttpRequestConfig) => {
      WinLog.info('request interceptor config------>' + JSON.stringify(config))
      if (config.showLoading) {
        WinLog.debug('显示加载框');
      }
      return config;
    },
    requestInterceptorCatch: (err) => {
      return err;
    },
    responseInterceptor: (response: AxiosResponse) => {
      WinLog.info('拦截器响应结果-----')
      return Promise.resolve(response);
    },
    responseInterceptorCatch: (error) => {
      errorHandler(error);
      return Promise.reject(error);
    },
  }
});
export default axiosClient;

// ============================================================
// 全局错误处理
// ============================================================

export function errorHandler(error: CommonType) {
  if (error instanceof AxiosError) {
    switch (error.status) {
      case 401:
        WinLog.warn('请求未授权(401)，需要重新登录');
        break;
      case 403:
        WinLog.warn('登录已过期(403)，请重新登录');
        break;
      case 404:
        WinLog.warn('请求的资源不存在(404)');
        break;
      default:
        WinLog.error(`请求失败(${error.status || 'unknown'})：${error.message || ''}`);
    }
  }
}
