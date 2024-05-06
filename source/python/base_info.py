from PySide6.QtCore import QObject, Slot

version = "1.0.5"

class BaseInfo(QObject):
    def __init__(self):
        super().__init__()
        self._version = version
    
    @Slot(result=str)
    def get_version(self):
        return self._version