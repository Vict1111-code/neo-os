import QtQuick

// A real image-backed Qt launcher icon remains above this glass-painted sphere.
Item {
    id: sphere
    property string iconUrl: ""
    property string label: ""
    property bool focused: false
    property bool hovered: false
    property bool pressed: false
    property bool reducedMotion: false
    property color neon: "#4ce8ff"

    scale: pressed ? 0.95 : hovered || focused ? 1.08 : 1
    Behavior on scale {
        enabled: !sphere.reducedMotion
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Canvas {
        id: glass
        anchors.fill: parent
        renderTarget: Canvas.Image
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            const r = Math.min(width, height) / 2 - 3
            const cx = width / 2
            const cy = height / 2
            const grad = ctx.createRadialGradient(cx - r * 0.34, cy - r * 0.42, 2,
                                                   cx, cy, r * 1.25)
            grad.addColorStop(0, "#4468b0")
            grad.addColorStop(0.25, "#202c72")
            grad.addColorStop(0.72, "#10173f")
            grad.addColorStop(0.92, "#2a205d")
            grad.addColorStop(1, "#3657a2")
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.fillStyle = grad
            ctx.fill()
            ctx.strokeStyle = sphere.focused ? "#ffe299" :
                              sphere.hovered ? "#e3fcff" : sphere.neon
            ctx.lineWidth = sphere.focused ? 4 : 2.5
            ctx.stroke()

            const highlight = ctx.createLinearGradient(0, 0, 0, cy)
            highlight.addColorStop(0, "rgba(235,250,255,0.67)")
            highlight.addColorStop(1, "rgba(114,186,255,0.0)")
            ctx.beginPath()
            ctx.arc(cx, cy, r - 6, Math.PI * 1.12, Math.PI * 1.86)
            ctx.strokeStyle = highlight
            ctx.lineWidth = Math.max(3, r * 0.10)
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(cx, cy, r - 7, Math.PI * 0.19, Math.PI * 0.80)
            ctx.strokeStyle = "rgba(217,79,249,0.33)"
            ctx.lineWidth = 3
            ctx.stroke()
        }
    }
    Column {
        anchors.centerIn: parent
        spacing: 2
        Image {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(24, sphere.width * 0.44)
            height: width
            source: sphere.iconUrl
            sourceSize.width: Math.ceil(width)
            sourceSize.height: Math.ceil(height)
            fillMode: Image.PreserveAspectFit
        }
        Text {
            visible: icon.status !== Image.Ready
            text: sphere.label ? sphere.label.slice(0, 1) : "?"
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ecfcff"
            font.bold: true
        }
        Text {
            text: sphere.label
            width: sphere.width - 5
            color: "white"
            font.pixelSize: sphere.width >= 75 ? 11 : 9
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            style: Text.Outline
            styleColor: "#0a1231"
        }
    }
}
