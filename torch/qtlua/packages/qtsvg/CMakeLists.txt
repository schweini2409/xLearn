# -*- cmake -*-

SET(QT_USE_QTXML 1)
SET(QT_USE_QTSVG 1)
INCLUDE(${QT_USE_FILE})		     
INCLUDE_DIRECTORIES("${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")

IF (USE_LUAJIT)
   SET(CMAKE_CXX_FLAGS "-DLUAJIT")
   MESSAGE(STATUS "QTLua: building against LuaJIT")
ENDIF (USE_LUAJIT)

SET(qtsvg_SRC 
  qtsvg.h qtsvg.cpp
  qtluasvggenerator.h qtluasvggenerator.cpp )
   
MACRO_QT4_AUTOGEN(qtsvg_GEN ${qtsvg_SRC})
MACRO_ADD_QTLUA_MODULE(libqtsvg ${qtsvg_SRC} ${qtsvg_GEN})

MACRO_INSTALL_QTLUA_FILES(qtsvg init.lua)

ADD_TORCH_HELP(qtsvg "QT Interface")
