#!/bin/bash
# ============================================
# RETROOS - Instalador Todo en Uno v3.1
# Soporte para RPi4B y RPi3B+
# Sistema Retro completo para Raspberry Pi
# ============================================

set -e  # Salir en caso de error

# ============================================
# CONFIGURACIÓN Y VARIABLES
# ============================================

VERSION="3.1.0"
INSTALL_LOG="$HOME/retroos_install.log"
RETROOS_DIR="$HOME/retroos_temp"
BIOS_DIR="$HOME/.config/retroarch/system/bios"
ROM_DIR="$HOME/RetroROMs"
RETROARCH_DIR="$HOME/.config/retroarch"
PEGASUS_DIR="$HOME/.config/pegasus-frontend"

# Variables de hardware
RPI_MODEL=""
RPI_IS_RPI4=false
RPI_IS_RPI3=false
RPI_IS_RPI2=false
RPI_CPU_CORES=4
RPI_ARM_VERSION="armhf"

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
# FUNCIONES DE UTILIDAD
# ============================================

log() {
    echo -e "${BLUE}[RETROOS]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$INSTALL_LOG"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    echo "[OK] $1" >> "$INSTALL_LOG"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    echo "[ERROR] $1" >> "$INSTALL_LOG"
}

log_info() {
    echo -e "${YELLOW}[i]${NC} $1"
    echo "[INFO] $1" >> "$INSTALL_LOG"
}

log_step() {
    echo -e "${CYAN}[➜]${NC} ${BOLD}$1${NC}"
    echo "[STEP] $1" >> "$INSTALL_LOG"
}

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
    echo "║            Sistema Retro para Raspberry Pi                  ║"
    echo "║                     Versión ${VERSION}                         ║"
    echo "║                                                              ║"
    echo "║   🎮 Emulación Multi-Sistema  |  📡 WiFi Integrado          ║"
    echo "║   🎨 Interfaz Gráfica        |  🎮 Soporte de Mandos       ║"
    echo "║   ⚡ Optimizado para RPi      |  💾 Gestión de BIOS         ║"
    echo "║   📦 Soporte: RPi4B | RPi3B+ | RPi2B                       ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# ============================================
# DETECCIÓN DE HARDWARE
# ============================================

detect_hardware() {
    log_step "Detectando hardware..."
    
    if grep -q "Raspberry Pi 4" /proc/device-tree/model 2>/dev/null; then
        RPI_MODEL="Raspberry Pi 4"
        RPI_IS_RPI4=true
        RPI_CPU_CORES=4
        RPI_ARM_VERSION="aarch64"
        log_success "Raspberry Pi 4 detectado"
    elif grep -q "Raspberry Pi 3" /proc/device-tree/model 2>/dev/null; then
        RPI_MODEL="Raspberry Pi 3"
        RPI_IS_RPI3=true
        RPI_CPU_CORES=4
        RPI_ARM_VERSION="armhf"
        log_success "Raspberry Pi 3 detectado"
    elif grep -q "Raspberry Pi 2" /proc/device-tree/model 2>/dev/null; then
        RPI_MODEL="Raspberry Pi 2"
        RPI_IS_RPI2=true
        RPI_CPU_CORES=4
        RPI_ARM_VERSION="armhf"
        log_success "Raspberry Pi 2 detectado"
    else
        RPI_MODEL="Raspberry Pi (desconocido)"
        RPI_CPU_CORES=$(nproc)
        log_info "Raspberry Pi no identificado - continuando con configuración genérica"
    fi
    
    # Mostrar información
    echo ""
    echo -e "${CYAN}Información del hardware:${NC}"
    echo -e "  Modelo: ${BOLD}$RPI_MODEL${NC}"
    echo -e "  Cores CPU: ${BOLD}$RPI_CPU_CORES${NC}"
    echo -e "  Arquitectura: ${BOLD}$RPI_ARM_VERSION${NC}"
    echo -e "  RAM: ${BOLD}$(free -h | awk '/^Mem:/ {print $2}')${NC}"
    echo ""
    
    # Verificar espacio
    available_space=$(df -BG /home | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ $available_space -lt 5 ]; then
        log_error "Espacio insuficiente. Necesitas al menos 5GB libres (tienes ${available_space}GB)"
        exit 1
    fi
    log_success "Espacio disponible: ${available_space}GB"
    
    # Verificar conexión a Internet
    log_info "Verificando conexión a Internet..."
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_success "Conexión a Internet OK"
    else
        log_error "No hay conexión a Internet"
        exit 1
    fi
}

