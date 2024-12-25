package net.ipv64.kivop.services

import android.content.Context
import java.lang.ref.WeakReference

object StringProvider {

  private var contextRef: WeakReference<Context>? = null
  
  fun initialize(context: Context) {
    contextRef = WeakReference(context.applicationContext)
  }

  fun getString(resId: Int): String {
    val context = contextRef?.get()
    if (context == null) {
      throw IllegalStateException("StringProvider is not initialized. Call initialize() first.")
    }
    return context.getString(resId)
  }
}

