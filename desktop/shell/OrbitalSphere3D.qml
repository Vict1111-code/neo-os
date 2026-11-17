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
            brightness: 1.6
            color: "#90dfff"
        }
        PointLight {
            x: -225; y: 170; z: 275
            brightness: 55
            color: "#6dddff"
        }
        PointLight {
            x: 240; y: -95; z: 175
            brightness: 42
            color: scene.violet ? "#ff4ff1" : "#d47aff"
        }
        Node {
            id: rotatingSphere
            // A sphere with real 3D mesh normals and material-based highlights.
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(3.9, 3.9, 3.9)
                materials: PrincipledMaterial {
                    baseColor: "#8b204d9a"
                    metalness: 0.27
                    roughness: 0.13
                    specularAmount: 1.0
                    alphaMode: PrincipledMaterial.Blend
                }
            }
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(3.78, 3.78, 3.78)
                materials: PrincipledMaterial {
                    baseColor: "#bf0d205b"
                    metalness: 0.65
                    roughness: 0.22
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

        // Physically positioned segmented cylindrical pedestal geometry.
        Node {
            y: -223
            Model {
                source: "#Cylinder"
                scale: Qt.vector3d(5.3, 0.35, 1.9)
                materials: PrincipledMaterial {
                    baseColor: "#10234e"
                    metalness: 0.75
                    roughness: 0.22
                }
            }
            Model {
                y: 18
                source: "#Cylinder"
                scale: Qt.vector3d(4.65, 0.12, 1.65)
                materials: PrincipledMaterial {
                    baseColor: "#25628c"
                    metalness: 0.86
                    roughness: 0.17
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
