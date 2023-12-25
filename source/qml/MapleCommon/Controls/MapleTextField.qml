import QtQuick
import QtQuick.Controls

Item {
    property var showText
    property var itemHeight: 20
    property var fontSize: 12
    height: itemHeight
    width: parent.width
    property alias curItemValue: textField.text
    property alias curDisplayValue: textField.text
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

        TextField {
            id: textField
            leftPadding: 10
            font.pixelSize: fontSize
            color:"white"
            anchors.left: content.right
            height: itemHeight
            width: root.width - 95
            placeholderText: ""
            // echoMode: TextInput.Password
            // font.bold: true

            // 自定义背景色和圆角
            background: Rectangle {
                color: textField.focus ? "#525252" : "#404040"
                radius: 2
            }

            // // 自定义文本颜色
            // style: TextFieldStyle {
            //     text: Text {
            //         color: textField.focus ? "#333333" : "#666666"
            //     }
            // }

            onTextEdited: {
                valueChanged()
            }
        }
    }
    
}
