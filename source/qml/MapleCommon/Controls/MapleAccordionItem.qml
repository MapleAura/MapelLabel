import QtQuick
import QtQuick.Controls

Item {
    id: root  
    property bool activated : false
    property var controller: null
    property int itemHeight : 20
    property alias text: titleText.text
    property bool sMode: true
    implicitHeight: title.height + container.implicitHeight          
    width: parent.width
    Rectangle {
        id : title
        width: parent.width
        height: itemHeight
        // anchors.topMargin: 1
        color: "#222222"
        Text {
            id: titleText
            anchors.fill: parent
            anchors.leftMargin: 20
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            color: "White Smoke"
        }
        Text {
            anchors{
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                margins: 20
            }
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            text: "^"
            color: "White Smoke"
            rotation: activated ? "180" : 0
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                activated = !activated
                if (controller.curItem !== root) {
                    controller.curItem = root
                }
                
            }
        }
    }

    onActivatedChanged: {
        if (!sMode) {
            if (activated) {
                controller.activatedNum++
            } else {
                controller.activatedNum--
            }
        }
    }

    Rectangle {
        id: container
        anchors.top: title.bottom
        width : parent.width
        color: "transparent"
        implicitHeight:  activated ? (controller.height - controller.itemNum * itemHeight) / controller.activatedNum : 0 // 中间加了spaceing造成的
        
        Behavior on implicitHeight {
            PropertyAnimation { duration: 150 }
        }
        clip: true

        
    }

    Component.onCompleted: {
        var childList = root.children
        var itemNum = childList.length
        if (itemNum > 3) {
            console.log("error, accordionItem just have one element.")
            return 
        } else if (itemNum == 3) {
            container.children.push(childList[2])
            var itemNum = childList.length
        }else{

        }
        
    }

    
}