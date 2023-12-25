import onnxruntime as rt
import cv2
import numpy as np

def preproc_stdmean(ori_img, means, stds):
    img = ori_img.astype(np.float32, copy=False)
    img -= np.array(means)
    img /= np.array(stds)
    img = np.transpose(img, (2, 0, 1))
    img = np.expand_dims(img, axis=0)
    return img

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

def filter_scores_and_topk(results, score_thr, topk):
    dets = results[0].squeeze()
    scores = results[1].squeeze()
    valid_mask = scores > score_thr
    scores = scores[valid_mask]
    valid_idxs = np.nonzero(valid_mask)
    valid_idxs = np.stack(valid_idxs, axis=1)
    num_topk = min(topk, valid_idxs.shape[0])
    # torch.sort is actually faster than .topk (at least on GPUs)
    rscores = np.sort(scores)
    rscores = rscores[::-1]
    idxs = np.argsort(scores) 
    idxs = idxs[::-1]
    
    rscores = rscores[:num_topk]
    topk_idxs = valid_idxs[idxs[:num_topk]]
    keep_idxs, labels = topk_idxs[:, 0], topk_idxs[:, 1]
    dets = dets[keep_idxs]
    return dets, rscores, labels, keep_idxs

def nms_rotate(boxes, scores, iou_threshold, max_output_size):
    keep = [] #保留框的结果集合
    num = boxes.shape[0] #获取检测框的个数

    suppressed = np.zeros((num), dtype=np.int64)
    for i in range(num):
        # 若当前保留框集合中的个数大于max_output_size时，直接返回
        if len(keep) >= max_output_size:
            break

        # 对于抑制的检测框直接跳过
        if suppressed[i] == 1:
            continue
        keep.append(i) #保留当前框的索引
        #根据box信息组合成opencv中的旋转bbox
        r1 = ((boxes[i, 0], boxes[i, 1]), (boxes[i, 2], boxes[i, 3]), boxes[i, 4])
        #计算当前检测框的面积
        area_r1 = boxes[i, 2] * boxes[i, 3]
        #对剩余的而进行遍历
        for j in range(i + 1, num):
            if suppressed[i] == 1:
                continue
            r2 = ((boxes[j, 0], boxes[j, 1]), (boxes[j, 2], boxes[j, 3]), boxes[j, 4])
            area_r2 = boxes[j, 2] * boxes[j, 3]
            inter = 0.0
            #求两个旋转矩形的交集，并返回相交的点集合
            int_pts = cv2.rotatedRectangleIntersection(r1, r2)[1]
            if int_pts is not None:
                #求点集的凸边形
                order_pts = cv2.convexHull(int_pts, returnPoints=True)
                # 计算当前点集合组成的凸边形的面积
                int_area = cv2.contourArea(order_pts)
                #计算出iou
                inter = int_area * 1.0 / (area_r1 + area_r2 - int_area + 0.0000001)
            # 对大于设定阈值的检测框进行滤除
            if inter >= iou_threshold:
                suppressed[j] = 1
 
    return np.array(keep, np.int64)

def obb2hbb(rboxes):
    N = rboxes.shape[0]
    new_boxs = np.zeros((rboxes.shape[0], 5))
    if N == 0:
        return new_boxs
    center, width, height, angle = np.split(rboxes, (2, 3, 4), axis=-1)
    new_boxs[:,0] = center[:,0] - 0.5* width[:,0]
    new_boxs[:,1] = center[:,1] - 0.5* height[:,0]
    new_boxs[:,2] = width[:,0]
    new_boxs[:,3] = height[:,0]
    new_boxs[:,4] = angle[:,0] / np.pi * 180
    return new_boxs

def arc2angle(boxes):
    new_boxes = boxes.copy()
    new_boxes[:, 4] = new_boxes[:, 4] / np.pi * 180
    return new_boxes