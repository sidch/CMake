# - Searches for an installation of the Thea library
#
# Defines:
#
#   Thea_FOUND           True if Thea was found, else false
#   Thea_LIBRARIES       Libraries to link
#   Thea_LIBRARY_DIRS    Additional directories for libraries. These do not necessarily correspond to Thea_LIBRARIES, and both
#                        variables must be passed to the linker.
#   Thea_INCLUDE_DIRS    The directories containing the header files
#   Thea_CFLAGS          Extra compiler flags
#   Thea_DEBUG_CFLAGS    Extra compiler flags to be used only in debug builds
#   Thea_RELEASE_CFLAGS  Extra compiler flags to be used only in release builds
#   Thea_LDFLAGS         Extra linker flags
#
# To specify an additional directory to search, set Thea_ROOT.
# To suppress searching and linking specific dependencies, set Thea_WITH_<PACKAGENAME> to false.
#
# Author: Siddhartha Chaudhuri, 2009
#
# Revisions:
#   - 2011-04-12: Locate dependencies automatically, without requiring the caller to do so separately. [SC]
#

SET(Thea_FOUND FALSE)
UNSET(Thea_LIBRARY_DIRS)
UNSET(Thea_LIBRARY_DIRS CACHE)
UNSET(Thea_CFLAGS)
UNSET(Thea_CFLAGS CACHE)
UNSET(Thea_LDFLAGS)
UNSET(Thea_LDFLAGS CACHE)

# Required unless explicitly omitted, in which case the caller must find Eigen separately.
IF(NOT DEFINED Thea_WITH_EIGEN3)
  SET(Thea_WITH_EIGEN3 TRUE)
ENDIF()

# Any optional library is enabled by default (unless the found library was compiled without it). If it is explicitly omitted,
# Thea will drop all support for it even if it is separately found by the caller. To work around this, the caller can add the
# compiler definition "-DTHEA_ENABLE_<PACKAGENAME>=1".
IF(NOT DEFINED Thea_WITH_FREEIMAGE)
  SET(Thea_WITH_FREEIMAGE TRUE)
ENDIF(NOT DEFINED Thea_WITH_FREEIMAGE)

IF(NOT DEFINED Thea_WITH_LIB3DS)
  SET(Thea_WITH_LIB3DS TRUE)
ENDIF(NOT DEFINED Thea_WITH_LIB3DS)

IF(NOT DEFINED Thea_WITH_CLUTO)
  SET(Thea_WITH_CLUTO TRUE)
ENDIF(NOT DEFINED Thea_WITH_CLUTO)

IF(NOT DEFINED Thea_WITH_CGAL)
  SET(Thea_WITH_CGAL TRUE)
ENDIF(NOT DEFINED Thea_WITH_CGAL)

# Look for the Thea header, first in the user-specified location and then in the system locations
SET(Thea_INCLUDE_DOC "The directory containing the Thea include file Thea/Common.hpp")
FIND_PATH(Thea_INCLUDE_DIRS NAMES Thea/Common.hpp PATHS ${Thea_ROOT} ${Thea_ROOT}/include ${Thea_ROOT}/Source
          DOC ${Thea_INCLUDE_DOC} NO_DEFAULT_PATH)
IF(NOT Thea_INCLUDE_DIRS)  # now look in system locations
  FIND_PATH(Thea_INCLUDE_DIRS NAMES Thea/Common.hpp DOC ${Thea_INCLUDE_DOC})
ENDIF(NOT Thea_INCLUDE_DIRS)

