import { ValuesBucket } from '@kit.ArkData'
import { DatabaseManager } from '../DatabaseManager'
import CommonRequestConstants from '../../common/constants/CommonRequestConstants'
import WinLog from '../../utils/WinLog'
import { getEmpId, PreferenceMgrTool } from '../../common/tool/PreferenceMgrTool'
import { WinBaseStore } from '../../common/bean/WinBaseStore'
import CommonTableNameConstants from '../../common/constants/CommonTableNameConstants'
import { WinBaseAcvtBean } from '../../common/bean/WinBaseAcvtBean'
import { WinBaseFuncBean, WinSpecModel } from '../../common/bean/WinBaseFuncBean'
import { JSONUtil } from '@pura/harmony-utils'
import { WinBaseStoreAcvtDisBean, WinBaseStoreAcvtDisModel } from '../../common/bean/WinBaseStoreAcvtDisBean'
import { WinBaseProductBean } from '../../common/bean/WinBaseProductBean'
import { pinyin4js } from '@ohos/pinyin4js'
import { WinBaseProductDisModel } from '../../common/bean/WSBaseProductDisBean'
// import { mapToValuesBucket } from '../../common/tool/MapToValuesBuketTool'

// ============================================================
// 工具函数
// ============================================================

/** 字段值标准化：数字→字符串（保留原 JSON.parse(JSON.stringify(...), replacer) 的 replacer 逻辑） */
export function replacer(key: string, value: Object): Object {
  if (key !== '_id' && typeof value === 'number') {
    return value.toString()
  }
  if (key === 'opt' || key === 'seq') {
    return value.toString()
  }
  return value
}

/** 特殊类型序列化（funcs spec 解析用） */
function normalizeSpecField(key: string, value: Object): Object {
  if (key === 'opt' || key === 'param') {
    return JSON.stringify(value)
  }
  return value
}

/** 构建 SQL IN 子句字符串，如 "'a','b','c'" */
function buildInClause(values: string[]): string {
  let result = ''
  for (let i = 0; i < values.length; i++) {
    if (i > 0) result += ','
    result += `'${values[i]}'`
  }
  return result
}

// ============================================================
// 主入口
// ============================================================

export class ParseServerDataManager {
  static parseLoginData(context: Context, jsonData?: string) {
    WinLog.info('parseLoginData 解析数据开始')
    if (!jsonData) {
      WinLog.info('jsonData is null')
      return
    }
    const jsonDataObj: Record<string, Object> = JSON.parse(jsonData) as Record<string, Object>
    if (!jsonDataObj) {
      WinLog.info('jsonDataObj is null')
      return
    }

    WinLog.info('parseLoginData 解析节点')
    const keys = Object.keys(jsonDataObj)

    for (let i = 0; i < keys.length; i++) {
      const key = keys[i]
      if (key === 'acvt' || key.startsWith('acvt:')) {
        parseBaseAcvtData(context, jsonData, key, true)
      } else if (key === 'stores' || key.startsWith('stores:')) {
        parseBaseStoreData(context, jsonData, key)
      } else if (key === 'empid') {
        parseEmpIdData(jsonData, key)
      } else if (key === 'funcs2') {
        parseBaseFuncsData(context, jsonData, key)
      } else if (key.startsWith('acvtdis')) {
        parseAcvtDisData(context, jsonData, key)
      } else if (key.startsWith('storeacvtdis')) {
        if (key === 'storeacvtdis:visitplan') {
          parseStoreVisitPlanData(context, jsonData, key)
        } else {
          parseStoreAcvtDisData(context, jsonData, key, undefined)
        }
      } else if (key === 'prods') {
        parseBaseProductData(context, jsonData, key)
      } else if (key === 'storeproddis') {
        // parseBaseStoreProductDisData(context, jsonData, key, '')
      } else if (key === 'store_acvt') {
        parseBaseStoreAcvtData(context, jsonData, key)
      } else if (key.startsWith('dicts')) {
        parseBaseDictsData(context, jsonData, key)
      } else if (key === CommonRequestConstants.SERVER_REQUIRE) {
        parseRequestServerData(jsonData, key)
      } else if (key === 'instoreprod') {
        parseBaseInStoreProductData(context, jsonData, key)
      }
    }

    WinLog.info('parseLoginData 解析数据结束')
    processServerAcvtDisValue()
  }
}

// ============================================================
// 各节点解析函数
// ============================================================

