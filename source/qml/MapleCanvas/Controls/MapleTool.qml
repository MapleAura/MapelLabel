import QtQuick
import QtQuick.Controls

Item {
    id: base
    enum ToolType {
        None,
        Selector,
        Eraser,
        Group,
        UnGroup,
        Point,
        Line,
        Rect,
        Polygen,
        Save,
        Undo
    }

    property var toolType: MapleTool.ToolType.None
    property bool activated: false
    property var controller: parent
    property bool finishedDraw: false


    property var defaultParams: ["x", "y", "width", "height", "type", "rotation", "shapes"]
    property var extraParams: []
    
    signal positionChanged(int newX, int newY)
    signal activatedClicked(bool state, var base)

    
    onXChanged: {
        positionChanged(x, y)
    }
    onYChanged: {
        positionChanged(x, y)
    }

    onActivatedChanged: {
        activatedClicked(activated, base)
    }

    function start(x, y, button) {
    }

    function then(x, y) {
    }

    function stop(x, y, button) {
        return true
    }

    function detailSerialize() {
        return null
    }

    function serialize() {
        return null
    }

    function reConstruct(ctx) {
        return null
    }

    function serializeExtraParams(output) {
        for (var i in extraParams) {
            output[extraParams[i].key] = extraParams[i].value
        }
    }

    function printExtraParams() {
        var ctx = ""
        for (var i in extraParams) {
            
            if (i > extraParams.length - 2) {
                ctx = ctx + extraParams[i].value
            } else {
                ctx = ctx + extraParams[i].value + ", "
            }
           
        }
        return ctx
    }

    function reConstructExtraParams(ctx) {
        var keys = Object.keys(ctx)
        var extraRes = []
        for (var i in keys) {
            var key = keys[i]
            if (!defaultParams.includes(key)) {
                var tmp = {}
                tmp["key"] = key
                tmp["value"] = ctx[key]
                extraRes.push(tmp)
            }
        }  
        extraParams = extraRes
    }


}