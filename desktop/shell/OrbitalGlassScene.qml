import QtQuick

// Layered 2.5D rendering behind real controls. No baked-in app labels/icons.
// Kept separate from application interactions so visual fidelity can improve
// independently without breaking accessibility or Linux app launches.
Canvas {
    id: scene
    property bool violet: false
    renderTarget: Canvas.Image
    onVioletChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    function ellipse(ctx, x, y, rx, ry, fill, stroke, lineWidth) {
        ctx.save()
        ctx.translate(x, y)
        ctx.scale(1, ry / rx)
        ctx.beginPath()
        ctx.arc(0, 0, rx, 0, Math.PI * 2)
        if (fill) { ctx.fillStyle = fill; ctx.fill() }
        if (stroke) {
            ctx.strokeStyle = stroke
            ctx.lineWidth = lineWidth || 1
            ctx.stroke()
        }
        ctx.restore()
    }
    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)
        if (width <= 0 || height <= 0) return
        ctx.save()
        ctx.scale(width / 600, height / 600)
        const cyan = "#48eaff", pink = violet ? "#ff70f5" : "#d77cff"

        // Grounded, illuminated metallic platform: multiple nested elliptical rims.
        const base = ctx.createLinearGradient(0, 490, 0, 555)
        base.addColorStop(0, "#0a214e")
        base.addColorStop(0.38, "#172a5d")
        base.addColorStop(0.67, "#050d29")
        base.addColorStop(1, "#0b0820")
        ellipse(ctx, 300, 514, 270, 53, base, "#8a8fe5", 3)
        ellipse(ctx, 300, 519, 247, 34, "#081332", "#ffaf46", 4)
        ellipse(ctx, 300, 512, 235, 31, "#071333", cyan, 3)
        ellipse(ctx, 300, 501, 185, 22, "#0c2450", "#a16bff", 3)
        ellipse(ctx, 300, 493, 148, 16, "#03264c", "#5deaff", 3)
        ctx.fillStyle = "#ff922a"
        ctx.fillRect(77, 525, 92, 8)
        ctx.fillRect(424, 525, 92, 8)
        ctx.fillStyle = "#3cf4ff"
        ctx.fillRect(268, 534, 64, 9)

        // Outer glow behind the refractive-looking glass sphere.
        let halo = ctx.createRadialGradient(294, 286, 130, 300, 289, 275)
        halo.addColorStop(0, "rgba(37,183,255,0)")
        halo.addColorStop(0.65, "rgba(65,124,253,0.03)")
        halo.addColorStop(0.78, "rgba(90,88,255,0.24)")
        halo.addColorStop(0.88, "rgba(126,47,232,0.11)")
        halo.addColorStop(1, "rgba(0,0,0,0)")
        ctx.fillStyle = halo
        ctx.beginPath()
        ctx.arc(300, 287, 275, 0, Math.PI * 2)
        ctx.fill()

        // Glass sphere volume: deep core, off-axis light, cool lower refraction.
        let sphere = ctx.createRadialGradient(221, 166, 12, 303, 301, 214)
        sphere.addColorStop(0, "rgba(53,130,216,0.84)")
        sphere.addColorStop(0.22, "rgba(19,53,125,0.85)")
        sphere.addColorStop(0.62, "rgba(12,22,82,0.94)")
        sphere.addColorStop(0.84, "rgba(12,16,63,0.95)")
        sphere.addColorStop(0.95, "rgba(42,44,118,0.94)")
        sphere.addColorStop(1, "rgba(83,166,242,0.81)")
        ctx.beginPath()
        ctx.arc(300, 286, 203, 0, Math.PI * 2)
        ctx.fillStyle = sphere
        ctx.fill()

        // Subtle projected curvature and liquid-glass streaks.
        for (let i = 0; i < 8; i++) {
            ctx.beginPath()
            ctx.arc(300, 286, 161 + i * 4, 3.67, 5.79)
            ctx.lineWidth = i % 2 ? 1 : 2.2
            ctx.strokeStyle = i % 2 ? "rgba(181,122,255,0.10)" : "rgba(97,212,255,0.13)"
            ctx.stroke()
        }
        let lower = ctx.createLinearGradient(0, 387, 0, 490)
        lower.addColorStop(0, "rgba(32,54,143,0)")
        lower.addColorStop(0.85, "rgba(45,228,255,0.21)")
        lower.addColorStop(1, "rgba(39,192,255,0.02)")
        ctx.fillStyle = lower
        ctx.beginPath()
        ctx.arc(300, 286, 202, 0, Math.PI * 2)
        ctx.fill()
        ctx.strokeStyle = "rgba(102,221,255,0.94)"
        ctx.lineWidth = 3.2
        ctx.stroke()

        // Refracted rim highlights, localized specular segments.
        ctx.lineCap = "round"
        ctx.beginPath()
        ctx.arc(300, 286, 201, 3.46, 5.38)
        ctx.strokeStyle = "rgba(203,252,255,0.94)"
        ctx.lineWidth = 5
        ctx.stroke()
        ctx.beginPath()
        ctx.arc(300, 286, 200, 5.6, 7.2)
        ctx.strokeStyle = "rgba(199,79,255,0.70)"
        ctx.lineWidth = 3
        ctx.stroke()
        ctx.beginPath()
        ctx.arc(300, 286, 193, 0.43, 2.12)
        ctx.strokeStyle = "rgba(40,236,255,0.50)"
        ctx.lineWidth = 7
        ctx.stroke()

        // Curved orbit bands are placed in projected planes around the sphere.
        ctx.save()
        ctx.translate(300, 300)
        ctx.rotate(-0.20)
        ctx.scale(1, 0.36)
        for (let i = 0; i < 5; i++) {
            ctx.beginPath()
            ctx.arc(0, 0, 267 + i * 8, 0, Math.PI * 2)
            ctx.lineWidth = i === 0 ? 13 : i === 2 ? 5 : 2
            ctx.strokeStyle = i % 2 ? "rgba(217,93,255,0.49)" :
                              i === 0 ? "rgba(65,210,255,0.11)" : "rgba(78,214,255,0.72)"
            ctx.stroke()
        }
        ctx.restore()

        // Inner energy loop around the interactive hub.
        for (let i = 0; i < 6; i++) {
            ctx.beginPath()
            ctx.arc(300, 286, 78 + i * 4, 0, Math.PI * 2)
            ctx.strokeStyle = i % 2 ? "rgba(224,95,255,0.26)" : "rgba(65,216,255,0.24)"
            ctx.lineWidth = i === 0 ? 7 : 2
            ctx.stroke()
        }
        ctx.beginPath()
        ctx.arc(300, 286, 94, 0.12, 2.57)
        ctx.strokeStyle = cyan
        ctx.lineWidth = 4
        ctx.stroke()
        ctx.beginPath()
        ctx.arc(300, 286, 94, 3.20, 5.72)
        ctx.strokeStyle = pink
        ctx.lineWidth = 3
        ctx.stroke()

        // Small star-like glints placed at intersections of orbital curves.
        for (let i = 0; i < 7; i++) {
            const theta = i * 2.39
            const x = 300 + Math.cos(theta) * (93 + (i % 2) * 123)
            const y = 286 + Math.sin(theta) * (88 + (i % 2) * 105)
            ctx.strokeStyle = i % 2 ? pink : cyan
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.moveTo(x - 7, y)
            ctx.lineTo(x + 7, y)
            ctx.moveTo(x, y - 7)
            ctx.lineTo(x, y + 7)
            ctx.stroke()
        }
        ctx.restore()
    }
}
