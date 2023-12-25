import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root 
    property var controller: null
    property alias source: image.source
    property alias text: tipText.text
    property string menuType: ""
    property bool activated: false
    property real btnScale: 0.8
    property bool bounceBacked: false
    height: parent.width
    width: parent.width
    anchors.horizontalCenter: parent.horizontalCenter
    
    Rectangle {
        id: viewBtn
        width: parent.height * 0.7
        height: parent.height * 0.7
        radius: 8
        anchors.horizontalCenter: parent.horizontalCenter
        color: activated ? "#888888" :(mouseArea.entered ? (mouseArea.pressed ? "#4E4E4E" : "#666666") : "transparent")
        Image {
            id: image
            width: parent.height * btnScale
            height: parent.height * btnScale
            anchors.centerIn: parent
            // ColorOverlay {
            //     anchors.fill: parent
            //     color: "white"
            //     source: parent
            // }
            mipmap:true
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            property bool entered: false
            hoverEnabled: true
            onEntered: entered = true
            onExited: entered = false
            onClicked: {
                activated = true
                if (controller.curBtn !== root) {
                    controller.curBtn = root
                }
                if (bounceBacked) {
                    activated = false
                    controller.curBtn = null
                } 
            }

            ToolTip {
                id : tip
                visible: parent.entered
                background: Rectangle {
                    border.color: "#505050"
                    color: "#707070"
                    radius: 4
                }
                contentItem: Text{
                    id: tipText
                    font.pixelSize: 12
                    font.bold: false
                    color: "white"
                }
                delay: 1000
            }
        }
    }
}