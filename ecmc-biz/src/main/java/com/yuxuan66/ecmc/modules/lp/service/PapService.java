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
import com.yuxuan66.ecmc.modules.lp.entity.LpLog;
import com.yuxuan66.ecmc.modules.lp.entity.PAPLog;
import com.yuxuan66.ecmc.modules.lp.entity.consts.LpSource;
import com.yuxuan66.ecmc.modules.lp.entity.consts.LpType;
import com.yuxuan66.ecmc.modules.lp.entity.dto.SendLpDto;
import com.yuxuan66.ecmc.modules.lp.entity.dto.SendPAPDto;
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
import net.troja.eve.esi.model.CharacterFleetResponse;
import net.troja.eve.esi.model.CorporationRolesResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;

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

    public Page<PAPLog> listPapLogByAccountId(PapLogQuery papLogQuery) {
        return query()
                .eq(papLogQuery.getAccountId() != null, "account_id", papLogQuery.getAccountId())
                .eq(papLogQuery.getAccountId() == null, "user_id", StpUtil.getLoginId()).page(papLogQuery.getPageOrder());
    }

    public Page<PAPLog> listPapLog(PapLogQuery papLogQuery) {
        if (!userService.getPermCode(StpUtil.getLoginId()).contains(Const.LP_SEND)) {
            papLogQuery.setUserId(StpUtil.getLoginId());
        }
        return baseMapper.selectPapLog(papLogQuery.getPage(), papLogQuery);
    }


    public void sendPAP(SendPAPDto sendPAPDto) {

        QueryWrapper<UserAccount> wrapper = new QueryWrapper<UserAccount>().in("character_name", sendPAPDto.getCreatedBy());
        wrapper.eq(true, "corp_id", ConfigKit.get(CacheKey.EVE_MAIN_CORP));
        List<UserAccount> creatorUserAccountList = userAccountMapper.selectList(wrapper);
        //非注册用户，非本军团成员不能PAP
        if (creatorUserAccountList.isEmpty()) {
            return;
        }
        UserAccount papCreator = creatorUserAccountList.get(0);
        if (papCreator == null) {
            return;
        }
        try {
            CorporationApi corporationApi = new CorporationApi();
            List<CorporationRolesResponse> corporationIdRoles =
                    corporationApi.getCorporationsCorporationIdRoles(papCreator.getCorpId(), "", "", papCreator.getAccessToken());
            // 角色ID=>是否是总监
            List<Integer> directorList = new ArrayList<>();
            for (CorporationRolesResponse role : corporationIdRoles) {
                if (role.getRoles() != null && role.getRoles().stream().anyMatch(item -> item == CorporationRolesResponse.RolesEnum.DIRECTOR)) {
                    directorList.add(role.getCharacterId());
                }
            }
            boolean isDirector = creatorUserAccountList.stream().anyMatch(item -> directorList.contains(item.getCharacterId()));
            if (!isDirector) {
                return;
            }
        } catch (ApiException e) {
            throw new RuntimeException(e);
        }
        FleetsApi fleetsApi = new FleetsApi();
        Long fleetId = 0L;
        //非统帅不可登PAP
        try {
            CharacterFleetResponse characterFleetResponse = fleetsApi.getCharactersCharacterIdFleet(papCreator.getCharacterId(), null, null,
                    papCreator.getAccessToken());
            fleetId = characterFleetResponse.getFleetId();
            if (characterFleetResponse.getFleetBossId().intValue() != papCreator.getCharacterId()) {
                log.warn("PAP creator is not boss:" + papCreator.getCharacterName());
                return;
            }
        } catch (ApiException e) {
            throw new RuntimeException(e);
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
        wrapper.eq(true, "corp_id", ConfigKit.get(CacheKey.EVE_MAIN_CORP));
        List<UserAccount> userAccountList = userAccountMapper.selectList(cWapper);

        if (userAccountList.isEmpty()) {
            throw new BizException("PAP发放失败,您复制的名单在系统中均为注册");
        }
        PapLogQuery papLogQuery = new PapLogQuery();
        papLogQuery.setUserId(StpUtil.getLoginId());
        papLogQuery.setAccountId(papCreator.getId());
        Page<PAPLog> logPage = listPapLogByAccountId(papLogQuery);
        if (logPage.getTotal() > 0) {
            //重新删除重登陆
            papLogMapper.delete(new QueryWrapper<PAPLog>().eq("create_id", papCreator.getUserId()).eq("fleet_id",
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

        }
        baseMapper.batchPAPInsert(saveLogList);
    }

}
