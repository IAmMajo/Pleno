package net.ipv64.kivop.services

import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

fun checkAndRequestPermissions(activity: Activity) {
  if (ContextCompat.checkSelfPermission(
      activity, android.Manifest.permission.ACCESS_FINE_LOCATION) !=
      PackageManager.PERMISSION_GRANTED ||
      ContextCompat.checkSelfPermission(
          activity, android.Manifest.permission.ACCESS_COARSE_LOCATION) !=
          PackageManager.PERMISSION_GRANTED) {
    ActivityCompat.requestPermissions(
        activity,
        arrayOf(
            android.Manifest.permission.ACCESS_FINE_LOCATION,
            android.Manifest.permission.ACCESS_COARSE_LOCATION),
        100)
  }
}
