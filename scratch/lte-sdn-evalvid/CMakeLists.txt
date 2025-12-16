# CMakeLists.txt for LTE + SDN + EvalVid simulation
# Compila sem PCH para evitar conflito com bofuss/list.h

set(target_prefix scratch_)

# Nome do executável
set(name lte-sdn-evalvid)

# Lista de arquivos fonte
set(source_files
    ${CMAKE_CURRENT_SOURCE_DIR}/main.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/video-qos-controller.cc
)

# Lista de bibliotecas necessárias
set(libraries_to_link
    ${libcore}
    ${libnetwork}
    ${libinternet}
    ${libpoint-to-point}
    ${libcsma}
    ${liblte}
    ${libmobility}
    ${libapplications}
    ${libflow-monitor}
    ${libevalvid}
    ${libofswitch13}
    ${libbridge}
)

# Cria o executável
add_executable(${target_prefix}${name} ${source_files})

# Define a pasta de saída
set_target_properties(
    ${target_prefix}${name}
    PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_OUTPUT_DIRECTORY}/scratch/
)

# Desabilita precompiled headers completamente para este target
set_target_properties(${target_prefix}${name} PROPERTIES DISABLE_PRECOMPILE_HEADERS ON)

# Linka as bibliotecas
target_link_libraries(${target_prefix}${name} PUBLIC ${LIB_AS_NEEDED_PRE} ${libraries_to_link} ${LIB_AS_NEEDED_POST})

# Inclui diretórios de header
target_include_directories(${target_prefix}${name} PUBLIC ${CMAKE_OUTPUT_DIRECTORY}/include)
