import QtQuick
import QtQuick.Window
import QtQuick.Controls.Fusion

Item {
    id: root
    property var curBtn: null
    property int btnNum: 0
    width: 35
    height: btnNum * width + 12
    property alias color: style.color
    signal menuTypeChanged(string menuType)

    
    Rectangle {
        id: style
        anchors.fill: parent
        border.color: "#323232"
        radius: 3
    }

    Rectangle {
        id: shape
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        anchors.fill: parent
        color:"transparent"
    }


    Component.onCompleted: {
        var childList = root.children
        for (var i = 0; i < childList.length; i++) {
            var curChild = childList[i]
            if (curChild instanceof MapleMenuButton) {
                curChild.controller = root
                shape.children.push(curChild)
                i--
                btnNum++
            }
        }
        for (var i = 1; i < shape.children.length; i++) {
            var lastChild = shape.children[i-1]
            var curChild = shape.children[i]
            curChild.anchors.top = lastChild.bottom
        }
    }

    onCurBtnChanged: {
        var childList = shape.children
        for (var i = 0; i < shape.children.length; i++) {
            var child = childList[i]
            if (curBtn !== child) {
                child.activated = false
            }     
        }
        if (curBtn !== null) {
            menuTypeChanged(curBtn.menuType)
        } else {
            menuTypeChanged("")
        }
        
    }

    function reset() {
        var childList = shape.children
        for (var i = 0; i < shape.children.length; i++) {
            var child = childList[i]
            child.activated = false
            curBtn = null
        }
    }
    
    function selectMenuButton(type) {
        var childList = shape.children
        for (var i = 0; i < shape.children.length; i++) {
            var child = childList[i]
            if (type === child.menuType) {
                curBtn = child
                curBtn.activated = true
            } 
        }
    }
}
