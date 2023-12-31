<template>
  <PageWrapper dense contentFullHeight contentClass="flex">
    <BasicTable @register="registerTable" :searchInfo="searchInfo">
      <template #toolbar>
        <a-button type="primary" @click="handleFly" preIcon="fly|svg">发放PAP</a-button>
      </template>
      <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'characterName'">
          <img class="table-head"
               :src="`https://images.evetech.net/characters/${record.characterId}/portrait?size=32`"
               alt=""/>
          <span style="margin-left: 10px">{{ record.characterName }}</span>
        </template>
        <template v-if="column.key === 'ship'">
          {{ record.ship }}
        </template>
        <template v-if="column.key === 'corpName'">
          <img class="table-head"
               :src="`https://images.evetech.net/corporations/${record.corpId}/logo?size=32`"
               alt=""/>
          <span style="margin-left: 10px">{{ record.corpName }}</span>
        </template>
        <template v-if="column.key === 'allianceName'">
          <img class="table-head"
               :src="`https://images.evetech.net/alliances/${record.allianceId}/logo?size=32`"
               alt=""/>
          <span style="margin-left: 10px">{{ record.allianceName }}</span>
        </template>
        <template v-if="column.key === 'action'">
          <TableAction
            :actions="[
              {
                icon: 'fly|svg',
                tooltip: '发放LP',
                onClick: handleFly.bind(null, record),
              }
            ]"
          />
        </template>
        <template v-if="column.key === 'commander'">
          <img class="table-head"
               :src="`https://images.evetech.net/characters/${record.commanderId}/portrait?size=32`"
               alt=""/>
          <span style="margin-left: 10px">{{ record.commander }}</span>
        </template>
        <template v-if="column.key === 'createTime'">
          {{ record.createTime }}
        </template>
<!--        <template v-if="column.key === 'status'">-->
<!--          <Tag :color="record.status === 0 ? 'processing' : 'error'">-->
<!--            {{ record.status === 0 ? '正常' : (record.status === 1 ? '冻结' : '锁定') }}-->
<!--          </Tag>-->
<!--        </template>-->
      </template>
    </BasicTable>
    <FormModal @register="registerModal" @success="handleSuccess"/>
  </PageWrapper>
</template>
<script lang="ts" setup>
import { reactive } from 'vue'

import { BasicTable, TableAction, useTable } from '/@/components/Table'
import {  listMembers } from '/@/api/lp/pap'
import { PageWrapper } from '/@/components/Page'
import { Tag } from 'ant-design-vue'
import { useModal } from '/@/components/Modal'
import { columns, searchFormSchema } from './data'
import FormModal from './FormModal.vue'

const [registerModal, { openModal }] = useModal()
const searchInfo = reactive<Recordable>({})
const [registerTable, { reload, getSelectRows }] = useTable({
  title: 'PAP列表',
  api: listMembers,
  rowKey: 'characterName',
  columns,
  beforeFetch: handleBeforeFetch,
  defSort: {
    order: 'ua.createTime',
    orderBy: 'desc'
  },
  formConfig: {
    labelWidth: 120,
    schemas: searchFormSchema,
    autoSubmitOnEnter: true,
  },
  showIndexColumn: false,
  useSearchForm: true,
  showTableSetting: true,
  bordered: true,
  rowSelection: {
    type: 'checkbox',
  },
  actionColumn: {
    width: 120,
    title: '操作',
    dataIndex: 'action',
  },
})

// 表格请求之前，对参数进行处理
function handleBeforeFetch(params) {
  return { ...params, all: true }
}

function handleFly(record: Recordable) {
  let characterNames:any = []
  if (record.characterName) {
    characterNames.push(record.characterName)
  } else {
    let rows = getSelectRows()
    rows.forEach(item => characterNames.push(item.characterName))
  }
  openModal(true, {
    characterNames,
    isUpdate: true,
  })
}


function handleSuccess() {
  reload()
}


</script>
