
import QtQuick
import QtQuick.Controls
import MapleCommon

MapleTool {
    id: root                
    width: 4          
    height: 4
    toolType: MapleTool.ToolType.Rect
    property var shapeType: "rect"
    property int borderMargin: 4
    property int startX
    property int startY
    
    Rectangle {
        anchors.fill: parent
        border.color: activated ? "blue" : "red"
        color: "transparent"
        antialiasing: true
    }

    Rectangle {
        color: "red"
        width: 2
        visible: true
        height: 20
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: -20
        }
    }

    Text {
        id: content
        x: 0 
        y: -15 
        font.pixelSize: 12
        font.bold: false
        color: "blue"
        // Rectangle {
            
        //     anchors.fill: parent
            
        //     color: "yellow"
        // }
    }

    onXChanged: {
        positionChanged(x, y)
    }

    onYChanged: {
        positionChanged(x, y)
    }

    onWidthChanged: {
        positionChanged(x, y)
    }

    onHeightChanged: {
        positionChanged(x, y)
    }

    onRotationChanged: {
        positionChanged(x, y)
    }


    MapleDrager {
        // source: "qrc:/MapleCanvas/Images/dragcursor.svg"
        // rotation: 0
        mouseCursorShape: Qt.SizeAllCursor
        cursorHeight: 20
        cursorWidth: 20
        anchors.fill: parent
        onPosChanged: function(xOffset, yOffset) {
            root.x += xOffset;
            root.y += yOffset;
        }
        onClickChanged: {
            root.activated = true
            if ("curActivatedInsts" in controller) {
                controller.curActivatedInsts = [root]
            }
        }
    }

    Rectangle {
        color: "green"
        width: 10
        height: width
        radius: width / 2
        visible: true
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: -20
        }
        Image {
            id: rotateCursor
            source: "qrc:/MapleCanvas/Images/rotation.svg"
            visible: rotateArea.containsMouse | rotateArea.pressed
            x: rotateArea.mouseX - width / 2
            y: rotateArea.mouseY - height / 2
            width: 20
            height: 20
        }
        MouseArea {
            id: rotateArea
            anchors.centerIn: parent
            width: parent.width * 2
            height: parent.height * 2
            hoverEnabled: true
            property int lastX: 0
            onContainsMouseChanged: {
                if (containsMouse) {
                    cursorShape = Qt.BlankCursor
                } else {
                    cursorShape = Qt.ArrowCursor
                }
            }
            onPressedChanged: {
                if (containsPress) {
                    lastX = mouseX
                }
            }
            onPositionChanged: {
                if (pressed) {
                    var t = root.rotation + (mouseX - lastX) / 5
                    t = t % 360
                    if (t >= 45) {
                        root.rotation = 45
                    }

                    if (t <= -45) {
                        root.rotation = -45
                    }
                    if (t < 45 && t > -45) {
                        root.rotation = t
                    }
                }
            }
        }
        ToolTip {
            id: toolTip
            x: rotateArea.mouseX + 30
            y: rotateArea.mouseY
            visible: rotateArea.pressed

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
                text: angleConvert(root.rotation) + "°"
            }
        }
    }


    //上边拖拽
    MapleDrager {
        // source: "qrc:/MapleCanvas/Images/drcursor.svg"
        // rotation: 90
        mouseCursorShape: Qt.SizeVerCursor
        width: parent.width
        height: borderMargin
        anchors.top : parent.top
        onPosChanged: function(xOffset, yOffset){  
            var theta = root.rotation / 180 * 3.1415926
            root.x = root.x - 0.5 * Math.tan(theta) * yOffset
            root.y = root.y + 0.5 * yOffset + 0.5 * yOffset / Math.cos(theta)
            root.height = root.height - yOffset / Math.cos(theta)
        }
    }

    //左边拖拽
    MapleDrager {
        // source: "qrc:/MapleCanvas/Images/drcursor.svg"
        // rotation: 0
        mouseCursorShape: Qt.SizeHorCursor
        height: parent.height
        width: borderMargin
        anchors.left : parent.left
        onPosChanged: function(xOffset, yOffset){  
            var theta = root.rotation / 180 * 3.1415926
            root.y = root.y + 0.5 * Math.tan(theta) * xOffset
            root.x = root.x + 0.5 * xOffset + 0.5 * xOffset / Math.cos(theta)
            root.width = root.width - xOffset / Math.cos(theta)
        }
    }

    //右边拖拽
    MapleDrager {
        // source: "qrc:/MapleCanvas/Images/drcursor.svg"
        // rotation: 0
        mouseCursorShape: Qt.SizeHorCursor
        anchors.right : parent.right
        height: parent.height
        width: borderMargin

        onPosChanged: function(xOffset, yOffset){  
            var theta = root.rotation / 180 * 3.1415926
            root.y = root.y + 0.5 * Math.tan(theta) * xOffset
            root.x = root.x + 0.5 * xOffset - 0.5 * xOffset / Math.cos(theta)
            root.width = root.width + xOffset / Math.cos(theta)
        }
    }

    //下边拖拽
    MapleDrager {
        // source: "qrc:/MapleCanvas/Images/drcursor.svg"
        // rotation: 90
        mouseCursorShape: Qt.SizeVerCursor
        anchors.bottom : parent.bottom
        width: parent.width
        height: borderMargin
        onPosChanged: function(xOffset, yOffset){  
            var theta = root.rotation / 180 * 3.1415926
            root.x = root.x - 0.5 * Math.tan(theta) * yOffset
            root.y = root.y + 0.5 * yOffset - 0.5 * yOffset / Math.cos(theta)
            root.height = root.height + yOffset / Math.cos(theta)
        }
    }

    function angleConvert() {
        var angle = 0
        if (rotation < 0 && width > height) {
            angle = rotation 
        }
        if (rotation < 0 && width <= height) {
            angle = -rotation - 90
        }
        if (rotation > 0 && width > height) {
            angle = rotation 
        }
        if (rotation > 0 && width <= height) {
            angle = -rotation + 90
        }
        return parseInt(angle)
    }

    function start(x, y, button) {
        if (button === Qt.LeftButton && !finishedDraw) {
            root.x = x
            root.y = y
            startX = x
            startY = y
        }    
    }

    function then(x, y) {
        
        if (!finishedDraw) {
            if (x - startX > 0) {
                root.width = x - startX
            } else {
                root.width = startX - x
                root.x = x
            }

            if (y - startY > 0) {
                root.height = y - startY
            } else {
                root.height = startY - y
                root.y = y
            }
        }    
    }

    function stop(x, y, button) {
        if (button === Qt.LeftButton && !finishedDraw) {
            if (root.width < 8 || root.height < 8) {
                finishedDraw = true
                return false
            }
            finishedDraw = true
            //controller.addInst(root)
            return true
        }  
        return true
    }

    function detailSerialize() {
        var modelList = []
        modelList.push({"value": "Rect:"})
        modelList.push({"value": "\tTLPt: (" + parseInt(x) + ", " + parseInt(y) + ")"})
        modelList.push({"value": "\tWidth: " + parseInt(width) + ", " + "Height: " + parseInt(height) })
        modelList.push({"value": "\tRotation: " + angleConvert(root.rotation) + "°"  })
        return modelList
    }

    function serialize() {
        var output = {}
        output.type = "rect"
        output.x = x 
        output.y = y 
        output.width = width 
        output.height = height
        output.rotation = rotation
        serializeExtraParams(output)
        return output
    }

    function reConstruct(ctx) {
        x = ctx.x 
        y = ctx.y 
        width = ctx.width 
        height = ctx.height 
        rotation = ctx.rotation 
        reConstructExtraParams(ctx)
    }

    

    onExtraParamsChanged: {
        content.text = printExtraParams()
    }
}