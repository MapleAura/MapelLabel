import QtQuick
import QtQuick.Controls

Item {
    id: root
    property var mouseCursorShape : null
    property alias source: cursor.source
    property alias rotation: cursor.rotation
    property alias containsMouse: mouseArea.containsMouse
    signal posChanged(int xOffset, int yOffset)
    signal clickChanged()
    property alias cursorHeight: cursor.height
    property alias cursorWidth: cursor.width


    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        property int lastX: 0
        property int lastY: 0

        Image {
            width: 25
            height: 25 
            id: cursor
            source: ""
            mipmap: true
            visible: mouseArea.containsMouse | mouseArea.pressed
        }

        onContainsMouseChanged: {

            if (containsMouse) {
                if (mouseCursorShape !== null) {
                    cursorShape = mouseCursorShape;
                } else {
                    cursorShape = Qt.BlankCursor
                }
                
            } else {
                if (mouseCursorShape !== null) {
                    cursorShape = mouseCursorShape
                } else {
                    cursorShape = Qt.BlankCursor
                }

            }
        }


        onPressedChanged: {
            if (containsPress) {
                lastX = mouseX;
                lastY = mouseY;
            }
        }
        onPositionChanged: {

            if (pressed) {
                posChanged(mouseX - lastX, mouseY - lastY)
            }
            cursor.x = mouseX - 0.5 * cursor.width
            cursor.y = mouseY - 0.5 * cursor.height

        }

        onClicked: { clickChanged() }

    }
}