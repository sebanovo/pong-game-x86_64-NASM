
# Pong Game en Windows hecho en Nasm x86_64

<div align="center"> 
  <img src="https://github.com/user-attachments/assets/dfcfd32a-726f-4372-885c-9145cddc1165" alt="pong-game" width="400">
</div>

## 🎮 Descripción

Este proyecto es una implementación del clásico juego de Pong utilizando el lenguaje de programación Assembly con NASM y la biblioteca gráfica **raylib**. ¡Disfruta de un emocionante duelo entre dos jugadores en pantalla!

### 🏆 Objetivo del Juego

Cada jugador controla una paleta que debe golpear la pelota y evitar que pase por su lado de la pantalla. El primer jugador en alcanzar el puntaje máximo gana el juego.

## 🚀 Características

- **Modo de dos jugadores**: Ideal para partidas competitivas.
- **Detección precisa de colisiones**: La pelota rebota en las paletas y los bordes de la pantalla.
- **Interfaz gráfica sencilla**: Utiliza **raylib** para ofrecer gráficos limpios y efectivos.

## 📋 Requisitos

- **Compilador C**: GCC para compilar y enlazar `(te recomiendo este compilador si quieres compilar este proyecto)` `->` [gcc](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/).
- **NASM**: Ensamblador para procesadores x86/x86_64 [nasm](https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/win64/).
- **raylib**: Biblioteca gráfica para C/C++. Descárgala desde [raylib](https://github.com/raysan5/raylib/releases/).
- **CMake** (opcional): Para generar el sistema de compilación [cmake](https://cmake.org/download/).

## 🛠️ Instalación

1. **Clona el repositorio**:

```bash
git clone https://github.com/sebanovo/pong-game-x86_64-NASM.git
cd pong-game
```

2. **Compila el código**:

### Opción 1: Compilación con CMake

```bash
mkdir build

cd build

# Configura el proyecto
cmake ..

# Compila el proyecto
cmake --build .
```

### Opción 2: Compilación manual

```bash
mkdir build

# Compila el archivo ensamblador
nasm -f win64  -I./src -o build/main.o src/main.asm

# Enlaza y genera el ejecutable
gcc -std=c11 -Wall -L./lib -o build/game build/main.o lib/libraylib.a -lopengl32 -lgdi32 -lkernel32 -lwinmm
```

## 🎮 Controles

- **Jugador 1**: Usa las teclas `W` (arriba) y `S` (abajo).
- **Jugador 2**: Usa las teclas de flecha `↑` (arriba) y `↓` (abajo).

## ▶️ Ejecuta el Juego

```bash
./build/game.exe
```

## 📂 Fuentes y Librerías

Si el compilador no reconoce las librerías de raylib incluidas, puedes compilarlas manualmente. Encuentra el código fuente en su repositorio oficial de GitHub: [raylib github](https://github.com/raysan5/raylib/releases/tag/5.5).

## 🤝 Contribuciones

¡Tus contribuciones son bienvenidas! Si encuentras algún problema o tienes una mejora, abre un **issue** o envía un **pull request**.

---

<div align="center">
  ¡Gracias por apoyar este proyecto! 🚀
</div>
