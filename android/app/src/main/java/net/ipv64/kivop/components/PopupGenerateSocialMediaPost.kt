package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import net.ipv64.kivop.components.ShareButton
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Signal_blue

@Composable
fun PopupGenerateSocialMediaPost(
  title: String,
  content: @Composable () -> Unit,
  contentToShare: String,
  onDismiss: () -> Unit
) {
  Dialog(onDismissRequest = onDismiss) {
    Box(
      modifier = Modifier
        .fillMaxWidth()
        .background(Background_secondary, shape = RoundedCornerShape(12.dp))
        .padding(16.dp)
    ) {
      Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
      ) {
        // Titelzeile mit Schließen-Button
        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically
        ) {
          Text(title, style = MaterialTheme.typography.headlineMedium)

          IconButton(onClick = onDismiss) {
            Icon(Icons.Default.Close, contentDescription = "Schließen")
          }
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Benutzerdefinierter Inhalt
        content()

        Spacer(modifier = Modifier.height(16.dp))

        // Share-Button als Bestätigungsbutton
        Box(
          modifier = Modifier
            .size(56.dp) 
            .clip(CircleShape) 
            .background(Signal_blue) 
            .padding(4.dp), 
          contentAlignment = Alignment.Center
        ) {
          ShareButton(contentToShare = contentToShare)
        }

      }
    }
  }
}
