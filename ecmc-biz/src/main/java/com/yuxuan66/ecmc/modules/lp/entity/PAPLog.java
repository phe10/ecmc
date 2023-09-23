package com.yuxuan66.ecmc.modules.lp.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.yuxuan66.ecmc.modules.account.entity.UserAccount;
import com.yuxuan66.ecmc.modules.lp.entity.consts.LpSource;
import com.yuxuan66.ecmc.modules.lp.entity.consts.LpType;
import com.yuxuan66.ecmc.support.base.BaseEntity;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 军团PAP发放记录表(PAP)实体类
 *
 * @author makejava
 * @since 2022-01-07 11:20:54
 */
@Data
@TableName("corp_pap_log")
public class PAPLog extends BaseEntity<PAPLog> implements Serializable {

    /**
     * 角色名
     */
    private String characterName;
    /**
     * 角色ID
     */
    private Long accountId;
    /**
     * 军团用户ID
     */
    private Long userId;
    /**
     * LP数量
     */
    private BigDecimal pap;
    /**
     * 说明
     */
    private String content;

    /**
     * 舰队ID
     */
    private Long fleetId;

    /**
     * 创建者ID
     */
    private Long createId;

    /**
     * 创建者
     */
    private String createBy;
}

