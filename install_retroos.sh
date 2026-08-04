#!/bin/bash
# ============================================
# RETROOS - Script de Instalación Completo
# Para Raspberry Pi 4B
# Basado en Raspberry Pi OS Lite
# ============================================

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Variables
RETROOS_VERSION="1.0.0"
INSTALL_LOG="$HOME/retroos_install.log"
BIOS_DIR="$HOME/.config/retroarch/system/bios"
ROM_DIR="$HOME/RetroROMs"
RETROARCH_DIR="$HOME/.config/retroarch"

# ============================================
# FUNCIONES DE LOGGING
# ============================================

log() {
    echo -e "${BLUE}[RETROOS]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$INSTALL_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $1" >> "$INSTALL_LOG"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
    echo "[OK] $1" >> "$INSTALL_LOG"
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$INSTALL_LOG"
}

print_banner() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║                                               ║"
    echo "║    ██████╗ ███████╗████████╗██████╗  ██████╗  ║"
    echo "║    ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗ ║"
    echo "║    ██████╔╝█████╗     ██║   ██████╔╝██║   ██║ ║"
    echo "║    ██╔══██╗██╔══╝     ██║   ██╔══██╗██║   ██║ ║"
    echo "║    ██║  ██║███████╗   ██║   ██║  ██║╚██████╔╝ ║"
    echo "║    ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ║"
    echo "║                                               ║"
    echo "║           Sistema Retro para RPi4             ║"
    echo "║              Versión $RETROOS_VERSION           ║"
    echo "║                                               ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ============================================
# FUNCIONES DE PREINSTALACIÓN
# ============================================

check_system() {
    log_info "Verificando sistema..."
    
    # Verificar que es Raspberry Pi
    if ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
        log_error "Este script solo funciona en Raspberry Pi"
        exit 1
    fi
    
    # Verificar modelo (RPi4)
    if ! grep -q "Raspberry Pi 4" /proc/device-tree/model 2>/dev/null; then
        log_error "Este script está optimizado para Raspberry Pi 4"
        log_info "Puedes continuar pero algunos ajustes pueden no funcionar"
        read -p "¿Continuar de todas formas? (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            exit 1
        fi
    fi
    
    # Verificar espacio en disco
    available_space=$(df -BG /home | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ $available_space -lt 5 ]; then
        log_error "Espacio insuficiente. Necesitas al menos 5GB libres"
        exit 1
    fi
    
    log_success "Sistema verificado correctamente"
}

check_network() {
    log_info "Verificando conexión a Internet..."
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_success "Conexión a Internet OK"
    else
        log_error "No hay conexión a Internet"
        exit 1
    fi
}

update_system() {
    log_info "Actualizando sistema base..."
    sudo apt update >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error en apt update"
        exit 1
    }
    sudo apt upgrade -y >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error en apt upgrade"
        exit 1
    }
    log_success "Sistema actualizado"
}

# ============================================
# FUNCIONES DE INSTALACIÓN
# ============================================

install_dependencies() {
    log_info "Instalando dependencias base..."
    
    DEPENDENCIES="git wget curl build-essential \
        libsdl2-dev libegl1-mesa-dev libgles2-mesa-dev \
        libgl1-mesa-dev libgbm-dev libdrm-dev \
        libpulse-dev libasound2-dev libudev-dev \
        libfreetype6-dev libx11-dev libxrandr-dev \
        libv4l-dev libavcodec-dev libavformat-dev \
        libavutil-dev libswscale-dev libxext-dev \
        libxkbcommon-dev libboost-dev libboost-filesystem-dev \
        libboost-locale-dev libboost-system-dev \
        libfreeimage-dev libcurl4-openssl-dev \
        libvlc-dev libvlccore-dev libvpx-dev \
        libavresample-dev unzip tree"
    
    sudo apt install -y $DEPENDENCIES >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error instalando dependencias"
        exit 1
    }
    log_success "Dependencias instaladas"
}

