import json
import os
import numpy as np

def obb2poly_le90(rboxes):
    N = rboxes.shape[0]
    if N == 0:
        return rboxes.new_zeros((rboxes.size(0), 8))
    center, width, height, angle = np.split(rboxes, (2, 3, 4), axis=-1)
    tl_x, tl_y, br_x, br_y = \
        -width * 0.5, -height * 0.5, \
        width * 0.5, height * 0.5
    rects = np.stack([tl_x, br_x, br_x, tl_x, tl_y, tl_y, br_y, br_y],
                        axis=0).reshape(2, 4, N).transpose(2, 0, 1)
    sin, cos = np.sin(angle), np.cos(angle)
    M = np.stack([cos, -sin, sin, cos], axis=0).reshape(2, 2,
                                                          N).transpose(2, 0, 1)
    polys = np.matmul(M,rects).transpose(2, 1, 0).reshape(-1, N).transpose(1, 0)
    polys[:, ::2] += center[:,:1]
    polys[:, 1::2] += center[:,1:]
    return polys


root_dir = "D:/fisheye_pro_jht1129/fisheye_pro_jht1129"
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
                        x = shape["x"]
                        y = shape["y"]
                        h = shape["height"]
                        w = shape["width"]
                        angle = shape["rotation"] / 180 * np.pi
                        obj_type = shape["objType"]
                        if obj_type == "NULL":
                            obj_type = "Car"
                        cx = x + 0.5 * w
                        cy = y + 0.5 * h
                        rbox  = np.array([cx, cy, w, h, angle]).reshape(1, -1)
                        poly = obb2poly_le90(rbox)
                        str_res = ' '.join(str(i) for i in poly[0])
                        output = output + str_res + " " + obj_type + " 0\n"
                with open(output_path, "w") as f2:
                    f2.write(output)