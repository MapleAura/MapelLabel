from PySide6.QtCore import  QObject,  Slot
import onnxruntime as rt
import json
from PIL import Image
from .simple_tokenizer import SimpleTokenizer as Tokenizer
from .ops import non_max_suppression, xyxy2xywh
import numpy as np
from .base_info import version
class AutoLabel(QObject):
    def __init__(self) -> None:
        super().__init__()
        self.engine = None
        
    @Slot()
    def create(self):
        self.yolo = rt.InferenceSession("_internal/resource/yolov8x-worldv2.onnx", providers=['CPUExecutionProvider'])
        # Load a pretrained YOLOv8s-worldv2 model
        self.clip = rt.InferenceSession("_internal/resource/clip.onnx", providers=['CPUExecutionProvider'])
        

    @Slot(list)    
    def set_classes(self, props):
        print(props)
        self.classes = props
        self.get_token()
        
    @Slot(str)    
    def set_classes(self, props):
        props = props.split(",")
        self.classes = props
        if isinstance(self.classes, str):
            self.classes = [self.classes]
        self.get_token()
        
    def get_token(self):
        text_token = self.tokenize(self.classes)
        self.txt_feats = [self.clip.run(["output"], {"input": token.reshape(1,-1)}) for token in text_token]
        self.txt_feats = self.txt_feats[0] if len(self.txt_feats) == 1 else np.concatenate(self.txt_feats, axis=0)
        norm = np.linalg.norm(self.txt_feats, ord=2, axis=-1, keepdims=True)
        self.txt_feats = self.txt_feats / norm
        self.txt_feats = self.txt_feats.reshape(-1, len(self.classes), self.txt_feats.shape[-1])
        
        
    def tokenize(self, texts, context_length: int = 77, truncate: bool = False):

        _tokenizer = Tokenizer()
        
        if isinstance(texts, str):
            texts = [texts]

        sot_token = _tokenizer.encoder["<|startoftext|>"]
        eot_token = _tokenizer.encoder["<|endoftext|>"]
        all_tokens = [[sot_token] + _tokenizer.encode(text) + [eot_token] for text in texts]
        result = np.zeros((len(all_tokens), context_length), dtype=np.int32)
        

        for i, tokens in enumerate(all_tokens):
            if len(tokens) > context_length:
                if truncate:
                    tokens = tokens[:context_length]
                    tokens[-1] = eot_token
                else:
                    raise RuntimeError(f"Input {texts[i]} is too long for context length {context_length}")
            result[i, :len(tokens)] = tokens
        return result
    
    def pad_image_to_multiples_of_32(self, image_path, padding_color=(114, 114, 114)):

        # 打开图片
        image = Image.open(image_path)
        width, height = image.size

        # 计算新的宽度和高度，使之成为 32 的倍数
        new_width = ((width - 1) // 32 + 1) * 32
        new_height = ((height - 1) // 32 + 1) * 32

        # 如果原始尺寸已经是 32 的倍数，则不需要修改
        if new_width == width and new_height == height:
            return image

        # 创建新的图片，背景为 padding_color
        padded_image = Image.new('RGB', (new_width, new_height), color=padding_color)
        padded_image.paste(image, (0, 0))  # 原始图片粘贴到新图片的左上角
        return padded_image
        
    @Slot(str,  str, result=str)
    def run(self, path, output_path):
        if "file:///" in path:
            path = path.replace("file:///", "")
        images = self.pad_image_to_multiples_of_32(path)
        images = np.expand_dims(images, axis=0)
        preds = self.yolo.run(["output0"], {"images": images, "txt_feats":self.txt_feats})
        # preds = np.transpose(preds[0], (0,2,1))
        # preds = [preds[preds[..., 4] > 0.25]]
        # print(preds[0].shape)
        preds = non_max_suppression(preds, 0.25, 0.7, agnostic=False, max_det=300, classes=None)
        self.serialize(preds, output_path)
            
    def serialize(self, dets, output_path):
        res = {}
        res["version"] = version
        shapes_res = []
        for i, det in enumerate(dets):
            for j, r in enumerate(det):
                
                xyxy = r[0:4]
                xywh = xyxy2xywh(xyxy)
                det_res = {}
                det_res["type"] = "rect"
                det_res["x"] = float(xyxy[0])
                det_res["y"] = float(xyxy[1])
                det_res["width"] = float(xywh[2])
                det_res["height"] = float(xywh[3])
                det_res["rotation"] = 0.0
                det_res["objType"] = self.classes[int(r[5])]
                shapes_res.append(det_res)
       
        res["shapes"] = shapes_res
        json_dict = json.dumps(res)
        with open(output_path.replace("file:///", ""), "w", encoding='utf-8') as f:
            f.write(json_dict)
    
    