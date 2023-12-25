import QtQuick 
import QtQuick.Controls 

Item {
    id: root

    anchors.fill:parent
    property var control: parent
    property int borderWidth: 6
    property int minWidth: 0
    property int minHeight: 0

    MapleDrager {
        id: leftTopHandle
        mouseCursorShape: Qt.SizeFDiagCursor
        width: borderWidth
        height: borderWidth
        onPosChanged: function(xOffset, yOffset) {
            if (control.width - xOffset > minWidth) {
                control.width-= xOffset;
                if (control.x + xOffset < control.x + control.width) {
                    control.x += xOffset;
                }
                
            } 
                  
            if (control.height -yOffset > minHeight) {
                control.height -= yOffset;
                if (control.y + yOffset < control.y + control.height) {
                    control.y += yOffset;
                }
                
            }
        }
    }

    MapleDrager {
        id: rightTopHandle
        mouseCursorShape: Qt.SizeBDiagCursor
        x: parent.width - width
        width: borderWidth
        height: borderWidth
        onPosChanged: function(xOffset, yOffset){

            if (control.width + xOffset > minWidth)
                control.width += xOffset;
            
            if (control.height - yOffset > minHeight) {
                control.height -= yOffset;
                if (control.y + yOffset < control.y + control.height) {
                    control.y += yOffset;   
                }
            }
            
                
        }
    }

    MapleDrager {
        id: leftBottomHandle
        mouseCursorShape: Qt.SizeBDiagCursor
        y: parent.height - height
        width: borderWidth
        height: borderWidth
        onPosChanged: function(xOffset, yOffset){            
            if (control.width - xOffset > minWidth) {
                control.width-= xOffset;
                if (control.x + xOffset < control.x + control.width) {
                    control.x += xOffset;
                }           
            }  
            if (control.height + yOffset > minHeight) {
                control.height += yOffset;
            }                
        }
    }

    MapleDrager {
        id: rightBottomHandle
        mouseCursorShape: Qt.SizeFDiagCursor
        x: parent.width - width
        y: parent.height - height
        width: borderWidth
        height: borderWidth
        onPosChanged: function(xOffset, yOffset){
            if (control.width + xOffset > minWidth)
                control.width += xOffset;
            if (control.height + yOffset > minHeight)
                control.height += yOffset;
        }
    }

    MapleDrager {
        mouseCursorShape: Qt.SizeVerCursor
        width: parent.width - leftTopHandle.width - rightTopHandle.width
        height: borderWidth
        x: leftBottomHandle.width
        onPosChanged: function(xOffset, yOffset){
            
            if (control.height - yOffset > minHeight) {
                control.height -= yOffset;
                if (control.y + yOffset < control.y + control.height) {
                    control.y += yOffset;
                }               
            }
                
        }
    }

    MapleDrager {
        mouseCursorShape: Qt.SizeHorCursor
        height: parent.height - leftTopHandle.height - leftBottomHandle.height
        width: borderWidth

        y: leftTopHandle.height
        onPosChanged: function(xOffset, yOffset){
            
            if (control.width - xOffset > minWidth) {
                control.width-= xOffset;
                if (control.x + xOffset < control.x + control.width) {
                    control.x += xOffset;
                }

            }
                
        }
    }

    MapleDrager {
        mouseCursorShape: Qt.SizeHorCursor
        x: parent.width - width
        height: parent.height - rightTopHandle.height - rightBottomHandle.height
        width: borderWidth

        y: rightTopHandle.height
        onPosChanged: function(xOffset, yOffset){
            if (control.width + xOffset > minWidth)
                control.width += xOffset;
        }
    }

    MapleDrager {
        mouseCursorShape: Qt.SizeVerCursor
        x: leftBottomHandle.width
        y: parent.height - height
        width: parent.width - leftBottomHandle.width - rightBottomHandle.width
        height: borderWidth
        onPosChanged: function(xOffset, yOffset){
            if (control.height + yOffset > minHeight)
                control.height += yOffset;
        }
    }
}
