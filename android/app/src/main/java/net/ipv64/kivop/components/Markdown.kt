package net.ipv64.kivop.components

import android.widget.TextView
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import io.noties.markwon.Markwon

@Composable
fun Markdown(
    modifier: Modifier = Modifier,
    markdown: String = "",
    backgroundColor: Color = Color.Gray,
    fontColor: Color = Color.Black
) {
  val context = LocalContext.current
  val markwon = Markwon.create(context)

  Box(
      modifier =
          modifier
              .wrapContentHeight()
              .background(
                  color = backgroundColor,
                  shape = RoundedCornerShape(16.dp) // todo: get dp from stylesheet
                  )
              .padding(16.dp)) {
        AndroidView(
            factory = { context ->
              TextView(context).apply { setTextColor(fontColor.toArgb()) }
            }) { textView ->
              markwon.setMarkdown(textView, markdown)
            }
      }
}