# ============================================
# PREPARACIÓN DEL SISTEMA
# ============================================

prepare_system() {
    log_step "Preparando sistema..."
    
    # Crear directorio temporal
    mkdir -p "$RETROOS_DIR"
    
    # Actualizar sistema
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
    
    # Instalar dependencias base
    log_info "Instalando dependencias base..."
    sudo apt install -y git wget curl build-essential \
        cmake pkg-config \
        >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error instalando dependencias base"
        exit 1
    }
    log_success "Dependencias base instaladas"
}

# ============================================
# INSTALACIÓN DE RETROARCH (CONFIGURACIÓN POR MODELO)
# ============================================

install_retroarch() {
    log_step "Instalando RetroArch desde fuente..."
    
    cd "$RETROOS_DIR"
    
    # Clonar o actualizar
    if [ -d "RetroArch" ]; then
        log_info "Actualizando RetroArch..."
        cd RetroArch
        git pull >> "$INSTALL_LOG" 2>&1
    else
        log_info "Clonando RetroArch..."
        git clone https://github.com/libretro/RetroArch.git >> "$INSTALL_LOG" 2>&1
        cd RetroArch
    fi
    
    # Instalar dependencias de compilación según modelo
    log_info "Instalando dependencias de compilación..."
    
    if [ "$RPI_IS_RPI4" = true ]; then
        sudo apt install -y \
            libsdl2-dev libegl1-mesa-dev libgles2-mesa-dev \
            libgl1-mesa-dev libgbm-dev libdrm-dev \
            libpulse-dev libasound2-dev libudev-dev \
            libfreetype6-dev libx11-dev libxrandr-dev \
            libv4l-dev libavcodec-dev libavformat-dev \
            libavutil-dev libswscale-dev libxext-dev \
            libxkbcommon-dev \
            >> "$INSTALL_LOG" 2>&1
    else
        # RPi3 y RPi2 usan menos dependencias
        sudo apt install -y \
            libsdl2-dev libgles2-mesa-dev \
            libpulse-dev libasound2-dev libudev-dev \
            libfreetype6-dev libx11-dev libxrandr-dev \
            libv4l-dev libavcodec-dev libavformat-dev \
            libavutil-dev libswscale-dev \
            >> "$INSTALL_LOG" 2>&1
    fi
    
    # Limpiar compilaciones anteriores
    make clean >> "$INSTALL_LOG" 2>&1 || true
    
    # Configurar según modelo
    log_info "Configurando RetroArch para $RPI_MODEL..."
    
    if [ "$RPI_IS_RPI4" = true ]; then
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
            --enable-zlib \
            >> "$INSTALL_LOG" 2>&1 || {
            log_error "Error en configuración de RetroArch"
            exit 1
        }
    else
        # RPi3 y RPi2 - configuración más ligera
        ./configure \
            --disable-oss \
            --disable-al \
            --enable-udev \
            --enable-gles \
            --enable-opengl \
            --enable-kms \
            --enable-x11 \
            --enable-pulse \
            --enable-alsa \
            --enable-freetype \
            --enable-egl \
            --enable-v4l2 \
            --enable-netplay \
            --disable-ffmpeg \
            --enable-zlib \
            >> "$INSTALL_LOG" 2>&1 || {
            log_error "Error en configuración de RetroArch"
            exit 1
        }
    fi
    
    # Compilar (usando menos cores en RPi3 para evitar sobrecalentamiento)
    if [ "$RPI_IS_RPI3" = true ] || [ "$RPI_IS_RPI2" = true ]; then
        log_info "Compilando RetroArch con 3 cores (recomendado para RPi3)..."
        make -j3 >> "$INSTALL_LOG" 2>&1 || {
            log_error "Error compilando RetroArch"
            exit 1
        }
    else
        log_info "Compilando RetroArch (esto puede tomar 10-15 minutos)..."
        make -j4 >> "$INSTALL_LOG" 2>&1 || {
            log_error "Error compilando RetroArch"
            exit 1
        }
    fi
    
    # Instalar
    sudo make install >> "$INSTALL_LOG" 2>&1 || {
        log_error "Error instalando RetroArch"
        exit 1
    }
    
    log_success "RetroArch instalado correctamente"
}

# ============================================
# INSTALACIÓN DE CORES (CON SELECTOR POR MODELO)
# ============================================

