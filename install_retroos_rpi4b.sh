#!/bin/bash
# ============================================
# RETROOS - Instalador Completo para RPi4B
# Genera TODOS los archivos y carpetas necesarios
# ============================================

set -e

# ============================================
# CONFIGURACIÓN
# ============================================

VERSION="4.0-RPi4"
INSTALL_LOG="$HOME/retroos_rpi4_install.log"
RETROOS_DIR="$HOME/retroos_temp_rpi4"

# Directorios principales
BIOS_DIR="$HOME/.config/retroarch/system/bios"
ROM_DIR="$HOME/RetroROMs"
RETROARCH_DIR="$HOME/.config/retroarch"
PEGASUS_DIR="$HOME/.config/pegasus-frontend"
EMULATION_DIR="$HOME/.emulationstation"
THEMES_DIR="$HOME/.config/pegasus-frontend/themes"
CONTROLLER_DIR="$HOME/.config/retroarch/autoconfig"
SCRIPTS_DIR="$HOME"
DESKTOP_DIR="$HOME/Desktop"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# ============================================
# FUNCIONES
# ============================================

log() {
    echo -e "${BLUE}[RETROOS-RPi4]${NC} $1"
    echo "[$(date)] $1" >> "$INSTALL_LOG"
}

log_success() { echo -e "${GREEN}[✓]${NC} $1"; echo "[OK] $1" >> "$INSTALL_LOG"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; echo "[ERROR] $1" >> "$INSTALL_LOG"; exit 1; }
log_info() { echo -e "${YELLOW}[i]${NC} $1"; echo "[INFO] $1" >> "$INSTALL_LOG"; }
log_step() { echo -e "${CYAN}[➜]${NC} ${BOLD}$1${NC}"; echo "[STEP] $1" >> "$INSTALL_LOG"; }

print_banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║    ██████╗ ███████╗████████╗██████╗  ██████╗  ███████╗      ║"
    echo "║    ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗ ██╔════╝      ║"
    echo "║    ██████╔╝█████╗     ██║   ██████╔╝██║   ██║ ███████╗      ║"
    echo "║    ██╔══██╗██╔══╝     ██║   ██╔══██╗██║   ██║ ╚════██║      ║"
    echo "║    ██║  ██║███████╗   ██║   ██║  ██║╚██████╔╝ ███████║      ║"
    echo "║    ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚══════╝      ║"
    echo "║                                                              ║"
    echo "║           🚀 RETROOS PARA RASPBERRY PI 4B                   ║"
    echo "║                     Versión ${VERSION}                         ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# ============================================
# CREACIÓN DE ESTRUCTURA DE CARPETAS
# ============================================

create_directories() {
    log_step "Creando estructura de carpetas..."
    
    # Directorios principales
    mkdir -p "$ROM_DIR"/{nes,snes,genesis,n64,psx,gb,gba,neogeo,segacd,pce,dreamcast,atari,mame,3do,jaguar,lynx,ngp,wonderswan}
    mkdir -p "$BIOS_DIR"/{psx,n64,gb,gba,genesis,saturn,neogeo,atari,dreamcast,pce,segacd,3do,jaguar,lynx,ngp,wonderswan}
    mkdir -p "$RETROARCH_DIR"/{cores,saves,states,system,autoconfig,cheats,overlays,shaders,database,playlists}
    mkdir -p "$PEGASUS_DIR"/{themes,fonts,assets}
    mkdir -p "$EMULATION_DIR"/{themes,scripts}
    mkdir -p "$CONTROLLER_DIR"
    mkdir -p "$DESKTOP_DIR"
    
    log_success "Estructura de carpetas creada"
}

# ============================================
# CREACIÓN DE ARCHIVOS DE CONFIGURACIÓN
# ============================================

