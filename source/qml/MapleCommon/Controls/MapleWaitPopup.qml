import QtQuick
import QtQuick.Controls

Popup {
    property alias text: ctx.text
    
    modal: true 
    Rectangle {
        color: "#343434"

        radius: 5
        anchors.fill: parent

        Text {
            id: ctx
            color: "white"
            font.pixelSize: 14
            anchors.centerIn: parent
        }

    }
}