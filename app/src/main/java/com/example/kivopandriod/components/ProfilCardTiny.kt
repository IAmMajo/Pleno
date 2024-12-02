package com.example.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.foundation.text.BasicText
import androidx.compose.ui.tooling.preview.Preview

// Farben anpassen (Beispiele)
private val profileCardBackgroundColor = Color(0xFFEFEFEF)
private val profilePlaceholderBackgroundColor = Color(0xFFCCCCCC)
private val profileTextColor = Color(0xFF000000)

@Composable
fun ProfileCard(name: String, role: String?, profileImageUrl: String? = null) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp)
            .background(profileCardBackgroundColor)
            .clip(RoundedCornerShape(8.dp)),
        colors = CardDefaults.cardColors(containerColor = profileCardBackgroundColor)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(8.dp)
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(if (profileImageUrl == null) profilePlaceholderBackgroundColor else Color.Transparent)
            ) {
                if (profileImageUrl == null) {
                    BasicText(
                        text = name.split(" ").last().first().toString(),
                        color = profileTextColor,
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                // TODO: Bild einfügen, wenn profileImageUrl nicht null ist
            }
            Spacer(modifier = Modifier.width(8.dp))
            Column {
                BasicText(
                    text = name,
                    color = profileTextColor,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                role?.let {
                    BasicText(
                        text = it,
                        color = profileTextColor.copy(alpha = 0.65f),
                        fontSize = 12.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}

@Preview
@Composable
fun PreviewProfileCard() {
    ProfileCard(
        name = "Thorsten Trauer",
        role = "Protokollant",
        profileImageUrl = null // Beispiel ohne Bild
    )
}