install_retroarch() {
    log_info "Instalando RetroArch desde fuente..."
    
    cd "$HOME"
    if [ -d "RetroArch" ]; then
        log_info "RetroArch ya existe, actualizando..."
        cd RetroArch
        git pull >> "$INSTALL_LOG" 2>&1
    else
        git clone https://github.com/libretro/RetroArch.git >> "$INSTALL_LOG" 2>&1
        cd RetroArch
    fi
    
    # Limpiar compilaciones anteriores
    make clean >> "$INSTALL_LOG" 2>&1 || true
    
    # Configurar para RPi4
    ./configure \
        --disable-oss \
        --disable-al \
        --enable-udev \
        --enable-gles \
        --enable-opengl \
        --enable-opengl_core \
        --enable-kms \
        --enable-wayland \
        --enable-x11 \
        --enable-pulse \
        --enable-alsa \
        --enable-freetype \
        --enable-egl \
        --enable-v4l2 \
        --enable-netplay \
        --enable-ffmpeg \
        --enable-zlib >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error en configuración de RetroArch"
        exit 1
    }
    
    log_info "Compilando RetroArch (esto puede tomar varios minutos)..."
    make -j4 >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error compilando RetroArch"
        exit 1
    }
    
    sudo make install >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error instalando RetroArch"
        exit 1
    }
    
    log_success "RetroArch instalado correctamente"
}

download_cores() {
    log_info "Descargando cores de RetroArch..."
    
    mkdir -p "$RETROARCH_DIR/cores"
    mkdir -p "$RETROARCH_DIR/cores/info"
    cd "$RETROARCH_DIR/cores"
    
    # Lista de cores a descargar
    CORES=(
        "2048"
        "quicknes"
        "snes9x"
        "snes9x2010"
        "genesis_plus_gx"
        "mupen64plus"
        "pcsx_rearmed"
        "gambatte"
        "mgba"
        "fbalpha"
        "mame2003_plus"
        "nestopia"
        "fceumm"
        "mednafen_psx"
        "parallel_n64"
        "picodrive"
        "gpsp"
    )
    
    for core in "${CORES[@]}"; do
        log_info "Descargando $core..."
        wget -q "https://buildbot.libretro.com/nightly/linux/armhf/latest/${core}_libretro.so" -O "${core}_libretro.so" || {
            log_error "Falló descarga de $core"
        }
        wget -q "https://buildbot.libretro.com/nightly/linux/armhf/latest/info/${core}_libretro.info" -O "info/${core}_libretro.info" || {
            log_error "Falló descarga de info de $core"
        }
    done
    
    chmod +x *.so
    log_success "Cores descargados"
}

configure_retroarch() {
    log_info "Configurando RetroArch..."
    
    mkdir -p "$RETROARCH_DIR"
    mkdir -p "$RETROARCH_DIR/saves"
    mkdir -p "$RETROARCH_DIR/states"
    mkdir -p "$RETROARCH_DIR/system"
    
    cat > "$RETROARCH_DIR/retroarch.cfg" << 'EOF'
# ============================================
# RETROOS - Configuración RetroArch
# ============================================

# Video
video_driver = "gl"
video_scale_integer = false
video_smooth = true
video_ctx_driver = "egl"
video_refresh_rate = 60
video_fullscreen = true
video_windowed_fullscreen = true
video_force_aspect = true
video_aspect_ratio = 1.777778
video_fullscreen_x = 0
video_fullscreen_y = 0

# Audio
audio_driver = "pulse"
audio_rate_control = true
audio_out_rate = 48000
audio_latency = 64
audio_device = "default"

# Menú
menu_driver = "ozone"
menu_show_advanced_settings = true
menu_show_core_updater = false
menu_show_online_updater = false

# Directorios
system_directory = "/home/pi/.config/retroarch/system"
savefile_directory = "/home/pi/.config/retroarch/saves"
savestate_directory = "/home/pi/.config/retroarch/states"
core_directory = "/home/pi/.config/retroarch/cores"

# Input
input_autodetect_enable = true
input_player1_joypad_index = 0
input_player2_joypad_index = 1
input_max_users = 4
input_axis_threshold = 0.5

# Rendering
video_max_swapchain_images = 3
video_shared_context = true
video_hard_sync = true
video_hard_sync_frames = 0
video_frame_delay = 0

# Performance
threaded_video = true
video_gpu_record = false
video_gpu_screenshot = false

# Netplay
netplay_enable = false
netplay_ip_address = ""
netplay_port = 55435
netplay_spectate_password = ""
netplay_mode = ""

# Ahorro de energía
audio_enable = true
video_disable_composition = true

# BIOS Paths
system_directory = "/home/pi/.config/retroarch/system"
bios_directory = "/home/pi/.config/retroarch/system/bios"
EOF
    
    log_success "RetroArch configurado"
}

