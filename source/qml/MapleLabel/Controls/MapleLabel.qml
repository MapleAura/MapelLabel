import QtQuick 
import QtQuick.Window 
import QtQuick.Controls.Fusion
import MapleCommon
import MapleCanvas
Window {
    id: window
    visible: true 
    flags: Qt.FramelessWindowHint | Qt.Window
    minimumHeight: 480
    minimumWidth: 640
    width: 1080
    height: 640
    MapleWindow {
        id: root
        oriWindow: window
        title: "MapleLabel v1.0.2"
        logo: "qrc:/MapleLabel/Images/logo.svg"
        titleBarColor: "#404040"
        bodyColor: "#282828"
        property var menuType: null
        property var mapleSettings: null
        property bool autoLabelEnable: false
        property var aiConfigure: null
        MapleCanvas {
            id: canvas
            settings: root.mapleSettings
            extraParamsIn: comboBox.extraParamsOut
            onOpenSignal: function(path) {
                output.text = path
            }
            onSaveSignal: function(path) {
                output.text = path
            }
        }

        MapleMenu {
            id: menu
            color: "#454545"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            MapleMenuButton {
                menuType:"open"
                source:"qrc:/MapleLabel/Images/open.svg"
                bounceBacked: true
                text:"open folder"
            }
            MapleMenuButton {
                menuType:"save"
                source:"qrc:/MapleLabel/Images/save.svg"
                bounceBacked: true
                text:"save file"
            }
            MapleMenuButton {
                menuType:"undo"
                source:"qrc:/MapleLabel/Images/undo.svg"
                bounceBacked: true
                text:"undo"
            }
            MapleMenuButton {
                menuType:"redo"
                source:"qrc:/MapleLabel/Images/redo.svg"
                bounceBacked: true
                text:"redo"
            }
            MapleMenuButton {
                menuType:"select"
                source:"qrc:/MapleLabel/Images/select.svg"
                text:"select shape(s)"
            }
            MapleMenuButton {
                menuType:"erase"
                source:"qrc:/MapleLabel/Images/erase.svg"
                text:"erase shape(s)"
            }
            MapleMenuButton {
                menuType:"point"
                source:"qrc:/MapleLabel/Images/point.svg"
                text:"draw point"
            }
            MapleMenuButton {
                menuType:"rect"
                source:"qrc:/MapleLabel/Images/rect.svg"
                text:"draw rect"
            }
            MapleMenuButton {
                menuType:"polygen"
                source:"qrc:/MapleLabel/Images/polygen.svg"
                text:"draw polygen"
            }
            MapleMenuButton {
                menuType:"group"
                source:"qrc:/MapleLabel/Images/group.svg"
                text:"merge shapes"
            }
            MapleMenuButton {
                menuType:"ungroup"
                source:"qrc:/MapleLabel/Images/ungroup.svg"
                text:"split shapes"
            }
            MapleMenuButton {
                menuType:"AI"
                source:"qrc:/MapleLabel/Images/ai.svg"
                bounceBacked: true
                text:"use AI"
            }
        }

        MapleAccordion {
            id: accordion
            singleMode: false
            width: 300
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#363636"
            MapleAccordionItem {
                text: "Files"
                ScrollView {
                    anchors.fill:parent
                    MapleFilePanel {
                        id: filePanel
                        anchors.fill:parent
                        color: "transparent"
                    }
                }
                
            }
            MapleAccordionItem {
                text: "Attributes"
                ScrollView {
                    anchors.fill:parent
                    MapleComboBoxPanel {
                        anchors.top: parent.top
                        id: comboBox
                        extraParamsIn: canvas.extraParamsOut
                    }
                    MapleDisplayPanel {
                        anchors.top: comboBox.bottom
                        anchors.bottom: parent.bottom
                        width: parent.width
                        color: "transparent"
                        listModel: canvas.curActivatedInstModel
                    }
                }
            }

            MapleDrager {
                mouseCursorShape: Qt.SizeHorCursor
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width:4
                onPosChanged: function(xOffset, yOffset) {
                    if (parent.width - xOffset < 50 || parent.width - xOffset > 300) {
                        return 
                    }
                    parent.width -= xOffset;
                }
            }
        }

        // ai 
        Rectangle {
            id: hiddenBox
            z: 99
            property bool isOpened: false
            anchors.verticalCenter: parent.verticalCenter
            height: menu.height * 0.8
            anchors.left: menu.right
            implicitWidth: isOpened? 200: 0
            color:"#404040"
            border.color:"#181818"
            clip: true
            Behavior on implicitWidth {
                PropertyAnimation { duration: 150 }
            }
            ScrollView {
                anchors.fill:parent
                anchors.margins:1
                MapleDisplayPanel {
                    id: aiList
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin:6
                    clickEnable: true
                    color:"transparent"
                    onCurrentItemChanged: {
                        dialog.open();
                    }
                    Component.onCompleted: {
                        try {
                            var ctx = fileOp.readFile("_internal/resource/aiconfig.json", "rb", "base64_utf-8")                                                    
                        } catch(err) {
                            output.text = "Auto label unsupported."
                            console.log("Auto label unsupported.")
                            return
                        }
                        
                        var res = watchDog.verify("resource/watchdog.txt")
                        if (!res) {
                            output.text = "Unauthorized."
                            console.log("Unauthorized.")
                            return
                        }
                        
                        root.aiConfigure = JSON.parse(ctx);
                        var tmp = Qt.createQmlObject("import QtQuick; ListModel {}", parent);
                        for (var i in root.aiConfigure.source) {
                            var curItem = root.aiConfigure.source[i]
                            tmp.append({"value": curItem.name})
                        }
                        listModel = tmp  
                    }                    
                }
            }
        }

        Dialog {
            id: dialog
            modal: true
            width: 400
            height: 125
            title: qsTr("Remind")
            anchors.centerIn: parent
            background: Rectangle {
                color:"#404040"
            }
            Text {
                anchors.margins: 6
                
                anchors.fill: parent
                id: text
                text: qsTr("The files in the current folder will be automatically labeled, click the OK button to confirm the operation.")
                anchors.centerIn: parent
                wrapMode: Text.WordWrap
                color:"white"
            }

            standardButtons: Dialog.Ok | Dialog.Cancel
            onAccepted: {
                for (var i in root.aiConfigure.source) {
                    var sr = root.aiConfigure.source[i]
                    if (sr.name === aiList.currentItem) {

                        root.setTimeout(function() {
                            popup.open()
                            popup.text = "Loading model..."
                        }, 0)
                        root.setTimeout(function() {
                            autoLabel.create(JSON.stringify(sr.ctx))
                            root.autoLabelEnable = true
                            popup.close()
          
                        }, 10)
                        break
                    }
                }
            }
        }

        MapleLoger {
            id: output
            anchors.leftMargin: 8
            anchors.bottomMargin: 6
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            color:"green"
        }


        MapleButton {
            width: 50
            height: 50
            visible: canvas.visible
            anchors.left: menu.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            source: "qrc:/MapleLabel/Images/last.svg"
            onClickChanged: function() {
                filePanel.last()
            }
        }

        MapleButton {
            width: 50
            height: 50
            visible: canvas.visible
            anchors.right: accordion.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            source: "qrc:/MapleLabel/Images/next.svg"
            onClickChanged: function() {
                filePanel.next()
            }
        }

        
        MapleWaitPopup {
            id: popup
            width: 300
            height: 70
            anchors.centerIn: parent
        }

        Component.onCompleted: {
            menu.menuTypeChanged.connect(function(type) {
                var canvasTools = {
                    "point": MapleTool.ToolType.Point,
                    "rect": MapleTool.ToolType.Rect,
                    "polygen": MapleTool.ToolType.Polygen,
                    "erase": MapleTool.ToolType.Eraser,
                    "select": MapleTool.ToolType.Selector,
                    "group": MapleTool.ToolType.Group,
                    "ungroup": MapleTool.ToolType.UnGroup,
                    "save":MapleTool.ToolType.Save,
                    "undo":MapleTool.ToolType.Undo,
                    "redo":MapleTool.ToolType.Redo,
                }
                if (type in canvasTools) {
                    canvas.toolType = canvasTools[type]
                } else {
                    canvas.toolType = null
                }
                if (type === "open") {
                    filePanel.dialogOpened = true
                } 
                if (type === "AI") {
                    hiddenBox.isOpened = !hiddenBox.isOpened
                }
            })

            filePanel.selectedFlieChanged.connect(function(path) {
                var mpname = path.substring(0, path.lastIndexOf(".")) + ".maple"
                var jname = path.substring(0, path.lastIndexOf(".")) + ".json"
                var isExist = fileOp.isExist(mpname)
                var jisExist = fileOp.isExist(jname)
                if (!isExist && !jisExist && autoLabelEnable) {
                    root.setTimeout(function() {
                        popup.open()
                        popup.text = "Current data is being processed..."
                    }, 0)
                    root.setTimeout(function() {
                        autoLabel.run(path)
                        popup.close()
                        canvas.source = path
                    }, 10)
                    
                } else {
                    canvas.source = path
                }
            })

            var ctx = fileOp.readFile("_internal/conf/settings.json", "rb", "utf-8")
            root.mapleSettings = JSON.parse(ctx);
        }

        function setTimeout(callback, timeout){
            var timer = Qt.createQmlObject("import QtQuick; Timer {}", root);
            timer.interval = timeout;
            timer.repeat = false;
            timer.triggered.connect(callback);
            timer.start();
        }
    }


    Shortcut {
        sequence: "g"
        onActivated: {
            menu.selectMenuButton("group")
            var groupShape = canvas.createInst(MapleTool.ToolType.Group)
            if (!groupShape.merge()) {
                groupShape.destroy()
            }
        }
    }

    Shortcut {
        sequence: "Shift+g"
        onActivated: {
            menu.selectMenuButton("ungroup")
            for (var i in canvas.curActivatedInsts) {
                var inst = canvas.curActivatedInsts[i]
                if (inst.shapeType === "group") {
                    inst.split()
                }
            }
        }
    }

    Shortcut {
        sequences: ["del", "e"]
        onActivated: {
            menu.selectMenuButton("erase")
            var eraser = canvas.createInst(MapleTool.ToolType.Eraser)
            if (canvas.curActivatedInsts !== null) {
                eraser.deleteInsts(canvas.curActivatedInsts)
            }
            eraser.destroy()
        }
    }

    Shortcut {
        sequence: "r"
        onActivated: {
            menu.selectMenuButton("rect")
        }
    }

    Shortcut {
        sequence: "p"
        onActivated: {
            menu.selectMenuButton("point")
        }
    }

    Shortcut {
        sequence: "p", "o"
        onActivated: {
            menu.selectMenuButton("polygen")
        }
    }

    Shortcut {
        sequence: "s"
        onActivated: {
            menu.selectMenuButton("select")
        }
    }

    Shortcut {
        sequence: "Ctrl+s"
        onActivated: {
            canvas.saveData()
        }
    }

    Shortcut {
        sequence: "Ctrl+z"
        onActivated: {
            canvas.undo()
        }
    }

    Shortcut {
        sequence: "Ctrl+y"
        onActivated: {
            canvas.redo()
        }
    }

    Shortcut {
        sequence: "right" 
        onActivated: {
            filePanel.next()
        }
    }

    Shortcut {
        sequence: "left" 
        onActivated: {
            filePanel.last()
        }
    }

    Shortcut {
        sequence: "Ctrl+o"
        onActivated: filePanel.dialogOpen()
    }


}

