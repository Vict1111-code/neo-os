cmake_minimum_required(VERSION 3.21)
project(neo_desktop LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Qml)
qt_standard_project_setup()
qt_add_executable(neo-desktop main.cpp MatrixPty.cpp MatrixPty.h)
qt_add_qml_module(neo-desktop
  URI NeoDesktop
  VERSION 1.0
  RESOURCE_PREFIX "/qt/qml"
  QML_FILES Main.qml MatrixTerminal.qml OrbitalGlassScene.qml OrbitalGlassBubble.qml
)
target_link_libraries(neo-desktop PRIVATE Qt6::Quick Qt6::Qml)
if(UNIX AND NOT APPLE)
  target_link_libraries(neo-desktop PRIVATE util)
endif()
install(TARGETS neo-desktop RUNTIME DESTINATION bin)

# A headless live-PTY integration check, independent from the graphical preview.
include(CTest)
if(BUILD_TESTING AND UNIX AND NOT APPLE)
  qt_add_executable(neo-matrix-pty-smoke MatrixPtySmoke.cpp MatrixPty.cpp MatrixPty.h)
  target_link_libraries(neo-matrix-pty-smoke PRIVATE Qt6::Core util)
  add_test(NAME matrix-pty-shell-smoke COMMAND neo-matrix-pty-smoke)
  set_tests_properties(matrix-pty-shell-smoke PROPERTIES TIMEOUT 15)
endif()
