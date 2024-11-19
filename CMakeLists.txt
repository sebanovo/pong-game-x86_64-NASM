cmake_minimum_required(VERSION 3.15)
project(GameProject LANGUAGES C)

# Configuración de directorios
set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(LIB_DIR ${CMAKE_SOURCE_DIR}/lib)
set(OUTPUT_DIR ${CMAKE_BINARY_DIR})
set(ASM_FILE ${SRC_DIR}/main.asm)
set(ASM_OBJECT ${OUTPUT_DIR}/main.o) 

# NASM
find_program(NASM_EXECUTABLE nasm REQUIRED)

# Comando para compilar el archivo ensamblador
add_custom_command(
    OUTPUT ${ASM_OBJECT}
    COMMAND ${NASM_EXECUTABLE} -f win64 -I${SRC_DIR}/ -o ${ASM_OBJECT} ${ASM_FILE}
    DEPENDS ${ASM_FILE} 
    COMMENT "Compilando archivo ensamblador con NASM"
)

# Asegurar que la compilación del ensamblador sea una dependencia del ejecutable
add_custom_target(CompileASM DEPENDS ${ASM_OBJECT})

# Archivos de librería y dependencias
set(LINK_LIBRARIES
    ${LIB_DIR}/libraylib.a
    opengl32
    gdi32
    kernel32
    winmm
)

# Configurar el ejecutable final
add_executable(game)
add_dependencies(game CompileASM) # game depende de CompileASM
target_sources(game PRIVATE ${ASM_OBJECT})

# Especificar el lenguaje para el enlazador
set_target_properties(game PROPERTIES LINKER_LANGUAGE C)

# Establecer el estándar y las opciones del compilador C
target_compile_options(game PRIVATE -std=c11 -Wall)
target_link_libraries(game PRIVATE ${LINK_LIBRARIES})

# Establecer directorios de salida
set_target_properties(game PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_DIR}
)
