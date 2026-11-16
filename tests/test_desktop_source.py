#!/usr/bin/env python3
"""Static source-contract checks; these do not compile Qt or exercise the GUI."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT / "desktop" / "shell"

class DesktopSourceTests(unittest.TestCase):
    def test_required_files_present(self):
        for name in ("CMakeLists.txt", "main.cpp", "Main.qml", "README.md"):
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

    def test_launcher_avoids_shell_interpolation(self):
        cpp = (SHELL / "main.cpp").read_text()
        self.assertIn('QProcess::startDetached("gio", {"launch", appPaths.value(id)})', cpp)
        self.assertIn("if (!appPaths.contains(id)", cpp)
        for disallowed in ("system(", "popen(", '"/bin/sh"', '"bash -c"'):
            self.assertNotIn(disallowed, cpp)

    def test_interface_and_accessibility_hooks(self):
        qml = (SHELL / "Main.qml").read_text()
        for expected in ("backend.pinnedApps", "backend.availableApps",
                         "backend.launch(appId)", "backend.launchMatrix()",
                         "image://appicons/", "backend.pin(modelData.id)",
                         "reducedMotion", "root.dockExpanded",
                         'sequence: "Ctrl+Space"', 'sequence: "Ctrl+K"',
                         'sequence: "Escape"', "dockButton.activeFocus",
                         "focusPolicy: Qt.StrongFocus"):
            with self.subTest(expected=expected):
                self.assertIn(expected, qml)

if __name__ == "__main__":
    unittest.main()
