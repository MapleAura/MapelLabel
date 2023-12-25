import QtQuick 
import QtQuick.Window 
import QtQuick.Layouts 
import QtQuick.Dialogs 
import QtQuick.Controls.Fusion

Item {
    property int textHeight: 20
    property var listModel
    property int curIndex: -1
    property string currentItem
    property bool clickEnable: false
    property alias color: shape.color
    //property alias borderColor: shape.border.color
    Rectangle {
        id: shape
        anchors.fill: parent
        // border.color: "#282828"
    }
    
    
    // anchors.margins:5
    clip: true
    id: root 
    width: parent.width
    ListView {
        id : labelsListView
        
        anchors.fill:parent
        anchors.topMargin: 2
        spacing:1     
        model: listModel
        focus: true     
        delegate: delegate
        Component.onCompleted: {
            labelsListView.currentIndex = -1;
        }
        
        onModelChanged: {
            contentY = curIndex
            labelsListView.currentIndex = curIndex
        }
    }

    Component {
        id: delegate
        Rectangle {
            height: textHeight
            width : labelsListView.width
            color :"transparent"
            MouseArea {
                anchors.fill: parent
                Rectangle {
                    anchors.fill:parent
                    color: labelsListView.currentIndex === index ? "#565656" : "transparent"
                }
                onClicked: {
                    if (clickEnable) {
                        curIndex = index;
                    }
                }

                onDoubleClicked: {
                    if(clickEnable) {
                        currentItem = model.value
                    }
                }
            }

            Text {
                color: "White Smoke"
                leftPadding: 8
                text: model.value
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12
            }
        }
    } 
    onCurIndexChanged:{
        labelsListView.currentIndex = curIndex
    }
}