# ============================================
# FUNCIONES DE BIOS
# ============================================

setup_bios() {
    log_info "Configurando estructura de BIOS..."
    
    mkdir -p "$BIOS_DIR"/{psx,n64,gb,gba,genesis,saturn,neogeo,atari,dreamcast,pce,segacd,3do,jaguar,lynx,ngp,wonderswan}
    
    # Crear README de BIOS
    cat > "$BIOS_DIR/README_BIOS.txt" << 'EOF'
==========================
RETROOS - BIOS REQUIREMENTS
==========================

Para el correcto funcionamiento, necesitas los siguientes archivos BIOS:

== PLAYSTATION (PSX) ==
Ubicación: ~/.config/retroarch/system/bios/psx/
- scph5500.bin (Japón) MD5: 8dd7d5296a650fac7319bce665a6a53c
- scph5501.bin (USA) MD5: 490f666e1afb15b7362b406ed1cea246
- scph5502.bin (Europa) MD5: 32736f17079d0b2b7024407c39bd3050

== NINTENDO 64 ==
Ubicación: ~/.config/retroarch/system/bios/n64/
- pifdata.bin

== GAME BOY ADVANCE ==
Ubicación: ~/.config/retroarch/system/bios/gba/
- gba_bios.bin

== NEO GEO ==
Ubicación: ~/.config/retroarch/system/bios/neogeo/
- neogeo.zip (contiene todos los archivos BIOS)

== SEGA CD ==
Ubicación: ~/.config/retroarch/system/bios/genesis/
- bios_CD_E.bin (Europa)
- bios_CD_U.bin (USA)
- bios_CD_J.bin (Japón)

Estos archivos son PROPIETARIOS y debes obtenerlos de tus propias consolas.
¡NO COMPARTAS ARCHIVOS BIOS! Respeta los derechos de autor.
EOF
    
    # Crear README en español
    cat > "$BIOS_DIR/LEEME_BIOS.txt" << 'EOF'
==========================
RETROOS - REQUISITOS DE BIOS
==========================

Para el funcionamiento correcto de los sistemas emulados:

== PLAYSTATION ==
~/.config/retroarch/system/bios/psx/
- scph5500.bin (Japón)
- scph5501.bin (USA)
- scph5502.bin (Europa)

== NINTENDO 64 ==
~/.config/retroarch/system/bios/n64/
- pifdata.bin

== GAME BOY ADVANCE ==
~/.config/retroarch/system/bios/gba/
- gba_bios.bin

== NEO GEO ==
~/.config/retroarch/system/bios/neogeo/
- neogeo.zip

Estos archivos son PROPIETARIOS y debes obtenerlos legalmente.
EOF
    
    log_success "Estructura de BIOS creada"
}

