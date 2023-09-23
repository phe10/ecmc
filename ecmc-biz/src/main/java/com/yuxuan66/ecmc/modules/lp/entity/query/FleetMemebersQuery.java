package com.yuxuan66.ecmc.modules.lp.entity.query;

import com.yuxuan66.ecmc.modules.lp.entity.LpLog;
import com.yuxuan66.ecmc.support.base.BaseEntity;
import com.yuxuan66.ecmc.support.base.BaseQuery;
import lombok.Data;

import java.io.Serializable;
import java.sql.Timestamp;

@Data
public class FleetMemebersQuery extends BaseQuery<FleetMemebersQuery> {
    private String commander;
}
