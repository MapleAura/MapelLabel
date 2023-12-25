import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias source: icon.source
    property alias text: button.text

    signal clickChanged()

    Image {
        id: icon
        width: root.width
        height: root.height
        fillMode: Image.PreserveAspectFit
        clip: true
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: 10
    }

    Text {
        id: button
        anchors.top: icon.bottom
        anchors.topMargin: 1
        anchors.horizontalCenter: icon.horizontalCenter
        anchors.bottom: icon.bottom
        anchors.bottomMargin: 5
        color:"#BBBBBB"
        font.bold: true
        font.pointSize: 8
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        //接受左键和右键输入
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            clickChanged()
        }
    }
}
