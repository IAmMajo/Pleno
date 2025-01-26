package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusManager
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun IconTextField(
    text: String = "Max Musterman",
    subText: String? = null,
    textStyle: TextStyle = TextStyles.subHeadingStyle,
    icon: ImageVector = Icons.Default.Notifications,
    edit: Boolean = false,
    newText: String = "",
    onClick: () -> Unit = {},
    onValueChange: (String) -> Unit = {},
    isClickable: Boolean = true
) {
  val focusManager: FocusManager = LocalFocusManager.current
  Column(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .clip(shape = RoundedCornerShape(8.dp))
              .background(Background_secondary)
              .clickable(onClick = onClick, enabled = isClickable)
              .padding(10.dp),
  ) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
      IconBox(icon = icon, height = 50.dp, backgroundColor = Tertiary.copy(0.2f), tint = Tertiary)
      Spacer(Modifier.size(12.dp))
      if (!edit) {
        Text(text = text, color = Text_prime, style = textStyle)
      } else {
        BasicTextField(
            modifier = Modifier.fillMaxWidth().height(50.dp).focusRequester(FocusRequester()),
            textStyle = textStyle,
            singleLine = true,
            value = newText,
            onValueChange = {
              // Transform first letter to be always uppercase
              val transformedText =
                  if (it.isNotEmpty()) {
                    it.replaceFirstChar { char -> char.uppercase() }
                  } else {
                    it
                  }
              onValueChange(transformedText)
            },
            keyboardOptions = KeyboardOptions.Default.copy(imeAction = ImeAction.Done),
            // Clear Focus when done writing
            keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() }),
            decorationBox = { innerTextField ->
              Row(
                  modifier = Modifier.fillMaxWidth(),
                  verticalAlignment = Alignment.CenterVertically,
                  horizontalArrangement = Arrangement.Start) {
                    Box(modifier = Modifier.weight(1f)) {
                      if (newText.isEmpty()) {
                        Text(
                            text = text,
                            color = Text_prime.copy(0.7f),
                            style = textStyle,
                            maxLines = 1,
                            modifier = Modifier.fillMaxWidth())
                      }
                      Box(modifier = Modifier.fillMaxWidth().zIndex(2f)) { innerTextField() }
                    }
                    Icon(
                        modifier = Modifier.height(25.dp).aspectRatio(1f),
                        imageVector = Icons.Default.Edit,
                        contentDescription = null,
                        tint = Text_prime.copy(0.3f),
                    )
                  }
            })
      }
    }
    if (!subText.isNullOrEmpty()) {
      SpacerBetweenElements(6.dp)
      Text(text = subText, color = Text_prime, style = TextStyles.contentStyle)
    }
  }
}

@Preview
@Composable
fun PreviewIconTextField() {
  IconTextField(subText = "test asdas da asd ad ad ada as dasdas asdasdasd")
}
