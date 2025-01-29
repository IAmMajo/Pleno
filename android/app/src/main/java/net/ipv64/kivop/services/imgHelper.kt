package net.ipv64.kivop.services

import android.content.ContentResolver
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import android.util.Log
import androidx.core.content.FileProvider
import java.io.File
import java.io.InputStream

fun uriToBase64String(context: Context, uri: Uri): String? {
  return try {
    // Open input stream from the URI
    val inputStream: InputStream = context.contentResolver.openInputStream(uri)!!

    // Convert InputStream to ByteArray
    val byteArray = inputStream.readBytes()

    // Encode the ByteArray in Base64 and return it as a String
    Base64.encodeToString(byteArray, Base64.NO_WRAP)
  } catch (e: Exception) {
    e.printStackTrace()
    null
  }
}

fun uriToBitmap(contentResolver: ContentResolver, uri: Uri): Bitmap? {
  return try {
    val inputStream: InputStream? = contentResolver.openInputStream(uri)
    BitmapFactory.decodeStream(inputStream)
  } catch (e: Exception) {
    e.printStackTrace()
    null
  }
}

fun base64ToBitmap(base64String: String): Bitmap? {
  Log.i("base64ToBitmap", "Converting Base64 string to Bitmap")
  return try {
    // Decode Base64 string into a byte array
    val decodedBytes = Base64.decode(base64String, Base64.NO_WRAP)
    // Convert byte array into Bitmap
    BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
  } catch (e: Exception) {
    e.printStackTrace()
    null
  }
}

fun encodeImageToBase64(imageByteArray: ByteArray?): String? {
  if (imageByteArray == null) {
    return null
  }
  return Base64.encodeToString(imageByteArray, Base64.NO_WRAP)
}

fun decodeFromBase64(base64String: String): ByteArray {
  return Base64.decode(base64String, Base64.NO_WRAP)
}

fun createTempUri(context: Context): Uri {
  val tempFile = File(context.cacheDir, "photo_${System.currentTimeMillis()}.jpg")
  return FileProvider.getUriForFile(context, "${context.packageName}.provider", tempFile)
}