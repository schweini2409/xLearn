# -*- cmake -*-

INCLUDE(CheckIncludeFiles)
INCLUDE(CheckFunctionExists)

IF (UNIX OR NOT WIN32)
  CHECK_INCLUDE_FILES(fcntl.h HAVE_FCNTL_H)
  CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)
  CHECK_INCLUDE_FILES(dirent.h HAVE_DIRENT_H)
  CHECK_INCLUDE_FILES(time.h HAVE_TIME_H)
  CHECK_INCLUDE_FILES(sys/time.h HAVE_SYS_TIME_H)
  CHECK_INCLUDE_FILES(sys/ndir.h HAVE_SYS_NDIR_H)
  CHECK_INCLUDE_FILES(sys/dir.h HAVE_SYS_DIR_H)
  CHECK_INCLUDE_FILES(ndir.h HAVE_NDIR_H)
  CHECK_FUNCTION_EXISTS(getcwd HAVE_GETCWD)
ENDIF (UNIX OR NOT WIN32)


INCLUDE_DIRECTORIES(
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_BINARY_DIR}")

CONFIGURE_FILE("paths.h.in" "${CMAKE_CURRENT_BINARY_DIR}/paths.h")
CONFIGURE_FILE("init.lua.in" "${CMAKE_CURRENT_BINARY_DIR}/init.lua")

SET(src 
  "${CMAKE_CURRENT_SOURCE_DIR}/paths.c"
  "${CMAKE_CURRENT_BINARY_DIR}/paths.h" )

SET(luasrc 
  "${CMAKE_CURRENT_BINARY_DIR}/init.lua")

ADD_TORCH_PACKAGE(paths "${src}" "${luasrc}" "System")

TARGET_LINK_LIBRARIES(paths ${LUA_LIBRARIES})