/** 问卷数据 */
export function parseBaseAcvtData(context: Context, jsonData: string, serverNode: string, isDelete: boolean) {
  if (isDelete) {
    DatabaseManager.deleteTableDataByTabName(context,CommonTableNameConstants.BASE_ACVT)
    DatabaseManager.deleteTableDataByTabName(context, CommonTableNameConstants.BASE_ACVT_QST)
    DatabaseManager.deleteTableDataByTabName(context, CommonTableNameConstants.BASE_ACVT_QST_OPT)
  }
  const acvtList: WinBaseAcvtBean[] = JSON.parse(jsonData)[serverNode]
  if (!acvtList) {
    WinLog.info('acvt is null')
    return
  }

  const acvtBucketList: ValuesBucket[] = []
  const qstBucketList: ValuesBucket[] = []
  const optBucketList: ValuesBucket[] = []

  const ACVT_FILTER = ['empId', 'acvtId', 'acvtCode', 'acvtName', 'typ', 'isblock', 'isReq', 'ftext', 'server_node', 'acvtObj', 'publisher']
  const QST_FILTER = ['acvtId', 'acvtQstId', 'qstId', 'qstCod', 'qstName', 'qstType', 'is_req', 'readonly', 'orientation', 'mlen', 'dlen', 'mnum', 'snum', 'mc', 'ds', 'filter', 'isAcvtName', 'isSupperLocalPhoto', 'defaultValue', 'acvtNestedId', 'ishidden', 'Js', 'displayMode', 'hideQstName', 'isCoverNewId', 'memo', 'parentQstId']
  const OPT_FILTER = ['acvtQstId', 'qstId', 'optId', 'optName']

  for (let i = 0; i < acvtList.length; i++) {
    const item = acvtList[i]
    item.server_node = serverNode
    acvtBucketList.push(JSON.parse(JSON.stringify(item, ACVT_FILTER), replacer))

    const raw: Record<string, Object> = JSON.parse(JSON.stringify(item)) as Record<string, Object>
    const qstList: Object[] = raw['qst'] as Object[]
    if (!qstList) continue

    for (let j = 0; j < qstList.length; j++) {
      const qstItem: Record<string, Object> = JSON.parse(JSON.stringify(qstList[j])) as Record<string, Object>
      qstBucketList.push(JSON.parse(JSON.stringify(qstItem, QST_FILTER), replacer))

      const optList: Object[] = qstItem['opt'] as Object[]
      if (!optList) continue

      for (let k = 0; k < optList.length; k++) {
        const optItem: Record<string, Object> = JSON.parse(JSON.stringify(optList[k])) as Record<string, Object>
        optBucketList.push(JSON.parse(JSON.stringify(optItem, OPT_FILTER), replacer))
      }
    }
  }

  DatabaseManager.batchInsertTableData(CommonTableNameConstants.BASE_ACVT, acvtBucketList)
  DatabaseManager.batchInsertTableData(CommonTableNameConstants.BASE_ACVT_QST, qstBucketList)
  DatabaseManager.batchInsertTableData(CommonTableNameConstants.BASE_ACVT_QST_OPT, optBucketList)
}

/** 门店数据 */
function parseBaseStoreData(context: Context, jsonData: string, serverNode: string) {
  DatabaseManager.deleteTableDataByTabName(context, CommonTableNameConstants.BASE_TABLE, serverNode)
  const storesList: WinBaseStore[] = JSON.parse(jsonData)[serverNode]
  if (!storesList) {
    WinLog.error('stores list is null')
    return
  }
  const STORE_FILTER = ['id', 'name', 'empId', 'cod', 'lat', 'lon', 'addr', 'styp', 'sort', 'server_node',
    'sv', 'acvt_genId', 'last_date', 'search_code', 'drId'];
  const list: ValuesBucket[] = []
  for (let i = 0; i < storesList.length; i++) {
    const item = storesList[i]
    item.server_node = serverNode
    list.push(JSON.parse(JSON.stringify(item, STORE_FILTER), replacer))
  }
  DatabaseManager.batchInsertTableData(CommonTableNameConstants.BASE_TABLE,list)
}

