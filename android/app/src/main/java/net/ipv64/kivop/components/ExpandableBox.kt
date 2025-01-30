package net.ipv64.kivop.components

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.keyframes
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.IntSize

@Composable
fun ExpandableBox(
    contentFoldedIn: @Composable () -> Unit,
    contentFoldedOut: @Composable () -> Unit
) {

  var expanded by remember { mutableStateOf(false) }
  Surface(
    modifier = Modifier
      .fillMaxWidth()
      .clickable(
        interactionSource = remember { MutableInteractionSource() }, // Verhindert Ripple-Effekt
        indication = null, // Keine Klick-Markierung
        onClick = { expanded = !expanded }
      ),
    color = Color.Transparent
  ) {
    AnimatedContent(
        targetState = expanded,
        transitionSpec = {
          fadeIn(animationSpec = tween(150, 150)) togetherWith
              fadeOut(animationSpec = tween(150)) using
              SizeTransform { initialSize, targetSize ->
                keyframes {
                  // Expand horizontally first.
                  IntSize(targetSize.width, initialSize.height) at 800
                  durationMillis = 300
                }
              }
        },
        label = "size transform") { targetExpanded ->
          if (targetExpanded) {

            contentFoldedOut()
          } else {

            contentFoldedIn()
          }
        }
  }
}