create_bios_checker() {
    log_info "Creando verificador de BIOS..."
    
    cat > "$HOME/check_bios.sh" << 'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BIOS_DIR="$HOME/.config/retroarch/system/bios"

echo "=== VERIFICADOR DE BIOS RETROOS ==="
echo ""

check_file() {
    local file=$1
    local desc=$2
    local path="$BIOS_DIR/$file"
    
    if [ -f "$path" ]; then
        local size=$(du -h "$path" | cut -f1)
        echo -e "${GREEN}✓${NC} $desc: $file ($size)"
        return 0
    else
        echo -e "${RED}✗${NC} $desc: $file (NO ENCONTRADO)"
        return 1
    fi
}

check_zip() {
    local file=$1
    local desc=$2
    local path="$BIOS_DIR/$file"
    
    if [ -f "$path" ]; then
        local size=$(du -h "$path" | cut -f1)
        echo -e "${GREEN}✓${NC} $desc: $file ($size)"
        return 0
    else
        echo -e "${RED}✗${NC} $desc: $file (NO ENCONTRADO)"
        return 1
    fi
}

echo "--- PLAYSTATION ---"
check_file "psx/scph5500.bin" "BIOS PSX Japón"
check_file "psx/scph5501.bin" "BIOS PSX USA"
check_file "psx/scph5502.bin" "BIOS PSX Europa"
echo ""

echo "--- NINTENDO 64 ---"
check_file "n64/pifdata.bin" "BIOS N64"
echo ""

echo "--- GAME BOY ADVANCE ---"
check_file "gba/gba_bios.bin" "BIOS GBA"
echo ""

echo "--- NEO GEO ---"
check_zip "neogeo/neogeo.zip" "BIOS Neo Geo"
echo ""

echo "=== RESUMEN ==="
echo "Los BIOS deben estar en: $BIOS_DIR"
echo "Consulta README_BIOS.txt para más información"
EOF
    
    chmod +x "$HOME/check_bios.sh"
    log_success "Verificador de BIOS creado"
}

# ============================================
# FUNCIONES DEL FRONTEND
# ============================================

install_pegasus() {
    log_info "Instalando Pegasus Frontend..."
    
    cd "$HOME"
    wget -q https://github.com/mmatyas/pegasus-frontend/releases/download/continuous/pegasus-frontend_continuous_2023-07-21_rpi-aarch64.AppImage -O pegasus-frontend.AppImage || {
        log_error "Error descargando Pegasus"
        exit 1
    }
    
    chmod +x pegasus-frontend.AppImage
    sudo mv pegasus-frontend.AppImage /opt/pegasus-frontend.AppImage
    sudo ln -sf /opt/pegasus-frontend.AppImage /usr/local/bin/pegasus-frontend
    
    # Configurar Pegasus
    mkdir -p "$HOME/.config/pegasus-frontend"
    
    cat > "$HOME/.config/pegasus-frontend/settings.txt" << 'EOF'
game_dirs:
  /home/pi/RetroROMs

theme: /home/pi/.config/pegasus-frontend/themes/gameOS

fullscreen: true
show_fps: false
force_aspect_ratio: 16:9
v-sync: true

launch_command: /usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/{core}.so -c /home/pi/.config/retroarch/retroarch.cfg {file}
EOF
    
    # Instalar tema
    cd "$HOME/.config/pegasus-frontend"
    git clone https://github.com/mmatyas/pegasus-theme-gameos themes/gameOS >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error instalando tema de Pegasus"
    }
    
    log_success "Pegasus Frontend instalado"
}

install_emulationstation() {
    log_info "Instalando EmulationStation (opcional)..."
    
    cd "$HOME"
    if [ -d "EmulationStation" ]; then
        cd EmulationStation
        git pull >> "$INSTALL_LOG" 2>&1
    else
        git clone https://github.com/RetroPie/EmulationStation.git >> "$INSTALL_LOG" 2>&1
        cd EmulationStation
    fi
    
    cmake -DCMAKE_BUILD_TYPE=Release . >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error en cmake de EmulationStation"
        return 1
    }
    make -j4 >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error compilando EmulationStation"
        return 1
    }
    sudo make install >> "$INSTALL_LOG" 2>&1
    
    # Configurar EmulationStation
    mkdir -p "$HOME/.emulationstation"
    
    cat > "$HOME/.emulationstation/es_systems.cfg" << 'EOF'
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
</systemList>
EOF
    
    log_success "EmulationStation instalado"
}

# ============================================
# FUNCIONES DE CONFIGURACIÓN
# ============================================

