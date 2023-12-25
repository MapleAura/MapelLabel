import cv2
import numpy as np
from .mpcv import *
from .base import registry
import os 
import json
from io import BytesIO
from .file_io import File

@registry.register('rtmdet')
class Rtmdet():
    def __init__(self, ctx) -> None:
        super().__init__()
        file = File()
        model_bytes = file.readFile(ctx["path"], "rb", "base64")
        # model_stream = BytesIO(model_bytes)
        self.sess = rt.InferenceSession(model_bytes, providers=['CPUExecutionProvider'])
        self.means = ctx["means"]
        self.stds = ctx["stds"]
        self.pre_nms_num = ctx["pre_nms_num"]
        self.conf = ctx["conf"]
        self.nms_threshold = ctx["nms_threshold"]
        self.obj_type = ctx["obj_type"]
        
    def __call__(self, path):
        if "file:///" in path:
            path = path.replace("file:///", "")
        ori_img = cv2.imread(path)
        input_data = preproc_stdmean(ori_img, self.means, self.stds)
        result = self.sess.run(None, {"input": input_data})
        filter_result = filter_scores_and_topk(result, self.conf, self.pre_nms_num)
        
        dets, scores, labels, keep_idxs  = filter_result
        adets = arc2angle(dets)
        keep = nms_rotate(adets, scores, self.nms_threshold, self.pre_nms_num)
        dets = dets[keep]
        labels = labels[keep]
        polys = obb2poly_le90(dets)  
        dets_hbb = obb2hbb(dets)
        ext = os.path.splitext(path)
        self.serialize(dets_hbb, labels, ext[0] + ".maple") 
        
    def serialize(self, dets, labels, output_path):
        res = {}
        res["version"] = "1.0.1"
        shapes_res = []
        for i, det in enumerate(dets):
            det_res = {}
            det_res["type"] = "rect"
            det_res["x"] = det[0]
            det_res["y"] = det[1]
            det_res["width"] = det[2]
            det_res["height"] = det[3]
            det_res["rotation"] = det[4]
            det_res["objType"] = self.obj_type[labels[i]]
            shapes_res.append(det_res)
        res["shapes"] = shapes_res
        json_dict = json.dumps(res)
        with open(output_path, "w", encoding='utf-8') as f:
            f.write(json_dict)

        
        