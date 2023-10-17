package com.yuxuan66.ecmc.job.modules;

import cn.hutool.core.convert.Convert;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.ReUtil;
import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpUtil;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.yuxuan66.ecmc.cache.ConfigKit;
import com.yuxuan66.ecmc.cache.EveCache;
import com.yuxuan66.ecmc.cache.key.CacheKey;
import com.yuxuan66.ecmc.common.utils.Lang;
import com.yuxuan66.ecmc.modules.account.entity.UserAccount;
import com.yuxuan66.ecmc.modules.account.mapper.UserAccountMapper;
import com.yuxuan66.ecmc.modules.data.entity.Member;
import com.yuxuan66.ecmc.modules.data.mapper.MemberMapper;
import com.yuxuan66.ecmc.modules.data.service.MemberService;
import com.yuxuan66.ecmc.modules.system.entity.User;
import com.yuxuan66.ecmc.modules.system.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.troja.eve.esi.api.CorporationApi;
import net.troja.eve.esi.model.CorporationMemberTrackingResponse;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * @author Sir丶雨轩
 * @since 2022/12/24
 */
@Slf4j
@Component
@Transactional(rollbackFor = Exception.class)
@RequiredArgsConstructor
public class CorpMemberJob {

    @Resource
    private UserMapper userMapper;
    private final EveCache eveCache;
    @Resource
    private MemberMapper memberMapper;
    @Resource
    private UserAccountMapper userAccountMapper;

    @Resource
    private MemberService memberService;

    @Scheduled(cron = "0 58 * ? * *")
    public void process() throws Exception {
        memberService.syncCropMember();
    }

    /**
     * 获取没有在SEAT中的用户
     *
     * @return 用户列表
     */
    public List<Integer> getNotSeatMember() {
        String charactorId = ConfigKit.get(CacheKey.SEAT_COOKIE_CID);
        HttpRequest request = HttpUtil.createGet("https://seat.winterco" +
                ".space/corporation/view/tracking/" + charactorId + "/membertracking?draw=3&columns%5B0%5D%5Bdata%5D=refresh_token" +
                "&columns%5B0%5D%5Bname%5D=user.refresh_token&columns%5B0%5D%5Bsearchable%5D=false&columns%5B0%5D%5Borderable%5D=false&columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B1%5D%5Bdata%5D=character_id&columns%5B1%5D%5Bname%5D=character_id&columns%5B1%5D%5Bsearchable%5D=true&columns%5B1%5D%5Borderable%5D=true&columns%5B1%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B1%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B2%5D%5Bdata%5D=location&columns%5B2%5D%5Bname%5D=location&columns%5B2%5D%5Bsearchable%5D=true&columns%5B2%5D%5Borderable%5D=true&columns%5B2%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B2%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B3%5D%5Bdata%5D=start_date&columns%5B3%5D%5Bname%5D=start_date&columns%5B3%5D%5Bsearchable%5D=false&columns%5B3%5D%5Borderable%5D=true&columns%5B3%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B3%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B4%5D%5Bdata%5D=logon_date&columns%5B4%5D%5Bname%5D=logon_date&columns%5B4%5D%5Bsearchable%5D=false&columns%5B4%5D%5Borderable%5D=true&columns%5B4%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B4%5D%5Bsearch%5D%5Bregex%5D=false&order%5B0%5D%5Bcolumn%5D=0&order%5B0%5D%5Bdir%5D=desc&start=0&length=1000&search%5Bvalue%5D=&search%5Bregex%5D=false&selected_refresh_token_status=missing_users&_=1671865308372");
        request.cookie(ConfigKit.get(CacheKey.SEAT_COOKIE));
        request.header("referer", "https://seat.winterco.space/corporation/view/tracking/" + charactorId);
        request.header("x-requested-with", "XMLHttpRequest");
        JSONArray array = JSONObject.parseObject(request.execute().body()).getJSONArray("data");
        List<Integer> characterIdList = new ArrayList<>();
        for (Object o : array) {
            JSONObject obj = (JSONObject) o;
            String characterId = obj.getString("character_id");
            characterIdList.add(Convert.toInt(ReUtil.get("characters/(.*)/portrait", characterId, 1)));
        }
        return characterIdList;
    }
}