/** 菜单数据 */
function parseBaseFuncsData(context: Context, jsonData: string, serverNode: string) {
  DatabaseManager.deleteTableDataByTabName(context, CommonTableNameConstants.BASE_FUNCS)
  const funcBeanList: WinBaseFuncBean[] = JSON.parse(jsonData)[serverNode]
  if (!funcBeanList) {
    WinLog.error('funcBeanList is null')
    return
  }

  for (let i = 0; i < funcBeanList.length; i++) {
    const element = funcBeanList[i]
    if (element.spec) {
      element.spec = element.spec.replace(/[\r\n\t\s]/g, '')
      if (JSONUtil.isJSONStr(element.spec)) {
        const sepcModel: WinSpecModel = JSON.parse(element.spec, normalizeSpecField)
        WinLog.debug('host_config打印: ' + JSON.stringify(sepcModel))
        element.ds = sepcModel.ds
        element.opt = sepcModel.opt
        element.nullvalue = sepcModel.nullvalue
        element.required = sepcModel.required
        element.filter = sepcModel.filter
        element.isAcvtList = sepcModel.isAcvtList
        element.sendRequest = sepcModel.sendRequest
        element.icon = sepcModel.icon
        element.param = sepcModel.param
        element.dateTyp = sepcModel.dateTyp
        element.lockCol = sepcModel.lockCol
        element.submenu = sepcModel.submenu
        element.styp = sepcModel.styp
        element.pageTag = sepcModel.pageTag
      }
      element.spec = undefined
    }
  }

  const FUNCS_FILTER = ['pk', 'fk', 'userId', 'fc', 'fv', 'name', 'required', 'opt', 'ds', 'filter', 'param', 'styp', 'isAcvtList', 'readonly', 'sort', 'levelCode', 'submenu', 'redis', 'icon', 'subCode',
    'script', 'menuType', 'pageTag', 'nullvalue', 'dateTyp']
  const list: ValuesBucket[] = []
  for (let i = 0; i < funcBeanList.length; i++) {
    list.push(JSON.parse(JSON.stringify(funcBeanList[i], FUNCS_FILTER), replacer))
  }
  DatabaseManager.batchInsertTableData(CommonTableNameConstants.BASE_FUNCS, list)
}

/** 拜访计划表 */
// export function parseRoutePlanTableData(context: Context, routePlanList: Stores[], serverNode: string) {
  // DatabaseManager.deleteTableDataByTabName(context, 'base_plan_route', serverNode)
  // if (!routePlanList) {
  //   WinLog.info('base_plan_route is null')
  //   return
  // }
  // try {
  //   const ROUTE_FILTER = ['storeId', 'type', 'routeId', 'sort', 'state', 'empId', 'bizDate', 'server_node']
  //   const list: ValuesBucket[] = []
  //   for (let i = 0; i < routePlanList.length; i++) {
  //     list.push(JSON.parse(JSON.stringify(routePlanList[i], ROUTE_FILTER), replacer))
  //   }
  //   DatabaseManager.batchInsertTableData(context, 'base_plan_route', list)
  // } catch (e) {
  //   WinLog.info('base_plan_route insert error' + e)
  // }
// }

/** 问卷回显（关联门店） */
export function parseStoreAcvtDisData(context: Context, jsonData: string, serverNode: string, storeId: string | undefined) {
  try {
    const storeAcvtDisList: WinBaseStoreAcvtDisModel[] = JSON.parse(jsonData)[serverNode]
    const insertList: WinBaseStoreAcvtDisBean[] = []
    const genIdList: string[] = []
    const storeIdList: string[] = []
    const acvtIdList: string[] = []

    for (let i = 0; i < storeAcvtDisList.length; i++) {
      const item = storeAcvtDisList[i]
      const genId: string = item.gen_id as string
      if (!item.p || !item.p.includes(',')) continue

      const propertyList = item.p.split(',')
      const sid = propertyList.length >= 3 ? propertyList[0] : ''
      const acvtId = propertyList.length >= 3 ? propertyList[1] : ''
      const acvtQstId = propertyList.length >= 3 ? propertyList[2] : ''
      const acvtQstValue = propertyList.length >= 4
        ? propertyList.slice(3).join(', ')
        : ''

      if (sid !== '-1' && sid.length > 0 && !storeIdList.includes(sid)) {
        storeIdList.push(sid)
      }
      if (acvtId.length > 0 && !acvtIdList.includes(acvtId)) {
        acvtIdList.push(acvtId)
      }
      if (genId.length > 0 && !genIdList.includes(genId)) {
        genIdList.push(genId)
      }
      const empId = item.empId || getEmpId();
      const model = new WinBaseStoreAcvtDisBean(sid, acvtId, acvtQstId, acvtQstValue, genId, serverNode, empId)
      insertList.push(model)
    }

    // 构建删除 SQL
    let deleteSql = `delete from base_store_acvt_dis where server_node = '${serverNode}'`
    if (genIdList.length > 0) {
      deleteSql += ` and gen_id in (${buildInClause(genIdList)})`
    }
    if (storeIdList.length > 0) {
      deleteSql += ` and sid in (${buildInClause(storeIdList)})`
      if (acvtIdList.length > 0) {
        deleteSql += ` and acvtId in (${buildInClause(acvtIdList)})`
      }
    }

    WinLog.info('sql 删除语句：---->' + deleteSql)
    DatabaseManager.deleteTableDataBySqlStr(context, 'base_store_acvt_dis', deleteSql)

    if (insertList.length > 0) {
      const STORE_ACVT_DIS_FILTER = ['sid', 'acvtId', 'acvtQstId', 'acvt_qst_answer', 'gen_id', 'server_node', 'emp_id']
      const bucketList: ValuesBucket[] = []
      for (let i = 0; i < insertList.length; i++) {
        bucketList.push(JSON.parse(JSON.stringify(insertList[i], STORE_ACVT_DIS_FILTER), replacer))
      }
      DatabaseManager.batchInsertTableData(CommonTableNameConstants.BASE_STORE_ACVT_DIS, bucketList)
    } else {
      WinLog.error(`节点：${serverNode}无数据`)
    }
  } catch (e) {
    WinLog.info('base_store_acvt_dis insert error' + e)
  }
}

