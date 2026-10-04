/// <reference path="../../adonisrc.ts" />
/// <reference path="../../config/inertia.ts" />

import '../css/app.css'
import { createRoot } from 'react-dom/client'
import { createInertiaApp } from '@inertiajs/react'
import axios from 'axios'
import { resolvePageComponent } from '@adonisjs/inertia/helpers'
import { getLang, localize } from '~/i18n/runtime'
import ModalsProvider from '~/providers/ModalProvider'
import { TransmitProvider } from 'react-adonis-transmit'
import { generateUUID } from '~/lib/util'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import NotificationsProvider from '~/providers/NotificationProvider'
import { ThemeProvider } from '~/providers/ThemeProvider'
import { UsePageProps } from '../../types/system'

const appName = import.meta.env.VITE_APP_NAME || 'Project NOMAD'
const queryClient = new QueryClient()

// de: Inertia 2 loads every later page (Link, router.visit/reload) through the default axios
// instance with responseType "text" – translate those props like the initial page's.
// Inertia's getDataFromResponse() accepts the parsed object as well.
axios.interceptors.response.use((response) => {
  if (getLang() === 'en' || !response.headers['x-inertia']) return response
  let data = response.data
  if (typeof data === 'string') {
    try {
      data = JSON.parse(data)
    } catch {
      return response
    }
  }
  if (data?.props) {
    data.props = localize(data.props)
    response.data = data
  }
  return response
})

// Patch the global crypto object for non-HTTPS/localhost contexts
if (!window.crypto?.randomUUID) {
  // @ts-ignore
  if (!window.crypto) window.crypto = {}
  // @ts-ignore
  window.crypto.randomUUID = generateUUID
}

createInertiaApp({
  progress: { color: '#424420' },

  title: (title) => `${title} - ${appName}`,

  resolve: (name) => {
    return resolvePageComponent(`../pages/${name}.tsx`, import.meta.glob('../pages/**/*.tsx'))
  },

  setup({ el, App, props }) {
    props.initialPage.props = localize(props.initialPage.props)
    const environment = (props.initialPage.props as unknown as UsePageProps).environment
    const showDevtools = ['development', 'staging'].includes(environment)
    createRoot(el).render(
      <QueryClientProvider client={queryClient}>
        <ThemeProvider>
          <TransmitProvider baseUrl={window.location.origin} enableLogging={environment === 'development'}>
            <NotificationsProvider>
              <ModalsProvider>
                <App {...props} />
                {showDevtools && <ReactQueryDevtools initialIsOpen={false} buttonPosition='bottom-left' />}
              </ModalsProvider>
            </NotificationsProvider>
          </TransmitProvider>
        </ThemeProvider>
      </QueryClientProvider>
    )
  },
})
