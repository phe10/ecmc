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
public class Pap2LPJob {

    @Resource
    private final LpService lpService;
    /**
     * 每个月的第二天10分进行PAP到LP转化，完了之后清零，但联盟那边5号所以还会存在一部分
     *
     * @throws Exception
     */
    @Scheduled(cron = "0 45 0 1 * ?")
    public void process() throws Exception {
        lpService.pap2lp();
    }
}
