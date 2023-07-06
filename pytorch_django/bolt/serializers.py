from rest_framework import serializers
from .models import SegImg

class SegImgSerializer(serializers.ModelSerializer):
    class Meta:
        model = SegImg
        fields = ('image')