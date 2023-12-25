#!/usr/bin/env python
#-*- coding:utf-8 -*-
import os
from PySide6.QtQml import QQmlApplicationEngine

def init(engine:QQmlApplicationEngine):
    current_module_path = os.path.dirname(os.path.abspath(__file__))+"/qml"
    engine.addImportPath(current_module_path)