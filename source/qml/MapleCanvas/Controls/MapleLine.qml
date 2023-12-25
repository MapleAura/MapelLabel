import QtQuick
import QtQuick.Controls
import MapleCommon

MapleTool {
    property MaplePoint start
    property MaplePoint end
    toolType : MapleTool.ToolType.Line
    property var shapeType: "line"
    property int thickness: 1

    Rectangle {
        width: Math.sqrt((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y))
        height: thickness
        color: "green"
        x: start.x
        y: start.y
        transform: Rotation {
            origin.x: 0
            origin.y: 0
            angle: Math.atan2(end.y - start.y, end.x - start.x) * 180 / Math.PI
        }
    }


}