/** 问卷回显（不关联门店） */
export function parseAcvtDisData(context: Context, jsonData: string, serverNode: string) {
  try {
    const storeAcvtDisList: WinBaseStoreAcvtDisModel[] = JSON.parse(jsonData)[serverNode]
    const insertList: WinBaseStoreAcvtDisBean[] = []
    const genIdArray: string[] = []
    const storeIdArray: string[] = []

    for (let i = 0; i < storeAcvtDisList.length; i++) {
      const item = storeAcvtDisList[i]
      const genId: string = item.gen_id as string
      if (!genIdArray.includes(genId)) {
        genIdArray.push(genId)
      }
      if (item.p && item.p.includes(',')) {
        const model = buildAcvtDisModel(serverNode, item.p, genId, item.empId)
        if (model.sid && !storeIdArray.includes(model.sid) && model.sid !== '') {
          storeIdArray.push(model.sid)
        }
        if (model) {
          insertList.push(model)
        }
      }
    }

    if (genIdArray.length > 0) {
      const deleteSqlList: string[] = []
      for (let i = 0; i < genIdArray.length; i++) {
        const genId = genIdArray[i]
        if (genId && genId.length > 0) {
          deleteSqlList.push(`delete from base_store_acvt_dis where genid = ${genId}}`)
        }
      }
      DatabaseManager.batchDeleteTableDataBySqlStr('base_store_acvt_dis', deleteSqlList)
    } else if (storeIdArray.length > 0) {
      WinLog.error('问卷回显表缺失逻辑，暂未处理功能，待开发')
    } else {
      DatabaseManager.deleteTableDataByTabName(context, 'base_store_acvt_dis', 'delete from base_store_acvt_dis where')
    }

    if (insertList.length > 0) {
      const FIELDS = ['sid', 'acvtId', 'acvtQstId', 'acvt_qst_answer', 'gen_id', 'server_node', 'emp_id']
      const bucketList: ValuesBucket[] = []
      for (let i = 0; i < insertList.length; i++) {
        bucketList.push(JSON.parse(JSON.stringify(insertList[i], FIELDS), replacer))
      }
      DatabaseManager.batchInsertTableData('base_store_acvt_dis', bucketList)
    } else {
      WinLog.error(`节点：${serverNode}无数据`)
    }
  } catch (e) {
    WinLog.info('base_store_acvt_dis insert error' + e)
  }
}

/** 从 p 字符串构建 BaseStoreAcvtDis 模型 */
export function buildAcvtDisModel(serverNode: string, pStr: string, genId: string, empId?: string): WinBaseStoreAcvtDisBean {
  const propertyList = pStr.split(',')

  // storeacvtdis 节点：propertyList[0] = storeId
  if (serverNode === 'acvtdisSpestoreUpdateEcho') {
    const storeId = propertyList.length >= 3 ? propertyList[0] : ''
    const sid = storeId === '-1' ? '' : storeId
    const acvtId = propertyList.length >= 3 ? propertyList[1] : ''
    const acvtQstId = propertyList.length >= 3 ? propertyList[2] : ''
    const acvtQstValue = propertyList.length >= 4 ? propertyList.slice(3).join(', ') : ''
    return new WinBaseStoreAcvtDisBean(sid, acvtId, acvtQstId, acvtQstValue, genId, serverNode, empId)
  }

  // acvtdis 节点：propertyList[0] = acvtId
  const acvtId = propertyList[0] || ''
  const acvtQstId = propertyList[1] || ''
  const acvtQstValue = propertyList.length >= 3 ? propertyList.slice(2).join(', ') : ''
  return new WinBaseStoreAcvtDisBean('', acvtId, acvtQstId, acvtQstValue, genId, serverNode, empId)
}

