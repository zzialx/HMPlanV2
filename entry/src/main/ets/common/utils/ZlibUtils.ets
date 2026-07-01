import { zlib } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import WinLog from '../../utils/WinLog';
export class ZlibUtils {
   static async inflateFile(src: fs.File, dest: fs.File) {
    let status: zlib.ReturnStatus = zlib.ReturnStatus.OK;
    let strm: zlib.ZStream = {};
    const BUFLEN = 4096;
    let inBuf = new ArrayBuffer(BUFLEN);
    let outBuf = new ArrayBuffer(BUFLEN);

    // 同步创建压缩对象
    let zip = zlib.createZipSync();

    // 初始化解压流
    let initStatus = zip.inflateInit(strm);
    console.info('初始化: ' + (await initStatus).valueOf());

    do {
      let readLen = fs.readSync(src.fd, inBuf);
      if (readLen == 0) break;

      strm.availableIn = readLen;
      strm.nextIn = inBuf;

      do {
        strm.availableOut = BUFLEN;
        strm.nextOut = outBuf;

        let inflateStatus = zip.inflate(strm, zlib.CompressFlushMode.NO_FLUSH);
        status = await inflateStatus;

        // 更新流状态
        let innerStrm = zip.getZStream();
        strm.availableIn = (await innerStrm).availableIn;
        strm.nextIn = (await innerStrm).nextIn;
        strm.availableOut = (await innerStrm).availableOut;
        strm.nextOut = (await innerStrm).nextOut;

        if (strm.availableOut != undefined) {
          let have = BUFLEN - strm.availableOut;
          fs.writeSync(dest.fd, outBuf, { length: have });
        }
      } while (strm.availableOut == 0);
    } while (status != zlib.ReturnStatus.STREAM_END.valueOf());

    zip.inflateEnd(strm);
  }

  // 已知解压后数据大小的场景
  static async decompressBuffer(compressedData: ArrayBuffer, originalSize: number) {
    WinLog.info(`compressedData.byteLength: ${compressedData.byteLength}`);
    WinLog.info(`originalSize: ${originalSize}`);
    // 参数校验
    if (!compressedData || compressedData.byteLength === 0) {
      WinLog.error('压缩数据为空');
      return null;
    }

    if (originalSize <= 0) {
      WinLog.error('原始大小无效');
      return null;
    }
    // ✅ 关键：确保是 ArrayBuffer 类型
    let sourceBuffer: ArrayBuffer;
    if (compressedData instanceof ArrayBuffer) {
      sourceBuffer = compressedData;
    } else {
      // Uint8Array 转 ArrayBuffer
      sourceBuffer = compressedData.buffer.slice(
        compressedData.byteOffset,
        compressedData.byteOffset + compressedData.byteLength
      );
    }
    // 同步创建 Zip 对象
    let zip = zlib.createZipSync();

    // 创建目标缓冲区
    let destBuffer = new ArrayBuffer(10000);

    try {
      // 解压缩 - 注意第三个参数是压缩数据的实际长度
      let result = await zip.uncompress(destBuffer, compressedData, compressedData.byteLength);
      WinLog.info(`解压成功，状态: ${result.status}, 解压后长度: ${result.destLen}`);

      // 如果解压后的数据小于缓冲区大小，可以截取有效部分
      if (result.destLen !== undefined && result.destLen < originalSize) {
        return destBuffer.slice(0, result.destLen);
      }
      return destBuffer;
    } catch (err) {
      WinLog.error('解压失败:' + JSON.stringify(err));
      return null;
    }
  }
}
