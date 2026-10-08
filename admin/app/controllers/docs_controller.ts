import { DocsService } from '#services/docs_service'
import { inject } from '@adonisjs/core'
import { parseLang } from '../../i18n/core.js'
import type { HttpContext } from '@adonisjs/core/http'

@inject()
export default class DocsController {
    constructor(
        private docsService: DocsService
    ) { }

    async list({ request }: HttpContext) {
        return await this.docsService.getDocs(parseLang(request.header('cookie')));
    }

    async show({ params, inertia, request }: HttpContext) {
        const content = await this.docsService.parseFile(params.slug, parseLang(request.header('cookie')));
        return inertia.render('docs/show', {
            content,
        });
    }
}