create_config_files() {
    log_step "Creando archivos de configuración..."
    
    # ============================================
    # 1. CONFIGURACIÓN DE RETROARCH
    # ============================================
    
    cat > "$RETROARCH_DIR/retroarch.cfg" << 'EOF'
# ============================================
# RETROOS RPi4 - Configuración RetroArch
# ============================================

# Video
video_driver = "gl"
video_ctx_driver = "egl"
video_fullscreen = true
video_smooth = true
video_vsync = true
video_threaded = true
video_hard_sync = true
video_frame_delay = 0
video_refresh_rate = 60
video_scale_integer = false
video_aspect_ratio = 1.777778
video_max_swapchain_images = 3
video_shared_context = true
video_allow_rotate = true
video_windowed_fullscreen = true
video_force_aspect = true
video_sync_refresh_rate = 60.00

# Audio
audio_driver = "pulse"
audio_latency = 64
audio_rate_control = true
audio_out_rate = 48000
audio_device = "default"
audio_enable = true
audio_disable_composition = true
audio_sync = true
audio_blocks = 2

# Menú
menu_driver = "ozone"
menu_show_advanced_settings = true
menu_show_core_updater = false
menu_show_online_updater = false
menu_show_restart_retroarch = true
menu_show_configurations = true
menu_show_information = true
menu_show_help = true
menu_show_quit_retroarch = true
menu_show_reboot = true
menu_show_shutdown = true

# Directorios
system_directory = "/home/pi/.config/retroarch/system"
savefile_directory = "/home/pi/.config/retroarch/saves"
savestate_directory = "/home/pi/.config/retroarch/states"
core_directory = "/home/pi/.config/retroarch/cores"
autoconfig_directory = "/home/pi/.config/retroarch/autoconfig"
cheat_database_path = "/home/pi/.config/retroarch/cheats"
overlay_directory = "/home/pi/.config/retroarch/overlays"
shader_directory = "/home/pi/.config/retroarch/shaders"
playlist_directory = "/home/pi/.config/retroarch/playlists"

# Input
input_autodetect_enable = true
input_joypad_driver = "udev"
input_udev_driver = "udev"
input_max_users = 4
input_player1_joypad_index = 0
input_player2_joypad_index = 1
input_player3_joypad_index = 2
input_player4_joypad_index = 3
input_axis_threshold = 0.5
input_analog_sensitivity = 1.0

# Configuración de botones por defecto
input_player1_a = "0"
input_player1_b = "1"
input_player1_x = "2"
input_player1_y = "3"
input_player1_l = "4"
input_player1_r = "5"
input_player1_l2 = "6"
input_player1_r2 = "7"
input_player1_l3 = "10"
input_player1_r3 = "11"
input_player1_select = "8"
input_player1_start = "9"
input_player1_up = "h0up"
input_player1_down = "h0down"
input_player1_left = "h0left"
input_player1_right = "h0right"

# Netplay
netplay_enable = false
netplay_ip_address = ""
netplay_port = 55435
netplay_mode = ""
netplay_spectate_password = ""

# BIOS Paths
bios_directory = "/home/pi/.config/retroarch/system/bios"

# Performance
rewind_enable = false
run_ahead_enabled = false

# Overlay
input_overlay_enable = false
input_overlay_show_physical_inputs = false

# Cheats
cheat_database_path = "/home/pi/.config/retroarch/cheats"
cheat_enable = false

# Playlists
playlist_entry_rename = false
playlist_entry_remove_duplicates = true
playlist_sort_alphabetical = true

# Logging
log_verbosity = 0
log_to_file = true
log_timestamp = true

# Other
fastforward_ratio = 0.0
slowmotion_ratio = 3.0
pause_nonactive = true
EOF

    # ============================================
    # 2. CONFIGURACIÓN DE PEGASUS
    # ============================================
    
    cat > "$PEGASUS_DIR/settings.txt" << 'EOF'
# ============================================
# RETROOS RPi4 - Configuración Pegasus FrontEnd
# ============================================

# Directorios de juegos
game_dirs:
  /home/pi/RetroROMs

# Tema
theme: /home/pi/.config/pegasus-frontend/themes/retroos

# Display
fullscreen: true
show_fps: false
force_aspect_ratio: 16:9
v-sync: true
window_width: 1920
window_height: 1080
max_fps: 60

# Comportamiento
exit_after_launch: false
remember_last_tab: true
start_in_game_collection: false
show_game_names: true
show_game_titles: true
show_game_platforms: true
show_game_developers: false
show_game_genres: false
show_game_years: true
show_game_ratings: false

# Lanzamiento
launch_command: /usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/{core}.so -c /home/pi/.config/retroarch/retroarch.cfg {file}
launch_timeout: 60
launch_cleanup: true

# Sonido
sound_enable: true
sound_volume: 100
sound_device: default

# Input
input_enable: true
input_device: 0
input_joypad_deadzone: 0.2
input_keyboard_enable: true

# Network
network_enable: true
network_port: 8080
network_password: ""

# Logging
log_level: info
log_file: "/home/pi/.config/pegasus-frontend/pegasus.log"
EOF

    # ============================================
    # 3. CONFIGURACIÓN DE EMULATIONSTATION
    # ============================================
    
    cat > "$EMULATION_DIR/es_systems.cfg" << 'EOF'
<?xml version="1.0"?>
<systemList>
    <system>
        <name>nes</name>
        <fullname>Nintendo Entertainment System</fullname>
        <path>/home/pi/RetroROMs/nes</path>
        <extension>.nes .NES .zip .ZIP</extension>
        <command>/usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/quicknes_libretro.so %ROM%</command>
        <platform>nes</platform>
        <theme>nes</theme>
    </system>
    <system>
        <name>snes</name>
        <fullname>Super Nintendo</fullname>
        <path>/home/pi/RetroROMs/snes</path>
        <extension>.smc .SMC .sfc .SFC .zip .ZIP</extension>
        <command>/usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/snes9x_libretro.so %ROM%</command>
        <platform>snes</platform>
        <theme>snes</theme>
    </system>
    <system>
        <name>genesis</name>
        <fullname>Sega Genesis</fullname>
        <path>/home/pi/RetroROMs/genesis</path>
        <extension>.smd .SMD .gen .GEN .bin .BIN .zip .ZIP</extension>
        <command>/usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/genesis_plus_gx_libretro.so %ROM%</command>
        <platform>genesis</platform>
        <theme>genesis</theme>
    </system>
    <system>
        <name>n64</name>
        <fullname>Nintendo 64</fullname>
        <path>/home/pi/RetroROMs/n64</path>
        <extension>.n64 .N64 .z64 .Z64 .v64 .V64</extension>
        <command>/usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/mupen64plus_libretro.so %ROM%</command>
        <platform>n64</platform>
        <theme>n64</theme>
    </system>
    <system>
        <name>psx</name>
        <fullname>PlayStation</fullname>
        <path>/home/pi/RetroROMs/psx</path>
        <extension>.cue .CUE .iso .ISO .bin .BIN .img .IMG</extension>
        <command>/usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/pcsx_rearmed_libretro.so %ROM%</command>
        <platform>psx</platform>
        <theme>psx</theme>
    </system>
    <system>
        <name>gba</name>
        <fullname>Game Boy Advance</fullname>
        <path>/home/pi/RetroROMs/gba</path>
        <extension>.gba .GBA .zip .ZIP</extension>
        <command>/usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/mgba_libretro.so %ROM%</command>
        <platform>gba</platform>
        <theme>gba</theme>
    </system>
    <system>
        <name>neogeo</name>
        <fullname>Neo Geo</fullname>
        <path>/home/pi/RetroROMs/neogeo</path>
        <extension>.zip .ZIP</extension>
        <command>/usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/fbalpha_libretro.so %ROM%</command>
        <platform>neogeo</platform>
        <theme>neogeo</theme>
    </system>
</systemList>
EOF

    log_success "Archivos de configuración creados"
}

# ============================================
# CREACIÓN DE ARCHIVOS DE BIOS Y DOCUMENTACIÓN
# ============================================

