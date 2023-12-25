from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QObject, Signal, Slot
import os 
import base64


def encrypt(data):
    return base64.b64encode(data)


def decrypt(encrypted_data):
    return base64.b64decode(encrypted_data)


class File(QObject):
    def __init__(self):
        super().__init__()
        
    @Slot(str, str, str, str)
    def saveFile(self, path, ctx, mode="w", encry="base64"):
        if "file:///" in path:
            path = path.replace("file:///", "")

        with open(path, mode) as f:
            if encry == "base64" :
                ctx = encrypt(ctx)
            elif encry == "utf-8":
                ctx = ctx.encode('utf8')
            else:
                print("unsupport!")
                
            f.write(ctx)
            
    @Slot(str, str, str, result=str)
    def readFile(self, path, mode="r", decry="base64"):
        if "file:///" in path:
            path = path.replace("file:///", "")
        
        if not os.path.exists(path):
            return None
        with open(path, mode) as f:           
            ctx = f.read()
            if decry == "base64":              
                ctx = decrypt(ctx)
            elif decry == "utf-8":
                ctx = ctx.decode('utf8')
            elif decry == "base64_utf-8":
                ctx = decrypt(ctx)
                ctx = ctx.decode('utf8')
            else:
                pass
            return ctx
    
    @Slot(str, result=bool)
    def isExist(self, path):
        if "file:///" in path:
            path = path.replace("file:///", "")
        if os.path.exists(path):
            return True
        else:
            return False