import { DateUtil, FileUtil } from "@pura/harmony-utils";
import { CommonFileConstants } from "../common/constants/CommonFileConstants";
import WinLog from "./WinLog";
import { UploadFile } from "./AxiosClient";
import { BusinessError, zlib } from "@kit.BasicServicesKit";
import { LXPostFileModel } from "../common/bean/LXPostFileResp";
import { uploadResource } from "../common/api/uploadFileApi";

/**
 * 文件工具类
 * 统一处理：日志目录初始化、日志备份、日志压缩、日志上传
 */
export class WinFileUtils {

  /**
   * 1. 初始化日志目录
   * 先尝试删除重建，异常时兜底创建
   */
  static initLogFile(): void {
    WinLog.info("[WinFileUtils] 初始化上传日志目录");

    try {
      // 日志上传相关目录
      FileUtil.rmdirSync(CommonFileConstants.TempUploadLogDir);
      FileUtil.mkdirSync(CommonFileConstants.TempUploadLogDir);

      FileUtil.rmdirSync(CommonFileConstants.UploadLogDir);
      FileUtil.mkdirSync(CommonFileConstants.UploadLogDir);

      // 图片缓存目录
      FileUtil.rmdirSync(CommonFileConstants.PhotoCachePath);
      FileUtil.mkdirSync(CommonFileConstants.PhotoCachePath);

    } catch (err) {
      // 异常兜底创建目录
      FileUtil.mkdirSync(CommonFileConstants.TempUploadLogDir);
      FileUtil.mkdirSync(CommonFileConstants.UploadLogDir);
      FileUtil.mkdirSync(CommonFileConstants.PhotoCachePath);

      WinLog.error(`[WinFileUtils] initLogFile err: ${(err as Error)?.message}`);
    }
  }

  /**
   * 2. 备份日志文件
   * 遍历日志目录，将 .log 文件重命名并拷贝到待上传目录
   */
  static backupLogFile(): void {
    WinLog.info("[WinFileUtils] 开始备份日志");

    const filenames: string[] = FileUtil.listFileSync(CommonFileConstants.winLogDir);

    for (let i = 0; i < filenames.length; i++) {
      const filename = filenames[i];
      WinLog.info(`[WinFileUtils] 日志文件：${filename}`);

      // 只处理 .log 文件
      if (filename.includes(".log")) {
        const logFileNames = filename.split(".");
        let newFileName = "";

        // 规则：长度 3 使用时间戳命名，否则使用当前时间
        if (logFileNames.length === 3) {
          newFileName = `${DateUtil.getFormatDateStr(logFileNames[2], "yyyy-MM-dd HH-mm-ss")}.${logFileNames[1]}`;
        } else {
          newFileName = `${DateUtil.getFormatDateStr(new Date(), "yyyy-MM-dd HH-mm-ss")}.${logFileNames[1]}`;
        }

        WinLog.info(`[WinFileUtils] 新文件名：${newFileName}`);

        // 拷贝到待上传目录
        const sourcePath = `${CommonFileConstants.winLogDir}/${filename}`;
        const targetPath = `${CommonFileConstants.TempUploadLogDir}/${newFileName}`;
        FileUtil.copyFileSync(sourcePath, targetPath);
      }
    }
  }

  /**
   * 3. 上传日志文件（压缩 + 上传）
   */
  public static async uploadLogFile(): Promise<void> {
    WinLog.info("[WinFileUtils] 开始上传日志文件");

    const filesPaths: string = FileUtil.getFilesDirPath("tempupload");
    const uploadZipPath: string = FileUtil.getFilesDirPath("uploadlog", "upload.zip");

    // 压缩配置
    const options: zlib.Options = {
      level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION,
      memLevel: zlib.MemLevel.MEM_LEVEL_DEFAULT,
      strategy: zlib.CompressStrategy.COMPRESS_STRATEGY_DEFAULT_STRATEGY
    };

    // 压缩文件
    zlib.compressFile(filesPaths, uploadZipPath, options)
      .then(() => {
        WinLog.info(`[WinFileUtils] 压缩成功：${uploadZipPath}`);
        WinFileUtils.uploadFile(uploadZipPath);
      })
      .catch((error: BusinessError) => {
        WinLog.error(`[WinFileUtils] 压缩失败：${JSON.stringify(error)}`);
      });
  }

  /**
   * 执行日志上传
   * @param path 压缩包路径
   */
  private static async uploadFile(path: string): Promise<void> {
    WinLog.debug(`[WinFileUtils] 压缩包路径：${path}`);

    const file: UploadFile = {
      uri: path,
      fileName: "upload.zip",
      mimeType: "zip"
    };
    const res = await uploadResource('log',file,'1')
    // uploadLogMine(file, "1")
    //   .then((res:LXPostFileModel) => {
    //     WinLog.info(`[WinFileUtils] 上传日志成功：${JSON.stringify(res)}`);
    //   })
    //   .catch((error:Error) => {
    //     WinLog.error(`[WinFileUtils] 上传日志失败：${error}`);
    //   });
  }
}