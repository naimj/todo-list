import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers'
import { Ziggy } from '@/ziggy' // si tu veux utiliser ziggy-js plus tard (inutile ici)
import '../css/app.css'

// 🚨 Protection de la fonction `route()` injectée via @routes
if (typeof route === 'function' && typeof Ziggy === 'object' && Ziggy.routes) {
  const originalRoute = route

  const safeRoute = function (name, params = {}, absolute = true) {
    if (typeof name !== 'string') {
      return originalRoute()
    }

    if (!Ziggy.routes[name]) {
      console.warn(`⚠️ La route '${name}' est absente de Ziggy.`)
      return '#'
    }

    return originalRoute(name, params, absolute)
  }

  Object.assign(safeRoute, originalRoute)
  window.route = safeRoute
}

// ✅ Inertia app with layout auto-detection
createInertiaApp({
  title: title => `${title} - MonApp`,
  resolve: name => {
    const pages = import.meta.glob('./Pages/**/*.vue', { eager: true })
    const page = pages[`./Pages/${name}.vue`]

    // 📦 Détection automatique du layout
    if (page.default.layout === undefined) {
      const isGuest = ['Login', 'Register', 'ForgotPassword', 'Cgu', 'ResetPassword'].includes(name)
      page.default.layout = isGuest
        ? (await import('./Layouts/GuestLayout.vue')).default
        : (await import('./Layouts/AuthLayout.vue')).default
    }

    return page
  },
  setup({ el, App, props, plugin }) {
    createApp({ render: () => h(App, props) })
      .use(plugin)
      .mount(el)
  }
})