# Only look for the library file in the immediate neighbourhood of the include directory
IF(Thea_INCLUDE_DIRS)
  SET(Thea_LIBRARY_DIRS ${Thea_INCLUDE_DIRS})
  IF("${Thea_LIBRARY_DIRS}" MATCHES "/include$" OR "${Thea_LIBRARY_DIRS}" MATCHES "/Source$")
    # Strip off the trailing "/include" or "/Source" from the path
    GET_FILENAME_COMPONENT(Thea_LIBRARY_DIRS ${Thea_LIBRARY_DIRS} PATH)
  ENDIF("${Thea_LIBRARY_DIRS}" MATCHES "/include$" OR "${Thea_LIBRARY_DIRS}" MATCHES "/Source$")

  FIND_LIBRARY(Thea_DEBUG_LIBRARY
               NAMES Thea_d Thead
               PATH_SUFFIXES Debug ${CMAKE_LIBRARY_ARCHITECTURE} ${CMAKE_LIBRARY_ARCHITECTURE}/Debug
               PATHS ${Thea_LIBRARY_DIRS} ${Thea_LIBRARY_DIRS}/lib ${Thea_LIBRARY_DIRS}/Build/lib NO_DEFAULT_PATH)

  FIND_LIBRARY(Thea_RELEASE_LIBRARY
               NAMES Thea
               PATH_SUFFIXES Release ${CMAKE_LIBRARY_ARCHITECTURE} ${CMAKE_LIBRARY_ARCHITECTURE}/Release
               PATHS ${Thea_LIBRARY_DIRS} ${Thea_LIBRARY_DIRS}/lib ${Thea_LIBRARY_DIRS}/Build/lib NO_DEFAULT_PATH)

  UNSET(Thea_LIBRARIES)
  IF(Thea_DEBUG_LIBRARY AND Thea_RELEASE_LIBRARY)
    SET(Thea_LIBRARIES debug ${Thea_DEBUG_LIBRARY} optimized ${Thea_RELEASE_LIBRARY})
  ELSEIF(Thea_DEBUG_LIBRARY)
    SET(Thea_LIBRARIES ${Thea_DEBUG_LIBRARY})
  ELSEIF(Thea_RELEASE_LIBRARY)
    SET(Thea_LIBRARIES ${Thea_RELEASE_LIBRARY})
  ENDIF(Thea_DEBUG_LIBRARY AND Thea_RELEASE_LIBRARY)

  IF(Thea_LIBRARIES)
    SET(Thea_FOUND TRUE)

    # Update the library directories based on the actual library locations
    UNSET(Thea_LIBRARY_DIRS)
    UNSET(Thea_LIBRARY_DIRS CACHE)
    IF(Thea_DEBUG_LIBRARY)
      GET_FILENAME_COMPONENT(Thea_LIBDIR ${Thea_DEBUG_LIBRARY} PATH)
      SET(Thea_LIBRARY_DIRS ${Thea_LIBRARY_DIRS} ${Thea_LIBDIR})
    ENDIF(Thea_DEBUG_LIBRARY)
    IF(Thea_RELEASE_LIBRARY)
      GET_FILENAME_COMPONENT(Thea_LIBDIR ${Thea_RELEASE_LIBRARY} PATH)
      SET(Thea_LIBRARY_DIRS ${Thea_LIBRARY_DIRS} ${Thea_LIBDIR})
    ENDIF(Thea_RELEASE_LIBRARY)

    # Flags for importing symbols from dynamically linked libraries
    IF(WIN32)
      # What's a good way of testing whether the .lib is static, or merely exports symbols from a DLL? For now, let's assume
      # it always exports (or hope that __declspec(dllimport) is a noop for static libraries)
      SET(Thea_CFLAGS "-DTHEA_DLL -DTHEA_DLL_IMPORTS")
    ELSE(WIN32)
      IF("${Thea_LIBRARIES}" MATCHES ".dylib$" OR "${Thea_LIBRARIES}" MATCHES ".so$")
        SET(Thea_CFLAGS "-DTHEA_DLL -DTHEA_DLL_IMPORTS")
      ENDIF("${Thea_LIBRARIES}" MATCHES ".dylib$" OR "${Thea_LIBRARIES}" MATCHES ".so$")
    ENDIF(WIN32)

    # Read extra flags to be used to build Thea (key-value parsing via https://stackoverflow.com/a/17168870)
    SET(Thea_BUILD_FLAGS_FILE "${Thea_INCLUDE_DIRS}/Thea/BuildFlags.txt")
    IF(EXISTS "${Thea_BUILD_FLAGS_FILE}")
      FILE(STRINGS "${Thea_BUILD_FLAGS_FILE}" Thea_BUILD_FLAGS)
      FOREACH(NameAndValue ${Thea_BUILD_FLAGS})
        # Strip leading spaces
        STRING(REGEX REPLACE "^[ ]+" "" NameAndValue ${NameAndValue})
        # Find variable name
        STRING(REGEX MATCH "^[^=]+" Name ${NameAndValue})
        # Find the value
        STRING(REPLACE "${Name}=" "" Value ${NameAndValue})
        # Set the variable
        SET(Thea_${Name} "${Value}")
      ENDFOREACH(NameAndValue ${Thea_BUILD_FLAGS})
    ENDIF(EXISTS "${Thea_BUILD_FLAGS_FILE}")

  ENDIF(Thea_LIBRARIES)