/** 产品表 */
export function parseBaseProductData(context: Context, jsonData: string, serverNode: string) {
  DatabaseManager.deleteTableDataByTabName(context,CommonTableNameConstants.BASE_PRODUCT, serverNode)
  try {
    const productList: WinBaseProductBean[] = JSON.parse(jsonData)[serverNode];
    for (let i = 0; i < productList.length; i++) {
      const element: WinBaseProductBean = productList[i] as WinBaseProductBean;
      element.seq = i + 1;
      element.server_node = serverNode;
      let pinyin = '';
      let firstLetter = ''
      if (element.name!=undefined) {
         pinyin = pinyin4js.convertToPinyinString(element.name, '', pinyin4js.WITHOUT_TONE)
         firstLetter = pinyin4js.convertToPinyinString(element.name, '', pinyin4js.FIRST_LETTER)
        element.pinyin = `${pinyin},${firstLetter}`
      }
    }

    const PRODUCT_FILTER = ['id', 'name', 'cod', 'searchcod', 'pTyp', 'price', 'seq',
      'pinyin', 'brand', 'barcode', 'size', 'server_node']
    const list: ValuesBucket[] = []
    for (let i = 0; i < productList.length; i++) {
      list.push(JSON.parse(JSON.stringify(productList[i], PRODUCT_FILTER), replacer))
    }
    DatabaseManager.batchInsertTableData(CommonTableNameConstants.BASE_PRODUCT, list)
  } catch (e) {
    WinLog.info('base_product insert error' + e)
  }
}

/** 门店产品回显表 */
export function parseBaseStoreProductDisData(context: Context, jsonData: string, serverNode: string, storeId: string) {
  try {
    const SPEC_LIST = ['drid', 'pid', 'dist', 'pri', 'inv', 'aging',
      'disp', 'sdisp', 'cmpt', 'oos', 'mtd', 'ord', 'gofa', 'item1', 'item2',
      'item3', 'item4', 'item5', 'item6', 'item7', 'item8', 'item9', 'item10', 'genid']

    const originalList: WinBaseProductDisModel[] = JSON.parse(jsonData)[serverNode]
    const bucketList: ValuesBucket[] = []
    const genIdList: string[] = []

    for (let i = 0; i < originalList.length; i++) {
      const element = originalList[i]
      const pStr: string = element.p as string
      if (!pStr || pStr.length === 0) continue

      const propertyList = pStr.split(',')
      const prodDisMap = new Map<string, string>()

      for (let j = 0; j < propertyList.length; j++) {
        let columnName = j < SPEC_LIST.length ? SPEC_LIST[j] : ''
        if (columnName === 'sid' || columnName === 'drid' || columnName === 'drId') {
          columnName = 'store_id'
        } else if (columnName === 'pid') {
          columnName = 'prod_id'
        }
        prodDisMap.set(columnName, propertyList[j])
      }

      if (element.gen_id && element.gen_id.length > 0) {
        prodDisMap.set('genid', element.gen_id)
        if (!genIdList.includes(element.gen_id)) {
          genIdList.push(element.gen_id)
        }
      }
      if (serverNode && serverNode.length > 0) {
        prodDisMap.set('server_node', serverNode)
      }

      // bucketList.push(mapToValuesBucket(prodDisMap))
    }

    if (storeId && storeId.length > 0) {
      if (genIdList.length > 0) {
        const deleteSqlList: string[] = []
        for (let i = 0; i < genIdList.length; i++) {
          const genId = genIdList[i]
          if (genId && genId.length > 0) {
            deleteSqlList.push(`delete from base_store_prod_dis where genid = ${genId}} and storeId = ${storeId}}`)
          }
        }
        DatabaseManager.batchDeleteTableDataBySqlStr('base_store_prod_dis', deleteSqlList)
      } else {
        DatabaseManager.deleteTableDataBySqlStr(context, 'base_store_prod_dis',
          `delete from base_store_prod_dis where storeId = ${storeId} and server_node = ${serverNode}`)
      }
    } else {
      DatabaseManager.deleteTableDataByTabName(context, 'base_store_prod_dis', serverNode)
    }

    DatabaseManager.batchInsertTableData('base_store_prod_dis', bucketList)
  } catch (error) {
    WinLog.info('base_store_prod_dis insert error' + error)
  }
}

