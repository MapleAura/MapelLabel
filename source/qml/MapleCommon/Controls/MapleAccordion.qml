import QtQuick
import QtQuick.Controls


Item { 
    id: root
    property int itemNum: 0
    property var curItem: null
    property int activatedNum: 0
    property bool singleMode: true
    property alias color: shape.color
    
    Rectangle {
        id: shape
        anchors.fill: parent
    }

    Component.onCompleted: {
        var childList = root.children
        for (var i = 0; i < childList.length; i++) {
            var curChild = childList[i]
            if (curChild instanceof MapleAccordionItem) {
                curChild.sMode = singleMode
                curChild.controller = root
                shape.children.push(curChild)
                i--
                itemNum++
            }
        }
        for (var i = 1; i < shape.children.length; i++) {
            var lastChild = shape.children[i-1]
            var curChild = shape.children[i]
            curChild.anchors.top = lastChild.bottom
        }
    }
    onCurItemChanged: {
        var childList = shape.children
        if (singleMode) {
            activatedNum = 1 
            for (var i = 0; i < childList.length; i++) {
                var child = childList[i]
                if (curItem !== child) {
                    child.activated = false
                }   
            }
        } 
    }
}