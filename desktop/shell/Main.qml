import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1180
    height: 740
    minimumWidth: 800
    minimumHeight: 560
    title: "NEO-OS • Desktop Preview"
    color: "#081422"
    property bool reducedMotion: false
    property string notice: "Select an application from the orbital dock"
    property bool showAppList: false

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#091929" }
            GradientStop { position: 0.55; color: "#10243c" }
            GradientStop { position: 1.0; color: "#201737" }
        }
    }
    // Atmospheric backdrop: native shapes, no screenshot masquerading as a functional UI.
    Rectangle {
        width: 500; height: 500; radius: 250
        anchors.centerIn: parent
        color: "transparent"; border.color: "#183c61"; border.width: 2
        opacity: 0.75
    }
    Rectangle {
        width: 280; height: 280; radius: 140
        anchors.centerIn: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#224578" }
            GradientStop { position: 1; color: "#111b37" }
        }
        border.color: "#538cce"
        opacity: 0.8
    }

    Rectangle {
        id: header
        height: 55; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
        color: "#d90b1829"
        border.color: "#2a5174"
        RowLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 16
            Text { text: "◈  NEO-OS"; color: "#67e8f9"; font.pixelSize: 22; font.bold: true }
            Text { text: "v0.1 • Desktop POC"; color: "#9fb5cd"; font.pixelSize: 12 }
            Item { Layout.fillWidth: true }
            Text { text: "Workspace 01"; color: "#e2e8f0"; font.pixelSize: 13 }
            Rectangle { width: 1; height: 22; color: "#45617d" }
            Button {
                text: "›_ Matrix CLI"
                onClicked: root.notice = backend.launchMatrix() ? "Terminal opened" : "Install xterm, kitty, konsole, gnome-terminal or xfce4-terminal"
            }
        }
    }

    Rectangle {
        id: rail
        width: 92; anchors.top: header.bottom; anchors.bottom: parent.bottom
        color: "#990a1929"
        Column {
            anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.topMargin: 30
            spacing: 24
            Repeater {
                model: [{symbol: "⌂", title:"Home"}, {symbol:"⌘", title:"Apps"}, {symbol:"⌁", title:"Matrix"}, {symbol:"⚙", title:"Settings"}]
                delegate: Column {
                    spacing: 4
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                    Rectangle {
                        width: 54; height: 48; radius: 12
                        color: "#193650"; border.color: "#367ba3"
                        Text { anchors.centerIn: parent; text: modelData.symbol; color:"#7dd3fc"; font.pixelSize: 26 }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (index === 1) root.showAppList = !root.showAppList
                                else if (index === 2) root.notice = backend.launchMatrix() ? "Matrix terminal opened" : "No compatible terminal installed"
                                else if (index === 3) root.reducedMotion = !root.reducedMotion
                                else root.notice = "NEO Desktop • home"
                            }
                        }
                    }
                    Text { width: 54; horizontalAlignment: Text.AlignHCenter; text: modelData.title; color:"#c3d5e6"; font.pixelSize: 11 }
                }
            }
        }
    }

    Column {
        anchors.left: rail.right; anchors.leftMargin: 34; anchors.top: header.bottom; anchors.topMargin: 40
        spacing: 12
        Text { text: "NEO WORKSPACE"; color: "#67e8f9"; font.pixelSize: 28; font.bold: true }
        Text { text: "Build · Learn · Code · Secure · Deploy"; color:"#d0d9e9"; font.pixelSize: 15 }
        Rectangle { height: 2; width: 220; color: "#b794f4" }
        Text { text: "Your first working desktop prototype"; color:"#b3c7da"; font.pixelSize: 13 }
    }

    Rectangle {
        anchors.top: header.bottom; anchors.topMargin: 28
        anchors.right: parent.right; anchors.rightMargin: 26
        width: 255; height: 128; radius: 14
        color: "#dd0c2036"; border.color: "#346a8f"
        Column {
            anchors.fill: parent; anchors.margins: 16; spacing: 13
            Text { text: "NEO CONTROL"; color: "#83e5f5"; font.bold: true; font.pixelSize: 14 }
            Text { text: "Desktop: prototype session"; color: "#e3eef9" }
            Row {
                spacing: 10
                Switch { id: motionToggle; checked: !root.reducedMotion; onToggled: root.reducedMotion = !checked }
                Text { text: "Motion effects"; color: "white"; anchors.verticalCenter: parent.verticalCenter }
            }
            Text { text: "Real system statistics come later"; color:"#94a3b8"; font.pixelSize: 11 }
        }
    }

    Rectangle {
        id: appPanel
        visible: root.showAppList
        anchors.left: rail.right; anchors.leftMargin: 26
        anchors.top: header.bottom; anchors.topMargin: 166
        width: 390; height: Math.min(350, root.height - 240)
        radius: 15; color: "#f00d2035"; border.color:"#4f8bae"; z: 10
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 14
            Text { text: "Installed applications • click to pin"; color:"white"; font.pixelSize: 15; font.bold: true }
            ListView {
                Layout.fillHeight: true; Layout.fillWidth: true; clip: true
                model: backend.availableApps; spacing: 3
                delegate: Rectangle {
                    width: ListView.view.width; height: 40; radius: 7
                    color: index % 2 ? "#17334b" : "#11283f"
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8
                        Text { text: modelData.name; color: "#e2efff"; Layout.fillWidth: true; elide: Text.ElideRight }
                        Button { text:"Pin"; onClicked: { backend.pin(modelData.id); root.notice = "Pinned " + modelData.name } }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.left: rail.right; anchors.leftMargin: 30; anchors.bottom: parent.bottom; anchors.bottomMargin: 22
        width: 490; height: 44; radius: 12
        color:"#db0c1b30"; border.color:"#305f82"
        Text {
            anchors.centerIn: parent; color:"#c7e3fb"; font.pixelSize: 12
            width: parent.width - 25; elide: Text.ElideRight
            text: root.notice
        }
    }

    Item {
        id: orbit
        width: 365; height: 350
        anchors.right: parent.right; anchors.rightMargin: 16
        anchors.bottom: parent.bottom; anchors.bottomMargin: 10
        property bool expanded: false
        property real orbitRadius: expanded ? 126 : 84
        Behavior on orbitRadius { enabled: !root.reducedMotion; NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        Rectangle {
            anchors.centerIn: parent
            width: orbit.orbitRadius * 2 + 25; height: width; radius: width / 2
            color: "transparent"; border.color: "#468cd0"; border.width: 2; opacity: 0.9
        }
        Rectangle {
            anchors.centerIn: parent
            width: 90; height: 90; radius: 45
            gradient: Gradient {
                GradientStop { position: 0; color: "#385e9a" }
                GradientStop { position: 1; color: "#182b59" }
            }
            border.color:"#b88df9"; border.width: 3
            Text { anchors.centerIn: parent; text: "◈"; color:"#8af1fc"; font.pixelSize: 44 }
            MouseArea { anchors.fill: parent; onClicked: orbit.expanded = !orbit.expanded }
        }
        Repeater {
            model: backend.pinnedApps
            delegate: Rectangle {
                required property string modelData
                required property int index
                readonly property var appInfo: backend.appById(modelData)
                readonly property int total: Math.max(1, backend.pinnedApps.length)
                readonly property real angle: (-Math.PI / 2) + (2 * Math.PI * index / total)
                width: 64; height: 64; radius: 32
                x: orbit.width/2 + Math.cos(angle)*orbit.orbitRadius - width/2
                y: orbit.height/2 + Math.sin(angle)*orbit.orbitRadius - height/2
                color: "#182f53"; border.color: "#65dcef"; border.width: 2
                scale: orbit.expanded ? 1.1 : 0.92
                Behavior on scale { enabled: !root.reducedMotion; NumberAnimation { duration: 200 } }
                Column {
                    anchors.centerIn: parent; spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: appInfo.name ? appInfo.name.charAt(0).toUpperCase() : "?"
                        color: "#ebffff"; font.pixelSize: 22; font.bold: true
                    }
                    Text {
                        width: 58; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                        text: appInfo.name || "App"; color: "white"; font.pixelSize: 10
                    }
                }
                MouseArea {
                    anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    onEntered: orbit.expanded = true
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            backend.unpin(modelData)
                            root.notice = "Removed pin"
                        } else {
                            root.notice = backend.launch(modelData) ? "Launched " + appInfo.name : "Could not launch " + appInfo.name + " (is gio installed?)"
                        }
                    }
                }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
            text: "ORBITAL DOCK  •  click center to expand"; color:"#b5d9ee"; font.pixelSize: 11
        }
    }
}
