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
            brightness: 2.0
            color: "#90dfff"
        }
        PointLight {
            x: -225; y: 170; z: 275
            brightness: 95
            color: "#6dddff"
        }
        PointLight {
            x: 240; y: -95; z: 175
            brightness: 85
            color: scene.violet ? "#ff4ff1" : "#d47aff"
        }
        Node {
            id: rotatingSphere
            // Keep a lit opaque core beneath a restrained translucent shell.
            // Highly metallic, under-lit layers previously rendered nearly black.
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(3.78, 3.78, 3.78)
                materials: PrincipledMaterial {
                    baseColor: scene.violet ? "#6545af" : "#327ac8"
                    metalness: 0.14
                    roughness: 0.34
                    specularAmount: 0.95
                    emissiveFactor: Qt.vector3d(0.035, 0.095, 0.17)
                }
            }
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(3.9, 3.9, 3.9)
                materials: PrincipledMaterial {
                    baseColor: scene.violet ? "#345eb9f8" : "#304dcaff"
                    metalness: 0.06
                    roughness: 0.11
                    specularAmount: 1.0
                    alphaMode: PrincipledMaterial.Blend
                    depthDrawMode: Material.OpaqueOnlyDepthDraw
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
                    baseColor: "#21b9ef"
                    metalness: 0.08
                    roughness: 0.31
                    emissiveFactor: Qt.vector3d(0.05, 0.48, 0.72)
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
                    baseColor: scene.violet ? "#bd61eb" : "#33d8ef"
                    metalness: 0.05
                    roughness: 0.45
                    emissiveFactor: scene.violet
                        ? Qt.vector3d(0.55, 0.13, 0.80)
                        : Qt.vector3d(0.05, 0.64, 0.80)
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