setup_roms() {
    log_info "Configurando estructura de ROMs..."
    
    mkdir -p "$ROM_DIR"/{nes,snes,genesis,n64,psx,gb,gba,neogeo,segacd,pce,dreamcast,atari,mame}
    
    # Crear archivos de metadata para Pegasus
    for system in nes snes genesis n64 psx gb gba; do
        cat > "$ROM_DIR/$system/metadata.txt" << EOF
collection: ${system^^}
shortname: $system
extensions: rom zip
launch: {core} = ${system}_core
EOF
    done
    
    # Crear README para ROMs
    cat > "$ROM_DIR/README.txt" << 'EOF'
================================
RETROOS - INSTRUCCIONES PARA ROMS
================================

Coloca tus ROMs en las siguientes carpetas:

NES: /home/pi/RetroROMs/nes/
SNES: /home/pi/RetroROMs/snes/
Genesis: /home/pi/RetroROMs/genesis/
N64: /home/pi/RetroROMs/n64/
PSX: /home/pi/RetroROMs/psx/
Game Boy: /home/pi/RetroROMs/gb/
Game Boy Advance: /home/pi/RetroROMs/gba/
Neo Geo: /home/pi/RetroROMs/neogeo/
SEGA CD: /home/pi/RetroROMs/segacd/
PC Engine: /home/pi/RetroROMs/pce/
Dreamcast: /home/pi/RetroROMs/dreamcast/
Atari: /home/pi/RetroROMs/atari/
MAME: /home/pi/RetroROMs/mame/

FORMATOS SOPORTADOS:
- NES: .nes, .zip
- SNES: .smc, .sfc, .zip
- Genesis: .smd, .gen, .bin, .zip
- N64: .n64, .z64, .v64
- PSX: .cue, .bin, .iso, .img
- GBA: .gba, .zip
- Neo Geo: .zip
- SEGA CD: .cue, .bin
- PC Engine: .pce, .zip

ARCHIVOS BIOS:
Consulta ~/.config/retroarch/system/bios/README_BIOS.txt
EOF
    
    log_success "Estructura de ROMs creada"
}

create_launcher() {
    log_info "Creando script de lanzamiento..."
    
    cat > "$HOME/start_retroos.sh" << 'EOF'
#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== RETROOS LAUNCHER ===${NC}"
echo ""
echo "Selecciona el frontend a usar:"
echo "1) Pegasus Frontend"
echo "2) EmulationStation"
echo "3) RetroArch (solo)"
echo "4) Salir"
echo ""
read -p "Opción: " choice

case $choice in
    1)
        echo -e "${GREEN}Iniciando Pegasus...${NC}"
        /usr/local/bin/pegasus-frontend
        ;;
    2)
        echo -e "${GREEN}Iniciando EmulationStation...${NC}"
        emulationstation
        ;;
    3)
        echo -e "${GREEN}Iniciando RetroArch...${NC}"
        retroarch
        ;;
    4)
        echo "¡Hasta luego!"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Opción inválida${NC}"
        ;;
esac
EOF
    
    chmod +x "$HOME/start_retroos.sh"
    log_success "Script de lanzamiento creado"
}

setup_autostart() {
    log_info "Configurando auto-inicio..."
    
    # Crear servicio systemd
    sudo tee /etc/systemd/system/retroos.service << 'EOF'
[Unit]
Description=RetroOS Frontend
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi
ExecStart=/home/pi/start_retroos.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    log_success "Servicio systemd creado"
    
    echo ""
    echo -e "${YELLOW}¿Quieres habilitar el auto-inicio?${NC}"
    echo "1) Sí, iniciar RetroOS automáticamente"
    echo "2) No, iniciar manualmente"
    read -p "Opción: " autostart_choice
    
    if [ "$autostart_choice" = "1" ]; then
        sudo systemctl enable retroos.service
        log_success "Auto-inicio habilitado"
    else
        log_info "Auto-inicio no habilitado"
    fi
}

# ============================================
# FUNCIONES DE OPTIMIZACIÓN
# ============================================

