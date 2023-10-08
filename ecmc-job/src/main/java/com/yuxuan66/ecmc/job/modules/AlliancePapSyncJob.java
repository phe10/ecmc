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
    private UserAccountMapper userAccountMapper;
    private final OpenAccountApiService accountApiService;
    private final PapService papService;

    /**
     * 每小时的第20分钟执行一次
     * @throws Exception
     */
    @Scheduled(cron = "0 20 * ? * *")
    public void process() throws Exception {
        List<UserAccount> userAccountList = userAccountMapper.selectList(null);
        Map<String, String> papMap = accountApiService.getPap();
        for (UserAccount userAccount : userAccountList) {
            double pap = Convert.toDouble(papMap.get(Convert.toStr(userAccount.getCharacterId())), 0D);
            papService.alliancePapSync(userAccount,pap);
        }
    }
}