/** 门店拜访计划表 */
export function parseStoreVisitPlanData(context: Context, jsonData: string, serverNode: string) {
  // DatabaseManager.deleteTableDataByTabName(context, 'base_store_visitplan')
  // try {
  //   const visitPlanList: BaseStoreVisitPlanResModel[] = JSON.parse(jsonData)[serverNode]
  //   for (let i = 0; i < visitPlanList.length; i++) {
  //     const plan = visitPlanList[i]
  //     plan.store_id = plan.sId
  //     plan.biz_date = plan.next
  //     plan.seq = i
  //     plan.emp_id = plan.empId
  //   }
  //   WinLog.info('plan data ' + JSON.stringify(visitPlanList))
  //
  //   const VISIT_PLAN_FILTER = ['emp_id', 'store_id', 'biz_date', 'seq']
  //   const list: ValuesBucket[] = []
  //   for (let i = 0; i < visitPlanList.length; i++) {
  //     list.push(JSON.parse(JSON.stringify(visitPlanList[i], VISIT_PLAN_FILTER), replacer))
  //   }
  //   DatabaseManager.batchInsertTableData(context, 'base_store_visitplan', list)
  // } catch (e) {
  //   WinLog.info('base_store_visitplan insert error' + e)
  // }
}

// ---- 简单解析函数 ----

function parseEmpIdData(jsonData: string, serverNode: string) {
  const empId: string = JSON.parse(jsonData)[serverNode] as string
  PreferenceMgrTool.set('UserInfoEMPID', empId)
}

function parseRequestServerData(jsonData: string, serverNode: string) {
  const serverRequireNode: string = JSON.parse(jsonData)[serverNode] as string
  PreferenceMgrTool.set(CommonRequestConstants.SERVER_REQUIRE, JSON.stringify(serverRequireNode))
}

/** 门店与问卷关系表 */
function parseBaseStoreAcvtData(context: Context, jsonData: string, serverNode: string) {
  // const storeAcvtList: BaseStoreAcvt[] = JSON.parse(jsonData)[serverNode]
  // if (!storeAcvtList) {
  //   WinLog.info('ParseServerDataManager parseBaseStoreAcvtData base store acvt is null')
  //   return
  // }
  //
  // const STORE_ACVT_FILTER = ['id', 'sid', 'acvtId', 'uploadCount', 'hasUploadedCount', 'server_node']
  // const list: ValuesBucket[] = []
  // for (let i = 0; i < storeAcvtList.length; i++) {
  //   list.push(JSON.parse(JSON.stringify(storeAcvtList[i], STORE_ACVT_FILTER), replacer))
  // }
  // DatabaseManager.batchInsertTableData(context, 'base_store_acvt', list)
  // DatabaseManager.deleteTableDataBySqlStr(context, 'base_store_acvt',
  //   `delete from base_store_acvt where _id not in (select max(_id) from base_store_acvt group by sid, acvtId)`)
}

/** 字典项数据 */
function parseBaseDictsData(context: Context, jsonData: string, serverNode: string) {
  // DatabaseManager.deleteTableDataByTabName(context, 'base_dicts', serverNode)
  // try {
  //   const dictsList: BaseDicts[] = JSON.parse(jsonData)[serverNode]
  //   const DICTS_FILTER = ['id', 'pid', 'name', 'typ', 'dtyp', 'btyp', 'col1', 'col2', 'cod', 'dicts_sequence', 'levelCode', 'server_node', 'SEQ']
  //
  //   const list: ValuesBucket[] = []
  //   for (let i = 0; i < dictsList.length; i++) {
  //     const item = dictsList[i]
  //     item.server_node = serverNode
  //     item.pid = item.p
  //     if (!item.SEQ || item.SEQ.length === 0) {
  //       item.SEQ = i.toString()
  //     }
  //     item.dicts_sequence = item.SEQ
  //     list.push(JSON.parse(JSON.stringify(item, DICTS_FILTER), replacer))
  //   }
  //   DatabaseManager.batchInsertTableData(context, 'base_dicts', list)
  // } catch (e) {
  //   WinLog.info('base_dicts insert error' + e)
  // }
}