create_bios_files() {
    log_step "Creando archivos de BIOS y documentación..."
    
    # ============================================
    # 1. README DE BIOS
    # ============================================
    
    cat > "$BIOS_DIR/README_BIOS.txt" << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              RETROOS RPi4 - BIOS REQUIREMENTS               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

Para el correcto funcionamiento de los sistemas emulados, 
necesitas colocar los siguientes archivos BIOS en sus carpetas:

┌─────────────────────────────────────────────────────────────┐
│ PLAYSTATION (PSX)                                          │
├─────────────────────────────────────────────────────────────┤
│ Ubicación: ~/.config/retroarch/system/bios/psx/            │
│                                                             │
│ scph5500.bin  (Japón)    MD5: 8dd7d5296a650fac7319bce665a6a53c │
│ scph5501.bin  (USA)      MD5: 490f666e1afb15b7362b406ed1cea246 │
│ scph5502.bin  (Europa)   MD5: 32736f17079d0b2b7024407c39bd3050 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ NINTENDO 64 (N64)                                          │
├─────────────────────────────────────────────────────────────┤
│ Ubicación: ~/.config/retroarch/system/bios/n64/            │
│                                                             │
│ pifdata.bin                                                │
│ cxd4_1.bin                                                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ GAME BOY ADVANCE (GBA)                                     │
├─────────────────────────────────────────────────────────────┤
│ Ubicación: ~/.config/retroarch/system/bios/gba/            │
│                                                             │
│ gba_bios.bin                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ NEO GEO                                                    │
├─────────────────────────────────────────────────────────────┤
│ Ubicación: ~/.config/retroarch/system/bios/neogeo/         │
│                                                             │
│ neogeo.zip (contiene todos los archivos BIOS)              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ SEGA CD                                                    │
├─────────────────────────────────────────────────────────────┤
│ Ubicación: ~/.config/retroarch/system/bios/genesis/        │
│                                                             │
│ bios_CD_E.bin (Europa)                                     │
│ bios_CD_U.bin (USA)                                        │
│ bios_CD_J.bin (Japón)                                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ DREAMCAST                                                  │
├─────────────────────────────────────────────────────────────┤
│ Ubicación: ~/.config/retroarch/system/bios/dreamcast/      │
│                                                             │
│ dc_boot.bin                                                │
│ dc_flash.bin                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PC ENGINE / TURBOGRAFX                                     │
├─────────────────────────────────────────────────────────────┤
│ Ubicación: ~/.config/retroarch/system/bios/pce/            │
│                                                             │
│ syscard3.pce                                               │
│ cd_bios.pce                                                │
└─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════
NOTA: Estos archivos son PROPIETARIOS y debes obtenerlos 
de tus propias consolas. NO COMPARTAS archivos BIOS.
═══════════════════════════════════════════════════════════════
EOF

    # ============================================
    # 2. README DE ROMS
    # ============================================
    
    cat > "$ROM_DIR/README_ROMS.txt" << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              RETROOS RPi4 - ROMS INSTRUCTIONS                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

Coloca tus ROMs en las siguientes carpetas según el sistema:

┌─────────────────────────────────────────────────────────────┐
│ SISTEMA              CARPETA           FORMATOS            │
├─────────────────────────────────────────────────────────────┤
│ NES                  nes/              .nes, .zip          │
│ SNES                 snes/             .smc, .sfc, .zip    │
│ Genesis              genesis/          .smd, .gen, .zip    │
│ N64                  n64/              .n64, .z64, .v64    │
│ PlayStation          psx/              .cue, .bin, .iso    │
│ Game Boy             gb/               .gb, .gbc           │
│ Game Boy Advance     gba/              .gba, .zip          │
│ Neo Geo              neogeo/           .zip                │
│ Sega CD              segacd/           .cue, .bin          │
│ PC Engine            pce/              .pce, .zip          │
│ Dreamcast            dreamcast/        .cdi, .gdi          │
│ Atari                atari/            .a26, .bin          │
│ MAME                 mame/             .zip                │
│ 3DO                  3do/              .iso, .bin          │
│ Jaguar               jaguar/           .j64, .zip          │
│ Lynx                 lynx/             .lnx, .zip          │
│ Neo Geo Pocket       ngp/              .ngp, .zip          │
│ Wonderswan           wonderswan/       .ws, .wsc           │
└─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════
NOTA: Las ROMs son propiedad de los titulares de derechos.
Usa solo ROMs de juegos que poseas legalmente.
═══════════════════════════════════════════════════════════════
EOF

    # ============================================
    # 3. METADATA PARA PEGASUS
    # ============================================
    
    for system in nes snes genesis n64 psx gb gba neogeo; do
        cat > "$ROM_DIR/$system/metadata.txt" << EOF
collection: ${system^^}
shortname: $system
extensions: rom zip
launch: {core} = ${system}_core
EOF
    done

    log_success "Archivos de BIOS y documentación creados"
}

# ============================================
# CREACIÓN DE SCRIPTS DEL SISTEMA
# ============================================

create_system_scripts() {
    log_step "Creando scripts del sistema..."
    
    # ============================================
    # 1. SCRIPT DE INICIO PRINCIPAL
    # ============================================
    
    cat > "$SCRIPTS_DIR/start_retroos.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Lanzador Principal
# ============================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

clear
echo -e "${BOLD}${CYAN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║          🎮 RETROOS RPi4 LAUNCHER             ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${YELLOW}Selecciona una opción:${NC}"
echo ""
echo "  1) 🎮 Pegasus FrontEnd (Recomendado)"
echo "  2) 🖥️  Menú Gráfico RetroOS"
echo "  3) 🕹️  RetroArch (solo)"
echo "  4) 📺 EmulationStation"
echo "  5) ⚙️  Configuración del Sistema"
echo "  6) 🛠️  Herramientas"
echo "  7) 💾 Gestionar BIOS"
echo "  8) 📁 Gestionar ROMs"
echo "  9) 🔄 Actualizar RetroOS"
echo " 10) 🔌 Apagar Sistema"
echo " 11) ♻️ Reiniciar Sistema"
echo " 12) ❌ Salir"
echo ""
read -p "Opción: " choice

case $choice in
    1)
        echo -e "${GREEN}Iniciando Pegasus...${NC}"
        pegasus-frontend
        ;;
    2)
        echo -e "${GREEN}Iniciando menú gráfico...${NC}"
        python3 ~/retroos_gui.py
        ;;
    3)
        echo -e "${GREEN}Iniciando RetroArch...${NC}"
        retroarch
        ;;
    4)
        echo -e "${GREEN}Iniciando EmulationStation...${NC}"
        emulationstation
        ;;
    5)
        echo -e "${GREEN}Abriendo configuración...${NC}"
        sudo raspi-config
        ;;
    6)
        ~/tools_menu.sh
        ;;
    7)
        ~/manage_bios.sh
        ;;
    8)
        ~/manage_roms.sh
        ;;
    9)
        ~/update_retroos.sh
        ;;
    10)
        ~/shutdown_retroos.sh
        ;;
    11)
        ~/restart_retroos.sh
        ;;
    12)
        echo -e "${YELLOW}¡Hasta luego!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Opción inválida${NC}"
        sleep 2
        ~/start_retroos.sh
        ;;
esac
EOF

    # ============================================
    # 2. SCRIPT DE VERIFICACIÓN DE BIOS
    # ============================================
    
    cat > "$SCRIPTS_DIR/check_bios.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Verificador de BIOS
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BIOS_DIR="$HOME/.config/retroarch/system/bios"

clear
echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       RETROOS RPi4 - Verificador BIOS         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
echo ""

check_file() {
    if [ -f "$BIOS_DIR/$1" ]; then
        SIZE=$(du -h "$BIOS_DIR/$1" 2>/dev/null | cut -f1)
        echo -e "${GREEN}✓${NC} $2 ($SIZE)"
        return 0
    else
        echo -e "${RED}✗${NC} $2 (NO ENCONTRADO)"
        return 1
    fi
}

echo -e "${YELLOW}=== PLAYSTATION ===${NC}"
check_file "psx/scph5500.bin" "BIOS PSX Japón"
check_file "psx/scph5501.bin" "BIOS PSX USA"
check_file "psx/scph5502.bin" "BIOS PSX Europa"
echo ""

echo -e "${YELLOW}=== NINTENDO 64 ===${NC}"
check_file "n64/pifdata.bin" "BIOS N64"
echo ""

