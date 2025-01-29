package net.ipv64.kivop.pages.mainApp

import GenerateTabs
import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.MarkdownEditorTab
import net.ipv64.kivop.components.MarkdownPreviewTab
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.viewModel.ProtocolViewModel
import net.ipv64.kivop.models.viewModel.ProtocolViewModelFactory
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Text_prime_light


@Composable
fun ProtocolEditPage(navController: NavController, meetingId: String, protocolLang: String) {
  // ViewModel laden
  val protocolViewModel: ProtocolViewModel = viewModel(
    factory = ProtocolViewModelFactory(meetingId, protocolLang)
  )

  // BackHandler für Navigation
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }

  // Sammle den State aus dem ViewModel
  val protocol by protocolViewModel.protocol
  val editableMarkdown by protocolViewModel.editableMarkdown

  if (protocol == null) {
    // Ladeanzeige
    SpacerTopBar()
    Box(
      modifier = Modifier.fillMaxSize(),
      contentAlignment = Alignment.Center
    ) {
      CircularProgressIndicator()
    }
  } else {
    // Definiere die Tabs als "Bearbeiten" und "Vorschau"
    val tabs = listOf("Protokoll Bearbeiten", "Protokoll Vorschau")

    // Definiere die Inhalte der Tabs
    val tabContents: List<@Composable () -> Unit> = listOf(
      {
        // Editor-Tab Inhalt
        MarkdownEditorTab(
          editableMarkdown = editableMarkdown,
          onMarkdownChange = { protocolViewModel.onMarkdownChange(it) }
        )
      },
      {
        // Vorschau-Tab Inhalt mit Button
        Column(
          modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
        ) {
          // Markdown-Vorschau nimmt den verfügbaren Platz ein
          MarkdownPreviewTab(
            markdown = editableMarkdown,
            modifier = Modifier.weight(1f)
          )

          // "Speichern"-Button unten platzieren
          CustomButton(
            text = "Speichern",
            onClick = {
              protocolViewModel.saveProtocolContent()
              navController.popBackStack()
            },
            modifier = Modifier,
            color = Primary,
            fontColor = Text_prime_light
          )
        }
      }
    )

    // Haupt-UI mit Tabs und Speichern-Button
    Column(modifier = Modifier.fillMaxSize()) {
      SpacerTopBar()

      // GenerateTabs enthält die TabRow und die HorizontalPager
      GenerateTabs(tabs = tabs, tabContents = tabContents)
      
      
    }
  }
}


