package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.theme.Background_prime


@Composable
fun Label(
  backgroundColor: Color = Color(color = 0xff686D74),
  content: @Composable BoxScope.() -> Unit
) {
  Box(
    modifier = Modifier
      .wrapContentWidth()
      .clip(RoundedCornerShape(50))
      .background(backgroundColor)
      .padding(horizontal = 18.dp, vertical = 6.dp),
      content = content
  ) 
   
}


@Composable
fun LabelMax(
  backgroundColor: Color = Color(color = 0xff686D74),
  onClick: (() -> Unit)? = null, // Optionaler onClick-Parameter
  content: @Composable BoxScope.() -> Unit
) {
  Box(
    modifier = Modifier
      .fillMaxWidth()
      .clip(RoundedCornerShape(50))
      .background(backgroundColor)
      .padding(horizontal = 18.dp, vertical = 6.dp)
      .let { baseModifier -> // Modifier nur hinzufügen, wenn onClick vorhanden ist
        if (onClick != null) {
          baseModifier.clickable { onClick() }
        } else {
          baseModifier
        }
      },
    content = content
  )
}


@Preview(showBackground = true)
@Composable
fun LabelMaxPreview() {
  LabelMax(
  ) {
    Text(
      text = "Nach rechts ausgerichtet",
      color = Background_prime,
      style = MaterialTheme.typography.bodyMedium
    )
  }
}
