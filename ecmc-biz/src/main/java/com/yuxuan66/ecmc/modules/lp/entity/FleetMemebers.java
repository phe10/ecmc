package com.yuxuan66.ecmc.modules.lp.entity;

import com.yuxuan66.ecmc.support.base.BaseEntity;
import lombok.Data;

import java.io.Serializable;
import java.sql.Timestamp;

@Data
public class FleetMemebers extends BaseEntity<FleetMemebers> implements Serializable {
    private String characterName;
    private String commander;
    private Timestamp createTime;
    private String ship;
    private String corpName;
    private String allianceName;
    private Integer commanderId;
}
