import Qt.labs.folderlistmodel 2.1
import QtQuick 
import QtQuick.Window 
import QtQuick.Layouts 
import QtQuick.Dialogs 
import QtQuick.Controls.Fusion


Item {
    id: root 
    property int textHeight : 18 
    property bool dialogOpened: false
    signal selectedFlieChanged(string path)
    clip: true
    property alias color: shape.color

    
    //property alias borderColor: shape.border.color
    Rectangle {
        id: shape
        anchors.fill: parent
    }

    ListView {
        id : fileList
        anchors.fill: parent
        anchors.topMargin: 2
        property int previousIndex: -1
        property var curItem: null
        property var lastItem: null 
        spacing:2
        FolderListModel {
            id: folderModel
            nameFilters: ["*.jpg", "*.png"]
            folder: folderDialog.res
            showDirs: false

        }
        cacheBuffer: folderModel.count * 2
        focus: true
        model: folderModel      
        delegate: delegate

        
        onCurrentIndexChanged: {
            fileList.curItem = fileList.currentItem
            fileList.currentItem.callback()
        }

    }

    Component {
        id: delegate
        Rectangle {
            id: item
            height: textHeight
            width : fileList.width
            color :"transparent"
            property bool isExist: false
            MouseArea {
                anchors.fill: parent
                Rectangle {
                    anchors.fill:parent
                    color: fileList.currentIndex === index ? "#565656" : "transparent"
                }
                onClicked: {
                    fileList.currentIndex = index  
                }
            }


            Text {
                id: ctx
                color: isExist? "red": "White Smoke"
                leftPadding: 4
                text: fileName
            }

            Component.onCompleted: {
                fileExist()
            }

            function callback() {
                if (fileList.lastItem !== null) {
                    fileList.lastItem.fileExist()
                }
                selectedFlieChanged("file:///" + filePath)
                fileList.lastItem = fileList.curItem
                fileList.previousIndex = fileList.currentIndex
            }


            function fileExist() {
                
                var name = filePath.substring(0, filePath.lastIndexOf(".")) + ".json"
                isExist = fileOp.isExist(name)
            }
        }
    } 
    FolderDialog  {
        id :folderDialog
        rejectLabel: "Cancel"
        title: "Please select image folder"
        acceptLabel: "OK"
        property var res : ""
        onAccepted: {
            console.log("You chose: " + selectedFolder);
            res = selectedFolder
            dialogOpened = false
        }
        onRejected: {
            dialogOpened = false
            console.log("Canceled");
        }
    }

    onDialogOpenedChanged: {
        if (dialogOpened) {
            folderDialog.open()
        }
    }

    function next() {
        fileList.incrementCurrentIndex()
    }

    function last() {
        fileList.decrementCurrentIndex()
    }

    function dialogOpen() {
        folderDialog.open()
    }

}





