package com.yuxuan66.ecmc.modules.lp.mapper;

import com.yuxuan66.ecmc.modules.lp.entity.PAPLog;
import com.yuxuan66.ecmc.support.base.BaseMapper;

import java.util.List;

/**
 * @author Sir丶雨轩
 * @since 2022/12/13
 */
public interface PapLogMapper extends BaseMapper<PAPLog> {
//    Page<PAPLog> selectPapLog(Page<PAPLog> page, PapLogQuery query);

    long batchPAPInsert(List<PAPLog> papLogList);

}
