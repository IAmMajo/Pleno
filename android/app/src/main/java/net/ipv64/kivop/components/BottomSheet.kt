package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.ModalBottomSheetValue

import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.SheetValue
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment

import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_prime

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CustomBottomSheet(showBottomSheet: Boolean, onDismiss: () -> Unit, content: @Composable () -> Unit) {
  val sheetState = rememberModalBottomSheetState(
    skipPartiallyExpanded = false, // Erlaubt Zwischenzustand
  )

  if (showBottomSheet) {
    ModalBottomSheet(
      modifier = Modifier.fillMaxHeight(),
      sheetState = sheetState,
      containerColor = Background_prime,
      contentColor = Text_prime,
      onDismissRequest = { onDismiss() } 
    ) {
     content()
    }
  
  }
}



