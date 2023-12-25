import QtQuick
import QtQuick.Controls
import MapleCommon

MapleSelector {
    toolType: MapleTool.ToolType.Eraser
    function stop(x, y, button) {
        if (button === Qt.LeftButton && !finishedDraw) {
            
            controller.curActivatedInsts = selectMultInst()

            deleteInsts(controller.curActivatedInsts)
            finishedDraw = true
            return false
        }  
        finishedDraw = true
        return false
    }

    function deleteInsts(obj) {

        insts = insts.filter(function(item) {
                return !obj.includes(item)
        });
 
        for (var i in obj) {

            obj[i].destroy()
        }
        curActivatedInsts = null

    }

    

}