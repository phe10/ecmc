package com.yuxuan66.ecmc.modules.lp.rest;

import com.yuxuan66.ecmc.modules.lp.entity.dto.SendLpDto;
import com.yuxuan66.ecmc.modules.lp.entity.dto.SendPAPDto;
import com.yuxuan66.ecmc.modules.lp.entity.query.FleetMemebersQuery;
import com.yuxuan66.ecmc.modules.lp.entity.query.LpLogQuery;
import com.yuxuan66.ecmc.modules.lp.service.LpService;
import com.yuxuan66.ecmc.modules.lp.service.PapService;
import com.yuxuan66.ecmc.support.base.BaseController;
import com.yuxuan66.ecmc.support.base.resp.Ps;
import com.yuxuan66.ecmc.support.base.resp.Rs;
import org.springframework.web.bind.annotation.*;

/**
 * @author Sir丶雨轩
 * @since 2022/12/13
 */
@RestController
@RequestMapping(path = "/pap")
public class PapController extends BaseController<PapService> {

    /**
     * PAP统计
     *
     * @param sendPAPDto 发放信息
     */
    @PostMapping(path = "/sendPAP")
    public Rs sendPap(@RequestBody SendPAPDto sendPAPDto) {
        baseService.sendPAP(sendPAPDto);
        return Rs.ok();
    }

    @GetMapping(path = "/searchFleetMemebers")
    public Rs searchFleetMemebers(FleetMemebersQuery fleetMemebersQuery){
        return Rs.ok(baseService.fleetMemebers(fleetMemebersQuery));
    }
}
