#!/usr/bin/env python
"""Scan a Maven/Gradle repo and emit a grounded module map + build hints.

Facts only — parsed from real pom.xml / build.gradle files, nothing invented.
The skill's LLM step wraps this output into the repo-root AGENTS.md; it must NOT
guess build commands — take them from here.

Usage:  python scan_modules.py [repo_root]   (default: current dir)
"""
import os
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
SKIP = {"target", "build", "out", ".git", ".idea", "node_modules", "bin"}


def local(tag):
    return tag.split("}")[-1]


def child(el, name):
    for c in el:
        if local(c.tag) == name:
            return c
    return None


def text(el, name, default=""):
    c = child(el, name)
    return c.text.strip() if c is not None and c.text else default


def parse_pom(path):
    try:
        root = ET.parse(path).getroot()
    except Exception as e:  # noqa: BLE001
        return None
    parent = child(root, "parent")
    gid = text(root, "groupId") or (text(parent, "groupId") if parent is not None else "")
    aid = text(root, "artifactId")
    packaging = text(root, "packaging", "jar")
    name = text(root, "name")
    return {"gid": gid, "aid": aid, "packaging": packaging, "name": name}


def walk_poms(root):
    found = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP]
        if "pom.xml" in filenames:
            found.append(os.path.join(dirpath, "pom.xml"))
    return sorted(found)


def rel(path):
    return os.path.relpath(path, ROOT).replace("\\", "/")


def main():
    poms = walk_poms(ROOT)
    gradle = any(
        f in ("build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts")
        for _, _, fs in os.walk(ROOT)
        for f in fs
    )
    has_mvnw = os.path.exists(os.path.join(ROOT, "mvnw")) or os.path.exists(os.path.join(ROOT, "mvnw.cmd"))
    has_gradlew = os.path.exists(os.path.join(ROOT, "gradlew")) or os.path.exists(os.path.join(ROOT, "gradlew.bat"))

    print(f"# repo scan: {ROOT}\n")
    if poms:
        tool = "Maven"
        runner = "mvnw" if has_mvnw else "mvn"
        print(f"Build tool: **{tool}**  |  runner: `{runner}`  |  pom.xml found: {len(poms)}\n")
        print("## Карта модулей (из pom.xml)\n")
        print("| Путь | groupId:artifactId | packaging | name |")
        print("|---|---|---|---|")
        for p in poms:
            m = parse_pom(p)
            if not m or not m["aid"]:
                continue
            d = os.path.dirname(rel(p)) or "."
            coord = f"{m['gid']}:{m['aid']}" if m["gid"] else m["aid"]
            print(f"| `{d}` | `{coord}` | {m['packaging']} | {m['name']} |")
        print("\n## Команды сборки (подставь <module> = artifactId нужного модуля)\n")
        print("```bash")
        print(f"{runner} -T 4 -pl <module> -am verify        # модуль + зависимости, полный verify")
        print(f"{runner} -pl <module> -am test               # только unit-тесты модуля")
        print(f"{runner} -pl <module> -Dtest=<TestClass> test  # один тест-класс")
        print("```")
    elif gradle:
        runner = "gradlew" if has_gradlew else "gradle"
        print(f"Build tool: **Gradle**  |  runner: `{runner}`\n")
        print("## Команды сборки\n```bash")
        print(f"{runner} :<module>:build")
        print(f"{runner} :<module>:test --tests <TestClass>")
        print("```")
    else:
        print("No pom.xml / build.gradle found — не Maven и не Gradle? Проверь корень репы.")


if __name__ == "__main__":
    main()
