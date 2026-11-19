#!/bin/sh
# Avvio dell'app Home Assistant per mikr.app.
# Legge /data/options.json, lo traduce nelle variabili d'ambiente di mikr
# e avvia il server Node dell'immagine ufficiale.
set -eu

OPTIONS=/data/options.json
DATA_DIR=/data/mikr

log() { echo "[mikr-ha] $*"; }

# Dati persistenti: /app/data -> /data/mikr (così finiscono nei backup di HA).
mkdir -p "$DATA_DIR"
if [ ! -L /app/data ]; then
    # Se l'immagine contiene già file in /app/data (primo avvio), li copiamo.
    if [ -d /app/data ] && [ -n "$(ls -A /app/data 2>/dev/null)" ] && [ -z "$(ls -A "$DATA_DIR")" ]; then
        cp -a /app/data/. "$DATA_DIR"/
    fi
    rm -rf /app/data
    ln -s "$DATA_DIR" /app/data
fi

# Node è l'unico interprete disponibile nell'immagine (niente jq/bashio):
# genera righe "export VAR='valore'" con quoting sicuro per la shell.
ENV_FILE=$(mktemp)
OPTIONS="$OPTIONS" node > "$ENV_FILE" <<'JS'
const fs = require('fs');
const o = JSON.parse(fs.readFileSync(process.env.OPTIONS, 'utf8'));
const env = {};
const set = (k, v) => { if (v !== undefined && v !== null && v !== '') env[k] = String(v); };

// Default "::" di mikr fallisce se il kernel non ha IPv6: in HA usiamo IPv4.
set('HOST', '0.0.0.0');
set('PORT', 3000);
set('HTTPS_PORT', 3443);
set('STORAGE_ADAPTER', 'sqlite');
set('LOG_LEVEL', o.log_level);
set('INITIAL_ADMIN_PASSWORD', o.initial_admin_password);
set('MONITOR_INTERVAL_MS', (o.monitor_interval_seconds || 60) * 1000);
set('SYSLOG_ENABLED', o.syslog_enabled ? 'true' : 'false');
set('SYSLOG_PORT', 5514);
set('CVE_ENABLED', o.cve_enabled ? 'true' : 'false');
set('NVD_API_KEY', o.nvd_api_key);
set('METRICS_ENABLED', o.metrics_enabled ? 'true' : 'false');
set('METRICS_TOKEN', o.metrics_token);
set('MCP_ENABLED', o.mcp_enabled ? 'true' : 'false');
if (o.ssl) {
  set('TLS_ENABLED', 'true');
  set('TLS_CERT_PATH', '/ssl/' + o.certfile);
  set('TLS_KEY_PATH', '/ssl/' + o.keyfile);
}
// Variabili avanzate (vedi https://mikr.app/docs/installation.html):
// hanno la precedenza sulle opzioni sopra.
for (const e of o.env_vars || []) set(e.name, e.value);

const q = (s) => "'" + s.replace(/'/g, "'\\''") + "'";
for (const [k, v] of Object.entries(env)) console.log(`export ${k}=${q(v)}`);
JS
# shellcheck disable=SC1090
. "$ENV_FILE"
rm -f "$ENV_FILE"

if [ "${TLS_ENABLED:-}" = "true" ]; then
    for f in "$TLS_CERT_PATH" "$TLS_KEY_PATH"; do
        [ -r "$f" ] || { log "ERRORE: certificato non trovato: $f"; exit 1; }
    done
    log "HTTPS attivo sulla porta 3443"
fi

log "Dati in $DATA_DIR, interfaccia web sulla porta 3000"
cd /app
exec node server.js
