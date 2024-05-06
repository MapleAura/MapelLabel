# This Python file uses the following encoding: utf-8
import os
import sys
sys.path.append("./")
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from source.python import file_io, auto_label, base_info
from source.qml.MapleLabel import res
from source.qml.MapleCommon import res
from source.qml.MapleCanvas import res

if __name__ == "__main__":
    os.environ['QML_IMPORT_PATH']= "qrc:/"
    app = QGuiApplication(sys.argv)
    app.setApplicationName("MapleLabel")
    app.setOrganizationName("Maple")
    app.setOrganizationDomain("com.maple")
    engine = QQmlApplicationEngine()
    
    file_op = file_io.File()
    auto_label = auto_label.AutoLabel()
    baseinfo = base_info.BaseInfo()
    engine.rootContext().setContextProperty("fileOp", file_op)
    engine.rootContext().setContextProperty("autoLabel", auto_label)
    engine.rootContext().setContextProperty("baseInfo", baseinfo)
    # engine.load(os.fspath(Path(__file__).resolve().parent / "source/qml/MapleLabel/Controls/MapleLabel.qml"))
    engine.load("qrc:/MapleLabel/Controls/MapleLabel.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())