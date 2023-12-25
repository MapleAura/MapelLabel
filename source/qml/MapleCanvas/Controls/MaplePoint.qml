import QtQuick
import QtQuick.Controls
import MapleCommon

MapleTool {
    id: root                 
    width: 4;            
    height: 4; 
    toolType : MapleTool.ToolType.Point
    property var shapeType: "point"

    Rectangle {
        anchors.fill:parent
        anchors.leftMargin:-2
        anchors.topMargin:-2
        color : root.activated ? "blue" : "red"      
        radius: 3;           
        clip: true;            
    }

    MapleDrager {
        // source: "qrc:/MapleCanvas/Images/dragcursor.svg"
        // rotation: 0
        mouseCursorShape: Qt.SizeAllCursor
        cursorHeight: 20
        cursorWidth: 20
        anchors.fill: parent
        anchors.leftMargin:-2
        anchors.topMargin:-2
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

    function start(x, y, button) {
        if (button === Qt.LeftButton && !finishedDraw) {
            root.x = x
            root.y = y
            //controller.addInst(root)   
        }    
    }

    function stop(x, y, button) {
        finishedDraw = true
        return true
    }

    function detailSerialize() {
        var modelList = []
        modelList.push({"value": "Point"})
        modelList.push({"value": "\tPt: (" + parseInt(x) + ", " + parseInt(y) + ")"})
        return modelList
    }

    function serialize() {
        var output = {}
        output.type = "point"
        output.x = x 
        output.y = y 
        serializeExtraParams(output)
        return output
    }

    function reConstruct(ctx) {
        x = ctx.x 
        y = ctx.y 
        reConstructExtraParams(ctx)
    }

}