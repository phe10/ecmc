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
public class AlliancePapSyncJob {

    @Resource
    private final LpService lpService;

    /**
     * 每小时的第20分钟执行一次
     * @throws Exception
     */
    @Scheduled(cron = "0 20 * ? * *")
    public void process() throws Exception {
        lpService.alliancePapSync();
    }
}