ENDIF(Thea_INCLUDE_DIRS)

IF(Thea_FOUND)
  # If Thea was built in LITE mode but the WITH_<PACKAGENAME> flags are still enabled (this would probably be because of a bug,
  # e.g. if the BuildFlags.txt file omitted them), disable them.
  IF(Thea_LITE)
    SET(Thea_WITH_CGAL FALSE)
    SET(Thea_WITH_CLUTO FALSE)
    SET(Thea_WITH_FREEIMAGE FALSE)
    SET(Thea_WITH_LIB3DS FALSE)
  ENDIF(Thea_LITE)

  IF(Thea_EXTERN_TEMPLATES)
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_EXTERN_TEMPLATES=1")
  ENDIF(Thea_EXTERN_TEMPLATES)
ENDIF(Thea_FOUND)

# Dependency: Eigen3 (required)
IF(Thea_FOUND AND Thea_WITH_EIGEN3)
  IF(EXISTS ${Thea_ROOT}/installed-eigen3)
    SET(EIGEN3_ROOT ${Thea_ROOT}/installed-eigen3)
  ELSE(EXISTS ${Thea_ROOT}/installed-eigen3)
    SET(EIGEN3_ROOT ${Thea_ROOT})
  ENDIF(EXISTS ${Thea_ROOT}/installed-eigen3)
  FIND_PACKAGE(Eigen3)
  IF(EIGEN3_FOUND)
    SET(Thea_INCLUDE_DIRS ${Thea_INCLUDE_DIRS} ${EIGEN3_INCLUDE_DIR})
  ELSE(EIGEN3_FOUND)
    MESSAGE(STATUS "Thea: Eigen3 not found")
    SET(Thea_FOUND FALSE)
  ENDIF(EIGEN3_FOUND)
ENDIF(Thea_FOUND AND Thea_WITH_EIGEN3)

# Dependency: CGAL (optional)
IF(Thea_FOUND AND Thea_WITH_CGAL)
  IF(EXISTS ${Thea_ROOT}/installed-cgal)
    SET(CGAL_ROOT ${Thea_ROOT}/installed-cgal)
  ELSE(EXISTS ${Thea_ROOT}/installed-cgal)
    SET(CGAL_ROOT ${Thea_ROOT})
  ENDIF(EXISTS ${Thea_ROOT}/installed-cgal)
  FIND_PACKAGE(CGAL)
  IF(CGAL_FOUND)
    SET(Thea_INCLUDE_DIRS ${Thea_INCLUDE_DIRS} ${CGAL_INCLUDE_DIRS})
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_CGAL=1")
    SET(Thea_DEBUG_CFLAGS "${Thea_DEBUG_CFLAGS} ${CGAL_DEBUG_CFLAGS}")
    SET(Thea_RELEASE_CFLAGS "${Thea_RELEASE_CFLAGS} ${CGAL_RELEASE_CFLAGS}")

    IF(CGAL_LIBRARY)
      SET(Thea_LIBRARIES ${Thea_LIBRARIES} ${CGAL_LIBRARY})
      SET(Thea_LIBRARY_DIRS ${Thea_LIBRARY_DIRS} ${CGAL_LIBRARY_DIRS})
    ENDIF(CGAL_LIBRARY)

    # CGAL appends the directory containing its own CMake modules to the module search path. We shouldn't need it after this
    # point, so let's drop everything on the module path other than the first component.
    LIST(GET CMAKE_MODULE_PATH 0 CMAKE_MODULE_PATH)

  ELSE(CGAL_FOUND)  # this is not a fatal error
    MESSAGE(STATUS "CGAL not found: library will be built without CGAL-dependent components")
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_CGAL=0")
  ENDIF(CGAL_FOUND)
