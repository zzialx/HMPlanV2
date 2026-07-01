import { AppUtil } from "@pura/harmony-utils";

let context = AppUtil.getContext();
export class CommonFileConstants {
  /**
   * 待上传文件存放目录.
   */
  static readonly TempUploadLogDir: string = context.cacheDir + '/tempupload'
  /**
   * 待上传压缩包存放目录.
   */
  static readonly UploadLogDir:string = context.cacheDir + '/uploadlog'
  /**
   * 日志存放目录.
   */
  static readonly winLogDir:string = context.filesDir
  /**
   * 日志存放路径.
   */
  static readonly winLogPath: string = context.filesDir + '/Wlog.log'

  /*
   * 文件下载目录
   * **/
  static readonly DownDirPath: string = context.filesDir + '/downfile'

}