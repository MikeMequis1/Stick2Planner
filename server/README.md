# Stick2Planner — servidor de sincronização

Serviço pequeno em Dart/shelf, sem Flutter. Armazena blobs opacos por entidade,
com revisão por item, idempotência por `changeId` e cursor global de mudanças.

## Endpoints

| Método | Rota | Auth | Uso |
| --- | --- | --- | --- |
| GET | `/v1/health` | — | saúde/versão/serverId |
| POST | `/v1/sync` | token do dispositivo | push + pull em uma chamada |
| POST | `/v1/pair` | token de pareamento | troca por token do dispositivo |
| POST | `/v1/admin/pairing-tokens` | token admin | cria token de pareamento (TTL) |
| GET | `/v1/admin/devices` | token admin | lista dispositivos |
| POST | `/v1/admin/devices/<id>/revoke` | token admin | revoga dispositivo |

Push aplica apenas com `baseRev` igual à revisão atual; divergência devolve
`conflicts` com a versão do servidor. Reenvio do mesmo `changeId` devolve o ack
anterior. Pull retorna mudanças após `since` com o estado atual da entidade.

## Variáveis

| Variável | Padrão | Descrição |
| --- | --- | --- |
| `PORT` | `8090` | porta HTTP |
| `DB_PATH` | `data/planner-server.sqlite` | arquivo SQLite |
| `ADMIN_TOKEN` | — | obrigatório para servir/parear |
| `PUBLIC_URL` | — | URL exibida no pareamento |

## Docker Compose

```bash
cp .env.example .env
# edite ADMIN_TOKEN e PUBLIC_URL
docker compose build
docker compose up -d
docker compose ps
curl -fsS http://127.0.0.1:8090/v1/health
```

O volume nomeado `planner-data` guarda o SQLite. Backup:

```bash
docker run --rm -v stick2planner_planner-data:/data -v "$PWD/backups:/backup" \
  debian:bookworm-slim sh -c 'apt-get update -qq && apt-get install -y -qq sqlite3 >/dev/null && sqlite3 /data/planner-server.sqlite ".backup /backup/planner-$(date +%F).sqlite"'
```

## Pareamento

```bash
docker compose exec api /app/bin/server pair 300
```

Saída (uma vez, com TTL):

```json
{
  "url": "http://192.168.219.130:8090",
  "serverId": "…",
  "pairingToken": "…",
  "expiresAt": "2026-11-04T…Z"
}
```

Esse JSON é o conteúdo do QR de pareamento. O app troca o token em `/v1/pair`
e recebe um token individual, guardado apenas no armazenamento seguro.

## Dispositivos

```bash
docker compose exec api /app/bin/server devices
docker compose exec api /app/bin/server revoke <deviceId>
```

## Testes

```bash
dart pub get
dart analyze
dart test
```

## Página web de pareamento

Abra `https://planner.<tailnet>.ts.net/` (ou o endereço usado para o serviço) no
navegador e informe o `ADMIN_TOKEN` para entrar. A página mostra:

- QR Code de pareamento **renovado automaticamente** enquanto estiver aberta
  (TTL de 5 min, renovação em 4,5 min);
- código textual equivalente para colar no app;
- dispositivos pareados, último acesso e botão de revogação;
- botão de sair (sessão em memória, cookie `HttpOnly`/`SameSite=Strict`).

O CLI continua disponível para automação:

```bash
docker compose exec api /app/bin/server pair 300
```

A página e as APIs `/api/pairing`, `/api/devices` exigem sessão administrativa;
sem cookie, retornam a tela de login/401. Não exponha a página fora da
LAN/Tailnet.

## Tailscale / tsdproxy

O serviço pode ser exposto por HTTPS no Tailnet usando o `tsdproxy` já presente
no host:

```yaml
labels:
  tsdproxy.enable: "true"
  tsdproxy.name: "planner"
  tsdproxy.container_port: "8090"
  tsdproxy.ephemeral: "false"
```

- URL resultante: `https://planner.<tailnet>.ts.net`.
- O nó novo exige **uma autorização manual** no Tailscale (dashboard do
  tsdproxy ou link de login). Autorizações seguintes reaproveitam o estado em
  `tsdproxy_data`.
- `tsdproxy.ephemeral: "false"` mantém o nó registrado ao recriar o container.
- `PUBLIC_URL` no `.env` deve usar a URL HTTPS para que o pareamento gere QR com
  o endereço correto.
- O tráfego é WireGuard do Tailscale; não é necessário publicar 8090 na
  internet.

## Segurança

- Tokens são guardados como SHA-256; comparação em tempo constante.
- Tokens de pareamento são de uso único e expiram.
- Corpo limitado a 8 MB, payload a 1 MB e lote a 500 mudanças.
- Sem logs de token ou payload.
- Exposição esperada: LAN ou Tailscale, porta 8090; sem publicar na internet.
- `data/` e `.env` são ignorados pelo git.