echo -e "${YELLOW}=== GAME BOY ADVANCE ===${NC}"
check_file "gba/gba_bios.bin" "BIOS GBA"
echo ""

echo -e "${YELLOW}=== NEO GEO ===${NC}"
check_file "neogeo/neogeo.zip" "BIOS Neo Geo"
echo ""

echo -e "${YELLOW}=== SEGA CD ===${NC}"
check_file "genesis/bios_CD_E.bin" "BIOS Sega CD Europa"
check_file "genesis/bios_CD_U.bin" "BIOS Sega CD USA"
check_file "genesis/bios_CD_J.bin" "BIOS Sega CD Japón"
echo ""

echo -e "${YELLOW}=== DREAMCAST ===${NC}"
check_file "dreamcast/dc_boot.bin" "BIOS Dreamcast Boot"
check_file "dreamcast/dc_flash.bin" "BIOS Dreamcast Flash"
echo ""

echo -e "${YELLOW}=== PC ENGINE ===${NC}"
check_file "pce/syscard3.pce" "BIOS Super System Card"
check_file "pce/cd_bios.pce" "BIOS PC Engine CD"
echo ""

echo -e "${BLUE}Total de archivos BIOS: $(find $BIOS_DIR -type f 2>/dev/null | wc -l)${NC}"
echo ""
read -p "Presiona Enter para continuar..."
EOF

    # ============================================
    # 3. SCRIPT DE GESTIÓN DE BIOS
    # ============================================
    
    cat > "$SCRIPTS_DIR/manage_bios.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Gestor de BIOS
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BIOS_DIR="$HOME/.config/retroarch/system/bios"

show_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        RETROOS RPi4 - Gestor de BIOS          ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1) 🔍 Verificar BIOS"
    echo "2) 📋 Listar BIOS instaladas"
    echo "3) 📂 Copiar BIOS desde USB"
    echo "4) 📂 Copiar BIOS desde red"
    echo "5) 🗑️ Eliminar BIOS"
    echo "6) 📖 Ver documentación"
    echo "7) 🔙 Volver"
    echo ""
    read -p "Opción: " option
}

list_bios() {
    echo -e "${YELLOW}BIOS instaladas:${NC}"
    find $BIOS_DIR -type f -name "*.bin" -o -name "*.zip" 2>/dev/null | while read file; do
        SIZE=$(du -h "$file" | cut -f1)
        echo "  📄 $(basename "$file") ($SIZE)"
    done
    echo ""
    echo -e "${YELLOW}Tamaño total:${NC} $(du -sh $BIOS_DIR 2>/dev/null | cut -f1)"
    read -p "Presiona Enter para continuar..."
}

