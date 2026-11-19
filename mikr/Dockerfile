# Immagine ufficiale e non modificata di mikr.app (multi-arch amd64/arm64).
# Per aggiornare: cambiare il tag qui e "version" in config.yaml.
FROM ghcr.io/hreskiv/mikr:2.8.0

COPY run.sh /run.sh
RUN chmod +x /run.sh

# L'entrypoint dell'immagine base (docker-entrypoint.sh di Node) non serve:
# run.sh prepara l'ambiente e poi esegue "node server.js".
ENTRYPOINT []
CMD ["/run.sh"]
