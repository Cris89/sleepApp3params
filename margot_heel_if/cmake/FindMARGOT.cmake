# - Check for the presence of the Argo framework
#
# The following variables are set when Argo is found:
#  HAVE_MARGOT         = Set to true, if all components of Argo
#                          have been found.
#  MARGOT_INCLUDES  = Include path for the header files of Argo
#  MARGOT_LIBRARIES    = Link these to use ANTAREX
#  MARGOT_CLI_COMMAND  = Path to the command line interface binary
#



## -----------------------------------------------------------------------------
## Check for the header files

set(MARGOT_SOURCE_PATH /home/cris/projects/benchmark/margot_project/core )
set(MARGOT_BINARY_PATH /home/cris/projects/benchmark/margot_project/core/build )
set(MARGOT_INSTALL_PATH /home/cris/projects/benchmark/margot_project/core/install )

# check for the header of the monitor module
find_path (MARGOT_MONITOR_INCLUDES margot/monitor.hpp PATHS
                    ${MARGOT_SOURCE_PATH}/framework/monitor/include
                    /usr/local/include
                    /usr/include
                    ${MARGOT_INSTALL_PATH}/include
                    ${CMAKE_EXTRA_INCLUDES}
          )

# check for the header of the asrtm module
find_path (MARGOT_ASRTM_INCLUDES margot/view.hpp PATHS
                    ${MARGOT_SOURCE_PATH}/framework/asrtm/include
                    /usr/local/include
                    /usr/include
                    ${MARGOT_INSTALL_PATH}/include
                    ${CMAKE_EXTRA_INCLUDES}
          )

# check for the header of the configuration file
find_path (MARGOT_CONF_INCLUDE margot/config.hpp PATHS
                    ${MARGOT_BINARY_PATH}/framework/include
                    /usr/local/include
                    /usr/include
                    ${MARGOT_INSTALL_PATH}/include
                    ${CMAKE_EXTRA_INCLUDES}
          )

# check for the header of the configuration file
find_path (MARGOT_CLI_COMMAND margot_cli PATHS
                    ${MARGOT_SOURCE_PATH}/margot_heel/margot_heel_cli/bin
                    /usr/local/bin
                    /usr/bin
                    ${MARGOT_INSTALL_PATH}/bin
                    ${CMAKE_EXTRA_INCLUDES}
          )

# check for the papi framework
set( PAPI_ROOT $ENV{PAPI_ROOT})
find_path (PAPI_INCLUDES papi.h
	PATHS ${PAPI_ROOT}/include
	NO_DEFAULT_PATH
	)
if (NOT PAPI_INCLUDES)
	find_path (PAPI_INCLUDES include/papi.h
		PATHS /usr/local /usr ${CMAKE_EXTRA_INCLUDES}
		)
endif(NOT PAPI_INCLUDES)

# check for the sensor framework
set( SENSORS_ROOT $ENV{SENSORS_ROOT})
find_path (SENSORS_INCLUDES sensors/sensors.h
	PATHS ${SENSORS_ROOT}/include
	NO_DEFAULT_PATH
	)
if (NOT SENSORS_INCLUDES)
	find_path (SENSORS_INCLUDES sensors/sensors.h
		PATHS /usr/local /usr ${CMAKE_EXTRA_INCLUDES}
		)
endif(NOT SENSORS_INCLUDES)

# check for the collector framework
set( COLLECTOR_ROOT $ENV{COLLECTOR_ROOT})
find_path (COLLECTOR_INCLUDES antarex_collector.h
	PATHS ${COLLECTOR_ROOT}
	NO_DEFAULT_PATH
	)
if (NOT COLLECTOR_INCLUDES)
	find_path (COLLECTOR_INCLUDES include/antarex_collector.h
		PATHS /usr/local /usr ${CMAKE_EXTRA_INCLUDES}
		)
endif(NOT COLLECTOR_INCLUDES)

# compose the real list of paths
set( MARGOT_INCLUDES ${MARGOT_MONITOR_INCLUDES} ${MARGOT_ASRTM_INCLUDES} ${MARGOT_CONF_INCLUDE} )
if (PAPI_INCLUDES)
	list( APPEND MARGOT_INCLUDES ${PAPI_INCLUDES} )
endif (PAPI_INCLUDES)
if (SENSORS_INCLUDES)
	list( APPEND MARGOT_INCLUDES ${SENSORS_INCLUDES} )
endif (SENSORS_INCLUDES)
if (COLLECTOR_INCLUDES)
	list( APPEND MARGOT_INCLUDES ${COLLECTOR_INCLUDES} )
endif (COLLECTOR_INCLUDES)

list( REMOVE_DUPLICATES MARGOT_INCLUDES )


## -----------------------------------------------------------------------------
## Check for the libraries

# check for the monitor module
find_library (MARGOT_MONITOR_LIBRARY margot_monitor PATHS
                ${MARGOT_BINARY_PATH}/framework/monitor
                ${MARGOT_INSTALL_PATH}/lib
                /usr/local/lib
                /usr/lib /lib
                ${CMAKE_EXTRA_LIBRARIES}
  )


# check for the asrtm module
find_library (MARGOT_ASRTM_LIBRARY margot_asrtm PATHS
                ${MARGOT_BINARY_PATH}/framework/asrtm
                ${MARGOT_INSTALL_PATH}/lib
                /usr/local/lib
                /usr/lib /lib
                ${CMAKE_EXTRA_LIBRARIES}
  )

# check for the PAPI library
find_library (PAPI_LIBRARIES libpapi.a papi
	PATHS ${PAPI_ROOT}/lib
	NO_DEFAULT_PATH
	)
