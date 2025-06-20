#!/data/data/com.termux/files/usr/bin/bash

# ========= KONFIGURASI =========
API_KEY="GANTI_DENGAN_API_KAMU"
ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY"
# ===============================

# Warna ANSI
bold=$(tput bold)
normal=$(tput sgr0)
cyan=$(tput setaf 6)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
grey=$(tput setaf 8)

# Header tampilan
clear
echo "${cyan}"
echo "╔═════════════════════════════════════════════════╗"
echo "║          ⚙️  ${bold}AI PROMPT GENERATOR v1.0${normal}${cyan}  ⚙️         ║"
echo "╠═════════════════════════════════════════════════╣"
echo "║   Masukkan kalimat biasa dan ubah jadi prompt   ║"
echo "║   profesional, terstruktur, dan powerful 💡     ║"
echo "╚═════════════════════════════════════════════════╝"
echo "${normal}"

# Input pengguna
read -p "${yellow}Masukkan kalimat biasa:${normal} " user_input

# Template prompt
template_prompt="Saya akan memberikan input sederhana dari pengguna. Tugas kamu adalah mengubahnya menjadi prompt AI yang:
- Spesifik dan terstruktur
- Tidak terlalu panjang
- Langsung bisa dipakai model AI seperti GPT-4 atau Gemini
- Tanpa perlu tambahan penjelasan atau breakdown teknis

Input: \"$user_input\"

Buatkan prompt yang sudah siap pakai, padat, dan powerful:"

# Kirim ke Gemini
json_data=$(jq -n \
  --arg prompt "$template_prompt" \
  '{contents: [{parts: [{text: $prompt}]}]}')

echo -e "\n${grey}🔄 Mengirim ke Gemini...\n${normal}"
response=$(curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$json_data")

# Tampilkan hasil
echo "${green}=== Prompt AI Jadi ===${normal}"
echo "$response" | jq -r '.candidates[0].content.parts[0].text'

# Pilihan lanjut
echo -e "\n${cyan}🔘 Opsi:"
echo "[C] Copy ke clipboard (jika Termux API aktif)"
echo "[S] Simpan ke file"
echo "[Q] Keluar${normal}"

read -n 1 -p "Pilih opsi: " opsi
echo ""

case $opsi in
  C|c)
    if command -v termux-clipboard-set >/dev/null; then
      echo "$response" | jq -r '.candidates[0].content.parts[0].text' | termux-clipboard-set
      echo "${green}✅ Disalin ke clipboard.${normal}"
    else
      echo "${red}❌ Termux API tidak ditemukan. Install dengan: pkg install termux-api${normal}"
    fi
    ;;
  S|s)
    file="prompt_output_$(date +%s).txt"
    echo "$response" | jq -r '.candidates[0].content.parts[0].text' > "$file"
    echo "${green}✅ Disimpan sebagai ${file}${normal}"
    ;;
  *)
    echo "${grey}Selesai.${normal}"
    ;;
esac
