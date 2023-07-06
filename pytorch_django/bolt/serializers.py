from rest_framework import serializers
from bolt.models import SegImg

class SegImgSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=False)

    class Meta:
        model = SegImg
        fields = ('image', )