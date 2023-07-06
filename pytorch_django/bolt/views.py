import base64
import io
import json
import os

import cv2
import numpy as np
import albumentations as A

import torch

from torchvision import models
from torchvision import transforms as T

from pathlib import Path

from PIL import Image

from django.shortcuts import render
from django.conf import settings

from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import SegImg
from .serializers import SegImgSerializer

import matplotlib.pyplot as plt

import uuid

# Create your views here.

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

model = torch.load('/home/enfycius/Documents/LH_Dataset/Semantic_Segmentation/models/UNet-Mobilenet_v2.pt')

model.to(device)

model.eval()

def transform_image(img, mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]):
    img_transforms = A.Compose([A.Resize(768, 1152, interpolation=cv2.INTER_NEAREST)])
    aug = img_transforms(image = img)
    img = Image.fromarray(aug['image'])

    ori = img

    t = T.Compose([T.ToTensor(), T.Normalize(mean, std)])
    
    img = t(img)
    img = img.to(device)

    return [img.unsqueeze(0), ori]

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
        img = request.FILES['image'].read()

        img = cv2.imdecode(np.frombuffer(img, np.uint8), cv2.IMREAD_UNCHANGED)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        img, ori = transform_image(img)
        masked = predict_image(img)

        img = ori

        fig = plt.figure()

        plt.imshow(img)
        plt.imshow(masked, alpha=0.6)

        path = str(settings.BASE_DIR) + '/media/' + str(uuid.uuid4()) + '.png'

        fig.savefig(Path(path))

        return Response({"status": "success", "data": settings.SERVER_IP_PORT + '/media/' + os.path.split(path)[1]})
    else:
        return Response({"status": "error", "data": serializer.errors})

