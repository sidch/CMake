# - Searches for an installation of the Eigen v3 library
#
# Defines:
#
#   EIGEN3_FOUND        True if Eigen3 was found, else false
#   EIGEN3_INCLUDE_DIR  The directories containing the header files (Eigen is header-only).
#
# Note that the naming (*_DIR and not *_DIRS) and capitalization is for compatibility with the FindEigen3.cmake shipped with
# recent versions of CMake.
#
# To specify an additional directory to search, set EIGEN3_ROOT.
#
# Author: Siddhartha Chaudhuri, 2016
#

SET(EIGEN3_FOUND FALSE)

# Look for the Eigen header, first in the user-specified location and then in the system locations
SET(Eigen3_INCLUDE_DOC "The directory containing the Eigen include file Eigen/Core")
FIND_PATH(EIGEN3_INCLUDE_DIR NAMES Eigen/Core eigen/Core Eigen/core eigen/core
          PATHS ${EIGEN3_ROOT}
          PATH_SUFFIXES eigen3 include include/eigen3
          DOC ${Eigen3_INCLUDE_DOC} NO_DEFAULT_PATH)
IF(NOT EIGEN3_INCLUDE_DIR)  # now look in system locations
  FIND_PATH(EIGEN3_INCLUDE_DIR NAMES Eigen/Core eigen/Core Eigen/core eigen/core
            PATH_SUFFIXES eigen3 include include/eigen3
            DOC ${Eigen3_INCLUDE_DOC})
ENDIF(NOT EIGEN3_INCLUDE_DIR)

IF(EIGEN3_INCLUDE_DIR)
  SET(EIGEN3_FOUND TRUE)
ENDIF(EIGEN3_INCLUDE_DIR)

IF(EIGEN3_FOUND)
  IF(NOT Eigen3_FIND_QUIETLY)
    MESSAGE(STATUS "Found Eigen3: headers at ${EIGEN3_INCLUDE_DIR}")
  ENDIF(NOT Eigen3_FIND_QUIETLY)
ELSE(EIGEN3_FOUND)
  IF(Eigen3_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "Eigen3 not found")
  ENDIF(Eigen3_FIND_REQUIRED)
ENDIF(EIGEN3_FOUND)
