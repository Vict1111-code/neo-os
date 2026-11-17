import QtQuick
import QtQuick3D

// Experimental real 3D sphere geometry. Works inside the Ubuntu preview,
// independent of the future LFS/compositor work. 2.5D fallback lives in Main.qml.
Item {
    id: scene
    property bool violet: false
    property bool reducedMotion: false

    View3D {
        anchors.fill: parent
        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.Medium
        }
        PerspectiveCamera {
            id: camera
            z: 680
            fieldOfView: 45
        }
        DirectionalLight {
            eulerRotation: Qt.vector3d(-40, -34, 0)
            brightness: 1.15
            color: "#90dfff"
        }
        PointLight {
            x: -225; y: 170; z: 275
            brightness: 32
            color: "#6dddff"
        }
        PointLight {
            x: 240; y: -95; z: 175
            brightness: 20
            color: scene.violet ? "#ff4ff1" : "#d47aff"
        }
        Node {
            id: rotatingSphere
            // A deep, restrained core carries dimensional shading while the outer
            // layer is faint and specular. Bright core illumination previously
            // flattened the entire sphere into an opaque pastel disc.
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(3.78, 3.78, 3.78)
                materials: PrincipledMaterial {
                    baseColor: scene.violet ? "#201239" : "#0d2141"
                    metalness: 0.17
                    roughness: 0.25
                    specularAmount: 0.95
                    emissiveFactor: Qt.vector3d(0.008, 0.022, 0.046)
                }
            }
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(3.9, 3.9, 3.9)
                materials: PrincipledMaterial {
                    baseColor: scene.violet ? "#1e8b6dc8" : "#207dbce9"
                    metalness: 0.11
                    roughness: 0.08
                    specularAmount: 1.0
                    alphaMode: PrincipledMaterial.Blend
                }
            }
            NumberAnimation on eulerRotation.y {
                running: !scene.reducedMotion
                from: -18
                to: 342
                duration: 48000
                loops: Animation.Infinite
            }
        }

        // Built-in cylinders use 100-unit mesh dimensions. The horizontal
        // scales create discs/rims; materials are bright enough without an IBL probe.
        Node {
            id: podium
            y: -223
            Model {
                source: "#Cylinder"
                scale: Qt.vector3d(5.25, 0.25, 2.15)
                materials: PrincipledMaterial {
                    baseColor: "#273b75"
                    metalness: 0.23
                    roughness: 0.28
                    emissiveFactor: Qt.vector3d(0.02, 0.035, 0.085)
                }
            }
            Model {
                y: 20
                source: "#Cylinder"
                scale: Qt.vector3d(4.95, 0.085, 1.98)
                materials: PrincipledMaterial {
                    baseColor: "#164969"
                    metalness: 0.08
                    roughness: 0.31
                    emissiveFactor: Qt.vector3d(0.015, 0.19, 0.30)
                }
            }
            Model {
                y: 29
                source: "#Cylinder"
                scale: Qt.vector3d(4.68, 0.10, 1.88)
                materials: PrincipledMaterial {
                    baseColor: "#101e50"
                    metalness: 0.27
                    roughness: 0.23
                    emissiveFactor: Qt.vector3d(0.025, 0.04, 0.11)
                }
            }
            Model {
                y: 35
                source: "#Cylinder"
                scale: Qt.vector3d(3.78, 0.028, 1.48)
                materials: PrincipledMaterial {
                    baseColor: scene.violet ? "#743e9a" : "#177c9b"
                    metalness: 0.05
                    roughness: 0.45
                    emissiveFactor: scene.violet
                        ? Qt.vector3d(0.19, 0.045, 0.32)
                        : Qt.vector3d(0.015, 0.26, 0.37)
                }
            }
            Model {
                y: 39
                source: "#Cylinder"
                scale: Qt.vector3d(3.52, 0.04, 1.32)
                materials: PrincipledMaterial {
                    baseColor: "#0c2147"
                    metalness: 0.15
                    roughness: 0.36
                }
            }
        }
    }

    // Low-opacity rim glints sell the silhouette without turning the opaque
    // core into a bright pastel disc. These are a deliberate 2D approximation,
    // NOT real environment reflection or optical refraction.
    Canvas {
        id: glassRim
        anchors.fill: parent
        renderTarget: Canvas.Image
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onVioletChanged: requestPaint()
        property bool violet: scene.violet
        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            const cx = width / 2, cy = height / 2
            const r = Math.min(width, height) * 0.355
            ctx.lineCap = "round"
            for (let i = 0; i < 3; i++) {
                ctx.beginPath()
                ctx.arc(cx, cy, r + i * 1.9, 3.35, 5.27)
                ctx.strokeStyle = i === 0 ? "rgba(196,251,255,0.55)" :
                                  "rgba(58,177,255,0.13)"
                ctx.lineWidth = i === 0 ? 2.6 : 4.5
                ctx.stroke()
            }
            ctx.beginPath()
            ctx.arc(cx, cy, r - 1.6, 0.26, 1.75)
            ctx.strokeStyle = violet ? "rgba(253,129,251,0.36)" :
                                       "rgba(70,226,252,0.35)"
            ctx.lineWidth = 4
            ctx.stroke()
            const glintX = cx - r * 0.62, glintY = cy - r * 0.78
            const glow = ctx.createRadialGradient(glintX, glintY, 0,
                                                   glintX, glintY, r * 0.27)
            glow.addColorStop(0, "rgba(200,247,255,0.28)")
            glow.addColorStop(1, "rgba(115,205,255,0)")
            ctx.fillStyle = glow
            ctx.beginPath()
            ctx.arc(glintX, glintY, r * 0.27, 0, 2 * Math.PI)
            ctx.fill()
        }
    }

    // 2D emissive paths over the true 3D sphere; ray-traced refraction and
    // depth-correct ring occlusion are not implemented in this first spike.
    Canvas {
        id: orbitalTrails
        anchors.fill: parent
        renderTarget: Canvas.Image
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onVioletChanged: requestPaint()
        property bool violet: scene.violet
        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            const cx = width / 2, cy = height / 2
            const rx = Math.min(width, height) * 0.52
            ctx.save()
            ctx.translate(cx, cy + 5)
            ctx.rotate(-0.18)
            ctx.scale(1, 0.32)
            for (let i = 0; i < 4; i++) {
                ctx.beginPath()
                ctx.arc(0, 0, rx - i * 9, 0, 2 * Math.PI)
                ctx.lineWidth = i === 0 ? 9 : i === 1 ? 5 : 2.6
                ctx.strokeStyle = i % 2 ?
                                  (violet ? "rgba(252,120,255,0.68)" : "rgba(197,102,248,0.64)") :
                                  "rgba(73,217,255,0.70)"
                ctx.stroke()
            }
            ctx.restore()
        }
    }
}
