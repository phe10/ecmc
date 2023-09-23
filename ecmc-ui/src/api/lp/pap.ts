import { defHttp } from '/@/utils/http/axios'

enum Api {
  Base = '/pap',
}
/**
 * 发放PAP
 * @param sendPAPInfo pap发放信息
 */
export const sendPAP = (sendPAPInfo?: object) => {
  return defHttp.post({ url: Api.Base+'/sendPAP', params: sendPAPInfo })
}

export const listMembers = (params: object) => {
  return defHttp.get<object>({ url: Api.Base + '/searchFleetMemebers', params })
}
