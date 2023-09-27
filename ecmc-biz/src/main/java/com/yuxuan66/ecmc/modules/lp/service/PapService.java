package com.yuxuan66.ecmc.modules.lp.service;

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
import com.yuxuan66.ecmc.modules.lp.entity.query.PapLogQuery;
import com.yuxuan66.ecmc.modules.lp.mapper.LpLogMapper;
import com.yuxuan66.ecmc.modules.lp.mapper.PapLogMapper;
import com.yuxuan66.ecmc.modules.system.entity.UsersRoles;
import com.yuxuan66.ecmc.modules.system.service.UserService;
import com.yuxuan66.ecmc.support.base.BaseService;
import com.yuxuan66.ecmc.support.exception.BizException;
import lombok.RequiredArgsConstructor;
import net.troja.eve.esi.ApiException;
import net.troja.eve.esi.api.CorporationApi;
import net.troja.eve.esi.api.FleetsApi;
import net.troja.eve.esi.model.*;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
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
public class PapService extends BaseService<PAPLog, PapLogMapper> {

    private final UserService userService;
    @Resource
    private UserAccountMapper userAccountMapper;

    @Resource
    private PapLogMapper papLogMapper;

    @Resource
    private EveCache eveCache;

    @Resource
    private UserAccountService userAccountService;

//    public Page<PAPLog> listPapLogByAccountId(PapLogQuery papLogQuery) {
//        return query()
//                .eq(papLogQuery.getAccountId() != null, "account_id", papLogQuery.getAccountId())
//                .eq(papLogQuery.getAccountId() == null, "user_id", StpUtil.getLoginId()).page(papLogQuery.getPageOrder());
//    }

//    public Page<PAPLog> listPapLog(PapLogQuery papLogQuery) {
//        if (!userService.getPermCode(StpUtil.getLoginId()).contains(Const.LP_SEND)) {
//            papLogQuery.setUserId(StpUtil.getLoginId());
//        }
//        return baseMapper.selectPapLog(papLogQuery.getPage(), papLogQuery);
//    }

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
            throw new BizException("获取登陆用户所在的舰队信息失败，可能ESI服务器存在问题，稍后再试.");
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
        List<PAPLog> list = papLogMapper.selectList(new QueryWrapper<PAPLog>().eq("user_id", StpUtil.getLoginId()).eq("fleet_id", fleetId));
        if (!list.isEmpty()) {
            Map<Long, PAPLog> papLogMap =
                    list.stream().collect(Collectors.toMap(PAPLog::getAccountId,
                            Function.identity(), (key1, key2) -> key1));
            for (UserAccount userAccount : userAccountList) {
                if (papLogMap.get(userAccount.getId()) != null) {
                    userAccount.setPap(userAccount.getPap().subtract(papLogMap.get(userAccount.getId()).getPap()));
                    userAccount.updateById();
                }
            }
            //重新删除重登陆
            papLogMapper.delete(new QueryWrapper<PAPLog>().eq("create_id", papCreator.getUserId()).eq(
                    "fleet_id",
                    fleetId));
        }
        List<PAPLog> saveLogList = new ArrayList<>();
        for (UserAccount userAccount : userAccountList) {
            PAPLog log = new PAPLog();
            log.setCharacterName(userAccount.getCharacterName());
            log.setAccountId(userAccount.getId());
            log.setUserId(userAccount.getUserId());
            log.setPap(sendPAPDto.getPap());
            log.setContent(sendPAPDto.getWhere());
            log.setCreateId(StpUtil.getLoginId());
            log.setCreateBy(sendPAPDto.getCreatedBy());
            log.setFleetId(fleetId);
            saveLogList.add(log);

            userAccount.setPap(userAccount.getPap().add(sendPAPDto.getPap()));
            userAccount.updateById();
            //更新total PAP
//            userAccountService.update(new UpdateWrapper<UserAccount>().eq("use_id", userAccount.getUserId()).set(
//                    "total_pap", userAccount.getTotalPap().add(sendPAPDto.getPap())));
        }

        baseMapper.batchPAPInsert(saveLogList);
    }

    public void papTransfor2Lp() {

    }
}
