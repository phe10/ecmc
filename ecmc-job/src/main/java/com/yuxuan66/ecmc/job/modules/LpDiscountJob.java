package com.yuxuan66.ecmc.job.modules;

import com.yuxuan66.ecmc.modules.lp.service.LpService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;

/**
 * 联盟PAP同步
 */
@Component
@Transactional
@RequiredArgsConstructor
public class LpDiscountJob {

    @Resource
    private final LpService lpService;
    /**
     * 每个月第一天的凌晨5分进行打折
     *
     *
     * @throws Exception
     */
    @Scheduled(cron = "0 5 0 1 * ?")
    public void process() throws Exception {
        lpService.discountLp();
    }
}
