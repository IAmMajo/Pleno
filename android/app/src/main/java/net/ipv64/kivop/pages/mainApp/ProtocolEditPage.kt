package net.ipv64.kivop.pages.mainApp

import GenerateTabs
import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.CustomBottomSheet
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
  val protocolViewModel: ProtocolViewModel =
      viewModel(factory = ProtocolViewModelFactory(meetingId, protocolLang))

  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }

  val protocol by protocolViewModel.protocol
  val editableMarkdown by protocolViewModel.editableMarkdown
  var showBottomSheet by remember { mutableStateOf(false) }
  var kiGenerierterText by remember { mutableStateOf("") }

  if (protocol == null) {
    SpacerTopBar()
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
      CircularProgressIndicator()
    }
  } else {
    val tabs = listOf("Protokoll Bearbeiten", "Protokoll Vorschau")

    val tabContents: List<@Composable () -> Unit> =
        listOf(
            {
              Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
                Column(modifier = Modifier.weight(1f)) {
                  MarkdownEditorTab(
                      editableMarkdown = editableMarkdown,
                      onMarkdownChange = { protocolViewModel.onMarkdownChange(it) },
                      modifier = Modifier.fillMaxWidth())
                }

                CustomButton(
                    text = "ki-Assistent",
                    onClick = { showBottomSheet = true },
                    modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
                    color = Primary,
                    fontColor = Text_prime_light)

                if (showBottomSheet) {
                  CustomBottomSheet(
                      showBottomSheet,
                      onDismiss = { showBottomSheet = false },
                      content = {
                        val linesList by protocolViewModel.lines.collectAsState()

                        protocolViewModel.startExtendProtocol(
                            content = editableMarkdown, lang = protocolLang)

                        LazyColumn(modifier = Modifier.fillMaxSize().padding(16.dp)) {
                          item {
                            // Speichere alle Zeilen in kiGenerierterText
                            kiGenerierterText = linesList.joinToString("\n")

                            linesList.forEach { line -> Text(text = line) }

                            CustomButton(
                                text = "Alles Übernehmen",
                                onClick = {
                                  protocolViewModel.onMarkdownChange(kiGenerierterText)
                                  showBottomSheet = false
                                },
                                modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
                                color = Primary,
                                fontColor = Text_prime_light)
                          }
                        }
                      })
                }
              }
            },
            {
              Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
                MarkdownPreviewTab(markdown = editableMarkdown, modifier = Modifier.weight(1f))

                CustomButton(
                    text = "Speichern",
                    onClick = {
                      protocolViewModel.saveProtocolContent()
                      navController.popBackStack()
                    },
                    modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
                    color = Primary,
                    fontColor = Text_prime_light)
              }
            })

    Column(modifier = Modifier.fillMaxSize()) {
      SpacerTopBar()
      GenerateTabs(tabs = tabs, tabContents = tabContents)
    }
  }
}
