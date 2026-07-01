import {
  AxiosHttpRequest,
  AxiosResponse,
  AxiosError,
  AxiosHeaders,
  FileUploadConfig,
  UploadFile,
  HttpPromise,
  AxiosRequestHeaders
} from '@nutpi/axios';
import axios, {
  AxiosProgressEvent,
  InternalAxiosRequestConfig,
  AxiosInstance,
  FormData
} from '@ohos/axios';
import fs from '@ohos.file.fs';
import { AppUtil, DateUtil, DATE_FORMAT1 } from '@pura/harmony-utils';
import { i18n } from '@kit.LocalizationKit';

import CommonReqConstants from '../common/constants/CommonReqConstants';
import { userCookie, userTenantId } from '../common/tool/PreferenceMgrTool';
import WinLog from './WinLog';
import { TimeUtils } from './TimeUtils';

// ==================== 类型定义 ====================
export type CommonType =
  | number
    | string
    | boolean
    | Array<number>
    | Array<string>
    | Array<boolean>
    | object
    | ArrayBuffer;

interface LXInterceptorHooks {
  requestInterceptor?: (config: LXHttpRequestConfig) => Promise<LXHttpRequestConfig>;
  requestInterceptorCatch?: (error: BusinessError) => BusinessError;
  responseInterceptor?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: BusinessError) => BusinessError;
}

export interface LXHttpRequestConfig extends InternalAxiosRequestConfig {
  showLoading?: boolean;
  checkResultCode?: boolean;
  checkLoginState?: boolean;
  needJumpToLogin?: boolean;
  interceptorHooks?: LXInterceptorHooks;
}

// ==================== 核心请求类 ====================
export class LXAxiosHttpRequest {
  private readonly config: LXHttpRequestConfig;
  private readonly interceptorHooks?: LXInterceptorHooks;
  private readonly instance: AxiosInstance;

  constructor(options: LXHttpRequestConfig) {
    this.config = options;
    this.interceptorHooks = options.interceptorHooks;
    this.instance = axios.create(options);
    this.setupInterceptors();
  }

  private setupInterceptors(): void {
    this.instance.interceptors.request.use(
      this.interceptorHooks?.requestInterceptor,
      this.interceptorHooks?.requestInterceptorCatch
    );
    this.instance.interceptors.response.use(
      this.interceptorHooks?.responseInterceptor,
      this.interceptorHooks?.responseInterceptorCatch
    );
  }
  // 基础请求
  public request<T = CommonType>(config: LXHttpRequestConfig): Promise<T> {
    WinLog.info('[请求参数]' + JSON.stringify(config));
    return new Promise<T>((resolve, reject) => {
      this.instance.request<CommonType, T>(config)
        .then(resolve)
        .catch(reject);
    });
  }

  // GET 请求
  public get<T = CommonType>(
    url: string,
    config?: LXHttpRequestConfig
  ): Promise<T> {
    const requestConfig: LXHttpRequestConfig = config ?? { headers: new AxiosHeaders() };
    requestConfig.method = 'GET';
    requestConfig.url = url;
    return this.request<T>(requestConfig);
  }

