import QtQuick
import QtQuick.Controls

Item {
    property alias text: output.text
    property alias color: output.color
    height: 10
    Text {
        id: output
        font.family: "Helvetica"
        font.pointSize: 8
        visible: true
        text: ""
        color: "green"
        onTextChanged: {
            timer.stop()
            timer.interval = 3000
            timer.start()
        }

    }

    Timer {
        id: timer;
        interval: 3000;          //间隔1s
        running: true;         //开启，则立即启动
        repeat: false             //开启循环
        triggeredOnStart: false;  //启动后，将立即触发一次
        onTriggered: {
            output.text = ""
           
        }
    }

}