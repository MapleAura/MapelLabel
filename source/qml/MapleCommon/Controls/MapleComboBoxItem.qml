import QtQuick 
import QtQuick.Controls 

Item {
    id: root
    property var itemHeight: 20
    property var fontSize: 12
    height: itemHeight
    width: parent.width
    property var showText
    property var showModel
    property var count 
    property alias curItemValue: comboBox.currentText
    property alias curDisplayValue: comboBox.displayText 
    signal valueChanged()
    anchors.margins: 2
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        Text {
            id: content
            color: "White Smoke"
            leftPadding: 8
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            text: showText + ":\t"
            font.pixelSize: fontSize
        }
        
        ComboBox {
            id: comboBox
            anchors.left: content.right
            height: itemHeight
            width: root.width - 95
            delegate: ItemDelegate {
                width: parent.width
                height: itemHeight
                Rectangle {
                    anchors.fill: parent
                    color: "#404040"
                }
                contentItem: Text {
                    text: modelData
                    color:"white"
                    font.pixelSize: fontSize
                    verticalAlignment: Text.AlignVCenter
                }
                
            }
            contentItem: Text {
                text: comboBox.displayText
                color:"white"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
                font.pixelSize: fontSize
            }
            model: showModel
            background: Rectangle {
                width: parent.width
                height: parent.height
                color: "#404040"
                radius: 2
            }

            popup: Popup {   
                y: root.height
                width: root.width - 95
                // padding:1
                implicitHeight: itemHeight * count + 12
                contentItem: ListView {
                    clip: true
                    
                    implicitHeight: parent.height
                    model: comboBox.popup.visible? comboBox.delegateModel: null
                }
                background: Rectangle {
                    color: "#404040"
                    // radius: 2
              }
            }

            onCurrentTextChanged: {
                valueChanged()
            }


        }
    }
}