cmake_minimum_required(VERSION 3.5)
project(cherrymxboard30s-rgb VERSION 0.1.3)

include(CTest)
enable_testing()

include(FindPkgConfig)
pkg_check_modules(LIBUSB libusb-1.0 REQUIRED)

add_compile_options(-Wall)
add_compile_definitions(VERSION="${CMAKE_PROJECT_VERSION}")
add_compile_definitions(PROJECT_URL="https://github.com/luv4bytes/cherrymxboard30s-rgb")

add_executable(cherrymxboard30s-rgb src/main.c
    src/args/args.c
    src/log/log.c
    src/device/device.c
    src/help/help.c
    src/device/lighting.c)

set_target_properties(cherrymxboard30s-rgb PROPERTIES
    C_STANDARD 11
    C_STANDARD_REQUIRED YES
    C_EXTENSIONS YES)

target_link_libraries(cherrymxboard30s-rgb usb-1.0)
target_link_libraries(cherrymxboard30s-rgb m) # math

if(BUILD_TESTING)
    add_test(NAME cli-version COMMAND cherrymxboard30s-rgb --version)
    set_tests_properties(cli-version PROPERTIES
        PASS_REGULAR_EXPRESSION "${CMAKE_PROJECT_VERSION}")

    add_test(NAME cli-help COMMAND cherrymxboard30s-rgb)
    set_tests_properties(cli-help PROPERTIES
        PASS_REGULAR_EXPRESSION "Possible lighting modes:")

    add_executable(cherrymxboard30s-unit-tests
        tests/unit_tests.c
        src/args/args.c
        src/device/lighting.c
        src/help/help.c)
    target_include_directories(cherrymxboard30s-unit-tests PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
        ${LIBUSB_INCLUDE_DIRS})
    target_compile_options(cherrymxboard30s-unit-tests PRIVATE
        ${LIBUSB_CFLAGS_OTHER})
    set_target_properties(cherrymxboard30s-unit-tests PROPERTIES
        C_STANDARD 11
        C_STANDARD_REQUIRED YES
        C_EXTENSIONS YES)

    add_test(NAME lighting-defaults
        COMMAND cherrymxboard30s-unit-tests lighting-defaults)
    add_test(NAME lighting-mode-names
        COMMAND cherrymxboard30s-unit-tests lighting-mode-names)
    add_test(NAME args-defaults
        COMMAND cherrymxboard30s-unit-tests args-defaults)
    add_test(NAME args-parse-and-clamp
        COMMAND cherrymxboard30s-unit-tests args-parse-and-clamp)
endif()

set(CPACK_CMAKE_GENERATOR "Unix Makefiles")
set(CPACK_SOURCE_GENERATOR "TGZ")
set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Software for controlling RGB lighting on the Cherry MX Board 3.0 S for Linux.")
set(CPACK_PACKAGE_VENDOR "luv4bytes")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VERSION "${CMAKE_PROJECT_VERSION}")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set(CPACK_PACKAGE_CONTACT "https://github.com/luv4bytes/cherrymxboard30s-rgb")
set(CPACK_PACKAGE_SECTION "misc")

INSTALL(TARGETS cherrymxboard30s-rgb RUNTIME DESTINATION bin)
INSTALL(FILES LICENSE "README.md" DESTINATION share/${PROJECT_NAME}/doc)
INSTALL(DIRECTORY doc/img DESTINATION share/${PROJECT_NAME}/doc/doc FILES_MATCHING PATTERN "*")
INSTALL(FILES 50-cherrymx.rules DESTINATION /etc/udev/rules.d)
INSTALL(CODE "execute_process(COMMAND udevadm control --reload-rules)")
INSTALL(CODE "execute_process(COMMAND udevadm trigger)")

include(CPack)
