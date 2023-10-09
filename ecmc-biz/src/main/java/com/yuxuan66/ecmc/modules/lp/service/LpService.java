package com.yuxuan66.ecmc.modules.lp.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.yuxuan66.ecmc.cache.ConfigKit;
import com.yuxuan66.ecmc.cache.key.CacheKey;
import com.yuxuan66.ecmc.common.consts.Const;
import com.yuxuan66.ecmc.common.utils.StpUtil;
import com.yuxuan66.ecmc.modules.account.entity.UserAccount;
import com.yuxuan66.ecmc.modules.account.mapper.UserAccountMapper;
import com.yuxuan66.ecmc.modules.account.service.UserAccountService;
import com.yuxuan66.ecmc.modules.lp.entity.LpLog;
import com.yuxuan66.ecmc.modules.lp.entity.consts.LpSource;
import com.yuxuan66.ecmc.modules.lp.entity.consts.LpType;
import com.yuxuan66.ecmc.modules.lp.entity.dto.SendLpDto;
import com.yuxuan66.ecmc.modules.lp.entity.query.LpLogQuery;
import com.yuxuan66.ecmc.modules.lp.mapper.LpLogMapper;
import com.yuxuan66.ecmc.modules.system.service.UserService;
import com.yuxuan66.ecmc.support.base.BaseService;
import com.yuxuan66.ecmc.support.exception.BizException;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Sir丶雨轩
 * @since 2022/12/13
 */
@Service
@RequiredArgsConstructor
@Transactional(rollbackFor = Exception.class)
public class LpService extends BaseService<LpLog, LpLogMapper> {

    private final UserService userService;
    @Resource
    private UserAccountMapper userAccountMapper;

    @Resource
    private UserAccountService userAccountService;

    /**
     * 给指定用户发放LP
     *
     * @param sendLpDto 发放信息
     */
    public void sendLp(SendLpDto sendLpDto) {

        String[] userList = sendLpDto.getLpUsers().split("\n");

        // 处理正确的角色名称
        List<String> sendUserList = new ArrayList<>();

        for (String user : userList) {
            // 移除行尾换行，移除空格
            String tempUser = user.replace("\r", "").trim();
            if (StrUtil.isNotBlank(tempUser)) {
                sendUserList.add(tempUser);
            }
        }

        // 拉取系统中所有角色名单，不在系统中的直接忽略
        QueryWrapper<UserAccount> wrapper = new QueryWrapper<UserAccount>().in("character_name", sendUserList);
        wrapper.eq(sendLpDto.isCorp(), "corp_id", ConfigKit.get(CacheKey.EVE_MAIN_CORP));
        List<UserAccount> userAccountList = userAccountMapper.selectList(wrapper);

        if (userAccountList.isEmpty()) {
            throw new BizException("LP发放失败,您复制的名单在系统中均为注册");
        }

        List<LpLog> saveLogList = new ArrayList<>();

        for (UserAccount userAccount : userAccountList) {
            LpLog log = new LpLog();
            log.setCharacterName(userAccount.getCharacterName());
            log.setAccountId(userAccount.getId());
            log.setUserId(userAccount.getUserId());
            log.setLp(sendLpDto.getLp());
            log.setSource(LpSource.MANUAL_RELEASE);
            log.setType(LpType.INCOME);
            log.setContent(sendLpDto.getWhere());
            saveLogList.add(log);
            // 更新用户的LP
            userAccount.setLpNow(userAccount.getLpNow().add(sendLpDto.getLp()));
            userAccount.setLpTotal(userAccount.getLpTotal().add(sendLpDto.getLp()));
            userAccount.updateById();

        }
        baseMapper.batchInsert(saveLogList);

    }

    /**
     * 查询指定角色或用户的LP历史
     *
     * @param lpLogQuery 查询条件
     * @return LP历史
     */
    public Page<LpLog> listLpLogByAccountId(LpLogQuery lpLogQuery) {
        return query().eq(lpLogQuery.getAccountId() != null, "account_id", lpLogQuery.getAccountId())
                .eq(lpLogQuery.getAccountId() == null, "user_id", StpUtil.getLoginId()).page(lpLogQuery.getPageOrder());
    }

    /**
     * 分页查询LP发放记录，如果有发放的权限则查看所有，否则查看自己的
     *
     * @param lpLogQuery 查询条件
     * @return LP历史
     */
    public Page<LpLog> listLpLog(LpLogQuery lpLogQuery) {
        if (!userService.getPermCode(StpUtil.getLoginId()).contains(Const.LP_SEND)) {
            lpLogQuery.setUserId(StpUtil.getLoginId());
        }
        return baseMapper.selectLpLog(lpLogQuery.getPage(), lpLogQuery);
    }

