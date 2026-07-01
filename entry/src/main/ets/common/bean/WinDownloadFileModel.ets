import { relationalStore } from "@kit.ArkData";

export class WinDownloadFileModel{
  private _fileId: string = '';

  public set fileId(value: string) {
    this._fileId = value;
  }

  public get fileId(): string {
    return this._fileId;
  }
  private _fileName: string = '';

  public set fileName(value: string) {
    this._fileName = value;
  }

  public get fileName(): string {
    return this._fileName;
  }
  private _fileUrl: string = '';

  public set fileUrl(value: string) {
    this._fileUrl = value;
  }

  public get fileUrl(): string {
    return this._fileUrl;
  }
  private _fileType: string = '';

  public set fileType(value: string) {
    this._fileType = value;
  }

  public get fileType(): string {
    return this._fileType;
  }

  private _fileSavePath: string = '';

  public set fileSavePath(value: string) {
    this._fileSavePath = value;
  }

  public get fileSavePath(): string {
    return this._fileSavePath;
  }
  //下载状态1未下载 2正在下载，3下载完成
  private _fileDownLoadStatus: string = '';

  public set fileDownLoadStatus(value: string) {
    this._fileDownLoadStatus = value;
  }

  public get fileDownLoadStatus(): string {
    return this._fileDownLoadStatus;
  }

  private _fileLength: number = 0;

  public set fileLength(value: number) {
    this._fileLength = value;
  }

  public get fileLength(): number {
    return this._fileLength;
  }
  private _fileDownLoadSize: number = 0;

  public set fileDownLoadSize(value: number) {
    this._fileDownLoadSize = value;
  }

  public get fileDownLoadSize(): number {
    return this._fileDownLoadSize;
  }
  fileDownBeginTime:string = ''
  fileDownEndTime:string = ''
  fileDownExpireTime:string = ''
  private _fileIcon: string = '';

  public set fileIcon(value: string) {
    this._fileIcon = value;
  }

  public get fileIcon(): string {
    return this._fileIcon;
  }

  private _fileDownProgress: number = 0;

  public set fileDownProgress(value: number) {
    this._fileDownProgress = value;
  }

  public get fileDownProgress(): number {
    return this._fileDownProgress;
  }
  constructor(resultSet?: relationalStore.ResultSet) {
    if (resultSet) {
      this._fileId =  resultSet.getString(resultSet.getColumnIndex('file_id'));
      this._fileName =  resultSet.getString(resultSet.getColumnIndex('file_name'));
      this._fileUrl =  resultSet.getString(resultSet.getColumnIndex('file_url'));
      this._fileType =  resultSet.getString(resultSet.getColumnIndex('file_type'));
      this._fileSavePath =  resultSet.getString(resultSet.getColumnIndex('file_save_path'));
      this._fileDownLoadStatus =  resultSet.getString(resultSet.getColumnIndex('file_download_status'));
      this._fileLength =  resultSet.getLong(resultSet.getColumnIndex('file_length'));
      this._fileDownLoadSize = resultSet.getLong(resultSet.getColumnIndex('file_download_size'));
    }
  }
}
export class FileModel {



}
export interface DownLoadCallback {
  /**
   * 下载回调
   * @param popInfo
   */
  onResult?: (downLoadingInfo: WinDownloadFileModel) => void;
}
export interface DownLoadErrorCallback {
  onError?: (error: string) => void;
}