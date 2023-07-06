from django.db import models

# Create your models here.

class SegImg(models.Model):
    image = models.ImageField(upload_to="uploads/")

