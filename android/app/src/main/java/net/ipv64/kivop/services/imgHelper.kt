package net.ipv64.kivop.services

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
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

fun byteArrayToBitmap(byteArray: ByteArray): Bitmap? {
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