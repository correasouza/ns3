build_lib(
  LIBNAME evalvid
  SOURCE_FILES
    model/evalvid-client.cc
    model/evalvid-server.cc
    helper/evalvid-client-server-helper.cc
  HEADER_FILES
    model/evalvid-client.h
    model/evalvid-server.h
    helper/evalvid-client-server-helper.h
  LIBRARIES_TO_LINK
    ${libinternet}
    ${libapplications}
    ${libmobility}
  TEST_SOURCES
)
