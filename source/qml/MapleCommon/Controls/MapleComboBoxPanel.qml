import QtQuick 
import QtQuick.Layouts 
import QtQuick.Dialogs 
import QtQuick.Controls.Fusion

Item {
    id: root 
    property int textHeight : 18 
    property int itemCount: 0
    property var boxComp: null
    property var textComp: null

    // format: example
    // {"allItems":[{"key":"objType","value":["NULL","Car","Pedestrian","Cyclist","Van","Truck","Bus","Animal","Other"]}],
    // "curSelectedItems":[{"key":"objType","value":"NULL"}]}
    property var extraParamsIn: null
    property var extraParamsOut: {}
    anchors.margins:5
    height: itemCount * textHeight
    width: parent.width
    property var curItem: null
        
    Component {
        id: dynamicComponent
        Rectangle {
            
            width: root.width
            color: "transparent"
            property var count: 0
            property var params: []
            function reviseParams() {
                var pData = []
                for (var i in params) {
                    var param = params[i]
                    var revisedItem = {}

                    //revise show text
                    param.curDisplayValue = param.curItemValue
                    revisedItem["key"] = param.showText
                    revisedItem["value"] = param.curItemValue
                    pData.push(revisedItem)
                }
                
                root.extraParamsOut = pData
            }
        }
    }

    function render() {
        if (extraParamsIn === null || extraParamsIn === undefined) {
            return 
        }
        
        if (curItem !== null) {
            curItem.destroy()
        }

        var allItems = extraParamsIn.allItems
        if(allItems === undefined) {
            return 
        }
        var curSelectedItems = extraParamsIn.curSelectedItems

        curItem = dynamicComponent.createObject(root);
        itemCount = allItems.length
        for (var i = 0; i < allItems.length; i++) {
            
            var item = allItems[i]
            if (item.value.length > 0) {
                var obj = boxComp.createObject(curItem)
                obj.showText = item.key
                obj.showModel = item.value
                obj.count = item.value.length
                obj.valueChanged.connect(curItem.reviseParams)

                for (var j = 0; j < curSelectedItems.length; j++) {
                    if (curSelectedItems[j].key === item.key) {
                        
                        obj.curDisplayValue = curSelectedItems[j].value
                    }
                }
                
            } else {
                var obj = textComp.createObject(curItem)
                obj.showText = item.key
                obj.valueChanged.connect(curItem.reviseParams)
                for (var j = 0; j < curSelectedItems.length; j++) {
                    if (curSelectedItems[j].key === item.key) {
                        
                        obj.curItemValue = curSelectedItems[j].value
                    }
                }
            }
            curItem.params.push(obj)
            
        }
        var childList = curItem.children
        for (var i = 1; i < childList.length; i++) {
            var lastChild = childList[i-1]
            var curChild = childList[i]
            curChild.anchors.top = lastChild.bottom
        }
        
    }

    onExtraParamsInChanged: {
                
        render()  
        // var isExist = false
        // for (var i in root.children) {
        //     var curRect = root.children[i]
        //    if(curRect.key === extraParamsIn.key) {
        //         root.children[i].visible = true
        //         isExist = true
        //         root.height = curRect.count * textHeight
        //         var configs = extraParamsIn.value
        //         // console.log(JSON.stringify(configs))
        //         for (var j in curRect.params) {
        //             var curItem = curRect.params[j]
        //             var showText = curItem.showText
        //             for (var k in configs) {
        //                 var config = configs[k]
        //                 if (config.key === showText) {
        //                     curItem.curDisplayValue = config.value
        //                 }
        //             }
        //         }
        //    } else {
        //         curRect.visible = false
        //    }
           
        // }
        // if(!isExist) {
        //     root.height = 0
        // }

    }

    Component.onCompleted: {
        boxComp = Qt.createComponent("MapleComboBoxItem.qml")
        if (boxComp.status !== Component.Ready) {console.log(boxComp.errorString())}

        textComp = Qt.createComponent("MapleTextField.qml")
        if (textComp.status !== Component.Ready) {console.log(textComp.errorString())}
        
    }

    function encodeUtf8(text) {
        const code = encodeURIComponent(text);
        const bytes = [];
        for (var i = 0; i < code.length; i++) {
            const c = code.charAt(i);
            if (c === '%') {
                const hex = code.charAt(i + 1) + code.charAt(i + 2);
                const hexVal = parseInt(hex, 16);
                bytes.push(hexVal);
                i += 2;
            } else bytes.push(c.charCodeAt(0));
        }
        return bytes;
    }

    function decodeUtf8(bytes) {
        var encoded = "";
        for (var i = 0; i < bytes.length; i++) {
            encoded += '%' + bytes[i].toString(16);
        }
        return decodeURIComponent(encoded);
    }
}
