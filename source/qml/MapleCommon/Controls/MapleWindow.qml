import QtQuick
import QtQuick.Controls

Item {
    id: root
    property var oriWindow: null
    property alias title: titleBar.text
    property alias logo: titleBar.logoSource
    property alias titleBarColor: titleBar.color
    property alias bodyColor: body.color
    anchors.fill: parent
    MapleTitleBar {
        id: titleBar
        height: 30
        width: parent.width
        mapleWindow: oriWindow
        z:100
    }   
    Rectangle {
        id: body
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
    MapleBorderDrager {
        control: oriWindow
        minWidth: minimumWidth
        minHeight: minimumHeight
    }

    Component.onCompleted: {
        var childList = root.children 
     
        var body = childList[1]
        for (var i = 0; i < childList.length; i++) {
            if (i > 2) {
                body.children.push(childList[i])
                i--
            }
            
            
        }

    }
}

