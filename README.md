<p align="center"><img src="mikr/logo.png" alt="mikr for Home Assistant" width="400"></p>

# mikr.app per Home Assistant

App (add-on) di Home Assistant che esegue [mikr.app](https://mikr.app),
il gestore self-hosted di router MikroTik RouterOS 7.

## Installazione

1. Impostazioni → App (Componenti aggiuntivi) → Store → ⋮ → **Repository**.
2. Aggiungi `https://github.com/Th3ABombs/mikr.app-homeassistant`.
3. Installa **MikroTik Manager (mikr.app)**, avvialo e apri l'interfaccia web.

Dettagli in [mikr/DOCS.md](mikr/DOCS.md).

## Aggiornare mikr

Cambia il tag in [mikr/Dockerfile](mikr/Dockerfile) e `version` in
[mikr/config.yaml](mikr/config.yaml), aggiorna il changelog e fai push:
Home Assistant proporrà l'aggiornamento.

mikr.app è software proprietario di terze parti (vedi la
[EULA](https://mikr.app/eula.html)); questo repository contiene solo il
pacchetto per Home Assistant.

Il codice di questo repository (configurazione e script di avvio) è
rilasciato con licenza [MIT](LICENSE).
