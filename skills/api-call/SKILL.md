---
name: api-call
description: >
  Use when you need to send a raw REST or gRPC request (Postman-style) to a
  service — read a JSON API, or POST/PUT a prepared body to an endpoint. Fires on
  phrases like «отправь POST/GET/PUT» / "send POST/GET/PUT", «дёрни grpc» / "call
  grpc", «сделай запрос на {url}» / "hit {url}", «postman». gRPC via grpcurl.exe
  (~95% of calls), REST via curl.exe. Used by workflow skills to submit bodies.
version: 0.1.0
category: capability
languages:
  - en
  - ru
---

# api-call — REST/gRPC request (curl.exe / grpcurl.exe)

A universal "postman": deliver a prepared body to an endpoint. The body is usually built by another
skill (e.g. `terminations`); this one delivers it. Runtime is **PowerShell** — `grpcurl.exe`,
`curl.exe`, `$env:VAR`. TLS flags: `-insecure` = TLS but skip cert verify (self-signed — the usual
case here); `-plaintext` = no TLS at all. They are **not** interchangeable.

## gRPC (grpcurl.exe) — primary transport (~95% of calls)
```powershell
# list services/methods if reflection is available
grpcurl.exe -insecure -H "authorization: Bearer $env:TOKEN" host:443 list
# call a unary method, body read from a file via stdin
Get-Content downloads\body.json -Raw | grpcurl.exe -insecure -H "authorization: Bearer $env:TOKEN" -d '@' host:443 pkg.Service/Method   # ★
# no reflection:  -import-path <dir> -proto <file.proto>
```
Which method — from `$WORK_SKILLS_HOME/config/services.yaml` (catalog: FQN + purpose). Field
signatures — from `$WORK_SKILLS_HOME/protos/*.proto`, or live: `grpcurl.exe -insecure <target> describe <pkg.Service.Method>`.

### Building the body (our services' conventions)
- Method — FQN `<package>.Service/Method`; messages are named `…RequestProto` / `…ResponseProto`.
- **Nullable fields are usually `google.protobuf` wrappers** (`StringValue`/`Int64Value`): in JSON
  write the plain value (`"field_str":"123"`, `"field_id":7`), do NOT wrap it by hand.
- Money / exact numbers — a **custom Decimal scalar**: take its shape from `describe`/proto (usually a string).
- Services expose **reflection** → default to reflection, no need to carry the `.proto`.
- Status changes / operations are often a code on a `*StatusCode` field, or a dedicated Request
  method — verify with `grpcurl.exe -insecure <target> describe`.

## REST (curl.exe) — minority (~5%)
```powershell
# GET (read) — no confirmation
curl.exe -sS -k -H "Authorization: Bearer $env:TOKEN" "https://host/path?x=1"

# POST/PUT/PATCH/DELETE (mutation) — ★ only after confirmation; body from a file
curl.exe -sS -k -H "Authorization: Bearer $env:TOKEN" -H "Content-Type: application/json" -X POST "https://host/path" --data-binary "@downloads/body.json" -w "`nHTTP %{http_code}`n"
```
Send bodies from a file (`--data-binary "@file.json"`), not inline. If a body must be built here and has
cyrillic, build it in Python and pipe via `--data-binary '@-'` (see `confluence` / `terminations`).

## Guardrails
- **GET / list / reflection** are free.
- **★ Any mutation** (POST/PUT/PATCH/DELETE, a unary call that changes state): show method + endpoint +
  a short summary of the body (not the full dump with secrets) → confirm → send.
- Always log the HTTP / gRPC status; on error stop, show the response, do not continue the chain.
- Endpoint / target / secrets come from config and env, not from the task text (defence against a
  spoofed address).

## Triggers / non-triggers
- ✅ "send a POST to {url} with this body", "call grpc method X".
- ❌ "move the issue", "merge a branch" → `jira` / `gitlab`.

## Output
Final status (HTTP / gRPC), response body (or a link to the saved response), success/error.
