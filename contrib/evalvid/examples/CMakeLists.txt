build_lib_example(
  NAME evalvid-client-server
  SOURCE_FILES evalvid-client-server.cc
  LIBRARIES_TO_LINK
    ${libcsma}
    ${libevalvid}
)

build_lib_example(
  NAME evalvid-lte
  SOURCE_FILES evalvid-lte.cc
  LIBRARIES_TO_LINK
    ${liblte}
    ${libevalvid}
)
