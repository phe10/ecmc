package com.yuxuan66.ecmc.modules.lp.entity.query;

import com.yuxuan66.ecmc.modules.lp.entity.PAPLog;
import com.yuxuan66.ecmc.support.base.BaseQuery;
import lombok.Data;

@Data
public class ActionListQuery extends BaseQuery<PAPLog> {
    private String commander;
}
