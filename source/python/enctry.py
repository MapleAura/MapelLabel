import file_io
import os
if __name__ == "__main__":
    file = file_io.File()
    folder = os.path.exists("resource")
    if not folder:                  
        os.makedirs("resource")
    for parent, dirnames, filenames in os.walk("models"): 
        for filename in filenames:
            if ".json" in filename:
                ctx = file.readFile(os.path.join(parent, filename), "rb", "")
                file.saveFile(os.path.join("resource", filename), ctx, "wb", "base64")
            if ".onnx" in filename:
                ctx = file.readFile(os.path.join(parent, filename), "rb", "")
                file.saveFile(os.path.join("resource", filename.replace(".onnx", ".bin")), ctx, "wb", "base64")