// ============================================================
// 运行时写入函数
// ============================================================

export async function insertVisitStoreStateTable(storeId: string, funcCode: string, status: string) {
  // try {
  //   const empId = PreferenceMgrTool.get(CommonRequestConstants.UserInfo_EMPID) as string
  //   const bizDate = PreferenceMgrTool.get(CommonRequestConstants.UserInfo_BIZDATE) as string
  //   const querySql = `select * from visit_store_status where emp_id = '${empId}' and store_id = '${storeId}' and biz_date = '${bizDate}'`
  //   const visitStoreArray = await DatabaseManager.queryVisitStoreTableDataBySqlStr('visit_store_status', querySql)
  //
  //   if (visitStoreArray.length > 0) {
  //     DatabaseManager.updateTableDataBySqlStr('visit_store_status',
  //       `update visit_store_status set status = ${status} where emp_id = '${empId}' and store_id = '${storeId}' and biz_date = '${bizDate}'`)
  //   } else {
  //     const sql = `INSERT INTO visit_store_status (emp_id,store_id,biz_date,status,func_code) VALUES ('${empId}','${storeId}','${bizDate}','${status}','${funcCode}')`
  //     WinLog.info('visit_store_status inster sql :' + sql)
  //     DatabaseManager.updateTableDataBySqlStr('visit_store_status', sql)
  //   }
  // } catch (e) {
  //   WinLog.info('visit_store_status insert error' + e)
  // }
}

// export async function insertInOutStoreTable(inOutStoreInfo: WinBaseInOutStoreModel) {
  // try {
  //   const tableName = CommonTableNameConstants.VISIT_INOUT_STORE_TABLE
  //   const empId = PreferencesManager.get(CommonRequestConstants.UserInfo_EMPID) as string
  //   const bizDate = PreferencesManager.get(CommonRequestConstants.UserInfo_BIZDATE) as string
  //   const deleteSql = `DELETE FROM ${tableName} where empId = '${empId}' and storeId = '${inOutStoreInfo.storeId}' and biz_date = '${bizDate}' and func_code = '${inOutStoreInfo.func_code}' and modulefc = '${inOutStoreInfo.modulefc}'`
  //   await DatabaseManager.updateTableDataBySqlStr(tableName, deleteSql)
  //
  //   const INOUT_FILTER = ['empId', 'storeId', 'biz_date', 'isPlan', 'inTime', 'outTime',
  //     'img_idx', 'upload_date', 'upload_flag', 'in_lon', 'in_lat', 'out_lon', 'out_lat',
  //     'func_code', 'memo1', 'visit_id', 'modulefc', 'local_image']
  //   const list: ValuesBucket[] = [JSON.parse(JSON.stringify(inOutStoreInfo, INOUT_FILTER), replacer)]
  //   DatabaseManager.batchInsertTableData(AppUtil.getContext(), tableName, list)
  // } catch (e) {
  //   WinLog.error('visit_inout_store insert error' + e)
  // }
// }

