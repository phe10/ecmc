package com.yuxuan66.ecmc.modules.lp.service;

import cn.hutool.core.convert.Convert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.yuxuan66.ecmc.cache.ConfigKit;
import com.yuxuan66.ecmc.cache.EveCache;
import com.yuxuan66.ecmc.cache.key.CacheKey;
import com.yuxuan66.ecmc.common.consts.Const;
import com.yuxuan66.ecmc.common.utils.Lang;
import com.yuxuan66.ecmc.common.utils.StpUtil;
import com.yuxuan66.ecmc.modules.account.entity.UserAccount;
import com.yuxuan66.ecmc.modules.account.mapper.UserAccountMapper;
import com.yuxuan66.ecmc.modules.account.service.OpenAccountApiService;
import com.yuxuan66.ecmc.modules.account.service.UserAccountService;
import com.yuxuan66.ecmc.modules.lp.entity.FleetMemebers;
import com.yuxuan66.ecmc.modules.lp.entity.LpLog;
import com.yuxuan66.ecmc.modules.lp.entity.PAPLog;
import com.yuxuan66.ecmc.modules.lp.entity.consts.LpSource;
import com.yuxuan66.ecmc.modules.lp.entity.consts.LpType;
import com.yuxuan66.ecmc.modules.lp.entity.dto.SendLpDto;
import com.yuxuan66.ecmc.modules.lp.entity.dto.SendPAPDto;
import com.yuxuan66.ecmc.modules.lp.entity.query.FleetMemebersQuery;
import com.yuxuan66.ecmc.modules.lp.entity.query.LpLogQuery;
import com.yuxuan66.ecmc.modules.lp.mapper.LpLogMapper;
import com.yuxuan66.ecmc.modules.system.service.UserService;
import com.yuxuan66.ecmc.support.base.BaseService;
import com.yuxuan66.ecmc.support.exception.BizException;
import lombok.RequiredArgsConstructor;
import net.troja.eve.esi.ApiException;
import net.troja.eve.esi.api.FleetsApi;
import net.troja.eve.esi.model.CharacterFleetResponse;
import net.troja.eve.esi.model.FleetMembersResponse;
import net.troja.eve.esi.model.TypeResponse;
import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
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
import java.util.function.Function;
import java.util.stream.Collectors;

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

    @Resource
    private EveCache eveCache;

    @Resource
    private OpenAccountApiService accountApiService;

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
            log.setFleetId(0L);
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

    private static final Integer PAP_TRANSFERED = 1;
    private static final Integer NOT_PAP_TRANSFERED = 0;

    /**
     * 仅转化联盟pap
     */
    @Async("threadPoolTaskExecutor")
    public void pap2lp() {
        //查询没有转移过的
        List<UserAccount> userAccountList = userAccountMapper.selectList(new QueryWrapper<UserAccount>().eq(
                "pap_status", NOT_PAP_TRANSFERED));
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
        //所有角色加起来，算一个user全部的PAP
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
        List<Long> transforedUser = new ArrayList<>();
        //进行当月的PAP转化成LP，加到主账号上
        for (Long userId : totalPAP.keySet()) {
            if (totalPAP.get(userId) == null) {
                continue;
            }
            BigDecimal usersPap = totalPAP.get(userId);
            BigDecimal three = new BigDecimal("3");
            //小于3不转化
            if (usersPap.compareTo(three) < 0) {
                continue;
            }
            //转化只更新到主账号
            UserAccount mainAccount =
                    userAccountService.query().eq("user_id", userId).eq("is_main", 1).one();
            //以下代码不再需要，后续pap单单指的是联盟pap
            LpLog log = new LpLog();
            log.setCharacterName(mainAccount.getCharacterName());
            log.setAccountId(mainAccount.getId());
            log.setUserId(mainAccount.getUserId());

            log.setLp(totalPAP.get(userId));
            log.setSource(LpSource.PAP);
            log.setType(LpType.INCOME);
            log.setContent("联盟PAP转化LP");
            log.setFleetId(0L);
            saveLogList.add(log);

            BigDecimal addLp = BigDecimal.ZERO;
            // 如果pap>3 小于等于50 则1:1 ;>50 2:1
            if (usersPap.compareTo(new BigDecimal("3")) > 0 && usersPap.compareTo(new BigDecimal("50")) <= 0) {
                addLp = usersPap;
            } else {
                BigDecimal d50 = new BigDecimal("50");
                //多出50的部分打0.5折
                BigDecimal extPap = usersPap.subtract(d50).multiply(new BigDecimal("0.5"));
                addLp = extPap.add(d50);
            }
            mainAccount.setLpNow(mainAccount.getLpNow().add(addLp));
            mainAccount.setLpTotal(mainAccount.getLpTotal().add(addLp));
            //记录修改状态代表已被转化过
            mainAccount.setPapStatus(PAP_TRANSFERED);
            mainAccount.updateById();

            transforedUser.add(userId);
        }
        //保存转移记录
        if (!CollectionUtils.isEmpty(saveLogList)) {
            baseMapper.batchInsert(saveLogList);
        }
        //pap转移过过不重新转移了
        for (Long userId : transforedUser) {
            userAccountService.update(new UpdateWrapper<UserAccount>().eq("user_id", userId).set("pap_status", PAP_TRANSFERED));
        }

//        userAccountMapper.cleanUserPap();
//        papService.makeupCleanLog(userAccountList);
    }

    @Async("threadPoolTaskExecutor")
    public void discountLp() {
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
            log.setContent("每月自动打折上个月的LP，保留60%");
            log.setFleetId(0L);
            decSaveLog.add(log);
            //小于0.4的就不减了，因为也兑换不了什么
            boolean hasSome =
                    userAccount.getLpNow() != null && userAccount.getLpNow().compareTo(new BigDecimal("0.4")) > 0;
            BigDecimal decount = BigDecimal.ZERO;
            if (hasSome) {
                //当前可用的60%
                decount = userAccount.getLpNow().multiply(new BigDecimal("0.4"));
                userAccount.setLpNow(userAccount.getLpNow().multiply(new BigDecimal("0.6")));
            }
            //可能一个都没用只判断是否
            //已经被用掉40%
            if (userAccount.getLpUse() != null && hasSome) {
                //自动消除40% 可用的，total总量不变
                userAccount.setLpUse(userAccount.getLpUse().add(decount));
            }
            //有了才能扣
            if (hasSome) {
                userAccount.updateById();
            }

        }
        if (!CollectionUtils.isEmpty(decSaveLog)) {
            baseMapper.batchInsert(decSaveLog);
        }
    }

    public List<FleetMemebers> fleetMemebers(FleetMemebersQuery fleetMemebersQuery) {
        //TODO 后续如果要做帮其他人PAP可以从前台传入指挥官信息。
        if (StringUtils.isBlank(fleetMemebersQuery.getCommander())) {
            List<UserAccount> userAccountList = userAccountService.query().eq("user_id", StpUtil.getLoginId()).list();
            UserAccount userAccount = userAccountList.get(0);
            fleetMemebersQuery.setCommander(userAccount.getCharacterName());
        }
        QueryWrapper<UserAccount> wrapper = new QueryWrapper<UserAccount>().in("character_name",
                fleetMemebersQuery.getCommander());
        wrapper.eq(true, "corp_id", ConfigKit.get(CacheKey.EVE_MAIN_CORP));
        List<UserAccount> creatorUserAccountList = userAccountMapper.selectList(wrapper);
        //非注册用户，非本军团成员不能PAP
        if (creatorUserAccountList.isEmpty()) {
            throw new BizException("没有一个是本军团成员，不可以PAP");
        }
        UserAccount papCreator = creatorUserAccountList.get(0);
        List<FleetMemebers> memebers = new ArrayList<>();
        FleetsApi fleetsApi = new FleetsApi();

        papCreator.esiClient();
        CharacterFleetResponse characterFleetResponse = null;
        try {
            characterFleetResponse = fleetsApi.getCharactersCharacterIdFleet(papCreator.getCharacterId(), null, null,
                    papCreator.getAccessToken());
        } catch (ApiException e) {
            throw new BizException("获取指挥官所在的舰队信息失败，可能ESI服务器存在问题，稍后再试.");
        }
        Long fleetId = characterFleetResponse.getFleetId();
        if (fleetId == null || fleetId == 0L) {
            throw new BizException("当前登陆用户不在一个舰队中.");
        }
        List<FleetMembersResponse> fleetMembersResponseList = null;
        try {
            fleetMembersResponseList = fleetsApi.getFleetsFleetIdMembers(fleetId, "zh",
                    null, null,
                    "zh",
                    papCreator.getAccessToken());
        } catch (ApiException e) {
            throw new BizException("获取登陆用户所在的舰队信息失败，可能ESI服务器存在问题，稍后再试.");
        }
        if (fleetMembersResponseList == null) {
            throw new BizException("当前用户所在舰队已解散.");
        }
        Map<Integer, FleetMembersResponse> fleetMembersResponseMap =
                fleetMembersResponseList.stream().collect(Collectors.toMap(FleetMembersResponse::getCharacterId,
                        Function.identity(), (key1, key2) -> key1));
        List<Integer> cIds = new ArrayList<>();
        boolean areUComd = false;
        for (FleetMembersResponse fleetMembersResponse : fleetMembersResponseList) {
            FleetMembersResponse.RoleEnum role = fleetMembersResponse.getRole();
            if (FleetMembersResponse.RoleEnum.FLEET_COMMANDER == role
                    && fleetMembersResponse.getCharacterId().equals(papCreator.getCharacterId())) {
                areUComd = true;
            }
            cIds.add(fleetMembersResponse.getCharacterId());
        }
        if (!areUComd) {
            throw new BizException("当前用户不是本舰队的指挥官，不可以PAP.");
        }
        //获取舰队成员在系统的信息
        QueryWrapper<UserAccount> cWapper = new QueryWrapper<UserAccount>().in("character_id", cIds);
        wrapper.eq(true, "corp_id", ConfigKit.get(CacheKey.EVE_MAIN_CORP));
        List<UserAccount> userAccountList = userAccountMapper.selectList(cWapper);
        if (userAccountList.isEmpty()) {
            throw new BizException("当前舰队没有一个是注册用户.");
        }

        for (UserAccount userAccount : userAccountList) {
            FleetMemebers fleetMemebers = new FleetMemebers();
            Integer shipId = fleetMembersResponseMap.get(userAccount.getCharacterId()).getShipTypeId();
            TypeResponse typeResponse = eveCache.typeName(shipId);
            if (typeResponse == null) {
                fleetMemebers.setShip("No Ship Found.");
            } else {
                fleetMemebers.setShip(eveCache.typeName(shipId).getName());
            }
            fleetMemebers.setCharacterName(userAccount.getCharacterName());
            fleetMemebers.setAllianceName(userAccount.getAllianceName());
            fleetMemebers.setCorpName(userAccount.getCorpName());
            fleetMemebers.setCreateTime(Lang.getNowTimestamp());
            fleetMemebers.setCommander(papCreator.getCharacterName());
            fleetMemebers.setCommanderId(papCreator.getCharacterId());
            memebers.add(fleetMemebers);
        }
        return memebers;
    }

    public void sendPAP(SendPAPDto sendPAPDto) {
        //使用当前用户的主角色进行PAP
        UserAccount papCreator =
                userAccountService.query().eq("user_id", StpUtil.getLoginId()).eq("is_main", 1).one();
        if (papCreator == null) {
            return;
        }
//        QueryWrapper<UserAccount> wrapper = new QueryWrapper<UserAccount>().in("character_name", sendPAPDto.getCreatedBy());
//        wrapper.eq(true, "corp_id", ConfigKit.get(CacheKey.EVE_MAIN_CORP));
//        List<UserAccount> creatorUserAccountList = userAccountMapper.selectList(wrapper);
//        //非注册用户，非本军团成员不能PAP
//        if (creatorUserAccountList.isEmpty()) {
//            return;
//        }
//        UserAccount papCreator = creatorUserAccountList.get(0);
//        if (papCreator == null) {
//            return;
//        }
        papCreator.esiClient();
//        try {
//
//            CorporationApi corporationApi = new CorporationApi();
//            List<CorporationRolesResponse> corporationIdRoles =
//                    corporationApi.getCorporationsCorporationIdRoles(papCreator.getCorpId(), "", "", papCreator.getAccessToken());
//            // 角色ID=>是否是总监
//            List<Integer> directorList = new ArrayList<>();
//            for (CorporationRolesResponse role : corporationIdRoles) {
//                if (role.getRoles() != null && role.getRoles().stream().anyMatch(item -> item == CorporationRolesResponse.RolesEnum.DIRECTOR)) {
//                    directorList.add(role.getCharacterId());
//                }
//            }
//            boolean isDirector = creatorUserAccountList.stream().anyMatch(item -> directorList.contains(item.getCharacterId()));
//            if (!isDirector) {
//                return;
//            }
//        } catch (ApiException e) {
//            throw new RuntimeException(e);
//        }
        FleetsApi fleetsApi = new FleetsApi();
        Long fleetId = 0L;

        CharacterFleetResponse characterFleetResponse = null;
        try {
            characterFleetResponse = fleetsApi.getCharactersCharacterIdFleet(papCreator.getCharacterId(), null, null,
                    papCreator.getAccessToken());
        } catch (ApiException e) {
            throw new BizException("获取登陆用户所在的舰队信息失败，您可能不再一支舰队中，稍后再试.");
        }
        //非统帅不可登PAP
        fleetId = characterFleetResponse.getFleetId();
        if (characterFleetResponse.getFleetBossId().intValue() != papCreator.getCharacterId()) {
            log.warn("PAP creator is not boss:" + papCreator.getCharacterName());
            throw new BizException("当前用户不是舰队统帅，请检查游戏内信息.");
        }

        //开始登PAP
        String[] userList = sendPAPDto.getPapUsers().split("\n");
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
        QueryWrapper<UserAccount> cWapper = new QueryWrapper<UserAccount>().in("character_name", sendUserList);
        cWapper.eq(true, "corp_id", ConfigKit.get(CacheKey.EVE_MAIN_CORP));
        List<UserAccount> userAccountList = userAccountMapper.selectList(cWapper);

        if (userAccountList.isEmpty()) {
            throw new BizException("PAP发放失败,您复制的名单在系统中均未注册");
        }
        List<LpLog> list = baseMapper.selectList(new QueryWrapper<LpLog>().eq("user_id", StpUtil.getLoginId()).eq(
                "fleet_id", fleetId));
        if (!list.isEmpty()) {
            //做得好可以用缓存，简单做用数据库，这里考虑重复pap回滚之前的
            Map<Long, LpLog> lpLogMap =
                    list.stream().collect(Collectors.toMap(LpLog::getAccountId,
                            Function.identity(), (key1, key2) -> key1));
            for (UserAccount userAccount : userAccountList) {
                if (lpLogMap.get(userAccount.getId()) != null) {
                    userAccount.setLpNow(userAccount.getLpNow().subtract(lpLogMap.get(userAccount.getId()).getLp()));
                    userAccount.setLpTotal(userAccount.getLpTotal().subtract(lpLogMap.get(userAccount.getId()).getLp()));
                    userAccount.updateById();
                }
            }
            //重新删除重登陆
            baseMapper.delete(new QueryWrapper<LpLog>().eq("create_id", papCreator.getUserId()).eq(
                    "fleet_id",
                    fleetId));
        }
        List<LpLog> saveLogList = new ArrayList<>();
        for (UserAccount userAccount : userAccountList) {
            LpLog log = new LpLog();
            log.setCharacterName(userAccount.getCharacterName());
            log.setAccountId(userAccount.getId());
            log.setUserId(userAccount.getUserId());
            log.setLp(sendPAPDto.getPap());
            log.setSource(LpSource.CROP_PAP_TRANS);
            log.setType(LpType.INCOME);
            log.setContent(sendPAPDto.getWhere());
            log.setFleetId(fleetId);
            saveLogList.add(log);
            // 更新用户的LP
            userAccount.setLpNow(userAccount.getLpNow().add(sendPAPDto.getPap()));
            userAccount.setLpTotal(userAccount.getLpTotal().add(sendPAPDto.getPap()));
            userAccount.updateById();
        }
        baseMapper.batchInsert(saveLogList);
    }

    @Async("threadPoolTaskExecutor")
    public void alliancePapSync() {
        List<UserAccount> userAccountList = userAccountMapper.selectList(null);
        Map<String, String> papMap = accountApiService.getPap();
        for (UserAccount userAccount : userAccountList) {
            double alliancePap = Convert.toDouble(papMap.get(Convert.toStr(userAccount.getCharacterId())), 0D);
            userAccount.setPap(new BigDecimal(alliancePap));
            userAccount.updateById();
        }
    }
}
