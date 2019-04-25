# - Searches for an installation of the Eigen v3 library
#
# Defines:
#
#   Eigen3_FOUND         True if Eigen3 was found, else false
#   Eigen3_INCLUDE_DIRS  The directories containing the header files (Eigen is header-only)
#
# To specify an additional directory to search, set Eigen3_ROOT.
#
# Author: Siddhartha Chaudhuri, 2016
#

SET(Eigen3_FOUND FALSE)

# Look for the Eigen header, first in the user-specified location and then in the system locations
SET(Eigen3_INCLUDE_DOC "The directory containing the Eigen include file Eigen/Core")
FIND_PATH(Eigen3_INCLUDE_DIRS NAMES Eigen/Core eigen/Core Eigen/core eigen/core
          PATHS ${Eigen3_ROOT}
          PATH_SUFFIXES eigen3 include include/eigen3
          DOC ${Eigen3_INCLUDE_DOC} NO_DEFAULT_PATH)
IF(NOT Eigen3_INCLUDE_DIRS)  # now look in system locations
  FIND_PATH(Eigen3_INCLUDE_DIRS NAMES Eigen/Core eigen/Core Eigen/core eigen/core
            PATH_SUFFIXES eigen3 include include/eigen3
            DOC ${Eigen3_INCLUDE_DOC})
ENDIF(NOT Eigen3_INCLUDE_DIRS)

IF(Eigen3_INCLUDE_DIRS)
  SET(Eigen3_FOUND TRUE)
ENDIF(Eigen3_INCLUDE_DIRS)

IF(Eigen3_FOUND)
  IF(NOT Eigen3_FIND_QUIETLY)
    MESSAGE(STATUS "Found Eigen3: headers at ${Eigen3_INCLUDE_DIRS}")
  ENDIF(NOT Eigen3_FIND_QUIETLY)
ELSE(Eigen3_FOUND)
  IF(Eigen3_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "Eigen3 not found")
  ENDIF(Eigen3_FIND_REQUIRED)
ENDIF(Eigen3_FOUND)