copy_bios_usb() {
    echo -e "${YELLOW}Copiando BIOS desde USB...${NC}"
    sudo mount /dev/sda1 /mnt 2>/dev/null || sudo mount /dev/sdb1 /mnt 2>/dev/null
    if [ -d "/mnt/bios" ]; then
        cp -r /mnt/bios/* $BIOS_DIR/
        echo -e "${GREEN}BIOS copiadas correctamente${NC}"
    else
        echo -e "${RED}No se encontraron BIOS en USB${NC}"
    fi
    sudo umount /mnt 2>/dev/null
    read -p "Presiona Enter para continuar..."
}

copy_bios_network() {
    echo -e "${YELLOW}Copiando BIOS desde red...${NC}"
    read -p "IP del servidor: " ip
    read -p "Usuario: " user
    read -p "Ruta: " path
    rsync -avz $user@$ip:$path/ $BIOS_DIR/
    echo -e "${GREEN}BIOS copiadas correctamente${NC}"
    read -p "Presiona Enter para continuar..."
}

delete_bios() {
    echo -e "${YELLOW}Selecciona BIOS a eliminar:${NC}"
    select file in $(find $BIOS_DIR -type f -name "*.bin" -o -name "*.zip" 2>/dev/null); do
        if [ -n "$file" ]; then
            rm "$file"
            echo -e "${GREEN}Eliminado: $file${NC}"
        else
            echo -e "${RED}Opción inválida${NC}"
        fi
        break
    done
    read -p "Presiona Enter para continuar..."
}

while true; do
    show_menu
    case $option in
        1) ~/check_bios.sh ;;
        2) list_bios ;;
        3) copy_bios_usb ;;
        4) copy_bios_network ;;
        5) delete_bios ;;
        6) less $BIOS_DIR/README_BIOS.txt ;;
        7) break ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac
done
EOF

    # ============================================
    # 4. SCRIPT DE GESTIÓN DE ROMS
    # ============================================
    
    cat > "$SCRIPTS_DIR/manage_roms.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Gestor de ROMs
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ROM_DIR="$HOME/RetroROMs"

show_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        RETROOS RPi4 - Gestor de ROMs          ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1) 📊 Ver ROMs instaladas"
    echo "2) 📂 Copiar ROMs desde USB"
    echo "3) 📂 Copiar ROMs desde red"
    echo "4) 🗑️ Eliminar ROMs"
    echo "5) 📊 Ver espacio usado"
    echo "6) 🔄 Organizar ROMs automáticamente"
    echo "7) 🔍 Verificar integridad"
    echo "8) 🔙 Volver"
    echo ""
    read -p "Opción: " option
}

list_roms() {
    echo -e "${YELLOW}Sistemas y cantidad de ROMs:${NC}"
    total=0
    for system in nes snes genesis n64 psx gb gba neogeo segacd pce dreamcast atari mame; do
        if [ -d "$ROM_DIR/$system" ]; then
            count=$(find "$ROM_DIR/$system" -type f ! -name "metadata.txt" ! -name "README*.txt" 2>/dev/null | wc -l)
            if [ $count -gt 0 ]; then
                SIZE=$(du -sh "$ROM_DIR/$system" 2>/dev/null | cut -f1)
                echo -e "${GREEN}$system:${NC} $count ROMs ($SIZE)"
                total=$((total + count))
            fi
        fi
    done
    echo ""
    echo -e "${YELLOW}Total:${NC} $total ROMs"
    echo -e "${YELLOW}Espacio total:${NC} $(du -sh $ROM_DIR 2>/dev/null | cut -f1)"
    echo ""
    read -p "Presiona Enter para continuar..."
}

copy_roms_usb() {
    echo -e "${YELLOW}Copiando ROMs desde USB...${NC}"
    sudo mount /dev/sda1 /mnt 2>/dev/null || sudo mount /dev/sdb1 /mnt 2>/dev/null
    if [ -d "/mnt/RetroROMs" ]; then
        cp -r /mnt/RetroROMs/* $ROM_DIR/
        echo -e "${GREEN}ROMs copiadas correctamente${NC}"
    else
        echo -e "${RED}No se encontraron ROMs en USB${NC}"
    fi
    sudo umount /mnt 2>/dev/null
    read -p "Presiona Enter para continuar..."
}

organize_roms() {
    echo -e "${YELLOW}Organizando ROMs automáticamente...${NC}"
    # NES
    find $ROM_DIR -type f \( -name "*.nes" -o -name "*.NES" \) -exec mv {} $ROM_DIR/nes/ \; 2>/dev/null
    # SNES
    find $ROM_DIR -type f \( -name "*.smc" -o -name "*.SMC" -o -name "*.sfc" -o -name "*.SFC" \) -exec mv {} $ROM_DIR/snes/ \; 2>/dev/null
    # Genesis
    find $ROM_DIR -type f \( -name "*.gen" -o -name "*.GEN" -o -name "*.smd" -o -name "*.SMD" -o -name "*.bin" -o -name "*.BIN" \) -exec mv {} $ROM_DIR/genesis/ \; 2>/dev/null
    # N64
    find $ROM_DIR -type f \( -name "*.n64" -o -name "*.N64" -o -name "*.z64" -o -name "*.Z64" \) -exec mv {} $ROM_DIR/n64/ \; 2>/dev/null
    # PSX
    find $ROM_DIR -type f \( -name "*.iso" -o -name "*.ISO" -o -name "*.bin" -o -name "*.BIN" -o -name "*.cue" -o -name "*.CUE" \) -exec mv {} $ROM_DIR/psx/ \; 2>/dev/null
    # GBA
    find $ROM_DIR -type f \( -name "*.gba" -o -name "*.GBA" \) -exec mv {} $ROM_DIR/gba/ \; 2>/dev/null
    # GB/GBC
    find $ROM_DIR -type f \( -name "*.gb" -o -name "*.GB" -o -name "*.gbc" -o -name "*.GBC" \) -exec mv {} $ROM_DIR/gb/ \; 2>/dev/null
    # Neo Geo
    find $ROM_DIR -type f -name "*.zip" -exec sh -c 'unzip -l "$0" | grep -qi "neo-geo" && mv "$0" $ROM_DIR/neogeo/' {} \; 2>/dev/null
    echo -e "${GREEN}ROMs organizadas correctamente${NC}"
    read -p "Presiona Enter para continuar..."
}

while true; do
    show_menu
    case $option in
        1) list_roms ;;
        2) copy_roms_usb ;;
        3) echo "Función en desarrollo"; read -p "Enter..." ;;
        4) echo "Función en desarrollo"; read -p "Enter..." ;;
        5) list_roms ;;
        6) organize_roms ;;
        7) echo "Verificando integridad..."; find $ROM_DIR -type f -size 0 -delete 2>/dev/null; echo -e "${GREEN}Archivos corruptos eliminados${NC}"; read -p "Enter..." ;;
        8) break ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac
done
EOF

    # ============================================
    # 5. SCRIPT DE HERRAMIENTAS
    # ============================================
    
    cat > "$SCRIPTS_DIR/tools_menu.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Menú de Herramientas
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     RETROOS RPi4 - Herramientas Sistema       ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1) 📊 Monitor de sistema (htop)"
    echo "2) 🌡️ Temperatura y rendimiento"
    echo "3) 🧹 Limpiar caché"
    echo "4) 💾 Crear respaldo"
    echo "5) 📋 Ver logs del sistema"
    echo "6) 🔧 Reparar permisos"
    echo "7) 📡 Información de red"
    echo "8) 🎮 Información de mandos"
    echo "9) 🔙 Volver"
    echo ""
    read -p "Opción: " option
}

while true; do
    show_menu
    case $option in
        1)
            htop
            ;;
        2)
            echo -e "${YELLOW}=== Temperatura y Rendimiento ===${NC}"
            echo "🌡️  Temperatura CPU: $(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 || echo 'N/A')"
            echo "⚡ Velocidad CPU: $(vcgencmd measure_clock arm 2>/dev/null | awk -F= '{printf "%.2f GHz", $2/1000000000}' || echo 'N/A')"
            echo "💾 Voltaje: $(vcgencmd measure_volts core 2>/dev/null | cut -d= -f2 || echo 'N/A')"
            echo "🎮 GPU: $(vcgencmd measure_clock v3d 2>/dev/null | awk -F= '{printf "%.2f MHz", $2/1000000}' || echo 'N/A')"
            echo ""
            read -p "Presiona Enter para continuar..."
            ;;
        3)
            echo -e "${YELLOW}Limpiando caché...${NC}"
            sudo apt clean
            sudo apt autoclean
            rm -rf ~/.cache/*
            echo -e "${GREEN}Caché limpiada${NC}"
            read -p "Presiona Enter para continuar..."
            ;;
        4)
            echo -e "${YELLOW}Creando respaldo...${NC}"
            BACKUP_FILE="~/retroos_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
            tar -czf "$BACKUP_FILE" ~/.config/retroarch ~/RetroROMs ~/.config/pegasus-frontend 2>/dev/null
            echo -e "${GREEN}Respaldo creado en $BACKUP_FILE${NC}"
            read -p "Presiona Enter para continuar..."
            ;;
        5)
            echo -e "${YELLOW}Logs del sistema:${NC}"
            echo "1) RetroOS install log"
            echo "2) RetroArch log"
            echo "3) Sistema log"
            read -p "Opción: " log_opt
            case $log_opt in
                1) less ~/retroos_install.log ;;
                2) less ~/.config/retroarch/retroarch.log 2>/dev/null || echo "No existe log" ;;
                3) sudo journalctl -n 50 ;;
            esac
            ;;
        6)
            echo -e "${YELLOW}Reparando permisos...${NC}"
            sudo chown -R pi:pi ~/.config/retroarch
            sudo chown -R pi:pi ~/RetroROMs
            sudo chown -R pi:pi ~/.config/pegasus-frontend
            echo -e "${GREEN}Permisos reparados${NC}"
            read -p "Presiona Enter para continuar..."
            ;;
        7)
            echo -e "${YELLOW}=== Información de Red ===${NC}"
            echo "IP: $(hostname -I | awk '{print $1}')"
            echo "WiFi: $(iwgetid -r 2>/dev/null || echo 'No conectado')"
            echo "Señal: $(iwconfig wlan0 2>/dev/null | grep -o 'Signal level=[^ ]*' | cut -d= -f2 || echo 'N/A')"
            echo ""
            read -p "Presiona Enter para continuar..."
            ;;
        8)
            echo -e "${YELLOW}=== Mandos Detectados ===${NC}"
            for js in /dev/input/js* 2>/dev/null; do
                if [ -e "$js" ]; then
                    echo "  🎮 $(basename $js)"
                fi
            done
            [ ! -e /dev/input/js0 ] && echo "  ❌ No se detectaron mandos"
            echo ""
            read -p "Presiona Enter para continuar..."
            ;;
        9)
            break
            ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            ;;
    esac
done
EOF

    # ============================================
    # 6. SCRIPT DE ACTUALIZACIÓN
    # ============================================
    
    cat > "$SCRIPTS_DIR/update_retroos.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Actualización del Sistema
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     RETROOS RPi4 - Actualización Sistema      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
echo ""

echo "1) 🔄 Actualizar sistema base"
echo "2) 🔄 Actualizar RetroArch"
echo "3) 🔄 Actualizar cores"
echo "4) 🔄 Actualizar Pegasus"
echo "5) 🔄 Actualizar todo"
echo "6) 🔙 Volver"
echo ""
read -p "Opción: " option

case $option in
    1)
        echo -e "${YELLOW}Actualizando sistema...${NC}"
        sudo apt update && sudo apt upgrade -y
        echo -e "${GREEN}Sistema actualizado${NC}"
        ;;
    2)
        echo -e "${YELLOW}Actualizando RetroArch...${NC}"
        cd ~/RetroArch 2>/dev/null || exit
        git pull
        make clean
        make -j4
        sudo make install
        echo -e "${GREEN}RetroArch actualizado${NC}"
        ;;
    3)
        echo -e "${YELLOW}Actualizando cores...${NC}"
        cd ~/.config/retroarch/cores
        for core in *.so; do
            base=$(basename "$core" _libretro.so)
            wget -q "https://buildbot.libretro.com/nightly/linux/aarch64/latest/${base}_libretro.so" -O "$core"
            echo "  ✓ $base"
        done
        echo -e "${GREEN}Cores actualizados${NC}"
        ;;
    4)
        echo -e "${YELLOW}Actualizando Pegasus...${NC}"
        cd ~
        wget -q https://github.com/mmatyas/pegasus-frontend/releases/download/continuous/pegasus-frontend_continuous_2023-07-21_rpi-aarch64.AppImage -O pegasus-frontend.AppImage
        chmod +x pegasus-frontend.AppImage
        sudo mv pegasus-frontend.AppImage /opt/pegasus-frontend.AppImage
        echo -e "${GREEN}Pegasus actualizado${NC}"
        ;;
    5)
        echo -e "${YELLOW}Actualizando todo...${NC}"
        bash "$0" 1
        bash "$0" 2
        bash "$0" 3
        bash "$0" 4
        echo -e "${GREEN}Todo actualizado${NC}"
        ;;
    6)
        exit 0
        ;;
    *)
        echo -e "${RED}Opción inválida${NC}"
        ;;
esac
read -p "Presiona Enter para continuar..."
EOF

    # ============================================
    # 7. SCRIPT DE APAGADO Y REINICIO
    # ============================================
    
    cat > "$SCRIPTS_DIR/shutdown_retroos.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Apagar Sistema
# ============================================

echo -e "${YELLOW}¿Estás seguro de que quieres APAGAR el sistema?${NC}"
echo "1) Sí, apagar"
echo "2) No, cancelar"
read -p "Opción: " option

if [ "$option" = "1" ]; then
    echo -e "${GREEN}Apagando sistema...${NC}"
    sudo shutdown -h now
else
    echo "Cancelado"
fi
EOF

    cat > "$SCRIPTS_DIR/restart_retroos.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Reiniciar Sistema
# ============================================

echo -e "${YELLOW}¿Estás seguro de que quieres REINICIAR el sistema?${NC}"
echo "1) Sí, reiniciar"
echo "2) No, cancelar"
read -p "Opción: " option

if [ "$option" = "1" ]; then
    echo -e "${GREEN}Reiniciando sistema...${NC}"
    sudo reboot
else
    echo "Cancelado"
fi
EOF

    # ============================================
    # 8. MENÚ GRÁFICO EN PYTHON
    # ============================================
    
    cat > "$SCRIPTS_DIR/retroos_gui.py" << 'PYEOF'
#!/usr/bin/env python3
# ============================================
# RETROOS RPi4 - Menú Gráfico
# ============================================

import sys
import os
import subprocess
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtGui import *

class RetroOSMenu(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("🎮 RETROOS RPi4")
        self.setGeometry(100, 100, 1000, 700)
        self.setStyleSheet("""
            QMainWindow {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 #1a1a2e, stop:0.5 #16213e, stop:1 #0f3460);
            }
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 #e94560, stop:1 #533483);
                border: none;
                border-radius: 10px;
                padding: 20px;
                color: white;
                font-weight: bold;
                font-size: 14px;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 #ff6b81, stop:1 #7b3fa0);
            }
            QLabel {
                color: white;
                font-size: 24px;
                font-weight: bold;
            }
            QLabel#status {
                color: #888888;
                font-size: 12px;
            }
        """)
        
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        
        # Título
        title = QLabel("🎮 RETROOS RPi4")
        title.setAlignment(Qt.AlignCenter)
        layout.addWidget(title)
        
        # Grid de botones
        grid = QGridLayout()
        grid.setSpacing(15)
        
        items = [
            ("🎮 Jugar", self.launch_games),
            ("⚙️ Configurar", self.open_settings),
            ("📁 ROMs", self.manage_roms),
            ("🎮 Mandos", self.manage_controllers),
            ("📶 WiFi", self.manage_wifi),
            ("🔧 Herramientas", self.open_tools),
            ("💾 BIOS", self.manage_bios),
            ("🎨 Temas", self.change_theme),
            ("📊 Stats", self.show_stats),
            ("ℹ️ About", self.show_about),
            ("🔄 Actualizar", self.update_system),
            ("🔌 Apagar", self.shutdown_system),
            ("♻️ Reiniciar", self.restart_system),
            ("🎯 RetroArch", self.open_retroarch),
        ]
        
        for i, (text, func) in enumerate(items):
            btn = QPushButton(text)
            btn.clicked.connect(func)
            if "Apagar" in text:
                btn.setStyleSheet("""
                    QPushButton {
                        background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                            stop:0 #c0392b, stop:1 #e74c3c);
                    }
                    QPushButton:hover {
                        background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                            stop:0 #e74c3c, stop:1 #c0392b);
                    }
                """)
            elif "Reiniciar" in text:
                btn.setStyleSheet("""
                    QPushButton {
                        background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                            stop:0 #f39c12, stop:1 #e67e22);
                    }
                    QPushButton:hover {
                        background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                            stop:0 #e67e22, stop:1 #f39c12);
                    }
                """)
            grid.addWidget(btn, i//4, i%4)
        
        layout.addLayout(grid)
        layout.addStretch()
        
        # Status bar
        self.status = QLabel("✅ Sistema listo | RPi4 Optimizado")
        self.status.setObjectName("status")
        layout.addWidget(self.status)
    
    def launch_games(self):
        self.close()
        os.system("pegasus-frontend &")
    
    def open_settings(self):
        subprocess.Popen(["lxterminal", "-e", "bash", "-c", 
                         "sudo raspi-config; read -p 'Presiona Enter...'"])
    
    def manage_roms(self):
        subprocess.Popen(["lxterminal", "-e", "bash", "-c", 
                         "~/manage_roms.sh; read -p 'Presiona Enter...'"])
    
    def manage_controllers(self):
        subprocess.Popen(["lxterminal", "-e", "bash", "-c", 
                         "jstest /dev/input/js0 2>/dev/null || echo 'No hay mando'; read -p 'Presiona Enter...'"])
    
    def manage_wifi(self):
        subprocess.Popen(["lxterminal", "-e", "bash", "-c", 
                         "sudo nmcli dev wifi list; read -p 'Presiona Enter...'"])
    
    def open_tools(self):
        subprocess.Popen(["lxterminal", "-e", "bash", "-c", 
                         "~/tools_menu.sh; read -p 'Presiona Enter...'"])
    
    def manage_bios(self):
        subprocess.Popen(["lxterminal", "-e", "bash", "-c", 
                         "~/manage_bios.sh; read -p 'Presiona Enter...'"])
    
    def change_theme(self):
        QMessageBox.information(self, "Temas", 
            "Cambia el tema editando:\n~/.config/pegasus-frontend/settings.txt")
    
    def show_stats(self):
        stats = """
        === RETROOS RPi4 ===
        
        Modelo: Raspberry Pi 4B
        RAM: {} MB
        CPU: {} cores
        Temperatura: {}
        IP: {}
        """.format(
            self.get_ram(),
            os.cpu_count(),
            self.get_temp(),
            self.get_ip()
        )
        QMessageBox.information(self, "Estadísticas", stats)
    
    def show_about(self):
        QMessageBox.about(self, "RetroOS RPi4", 
            "RETROOS RPi4 v4.0\n"
            "Sistema Retro para Raspberry Pi 4B\n"
            "Basado en RetroArch y Pegasus FrontEnd\n"
            "Optimizado para máximo rendimiento")
    
    def update_system(self):
        reply = QMessageBox.question(self, 'Actualizar RetroOS',
            '¿Deseas actualizar RetroOS a la última versión?',
            QMessageBox.Yes | QMessageBox.No)
        if reply == QMessageBox.Yes:
            subprocess.Popen(["lxterminal", "-e", "bash", "-c", 
                            "~/update_retroos.sh; read -p 'Presiona Enter...'"])
    
    def shutdown_system(self):
        reply = QMessageBox.question(self, 'Apagar Sistema',
            '¿Estás seguro de que quieres apagar el sistema?',
            QMessageBox.Yes | QMessageBox.No)
        if reply == QMessageBox.Yes:
            os.system("sudo shutdown -h now")
    
    def restart_system(self):
        reply = QMessageBox.question(self, 'Reiniciar Sistema',
            '¿Estás seguro de que quieres reiniciar el sistema?',
            QMessageBox.Yes | QMessageBox.No)
        if reply == QMessageBox.Yes:
            os.system("sudo reboot")
    
    def open_retroarch(self):
        self.close()
        os.system("retroarch &")
    
    def get_ram(self):
        try:
            with open('/proc/meminfo', 'r') as f:
                for line in f:
                    if 'MemTotal' in line:
                        return int(line.split()[1]) // 1024
        except:
            return 0
    
    def get_temp(self):
        try:
            with open('/sys/class/thermal/thermal_zone0/temp', 'r') as f:
                return f"{int(f.read()) // 1000}°C"
        except:
            return "N/A"
    
    def get_ip(self):
        try:
            import socket
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return "N/A"

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = RetroOSMenu()
    window.show()
    sys.exit(app.exec_())
PYEOF

    # ============================================
    # 9. SCRIPTS DE CONFIGURACIÓN DE MANDOS
    # ============================================
    
    cat > "$SCRIPTS_DIR/configure_controller.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Configuración de Mandos
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     RETROOS RPi4 - Configuración Mandos       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Mandos detectados:${NC}"
for js in /dev/input/js* 2>/dev/null; do
    if [ -e "$js" ]; then
        echo "  🎮 $(basename $js)"
    fi
done
[ ! -e /dev/input/js0 ] && echo "  ❌ No se detectaron mandos"
echo ""

echo "1) Probar mando (jstest)"
echo "2) Configurar en RetroArch"
echo "3) Calibrar mando"
echo "4) Ver información"
echo "5) Volver"
echo ""
read -p "Opción: " option

case $option in
    1)
        if [ -e /dev/input/js0 ]; then
            sudo jstest /dev/input/js0
        else
            echo -e "${RED}No hay mandos conectados${NC}"
        fi
        ;;
    2)
        echo -e "${YELLOW}Conecta el mando y presiona cualquier botón...${NC}"
        retroarch --menu
        ;;
    3)
        if [ -e /dev/input/js0 ]; then
            sudo jscal -c /dev/input/js0
        else
            echo -e "${RED}No hay mandos conectados${NC}"
        fi
        ;;
    4)
        echo -e "${YELLOW}=== Información de Mandos ===${NC}"
        ls -la /dev/input/js* 2>/dev/null
        echo ""
        echo -e "${YELLOW}Dispositivos USB:${NC}"
        lsusb | grep -i "joystick\|gamepad\|controller" 2>/dev/null
        ;;
    5)
        exit 0
        ;;
esac
read -p "Presiona Enter para continuar..."
EOF

    # ============================================
    # 10. SCRIPTS DE GESTIÓN DE WIFI
    # ============================================
    
    cat > "$SCRIPTS_DIR/manage_wifi.sh" << 'EOF'
#!/bin/bash
# ============================================
# RETROOS RPi4 - Gestión WiFi
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        RETROOS RPi4 - Gestión WiFi            ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1) 🔍 Escanear redes"
    echo "2) 📶 Conectar a red"
    echo "3) 🔓 Redes guardadas"
    echo "4) 🔌 Desconectar"
    echo "5) ℹ️ Estado WiFi"
    echo "6) 📊 Prueba de velocidad"
    echo "7) 🔄 Reconectar"
    echo "8) 🔙 Volver"
    echo ""
    read -p "Opción: " option
}

scan_networks() {
    echo -e "${YELLOW}Escaneando redes disponibles...${NC}"
    sudo nmcli dev wifi list
    read -p "Presiona Enter para continuar..."
}

connect_network() {
    echo -e "${YELLOW}Redes disponibles:${NC}"
    sudo nmcli dev wifi list | tail -n +2
    echo ""
    read -p "SSID de la red: " ssid
    read -sp "Contraseña (dejar vacío si no tiene): " password
    echo ""
    
    if [ -z "$password" ]; then
        sudo nmcli dev wifi connect "$ssid"
    else
        sudo nmcli dev wifi connect "$ssid" password "$password"
    fi
    
    read -p "Presiona Enter para continuar..."
}

saved_networks() {
    echo -e "${YELLOW}Redes guardadas:${NC}"
    sudo nmcli con show
    read -p "Presiona Enter para continuar..."
}

disconnect_wifi() {
    echo -e "${YELLOW}Desconectando WiFi...${NC}"
    sudo nmcli dev wifi disconnect
    read -p "Presiona Enter para continuar..."
}

wifi_status() {
    echo -e "${YELLOW}Estado WiFi:${NC}"
    sudo nmcli dev status | grep wifi
    echo ""
    echo -e "${YELLOW}Información de conexión:${NC}"
    sudo nmcli con show --active | grep wifi
    echo ""
    echo -e "${YELLOW}IP y red:${NC}"
    ifconfig wlan0 2>/dev/null || echo "WiFi no conectado"
    read -p "Presiona Enter para continuar..."
}

speed_test() {
    echo -e "${YELLOW}Probando velocidad...${NC}"
    if command -v speedtest-cli &> /dev/null; then
        speedtest-cli
    else
        echo "Instalando speedtest-cli..."
        sudo apt install -y speedtest-cli
        speedtest-cli
    fi
    read -p "Presiona Enter para continuar..."
}

reconnect_wifi() {
    echo -e "${YELLOW}Reconectando WiFi...${NC}"
    sudo nmcli dev wifi connect
    read -p "Presiona Enter para continuar..."
}

while true; do
    show_menu
    case $option in
        1) scan_networks ;;
        2) connect_network ;;
        3) saved_networks ;;
        4) disconnect_wifi ;;
        5) wifi_status ;;
        6) speed_test ;;
        7) reconnect_wifi ;;
        8) break ;;
        *) echo -e "${RED}Opción inválida${NC}" ;;
    esac
done
EOF

    # ============================================
    # 11. CREAR ACCESOS DIRECTOS EN EL ESCRITORIO
    # ============================================
    
    cat > "$DESKTOP_DIR/RetroOS.desktop" << 'EOF'
[Desktop Entry]
Name=RetroOS RPi4
Comment=Sistema Retro para Raspberry Pi 4B
Exec=/home/pi/start_retroos.sh
Icon=gamepad
Terminal=true
Type=Application
Categories=Game;
EOF

    cat > "$DESKTOP_DIR/RetroOS_GUI.desktop" << 'EOF'
[Desktop Entry]
Name=RetroOS GUI RPi4
Comment=Menú Gráfico RetroOS
Exec=python3 /home/pi/retroos_gui.py
Icon=gamepad
Terminal=false
Type=Application
Categories=Game;
EOF

    cat > "$DESKTOP_DIR/RetroOS_Config.desktop" << 'EOF'
[Desktop Entry]
Name=RetroOS Config
Comment=Configuración RetroOS
Exec=lxterminal -e sudo raspi-config
Icon=settings
Terminal=false
Type=Application
Categories=Settings;
EOF

    # ============================================
    # 12. HACER TODOS LOS SCRIPTS EJECUTABLES
    # ============================================
    
    chmod +x "$SCRIPTS_DIR"/start_retroos.sh
    chmod +x "$SCRIPTS_DIR"/check_bios.sh
    chmod +x "$SCRIPTS_DIR"/manage_bios.sh
    chmod +x "$SCRIPTS_DIR"/manage_roms.sh
    chmod +x "$SCRIPTS_DIR"/tools_menu.sh
    chmod +x "$SCRIPTS_DIR"/update_retroos.sh
    chmod +x "$SCRIPTS_DIR"/shutdown_retroos.sh
    chmod +x "$SCRIPTS_DIR"/restart_retroos.sh
    chmod +x "$SCRIPTS_DIR"/retroos_gui.py
    chmod +x "$SCRIPTS_DIR"/configure_controller.sh
    chmod +x "$SCRIPTS_DIR"/manage_wifi.sh
    
    log_success "Todos los scripts creados y configurados"
}

# ============================================
# FUNCIÓN PRINCIPAL
# ============================================

main() {
    print_banner
    
    log "Iniciando instalación de RETROOS RPi4 v$VERSION"
    log "Log de instalación: $INSTALL_LOG"
    
    # Crear estructura
    create_directories
    
    # Crear archivos de configuración
    create_config_files
    
    # Crear archivos de BIOS
    create_bios_files
    
    # Crear scripts
    create_system_scripts
    
    log_success "¡Instalación de RETROOS RPi4 completada!"
    log_success "Se han creado TODOS los archivos y carpetas necesarios"
    log_info "Ejecuta '~/start_retroos.sh' para iniciar el sistema"
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ ¡RETROOS RPi4 INSTALADO CON ÉXITO!      ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Archivos creados:${NC}"
    echo "  📁 ~/RetroROMs/ - ROMs"
    echo "  📁 ~/.config/retroarch/ - Configuración RetroArch"
    echo "  📁 ~/.config/pegasus-frontend/ - Configuración Pegasus"
    echo "  📁 ~/.config/retroarch/system/bios/ - BIOS"
    echo "  📄 ~/start_retroos.sh - Lanzador principal"
    echo "  📄 ~/retroos_gui.py - Menú gráfico"
    echo "  📄 ~/manage_roms.sh - Gestor de ROMs"
    echo "  📄 ~/manage_bios.sh - Gestor de BIOS"
    echo "  📄 ~/manage_wifi.sh - Gestor de WiFi"
    echo "  📄 ~/check_bios.sh - Verificador de BIOS"
    echo "  📄 ~/tools_menu.sh - Herramientas del sistema"
    echo "  📄 ~/update_retroos.sh - Actualización"
    echo "  📄 ~/configure_controller.sh - Configuración de mandos"
    echo "  📄 ~/Desktop/RetroOS.desktop - Acceso directo"
    echo ""
    echo -e "${YELLOW}Comandos útiles:${NC}"
    echo "  ~/start_retroos.sh     - Iniciar RetroOS"
    echo "  python3 ~/retroos_gui.py - Menú gráfico"
    echo "  pegasus-frontend       - Iniciar Pegasus"
    echo "  retroarch              - Iniciar RetroArch"
    echo ""
    echo -e "${GREEN}¡Disfruta de RetroOS en tu RPi4! 🚀${NC}"
    echo ""
    
    read -p "¿Reiniciar ahora? (s/N): " -n 1 -r
    [[ $REPLY =~ ^[Ss]$ ]] && sudo reboot
}

main