ELSE(Thea_FOUND AND Thea_WITH_CGAL)
  SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_CGAL=0")
ENDIF(Thea_FOUND AND Thea_WITH_CGAL)

# Dependency: CLUTO (optional)
IF(Thea_FOUND AND Thea_WITH_CLUTO)
  IF(EXISTS ${Thea_ROOT}/installed-cluto)
    SET(CLUTO_ROOT ${Thea_ROOT}/installed-cluto)
  ELSE(EXISTS ${Thea_ROOT}/installed-cluto)
    SET(CLUTO_ROOT ${Thea_ROOT})
  ENDIF(EXISTS ${Thea_ROOT}/installed-cluto)
  FIND_PACKAGE(CLUTO)
  IF(CLUTO_FOUND)
    SET(Thea_LIBRARIES ${Thea_LIBRARIES} ${CLUTO_LIBRARIES})
    SET(Thea_INCLUDE_DIRS ${Thea_INCLUDE_DIRS} ${CLUTO_INCLUDE_DIRS})
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_CLUTO=1")
  ELSE(CLUTO_FOUND)
    MESSAGE(STATUS "Thea: CLUTO not found")  # this is not a fatal error
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_CLUTO=0")
  ENDIF(CLUTO_FOUND)
ELSE(Thea_FOUND AND Thea_WITH_CLUTO)
  SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_CLUTO=0")
ENDIF(Thea_FOUND AND Thea_WITH_CLUTO)

# Dependency: FreeImage (optional)
IF(Thea_FOUND AND Thea_WITH_FREEIMAGE)
  IF(EXISTS ${Thea_ROOT}/installed-freeimage)
    SET(FreeImage_ROOT ${Thea_ROOT}/installed-freeimage)
  ELSE(EXISTS ${Thea_ROOT}/installed-freeimage)
    SET(FreeImage_ROOT ${Thea_ROOT})
  ENDIF(EXISTS ${Thea_ROOT}/installed-freeimage)
  SET(FreeImage_LANGUAGE "C++")
  FIND_PACKAGE(FreeImage)
  IF(FreeImage_FOUND)
    SET(Thea_LIBRARIES ${Thea_LIBRARIES} ${FreeImage_LIBRARIES})
    SET(Thea_INCLUDE_DIRS ${Thea_INCLUDE_DIRS} ${FreeImage_INCLUDE_DIRS})
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_FREEIMAGE=1")
  ELSE(FreeImage_FOUND)
    MESSAGE(STATUS "Thea: FreeImage not found")  # this is not a fatal error
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_FREEIMAGE=0")
  ENDIF(FreeImage_FOUND)
ELSE(Thea_FOUND AND Thea_WITH_FREEIMAGE)
  SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_FREEIMAGE=0")
ENDIF(Thea_FOUND AND Thea_WITH_FREEIMAGE)

