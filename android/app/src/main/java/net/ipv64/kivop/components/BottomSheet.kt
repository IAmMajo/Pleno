package net.ipv64.kivop.components

import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Text_prime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CustomBottomSheet(
    showBottomSheet: Boolean,
    onDismiss: () -> Unit,
    content: @Composable () -> Unit
) {
  val sheetState =
      rememberModalBottomSheetState(
          skipPartiallyExpanded = false, // Erlaubt Zwischenzustand
      )

  if (showBottomSheet) {
    ModalBottomSheet(
        modifier = Modifier.fillMaxHeight(),
        sheetState = sheetState,
        containerColor = Background_prime,
        contentColor = Text_prime,
        onDismissRequest = { onDismiss() }) {
          content()
        }
  }
}
