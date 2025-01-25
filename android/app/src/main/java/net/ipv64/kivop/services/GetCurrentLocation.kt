package net.ipv64.kivop.services

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.util.Log
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.tasks.CancellationTokenSource

@SuppressLint("MissingPermission")
fun getCurrentLocation(context: Context, onLocationReceived: (Location?) -> Unit) {
  // Check if permissions are granted
  if (ContextCompat.checkSelfPermission(
      context, android.Manifest.permission.ACCESS_FINE_LOCATION) ==
      PackageManager.PERMISSION_GRANTED ||
      ContextCompat.checkSelfPermission(
          context, android.Manifest.permission.ACCESS_COARSE_LOCATION) ==
          PackageManager.PERMISSION_GRANTED) {

    // Permissions are granted, proceed with location retrieval
    val fusedLocationClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(context)

    fusedLocationClient
        .getCurrentLocation(
            com.google.android.gms.location.Priority.PRIORITY_HIGH_ACCURACY,
            CancellationTokenSource().token)
        .addOnSuccessListener { location: Location? ->
          if (location != null) {
            onLocationReceived(location)
          } else {
            Log.e("Location", "Failed to retrieve location")
            onLocationReceived(null)
          }
        }
        .addOnFailureListener {
          Log.e("Location", "Location retrieval failed: ${it.message}")
          onLocationReceived(null)
        }
  } else {
    // If permissions are not granted, request them
    checkAndRequestPermissions(context as Activity)
  }
}
