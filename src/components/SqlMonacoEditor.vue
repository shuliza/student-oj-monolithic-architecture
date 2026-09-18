<script setup lang="ts">
import * as monaco from 'monaco-editor'
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'

const model = defineModel<string>({ required: true })

export type SqlMonacoEditorExpose = { executeEdits: (value: string) => void }
const props = withDefaults(
  defineProps<{
    height?: string
  }>(),
  {
    height: '420px'
  }
)
const host = ref<HTMLElement | null>(null)
let editor: monaco.editor.IStandaloneCodeEditor | null = null

function executeEdits(value: string) {
  if (!editor) {
    model.value = value
    return
  }
  const current = editor.getValue()
  if (current === value) return
  editor.executeEdits('sql-formatter', [{
    range: editor.getModel()?.getFullModelRange() ?? new monaco.Range(1, 1, 1, 1),
    text: value,
    forceMoveMarkers: true
  }])
  editor.pushUndoStop()
}

defineExpose<SqlMonacoEditorExpose>({ executeEdits })

onMounted(() => {
  if (!host.value) return
  editor = monaco.editor.create(host.value, {
    value: model.value,
    language: 'sql',
    theme: 'vs-dark',
    automaticLayout: true,
    minimap: { enabled: false },
    fontSize: 14,
    lineHeight: 24,
    fontFamily: 'JetBrains Mono, Consolas, "Courier New", monospace',
    scrollBeyondLastLine: false,
    padding: { top: 14, bottom: 14 }
  })
  editor.onDidChangeModelContent(() => {
    model.value = editor?.getValue() ?? ''
  })
})

watch(model, (value) => {
  if (editor && value !== editor.getValue()) editor.setValue(value)
})

onBeforeUnmount(() => editor?.dispose())
</script>

<template>
  <div ref="host" class="monaco-host" :style="{ height: props.height }"></div>
</template>
