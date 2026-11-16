import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1280
    height: 780
    minimumWidth: 860
    minimumHeight: 590
    title: "NEO-OS • Desktop Preview"
    color: "#081422"

    property bool reducedMotion: false
    property bool showAppList: false
    property bool dockExpanded: false
    property string notice: "Desktop prototype ready • Select an application"
    property string searchText: ""
    // Keyboard shortcuts are active within the preview window.
    function toggleApps() {
        showAppList = !showAppList
        if (showAppList) searchField.forceActiveFocus()
    }
    Shortcut {
        sequence: "Ctrl+Space"
        context: Qt.WindowShortcut
        onActivated: root.dockExpanded = !root.dockExpanded
    }
    Shortcut {
        sequence: "Ctrl+K"
        context: Qt.WindowShortcut
        onActivated: root.toggleApps()
    }
    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        enabled: root.showAppList || root.dockExpanded
        onActivated: {
            if (root.showAppList) root.showAppList = false
            else root.dockExpanded = false
        }
    }

    function openMatrix() {
        notice = backend.launchMatrix()
            ? "Matrix terminal launch requested"
            : "No supported terminal installed (xterm, kitty, konsole...)"
    }
    function openApp(appId, appName) {
        notice = backend.launch(appId)
            ? "Launch requested: " + appName
            : "Unable to start " + appName
    }

    // High-contrast, restrained classical-futuristic palette.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#081525" }
            GradientStop { position: 0.55; color: "#10243a" }
            GradientStop { position: 1.0; color: "#1c1a33" }
        }
    }
    // Atmospheric arc: intentionally subtle so the main work area remains usable.
    Rectangle {
        width: Math.min(root.width * 0.46, 550)
        height: width
        radius: width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"
        border.color: "#24415d"
        border.width: 1
        opacity: 0.42
    }
    Rectangle {
        width: Math.min(root.width * 0.25, 300)
        height: width
        radius: width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "#111e33"
        border.color: "#345a78"
        opacity: 0.24
    }

    Rectangle {
        id: header
        height: 58
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#ec0a182a"
        border.color: "#244967"
        z: 5
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 13
            Text {
                text: "◈  NEO-OS"
                color: "#7be5f5"
                font.pixelSize: 22
                font.bold: true
            }
            Text { text: "v0.2 preview"; color: "#aabfd4"; font.pixelSize: 12 }
            Item { Layout.fillWidth: true }
            Text { text: "Workspace 01"; color: "#d9e8f4"; font.pixelSize: 13 }
            Rectangle { width: 1; height: 23; color: "#35516d" }
            Button {
                text: "›_  Matrix CLI"
                onClicked: root.openMatrix()
                Accessible.name: "Open Matrix terminal"
            }
        }
    }

    Rectangle {
        id: rail
        width: 87
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: "#c00a1a2b"
        border.color: "#172e4b"
        Column {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 28
            spacing: 20
            Repeater {
                model: [
                    {glyph: "⌂", label: "Home"},
                    {glyph: "▦", label: "Apps"},
                    {glyph: ">_", label: "Matrix"},
                    {glyph: "⚙", label: "Settings"}
                ]
                delegate: Column {
                    required property var modelData
                    required property int index
                    spacing: 5
                    Rectangle {
                        width: 55; height: 48; radius: 12
                        color: railButton.hovered ? "#245176" : "#16334f"
                        border.color: railButton.activeFocus ? "#eabf72" : "#3a7ba0"
                        Text {
                            anchors.centerIn: parent
                            text: modelData.glyph
                            color: "#8fe8fa"
                            font.pixelSize: 23
                        }
                        Button {
                            id: railButton
                            anchors.fill: parent
                            opacity: 0
                            Accessible.name: modelData.label
                            onClicked: {
                                if (index === 1) {
                                    root.toggleApps()
                                } else if (index === 2) root.openMatrix()
                                else if (index === 3) root.reducedMotion = !root.reducedMotion
                                else root.notice = "NEO Workspace • Home"
                            }
                        }
                    }
                    Text {
                        width: 55
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.label
                        color: "#c0d6e9"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }

    Column {
        anchors.left: rail.right
        anchors.leftMargin: 34
        anchors.top: header.bottom
        anchors.topMargin: 42
        spacing: 9
        Text { text: "NEO WORKSPACE"; color: "#72e6f7"; font.pixelSize: 29; font.bold: true }
        Text { text: "Build · Learn · Code · Secure · Deploy"; color: "#d6dfef"; font.pixelSize: 15 }
        Rectangle { width: 220; height: 2; color: "#b794f4" }
        Text { text: "A real desktop preview • The full operating system is still under development"; color: "#aabdd1"; font.pixelSize: 12 }
    }

    Rectangle {
        anchors.top: header.bottom
        anchors.topMargin: 28
        anchors.right: parent.right
        anchors.rightMargin: 24
        width: 270
        height: 148
        radius: 14
        color: "#ea11263c"
        border.color: "#366b91"
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 6
            Text { text: "NEO CONTROL"; color: "#9befff"; font.bold: true; font.pixelSize: 14 }
            Text { text: "Preview session · Ubuntu host"; color: "#d2e3f1"; font.pixelSize: 12 }
            RowLayout {
                Switch {
                    id: motionToggle
                    checked: !root.reducedMotion
                    onToggled: root.reducedMotion = !checked
                    Accessible.name: "Enable interface animations"
                }
                Text { text: "Motion effects"; color: "#f1f5f9"; font.pixelSize: 13 }
                Item { Layout.fillWidth: true }
            }
            Text {
                text: "App icons are sourced from your system theme"
                wrapMode: Text.WordWrap
                color: "#9caec0"
                font.pixelSize: 11
                Layout.fillWidth: true
            }
        }
    }

    Rectangle {
        id: appPanel
        visible: root.showAppList
        z: 10
        anchors.left: rail.right
        anchors.leftMargin: 28
        anchors.top: header.bottom
        anchors.topMargin: 175
        width: Math.min(455, root.width - 165)
        height: Math.min(440, root.height - 255)
        radius: 15
        color: "#f00e2135"
        border.color: "#568bb0"
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8
            RowLayout {
                Text { text: "Installed applications"; color: "#effaff"; font.pixelSize: 17; font.bold: true }
                Item { Layout.fillWidth: true }
                Button { text: "Close"; onClicked: root.showAppList = false }
            }
            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search installed apps..."
                onTextChanged: root.searchText = text.toLowerCase()
                Accessible.name: "Search installed applications"
            }
            ListView {
                id: appList
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                spacing: 3
                model: backend.availableApps
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: appList.width
                    height: modelData.name.toLowerCase().indexOf(root.searchText) >= 0 ? 48 : 0
                    visible: height > 0
                    radius: 7
                    color: index % 2 ? "#1a354d" : "#132b43"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 7
                        spacing: 10
                        Image {
                            source: "image://appicons/" + modelData.id
                            sourceSize.width: 27; sourceSize.height: 27
                            Layout.preferredWidth: 27; Layout.preferredHeight: 27
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            text: modelData.name
                            color: "#e8f5ff"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Button {
                            text: "Open"
                            onClicked: root.openApp(modelData.id, modelData.name)
                        }
                        Button {
                            text: "Pin"
                            onClicked: {
                                root.notice = backend.pin(modelData.id)
                                    ? "Pinned " + modelData.name
                                    : modelData.name + " is already pinned"
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.left: rail.right
        anchors.leftMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: Math.min(490, root.width - 570)
        height: 42
        radius: 10
        color: "#e80c1d30"
        border.color: "#345d7f"
        Text {
            anchors.fill: parent
            anchors.margins: 12
            verticalAlignment: Text.AlignVCenter
            text: root.notice
            elide: Text.ElideRight
            color: "#d0e9fa"
            font.pixelSize: 12
        }
    }

    Item {
        id: orbit
        width: 340
        height: 335
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        property real orbitRadius: root.dockExpanded ? 122 : 88

        Behavior on orbitRadius {
            enabled: !root.reducedMotion
            NumberAnimation { duration: 230; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.centerIn: parent
            width: orbit.orbitRadius * 2 + 24
            height: width
            radius: width / 2
            color: "#081c3040"
            border.color: "#4f98cc"
            border.width: 2
        }
        Rectangle {
            anchors.centerIn: parent
            width: orbit.orbitRadius * 2 - 24
            height: width
            radius: width / 2
            color: "transparent"
            border.color: "#7c4ea0"
            border.width: 1
            opacity: 0.7
        }
        Rectangle {
            id: dockCenter
            anchors.centerIn: parent
            width: 88
            height: 88
            radius: 44
            gradient: Gradient {
                GradientStop { position: 0; color: "#385b9a" }
                GradientStop { position: 1; color: "#19294b" }
            }
            border.color: dockButton.activeFocus ? "#f6d58b" : "#c499f7"
            border.width: dockButton.activeFocus ? 4 : 3
            Text {
                anchors.centerIn: parent
                text: "◈"
                color: "#a0f8ff"
                font.pixelSize: 42
            }
            Button {
                id: dockButton
                anchors.fill: parent
                opacity: 0
                focusPolicy: Qt.StrongFocus
                Accessible.name: root.dockExpanded ? "Collapse orbital dock" : "Expand orbital dock"
                onClicked: root.dockExpanded = !root.dockExpanded
            }
        }
        Repeater {
            model: backend.pinnedApps
            delegate: Rectangle {
                required property string modelData
                required property int index
                readonly property var appInfo: backend.appById(modelData)
                readonly property int total: Math.max(1, backend.pinnedApps.length)
                readonly property real angle: (-Math.PI / 2) + (2 * Math.PI * index / total)
                width: 65; height: 65; radius: 33
                x: orbit.width / 2 + Math.cos(angle) * orbit.orbitRadius - width / 2
                y: orbit.height / 2 + Math.sin(angle) * orbit.orbitRadius - height / 2
                color: "#1b3150"
                border.color: iconMouse.containsMouse ? "#efcb8f" : "#6bd9f4"
                border.width: 2
                scale: root.dockExpanded ? 1.05 : 0.95
                Behavior on scale {
                    enabled: !root.reducedMotion
                    NumberAnimation { duration: 180 }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 1
                    Image {
                        id: appIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "image://appicons/" + modelData
                        sourceSize.width: 31
                        sourceSize.height: 31
                        width: 31; height: 31
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        visible: appIcon.status !== Image.Ready
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: appInfo.name ? appInfo.name.charAt(0) : "?"
                        color: "#e9ffff"
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        width: 60
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: appInfo.name || "App"
                        color: "#e5f3fd"
                        font.pixelSize: 10
                    }
                }
                MouseArea {
                    id: iconMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onEntered: root.dockExpanded = true
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            root.notice = backend.unpin(modelData) ? "Unpinned " + appInfo.name : "Cannot unpin"
                        } else {
                            root.openApp(modelData, appInfo.name)
                        }
                    }
                }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: "Ctrl+Space: dock  ·  Ctrl+K: search  ·  Esc: close"
            color: "#bddbeb"
            font.pixelSize: 11
        }
    }
}
