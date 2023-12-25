import uuid
from psutil import net_if_addrs
import argparse
import base64
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QObject, Signal, Slot
import os
parser = argparse.ArgumentParser()

class WatchDog(QObject):
    
    def __init__(self):
        super().__init__()

    def gen_key(self, input_str):
        res = base64.b64encode(input_str.encode())
        with open("resource/watchdog.txt", "wb") as f:
            f.write(res)
            
    @Slot(str, result=bool)
    def verify(self, path):
        if not os.path.exists(path):
            return False
        with open(path, "rb") as f:
            ctx = f.readline()
        try:
            ctx = base64.b64decode(ctx).decode()
        except:
            return False    
        for k, v in net_if_addrs().items():
            for item in v:
                address = item[1]
                if '-' in address and len(address)==17:
                    if ctx == address:
                        return True
        return False
    
    
    

if __name__ == "__main__":
    parser.add_argument('input', type=str, help='display an integer')
    args = parser.parse_args()
    watchdog = WatchDog()
    watchdog.gen_key(args.input)
    


