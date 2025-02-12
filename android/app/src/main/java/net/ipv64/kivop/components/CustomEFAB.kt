import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.R
import net.ipv64.kivop.components.CustomBottomSheet
import net.ipv64.kivop.components.PopupGenerateSocialMediaPost

import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun CustomEFAB(
  isExpanded: Boolean, // Gemeinsamer State für FAB & Popup
  onExpandChange: (Boolean) -> Unit, // Ändert den gemeinsamen State
  expandedContent: @Composable () -> Unit
) {
  Box(modifier = Modifier.fillMaxSize()) {
    // Floating Action Button (FAB)
    ExtendedFloatingActionButton(
      onClick = { onExpandChange(true) }, // Öffnet FAB & Popup
      expanded = !isExpanded,
      text = { if (!isExpanded) Text("Generiere Post") },
      icon = { Icon(ImageVector.vectorResource(id = R.drawable.ic_edit), contentDescription = "Generiere Post") },
      modifier = Modifier
        .align(Alignment.BottomStart)
        .padding(16.dp),
      containerColor = Signal_blue,
      contentColor = Text_prime_light
    )

    // Zeigt expandedContent() (also das Popup) nur, wenn `isExpanded = true`
    if (isExpanded) {
      expandedContent()
    }
  }
}

