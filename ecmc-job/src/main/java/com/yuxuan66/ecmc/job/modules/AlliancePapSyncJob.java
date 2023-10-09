package com.yuxuan66.ecmc.job.modules;

import cn.hutool.core.convert.Convert;
import com.yuxuan66.ecmc.modules.account.entity.UserAccount;
import com.yuxuan66.ecmc.modules.account.mapper.UserAccountMapper;
import com.yuxuan66.ecmc.modules.account.service.OpenAccountApiService;
import com.yuxuan66.ecmc.modules.account.service.UserAccountService;
import com.yuxuan66.ecmc.modules.account.service.refresh.AccountWalletRefresh;
import com.yuxuan66.ecmc.modules.lp.service.PapService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

/**
 * 联盟PAP同步
 */
@Component
@Transactional
@RequiredArgsConstructor
public class AlliancePapSyncJob {

    @Resource
    private final PapService papService;

    /**
     * 每小时的第20分钟执行一次
     * @throws Exception
     */
    @Scheduled(cron = "0 20 * ? * *")
    public void process() throws Exception {
        papService.alliancePapSync();
    }
}
