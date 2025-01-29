package net.ipv64.kivop.services

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.compose.ui.platform.LocalContext
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

// Function to check and request permissions
fun checkAndRequestPermissions(
  context: Context,
  permission: String,
  permissionLauncher: ActivityResultLauncher<String>
): Boolean {
  return when {
    ContextCompat.checkSelfPermission(context, permission) == android.content.pm.PackageManager.PERMISSION_GRANTED -> {
      // Permission is already granted
      true
    }
    else -> {
      // Request the permission
      permissionLauncher.launch(permission)
      false
    }
  }
}