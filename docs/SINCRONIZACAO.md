# Conexão e sincronização

## Visão geral

O app é local-first: agenda, notas e Caixinha funcionam sem servidor. A
sincronização é **opcional** e acontece entre o SQLite local e um servidor
próprio. Nada é apagado do aparelho quando o servidor está fora do ar.

Três credenciais são diferentes:

| Item | Onde fica | Para que serve |
| --- | --- | --- |
| `ADMIN_TOKEN` | `.env` do servidor | entrar na página web de pareamento |
| token de pareamento | QR/código gerado pela página (TTL 5 min, uso único) | autorizar um aparelho |
| token do dispositivo | `flutter_secure_storage` no aparelho | autenticar sync e pull |

## Pré-requisitos

1. Servidor no ar (`docker compose ps` → `healthy`).
2. Aparelho alcançando o servidor por LAN ou Tailscale.
3. App instalado e aberto pelo menos uma vez (banco local criado).

Teste rápido no navegador: `https://planner.<tailnet>.ts.net/v1/health`.

## Fluxo de conexão (primeira vez)

### 1. Gerar o QR no servidor

1. Abra `https://planner.<tailnet>.ts.net/`.
2. Informe o `ADMIN_TOKEN` (está em `~/stick2planner/.env`).
3. A página mostra:
   - QR de pareamento (renovado enquanto a página estiver aberta);
   - código textual equivalente;
   - dispositivos já pareados.

O QR contém `{url, serverId, pairingToken}`. Ele **expira em 5 minutos** e só
pode ser usado uma vez.

### 2. Parear no app

No aparelho:

1. **Configurações → Sincronização**.
2. Toque em **Parear dispositivo**.
3. Escaneie o QR ou cole o código.
4. Confirme.

O pareamento faz tudo de uma vez:

- salva a URL do servidor;
- guarda o token do dispositivo no armazenamento seguro;
- habilita a sincronização automática;
- dispara um sync imediato.

**Não é necessário salvar a URL nem testar a conexão antes de parear.** O código
já carrega o endereço correto.

### 3. Conferir

A seção deve mostrar:

- **Pareado · N pendentes**
- último sync;
- último relatório/erro, se houver.

## O que cada botão faz

| Controle | Depende de pareamento? | Efeito |
| --- | --- | --- |
| Campo de endereço | não | apenas edita o texto |
| **Salvar endereço** | não | grava a URL; não autentica nem pareia |
| **Testar conexão** | não | consulta `/v1/health`; valida rede/URL, **não** pareia |
| **Parear dispositivo** | não | troca o código por um token e configura URL + token + automático |
| **Sincronizar agora** | **sim** | desabilitado até existir token; faz push/pull |
| **Sincronizar automaticamente** | **sim** | desabilitado até parear; liga os gatilhos |
| **Desconectar** | sim | apaga URL/token e desliga o automático; dados locais ficam |

Ordem recomendada:

1. (Opcional) digitar URL → **Testar conexão** → **Salvar endereço**;
2. **Parear dispositivo** (QR/código);
3. **Sincronizar agora**, se quiser forçar.

Em resumo: **testar não pareia; parear já configura; sincronizar só funciona
depois de parear.**

## Quando o sync acontece

- Na abertura/retomada do app.
- Após alteração local (debounce de ~2 s).
- Ao reconectar à rede.
- A cada ~15 min pelo WorkManager (best-effort, com rede).
- No botão **Sincronizar agora**.

Falhas não bloqueiam a interface: a fila local permanece e o erro aparece no
status.

## Notas e vínculos

- A **nota é uma unidade atômica**: título, tipo, Markdown, linhas/checklists,
  IDs e estado viajam juntos.
- Post-its vinculados carregam `noteId`; trechos copiados (`noteExcerpt`)
  continuam como snapshot independente.
- Excluir uma nota gera tombstone; os post-its vinculados são desvinculados
  localmente e sincronizados como alterações próprias.
- Ordem de aplicação no pull: **notas → post-its → histórico** (respeita FKs).
- Conflito: vence o maior `updatedAt`. A versão perdedora é preservada como
  `[Conflito] <título>`; no caso de nota, as linhas recebem novos IDs.
- Conteúdo idêntico não gera cópia; tombstone do servidor com conteúdo local
  gera cópia antes de excluir.

## Dispositivos e revogação

- Cada instalação tem `deviceId` próprio e token individual.
- Renomear/revogar: página web → lista de dispositivos.
- Token revogado → sync responde **401**; pareie novamente para voltar.
- O nome inicial vem do modelo Android; pode ser corrigido na página.

## Problemas comuns

| Sintoma | Causa provável | Ação |
| --- | --- | --- |
| `Failed host lookup` | MagicDNS/DNS privado no Android | usar `http://<ip-do-host>:8090` ou ajustar DNS privado/Tailscale |
| `Connection refused` | porta/URL errada ou túnel encerrado | **Testar conexão**, conferir `:8090` |
| **401** | token revogado/expirado | parear de novo |
| Pendências não caem | servidor fora ou erro de rede | ver último erro; tentar **Sincronizar agora** |
| QR expirado | passou de 5 min/uso único | gerar novo na página (renova sozinho) |
| Dispositivo aparece como “Tablet” | pareamento antigo | renomear na página ou parear com o app atualizado |

## Segurança

- Tokens não entram em backup, logs ou banco local.
- A página web exige `ADMIN_TOKEN`; sessão em memória com cookie HttpOnly.
- Serviço restrito à LAN/Tailnet; não publique a porta na internet.
- Revogar remove o acesso imediatamente.
