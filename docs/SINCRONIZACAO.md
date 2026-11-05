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

## Obter o ADMIN_TOKEN

O servidor **não cria** o `ADMIN_TOKEN` sozinho: ele lê a variável do ambiente.
O processo é:

1. Gere um token forte no diretório `server/`:
   ```bash
   dart run bin/server token
   # alternativa: openssl rand -hex 32
   ```
   O comando imprime um valor aleatório e não altera o servidor em execução.
2. Grave o valor no arquivo `.env` do servidor:
   ```dotenv
   ADMIN_TOKEN=valor-gerado
   ```
3. Recrie o serviço para carregar o novo valor:
   ```bash
   docker compose up -d --force-recreate
   ```
4. Para consultar o valor já configurado:
   ```bash
   grep '^ADMIN_TOKEN=' .env
   ```
5. Use esse valor na tela de login da página web.

O `ADMIN_TOKEN` é uma senha administrativa; não é o token do aparelho. Alterá-lo
encerra as sessões web em memória, mas não revoga os dispositivos já pareados.
Mantenha o `.env` fora do Git e com permissão restrita.

## Pré-requisitos

1. Servidor no ar (`docker compose ps` → `healthy`).
2. Aparelho alcançando o servidor por LAN ou Tailscale.
3. App instalado e aberto pelo menos uma vez (banco local criado).

Teste rápido no navegador: `<PUBLIC_URL>/v1/health`.

## Fluxo de conexão (primeira vez)

### 1. Gerar o QR no servidor

1. Abra a URL configurada em `PUBLIC_URL` (LAN ou Tailscale).
2. Informe o `ADMIN_TOKEN` gerado no passo anterior.
3. A página mostra:
   - QR de pareamento (renovado enquanto a página estiver aberta);
   - código textual equivalente;
   - dispositivos já pareados.
4. Use o botão de idioma no topo para alternar **Português/English**; a escolha
   fica salva no navegador e a página atualiza sem recarregar.

O QR contém `{url, serverId, pairingToken}`. Ele **expira em 5 minutos** e só
pode ser usado uma vez.

### 2. Parear no app

No aparelho:

1. **Configurações → Conexão e sincronização**.
2. Toque em **Parear este dispositivo**.
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

O card de sincronização em **Configurações → Conexão e sincronização** mostra
apenas o estado e as ações. O endereço e o teste ficam na tela **Endereço e teste
de conexão**, aberta pelo botão de mesmo nome.

| Controle | Onde | Depende de pareamento? | Efeito |
| --- | --- | --- | --- |
| **Endereço e teste de conexão** | Configurações | não | abre a tela dedicada |
| Campo de endereço | tela de conexão | não | apenas edita o texto |
| **Salvar endereço** | tela de conexão | não | grava a URL; não autentica nem pareia |
| **Testar conexão** | tela de conexão | não | consulta `/v1/health`; valida rede/URL, **não** pareia |
| **Parear este dispositivo** | Configurações | não | troca o código por um token e configura URL + token + automático |
| **Sincronizar agora** | Configurações | **sim** | desabilitado até existir token; faz push/pull |
| **Sincronização automática** | Configurações | **sim** | desabilitado até parear; liga os gatilhos |
| **Desconectar deste servidor** | Configurações | sim | apaga URL/token e desliga o automático; dados locais ficam |

Ordem recomendada:

1. (Opcional) **Endereço e teste de conexão** → digitar URL →
   **Salvar endereço** → **Testar conexão**;
2. **Parear este dispositivo** (QR/código);
3. **Sincronizar agora**, se quiser forçar.

Em resumo: **testar não pareia; parear já configura; sincronizar só funciona
depois de parear.**

## Conferência antes de sincronizar

Antes de qualquer sync (manual, automático ou pela nuvem), o app consulta
`/v1/sync/stats` e conta os dados locais ativos:

- post-its;
- notas;
- eventos;
- tarefas;
- histórico.

Se os dois lados têm dados e as contagens de post-its/notas/eventos/tarefas são
diferentes, a operação é interrompida quando este é o primeiro sync ou quando
não há alterações locais pendentes na outbox. A tela mostra a comparação.
Escolha:

- **Manter local:** envia notas, post-its e eventos deste aparelho; o servidor
  passa a refletir este conjunto e remove o que não existe aqui (o histórico é
  preservado como auditoria);
- **Manter remoto:** substitui o conteúdo local pelo conjunto do servidor;
- **Cancelar:** não altera nenhum dos lados.

Quando há alterações locais pendentes, o sync normal continua: a diferença é
explicada por dados que ainda serão enviados. Se o sync automático encontrar a
divergência, ele **não sobrescreve nada**: fica em “Revisão necessária”, a nuvem
muda de estado e o usuário decide em Configurações → **Revisar agora**.

## Ícone de nuvem no topo

O ícone ao lado de Configurações resume o estado e abre **Configurações** já
rolada até a seção de sincronização:

| Ícone | Estado |
| --- | --- |
| nuvem cortada (cinza) | dispositivo não pareado |
| nuvem com sincronização | sync em andamento |
| nuvem cortada (vermelha) | último sync falhou |
| nuvem com seta para cima | há alterações pendentes |
| nuvem com check | pareado e sem pendências |

## Quando o sync acontece

- Na abertura/retomada do app.
- Após alteração local (debounce de ~2 s).
- Ao reconectar à rede.
- A cada ~15 min pelo WorkManager (best-effort, com rede).
- No botão **Sincronizar agora**.

Falhas não bloqueiam a interface: a fila local permanece e o erro aparece no
status. Se a conferência exigir escolha, o sync automático fica suspenso até o
usuário decidir.

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
