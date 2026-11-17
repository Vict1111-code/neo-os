#!/usr/bin/env python3
"""Static source-contract checks; these do not compile Qt or exercise the GUI."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT / "desktop" / "shell"

class DesktopSourceTests(unittest.TestCase):
    def test_required_files_present(self):
        for name in ("CMakeLists.txt", "main.cpp", "Main.qml", "README.md",
                     "MatrixPty.h", "MatrixPty.cpp", "MatrixTerminal.qml"):
            with self.subTest(name=name):
                self.assertTrue((SHELL / name).is_file())

    def test_qt_quick_module_and_backend_present(self):
        cmake = (SHELL / "CMakeLists.txt").read_text()
        cpp = (SHELL / "main.cpp").read_text()
        self.assertIn("qt_add_qml_module", cmake)
        self.assertIn("Q_PROPERTY(QStringList pinnedApps", cpp)
        self.assertIn("QSettings", cpp)
        self.assertIn("AppIconProvider", cpp)
        self.assertIn('engine.addImageProvider("appicons"', cpp)
        self.assertIn("QProcess::startDetached", cpp)

    def test_matrix_pty_prototype_contract(self):
        cmake = (SHELL / "CMakeLists.txt").read_text()
        cpp = (SHELL / "MatrixPty.cpp").read_text()
        header = (SHELL / "MatrixPty.h").read_text()
        qml = (SHELL / "MatrixTerminal.qml").read_text()
        root_qml = (SHELL / "Main.qml").read_text()
        for token in ("forkpty(", "QSocketNotifier", "waitpid(", "sendLine(",
                      "interrupt()", "stop()", "TERM", "dumb"):
            with self.subTest(token=token):
                self.assertIn(token, cpp)
        self.assertIn("Q_PROPERTY(bool running", header)
        self.assertIn("MatrixPty.cpp", cmake)
        self.assertIn("MatrixTerminal.qml", cmake)
        self.assertIn("target_link_libraries(neo-desktop PRIVATE util)", cmake)
        self.assertIn("matrixPty.sendLine", qml)
        self.assertIn("matrixPty.interrupt()", qml)
        self.assertIn("matrixPty.stop()", qml)
        self.assertIn("MatrixTerminal {", root_qml)

    def test_celestial_visual_contract_and_no_fake_data(self):
        qml = (SHELL / "Main.qml").read_text()
        cpp = (SHELL / "main.cpp").read_text()
        for token in (
            "Canvas {", "createRadialGradient", "source: backend.wallpaperUrl",
            "backend.setWallpaperPath(", "backend.setAccentTheme(",
            "backend.pinnedApps", "backend.availableApps",
            "backend.wallpaperThemes", "backend.wallpaperDim",
            "backend.setWallpaperDim(", "FileDialog {", "wallpaperPicker.open()",
            "backend.importWallpaper(", "backend.refreshWallpapers()",
            "NEO AI ASSISTANT", "SYSTEM STATUS", "NEO MARKET",
            "DEVICES & SYNC", "Ctrl+Space", "Ctrl+K",
            "not connected", "not implemented", "root.reducedMotion"
        ):
            with self.subTest(token=token):
                self.assertIn(token, qml)
        for token in ("QImageReader(path).canRead()", "wallpaperThemes READ wallpaperThemes",
                      "QStandardPaths::GenericDataLocation", "appearance/dim", "appearance/wallpaper",
                      "appearance/accent", "wallpaperUrlChanged()",
                      "accentThemeChanged()", "wallpaperThemesChanged()",
                      "QCryptographicHash::Sha256", "Q_INVOKABLE bool importWallpaper(",
                      "ensureBuiltInWallpapers()", "wallpaperErrorChanged()",
                      "image.save(destination, \"PNG\")"):
            with self.subTest(token=token):
                self.assertIn(token, cpp)

    def test_orbital_launcher_visual_and_keyboard_contract(self):
        qml = (SHELL / "Main.qml").read_text()
        for token in (
            "id: orbit", "readonly property real availableWidth",
            "readonly property real hubDiameter", "OrbitalGlassScene {",
            "id: dockButton", "id: orbitAppButton", "Accessible.description:",
            "OrbitalGlassScene {", "OrbitalGlassBubble {",
            "root.openApp(orbitApp.modelData, orbitApp.info.name)",
            "backend.unpin(orbitApp.modelData)",
            "enabled: !root.reducedMotion", "root.dockExpanded = !root.dockExpanded"
        ):
            with self.subTest(token=token):
                self.assertIn(token, qml)

    def test_orbital_glass_scene_is_separate_from_interactions(self):
        cmake = (SHELL / "CMakeLists.txt").read_text()
        visual = (SHELL / "OrbitalGlassScene.qml").read_text()
        bubble = (SHELL / "OrbitalGlassBubble.qml").read_text()
        for filename in ("OrbitalGlassScene.qml", "OrbitalGlassBubble.qml"):
            self.assertIn(filename, cmake)
        for effect in ("createRadialGradient", "createLinearGradient",
                       "ellipse(ctx", "ctx.arc(", "ctx.rotate("):
            self.assertIn(effect, visual)
        for hook in ("property string iconUrl", "property string label",
                     "property bool focused", "source: sphere.iconUrl"):
            self.assertIn(hook, bubble)

    def test_experimental_3d_scene_and_safe_fallback(self):
        qml = (SHELL / "Main.qml").read_text()
        cmake = (SHELL / "CMakeLists.txt").read_text()
        scene = (SHELL / "OrbitalSphere3D.qml").read_text()
        for token in ("Loader {", 'source: "OrbitalSphere3D.qml"',
                      "visible: threeDimensionalOrbit.status !== Loader.Ready",
                      "property bool prefer3DOrbit", "root.prefer3DOrbit = checked"):
            self.assertIn(token, qml)
        self.assertIn("OrbitalSphere3D.qml", cmake)
        # The opaque inner shell and translucent outer shell must coexist;
        # fully metallic dark layers previously made the model nearly black.
        self.assertIn('emissiveFactor: Qt.vector3d(0.008, 0.022, 0.046)', scene)
        self.assertIn('property real glassTransparency: 0.78', scene)
        self.assertIn('opacity: 1.0 - scene.glassTransparency * 0.92', scene)
        self.assertIn('opacity: 0.50 - scene.glassTransparency * 0.30', scene)
        self.assertIn("onOrbitGlassTransparencyChanged()", qml)
        self.assertIn('Accessible.name: "3D orbital glass transparency"', qml)
        self.assertIn('id: podium', scene)
        self.assertGreaterEqual(scene.count('source: "#Cylinder"'), 4)
        self.assertIn('baseColor: "#164969"', scene)
        self.assertIn('id: glassRim', scene)
        self.assertIn('baseColor: scene.violet ? "#201239" : "#0d2141"', scene)

        for token in ("import QtQuick3D", "View3D {",
                      "source: \"#Sphere\"", "PerspectiveCamera {",
                      "DirectionalLight {", "PointLight {",
                      "SceneEnvironment.Transparent", "PrincipledMaterial {"):
            self.assertIn(token, scene)

    def test_launcher_avoids_shell_interpolation(self):
        cpp = (SHELL / "main.cpp").read_text()
        self.assertIn('QProcess::startDetached("gio", {"launch", appPaths.value(id)})', cpp)
        self.assertIn("if (!appPaths.contains(id)", cpp)
        for disallowed in ("system(", "popen(", '"/bin/sh"', '"bash -c"'):
            self.assertNotIn(disallowed, cpp)

    def test_interface_and_accessibility_hooks(self):
        qml = (SHELL / "Main.qml").read_text()
        for expected in ("backend.pinnedApps", "backend.availableApps",
                         "backend.launch(appId)", "matrixPty.start()",
                         "image://appicons/", "backend.pin(modelData.id)",
                         "reducedMotion", "root.dockExpanded",
                         'sequence: "Ctrl+Space"', 'sequence: "Ctrl+K"',
                         'sequence: "Escape"', "dockButton.activeFocus",
                         "focusPolicy: Qt.StrongFocus"):
            with self.subTest(expected=expected):
                self.assertIn(expected, qml)

if __name__ == "__main__":
    unittest.main()
