# MikroTik Manager (mikr.app)

Esegue [mikr.app](https://mikr.app) dentro Home Assistant: gestione centralizzata
di router MikroTik con RouterOS 7 (monitoraggio, backup pianificati con diff,
upgrade di massa, comandi, raccolta syslog, CVE, topologia).

L'app usa l'immagine Docker ufficiale `ghcr.io/hreskiv/mikr` senza modificarla:
aggiunge solo lo script di avvio che legge le opzioni di Home Assistant.

## Primo avvio

1. Avvia l'app e apri **Apri interfaccia web** (porta 3000).
2. Accedi con `admin` / `admin` (o con la password impostata in
   *Password admin iniziale*) e cambia la password quando richiesto.
3. Aggiungi i router. Su ogni router conviene creare un utente dedicato:

   ```
   /user/group/add name=manager-group policy=ssh,reboot,read,write,sensitive,rest-api,policy,ftp,test,api,!local,!telnet,!winbox,!password,!web,!sniff,!romon
   /user/add name=mikr group=manager-group password=...
   ```

   mikr legge via SSH (porta 22) e scrive via SSH o REST API (www-ssl, 443).
   Il firewall dei router deve accettare queste porte dall'IP di Home Assistant.

## Syslog

Per raccogliere i log dei router:

```
/system/logging/action/add name=mikr target=remote remote=<IP di Home Assistant> remote-port=5514
/system/logging/add topics=info action=mikr
```

La porta TCP 5514 è disattivata di default: abilitala nella sezione *Rete*
dell'app se ti serve.

## HTTPS

Con `ssl: true` l'interfaccia è disponibile anche su `https://<host>:3443`
usando i certificati in `/ssl` (gli stessi di Home Assistant, es. quelli
dell'app Let's Encrypt). Ricorda di abilitare la porta 3443 nella sezione *Rete*.

## Dati e backup

Database SQLite, segreti (`.secrets.json`) e backup `.rsc` stanno in `/data/mikr`
e sono inclusi nei backup di Home Assistant. **Non perdere `.secrets.json`**:
contiene la chiave che cifra le password dei router.

## Opzioni avanzate

Qualsiasi variabile documentata in
<https://mikr.app/docs/installation.html> si può passare in `env_vars`:

```yaml
env_vars:
  - name: DEFAULT_SSH_PORT
    value: "2222"
  - name: MONITOR_SNMP_FIRST
    value: "true"
```

## Integrazione con Home Assistant

Con *Metriche Prometheus* attive, mikr espone `/metrics`, utilizzabile dalla
app/integrazione Prometheus. I webhook di mikr possono puntare a un webhook
di un'automazione di Home Assistant (`http://<host>:8123/api/webhook/<id>`)
per ricevere notifiche di dispositivi offline, upgrade, ecc.

## Licenza

mikr.app non è open source: è soggetto alla
[EULA](https://mikr.app/eula.html). Il tier Community è gratuito fino a 10
dispositivi; oltre serve una licenza (una licenza = un container in esecuzione).
