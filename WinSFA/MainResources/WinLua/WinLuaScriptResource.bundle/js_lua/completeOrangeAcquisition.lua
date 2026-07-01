function completeOrangeAcquisition(storeId)

    local empId = getDataByMethod("getEmpId", "");
    local qstCode = "secsmdhd";
    local optName = "完美已采集";
    local acvtqstAnswersql = "select baq.acvtId acvtId, baq.acvtQstId acvtQstId, opt._id acvt_qst_answer,opt.optName opt_value from base_acvt_qst_opt opt join base_acvt_qst baq on  baq.qstCod = '"..qstCode.."' and opt.acvtQstId=baq.qstId where opt.optName = '"..optName.."' ";
    local acvtData = getDataByMethod("executeSql:", acvtqstAnswersql);
    print("acvtData--->"..acvtData);

    local position = string.find(acvtData, "acvt_qst_answer");
    local acvtData1 = string.sub(acvtData, 1, position - 1);
    print("acvtData1--->"..acvtData1);

    acvtData1 = string.gsub(acvtData1,",","='");
    acvtData1 = string.gsub(acvtData1,"@","' and ");
    local whereData = acvtData1.." sid='"..storeId.."' and server_node='storeacvtdis:searchStore' and emp_id='"..empId.."' ";
    whereData = string.gsub(whereData,"@luaExtra","");
    print("whereData--->"..whereData);

    local delSql = "delete from base_store_acvt_dis where "..whereData;
    print("delSql==="..delSql);
    getDataByMethod("executeSql:", delSql);

    acvtData = string.gsub(acvtData,"@|","'");
    acvtData = string.gsub(acvtData,"@","'");
    acvtData = string.gsub(acvtData,"acvtId,",",'");
    acvtData = string.gsub(acvtData,"acvtQstId,",",'");
    acvtData = string.gsub(acvtData,"acvt_qst_answer,",",'");
    acvtData = string.gsub(acvtData,"opt_value,",",'");
    local valuesData = " '"..storeId.."'".. acvtData..",'storeacvtdis:searchStore','"..empId.."' ";
    valuesData = string.gsub(valuesData,"@luaExtra","");
    print("valuesData--->"..valuesData);

    local updateSql = "insert or replace into base_store_acvt_dis (sid,acvtId,acvtQstId,acvt_qst_answer,opt_value,server_node,emp_id) values ("..valuesData..") ";
    print("updateSql==="..updateSql);
    getDataByMethod("executeSql:", updateSql);

end
