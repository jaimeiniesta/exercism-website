import React, { useEffect, useCallback, useMemo } from 'react'
import MonacoEditor from 'react-monaco-editor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'
import { listen, MessageConnection } from 'vscode-ws-jsonrpc'
import {
  MonacoLanguageClient,
  CloseAction,
  ErrorAction,
  MonacoServices,
  createConnection,
} from 'monaco-languageclient'
import normalizeUrl from 'normalize-url'
import ReconnectingWebsocket from 'reconnecting-websocket'
import { v4 as uuidv4 } from 'uuid'

export type FileEditorHandle = {
  getFile: () => File
}

type FileEditorProps = {
  file: File
  language: string
  onRunTests: () => void
}

const SAVE_INTERVAL = 500

export function ExercismMonacoEditor({
  width,
  height,
  language,
  editorDidMount,
  onRunTests,
  options,
  value,
  theme,
}: {
  width: string
  height: string
  language: string
  editorDidMount: (editor: monacoEditor.editor.IStandaloneCodeEditor) => void
  onRunTests: () => void
  options: monacoEditor.editor.IStandaloneEditorConstructionOptions
  value: string | null | undefined
  theme: string
}) {
  // const languageServerUrl: string = useMemo(() => {
  //   const languageServerHost = document.querySelector<HTMLMetaElement>(
  //     'meta[name="language-server-url"]'
  //   )?.content

  //   if (!languageServerHost) {
  //     throw 'Language server host not found'
  //   }

  //   return normalizeUrl(`${languageServerHost}/${language}/${uuidv4()}`)
  // }, [document, language, uuidv4])

  // useEffect(() => {
  //   const webSocket = new ReconnectingWebsocket(languageServerUrl, [], {
  //     maxReconnectionDelay: 10000,
  //     minReconnectionDelay: 1000,
  //     reconnectionDelayGrowFactor: 1.3,
  //     connectionTimeout: 10000,
  //     maxRetries: Infinity,
  //     debug: false,
  //   })

  //   listen({
  //     webSocket,
  //     onConnection: (connection) => {
  //       const languageClient = new MonacoLanguageClient({
  //         name: 'Language Client',
  //         clientOptions: {
  //           documentSelector: [language],
  //           errorHandler: {
  //             error: () => ErrorAction.Continue,
  //             closed: () => CloseAction.DoNotRestart,
  //           },
  //         },
  //         connectionProvider: {
  //           get: (errorHandler, closeHandler) => {
  //             return Promise.resolve(
  //               createConnection(connection, errorHandler, closeHandler)
  //             )
  //           },
  //         },
  //       })
  //       const disposable = languageClient.start()
  //       connection.onClose(() => disposable.dispose())
  //     },
  //   })

  //   return () => {
  //     webSocket.close()
  //   }
  // }, [languageServerUrl])

  const handleEditorDidMount = (
    editor: monacoEditor.editor.IStandaloneCodeEditor
  ) => {
    editor.addAction({
      id: 'runTests',
      label: 'Run tests',
      keybindings: [monacoEditor.KeyCode.F2],
      run: onRunTests,
    })

    MonacoServices.install(editor)
    editorDidMount(editor)
  }

  return (
    <MonacoEditor
      width="800"
      height="600"
      language={language}
      editorDidMount={handleEditorDidMount}
      options={options}
      value={value}
      theme={theme}
    />
  )
}