import QtQuick
import QtQuick.Controls
import MapleCommon

MapleSelector {
    id: root
    toolType: MapleTool.ToolType.Group
    property alias mapleX: border.x
    property alias mapleY: border.y
    property alias mapleWidth: border.width
    property alias mapleHeight: border.height
    property var shapeType: "group"
    property var container: []
    function stop(x, y, button) {
        if (button === Qt.LeftButton && !finishedDraw) {
            finishedDraw = true
            controller.curActivatedInsts = selectMultInst()
            if (!merge()) {
                return false
            }    
            return true
        } 
        finishedDraw = true 
        return false
    }

    
    Rectangle {
        id: border
        color: "transparent"
    }

    function checkBorder() {
        var tlPt = {"x":999999, "y":999999}
        var brPt = {"x":-999999,"y":-999999}
        for (var i in container) {   
            if ("mapleX" in container[i]) {
                if (tlPt.x > container[i].mapleX) {
                    tlPt.x = container[i].mapleX              
                }
                if( tlPt.y > container[i].mapleY) {
                    tlPt.y = container[i].mapleY
                }
                if (brPt.x < container[i].mapleX) {
                    brPt.x = container[i].mapleX
                }
                if( brPt.y < container[i].mapleY) {
                    brPt.y = container[i].mapleY
                }

            }  else {
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

    }

    function bindActivated(state) {
        if (state) {
            for (var i in container) {
                container[i].activated = true
            }       
            if ("curActivatedInsts" in controller) {
                controller.curActivatedInsts = [root]
            }
        } else {
            for (var i in container) {
                container[i].activated = false
            }
        }
    }

    function detailSerialize() {
        var arr = []
        arr.push({"value": "Group:"})
        for (var i in container) {
            var inst = container[i]
            var res = inst.detailSerialize()
            arr.push(...res)
            
        }

        return arr
    }

    function merge() {
        if (controller.curActivatedInsts === null) {
            return 
        }
        container = controller.curActivatedInsts.filter(function(item) {return item.shapeType !== "group"})
        if (container.length < 2) {
            return false
        }
        var newShapeInsts = controller.insts.filter(function(item) {
            return !container.includes(item)
        });
        for (var i in container) {
            container[i].activatedClicked.connect(bindActivated)
        }
        root.x = 0
        root.y = 0
        checkBorder() // todo: strictly limit
        root.visible = false
        newShapeInsts.push(root)
        controller.insts = newShapeInsts
        root.activated = true
        controller.curActivatedInsts = [root]

        return true
    }

    function split() {
        var newShapeInst = insts.filter(function(item) {
            return root !== item
        });

        for (var i in container) {
            container[i].activatedClicked.disconnect(bindActivated)
            newShapeInst.push(container[i])
        }
        container = []
        controller.insts = newShapeInst
        controller.curActivatedInsts = null
        root.destroy()
    }

    onActivatedChanged: {

        if (activated) {
            for (var i in container) {
                container[i].activated = true
            } 
        } else {
    
            for (var i in container) {
                container[i].activated = false
            }
        }
    }

    function serialize() {
        var output = {}
        output.type = "group"
        var shapes = []
        for (var i in container) {
            shapes.push(container[i].serialize())
        }
        output.shapes = shapes
        output.x = mapleX 
        output.y = mapleY 
        output.width = mapleWidth
        output.height = mapleHeight
        serializeExtraParams(output)
        return output
    }

    function reConstruct(ctx) {
        mapleX = ctx.x 
        mapleY = ctx.y 
        mapleWidth = ctx.width 
        mapleHeight = ctx.height 
        for (var i in ctx.shapes) {
            var shape = ctx.shapes[i]
            var obj = controller.mapleTools[controller.toolTypeLUT[shape.type]].createObject(root)  
            obj.reConstruct(shape)
            obj.activatedClicked.connect(bindActivated)
            obj.positionChanged.connect(controller.updateModelListInfo)
            container.push(obj)
        }
        reConstructExtraParams(ctx)
    }

    Component.onDestruction: {
        for (var i in container) {
            container[i].destroy()
        }
    }


}