  // POST 请求
  public post<T = CommonType>(
    url: string,
    data?: CommonType,
    config?: LXHttpRequestConfig
  ): Promise<T> {
    const requestConfig: LXHttpRequestConfig = config ?? { headers: new AxiosHeaders() };
    requestConfig.method = 'POST';
    requestConfig.url = url;
    requestConfig.data = data;
    return this.request<T>(requestConfig);
  }
  // ==================== 上传方法 ====================
  // 上传日志
  public uploadLogFile(url: string, path: string, logType: string): Promise<string> {
    return new Promise<string>(async (resolve, reject) => {
      try {
        const buffer = await this.fileToBuffer(path);
        const formData = new FormData();
        formData.append('winlog', buffer, { filename: 'winchannel.zip' });
        formData.append('mobileUploadDate', DateUtil.getTodayStr(DATE_FORMAT1));
        formData.append('logType', logType);

        const headers = this.createCommonHeaders();
        headers.set('Content-Type', 'application/octet-stream');

        const res:AxiosResponse = await axios.post(url, formData, {
          context: AppUtil.getContext(),
          headers,
          onUploadProgress: this.handleUploadProgress
        });
        resolve(JSON.stringify(res.data));
      } catch (err) {
        WinLog.error('[日志上传失败]'+ JSON.stringify(err));
        reject(JSON.stringify(err));
      }
    });
  }
  // 批量上传图片
  public uploadImages(url: string, paths: string[]): Promise<string> {
    return new Promise<string>(async (resolve, reject) => {
      try {
        const formData = new FormData();
        for (const path of paths) {
          const buffer = await this.fileToBuffer(path);
          const timeNumber = TimeUtils.getCurrentTime();
          const name = path.split('/').pop() || 'unknown.jpg';
          formData.append('file', buffer, { filename: name, type: 'image/jpg' });
        }

        const headers = this.createCommonHeaders();
        headers.set('Content-Type', 'multipart/form-data');
        headers.set('extension', 'JPEG');

        const res:AxiosResponse = await axios.post(url, formData, {
          context: AppUtil.getContext(),
          headers,
          onUploadProgress: this.handleUploadProgress
        });
        resolve(JSON.stringify(res.data));
      } catch (err) {
        WinLog.error('[图片上传失败]'+ JSON.stringify(err));
        reject(JSON.stringify(err));
      }
    });
  }
  // URI上传
  public uploadImageByUri(url: string, uri: string): Promise<string> {
    return new Promise<string>(async (resolve, reject) => {
      try {
        const formData = new FormData();
        const name = uri.split('/').pop() || 'unknown.jpg';
        formData.append('file', `internal://cache${uri}`, { filename: name, type: 'image/jpg' });

        const headers = this.createCommonHeaders();
        headers.set('Content-Type', 'multipart/form-data');

        const res:AxiosResponse = await axios.post(url, formData, {
          context: AppUtil.getContext(),
          headers,
          onUploadProgress: this.handleUploadProgress
        });
        resolve(JSON.stringify(res.data));
      } catch (err) {
        WinLog.error('[URI上传失败]'+ JSON.stringify(err));
        reject(JSON.stringify(err));
      }
    });
  }

  // ==================== 私有工具 ====================
  private fileToBuffer(path: string): ArrayBuffer {
    const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
    const stat = fs.lstatSync(path);
    const buffer = new ArrayBuffer(stat.size);
    fs.readSync(file.fd, buffer);
    fs.closeSync(file.fd);
    return buffer;
  }

  private createCommonHeaders(): AxiosHeaders {
    const headers = new AxiosHeaders();
    headers.set('tenantId', userTenantId());
    headers.set('Token-Cloud', userCookie());
    headers.set('Accept-Language', i18n.System.getSystemLanguage());
    headers.set('connection', 'keep-alive');
    headers.set('Charset', 'UTF-8');
    return headers;
  }

  private handleUploadProgress(e: AxiosProgressEvent): void {
    const percent = e.total ? Math.ceil((e.loaded / e.total) * 100) : 0;
    WinLog.info(`[上传进度] ${percent}%`);
  }
}

// ==================== 实例创建（大厂标准） ====================
 const lxHttpClient = new LXAxiosHttpRequest({
  baseURL: CommonReqConstants.Base_Url,
  timeout: 60 * 1000,
  checkResultCode: false,
  headers: { 'Content-Type': 'application/json' } as AxiosRequestHeaders,
  interceptorHooks: {
    requestInterceptor: async (config:LXHttpRequestConfig) => {
      const cookie = userCookie() || '';
      const tenantId = userTenantId() || '';
      config.headers?.set('tenantId', tenantId);
      config.headers?.set('Token-Cloud', cookie);
      config.showLoading && WinLog.info('[加载] 显示加载框');
      return config;
    },
    requestInterceptorCatch: (err:BusinessError) => {
      errorHandler(err);
      return err;
    },
    responseInterceptor: (res: AxiosResponse) => {
      if (res.status === 200 && (res.data.code === 0 || res.data.code === '0') ) return res;
      errorHandle(res);
      return Promise.reject(res);
    },
    responseInterceptorCatch: (err:BusinessError) => {
      errorHandler(err);
      return err;
    }
  }
});

// ==================== 错误处理 ====================
function errorHandle(res: AxiosResponse): void {
  const map: Record<number, string> = { 100401: '未登录或者登录过期', 403: '登录过期', 404: '接口不存在' };
  WinLog.error(`[业务错误] ${res.data.code}: ${map[res.data.code] || '未知错误'}`);
}

function errorHandler(err: BusinessError): void {
  if (err instanceof AxiosError && err.response) {
    WinLog.error(`[HTTP错误] ${err.response.status}`);
  }
}

// ==================== 最终导出：整个项目只用这一个！ ====================
export {
  HttpPromise,
  FileUploadConfig,
  UploadFile,
  lxHttpClient
};