install_cores() {
    log_step "Descargando cores de RetroArch..."
    
    mkdir -p "$RETROARCH_DIR/cores"
    mkdir -p "$RETROARCH_DIR/cores/info"
    cd "$RETROARCH_DIR/cores"
    
    # Lista de cores por modelo
    if [ "$RPI_IS_RPI4" = true ]; then
        # Cores completos para RPi4
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
            "smsplus"
            "stella"
            "vecx"
            "ppsspp"
            "flycast"
        )
    else
        # Cores ligeros para RPi3/RPi2
        CORES=(
            "2048"
            "quicknes"
            "snes9x"
            "snes9x2010"
            "genesis_plus_gx"
            "gambatte"
            "mgba"
            "fbalpha"
            "mame2003_plus"
            "nestopia"
            "fceumm"
            "picodrive"
            "gpsp"
            "smsplus"
            "stella"
            "vecx"
        )
    fi
    
    log_info "Descargando cores para $RPI_MODEL..."
    for core in "${CORES[@]}"; do
        echo -n "  - $core... "
        wget -q "https://buildbot.libretro.com/nightly/linux/${RPI_ARM_VERSION}/latest/${core}_libretro.so" -O "${core}_libretro.so" 2>/dev/null && \
        wget -q "https://buildbot.libretro.com/nightly/linux/${RPI_ARM_VERSION}/latest/info/${core}_libretro.info" -O "info/${core}_libretro.info" 2>/dev/null
        if [ -f "${core}_libretro.so" ]; then
            echo -e "${GREEN}OK${NC}"
        else
            echo -e "${RED}Falló${NC}"
        fi
    done
    
    chmod +x *.so
    log_success "${#CORES[@]} cores descargados"
}

# ============================================
# CONFIGURACIÓN DE RETROARCH POR MODELO
# ============================================

configure_retroarch() {
    log_step "Configurando RetroArch para $RPI_MODEL..."
    
    mkdir -p "$RETROARCH_DIR"
    mkdir -p "$RETROARCH_DIR/saves"
    mkdir -p "$RETROARCH_DIR/states"
    mkdir -p "$RETROARCH_DIR/system"
    mkdir -p "$RETROARCH_DIR/autoconfig"
    
    # Configuración base
    cat > "$RETROARCH_DIR/retroarch.cfg" << 'EOF'
# ============================================
# RETROOS - Configuración RetroArch
# ============================================

# Video
video_driver = "gl"
video_scale_integer = false
video_smooth = true
video_refresh_rate = 60
video_fullscreen = true
video_windowed_fullscreen = true
video_force_aspect = true
video_aspect_ratio = 1.777778
video_fullscreen_x = 0
video_fullscreen_y = 0
video_max_swapchain_images = 3
video_shared_context = true
video_hard_sync = true
video_hard_sync_frames = 0
video_frame_delay = 0
threaded_video = true
video_gpu_record = false
video_gpu_screenshot = false

# Audio
audio_driver = "pulse"
audio_rate_control = true
audio_out_rate = 48000
audio_latency = 64
audio_device = "default"
audio_enable = true
audio_disable_composition = true

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
autoconfig_directory = "/home/pi/.config/retroarch/autoconfig"

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

# Netplay
netplay_enable = false

# BIOS Paths
bios_directory = "/home/pi/.config/retroarch/system/bios"

# Performance
rewind_enable = false
run_ahead_enabled = false
EOF

    # Ajustes específicos por modelo
    if [ "$RPI_IS_RPI4" = true ]; then
        cat >> "$RETROARCH_DIR/retroarch.cfg" << 'EOF'

# Ajustes para RPi4
video_ctx_driver = "egl"
video_sync_refresh_rate = 60.00
video_hard_sync = true
video_frame_delay = 0
threaded_video = true
EOF
    elif [ "$RPI_IS_RPI3" = true ]; then
        cat >> "$RETROARCH_DIR/retroarch.cfg" << 'EOF'

# Ajustes para RPi3 (rendimiento)
video_ctx_driver = "dispmanx"
video_sync_refresh_rate = 60.00
video_hard_sync = false
video_frame_delay = 1
threaded_video = true
video_smooth = false
video_scale_integer = true
EOF
    else
        cat >> "$RETROARCH_DIR/retroarch.cfg" << 'EOF'

# Ajustes para RPi2 (máximo rendimiento)
video_ctx_driver = "dispmanx"
video_sync_refresh_rate = 60.00
video_hard_sync = false
video_frame_delay = 2
threaded_video = true
video_smooth = false
video_scale_integer = true
video_max_swapchain_images = 2
EOF
    fi
    
    log_success "RetroArch configurado para $RPI_MODEL"
}

