# This Python file uses the following encoding: utf-8
import os
from pathlib import Path
import sys
sys.path.append("./")
from typing import Optional
import fnmatch
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QObject, Signal, Slot
from source.python import file_io, auto_label, watchdog
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
    watchdog = watchdog.WatchDog()
    engine.rootContext().setContextProperty("fileOp", file_op)
    engine.rootContext().setContextProperty("autoLabel", auto_label)
    engine.rootContext().setContextProperty("watchDog", watchdog)
    # engine.load(os.fspath(Path(__file__).resolve().parent / "source/qml/MapleLabel/Controls/MapleLabel.qml"))
    engine.load("qrc:/MapleLabel/Controls/MapleLabel.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())