package com.yuxuan66.ecmc.job.modules;

import cn.hutool.core.convert.Convert;
import com.yuxuan66.ecmc.modules.account.entity.UserAccount;
import com.yuxuan66.ecmc.modules.account.mapper.UserAccountMapper;
import com.yuxuan66.ecmc.modules.account.service.OpenAccountApiService;
import com.yuxuan66.ecmc.modules.lp.service.LpService;
import com.yuxuan66.ecmc.modules.lp.service.PapService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 联盟PAP同步
 */
@Component
@Transactional
@RequiredArgsConstructor
public class Pap2LPJob {

    @Resource
    private final LpService lpService;
    /**
     * 每个月的28号23点进行PAP转化成LP
     *
     * @throws Exception
     */
    @Scheduled(cron = "0 23 28 * *")
    public void process() throws Exception {
        lpService.pap2lp();
    }
}