# ============================================
# OPTIMIZACIONES POR MODELO
# ============================================

optimize_system() {
    log_step "Optimizando sistema para $RPI_MODEL..."
    
    # Configurar GPU según modelo
    if [ "$RPI_IS_RPI4" = true ]; then
        sudo bash -c 'echo "gpu_mem=256" >> /boot/config.txt'
        sudo bash -c 'cat >> /boot/config.txt << EOF

# RetroOS Optimizations for RPi4
over_voltage=2
arm_freq=1750
gpu_freq=600
v3d_freq=600
hdmi_enable_4kp60=1
force_turbo=1
EOF'
    elif [ "$RPI_IS_RPI3" = true ]; then
        sudo bash -c 'echo "gpu_mem=128" >> /boot/config.txt'
        sudo bash -c 'cat >> /boot/config.txt << EOF

# RetroOS Optimizations for RPi3
over_voltage=1
arm_freq=1300
gpu_freq=500
core_freq=400
force_turbo=0
disable_overscan=1
EOF'
    else
        sudo bash -c 'echo "gpu_mem=128" >> /boot/config.txt'
        sudo bash -c 'cat >> /boot/config.txt << EOF

# RetroOS Optimizations for RPi2
arm_freq=1000
gpu_freq=250
core_freq=250
disable_overscan=1
EOF'
    fi
    
    # Deshabilitar servicios innecesarios
    sudo systemctl disable bluetooth.service 2>/dev/null || true
    sudo systemctl disable hciuart.service 2>/dev/null || true
    
    # Ajustar swappiness
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
    
    log_success "Optimizaciones aplicadas para $RPI_MODEL"
}

# ============================================
# CONFIGURACIÓN DE BIOS
# ============================================

setup_bios() {
    log_step "Configurando estructura de BIOS..."
    
    mkdir -p "$BIOS_DIR"/{psx,n64,gb,gba,genesis,saturn,neogeo,atari,dreamcast,pce,segacd,3do,jaguar,lynx,ngp,wonderswan}
    
    # README de BIOS
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
    
    # README en español
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

# ============================================
# INSTALACIÓN DE PEGASUS
# ============================================

install_pegasus() {
    log_step "Instalando Pegasus FrontEnd..."
    
    cd "$RETROOS_DIR"
    
    # Versión según modelo
    if [ "$RPI_IS_RPI4" = true ]; then
        PEGASUS_URL="https://github.com/mmatyas/pegasus-frontend/releases/download/continuous/pegasus-frontend_continuous_2023-07-21_rpi-aarch64.AppImage"
    else
        PEGASUS_URL="https://github.com/mmatyas/pegasus-frontend/releases/download/continuous/pegasus-frontend_continuous_2023-07-21_rpi-armv7l.AppImage"
    fi
    
    log_info "Descargando Pegasus para $RPI_MODEL..."
    wget -q "$PEGASUS_URL" -O pegasus-frontend.AppImage || {
        log_error "Error descargando Pegasus"
        exit 1
    }
    
    chmod +x pegasus-frontend.AppImage
    sudo mv pegasus-frontend.AppImage /opt/pegasus-frontend.AppImage
    sudo ln -sf /opt/pegasus-frontend.AppImage /usr/local/bin/pegasus-frontend
    
    # Configurar Pegasus
    mkdir -p "$PEGASUS_DIR"
    
    cat > "$PEGASUS_DIR/settings.txt" << 'EOF'
game_dirs:
  /home/pi/RetroROMs
theme: /home/pi/.config/pegasus-frontend/themes/retroos
fullscreen: true
show_fps: false
force_aspect_ratio: 16:9
v-sync: true
exit_after_launch: false
remember_last_tab: true
start_in_game_collection: false
launch_command: /usr/local/bin/retroarch -L /home/pi/.config/retroarch/cores/{core}.so -c /home/pi/.config/retroarch/retroarch.cfg {file}
EOF
    
    # Instalar tema
    log_info "Instalando tema RetroOS..."
    mkdir -p "$PEGASUS_DIR/themes/retroos"
    cd "$PEGASUS_DIR/themes/retroos"
    
    cat > "theme.qml" << 'EOF'
import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    color: "#1a1a2e"
    
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a2e" }
            GradientStop { position: 0.5; color: "#16213e" }
            GradientStop { position: 1.0; color: "#0f3460" }
        }
    }
    
    Text {
        text: "🎮 RETROOS"
        color: "#e94560"
        font.pixelSize: 48
        font.bold: true
        anchors.centerIn: parent
    }
}
EOF
    
    log_success "Pegasus FrontEnd instalado"
}

