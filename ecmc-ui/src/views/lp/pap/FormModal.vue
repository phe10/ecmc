<template>
  <BasicModal v-bind="$attrs" @register="registerModal" :title="getTitle" @ok="handleSubmit">
    <BasicForm @register="registerForm" />
  </BasicModal>
</template>
<script lang="ts" setup>
import { ref, unref } from 'vue'
import { BasicModal, useModalInner } from '/@/components/Modal'
import { BasicForm, useForm } from '/@/components/Form/index'
import { crudFormSchema } from './data'
import { useMessage } from '/@/hooks/web/useMessage'
import { sendPAP } from '/@/api/lp/pap'
const emit = defineEmits(['success', 'register'])
const isUpdate = ref(true)
const rowId = ref('')

const [registerForm, { setFieldsValue, resetFields, validate }] = useForm({
  labelWidth: 100,
  baseColProps: { span: 24 },
  schemas: crudFormSchema,
  showActionButtonGroup: false,
  actionColOptions: {
    span: 23,
  },
})
const { createMessage } = useMessage()
const getTitle = 'PAP发放'
const [registerModal, { setModalProps, closeModal }] = useModalInner(async (data) => {
  await resetFields()
  setModalProps({ confirmLoading: false })
  if (data.characterNames.length > 0){
    await setFieldsValue({
      papUsers: data.characterNames.join('\n')
    })
  }

})



async function handleSubmit() {
  try {
    const values = await validate()
    setModalProps({ confirmLoading: true })
    await sendPAP(values)
    createMessage.success('PAP登记成功！')
    closeModal()
    emit('success', { isUpdate: unref(isUpdate), values: { ...values, id: rowId.value } })
  } finally {
    setModalProps({ confirmLoading: false })
  }
}

</script>
