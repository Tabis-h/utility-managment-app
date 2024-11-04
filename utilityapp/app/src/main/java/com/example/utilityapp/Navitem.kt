package com.example.utilityapp

import android.graphics.drawable.Icon
import androidx.compose.ui.graphics.vector.ImageVector
import com.google.protobuf.DescriptorProtos.FieldDescriptorProto.Label

data class Navitem(
    val label: String,
    val icon: ImageVector,
    val badgeCount : Int ,
)
