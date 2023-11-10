package com.yuxuan66.ecmc.modules.data.service;

import cn.hutool.core.convert.Convert;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.ReUtil;
import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpUtil;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.yuxuan66.ecmc.cache.ConfigKit;
import com.yuxuan66.ecmc.cache.EveCache;
import com.yuxuan66.ecmc.cache.key.CacheKey;
import com.yuxuan66.ecmc.common.utils.FileUtil;
import com.yuxuan66.ecmc.common.utils.Lang;
import com.yuxuan66.ecmc.modules.account.entity.UserAccount;
import com.yuxuan66.ecmc.modules.account.mapper.UserAccountMapper;
import com.yuxuan66.ecmc.modules.data.entity.Member;
import com.yuxuan66.ecmc.modules.data.entity.query.MemberQuery;
import com.yuxuan66.ecmc.modules.data.mapper.MemberMapper;
import com.yuxuan66.ecmc.modules.system.entity.User;
import com.yuxuan66.ecmc.modules.system.mapper.UserMapper;
import com.yuxuan66.ecmc.support.base.BaseService;
import com.yuxuan66.ecmc.support.base.resp.Ps;
import net.troja.eve.esi.api.CorporationApi;
import net.troja.eve.esi.model.CorporationMemberTrackingResponse;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * @author Sir丶雨轩
 * @since 2022/12/24
 */
@Service
public class MemberService extends BaseService<Member, MemberMapper> {

    /**
     * 获取查询条件
     * @param query 查询参数
     * @return 查询条件
     */
    private QueryWrapper<Member> getWrapper(MemberQuery query){
        query.processingBlurry("character_name", "nick_name");
        QueryWrapper<Member> wrapper = query.getQueryWrapper();
        wrapper.le(query.getDay() != null, "not_login_day", query.getDay());
        wrapper.eq(query.getCorpSystem()!=null,"corp_system",query.getCorpSystem());
        wrapper.eq(query.getSeatSystem()!=null,"seat_system",query.getSeatSystem());
        return wrapper;
    }

    /**
     * 分页查询军团成员列表
     * @param query 查询条件
     * @return 军团成员列表
     */
    public Ps list(MemberQuery query) {
        return Ps.ok(page(query.getPage(), getWrapper(query)));
    }

    /**
     * 导出军团成员列表
     * @param query 查询条件
     */
    public void download(MemberQuery query){
        FileUtil.exportExcel(preDownload(baseMapper.selectList(getWrapper(query))));
    }

    @Resource
    private UserAccountMapper userAccountMapper;

    @Resource
    private UserMapper userMapper;

    @Resource
    private EveCache eveCache;
    public void syncCropMember() throws Exception {
        UserAccount userAccount = userAccountMapper.selectById(1);
        userAccount.esiClient();
        CorporationApi corporationApi = new CorporationApi();
        List<CorporationMemberTrackingResponse> memberTracking = corporationApi.getCorporationsCorporationIdMembertracking(userAccount.getCorpId(), "", "", userAccount.getAccessToken());
        List<Member> memberList = new ArrayList<>();
        List<Integer> notSeatMember = getNotSeatMember();
        List<User> userList = userMapper.selectList(null);
        List<UserAccount> userAccountList = userAccountMapper.selectList(null);
        for (CorporationMemberTrackingResponse memberTrackingResponse : memberTracking) {
            Member member = new Member();
            member.setCharacterId(memberTrackingResponse.getCharacterId());
            member.setCharacterName(eveCache.getCharacterInfo(member.getCharacterId()).getName());
            // 判断是否在军团系统中存在
            List<UserAccount> accountList = userAccountList.stream().filter(item -> item.getCharacterId().equals(memberTrackingResponse.getCharacterId())).toList();
            if (accountList.isEmpty()) {
                member.setCorpSystem(false);
            } else {
                member.setCorpSystem(true);
                member.setAccountId(accountList.get(0).getId());
                member.setUserId(accountList.get(0).getUserId());
                member.setCharacterName(accountList.get(0).getCharacterName());
                userList.stream().filter(item -> item.getId().equals(member.getUserId())).findFirst().ifPresent(item -> member.setNickName(item.getNickName()));
            }
            // 获取上次登录时间
            OffsetDateTime logoffDate = memberTrackingResponse.getLogoffDate();
            if (logoffDate != null) {
                member.setLastLoginTime(Lang.get(logoffDate));
                member.setNotLoginDay((int) DateUtil.betweenDay(new Date(member.getLastLoginTime().getTime()), new Date(), true));
            }
            // 判断是否在SEAT中存在
            member.setSeatSystem(!notSeatMember.contains(member.getCharacterId()));
            memberList.add(member);

        }
        baseMapper.delete(null);
        baseMapper.batchInsert(memberList);
    }

    public List<Integer> getNotSeatMember() {
        String charactorId = ConfigKit.get(CacheKey.SEAT_COOKIE_CID);
        HttpRequest request = HttpUtil.createGet("https://seat.winterco.space/character/list/data?draw=4&columns%5B0%5D%5Bdata%5D=name_view&columns%5B0%5D%5Bname%5D=name&columns%5B0%5D%5Bsearchable%5D=true&columns%5B0%5D%5Borderable%5D=true&columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B1%5D%5Bdata%5D=corporation_id&columns%5B1%5D%5Bname%5D=corporation_id&columns%5B1%5D%5Bsearchable%5D=true&columns%5B1%5D%5Borderable%5D=true&columns%5B1%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B1%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B2%5D%5Bdata%5D=alliance_id&columns%5B2%5D%5Bname%5D=alliance_id&columns%5B2%5D%5Bsearchable%5D=true&columns%5B2%5D%5Borderable%5D=true&columns%5B2%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B2%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B3%5D%5Bdata%5D=security_status&columns%5B3%5D%5Bname%5D=security_status&columns%5B3%5D%5Bsearchable%5D=true&columns%5B3%5D%5Borderable%5D=true&columns%5B3%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B3%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B4%5D%5Bdata%5D=actions&columns%5B4%5D%5Bname%5D=actions&columns%5B4%5D%5Bsearchable%5D=false&columns%5B4%5D%5Borderable%5D=false&columns%5B4%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B4%5D%5Bsearch%5D%5Bregex%5D=false&order%5B0%5D%5Bcolumn%5D=0&order%5B0%5D%5Bdir%5D=desc&start=0&length=100&search%5Bvalue%5D=&search%5Bregex%5D=false&filtered=false&_=1697527339178");
        request.cookie(ConfigKit.get(CacheKey.SEAT_COOKIE));
        request.header("referer", "https://seat.winterco.space/corporation/view/tracking/"+charactorId);
        request.header("x-requested-with", "XMLHttpRequest");
        JSONArray array = JSONObject.parseObject(request.execute().body()).getJSONArray("data");
        List<Integer> characterIdList = new ArrayList<>();
        for (Object o : array) {
            JSONObject obj = (JSONObject) o;
            String characterId = obj.getString("character_id");
            characterIdList.add(Convert.toInt(characterId));
        }
        return characterIdList;
    }
}
