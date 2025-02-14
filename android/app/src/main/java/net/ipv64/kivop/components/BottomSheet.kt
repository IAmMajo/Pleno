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
