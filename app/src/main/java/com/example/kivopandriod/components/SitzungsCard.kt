package com.example.kivopandriod.components

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Place
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.kivopandriod.R
import com.example.kivopandriod.ui.theme.Background_secondary_light
import com.example.kivopandriod.ui.theme.Tertiary_light
import com.example.kivopandriod.ui.theme.Text_light
import java.time.LocalDate
import java.time.format.DateTimeFormatter


@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun SitzungsCard(title: String, date: LocalDate) {
    val formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")

    // Kartenlayout
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(Color(0xFFBFEFB1))
    ) {
        Column(
            modifier = Modifier
            .padding(12.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(8.dp))
            Row {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        painter = painterResource(id = R.drawable.ic_calendar),
                        contentDescription = "Icon Kalender"
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = date.format(formatter),
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.width(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        painter = painterResource(id = R.drawable.ic_schedule_24px),
                        contentDescription = "Icon Uhrzeit"
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "16:30 Uhr (90Min.)",
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Bold

                    )
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Outlined.Place,
                    contentDescription = "Icon Standort"
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "Sitzungssaal 1",
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Bold
                )
            }
            Spacer(modifier = Modifier.height(8.dp))
            ProfileCardTiny(name = "Thorsten Trauer",
                role = null,
                profileImageUrl = null, // Beispiel ohne Bild
                backgroundColor = Tertiary_light,
                backgroundColorProfile = Color.Cyan)
            Spacer(modifier = Modifier.height(4.dp))

        }
    }
}

@Composable
fun ProfileCardTiny(
    name: String,
    role: String?,
    profileImageUrl: String? = null,
    backgroundColor: Color,
    backgroundColorProfile: Color
) {
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
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(if (profileImageUrl == null) backgroundColorProfile else Color.Transparent)
            ) {
                if (profileImageUrl == null) {
                    androidx.compose.material3.Text(
                        text = initial,
                        color = Text_light,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                } else {
                    // TODO: Bild einfügen, wenn profileImageUrl nicht null ist
                }
            }
            Spacer(modifier = Modifier.width(8.dp))
            Column {
                androidx.compose.material3.Text(
                    text = name,
                    color = Text_light,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold
                )
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

@RequiresApi(Build.VERSION_CODES.O)
@Preview
@Composable
fun PreviewSitzungsCard() {
    SitzungsCard(title = "Vorstandswahl", date = LocalDate.now())
}