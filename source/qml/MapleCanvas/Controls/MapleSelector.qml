import QtQuick
import QtQuick.Controls

MapleTool {
    id: root
    property int startX
    property int startY
    Rectangle {
        anchors.fill: parent
        color:"#232323"
        opacity:0.5
        border.color: "#454545"
    }

    function selectMultInst() {
        var insts = []
        for (var i in controller.insts) {
            var inst = controller.insts[i]
            if (inst.shapeType === "polygen") {  
                var cx = inst.mapleX + inst.mapleWidth * 0.5
                var cy = inst.mapleY + inst.mapleHeight * 0.5
                if (cx > root.x && cx < root.x + root.width && cy > root.y && cy < root.y + root.height) {
                    insts.push(inst)
                }
            } else if (inst.shapeType === "point") {
                
                var cx = inst.x
                var cy = inst.y
                if (cx > root.x && cx < root.x + root.width && cy > root.y && cy < root.y + root.height) {
                    insts.push(inst)
                }
            } else if (inst.shapeType === "rect") {
                var cx = inst.x + inst.width * 0.5
                var cy = inst.y + inst.height * 0.5
                if (cx > root.x && cx < root.x + root.width && cy > root.y && cy < root.y + root.height) {
                    insts.push(inst)
                }
            } else if (inst.shapeType === "group") {  
                var cx = inst.mapleX + inst.mapleWidth * 0.5
                var cy = inst.mapleY + inst.mapleHeight * 0.5
                if (cx > root.x && cx < root.x + root.width && cy > root.y && cy < root.y + root.height) {
                    insts.push(inst)
                }
            } else {

            }
        }
        return insts
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
            controller.curActivatedInsts = selectMultInst()
            finishedDraw = true
            return false
        }  
        finishedDraw = true
        return false
    }
}