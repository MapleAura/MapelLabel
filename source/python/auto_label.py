from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QObject, Signal, Slot
import json
import cv2
from .rtmdet import Rtmdet
from .base import registry

class AutoLabel(QObject):
    def __init__(self) -> None:
        super().__init__()
        self.engine = None
        
    @Slot(str)
    def create(self, ctx):
        ctx = json.loads(ctx)
        mpcls = registry.get_class(ctx["class"])
        self.engine = mpcls(ctx)
   
        
    @Slot(str, result=str)
    def run(self, path):
        if self.engine != None:
            self.engine(path)
        