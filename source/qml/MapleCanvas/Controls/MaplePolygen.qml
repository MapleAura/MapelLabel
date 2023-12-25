import QtQuick 
import QtQuick.Controls 
  
MapleTool {  
    id: root  
    toolType: MapleTool.ToolType.Polygen
    property var curPoint : null
    property var lastPoint : null
    property var container : []
    property var curLine : null
    property bool firstTime : true
    property var firstPoint : null 
    property alias mapleX: border.x
    property alias mapleY: border.y
    property alias mapleWidth: border.width
    property alias mapleHeight: border.height
    property var shapeType: "polygen"

    onMapleXChanged: {
        positionChanged(mapleX, mapleY)
    }
    onMapleYChanged: {
        positionChanged(mapleX, mapleY)
    }
    
    Rectangle {
        property point tlPt : "999999.0,999999.0"
        property point brPt : "-999999.0,-999999.0"
        id: border
        border.color : root.activated ? "blue" : "transparent"  
        color : "transparent"         
    }

    Text {
        id: content
        x: mapleX 
        y: mapleY - 15 
        font.pixelSize: 12
        font.bold: false
        color: "blue"
    }

    MouseArea {
        id : mouseArea
        visible: false
        anchors.fill:parent
        onClicked: {
            root.activated = true
            if ("curActivatedInsts" in controller) {
                controller.curActivatedInsts = [root]
            }
        }
    }   

    function checkBorder() {
        var tlPt = {"x":999999, "y":999999}
        var brPt = {"x":-999999,"y":-999999}
        for (var i in container) {
            if (i % 2 === 0) {
                
                if (tlPt.x > container[i].x) {
                    tlPt.x = container[i].x              
                }
                if( tlPt.y > container[i].y) {
                    tlPt.y = container[i].y
                }
                if (brPt.x < container[i].x) {
                    brPt.x = container[i].x
                }
                if( brPt.y < container[i].y) {
                    brPt.y = container[i].y
                }
            }

        }
        border.x = tlPt.x
        border.y = tlPt.y
        border.width = brPt.x - tlPt.x
        border.height = brPt.y - tlPt.y
        positionChanged(mapleX, mapleY)
    }

    function bindActivated(state) {
        if (state) {
            for (var i in container) {
                if (i % 2 === 0) {
                    container[i].activated = false
                }
            }       
            if ("curActivatedInsts" in controller) {
                controller.curActivatedInsts = [root]
            }
        } else {
            for (var i in container) {
                if (i % 2 === 0) {
                    container[i].activated = false
                }
            }
        }
        
    }

    function addPoint(x, y) {   
        if (border.tlPt.x > x) {
            border.tlPt.x = x
            border.x = x
        }
        if( border.tlPt.y > y) {
            border.tlPt.y = y
            border.y = y
        }
        if (border.brPt.x < x) {
            
            border.brPt.x = x
        }
        if( border.brPt.y < y) {
            border.brPt.y = y
        }
        if ( border.brPt.x - x> border.width) {
            
            border.width = border.brPt.x - x
        }
        if (border.brPt.y - y> border.height) {
            border.height = border.brPt.y - y
        }
        if ( x - border.tlPt.x> border.width) {
            border.width = x - border.tlPt.x
        }
        if ( y- border.tlPt.y> border.height) {
            border.height = y - border.tlPt.y
        }

        
        curPoint = controller.mapleTools[MapleTool.ToolType.Point].createObject(root, { "x": x, "y": y }); 
        curPoint.positionChanged.connect(checkBorder)
        curPoint.activatedClicked.connect(bindActivated)
        if (firstTime) {
           firstTime = false
           firstPoint = curPoint
        } else {
            curLine = controller.mapleTools[MapleTool.ToolType.Line].createObject(root, { "start": lastPoint, "end": curPoint}); 
            container.push(curLine)
        }
        container.push(curPoint)

        lastPoint = curPoint 
        
    }

    function addFinished() {
        curLine = controller.mapleTools[MapleTool.ToolType.Line].createObject(root, { "start": lastPoint, "end": firstPoint}); 
        container.push(curLine)
    }

    function start(x, y, button) {
        if (button === Qt.LeftButton && !finishedDraw) {
            addPoint(x, y)
        }    
    }

    function stop(x, y, button) {
        if (button === Qt.RightButton && !finishedDraw) {
            if (container.length < 4) {
                finishedDraw = true
                return false
            }
            addFinished()
            finishedDraw = true
            //controller.addInst(root)
            return true
        } 
        return false

    }

    function detailSerialize() {
        var modelList = []
        modelList.push({"value": "Poylgen:"})
        modelList.push({"value": "\tTLPt: (" + parseInt(mapleX) + ", " + parseInt(mapleY) + ")"})
        modelList.push({"value": "\tBRPt: (" + parseInt(mapleX + mapleWidth) + ", " + parseInt(mapleY + mapleHeight) + ")"})
        // modelList.push({"value": "\tContour:"})
        // for (var i in container) {
        //     if (i % 2 === 0) {   
        //         var po = container[i]
        //         modelList.push({"value": "\t\t(" + parseInt(po.x) + ", " + parseInt(po.y) + ")"})
        //     }
            
        // }
        return modelList
    }

    function serialize() {
        var output = {}
        output.type = "polygen"
        output.x = mapleX 
        output.y = mapleY 
        output.width = mapleWidth
        output.height = mapleHeight
        var shapes = []
        for (var i in container) {
            if (i % 2 === 0) {
                shapes.push(container[i].serialize())
            } 
        }
        serializeExtraParams(output)
        output.shapes = shapes
        return output
    }

    function reConstruct(ctx) {
        mapleX = ctx.x 
        mapleY = ctx.y 
        mapleWidth = ctx.width
        mapleHeight = ctx.height
        for (var i in ctx.shapes) {
            var shape = ctx.shapes[i]
            var obj = controller.mapleTools[MapleTool.ToolType.Point].createObject(root)
            obj.reConstruct(shape)
            obj.positionChanged.connect(checkBorder)
            obj.activatedClicked.connect(bindActivated)
            if (i > 0) {
                var line = controller.mapleTools[MapleTool.ToolType.Line].createObject(root, { "start": container[container.length - 1], "end": obj}); 
                container.push(line)
            }
            container.push(obj)
            if (i > ctx.shapes.length - 2) {
                var endline = controller.mapleTools[MapleTool.ToolType.Line].createObject(root, { "start": obj, "end": container[0]}); 
                container.push(endline)
            }
        }  
        reConstructExtraParams(ctx)
    }

    onExtraParamsChanged: {
        content.text = printExtraParams()
    }

    Component.onDestruction: {
        for (var i in container) {
            container[i].destroy()
        }
    }
}