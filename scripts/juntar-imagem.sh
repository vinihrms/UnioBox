#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Junta as partes da imagem da TV Box BTV B13 (.img.gz.part*) e valida SHA-256
# Uso: coloque este script na mesma pasta dos arquivos .part* e execute:
#   ./juntar-imagem.sh
# ==============================================================================

shopt -s nullglob
PARTS=( *.img.gz.part* )

if [ "${#PARTS[@]}" -eq 0 ]; then
  echo "Erro: nenhum arquivo '*.img.gz.part*' encontrado na pasta atual ($(pwd))."
  echo "Coloque todas as partes baixadas da Release na mesma pasta e execute novamente."
  exit 1
fi

# Ordena as partes em ordem lexicográfica (part00, part01, ...)
IFS=$'\n' SORTED_PARTS=($(printf '%s\n' "${PARTS[@]}" | sort))
unset IFS

FIRST_PART="${SORTED_PARTS[0]}"
OUTPUT_FILE="${FIRST_PART%.part*}"

echo "Partes encontradas (${#SORTED_PARTS[@]}):"
printf '  - %s\n' "${SORTED_PARTS[@]}"
echo ""
echo "Recombinando em: ${OUTPUT_FILE} ..."

cat "${SORTED_PARTS[@]}" > "${OUTPUT_FILE}"

echo "Arquivo gerado com sucesso: ${OUTPUT_FILE}"
ls -lh "${OUTPUT_FILE}"

if [ -f "SHA256SUMS.txt" ]; then
  echo ""
  echo "Validando integridade com SHA256SUMS.txt..."
  if command -v sha256sum >/dev/null 2>&1; then
    grep " ${OUTPUT_FILE}$" SHA256SUMS.txt | sha256sum -c -
  elif command -v shasum >/dev/null 2>&1; then
    grep " ${OUTPUT_FILE}$" SHA256SUMS.txt | shasum -a 256 -c -
  else
    echo "Aviso: nem 'sha256sum' nem 'shasum' encontrados. Pulando verificação."
  fi
else
  echo ""
  echo "Dica: baixe também o arquivo SHA256SUMS.txt da Release para validar a integridade."
fi

echo ""
echo "Pronto! Agora grave '${OUTPUT_FILE}' no cartão microSD usando BalenaEtcher, Raspberry Pi Imager ou dd."
