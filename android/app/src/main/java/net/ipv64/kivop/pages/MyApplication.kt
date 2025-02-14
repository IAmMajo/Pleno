package net.ipv64.kivop.pages

import android.app.Application
import android.content.Context
import coil3.ImageLoader
import coil3.SingletonImageLoader
import coil3.request.crossfade
import net.ipv64.kivop.services.AuthController
import net.ipv64.kivop.services.StringProvider

class MyApplication : Application(), SingletonImageLoader.Factory {
  override fun newImageLoader(context: Context): ImageLoader {
    return ImageLoader.Builder(context).crossfade(true).build()
  }

  lateinit var authController: AuthController

  override fun onCreate() {
    super.onCreate()
    StringProvider.initialize(applicationContext)
    authController = AuthController(applicationContext)
  }

  companion object {
    @JvmStatic
    lateinit var instance: MyApplication
      private set
  }

  init {
    instance = this
  }
}
