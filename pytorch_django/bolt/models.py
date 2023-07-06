from django.db import models

# Create your models here.

class SegImg(models.Model):
    image = models.ImageField(default='media/test.jpg', upload_to="%Y/%m/%d")

