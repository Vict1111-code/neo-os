import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1360
    height: 820
    minimumWidth: 980
    minimumHeight: 640
    title: "NEO-OS • Celestial Desktop Preview"
    color: "#060d24"

    property bool reducedMotion: false
    property bool showAppList: false
    property bool showMatrix: false
    property bool showSettings: false
    property bool dockExpanded: true
    property string searchText: ""
    property string notice: "NEO Desktop visual preview • Native Linux apps available"
    property color neon: backend.accentTheme === "violet" ? "#d970ff" : "#38dcff"
    property color neonSoft: backend.accentTheme === "violet" ? "#a34ccf" : "#287cb5"
    property date clockTime: new Date()
    property int workspace: 1

    Timer { interval: 30000; running: true; repeat: true; onTriggered: root.clockTime = new Date() }

    function toggleApps() {
        showSettings = false
        showAppList = !showAppList
        if (showAppList) searchField.forceActiveFocus()
    }
    function openMatrix() {
        showMatrix = true
        if (!matrixPty.running && !matrixPty.start())
            notice = "Unable to start Matrix CLI"
    }
    function openApp(appId, appName) {
        notice = backend.launch(appId)
            ? "Launch requested: " + appName : "Unable to launch: " + appName
    }
    function action(name) {
        if (name === "Apps" || name === "Files" || name === "Dev Suite") {
            root.toggleApps()
        } else if (name === "Matrix") {
            root.openMatrix()
        } else if (name === "Settings" || name === "Appearance") {
            root.showSettings = !root.showSettings
        } else if (name === "Home") {
            root.showAppList = false
            root.showSettings = false
            root.notice = "NEO Workspace • Home"
        } else {
            root.notice = name + " is a design preview; service not connected"
        }
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
        enabled: root.showAppList || root.showSettings || root.showMatrix || root.dockExpanded
        onActivated: {
            if (root.showMatrix) root.showMatrix = false
            else if (root.showSettings) root.showSettings = false
            else if (root.showAppList) root.showAppList = false
            else root.dockExpanded = false
        }
    }

    // Native decorative fallback: uses no network, no inaccessible image URLs.
    // A user-selected local image is rendered over it when configured.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#050d2b" }
            GradientStop { position: 0.50; color: "#102657" }
            GradientStop { position: 1; color: "#26143e" }
        }
    }
    Canvas {
        id: celestialSky
        anchors.fill: parent
        renderTarget: Canvas.Image
        onPaint: {
            const ctx = getContext("2d")
            const w = width, h = height
            ctx.clearRect(0, 0, w, h)
            // A luminous planetary horizon and restrained star field.
            let glow = ctx.createRadialGradient(w * 0.54, h * 0.33, 8, w * 0.54, h * 0.33, w * 0.40)
            glow.addColorStop(0, "rgba(53,143,252,0.35)")
            glow.addColorStop(0.5, "rgba(83,32,171,0.18)")
            glow.addColorStop(1, "rgba(0,0,0,0)")
            ctx.fillStyle = glow
            ctx.fillRect(0, 0, w, h)
            for (let i = 0; i < 125; ++i) {
                const xx = ((i * 977 + 91) % 1399) / 1399 * w
                const yy = ((i * 571 + 27) % 883) / 883 * h
                ctx.fillStyle = i % 4 ? "rgba(190,224,255,0.30)" : "rgba(118,219,255,0.70)"
                ctx.beginPath()
                ctx.arc(xx, yy, i % 7 === 0 ? 1.45 : 0.7, 0, 2 * Math.PI)
                ctx.fill()
            }
            const px = w * 0.52, py = h * 0.40, pr = Math.min(w, h) * 0.30
            let planet = ctx.createRadialGradient(px - pr * 0.28, py - pr * 0.37, 4, px, py, pr)
            planet.addColorStop(0, "#2b8dc9")
            planet.addColorStop(0.52, "#192d6b")
            planet.addColorStop(0.86, "#11143f")
            planet.addColorStop(1, "#090a26")
            ctx.fillStyle = planet
            ctx.beginPath()
            ctx.arc(px, py, pr, 0, 2 * Math.PI)
            ctx.fill()
            ctx.lineWidth = 4
            ctx.strokeStyle = "rgba(87,198,255,0.8)"
            ctx.stroke()
            ctx.lineWidth = 1.4
            ctx.strokeStyle = "rgba(211,105,255,0.55)"
            ctx.beginPath()
            ctx.ellipse(px, py + pr * 0.1, pr * 1.56, pr * 0.33, -0.22, 0, 2 * Math.PI)
            ctx.stroke()
            ctx.strokeStyle = "rgba(75,195,255,0.43)"
            ctx.beginPath()
            ctx.ellipse(px, py + pr * 0.1, pr * 1.76, pr * 0.38, -0.22, 0, 2 * Math.PI)
            ctx.stroke()
            const ground = ctx.createLinearGradient(0, h * 0.78, 0, h)
            ground.addColorStop(0, "rgba(9,22,52,0)")
            ground.addColorStop(1, "rgba(14,9,33,0.92)")
            ctx.fillStyle = ground
            ctx.fillRect(0, h * 0.72, w, h * 0.28)
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }
    Image {
        anchors.fill: parent
        source: backend.wallpaperUrl
        visible: backend.wallpaperUrl !== "" && status === Image.Ready
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }
    // User-adjustable contrast overlay: wallpapers stay legible beneath text and cards.
    Rectangle {
        anchors.fill: parent
        color: "#03091c"
        opacity: backend.wallpaperDim
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#58030d20" }
            GradientStop { position: 0.46; color: "#10010a1c" }
            GradientStop { position: 1; color: "#71050822" }
        }
    }

    // The top chrome mirrors the reference without spoofing OS battery/network status.
    Rectangle {
        id: topBar
        z: 10
        height: 62
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#e3081029"
        border.color: "#4d6ba6"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 20
            spacing: 10
            Text { text: "◇"; color: root.neon; font.pixelSize: 38; font.bold: true }
            Text { text: "NEO-OS"; color: "#f7fcff"; font.bold: true; font.pixelSize: 22 }
            Rectangle { width: 1; height: 24; color: "#58739e" }
            Text { text: "Desktop Preview"; color: "#aab9dc"; font.pixelSize: 11 }
            Item { Layout.preferredWidth: 14 }
            Repeater {
                model: 4
                delegate: Button {
                    required property int index
                    text: String(index + 1)
                    Layout.preferredWidth: 43
                    Layout.preferredHeight: 35
                    focusPolicy: Qt.StrongFocus
                    Accessible.name: "Workspace " + (index + 1)
                    background: Rectangle {
                        radius: 13
                        color: root.workspace === index + 1 ? "#70346586" : "#77101933"
                        border.width: root.workspace === index + 1 ? 2 : 1
                        border.color: root.workspace === index + 1 ? root.neon : "#43557d"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#f6fcff"
                        font.pixelSize: 15
                        font.bold: root.workspace === index + 1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        root.workspace = index + 1
                        root.notice = "Workspace " + (index + 1) + " selected (preview only)"
                    }
                }
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "⌕  Search apps"
                Layout.preferredWidth: 155
                Layout.preferredHeight: 35
                Accessible.name: "Search installed applications"
                onClicked: root.toggleApps()
                background: Rectangle {
                    radius: 16
                    color: "#b5102349"
                    border.color: root.neonSoft
                }
                contentItem: Text {
                    text: parent.text
                    color: "#dffaff"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            Text {
                text: Qt.formatDateTime(root.clockTime, "ddd, MMM d  hh:mm")
                color: "#dcecff"
                font.pixelSize: 12
            }
            Button {
                text: "⚙"
                Accessible.name: "Appearance settings"
                onClicked: root.action("Settings")
                background: Rectangle { radius: 12; color: "#7823324e"; border.color: "#506b91" }
            }
        }
    }

    // Glass-like vertical sidebar; items never pretend to be running services.
    Rectangle {
        id: sideRail
        z: 4
        x: 16
        y: 80
        width: 163
        height: Math.min(root.height - 184, 610)
        radius: 19
        color: "#c5091730"
        border.color: "#6672c8"
        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 5
            Repeater {
                model: [
                    { name: "Home", glyph: "⌂" },
                    { name: "Files", glyph: "▣" },
                    { name: "Dev Suite", glyph: "⌘" },
                    { name: "Matrix", glyph: ">_" },
                    { name: "Apps", glyph: "▦" },
                    { name: "AI Studio", glyph: "✦" },
                    { name: "NEO Market", glyph: "◇" },
                    { name: "Settings", glyph: "⚙" }
                ]
                delegate: Button {
                    required property var modelData
                    width: sideRail.width - 24
                    height: Math.min(50, (sideRail.height - 30) / 8)
                    text: modelData.glyph + "   " + modelData.name
                    Accessible.name: modelData.name
                    focusPolicy: Qt.StrongFocus
                    onClicked: root.action(modelData.name)
                    background: Rectangle {
                        radius: 13
                        color: parent.hovered || parent.activeFocus ? "#ad19466e" :
                               modelData.name === "Home" ? "#9a173760" : "#45121c3e"
                        border.width: parent.activeFocus || modelData.name === "Home" ? 2 : 1
                        border.color: parent.activeFocus ? "#ffd989" :
                                      modelData.name === "Home" ? root.neon : "#31416a"
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#dff9ff"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Column {
        x: sideRail.x + sideRail.width + 30
        y: 92
        spacing: 6
        Text {
            text: "NEO WORKSPACE"
            font.pixelSize: 27
            font.bold: true
            color: "#ffffff"
            style: Text.Outline
            styleColor: "#315c9e"
        }
        Text { text: "Build  ·  Learn  ·  Code  ·  Secure  ·  Deploy"; color: "#d1deff"; font.pixelSize: 14 }
        Rectangle { width: 230; height: 3; radius: 2; color: root.neon }
        Text {
            text: "Celestial desktop • Native preview running on your Linux host"
            color: "#c4d6f1"
            font.pixelSize: 11
        }
    }

    // Functional orbital launcher. Its populated apps come from the Linux host.
    Item {
        id: orbit
        z: 3
        width: Math.min(380, root.width * 0.33)
        height: width
        x: sideRail.x + sideRail.width +
           (root.width - sideRail.x - sideRail.width - rightPanels.width - 24 - width) / 2
        y: Math.max(216, (root.height - height) / 2 - 2)
        property real orbitRadius: root.dockExpanded ? width * 0.37 : width * 0.29
        Behavior on orbitRadius {
            enabled: !root.reducedMotion
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        Rectangle {
            anchors.centerIn: parent
            width: orbit.orbitRadius * 2 + 55
            height: width
            radius: width / 2
            color: "transparent"
            border.width: 10
            border.color: root.neon
            opacity: 0.12
        }
        Rectangle {
            anchors.centerIn: parent
            width: orbit.orbitRadius * 2 + 22
            height: width
            radius: width / 2
            color: "#34082350"
            border.width: 3
            border.color: root.neon
            opacity: 0.8
        }
        Rectangle {
            anchors.centerIn: parent
            width: orbit.orbitRadius * 2 - 35
            height: width
            radius: width / 2
            color: "#14152554"
            border.color: "#cb67fc"
            border.width: 2
        }
        Rectangle {
            id: dockCenter
            anchors.centerIn: parent
            width: Math.max(92, orbit.width * 0.27)
            height: width
            radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0; color: "#345eb3" }
                GradientStop { position: 0.48; color: "#263e8d" }
                GradientStop { position: 1; color: "#1b1850" }
            }
            border.width: 4
            border.color: dockButton.activeFocus ? "#f9d078" : "#b96bfa"
            Text {
                anchors.centerIn: parent
                text: "▦"
                font.pixelSize: 44
                color: "#a2faff"
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
                readonly property var info: backend.appById(modelData)
                readonly property int count: Math.max(1, backend.pinnedApps.length)
                readonly property real angle: -Math.PI / 2 + 2 * Math.PI * index / count
                readonly property int iconSize: Math.max(43, Math.min(66, orbit.width * 0.17))
                width: iconSize
                height: iconSize
                radius: width / 2
                x: orbit.width / 2 + Math.cos(angle) * orbit.orbitRadius - width / 2
                y: orbit.height / 2 + Math.sin(angle) * orbit.orbitRadius - height / 2
                color: "#d1112853"
                border.color: orbitMouse.containsMouse ? "#ffe7a0" : root.neon
                border.width: 2
                scale: root.dockExpanded ? 1 : 0.9
                Behavior on scale { enabled: !root.reducedMotion; NumberAnimation { duration: 200 } }
                Column {
                    anchors.centerIn: parent
                    spacing: 1
                    Image {
                        id: orbitIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 31; height: 31
                        source: "image://appicons/" + modelData
                        sourceSize.width: 31
                        sourceSize.height: 31
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        visible: orbitIcon.status !== Image.Ready
                        text: info.name ? info.name.slice(0, 1) : "?"
                        color: "#e5ffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: info.name || "App"
                        width: 61
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        color: "#e6f9ff"
                        font.pixelSize: 9
                    }
                }
                MouseArea {
                    id: orbitMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onEntered: if (!root.reducedMotion) root.dockExpanded = true
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            root.notice = backend.unpin(modelData) ? "Unpinned " + info.name : "Cannot unpin"
                        else root.openApp(modelData, info.name)
                    }
                }
            }
        }
    }

    // Informational preview panels use truthful labels and no invented metrics.
    Column {
        id: rightPanels
        z: 4
        width: Math.min(315, root.width * 0.26)
        x: root.width - width - 19
        y: 89
        spacing: 10
        Rectangle {
            width: parent.width
            height: 170
            radius: 18
            color: "#df0b1734"
            border.width: 1
            border.color: "#936bce"
            Column {
                anchors.fill: parent; anchors.margins: 15; spacing: 10
                Text { text: "✦  NEO AI ASSISTANT"; color: "#f4eaff"; font.pixelSize: 16; font.bold: true }
                Text { text: "Design preview • AI not connected"; color: "#a9c3ec"; font.pixelSize: 12 }
                Text { text: "Ask, build, learn, and automate"; color: "#ebf8ff"; font.pixelSize: 13 }
                Button {
                    width: parent.width; height: 39
                    text: "Explore AI Studio (preview)"
                    onClicked: root.action("AI Studio")
                    background: Rectangle { radius: 12; color: "#8b243a73"; border.color: root.neonSoft }
                    contentItem: Text { text: parent.text; color: "#e7f8ff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
        }
        Rectangle {
            width: parent.width; height: 132; radius: 17
            color: "#df0b1734"; border.color: "#567fc1"
            Column {
                anchors.fill: parent; anchors.margins: 14; spacing: 8
                Text { text: "⌁  SYSTEM STATUS"; color: "#e7faff"; font.bold: true; font.pixelSize: 15 }
                Text { text: "Current host: Ubuntu preview"; color: "#b8d2f0"; font.pixelSize: 12 }
                Text { text: "Live CPU / RAM telemetry: not connected"; color: "#bad0e5"; font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width }
                Rectangle { width: parent.width; height: 1; color: "#36618c" }
                Text { text: "No simulated system metrics"; color: root.neon; font.pixelSize: 11 }
            }
        }
        Rectangle {
            width: parent.width; height: 119; radius: 17
            color: "#df0b1734"; border.color: "#8062c1"
            Column {
                anchors.fill: parent; anchors.margins: 14; spacing: 7
                Text { text: "◇  NEO MARKET"; color: "#e7faff"; font.bold: true; font.pixelSize: 15 }
                Text { text: "Universal app platform — planned"; color: "#c2d2f2"; font.pixelSize: 11 }
                Button {
                    width: parent.width; height: 37
                    text: "Browse local installed apps"
                    onClicked: root.toggleApps()
                    background: Rectangle { radius: 11; color: "#64234274"; border.color: root.neonSoft }
                    contentItem: Text { text: parent.text; color: "#e7f8ff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
        }
        Rectangle {
            visible: root.height >= 760
            width: parent.width; height: 100; radius: 17
            color: "#df0b1734"; border.color: "#597dbe"
            Column {
                anchors.fill: parent; anchors.margins: 14; spacing: 8
                Text { text: "▣  DEVICES & SYNC"; color: "#e7faff"; font.bold: true; font.pixelSize: 15 }
                Text { text: "No devices connected through NEO-OS"; color: "#c2d2f2"; font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width }
                Text { text: "Service not implemented"; color: "#f3bde3"; font.pixelSize: 11 }
            }
        }
    }

    Rectangle {
        visible: root.height >= 760
        z: 5
        x: sideRail.x + sideRail.width + 18
        y: root.height - 143
        width: Math.min(370, root.width - rightPanels.width - 300)
        height: 62
        radius: 16
        color: "#d80c1737"
        border.color: "#5679aa"
        RowLayout {
            anchors.fill: parent
            anchors.margins: 9
            spacing: 6
            Repeater {
                model: [
                    {name: "Apps", glyph: "▦"},
                    {name: "Matrix", glyph: ">_"},
                    {name: "Settings", glyph: "⚙"}
                ]
                delegate: Button {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: modelData.glyph + " " + modelData.name
                    Accessible.name: modelData.name
                    onClicked: root.action(modelData.name)
                    background: Rectangle { radius: 10; color: "#a21b3763"; border.color: root.neonSoft }
                    contentItem: Text { text: parent.text; color: "#e7f8ff"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
        }
    }

    // A compact taskbar, inspired by the reference. Uses real pinned Linux apps.
    Rectangle {
        id: bottomDock
        z: 7
        height: 65
        width: Math.min(800, root.width - sideRail.width - rightPanels.width - 75)
        x: sideRail.x + sideRail.width +
           (root.width - sideRail.x - sideRail.width - rightPanels.width - 24 - width) / 2
        y: root.height - 75
        radius: 30
        color: "#e0081730"
        border.width: 2
        border.color: root.neon
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.width: 4
            border.color: root.neonSoft
            opacity: 0.16
            z: -1
        }
        Row {
            anchors.centerIn: parent
            spacing: 15
            Button {
                width: 48; height: 48
                text: "▦"
                Accessible.name: "Open installed applications"
                onClicked: root.toggleApps()
                background: Rectangle { radius: 25; color: "#31458d"; border.color: root.neon; border.width: 2 }
                contentItem: Text { text: parent.text; color: "#a6faff"; font.pixelSize: 26; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Repeater {
                model: backend.pinnedApps
                delegate: Button {
                    required property string modelData
                    width: 45; height: 46
                    readonly property var appInfo: backend.appById(modelData)
                    Accessible.name: "Launch " + appInfo.name
                    onClicked: root.openApp(modelData, appInfo.name)
                    background: Rectangle { radius: 14; color: parent.hovered ? "#87415d93" : "#491d2c51"; border.color: parent.activeFocus ? "#f7dc80" : "#5579a5" }
                    contentItem: Image {
                        source: "image://appicons/" + modelData
                        sourceSize.width: 30; sourceSize.height: 30
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }
            Button {
                width: 47; height: 46
                text: ">_"
                Accessible.name: "Open Matrix CLI"
                onClicked: root.openMatrix()
                background: Rectangle { radius: 14; color: "#64355a83"; border.color: root.neonSoft }
                contentItem: Text { text: parent.text; color: "#d8ffff"; font.bold: true; font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }
    }

    Rectangle {
        visible: root.height >= 760
        z: 8
        x: 19
        y: root.height - 73
        width: 275
        height: 53
        radius: 16
        color: "#d50a1734"
        border.color: "#4b8dba"
        Text {
            anchors.fill: parent
            anchors.margins: 11
            text: root.notice
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            color: "#d7eaff"
            font.pixelSize: 11
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Installed application browser: real .desktop entries from Ubuntu.
    Rectangle {
        id: appPanel
        visible: root.showAppList
        z: 30
        x: sideRail.x + sideRail.width + 26
        y: Math.min(root.height * 0.24, 185)
        width: Math.min(495, root.width - 390)
        height: Math.min(460, root.height - 260)
        radius: 19
        color: "#f00c1730"
        border.width: 2
        border.color: root.neon
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            RowLayout {
                Text { text: "▦ Installed applications"; color: "#f2faff"; font.pixelSize: 18; font.bold: true }
                Item { Layout.fillWidth: true }
                Button { text: "Close"; onClicked: root.showAppList = false }
            }
            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search installed apps...  Ctrl+K"
                onTextChanged: root.searchText = text.toLowerCase()
                Accessible.name: "Search installed applications"
            }
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: backend.availableApps
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: appList.width
                    height: modelData.name.toLowerCase().indexOf(root.searchText) >= 0 ? 49 : 0
                    visible: height > 0
                    radius: 8
                    color: index % 2 ? "#34204a6c" : "#44254367"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 7
                        Image {
                            source: "image://appicons/" + modelData.id
                            sourceSize.width: 27; sourceSize.height: 27
                            Layout.preferredWidth: 27; Layout.preferredHeight: 27
                        }
                        Text { text: modelData.name; color: "#ebfaff"; elide: Text.ElideRight; Layout.fillWidth: true }
                        Button { text: "Open"; onClicked: root.openApp(modelData.id, modelData.name) }
                        Button {
                            text: "Pin"
                            onClicked: root.notice = backend.pin(modelData.id)
                                ? "Pinned " + modelData.name : modelData.name + " already pinned"
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: appearancePanel
        visible: root.showSettings
        z: 31
        width: Math.min(520, root.width - 50)
        height: Math.min(520, root.height - 80)
        anchors.centerIn: parent
        radius: 18
        color: "#f20a1730"
        border.width: 2
        border.color: root.neon
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10
            Text { text: "⚙  APPEARANCE"; color: "#ffffff"; font.pixelSize: 20; font.bold: true }
            Text {
                text: "Use a local wallpaper image (JPG, PNG, WebP). No files are uploaded."
                color: "#bad5ec"
                font.pixelSize: 12
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            TextField {
                id: wallpaperInput
                Layout.fillWidth: true
                placeholderText: "/home/you/Pictures/neo-wallpaper.webp"
                text: decodeURIComponent(backend.wallpaperUrl.toString().replace("file://", ""))
                Accessible.name: "Absolute local wallpaper file path"
            }
            RowLayout {
                Button {
                    text: "Apply wallpaper"
                    onClicked: root.notice = backend.setWallpaperPath(wallpaperInput.text.trim())
                        ? "Wallpaper saved" : "Image not found or unsupported"
                }
                Button {
                    text: "Use celestial fallback"
                    onClicked: {
                        backend.setWallpaperPath("")
                        wallpaperInput.text = ""
                        root.notice = "Default NEO celestial wallpaper restored"
                    }
                }
            }
            CheckBox {
                text: "Reduce interface animations"
                checked: root.reducedMotion
                onToggled: root.reducedMotion = checked
                Accessible.name: "Reduce interface animations"
            }
            Text { text: "Wallpaper gallery — installed locally"; color: "#ecfaff"; font.bold: true }
            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                contentWidth: galleryRow.width
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                Row {
                    id: galleryRow
                    spacing: 10
                    Repeater {
                        model: backend.wallpaperThemes
                        delegate: Button {
                            required property var modelData
                            width: 132
                            height: 104
                            Accessible.name: "Select wallpaper " + modelData.name
                            onClicked: {
                                root.notice = backend.setWallpaperPath(modelData.url)
                                    ? "Wallpaper selected: " + modelData.name
                                    : "Wallpaper unavailable"
                            }
                            background: Rectangle {
                                radius: 12
                                color: "#251b3d"
                                border.width: backend.wallpaperUrl === modelData.url ? 3 : 1
                                border.color: backend.wallpaperUrl === modelData.url ? root.neon : "#516aa0"
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: modelData.url
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 4
                                    height: 27
                                    radius: 5
                                    color: "#df071327"
                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        text: modelData.name
                                        color: "#fff"
                                        elide: Text.ElideRight
                                        font.pixelSize: 10
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Wallpaper contrast"; color: "#ecfaff" }
                Slider {
                    id: dimSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 0.72
                    stepSize: 0.02
                    value: backend.wallpaperDim
                    Accessible.name: "Wallpaper dim overlay"
                    onMoved: backend.setWallpaperDim(value)
                }
                Text { text: Math.round(backend.wallpaperDim * 100) + "%"; color: "#c8eaff" }
            }
            Text { text: "Accent theme"; color: "#ecfaff"; font.bold: true }
            RowLayout {
                Button { text: "◈ Cyan"; onClicked: backend.setAccentTheme("cyan") }
                Button { text: "✦ Violet"; onClicked: backend.setAccentTheme("violet") }
                Item { Layout.fillWidth: true }
                Button { text: "Close"; onClicked: root.showSettings = false }
            }
            Text {
                text: "Preview only: live AI, weather, phone sync, cross-platform store and desktop compositor are not implemented."
                color: "#c5b6d9"
                font.pixelSize: 11
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }
    }

    MatrixTerminal {
        id: matrixPanel
        visible: root.showMatrix
        z: 40
        anchors.centerIn: parent
        width: Math.min(760, root.width - 180)
        height: Math.min(470, root.height - 150)
        onCloseRequested: root.showMatrix = false
    }
}
