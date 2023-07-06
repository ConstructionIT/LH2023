import base64
import io
import json
import os

import cv2
import albumentations as A

import torch

from torchvision import models
from torchvision import transforms as T

from PIL import Image

from django.shortcuts import render
from django.conf import settings

from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import SegImg
from .serializers import SegImgSerializer

# Create your views here.

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

model = torch.load('/home/enfycius/Documents/LH_Dataset/Semantic_Segmentation/models/UNet-Mobilenet_v2.pt')

model.to(device)

model.eval()

def transform_image(img_bytes, mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]):
    img_transforms = T.Compose([A.Resize(768, 1152, interpolation=cv2.INTER_NEAREST)])
    aug = img_transforms(image = img_bytes)
    img = Image.fromarray(aug['image'])

    t = T.Compose([T.ToTensor(), T.Normalize(mean, std)])
    img = t(img)

    img = img.to(device)

    return img.unsqueeze(0)

def predict_image(img):
    with torch.no_grad():
        output = model(img)
        masked = torch.argmax(output, dim=1)
        masked = masked.cpu().squeeze(0)

    return masked
    
@api_view(['POST'])
def index(request):
    serializer = SegImgSerializer(data=request.data)

    if serializer.is_valid():
        print(serializer.data)
    else:
        return Response({"status": "error", "data": serializer.errors})

