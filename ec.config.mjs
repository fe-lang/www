import { defineEcConfig } from 'astro-expressive-code'
import fs from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const feGrammar = JSON.parse(fs.readFileSync(join(__dirname, 'src/fe.tmLanguage.json'), 'utf-8'))

export default defineEcConfig({
  shiki: {
    langs: [
      {
        ...feGrammar,
        id: 'fe',
        aliases: ['fe'],
      }
    ]
  }
})
