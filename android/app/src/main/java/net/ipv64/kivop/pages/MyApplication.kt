// MIT No Attribution
//
// Copyright 2025 KIVoP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
