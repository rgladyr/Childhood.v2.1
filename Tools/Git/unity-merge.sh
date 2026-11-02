#!/bin/sh
# Git merge driver для YAML-ассетов Unity (сцены, префабы, ассеты).
#
# 1) UnityYAMLMerge сливает всё, что может, по объектам и свойствам.
# 2) Настоящие конфликты (одно свойство изменено в обеих ветках) git merge-file
#    помечает маркерами <<<<<<< / >>>>>>>, чтобы конфликт не решался молча
#    в пользу вливаемой ветки.
# 3) Для каждого конфликта печатается, какому объекту он принадлежит.
#
# Подключение (.git/config):
#   [merge "unityyamlmerge"]
#       name = Unity SmartMerge
#       driver = sh Tools/Git/unity-merge.sh %O %A %B %P
# Путь к UnityYAMLMerge.exe берётся из переменной UNITY_YAML_MERGE,
# иначе ищется по версии из ProjectSettings/ProjectVersion.txt.

BASE="$1"; OURS="$2"; THEIRS="$3"; FILE="$4"

TOOL="$UNITY_YAML_MERGE"
if [ -z "$TOOL" ]; then
    VER=$(sed -n 's/^m_EditorVersion: *//p' ProjectSettings/ProjectVersion.txt 2>/dev/null | tr -d '\r')
    for ROOT in "D:/Work/Unity Editors" "C:/Program Files/Unity/Hub/Editor"; do
        if [ -f "$ROOT/$VER/Editor/Data/Tools/UnityYAMLMerge.exe" ]; then
            TOOL="$ROOT/$VER/Editor/Data/Tools/UnityYAMLMerge.exe"
            break
        fi
    done
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Слить с заданной стороной для конфликтов: "" = base, -l = theirs, -r = ours.
# Инструмент может менять входные файлы, поэтому каждый раз берутся свежие копии.
smart() {
    cp "$BASE" "$TMP/b"; cp "$THEIRS" "$TMP/t"; cp "$OURS" "$TMP/o"
    "$TOOL" merge -h $1 --force --fallback none "$TMP/b" "$TMP/t" "$TMP/o" "$2" > "$TMP/log" 2>&1
}

if [ -n "$TOOL" ] && [ -f "$TOOL" ]; then
    if smart "" "$TMP/merged"; then
        cp "$TMP/merged" "$OURS"
        exit 0
    fi
    smart -r "$TMP/pre_ours"
    smart -l "$TMP/pre_theirs"
    cp "$TMP/merged" "$TMP/pre_base"
else
    echo "unity-merge: UnityYAMLMerge.exe не найден, обычное слияние git" >&2
    cp "$OURS" "$TMP/pre_ours"; cp "$BASE" "$TMP/pre_base"; cp "$THEIRS" "$TMP/pre_theirs"
fi

git merge-file -L "ours (текущая ветка)" -L base -L "theirs (вливаемая ветка)" \
    "$TMP/pre_ours" "$TMP/pre_base" "$TMP/pre_theirs"
RESULT=$?
cp "$TMP/pre_ours" "$OURS"

if [ $RESULT -ne 0 ]; then
    echo "unity-merge: конфликты в $FILE:" >&2
    awk '
        /^--- !u!/ { id=$3; sub(/^&/, "", id); t=$2; sub(/^!u!/, "", t); cur=id; ctype[id]=t; next }
        cur != "" && /^[A-Za-z]+:$/ && !(cur in cname) { n=$1; sub(/:$/, "", n); cname[cur]=n }
        cur != "" && /^  m_Name: / && ctype[cur] == 1 { n=$0; sub(/^  m_Name: /, "", n); goname[cur]=n }
        cur != "" && /^  m_GameObject: \{fileID: / { g=$0; gsub(/[^0-9]/, "", g); owner[cur]=g }
        /^<<<<<<< / { conf[++k]=cur }
        END {
            for (i = 1; i <= k; i++) {
                c = conf[i]; go = (ctype[c] == 1) ? c : owner[c]
                name = (go in goname) ? goname[go] : "?"
                printf "  - объект \"%s\", компонент %s (&%s)\n", name, cname[c], c > "/dev/stderr"
            }
        }' "$OURS"
fi
exit $RESULT