// export async function parseVisitStoreAcvtaTableData(visitStoreAcvtDataList: BaseVisitStoreAcvtDataModel[], serverNode: string, genId: string) {
//   if (!visitStoreAcvtDataList) {
//     WinLog.info('visit_store_acvt_data is null')
//     return
//   }
//   try {
//     const context = AppUtil.getContext()
//     const genIdIn = genId.split(',').map(item => `'${item}'`).join(',')
//     const deleteSql = `delete from visit_store_acvt_data where gen_id in (${genIdIn}) and server_node = '${serverNode}'`
//     WinLog.debug('delete visit_store_acvt_data sql：' + deleteSql)
//     await DatabaseManager.deleteTableDataBySqlStr(context, 'visit_store_acvt_data', deleteSql)
//
//     const VISIT_ACVT_FILTER = ['sid', 'acvtId', 'acvtQstId', 'acvt_qst_answer', 'gen_id', 'emp_id', 'biz_date', 'server_node', 'assetId']
//     const list: ValuesBucket[] = []
//     for (let i = 0; i < visitStoreAcvtDataList.length; i++) {
//       list.push(JSON.parse(JSON.stringify(visitStoreAcvtDataList[i], VISIT_ACVT_FILTER), replacer))
//     }
//     DatabaseManager.batchInsertTableData(context, 'visit_store_acvt_data', list)
//   } catch (e) {
//     WinLog.info('visit_store_acvt_data insert error' + e)
//   }
// }
//
export async function parseBaseInStoreProductData(context: Context, jsonData: string, serverNode: string) {
  // try {
  //   const tableName = 'base_in_store_prod'
  //   DatabaseManager.deleteTableDataBySqlStr(context, tableName, 'delete from base_in_store_prod where server_node is null')
  //   DatabaseManager.deleteTableDataByTabName(context, tableName, serverNode)
  //
  //   const serverDataList: BaseInStoreProdServerModel[] = JSON.parse(jsonData)[serverNode] as BaseInStoreProdServerModel[]
  //   if (!serverDataList || serverDataList.length === 0) {
  //     WinLog.error('base_in_store_prod data is null')
  //     return
  //   }
  //
  //   const firstItem = serverDataList[0]
  //   const pComponents = (firstItem.p as string).split(',')
  //
  //   const prodSpecStr = PreferencesManager.get(CommonAppDataKeyConstants.ProdSpec_Key) as string[]
  //   if (pComponents.length > prodSpecStr.length) {
  //     WinLog.error('[pArray count] > [spec count] is error')
  //     return
  //   }
  //
  //   const insertSQLs: string[] = []
  //   for (let i = 0; i < serverDataList.length; i++) {
  //     const prodItem = serverDataList[i]
  //     const pStr = prodItem.p as string
  //     const imgtypeStr: string = prodItem.imgtype as string
  //     const pValues = pStr.split(',')
  //
  //     const cols: string[] = []
  //     const vals: string[] = []
  //     for (let j = 0; j < prodSpecStr.length; j++) {
  //       const spec = prodSpecStr[j] as string
  //       if (j >= pValues.length) break
  //
  //       let col = spec.toLowerCase()
  //       if (col === 'sid' || col === 'drid') {
  //         col = 'store_id'
  //       } else if (col === 'pid') {
  //         col = 'prod_id'
  //       } else if (col === 'func_code') {
  //         col = 'funccode'
  //       }
  //       cols.push(col)
  //       vals.push(pValues[j])
  //     }
  //
  //     let sql = 'INSERT INTO base_in_store_prod ('
  //     sql += cols.join(',')
  //     if (imgtypeStr.length > 0) {
  //       sql += ',imgtype'
  //     }
  //     sql += ',server_node) VALUES ('
  //     for (let k = 0; k < vals.length; k++) {
  //       sql += `'${vals[k]}'`
  //       if (k < vals.length - 1 || imgtypeStr.length > 0) {
  //         sql += ','
  //       }
  //     }
  //     if (imgtypeStr.length > 0) {
  //       sql += `'${imgtypeStr}',`
  //     }
  //     sql += `'${serverNode}')`
  //
  //     insertSQLs.push(sql)
  //   }
  //
  //   WinLog.info('base_in_store_prod sqls :' + insertSQLs.length)
  //   DatabaseManager.batchInsertTableDataBySqlStr(tableName, insertSQLs)
  // } catch (e) {
  //   WinLog.info('base_in_store_product insert error' + e)
  // }
}
/*
 * 更新opt_value
 * */
export async function processServerAcvtDisValue(){
  // let optValueModelList:BaseStoreAcvtDisOptValueModel[]  = await BaseStoreAcvtDisQueryManager.queryBaseStoreAcvtDisOptValue();
  // let context = getContext(BaseStoreAcvtDisQueryManager) as common.UIAbilityContext;
  // if (context==undefined){
  //   context = AppUtil.getContext();
  // }
  // relationalStore.getRdbStore(context, DatabaseSqlUtil.STORE_CONFIG, (err, rdbStore) => {
  //   try {
  //     rdbStore.beginTransaction()
  //     optValueModelList.map(storeAcvtDisOptValueModel=>{
  //       let predicates = new relationalStore.RdbPredicates("base_store_acvt_dis");
  //       predicates.equalTo("_id", storeAcvtDisOptValueModel.optId);
  //       let value1 = ''
  //       if (storeAcvtDisOptValueModel.optName&&storeAcvtDisOptValueModel.optName?.length>0) {
  //         value1 = storeAcvtDisOptValueModel.optName;
  //       }
  //       const valueBucket: ValuesBucket = {
  //         'opt_value': value1
  //       };
  //       rdbStore.update(valueBucket, predicates, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then((rows:number)=>{
  //       }).catch((e:BusinessError)=>{
  //         WinLog.error(`更新opt目标数据Updated base_store_acvt_dis row count: ${e.code}`);
  //       });
  //     })
  //     rdbStore.commit()
  //   } catch (e) {
  //     rdbStore.rollBack()
  //   }
  // })
}