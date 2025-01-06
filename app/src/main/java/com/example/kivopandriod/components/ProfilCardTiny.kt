package com.example.kivopandriod.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.draw.clip
import androidx.compose.ui.tooling.preview.Preview
import com.example.kivopandriod.ui.theme.Tertiary_light
import com.example.kivopandriod.ui.theme.Text_light


@Composable
fun ProfileCardSmall(
    name: String,
    role: String?,
    profileImageUrl: String? = null,
    backgroundColor: Color,
    backgroundColorProfile: Color
) {
    // Extrahiere den ersten Buchstaben des Nachnamens als Initial
    val initial = remember(name) { name.split(" ").lastOrNull()?.firstOrNull()?.toString().orEmpty() }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            // .padding(8.dp)
            .clip(RoundedCornerShape(8.dp)),
        colors = CardDefaults.cardColors(containerColor = backgroundColor)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(vertical = 4.dp)
        ) {
            // Box für das Profilbild oder Initial
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(if (profileImageUrl == null) backgroundColorProfile else Color.Transparent)
            ) {
                if (profileImageUrl == null) {
                    // Zeigt das Initial an, wenn kein Profilbild vorhanden ist
                    androidx.compose.material3.Text(
                        text = initial,
                        color = Text_light,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                } else {
                    // TODO: Hier sollte das Bild eingefügt werden, wenn profileImageUrl nicht null ist
                }
            }
            Spacer(modifier = Modifier.width(8.dp))
            // Spalte für Name und Rolle
            Column {
                androidx.compose.material3.Text(
                    text = name,
                    color = Text_light,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
                // Zeigt die Rolle an, wenn vorhanden
                role?.let {
                    androidx.compose.material3.Text(
                        text = it,
                        color = Text_light.copy(alpha = 0.65f),
                        fontSize = 12.sp
                    )
                }
            }
        }
    }
}

// Vorschau-Funktion für die ProfileCardSmall
@Preview
@Composable
fun PreviewProfileCard() {
    Box(modifier = Modifier.width(300.dp)) {
        ProfileCardSmall(
            name = "Thorsten Trauer",
            role = null,
            profileImageUrl = null, // Beispiel ohne Bild
            backgroundColor = Tertiary_light,
            backgroundColorProfile = Color.Cyan

        )
    }
}