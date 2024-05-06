import json
import os
import numpy as np

class_dict = {"Car":"0","Van":"1","Truck":"2","Bus":"3","Other":"4"}
color_dict = {"White":"0","Gray":"1","Yellow":"2","Pink":"3","Red":"4","Purple":"5","Green":"6","Blue":"7","Blown":"8","Black":"9"}

root_dir = "D:/debug"
for parent,dirnames,filenames in os.walk(root_dir): 
    for filename in filenames:
        if ".json" in filename:
            fname = filename.replace(".json", ".txt")
            output_path = os.path.join(parent, fname)
            with open(os.path.join(parent, filename)) as f:
                output = ""
                ctx = json.load(f)
                for shape in ctx["shapes"]:
                    if shape["type"] == "rect":
                        x = shape["x"] / 1069
                        y = shape["y"] / 500
                        h = shape["height"] / 500
                        w = shape["width"] / 1069
                        obj_type = shape["class"]
                        color = shape["color"]
                        cx = x + 0.5 * w
                        cy = y + 0.5 * h
                        output = output + class_dict[obj_type] + " " + color_dict[color] + " " + str(cx) + " " + str(cy) + " " + str(w) + " " + str(h) +"\n"
                with open(output_path, "w") as f2:
                    f2.write(output)