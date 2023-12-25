import QtQuick 
import QtQuick.Window 
import QtQuick.Controls.Fusion
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property alias text: textShow.text
    property bool isMaximized: false
    property alias logoSource: logo.source
    property alias color: titleBar.color
    property var mapleWindow: null
    Rectangle {
        id: titleBar
        property bool doubleClickedEnable:false
        anchors.fill: parent

        property real btnScale: 0.5
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            property point clickPos: "0, 0"

            onPressed: function(mouse) {
                if (mouse.button == Qt.LeftButton) {
                    clickPos = Qt.point(mouseX, mouseY)
                }
            }
            onPositionChanged: {
                if (!titleBar.doubleClickedEnable &&pressed) {
                    var mousePos = Qt.point(mouseX-clickPos.x, mouseY-clickPos.y)
                    mapleWindow.setX(mapleWindow.x+mousePos.x)
                    mapleWindow.setY(mapleWindow.y+mousePos.y)
                }
            }

            onDoubleClicked :{
                titleBar.doubleClickedEnable = true; 
                if(isMaximized){
                    isMaximized = false;
                    mapleWindow.showNormal();
                }else{
                    isMaximized = true;
                    mapleWindow.showMaximized();
                }
                titleBar.doubleClickedEnable = false;
            }

        }
        
        Image {
            id: logo
            anchors.left: parent.left
            anchors.leftMargin : 8
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height * 0.8
            height: parent.height * 0.8

            ColorOverlay{
                anchors.fill: parent
                color: "white"
                source: parent
            }
            mipmap:true
            smooth: true
        }

        Text {
            id: textShow
            width : parent.width
            height : parent.height
            color:"Seashell"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
        }

        Button{
            id:closeBtn
            anchors.right: parent.right
            width: parent.height
            height: parent.height - 1
            hoverEnabled : true
            background: Rectangle {
                color: closeBtn.hovered ? (closeBtn.pressed ? "#DE0000" : "#F91515") : "transparent"
                Image{
                    id: closeBtnImg
                    width: parent.height * titleBar.btnScale
                    height: parent.height * titleBar.btnScale
                    anchors.centerIn: parent
                    source: "qrc:/MapleCommon/Images/close.svg"
                    ColorOverlay{
                        anchors.fill: parent
                        color: "white"
                        source: parent
                    }
                    smooth: true
                }
            }
            onClicked: {
                mapleWindow.close()
            }
        }

        Button{
            id: maxBtn
            anchors.right: closeBtn.left
            width: parent.height
            height: parent.height - 1
            hoverEnabled : true
            background: Rectangle{
                color: maxBtn.hovered ? (maxBtn.pressed ? "#4E4E4E" : "#666666") : "transparent"
                //color: "black"
                Image{
                    id: maxBtnBg
                    width: parent.height * titleBar.btnScale
                    height: parent.height * titleBar.btnScale
                    anchors.centerIn: parent
                    source: "qrc:/MapleCommon/Images/max.svg"
                    ColorOverlay{
                        anchors.fill: parent
                        color: "white"
                        source: parent
                    }
                    smooth: true
                }
            }
            onClicked:{
                if (isMaximized) {                   
                    mapleWindow.showNormal();
                }   else {
                    mapleWindow.showMaximized();
                } 
                isMaximized = !isMaximized;                                      
            }
        }

        Button {
            id: minBtn
            anchors.right: maxBtn.left
            width: parent.height
            height: parent.height - 1
            hoverEnabled : true
            background: Rectangle{
                color: minBtn.hovered ? (minBtn.pressed ? "#4E4E4E" : "#666666") : "transparent"
                Image{
                    width: parent.height * titleBar.btnScale
                    height: parent.height * titleBar.btnScale
                    anchors.centerIn: parent
                    source: "qrc:/MapleCommon/Images/min.svg"
                    ColorOverlay{
                        anchors.fill: parent
                        color: "white"
                        source: parent
                    }
                    smooth: true
                }
            }
            onClicked:{
                mapleWindow.showMinimized();
            }
        }
    }
}

