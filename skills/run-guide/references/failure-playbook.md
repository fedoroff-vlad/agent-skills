# Failure playbook — common build/run walls and the one fix each

Each row: the signature in the logs → the likely cause → the smallest fix. Apply
ONE per loop iteration, record it in `journey-log.md`, retry. This is a starter
set; append rows as a project teaches you new walls.

## Build walls

| Log signature | Cause | Smallest fix |
|---|---|---|
| `invalid target release: 25`, `class file version` | Wrong JDK building | Select the version the map names (jenv/sdkman/`JAVA_HOME`); re-run. |
| `PKIX path building failed`, `unable to find valid certification path` | Corporate/self-signed cert not trusted | Import the cert into the JVM/toolchain trust store (`keytool -importcert` into `cacerts`), or set the build's truststore; re-run. |
| `Could not resolve dependencies`, `401/403` from a registry | Missing/authless internal registry | Configure the registry creds in the build config (`settings.xml` / `.npmrc`) — **ask the user** for the token. |
| `Could not find or load main class`, packaging errors | Wrong module build order in a multi-module repo | Build with reactor + upstream (`mvn -pl <m> -am`), or build the aggregator first. |
| OOM / killed during build | Build heap too small | Raise `MAVEN_OPTS`/`GRADLE_OPTS` `-Xmx`; re-run. |

## Run walls

| Log signature | Cause | Smallest fix |
|---|---|---|
| `Access denied for user`, `password authentication failed`, `Could not create connection` | DB creds absent/wrong | Collect the exact env keys; **ask the user** for values; write to local `.env`; retry. |
| `Connection refused`, `UnknownHostException`, `timed out` to an internal host | Backing service not forwarded | Map svc→port from deploy manifests; generate + run `port-forward.{sh,ps1}`; retry. |
| `NoSuchBeanDefinitionException`, `Could not resolve placeholder '${X}'` | Required config/env key unset | Set the key (non-secret from the map; secret from the user) in `.env`; retry. |
| `Port already in use`, `bind: address already in use` | Local port collision | Pick a free local port in the port-forward / app config; note it in RUN.md; retry. |
| Process starts then health check fails | Booted but dependency unhealthy | Hit the health endpoint, read WHICH dependency is down, fix that one; retry. |
| `SSLHandshakeException` at runtime to an internal endpoint | Same cert issue as build, runtime trust store | Add the cert to the runtime JVM truststore; retry. |

## Discipline

- The fix is almost always named in the **last** failure's output — quote that
  line before you theorize.
- A wall you cleared with a non-obvious fix is a RUN.md step. A wall you cleared
  by supplying a secret is a `.env` key (name only) + a RUN.md "you will be asked
  for" note.
- If two fixes seem needed, apply the one the log names first; the second may
  disappear once the first is in place.