    @Async("threadPoolTaskExecutor")
    public void pap2lp() {
        //系数判断
        // int systemPapCOTM = 0;
        //先清理上个月的，每个账户乘以0.6也就是减少0.4
        List<UserAccount> userAccountList = userAccountMapper.selectList(null);
        List<LpLog> decSaveLog = new ArrayList<>();
        for (UserAccount userAccount : userAccountList) {
            LpLog log = new LpLog();
            log.setCharacterName(userAccount.getCharacterName());
            log.setAccountId(userAccount.getId());
            log.setUserId(userAccount.getUserId());

            log.setLp(userAccount.getLpNow().multiply(new BigDecimal("0.4")));
            log.setSource(LpSource.AUTO_DEC);
            log.setType(LpType.EXPENDITURE);
            log.setContent("联盟PAP转化LP");
            decSaveLog.add(log);

            boolean hasSome = userAccount.getLpNow() != null && userAccount.getLpNow().compareTo(BigDecimal.ZERO) > 0;
            if (hasSome) {
                //当前可用的60%
                userAccount.setLpNow(userAccount.getLpNow().multiply(new BigDecimal("0.6")));
            }
            boolean hasUsesome = userAccount.getLpUse() != null && userAccount.getLpUse().compareTo(BigDecimal.ZERO) > 0;
            //已经被用掉40%
            if (hasUsesome) {
                userAccount.setLpUse(userAccount.getLpUse().add(userAccount.getLpUse().multiply(new BigDecimal("0.4"))));
            }
            if (hasSome || hasUsesome) {
                userAccount.updateById();
            }
        }
        if (!CollectionUtils.isEmpty(decSaveLog)) {
            baseMapper.batchInsert(decSaveLog);
        }

        Map<Long, List<UserAccount>> userId2AccountList = new HashMap<>();
        for (UserAccount userAccount : userAccountList) {
            if (userAccount.getUserId() == null) {
                continue;
            }
            if (userId2AccountList.get(userAccount.getUserId()) == null) {
                List<UserAccount> list = new ArrayList<>();
                list.add(userAccount);
                userId2AccountList.put(userAccount.getUserId(), list);
            } else {
                List<UserAccount> userAccounts = userId2AccountList.get(userAccount.getUserId());
                userAccounts.add(userAccount);
            }
        }
        Map<Long, BigDecimal> totalPAP = new HashMap<>();
        for (Long userId : userId2AccountList.keySet()) {
            List<UserAccount> userAccounts = userId2AccountList.get(userId);
            BigDecimal totalPapOfUser = BigDecimal.ZERO;
            for (UserAccount userAccount : userAccounts) {
                if (userAccount.getPap() != null) {
                    totalPapOfUser = totalPapOfUser.add(userAccount.getPap());
                }
            }
            totalPAP.put(userId, totalPapOfUser);
        }
        if (CollectionUtils.isEmpty(totalPAP)) {
            return;
        }
        List<LpLog> saveLogList = new ArrayList<>();
        //进行当月的PAP转化成LP，加到主账号上
        for (Long userId : totalPAP.keySet()) {
            if (totalPAP.get(userId) == null) {
                continue;
            }
            BigDecimal three = new BigDecimal(3);
            //小于3不转化
            if (totalPAP.get(userId).compareTo(three) < 0) {
                continue;
            }
            //转化只更新到主账号
            UserAccount mainAccount =
                    userAccountService.query().eq("user_id", userId).eq("is_main", 1).one();
            LpLog log = new LpLog();
            log.setCharacterName(mainAccount.getCharacterName());
            log.setAccountId(mainAccount.getId());
            log.setUserId(mainAccount.getUserId());

            log.setLp(totalPAP.get(userId));
            log.setSource(LpSource.PAP);
            log.setType(LpType.INCOME);
            log.setContent("联盟PAP转化LP");
            saveLogList.add(log);
            // 更新用户的LP
            mainAccount.setLpNow(mainAccount.getLpNow().add(totalPAP.get(userId)));
            mainAccount.setLpTotal(mainAccount.getLpTotal().add(totalPAP.get(userId)));
            mainAccount.updateById();
        }
        baseMapper.batchInsert(saveLogList);
    }
}
