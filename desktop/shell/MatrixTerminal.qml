import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: panel
    signal closeRequested()
    radius: 14
    color: "#07140f"
    border.color: "#54bd86"
    border.width: 2
    onVisibleChanged: if (visible) commandEntry.forceActiveFocus()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "MATRIX CLI  •  Linux PTY preview"
                color: "#80ffac"
                font.pixelSize: 17
                font.bold: true
                Layout.fillWidth: true
            }
            Button {
                text: "External terminal"
                onClicked: backend.launchMatrix()
                Accessible.name: "Launch fallback external terminal"
            }
            Button {
                text: "Close"
                onClicked: panel.closeRequested()
                Accessible.name: "Close Matrix panel"
            }
        }
        Text {
            text: "Real /bin/bash shell as current user. Basic line-oriented terminal, not a full VT emulator."
            color: "#a6c4b0"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            font.pixelSize: 12
        }
        ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            TextArea {
                id: outputArea
                text: matrixPty.output
                readOnly: true
                wrapMode: TextEdit.WrapAnywhere
                selectByMouse: true
                color: "#79f4a5"
                selectionColor: "#397759"
                font.family: "monospace"
                font.pixelSize: 13
                background: Rectangle { color: "#041009"; radius: 6 }
                Accessible.name: "PTY shell output"
                onTextChanged: cursorPosition = length
            }
        }
        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: commandEntry
                Layout.fillWidth: true
                color: "#b5ffd0"
                placeholderText: matrixPty.running ? "Type a shell command and press Enter" : "Start the shell to continue"
                enabled: matrixPty.running
                font.family: "monospace"
                font.pixelSize: 14
                selectByMouse: true
                Accessible.name: "Matrix shell command input"
                onAccepted: {
                    if (matrixPty.sendLine(text)) text = ""
                }
            }
            Button {
                text: "Send"
                enabled: matrixPty.running
                onClicked: {
                    if (matrixPty.sendLine(commandEntry.text)) commandEntry.text = ""
                    commandEntry.forceActiveFocus()
                }
            }
            Button {
                text: "Ctrl+C"
                enabled: matrixPty.running
                onClicked: {
                    matrixPty.interrupt()
                    commandEntry.forceActiveFocus()
                }
            }
            Button {
                text: matrixPty.running ? "Stop" : "Start"
                onClicked: {
                    if (matrixPty.running) matrixPty.stop()
                    else matrixPty.start()
                    commandEntry.forceActiveFocus()
                }
            }
        }
        Text {
            text: "PTY prototype: full-screen editors, cursor movement, complex ANSI sequences, and per-keystroke interaction are not supported yet."
            color: "#8caa96"
            font.pixelSize: 11
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }
}
