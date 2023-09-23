package com.yuxuan66.ecmc.modules.lp.entity.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * @author Sir丶雨轩
 * @since 2022/1/7
 */
@Data
public class SendPAPDto {

    /**
     * 人员名单
     */
    private String papUsers;

    /**
     * 发放数量
     */
    private BigDecimal pap;
    /**
     * 发放原因
     */
    private String where;

    /**
     * 舰队长角色
     */
    private String createdBy;
    /**
     * 是否只发给军团成员
     */
//    private boolean corp;

}
