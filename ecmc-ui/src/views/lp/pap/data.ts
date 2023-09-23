import { BasicColumn, FormSchema } from '/@/components/Table'


export const columns: BasicColumn[] = [
  {
    title: '成员',
    dataIndex: 'characterName',
    width: 120,
  },
  {
    title: '舰船',
    dataIndex: 'ship',
    width: 120
  },
  {
    title: '军团',
    dataIndex: 'corpName',
    width: 120,
  },
  {
    title: '联盟',
    dataIndex: 'allianceName',
    width: 120,
  },
  {
    title: '舰队统帅',
    dataIndex: 'commander',
    width: 120
  },
  {
    title: 'PAP时间',
    dataIndex: 'createTime',
    width: 120
  },
]

export const searchFormSchema: FormSchema[] = [
  {
    field: 'blurry',
    component: 'Input',
    colProps: { span: 6 },
    componentProps: {
      placeholder: '输入角色名搜索',
    }
  },
]

export const crudFormSchema: FormSchema[] = [
  {
    field: 'papUsers',
    label: '发放名单',
    component: 'InputTextArea',
    required: true,
    componentProps: {
      rows: 15
    }
  },
  {
    field: 'pap',
    label: '发放数量',
    component: 'InputNumber',
    required: true,
    defaultValue: 1,
    componentProps: {
      rows: 8
    }
  },
  {
    field: 'where',
    label: '发放原因',
    component: 'InputTextArea',
    componentProps: {
      rows: 3
    }

  },
  // {
  //   field: 'createdBy',
  //   label: '登记人',
  //   component: 'InputTextArea',
  //   componentProps: {
  //     rows: 1
  //   }
  //
  // }
  // ,
  // {
  //   field: 'corp',
  //   label: '军团成员',
  //   component: 'RadioGroup',
  //   helpMessage: '选择后,系统中注册的非主军团成员无法获得LP',
  //   componentProps: {
  //     options: [
  //       { label: '是', value: true },
  //       { label: '否', value: false },
  //     ]
  //   },
  //   defaultValue: true
  //
  // },
]
