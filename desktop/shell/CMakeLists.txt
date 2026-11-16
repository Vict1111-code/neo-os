cmake_minimum_required(VERSION 3.21)
project(neo_desktop LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Qml)
qt_standard_project_setup()
qt_add_executable(neo-desktop main.cpp)
qt_add_qml_module(neo-desktop
  URI NeoDesktop
  VERSION 1.0
  QML_FILES Main.qml
)
target_link_libraries(neo-desktop PRIVATE Qt6::Quick Qt6::Qml)
install(TARGETS neo-desktop RUNTIME DESTINATION bin)