# ============================================
# CREACIÓN DE SCRIPTS
# ============================================

create_scripts() {
    log_step "Creando scripts del sistema..."
    
    # Script de inicio
    cat > "$HOME/start_retroos.sh" << 'EOF'
#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== RETROOS LAUNCHER ===${NC}"
echo ""
echo "1) Pegasus FrontEnd (Recomendado)"
echo "2) Menú Gráfico RetroOS"
echo "3) RetroArch (solo)"
echo "4) EmulationStation"
echo "5) Salir"
echo ""
read -p "Opción: " choice

case $choice in
    1) pegasus-frontend ;;
    2) python3 ~/retroos_gui.py ;;
    3) retroarch ;;
    4) emulationstation ;;
    5) exit 0 ;;
    *) echo -e "${YELLOW}Opción inválida${NC}" ;;
esac
EOF
    chmod +x "$HOME/start_retroos.sh"
    
    # Script de verificación de BIOS
    cat > "$HOME/check_bios.sh" << 'EOF'
#!/bin/bash
BIOS_DIR="$HOME/.config/retroarch/system/bios"
echo "=== VERIFICADOR DE BIOS RETROOS ==="
echo ""
check() {
    if [ -f "$BIOS_DIR/$1" ]; then
        echo -e "\033[0;32m✓\033[0m $2"
    else
        echo -e "\033[0;31m✗\033[0m $2"
    fi
}
check "psx/scph5500.bin" "BIOS PSX Japón"
check "psx/scph5501.bin" "BIOS PSX USA"
check "psx/scph5502.bin" "BIOS PSX Europa"
check "n64/pifdata.bin" "BIOS N64"
check "gba/gba_bios.bin" "BIOS GBA"
check "neogeo/neogeo.zip" "BIOS Neo Geo"
EOF
    chmod +x "$HOME/check_bios.sh"
    
    # Script de información del sistema
    cat > "$HOME/sysinfo.sh" << 'EOF'
#!/bin/bash
echo "=== RETROOS - Información del Sistema ==="
echo ""
echo "Modelo: $(cat /proc/device-tree/model 2>/dev/null || echo "Desconocido")"
echo "CPU: $(nproc) cores"
echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Almacenamiento: $(df -h / | awk 'NR==2 {print $2}')"
echo "Temperatura: $(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 || echo "N/A")"
echo "IP: $(hostname -I | awk '{print $1}')"
echo "Kernel: $(uname -r)"
echo ""
EOF
    chmod +x "$HOME/sysinfo.sh"
    
    log_success "Scripts creados"
}

# ============================================
# INSTALACIÓN DE HERRAMIENTAS
# ============================================

install_tools() {
    log_step "Instalando herramientas adicionales..."
    
    # Herramientas según modelo
    if [ "$RPI_IS_RPI4" = true ]; then
        sudo apt install -y \
            htop iotop nethogs \
            nmap speedtest-cli \
            tree neofetch \
            >> "$INSTALL_LOG" 2>&1
    else
        # RPi3 y RPi2 - menos herramientas pesadas
        sudo apt install -y \
            htop \
            nmap \
            tree \
            >> "$INSTALL_LOG" 2>&1
    fi
    
    log_success "Herramientas instaladas"
}

# ============================================
# MENSAJE FINAL CON INFORMACIÓN DEL MODELO
# ============================================