if (NOT PAPI_LIBRARIES)
	find_library (PAPI_LIBRARIES libpapi.a papi
		PATHS /usr/local/lib /usr/lib /lib ${CMAKE_EXTRA_LIBRARIES}
		)
endif (NOT PAPI_LIBRARIES)

# check for the SENSOR library
find_library (SENSORS_LIBRARIES libsensors.so.4 libsensors.so sensors
	PATHS ${SENSORS_ROOT}
	NO_DEFAULT_PATH
	)
if (NOT SENSORS_LIBRARIES)
	find_library (SENSORS_LIBRARIES libsensors.so.4 libsensors.so sensors
		PATHS /usr/local/lib /usr/lib /lib ${CMAKE_EXTRA_LIBRARIES}
		)
endif (NOT SENSORS_LIBRARIES)

# check for the COLLECTOR library
find_library (COLLECTOR_LIBRARY libcollector.a collector
	PATHS ${COLLECTOR_ROOT}
	NO_DEFAULT_PATH
	)
if (NOT COLLECTOR_LIBRARY)
	find_library (COLLECTOR_LIBRARY libcollector.a collector
		PATHS /usr/local/lib /usr/lib /lib ${CMAKE_EXTRA_LIBRARIES}
		)
endif (NOT COLLECTOR_LIBRARY)

# append the libraries
set( MARGOT_LIBRARIES ${MARGOT_ASRTM_LIBRARY} ${MARGOT_MONITOR_LIBRARY} )
if (PAPI_LIBRARIES)
	list( APPEND MARGOT_LIBRARIES ${PAPI_LIBRARIES} )
endif(PAPI_LIBRARIES)
if (SENSORS_LIBRARIES)
	list( APPEND MARGOT_LIBRARIES ${SENSORS_LIBRARIES} )
endif(SENSORS_LIBRARIES)
if (COLLECTOR_LIBRARY)
	find_library (MOSQUITTO_LIBRARY libmosquitto.a mosquitto
		PATHS ${COLLECTOR_ROOT}/../lib/mosquitto-1.3.5/lib
		NO_DEFAULT_PATH
		)
	if (NOT COLLECTOR_LIBRARY)
		find_library (MOSQUITTO_LIBRARY libmosquitto.a mosquitto
			PATHS /usr/local/lib /usr/lib /lib ${CMAKE_EXTRA_LIBRARIES}
			)
	endif (NOT COLLECTOR_LIBRARY)
	list( APPEND MARGOT_LIBRARIES ${COLLECTOR_LIBRARY} ${MOSQUITTO_LIBRARY} ssl crypto pthread )
endif(COLLECTOR_LIBRARY)

list( REMOVE_DUPLICATES MARGOT_LIBRARIES )



## -----------------------------------------------------------------------------
## Actions taken when all components have been found


if (MARGOT_MONITOR_INCLUDES AND MARGOT_ASRTM_INCLUDES AND MARGOT_CONF_INCLUDE AND MARGOT_MONITOR_LIBRARY AND MARGOT_ASRTM_LIBRARY AND MARGOT_CLI_COMMAND)
  set (HAVE_MARGOT TRUE)
else (MARGOT_MONITOR_INCLUDES AND MARGOT_ASRTM_INCLUDES AND MARGOT_CONF_INCLUDE AND MARGOT_MONITOR_LIBRARY AND MARGOT_ASRTM_LIBRARY AND MARGOT_CLI_COMMAND)
  if (NOT MARGOT_FIND_QUIETLY)
    if (NOT (MARGOT_MONITOR_INCLUDES AND MARGOT_ASRTM_INCLUDES AND MARGOT_CONF_INCLUDE))
      message (STATUS "Unable to find MARGOT header files!")
  endif (NOT (MARGOT_MONITOR_INCLUDES AND MARGOT_ASRTM_INCLUDES AND MARGOT_CONF_INCLUDE))
    if (NOT (MARGOT_MONITOR_LIBRARY AND MARGOT_ASRTM_LIBRARY))
      message (STATUS "Unable to find MARGOT library files!")
  endif (NOT (MARGOT_MONITOR_LIBRARY AND MARGOT_ASRTM_LIBRARY))
    if (NOT MARGOT_CLI_COMMAND)
      message (STATUS "Unable to fine MARGOT gagway command line interface")
  endif (NOT MARGOT_CLI_COMMAND)
  endif (NOT MARGOT_FIND_QUIETLY)
endif (MARGOT_MONITOR_INCLUDES AND MARGOT_ASRTM_INCLUDES AND MARGOT_CONF_INCLUDE AND MARGOT_MONITOR_LIBRARY AND MARGOT_ASRTM_LIBRARY AND MARGOT_CLI_COMMAND)

if (HAVE_MARGOT)
  if (NOT MARGOT_FIND_QUIETLY)
    message (STATUS "Found components for MARGOT")
    message (STATUS "MARGOT_INCLUDES .... = ${MARGOT_INCLUDES}")
    message (STATUS "MARGOT_LIBRARIES ... = ${MARGOT_LIBRARIES}")
		message (STATUS "MARGOT_CLI ......... = ${MARGOT_CLI_COMMAND}")
  endif (NOT MARGOT_FIND_QUIETLY)
else (HAVE_MARGOT)
  if (MARGOT_FIND_QUIETLY)
    message (FATAL_ERROR "Could not find MARGOT!")
endif (MARGOT_FIND_QUIETLY)
endif (HAVE_MARGOT)

mark_as_advanced (
  HAVE_MARGOT
  MARGOT_INCLUDES
  MARGOT_LIBRARIES
  MARGOT_CLI_COMMAND
  )
