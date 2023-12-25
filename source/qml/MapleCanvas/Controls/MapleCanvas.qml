import QtQuick
import QtQuick.Controls

Image {
    id: root
    property var settings: null
    property var extraParamsIn: null
    property var extraParamsOut: null
    property var mapleTools: {"none": null}
    property var toolType: null
    property bool ctrlEnable: false
    property bool undoEnable: false
    property bool redoEnable: false
    property int undoCount: 0
    property var insts: []
    property var curActivatedInsts: null
    property var lastActivatedInsts: null
    property var curUnCompletedInst: null
    property ListModel curActivatedInstModel: ListModel {}
    property var tmpFilePath: null
    property var filePath: null
    property var historyRecoder: []
    visible: root.status  === Image.Ready ? true: false
    fillMode: Image.PreserveAspectFit
    property var toolTypeLUT: {
        "rect": MapleTool.ToolType.Rect,
        "point": MapleTool.ToolType.Point,
        "polygen": MapleTool.ToolType.Polygen,
        "group": MapleTool.ToolType.Group,
    }

    signal openSignal(string path)
    signal saveSignal(string path)

    MouseArea {
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        drag.target: pressedButtons === Qt.RightButton? root : null
        drag.axis: Drag.XAndYAxis
        drag.filterChildren: true
        drag.threshold: 4
        onWheel: function(wheel) {
            if (wheel.modifiers & Qt.ControlModifier) {
                root.rotation += wheel.angleDelta.y / 120 * 5;
                if (Math.abs(root.rotation) < 4)
                    root.rotation = 0;
            } else {
                root.rotation += wheel.angleDelta.x / 120;
                if (Math.abs(root.rotation) < 0.6)
                    root.rotation = 0;
                var scaleBefore = root.scale;
                root.scale += root.scale * wheel.angleDelta.y / 120 / 10;
            }
        }
        hoverEnabled: true
        onPressed: function(mouse) {
            if ((curUnCompletedInst !== null && curUnCompletedInst.finishedDraw) || curUnCompletedInst === null) {
                if (mouse.button ===  Qt.LeftButton) {
                    curUnCompletedInst = createInst(toolType)
                    if (curUnCompletedInst !== null) {
                        curUnCompletedInst.start(mouse.x, mouse.y, mouse.button)
                    }
                }
            } else if (curUnCompletedInst !== null && !curUnCompletedInst.finishedDraw) {
                curUnCompletedInst.start(mouse.x, mouse.y, mouse.button)
            } else {

            }
        }

        onPositionChanged: function(mouse) {
            if (curUnCompletedInst !== null && !curUnCompletedInst.finishedDraw) {
                curUnCompletedInst.then(mouse.x, mouse.y)
            }
        }

        onReleased: function(mouse) {
            if (curUnCompletedInst !== null && !curUnCompletedInst.finishedDraw) {
                if(!curUnCompletedInst.stop(mouse.x, mouse.y, mouse.button)) {
                    if (curUnCompletedInst.finishedDraw) {
                        curUnCompletedInst.destroy()
                    }    
                } else {
                    curUnCompletedInst.positionChanged.connect(updateCurInstModelInfo)

                    // init extra params
                    if (settings !== null && curUnCompletedInst.shapeType in settings) {
                        var setting = settings[curUnCompletedInst.shapeType]
                        var curValues = []
                        for (var i in setting) {
                            var item = setting[i]
                            var curValue = {}
                            curValue["key"] = item.key
                            if (item.value.length > 0) {
                                curValue["value"] = item.value[0]
                            } else {
                                curValue["value"] = ""
                            }
                           
                            curValues.push(curValue)
                        }   
                        curUnCompletedInst.extraParams = curValues

                    }
                    root.addInst(curUnCompletedInst)
                }
            }
        }
    }


    onToolTypeChanged: {
        if (toolType === MapleTool.ToolType.Save) {
            saveData()
        }
        if (toolType === MapleTool.ToolType.Undo) {
            undo()
        }
        if (toolType === MapleTool.ToolType.Redo) {
            redo()
        }
    }

    onInstsChanged: {
        if (!undoEnable && !redoEnable) {
            if (undoCount > 0) {
                historyRecoder.splice(historyRecoder.length - undoCount, undoCount);
                undoCount = 0
                
            }
            var tmp = []
            for (var i in insts) {
                var inst = insts[i]
                var rec = inst.serialize()
                tmp.push(rec)
                // console.log(JSON.stringify(rec))
            }
            historyRecoder.push(tmp)
        }
    }

    Keys.onPressed:function(event) {
        event.accepted = true
        if (event.key === Qt.Key_Control) {
            ctrlEnable = true
        } 
    }

    Keys.onReleased: {
        ctrlEnable = false
    }

    onCurActivatedInstsChanged: {
        
        if (ctrlEnable) {
            for (var i in lastActivatedInsts) {
                var lastInst = lastActivatedInsts[i]
                curActivatedInsts.push(lastInst)
            }
        }
        lastActivatedInsts = curActivatedInsts

        updateActivatedStates()
        updateCurInstModelInfo()
        updateOutputExtraParams()
        
    }

    function updateOutputExtraParams() {
        var paramsOut = {}
        if (curActivatedInsts  !== null && curActivatedInsts.length > 0) {
            paramsOut.allItems = settings[curActivatedInsts[0].shapeType]
            paramsOut.curSelectedItems = curActivatedInsts[0].extraParams
        }
        extraParamsOut = paramsOut
    }

    onSourceChanged: {
        saveTmpData()
        clearAll()
        loadByData()
    }

    onExtraParamsInChanged: {
        if (curActivatedInsts !== null && curActivatedInsts.length > 0) {
            curActivatedInsts[0].extraParams = extraParamsIn
        }
    }

    Keys.enabled: true
    focus: true

    function register(key, compPath) {
        var comp = Qt.createComponent(compPath);
        if (comp.status === Component.Ready) {
            mapleTools[key] = comp
        } else {                   
            console.log("Component load failed: "+ comp.errorString())
        }
    }

    function createInst(toolType) {
        var obj = null
        if (toolType in mapleTools) {
            
            obj = mapleTools[toolType].createObject(root);
        }
        return obj;    
    }

    function addInst(obj) {
        var tmp = insts
        tmp.push(obj)
        insts = tmp
   
    }

    function clearAll() {
        curActivatedInsts = []
        for (var i in insts){
            var inst = insts[i]
            inst.destroy()
        }
        historyRecoder = []
        insts = []
        
    }

    function undo() {
        undoEnable = true
        if (historyRecoder.length > 1 && undoCount < historyRecoder.length) {
            
            undoCount ++
            curActivatedInsts = []
            for (var i in insts) {
                var inst = insts[i]
                inst.destroy()
            }
            var recoder = historyRecoder[historyRecoder.length - 1 - undoCount]
            var tmp_insts = []
            for (var i in recoder) {
                var rec = recoder[i]
                var obj = createInst(toolTypeLUT[rec.type])
                obj.reConstruct(rec)
                obj.positionChanged.connect(updateCurInstModelInfo)
                tmp_insts.push(obj)
            }
            insts = tmp_insts
            
            
        }
        undoEnable = false
        
    }

    function redo() {
        redoEnable = true
        if (historyRecoder.length > 1 && undoCount > 0) {
            undoCount --
            curActivatedInsts = []
            for (var i in insts) {
                var inst = insts[i]
                inst.destroy()
            }
            var recoder = historyRecoder[historyRecoder.length - 1 - undoCount]
            var tmp_insts = []
            for (var i in recoder) {
                var rec = recoder[i]
                var obj = createInst(toolTypeLUT[rec.type])
                obj.reConstruct(rec)
                obj.positionChanged.connect(updateCurInstModelInfo)
                tmp_insts.push(obj)
            }
            insts = tmp_insts
        }
        redoEnable = false
    }

    function updateCurInstModelInfo() {
        var tmp = Qt.createQmlObject("import QtQuick; ListModel {}", parent);
        if (curActivatedInsts !== null && curActivatedInsts.length > 0) {
            
            var curInst = curActivatedInsts[0]
            var obj = curInst.detailSerialize()
            for (var i in obj) {
                var value = obj[i]
                tmp.append(value)
            } 
        } 
        curActivatedInstModel = tmp
    }

    function updateActivatedStates() {   
        if (curActivatedInsts === null) {
            return
        }
        var unActivatedInsts = insts.filter(function(item) {
            return !curActivatedInsts.includes(item)
        });

        for (var i in unActivatedInsts) {
            unActivatedInsts[i].activated = false;
            
        }
        for (var i in curActivatedInsts) {
            curActivatedInsts[i].activated = true;
        }
    }

    function getPathElem(path) {
        var pos = path.lastIndexOf('/');
        var fileName = path.substr(pos + 1);
        var filePath = path.substr(0, pos);
        var pos2 = fileName.lastIndexOf('.');
        var suf = fileName.substr(pos2 + 1);
        var name = fileName.substr(0, pos2);
        return [filePath, name, suf]

    }

    function saveJsonFile(path, content) {
        if (path === null) {
            return 
        }
        var res = JSON.stringify(content)
        fileOp.saveFile(path, res, "wb", "utf-8")

    }

    function openJsonFile(path) {
        var res = fileOp.readFile(path, "rb", "utf-8")
        if (res === "") {
            return null
        } else {
            return JSON.parse(res)
        }
    }

    function loadByData() {

        var sepPath = getPathElem(source.toString())
        filePath = sepPath[0] + "/" + sepPath[1] + ".json"
        tmpFilePath = sepPath[0] + "/" + sepPath[1] + ".maple"
        openSignal(source.toString().replace("file:///", "") + " has been loaded.")
        var ctx = openJsonFile(filePath)
        if (ctx === null) {
            ctx = openJsonFile(tmpFilePath)
        }
        if (ctx === null) {
            return 
        }
        var tmp = []

        // try {
            var shapes = ctx["shapes"]
            for (var i in shapes) {
                var shape = shapes[i]
                var obj = createInst(toolTypeLUT[shape.type])
                obj.reConstruct(shape)
                obj.positionChanged.connect(updateCurInstModelInfo)
                tmp.push(obj)
            }
        // } catch(err) {
        //     console.log("label has been revised.")
        // }
        insts = tmp
        
    }


    function saveByData(path) {
        if (path === null) {
            return 
        }
        var obj = {}
        obj.version = "1.0.1"
        var shapes = []
        for (var i in insts) {
            var shape = insts[i].serialize()
            shapes.push(shape)
        }
        if (shapes.length < 1 && path.includes(".maple")) {
            return 
        }
        obj.shapes = shapes
        saveJsonFile(path, obj)
    }

    function saveData() {
    
        saveByData(filePath)
        saveSignal(filePath + " has been saved.")
    }

    function saveTmpData() {
        saveByData(tmpFilePath)
    }

    Component.onCompleted: {
        register(MapleTool.ToolType.Point, "MaplePoint.qml")
        register(MapleTool.ToolType.Rect, "MapleRect.qml")
        register(MapleTool.ToolType.Polygen, "MaplePolygen.qml")
        register(MapleTool.ToolType.Line, "MapleLine.qml")
        register(MapleTool.ToolType.Selector, "MapleSelector.qml")
        register(MapleTool.ToolType.Eraser, "MapleEraser.qml")
        register(MapleTool.ToolType.Group, "MapleGroup.qml")
        register(MapleTool.ToolType.UnGroup, "MapleUnGroup.qml")
    }
}