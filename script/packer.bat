pyside6-rcc .\source\qml\MapleLabel\res.qrc -o .\source\qml\MapleLabel\res.py
pyside6-rcc .\source\qml\MapleCommon\res.qrc -o .\source\qml\MapleCommon\res.py
pyside6-rcc .\source\qml\MapleCanvas\res.qrc -o .\source\qml\MapleCanvas\res.py
python .\source\python\enctry.py
pyinstaller  .\app.py -i logo.ico -w -n MapleLabel --add-data=".\conf\*;.\conf"