# Dependency: Lib3ds (optional)
IF(Thea_FOUND AND Thea_WITH_LIB3DS)
  IF(EXISTS ${Thea_ROOT}/installed-lib3ds)
    SET(Lib3ds_ROOT ${Thea_ROOT}/installed-lib3ds)
  ELSE(EXISTS ${Thea_ROOT}/installed-lib3ds)
    SET(Lib3ds_ROOT ${Thea_ROOT})
  ENDIF(EXISTS ${Thea_ROOT}/installed-lib3ds)
  FIND_PACKAGE(Lib3ds)
  IF(Lib3ds_FOUND)
    SET(Thea_LIBRARIES ${Thea_LIBRARIES} ${Lib3ds_LIBRARIES})
    SET(Thea_INCLUDE_DIRS ${Thea_INCLUDE_DIRS} ${Lib3ds_INCLUDE_DIRS})
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_LIB3DS=1")
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_LIB3DS_VERSION_MAJOR=${Lib3ds_VERSION_MAJOR}")
  ELSE(Lib3ds_FOUND)
    MESSAGE(STATUS "Thea: Lib3ds not found")  # this is not a fatal error
    SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_LIB3DS=0")
  ENDIF(Lib3ds_FOUND)
ELSE(Thea_FOUND AND Thea_WITH_LIB3DS)
  SET(Thea_CFLAGS "${Thea_CFLAGS} -DTHEA_ENABLE_LIB3DS=0")
ENDIF(Thea_FOUND AND Thea_WITH_LIB3DS)

# Platform libs
FIND_PACKAGE(Threads REQUIRED)
SET(Thea_LIBRARIES ${Thea_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})

IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  SET(Thea_LIBRARIES ${Thea_LIBRARIES} "-framework Carbon")
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

SET(Thea_LIBRARIES ${Thea_LIBRARIES} ${CMAKE_DL_LIBS})  # for loading plugins with DynLib

# Remove duplicate entries from lists, else the same dirs and flags can repeat many times
# Don't remove duplicates from Thea_LIBRARIES -- the list includes repetitions of "debug" and "optimized"

IF(Thea_LIBRARY_DIRS)
  LIST(REMOVE_DUPLICATES Thea_LIBRARY_DIRS)
ENDIF(Thea_LIBRARY_DIRS)

IF(Thea_INCLUDE_DIRS)
  LIST(REMOVE_DUPLICATES Thea_INCLUDE_DIRS)
ENDIF(Thea_INCLUDE_DIRS)

IF(Thea_CFLAGS)
  LIST(REMOVE_DUPLICATES Thea_CFLAGS)
ENDIF(Thea_CFLAGS)

IF(Thea_DEBUG_CFLAGS)
  LIST(REMOVE_DUPLICATES Thea_DEBUG_CFLAGS)
ENDIF(Thea_DEBUG_CFLAGS)

IF(Thea_RELEASE_CFLAGS)
  LIST(REMOVE_DUPLICATES Thea_RELEASE_CFLAGS)
ENDIF(Thea_RELEASE_CFLAGS)

IF(Thea_LDFLAGS)
  LIST(REMOVE_DUPLICATES Thea_LDFLAGS)
ENDIF(Thea_LDFLAGS)

SET(Thea_LIBRARY_DIRS ${Thea_LIBRARY_DIRS} CACHE STRING "Additional directories for libraries required by Thea" FORCE)
SET(Thea_CFLAGS ${Thea_CFLAGS} CACHE STRING "Extra compiler flags required by Thea" FORCE)
SET(Thea_LDFLAGS ${Thea_LDFLAGS} CACHE STRING "Extra linker flags required by Thea" FORCE)

IF(Thea_FOUND)
  IF(NOT Thea_FIND_QUIETLY)
    MESSAGE(STATUS "Found Thea: headers at ${Thea_INCLUDE_DIRS}, libraries at ${Thea_LIBRARIES}")
  ENDIF(NOT Thea_FIND_QUIETLY)
ELSE(Thea_FOUND)
  IF(Thea_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "Thea not found")
  ENDIF(Thea_FIND_REQUIRED)
ENDIF(Thea_FOUND)
