#[===============================================================================================[.rst:
FindZip
 Searches for an installation of the zip library. On success, it sets the following variables:
 ::
   Zip_FOUND        - Set to true to indicate the zip library was found
   Zip_INCLUDE_DIRS - The directory containing the header file zip/zip.h
   Zip_LIBRARIES    - The libraries needed to use the zip library

   Zip_VERSION_STRING - The verision of zip found (x.y.z)
   Zi_VERSION_MAJOR  - The major version of zip
   Zip_VERSION_MINOR  - The minor version of zip
   Zip_VERSION_PATCH  - The micro version of zip

 Imported targets are also defined through
 ::
    Zip::Zip

Hints
^^^^

To specify an additional directory to search, set Zip_ROOT.

 Original Author: Siddhartha Chaudhuri, 2009
 Current Author: Adesina Meekness, 2022

#]===============================================================================================]

# Look for the header, first in the user-specified location and then in the system locations
SET(Zip_INCLUDE_DOC "The directory containing the header file zip/zip.h")
FIND_PATH(Zip_INCLUDE_DIRS NAMES zip/zip.h PATHS ${Zip_ROOT} ${Zip_ROOT}/include DOC ${Zip_INCLUDE_DOC} NO_DEFAULT_PATH)
IF(NOT Zip_INCLUDE_DIRS)  # now look in system locations
    FIND_PATH(Zip_INCLUDE_DIRS NAMES zip.h zip/zip.h DOC ${Zip_INCLUDE_DOC})
ENDIF(NOT Zip_INCLUDE_DIRS)

SET(Zip_FOUND FALSE)

IF(Zip_INCLUDE_DIRS)
    SET(Zip_LIBRARY_DIRS ${Zip_INCLUDE_DIRS})

    file(STRINGS "${Zip_INCLUDE_DIRS}/zipconf.h" ZIPCONF_H REGEX "^#define LIBZIP_VERSION \"[^\"]*\"$")
    string(REGEX REPLACE "^.*LIBZIP_VERSION \"([0-9]+).*$"                   "\\1" Zip_VERSION_MAJOR "${ZIPCONF_H}")
    string(REGEX REPLACE "^.*LIBZIP_VERSION \"[0-9]+\\.([0-9]+).*$"          "\\1" Zip_VERSION_MINOR  "${ZIPCONF_H}")
    string(REGEX REPLACE "^.*LIBZIP_VERSION \"[0-9]+\\.[0-9]+\\.([0-9]+).*$" "\\1" Zip_VERSION_PATCH "${ZIPCONF_H}")
    set(Zip_VERSION_STRING "${Zip_VERSION_MAJOR}.${Zip_VERSION_MINOR}.${Zip_VERSION_PATCH}")

    IF("${Zip_LIBRARY_DIRS}" MATCHES "/include$")
        # Strip off the trailing "/include" in the path.
        GET_FILENAME_COMPONENT(Zip_LIBRARY_DIRS ${Zip_LIBRARY_DIRS} PATH)
    ENDIF("${Zip_LIBRARY_DIRS}" MATCHES "/include$")

    IF(EXISTS "${Zip_LIBRARY_DIRS}/lib")
        SET(Zip_LIBRARY_DIRS ${Zip_LIBRARY_DIRS}/lib)
    ENDIF(EXISTS "${Zip_LIBRARY_DIRS}/lib")

    # Find Zip libraries
    FIND_LIBRARY(Zip_DEBUG_LIBRARY NAMES zipd zip_d libzipd libzip_d
            PATH_SUFFIXES Debug ${CMAKE_LIBRARY_ARCHITECTURE} ${CMAKE_LIBRARY_ARCHITECTURE}/Debug
            PATHS ${Zip_LIBRARY_DIRS} NO_DEFAULT_PATH)
    FIND_LIBRARY(Zip_RELEASE_LIBRARY NAMES zip libzip
            PATH_SUFFIXES Release ${CMAKE_LIBRARY_ARCHITECTURE} ${CMAKE_LIBRARY_ARCHITECTURE}/Release
            PATHS ${Zip_LIBRARY_DIRS} NO_DEFAULT_PATH)

    SET(Zip_LIBRARIES )
    IF(Zip_DEBUG_LIBRARY AND Zip_RELEASE_LIBRARY)
        SET(Zip_LIBRARIES debug ${Zip_DEBUG_LIBRARY} optimized ${Zip_RELEASE_LIBRARY})
    ELSEIF(Zip_DEBUG_LIBRARY)
        SET(Zip_LIBRARIES ${Zip_DEBUG_LIBRARY})
    ELSEIF(Zip_RELEASE_LIBRARY)
        SET(Zip_LIBRARIES ${Zip_RELEASE_LIBRARY})
    ENDIF(Zip_DEBUG_LIBRARY AND Zip_RELEASE_LIBRARY)

    IF(Zip_LIBRARIES)
        SET(Zip_FOUND TRUE)
    ENDIF(Zip_LIBRARIES)
ENDIF(Zip_INCLUDE_DIRS)

IF(Zip_FOUND)
    IF(NOT Zip_FIND_QUIETLY)
        MESSAGE(STATUS "Found Zip: headers at ${Zip_INCLUDE_DIRS}, libraries at ${Zip_LIBRARY_DIRS}")
    ENDIF(NOT Zip_FIND_QUIETLY)
    IF(NOT TARGET Zip::Zip)
        add_library(Zip::Zip UNKNOWN IMPORTED)
        set_target_properties(Zip::Zip PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Zip_INCLUDE_DIRS}")
        IF(Zip_DEBUG_LIBRARY)
            set_property(TARGET Zip::Zip APPEND PROPERTY IMPORTED_CONFIGURATION DEBUG)
            set_target_properties(Zip::Zip PROPERTIES IMPORTED_LOCATION_DEBUG "${Zip_DEBUG_LIBRARY}")
        ENDIF(Zip_DEBUG_LIBRARY)
        IF(Zip_RELEASE_LIBRARY)
            set_property(TARGET Zip::Zip APPEND PROPERTY IMPORTED_CONFIGURATION RELEASE)
            set_target_properties(Zip::Zip PROPERTIES IMPORTED_LOCATION_RELEASE "${Zip_RELEASE_LIBRARY}")
        ENDIF(Zip_RELEASE_LIBRARY)
        IF(NOT Zip_DEBUG_LIBRARY AND Zip_RELEASE_LIBRARY)
            set_property(TARGET Zip::Zip APPEND PROPERTY IMPORTED_LOCATION "${Zip_LIBRARIES}")
        ENDIF(NOT Zip_DEBUG_LIBRARY AND Zip_RELEASE_LIBRARY)
    ENDIF(NOT TARGET Zip::Zip)
ELSE(Zip_FOUND)
    IF(Zip_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Zip library not found")
    ENDIF(Zip_FIND_REQUIRED)
ENDIF(Zip_FOUND)
