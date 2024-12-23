package net.ipv64.kivop

import android.annotation.SuppressLint
import android.app.Application
import androidx.lifecycle.ViewModelProvider.NewInstanceFactory.Companion.instance
import net.ipv64.kivop.services.AuthController

class MyApplication : Application() {
  lateinit var authController: AuthController

  override fun onCreate() {
    super.onCreate()
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