package net.ipv64.kivop.services

import android.content.ContentResolver
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import android.util.Log
import java.io.InputStream

fun uriToByteArray(context: Context, uri: Uri): ByteArray? {
  try {
    // Open input stream from the URI
    val inputStream: InputStream = context.contentResolver.openInputStream(uri)!!

    // Convert InputStream to ByteArray
    val byteArray = inputStream.readBytes()

    // Encode the ByteArray in Base64
    return Base64.encodeToString(byteArray, Base64.NO_WRAP).toByteArray()
  } catch (e: Exception) {
    e.printStackTrace()
    return null
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

fun byteArrayToBitmap(byteArray: ByteArray): Bitmap? {
  Log.i("byteArrayToBitmap", "byteArrayToBitmap")
  return try {
    // Decode Base64 string into a byte array
    val decodedString = Base64.decode(byteArray.decodeToString(), Base64.NO_WRAP)
    // Convert byte array into Bitmap
    BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
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
