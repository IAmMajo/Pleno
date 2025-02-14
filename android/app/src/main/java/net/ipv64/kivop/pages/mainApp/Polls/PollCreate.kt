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

package net.ipv64.kivop.pages.mainApp.Polls

import DateTimePicker
import android.util.Log
import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Checkbox
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.CustomInputField
import net.ipv64.kivop.components.IconBoxClickable
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.viewModel.PollCreateViewModel
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun PollCreate(navController: NavController) {
  val pollCreateViewModel: PollCreateViewModel = viewModel()
  val context = LocalContext.current
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  Column(modifier = Modifier.fillMaxSize().padding(22.dp)) {
    Column() {
      SpacerTopBar()
      Text("Frage", style = TextStyles.subHeadingStyle)
      SpacerBetweenElements(10.dp)
      CustomInputField(
          modifier = Modifier.customShadow(),
          backgroundColor = Background_secondary,
          value = pollCreateViewModel.createPoll.question,
          onValueChange = {
            pollCreateViewModel.createPoll = pollCreateViewModel.createPoll.copy(question = it)
          },
          placeholder = "Was ist die beste Pizza?")
      pollCreateViewModel.createPoll.description?.let { Text(it) }
      Row(verticalAlignment = Alignment.CenterVertically) {
        Text("Anonym", style = TextStyles.subHeadingStyle, color = Text_prime)
        Checkbox(
            checked = pollCreateViewModel.createPoll.anonymous,
            onCheckedChange = {
              pollCreateViewModel.createPoll = pollCreateViewModel.createPoll.copy(anonymous = it)
            },
        )
        Text("Mehrfachauswahl", style = TextStyles.subHeadingStyle, color = Text_prime)
        Checkbox(
            checked = pollCreateViewModel.createPoll.multiSelect,
            onCheckedChange = {
              pollCreateViewModel.createPoll = pollCreateViewModel.createPoll.copy(multiSelect = it)
            },
        )
      }
      DateTimePicker(
          context = context,
          modifier = Modifier.customShadow(),
          backgroundColor = Background_secondary,
          onDateTimeSelected = {
            pollCreateViewModel.createPoll = pollCreateViewModel.createPoll.copy(closedAt = it)
          })
      SpacerBetweenElements()
      Text("Optionen", style = TextStyles.subHeadingStyle, color = Text_prime)
      Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
        IconBoxClickable(
            ImageVector.vectorResource(id = R.drawable.ic_add),
            height = 40.dp,
            Primary,
            Text_prime_light,
            onClick = { pollCreateViewModel.addOption("") })
      }
      Box(
          modifier =
              Modifier.weight(1f) // Makes sure the list takes available space
                  .fillMaxWidth()) {
            LazyColumn {
              item { SpacerBetweenElements(10.dp) }
              items(pollCreateViewModel.createPoll.options) { option ->
                Box(contentAlignment = Alignment.CenterEnd) {
                  CustomInputField(
                      modifier = Modifier.customShadow(),
                      backgroundColor = Background_secondary,
                      value = option.text,
                      onValueChange = { pollCreateViewModel.updateOptionText(option.index, it) },
                      placeholder = "Option")
                  Row {
                    SpacerBetweenElements(7.dp)
                    IconBoxClickable(
                        ImageVector.vectorResource(id = R.drawable.ic_remove),
                        height = 52.dp,
                        Background_secondary.copy(alpha = 0.15f),
                        Text_prime,
                        onClick = { pollCreateViewModel.removeOption(option.index) })
                  }
                }
                SpacerBetweenElements(8.dp)
              }
              item { SpacerBetweenElements(15.dp) }
            }
          }
      val scope = rememberCoroutineScope()
      CustomButton(
          modifier = Modifier,
          text = "Speichern",
          buttonStyle = primaryButtonStyle,
          onClick = {
            scope.launch {
              if (pollCreateViewModel.isPollValid()) {
                if (pollCreateViewModel.createPoll()) {
                  navController.popBackStack()
                } else {
                  Toast.makeText(context, "Es ist ein Fehler aufgetreten", Toast.LENGTH_SHORT)
                      .show()
                }
              } else {
                Toast.makeText(context, "Alle Felder müssen ausgefüllt werden", Toast.LENGTH_SHORT)
                    .show()
              }
            }
          })
    }
  }
}