optimize_system() {
    log_info "Optimizando sistema para RPi4..."
    
    # Configurar memoria GPU
    sudo bash -c 'echo "gpu_mem=256" >> /boot/config.txt'
    
    # Overclocking seguro
    sudo bash -c 'cat >> /boot/config.txt << EOF

# Overclock seguro para RPi4
over_voltage=2
arm_freq=1750
gpu_freq=600
v3d_freq=600
hdmi_enable_4kp60=1
EOF'
    
    # Deshabilitar servicios innecesarios
    sudo systemctl disable bluetooth.service
    sudo systemctl disable hciuart.service
    
    log_success "Optimizaciones aplicadas"
}

# ============================================
# FUNCIONES DE POST-INSTALACIÓN
# ============================================

print_summary() {
    clear
    echo -e "${BOLD}${GREEN}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║                                               ║"
    echo "║         ¡INSTALACIÓN COMPLETADA!              ║"
    echo "║                                               ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BOLD}RESUMEN DE INSTALACIÓN:${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} Sistema base actualizado"
    echo -e "${GREEN}✓${NC} Dependencias instaladas"
    echo -e "${GREEN}✓${NC} RetroArch compilado e instalado"
    echo -e "${GREEN}✓${NC} Cores descargados"
    echo -e "${GREEN}✓${NC} Frontend instalado"
    echo -e "${GREEN}✓${NC} BIOS configurado"
    echo -e "${GREEN}✓${NC} ROMs estructuradas"
    echo -e "${GREEN}✓${NC} Sistema optimizado"
    echo ""
    
    echo -e "${BOLD}INFORMACIÓN IMPORTANTE:${NC}"
    echo ""
    echo -e "1. ${YELLOW}BIOS:${NC} Coloca tus archivos BIOS en:"
    echo "   ~/.config/retroarch/system/bios/"
    echo "   Ejecuta ~/check_bios.sh para verificar"
    echo ""
    echo -e "2. ${YELLOW}ROMs:${NC} Coloca tus ROMs en:"
    echo "   ~/RetroROMs/[sistema]/"
    echo ""
    echo -e "3. ${YELLOW}Inicio:${NC} Ejecuta para iniciar:"
    echo "   ~/start_retroos.sh"
    echo ""
    echo -e "4. ${YELLOW}Auto-inicio:${NC} Si lo habilitaste, reinicia el sistema"
    echo ""
    echo -e "5. ${YELLOW}Log de instalación:${NC} $INSTALL_LOG"
    echo ""
    
    echo -e "${BOLD}COMANDOS ÚTILES:${NC}"
    echo ""
    echo "  ~/start_retroos.sh       - Iniciar RetroOS"
    echo "  ~/check_bios.sh          - Verificar BIOS"
    echo "  retroarch                - Abrir RetroArch"
    echo "  pegasus-frontend         - Abrir Pegasus"
    echo "  emulationstation         - Abrir EmulationStation"
    echo ""
    
    echo -e "${BLUE}¡Disfruta de tu RetroOS!${NC}"
}

# ============================================
# FUNCIÓN PRINCIPAL
# ============================================

main() {
    print_banner
    
    log "Iniciando instalación de RetroOS v$RETROOS_VERSION"
    log "Log de instalación: $INSTALL_LOG"
    
    # Pre-instalación
    check_system
    check_network
    update_system
    
    # Instalación principal
    install_dependencies
    install_retroarch
    download_cores
    configure_retroarch
    
    # BIOS
    setup_bios
    create_bios_checker
    
    # Frontend
    install_pegasus
    install_emulationstation
    
    # Configuración
    setup_roms
    create_launcher
    
    # Optimizaciones
    optimize_system
    
    # Auto-inicio
    setup_autostart
    
    # Resumen
    print_summary
    
    log_success "Instalación completada exitosamente"
}

# ============================================
# EJECUCIÓN
# ============================================

# Verificar que se ejecuta como usuario pi
if [ "$USER" != "pi" ]; then
    log_error "Este script debe ejecutarse como usuario pi"
    exit 1
fi

# Ejecutar instalación
main

# Preguntar por reinicio
echo ""
read -p "¿Reiniciar ahora? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    log_info "Reiniciando sistema..."
    sudo reboot
else
    log_info "Recuerda reiniciar para aplicar todos los cambios"
fi
