package net.ipv64.kivop.components

import android.content.Intent
import android.content.Context
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.vectorResource
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.theme.Background_prime

@Composable
fun ShareButton(contentToShare: String) {
  val context = LocalContext.current

  IconButton(onClick = {  shareText(context, contentToShare)}) {
    Icon(ImageVector.vectorResource(id = R.drawable.ic_share_24), contentDescription = "Teiln Button",tint = Background_prime)
  }
}

fun shareText(context: Context, text: String) {
  val sendIntent = Intent().apply {
    action = Intent.ACTION_SEND
    putExtra(Intent.EXTRA_TEXT, text)
    type = "text/plain"
  }
  val shareIntent = Intent.createChooser(sendIntent, "Teilen über")
  context.startActivity(shareIntent)
}
