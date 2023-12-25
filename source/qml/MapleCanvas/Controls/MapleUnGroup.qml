import QtQuick
import QtQuick.Controls

MapleSelector {
    id: root
    function stop(x, y, button) {
        if (button === Qt.LeftButton && !finishedDraw) {
            controller.curActivatedInsts = selectMultInst()
            for (var i in controller.curActivatedInsts) {
                var inst = controller.curActivatedInsts[i]
                if (inst.shapeType === "group") {
                    inst.split()
                }
            }
            finishedDraw = true
            return false
        }  
        finishedDraw = true
        return false
    }
}