# - Searches for an installation of the VRT library
#
# Defines:
#
#   VRT_FOUND           True if VRT was found, else false
#   VRT_LIBRARIES       Libraries to link
#   VRT_INCLUDE_DIRS    The directories containing the header files
#
# To specify an additional directory to search, set VRT_ROOT.
#
# Author: Siddhartha Chaudhuri, 2022
#

SET(VRT_FOUND FALSE)
SET(VRT_CFLAGS )

# Look for the VRT header, first in the user-specified location and then in the system locations
SET(VRT_INCLUDE_DOC "The directory containing the VRT include file VRT/Common.hpp")
FIND_PATH(VRT_INCLUDE_DIRS NAMES VRT/Common.hpp PATHS ${VRT_ROOT} ${VRT_ROOT}/include ${VRT_ROOT}/Source
          DOC ${VRT_INCLUDE_DOC} NO_DEFAULT_PATH)
IF(NOT VRT_INCLUDE_DIRS)  # now look in system locations
  FIND_PATH(VRT_INCLUDE_DIRS NAMES VRT/Common.hpp DOC ${VRT_INCLUDE_DOC})
ENDIF(NOT VRT_INCLUDE_DIRS)

# Only look for the library file in the immediate neighbourhood of the include directory
IF(VRT_INCLUDE_DIRS)
  SET(VRT_LIBRARY_DIRS ${VRT_INCLUDE_DIRS})
  IF("${VRT_LIBRARY_DIRS}" MATCHES "/include$" OR "${VRT_LIBRARY_DIRS}" MATCHES "/Source$")
    # Strip off the trailing "/include" or "/Source" from the path
    GET_FILENAME_COMPONENT(VRT_LIBRARY_DIRS ${VRT_LIBRARY_DIRS} PATH)
  ENDIF("${VRT_LIBRARY_DIRS}" MATCHES "/include$" OR "${VRT_LIBRARY_DIRS}" MATCHES "/Source$")

  FIND_LIBRARY(VRT_DEBUG_LIBRARY
               NAMES VRT_d VRTd
               PATH_SUFFIXES Debug ${CMAKE_LIBRARY_ARCHITECTURE} ${CMAKE_LIBRARY_ARCHITECTURE}/Debug
               PATHS ${VRT_LIBRARY_DIRS} ${VRT_LIBRARY_DIRS}/lib ${VRT_LIBRARY_DIRS}/Build/lib NO_DEFAULT_PATH)

  FIND_LIBRARY(VRT_RELEASE_LIBRARY
               NAMES VRT
               PATH_SUFFIXES Release ${CMAKE_LIBRARY_ARCHITECTURE} ${CMAKE_LIBRARY_ARCHITECTURE}/Release
               PATHS ${VRT_LIBRARY_DIRS} ${VRT_LIBRARY_DIRS}/lib ${VRT_LIBRARY_DIRS}/Build/lib NO_DEFAULT_PATH)

  SET(VRT_LIBRARIES)
  IF(VRT_DEBUG_LIBRARY AND VRT_RELEASE_LIBRARY)
    SET(VRT_LIBRARIES debug ${VRT_DEBUG_LIBRARY} optimized ${VRT_RELEASE_LIBRARY})
  ELSEIF(VRT_DEBUG_LIBRARY)
    SET(VRT_LIBRARIES ${VRT_DEBUG_LIBRARY})
  ELSEIF(VRT_RELEASE_LIBRARY)
    SET(VRT_LIBRARIES ${VRT_RELEASE_LIBRARY})
  ENDIF(VRT_DEBUG_LIBRARY AND VRT_RELEASE_LIBRARY)

  IF(VRT_LIBRARIES)
    SET(VRT_FOUND TRUE)
  ENDIF(VRT_LIBRARIES)
ENDIF(VRT_INCLUDE_DIRS)

IF(VRT_FOUND)
  IF(NOT VRT_FIND_QUIETLY)
    MESSAGE(STATUS "Found VRT: headers at ${VRT_INCLUDE_DIRS}, libraries at ${VRT_LIBRARIES}")
  ENDIF(NOT VRT_FIND_QUIETLY)
ELSE(VRT_FOUND)
  IF(VRT_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "VRT not found")
  ENDIF(VRT_FIND_REQUIRED)
ENDIF(VRT_FOUND)