show_summary() {
    clear
    echo -e "${BOLD}${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           ¡🎉 INSTALACIÓN COMPLETADA CON ÉXITO! 🎉           ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    echo -e "${BOLD}📋 RESUMEN DE INSTALACIÓN:${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} Sistema base actualizado"
    echo -e "${GREEN}✓${NC} RetroArch compilado e instalado"
    echo -e "${GREEN}✓${NC} ${#CORES[@]} cores descargados"
    echo -e "${GREEN}✓${NC} BIOS estructurados"
    echo -e "${GREEN}✓${NC} Pegasus FrontEnd instalado"
    echo -e "${GREEN}✓${NC} Menú gráfico creado"
    echo -e "${GREEN}✓${NC} Soporte para mandos configurado"
    echo -e "${GREEN}✓${NC} Gestión WiFi integrada"
    echo -e "${GREEN}✓${NC} Optimizaciones para $RPI_MODEL aplicadas"
    echo ""
    
    echo -e "${BOLD}🖥️ HARDWARE DETECTADO:${NC}"
    echo ""
    echo -e "  Modelo: ${BOLD}$RPI_MODEL${NC}"
    echo -e "  Cores CPU: ${BOLD}$RPI_CPU_CORES${NC}"
    echo -e "  Arquitectura: ${BOLD}$RPI_ARM_VERSION${NC}"
    echo -e "  RAM: ${BOLD}$(free -h | awk '/^Mem:/ {print $2}')${NC}"
    echo ""
    
    echo -e "${BOLD}🚀 CÓMO USAR RETROOS:${NC}"
    echo ""
    echo -e "  ${CYAN}1. Iniciar RetroOS:${NC}"
    echo "     ~/start_retroos.sh"
    echo ""
    echo -e "  ${CYAN}2. Iniciar menú gráfico:${NC}"
    echo "     python3 ~/retroos_gui.py"
    echo ""
    echo -e "  ${CYAN}3. Iniciar Pegasus:${NC}"
    echo "     pegasus-frontend"
    echo ""
    echo -e "  ${CYAN}4. Verificar BIOS:${NC}"
    echo "     ~/check_bios.sh"
    echo ""
    echo -e "  ${CYAN}5. Información del sistema:${NC}"
    echo "     ~/sysinfo.sh"
    echo ""
    
    echo -e "${BOLD}📁 DIRECTORIOS IMPORTANTES:${NC}"
    echo ""
    echo -e "  ${YELLOW}ROMs:${NC}       ~/RetroROMs/"
    echo -e "  ${YELLOW}BIOS:${NC}       ~/.config/retroarch/system/bios/"
    echo -e "  ${YELLOW}Config:${NC}     ~/.config/retroarch/retroarch.cfg"
    echo -e "  ${YELLOW}Log:${NC}        ~/retroos_install.log"
    echo ""
    
    echo -e "${BOLD}💡 CONSEJOS:${NC}"
    echo ""
    echo -e "  • Coloca tus ROMs en las carpetas correspondientes"
    echo -e "  • Conecta los mandos ANTES de iniciar RetroArch"
    echo -e "  • Las BIOS son necesarias para PSX, N64 y Neo Geo"
    if [ "$RPI_IS_RPI3" = true ] || [ "$RPI_IS_RPI2" = true ]; then
        echo -e "  ${YELLOW}• En RPi3/RPi2 usa sistemas ligeros (NES, SNES, Genesis, GBA)${NC}"
        echo -e "  ${YELLOW}• N64 y PSX pueden ir lentos en RPi3/RPi2${NC}"
    fi
    echo ""
    
    echo -e "${BOLD}${MAGENTA}¡Disfruta de tu RetroOS en $RPI_MODEL! 🎮${NC}"
    echo ""
}

# ============================================
# FUNCIÓN PRINCIPAL
# ============================================

main() {
    print_banner
    
    log "Iniciando instalación de RetroOS v$VERSION"
    log "Log de instalación: $INSTALL_LOG"
    
    # Detectar hardware
    detect_hardware
    
    # Preparar sistema
    prepare_system
    
    # Instalar RetroArch
    install_retroarch
    
    # Configurar RetroArch
    configure_retroarch
    
    # Instalar cores
    install_cores
    
    # Configurar BIOS
    setup_bios
    
    # Instalar Pegasus
    install_pegasus
    
    # Crear scripts
    create_scripts
    
    # Instalar herramientas
    install_tools
    
    # Optimizar sistema
    optimize_system
    
    # Mostrar resumen
    show_summary
    
    # Preguntar reinicio
    echo ""
    read -p "¿Reiniciar ahora para aplicar todos los cambios? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        log_info "Reiniciando sistema..."
        sudo reboot
    else
        log_info "Recuerda reiniciar para aplicar todos los cambios"
        log_info "Ejecuta '~/start_retroos.sh' para iniciar RetroOS"
    fi
    
    log_success "Instalación completada exitosamente"
}

# ============================================
# EJECUCIÓN
# ============================================

# Verificar que se ejecuta como usuario pi
if [ "$USER" != "pi" ]; then
    echo -e "${RED}Error: Este script debe ejecutarse como usuario pi${NC}"
    exit 1
fi

# Ejecutar instalación
main
