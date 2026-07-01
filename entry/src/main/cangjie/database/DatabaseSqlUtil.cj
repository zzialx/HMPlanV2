/**
 * Created on 2025/8/29
 */
package ohos_app_cangjie_entry.database
import ohos.relational_store.StoreConfig
import ohos.relational_store.SecurityLevel

public class DatabaseSqlUtil{

    public static let STORE_CONFIG : StoreConfig = StoreConfig("WinSFA.db", SecurityLevel.S1,encrypt:false,dataGroupId:'',customDir:'winchannel',autoCleanDirtyData:false);
    /**
    * 门店表
    */
    public static let CREATE_BASE_STORE_TABLE:String = '''
                                    CREATE TABLE IF NOT EXISTS base_store(
                                        _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                        id TEXT,
                                        name TEXT,
                                        cod TEXT,
                                        styp TEXT,
                                        addr TEXT,
                                        lon TEXT,
                                        lat TEXT,
                                        empId TEXT,
                                        biz_date TEXT,
                                        sort TEXT,
                                        server_node TEXT,
                                        distances TEXT,
                                        sv TEXT,
                                        acvt_genId TEXT,
                                        last_date TEXT,
                                        pinyin TEXT,
                                        search_code TEXT);
                                    '''
    public static let  CREATE_BASE_ACVT_TABLE:String = '''
                                    CREATE TABLE IF NOT EXISTS base_acvt (
                                        _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                        acvtId TEXT,
                                        acvtCode TEXT,
                                        acvtName TEXT,
                                        typ TEXT,
                                        isblock TEXT,
                                        isReq TEXT,
                                        ftext TEXT,
                                        server_node TEXT,
                                        acvtIconUrl TEXT,
                                        originalAcvtId TEXT,
                                        empId TEXT,
                                        acvtObj TEXT,
                                        publisher TEXT);
                                '''
    public static let CREATE_BASE_ACVT_QST_OPT_TABLE:String = '''
                                    CREATE TABLE IF NOT EXISTS base_acvt_qst_opt (
                                        _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                        acvtQstId TEXT,
                                        qstId TEXT,
                                        optId TEXT,
                                        optName TEXT,
                                        server_node TEXT);
                                    '''
  public static let CREAT_BASE_FUNCS_TABLE:String = '''
                                    CREATE TABLE IF NOT EXISTS base_funcs (
                                    _id INTEGER PRIMARY KEY NOT NULL,
                                    pk TEXT,
                                    fk TEXT,
                                    userId TEXT,
                                    fc TEXT,
                                    fv TEXT,
                                    name TEXT,
                                    required TEXT,
                                    opt TEXT,
                                    ds TEXT,
                                    filter TEXT,
                                    param TEXT,
                                    styp TEXT,
                                    isAcvtList TEXT,
                                    readonly TEXT,
                                    sort INTEGER,
                                    levelCode INTEGER,
                                    submenu TEXT,
                                    redis TEXT,
                                    sqlw TEXT,
                                    icon TEXT,
                                    subCode TEXT,
                                    script TEXT,
                                    menuType TEXT,
                                    pageTag TEXT,
                                    nullvalue TEXT,
                                    dateTyp TEXT);
                                '''
  public static let CREAT_BASE_Plan_Route_TABLE:String = '''
                                    CREATE TABLE IF NOT EXISTS base_plan_route (
                                    _id INTEGER PRIMARY KEY NOT NULL,
                                    storeId TEXT,
                                    type TEXT,
                                    routeId TEXT,
                                    sort TEXT,
                                    state TEXT,
                                    empId TEXT,
                                    bizDate TEXT,
                                    item TEXT,
                                    item1 TEXT,
                                    item2 TEXT,
                                    server_node TEXT);
                                '''
  public static let CREAT_BASE_STORE_ACVT_DIS:String = '''
                                    CREATE TABLE IF NOT EXISTS base_store_acvt_dis (
                                    _id INTEGER PRIMARY KEY NOT NULL,
                                    sid TEXT,
                                    acvtId TEXT,
                                    acvtQstId TEXT,
                                    acvt_qst_answer TEXT,
                                    gen_id TEXT,
                                    assetId TEXT,
                                    opt_value TEXT,
                                    is_search TEXT,
                                    newStoreId TEXT,
                                    server_node TEXT, e
                                    mp_id TEXT,
                                    getTime TEXT);
                                '''
  public static let CREAT_BASE_STORE_PROD_DIS:String = '''
                                    CREATE TABLE IF NOT EXISTS base_store_prod_dis (
                                    _id INTEGER PRIMARY KEY NOT NULL,
                                    id Text,
                                    store_id INTEGER,
                                    prod_id INTEGER,
                                    dist TEXT,
                                    pri TEXT,
                                    inv TEXT,
                                    disp TEXT,
                                    sdisp TEXT,
                                    cmpt TEXT,
                                    oos TEXT,
                                    mtd TEXT,
                                    ord TEXT,
                                    gofa TEXT,
                                    aging TEXT,
                                    otherdicts TEXT,
                                    item1 TEXT,
                                    item2 TEXT,
                                    item3 TEXT,
                                    item4 TEXT,
                                    item5 TEXT,
                                    item6 TEXT,
                                    item7 TEXT,
                                    item8 TEXT,
                                    item9 TEXT,
                                    item10 TEXT,
                                    item11 TEXT,
                                    item12 TEXT,
                                    item13 TEXT,
                                    item14 TEXT,
                                    item15 TEXT,
                                    item16 TEXT,
                                    item17 TEXT,i
                                    tem18 TEXT,
                                    item19 TEXT,
                                    item20 TEXT,
                                    item21 TEXT,
                                    item22 TEXT,
                                    item23 TEXT,
                                    item24 TEXT,
                                    item25 TEXT,
                                    item26 TEXT,
                                    item27 TEXT,
                                    item28 TEXT,
                                    item29 TEXT,
                                    item30 TEXT,
                                    item31 TEXT,
                                    item32 TEXT,
                                    item33 TEXT,
                                    item34 TEXT,
                                    item35 TEXT,
                                    item36 TEXT,
                                    item37 TEXT,
                                    item38 TEXT,
                                    item39 TEXT,
                                    item40 TEXT,
                                    dt TEXT,
                                    dn TEXT,
                                    funccode TEXT,
                                    genid TEXT,
                                    server_node TEXT);
                                '''
  public static let CREAT_BASE_STORE_PRODUCT:String = '''
                                    CREATE TABLE IF NOT EXISTS base_product (
                                    _id INTEGER PRIMARY KEY NOT NULL,
                                    id Text,name TEXT,
                                    cod TEXT,
                                    searchcod TEXT,
                                    pTyp TEXT,
                                    brand TEXT,
                                    barcode TEXT,
                                    price TEXT,
                                    url TEXT,
                                    seq INTEGER,
                                    addproduct_json_data TEXT,
                                    blockPrice TEXT,
                                    regex TEXT,
                                    pack TEXT,
                                    size TEXT,
                                    series TEXT,
                                    server_node TEXT,
                                    memo TEXT,
                                    memo1 TEXT,
                                    memo2 TEXT,
                                    memo3 TEXT,
                                    memo4 TEXT,
                                    prodtrees TEXT,
                                    pinyin TEXT,
                                    barcode2 TEXT,
                                    expirydate TEXT,
                                    bigage TEXT);
                                '''
  public static let CREAT_BASE_STORE_OTHER_DATA:String = '''
                                    CREATE TABLE IF NOT EXISTS base_store_other_data (
                                    _id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                                    emp_id TEXT,
                                    store_id TEXT,
                                    type TEXT,
                                    item1 TEXT,
                                    item2 TEXT,
                                    item3 TEXT,
                                    item4 TEXT,
                                    item5 TEXT,
                                    item6 TEXT,
                                    item7 TEXT,
                                    item8 TEXT,
                                    item9 TEXT,
                                    item10 TEXT,
                                    biz_date TEXT);
                                '''
  public static let CREAT_BASE_STORE_VISIT_PLAN:String = '''
                                    CREATE TABLE IF NOT EXISTS base_store_visitplan (
                                    _id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                                    emp_id TEXT,
                                    store_id TEXT,
                                    biz_date TEXT,
                                    seq TEXT);
                                '''
  public static let CREAT_BASE_DICTS:String = '''
                                    CREATE TABLE IF NOT EXISTS base_dicts (
                                    _id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                                    id TEXT,
                                    pid TEXT,
                                    name TEXT,
                                    typ TEXT,
                                    dtyp TEXT,
                                    btyp TEXT,
                                    col1 TEXT,
                                    col2 TEXT,
                                    cod TEXT,
                                    dicts_sequence INTEGER,
                                    levelCode TEXT,
                                    regex TEXT,
                                    server_node TEXT,
                                    SEQ TEXT,
                                    fl TEXT,
                                    iconUrl TEXT);
                                '''
  public static let CREAT_DOWN_FILE:String = '''
                                    CREATE TABLE IF NOT EXISTS ws_download_file (
                                    _id INTEGER  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,
                                    empid TEXT DEFAULT NULL,
                                    biz_date TEXT DEFAULT NULL,
                                    acvt_id Varchar(20) DEFAULT NULL,
                                    file_id VARCHAR(32) NOT NULL,
                                    file_name TEXT,
                                    file_url TEXT,
                                    file_length NUMBER NULL,
                                    file_download_size NUMBER,
                                    file_type TEXT,
                                    file_save_path TEXT,
                                    file_download_status TEXT,
                                    file_download_begin_time TEXT,
                                    file_download_end_time TEXT,
                                    file_expire_time TEXT);
                                '''
  public static let CREAT_BASE_STORE_ACVT_TABLE: String = '''
                                    CREATE TABLE IF NOT EXISTS base_store_acvt (
                                    _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    sid TEXT,
                                    acvtId TEXT,
                                    uploadCount TEXT,
                                    hasUploadedCount TEXT,
                                    server_node TEXT);
                                '''
  public static let CREAT_VISIT_STORE_ACVT_DATA_TABLE: String = '''
                                    CREATE TABLE IF NOT EXISTS visit_store_acvt_data (
                                    _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    sid TEXT,
                                    acvtId TEXT,
                                    acvtQstId TEXT,
                                    acvt_qst_answer TEXT,
                                    gen_id TEXT,
                                    assetId TEXT,
                                    emp_id TEXT,
                                    biz_date TEXT,
                                    opt_value TEXT,
                                    server_node TEXT,
                                    is_search TEXT);
                                '''

