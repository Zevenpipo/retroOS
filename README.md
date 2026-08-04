# 🎮 RetroOS

<div align="center">

![RetroOS Banner](https://img.shields.io/badge/RetroOS-Raspberry%20Pi%204-blueviolet?style=for-the-badge&logo=raspberry-pi)
[![Version](https://img.shields.io/badge/version-1.0.0-green?style=flat-square)](https://github.com/tuusuario/retroos)
[![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-4B-red?style=flat-square&logo=raspberry-pi)](https://www.raspberrypi.com/)
[![RetroArch](https://img.shields.io/badge/RetroArch-latest-blue?style=flat-square&logo=retroarch)](https://www.retroarch.com/)
[![License](https://img.shields.io/badge/license-MIT-yellow?style=flat-square)](LICENSE)

**Sistema Retro completo para Raspberry Pi 4B**

[Instalación](#-instalación) • [Características](#-características) • [Requisitos](#-requisitos) • [Configuración](#-configuración) • [FAQ](#-faq)

</div>

---

## 📋 Tabla de Contenidos

- [📋 Tabla de Contenidos](#-tabla-de-contenidos)
- [✨ Características](#-características)
- [📦 Requisitos](#-requisitos)
- [🚀 Instalación](#-instalación)
- [🎯 Sistemas Emulados](#-sistemas-emulados)
- [🎮 Frontends](#-frontends)
- [💾 Estructura de Directorios](#-estructura-de-directorios)
- [🔧 Configuración](#-configuración)
- [📝 BIOS](#-bios)
- [🎨 Temas](#-temas)
- [⚡ Optimizaciones](#-optimizaciones)
- [🐛 Solución de Problemas](#-solución-de-problemas)
- [❓ FAQ](#-faq)
- [🤝 Contribuir](#-contribuir)
- [📄 Licencia](#-licencia)

---

## ✨ Características

- **🕹️ Emulación Multi-Sistema**: Soporte para más de 20 sistemas clásicos
- **⚡ Optimizado para RPi4**: Compilación específica con overclocking seguro
- **🎨 Doble Frontend**: Pegasus (moderno) y EmulationStation (clásico)
- **📦 BIOS Automatizada**: Estructura y verificador de BIOS incluidos
- **🚀 Rendimiento**: Ajustes de GPU y CPU para máximo FPS
- **🎮 Soporte de Controles**: Plug-and-play para USB y Bluetooth
- **📊 Sistema de Logs**: Registro completo de instalación
- **🔄 Actualizable**: Fácil de mantener y actualizar
- **💾 Gestión de Saves**: Guardado automático de partidas
- **🌐 Netplay**: Soporte para juego en línea (opcional)

---

## 📦 Requisitos

### Hardware
- **Raspberry Pi 4B** (2GB+ RAM recomendado)
- **Tarjeta SD**: 16GB mínimo (32GB+ recomendado)
- **Fuente de Alimentación**: 5V 3A USB-C
- **Controladores**: USB o Bluetooth
- **Display**: HDMI 1080p (4K opcional)
- **Conexión a Internet**: Necesaria para la instalación

### Software Base
- **Raspberry Pi OS Lite** (bullseye o bookworm)
- **SSH Habilitado** (para instalación headless)
- **Conexión WiFi o Ethernet**

### Opcional
- **Disipador/ventilador** para overclocking
- **Case** para una mejor estética
- **Teclado USB** para configuración inicial

---

## 🚀 Instalación

### Instalación Rápida (Recomendada)

```bash
# Descargar e instalar
curl -sSL https://raw.githubusercontent.com/Zevenpipo/retroOS/main/install_retroos.sh | bash
