import { MD5 } from '@pura/harmony-utils'

// ============================================================
// 常量 — 与 OC WCSDK 中 InitStreetCode / InitHttpCode 一致
// ============================================================

const InitStreetCode: string =
  '8F, Block E, Dazhongsi Zhongkun Plaza, No. A18 West Beisanhuan Road, Haidian District, Beijing'
const InitHttpCode: string = 'http://www.winchannel.net'

// ============================================================
// 工具函数
// ============================================================

/**
 * Hex 字符串 → Uint8Array（原始字节）
 * "a1b2" → Uint8Array[0xa1, 0xb2]
 */
function hexToBytes(hex: string): Uint8Array {
  const len = hex.length / 2
  const bytes = new Uint8Array(len)
  for (let i = 0; i < len; i++) {
    bytes[i] = parseInt(hex.substring(i * 2, i * 2 + 2), 16)
  }
  return bytes
}

// ============================================================
// 钥匙串生成
// ============================================================

/**
 * 生成解密钥匙串，与 OC secretKey 输出完全一致。
 *
 * 算法：
 *   key = MD5(InitStreetCode 的 UTF-8) || MD5(salt ?? InitHttpCode 的 UTF-8)
 *   → 两个 16 字节 MD5 摘要拼接 → 共 32 字节
 *
 * @param salt 可选盐值，非空时替换 InitHttpCode
 * @returns 32 字节 Uint8Array
 */
export function secretKey(salt?: string): Uint8Array {
  // firstPart = MD5(InitStreetCode)
  const firstHex: string = MD5.digestSync(InitStreetCode, 'hex')
  const firstBytes: Uint8Array = hexToBytes(firstHex) // 16 bytes

  // secondPart = MD5(salt ?? InitHttpCode)
  const secondSource: string = (salt && salt.length > 0) ? salt : InitHttpCode
  const secondHex: string = MD5.digestSync(secondSource, 'hex')
  const secondBytes: Uint8Array = hexToBytes(secondHex) // 16 bytes

  // code = [firstBytes appendData:secondBytes]
  const result = new Uint8Array(32)
  result.set(firstBytes, 0)
  result.set(secondBytes, 16)
  return result
}
