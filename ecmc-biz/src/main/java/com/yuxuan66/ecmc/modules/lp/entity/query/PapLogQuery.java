package com.yuxuan66.ecmc.modules.lp.entity.query;

import com.yuxuan66.ecmc.modules.lp.entity.LpLog;
import com.yuxuan66.ecmc.modules.lp.entity.PAPLog;
import com.yuxuan66.ecmc.support.base.BaseQuery;
import lombok.Data;

/**
 * @author Sir丶雨轩
 * @since 2022/12/13
 */
@Data
public class PapLogQuery extends BaseQuery<PAPLog> {

    private Long accountId;
    private Long userId;
}