  public static let CREATE_BASE_ACVT_QST_TABLE:String = '''
                                            CREATE TABLE IF NOT EXISTS base_acvt_qst (
                                            _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                            acvtId TEXT,
                                            acvtQstId TEXT,
                                            qstId TEXT,
                                            qstCod TEXT,
                                            qstName TEXT,
                                            qstType TEXT,
                                            is_req TEXT,
                                            readonly TEXT,
                                            orientation TEXT,
                                            mlen TEXT,
                                            dlen TEXT,
                                            mnum TEXT,
                                            snum TEXT,
                                            mc TEXT,
                                            ds TEXT,
                                            filter TEXT,
                                            isAcvtName TEXT,
                                            isSupperLocalPhoto TEXT,
                                            defaultValue TEXT,
                                            acvtNestedId TEXT,
                                            isHidden TEXT,
                                            Js TEXT,
                                            displayMode TEXT,
                                            hideQstName TEXT,
                                            isCoverNewId TEXT,
                                            memo3 TEXT,
                                            parentQstId TEXT);
                                    '''
  public static let CREAT_INOUT_STORE_TABLE = '''
                                CREATE TABLE IF NOT EXISTS visit_inout_store(
                                    _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    storeId TEXT,
                                    empId TEXT,
                                    isPlan TEXT,
                                    biz_date TEXT,
                                    inTime TEXT,
                                    outTime TEXT,
                                    img_idx TEXT,
                                    memo TEXT,
                                    upload_date TEXT,
                                    upload_flag TEXT,
                                    in_lon TEXT,
                                    in_lat TEXT,
                                    out_lon TEXT,
                                    out_lat TEXT,
                                    in_callId TEXT,
                                    out_callId TEXT,
                                    sr_id TEXT,
                                    func_code TEXT,
                                    memo1 TEXT,
                                    memo2 TEXT,
                                    memo3 TEXT,
                                    memo4 TEXT,
                                    memo5 TEXT,
                                    memo6 TEXT,
                                    memo7 TEXT,
                                    memo8 TEXT,
                                    memo9 TEXT,
                                    memo10 TEXT,
                                    visit_id TEXT,
                                    modulefc TEXT,
                                    local_image TEXT);
                                '''
  public static let CREAT_OFFLINE_UPLOAD_TABLE = '''
                                CREATE TABLE IF NOT EXISTS wch_offline_upload (
                                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    emp_id VARCHAR(10),
                                    biz_date VARCHAR(30),
                                    upload_flag VARCHAR(10),
                                    upload_data VARCHAR(1000),
                                    url VARCHAR(500),
                                    gen_id VARCHAR(100),
                                    is_photo VARCHAR(10),
                                    notify VARCHAR(50),
                                    data_type VARCHAR(8),
                                    photo_filename VARCHAR(50)
                                    );
                                '''
  public static let CREAT_VISIT_STORE_TABLE = '''
                                CREATE TABLE visit_store_status (
                                    _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    emp_id TEXT,
                                    store_id TEXT,
                                    status TEXT,
                                    biz_date TEXT,
                                    func_code TEXT,
                                    is_plan INTEGER
                                    );
                                '''
  public static let CREAT_VISIT_STORE_ACTION_TABLE = '''
                                CREATE TABLE IF NOT EXISTS visit_store_action (
                                    _id INTEGER PRIMARY KEY AUTOINCREMENT,
                                    top_func_code VARCHAR(30) DEFAULT NULL,
                                    parent_func_pk VARCHAR(20) DEFAULT NULL,
                                    func_code VARCHAR(20) DEFAULT NULL,
                                    store_id VARCHAR(20) DEFAULT NULL,
                                    biz_date VARCHAR(20) DEFAULT NULL,
                                    status VARCHAR(20) DEFAULT NULL,
                                    emp_id VARCHAR(20) DEFAULT NULL,
                                    dict_id VARCHAR(20) DEFAULT NULL,
                                    is_required VARCHAR(20) DEFAULT NULL,
                                    title VARCHAR(100) DEFAULT NULL
                                    );
                                '''
  public static let CREATE_IMAGE_PATH_TABLE = '''
                                CREATE TABLE IF NOT EXISTS base_image (
                                    ID INTEGER PRIMARY KEY AUTOINCREMENT,
                                    upload_flag VARCHAR(12),
                                    image_idx TEXT,
                                    image_path TEXT,
                                    image_id TEXT,
                                    image_json TEXT,
                                    biz_date VARCHAR(12),
                                    upload_time VARCHAR(50),
                                    store_id TEXT,
                                    acvt_id TEXT,
                                    emp_id VARCHAR(20)
                                    );
                                '''
}