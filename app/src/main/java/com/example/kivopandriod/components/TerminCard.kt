package com.example.kivopandriod.components

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TileMode
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.R
import java.time.LocalDate
import java.time.LocalTime
import java.time.format.DateTimeFormatter
@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun TermindCard(
    title: String,
    date: LocalDate,
    time: LocalTime,
    status: Int,
    color1: Color,
    color2: Color,
    color3: Color,
    icon: Int
) {
    val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
    val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")
    val brush = Brush.linearGradient(
        colors = listOf(color1, color3),
        start = Offset(0.0f, 0.0f),       // Start oben links
        end = Offset(400.0f, 700.0f) // Ende unten rechts
    )


    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(12.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(brush)
            .padding(8.dp)
    ){
            Column {
                // Titeltext
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )

                // Datum- und Zeitzeile
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        // Kalender-Icon und Datum
                        Icon(
                            painter = painterResource(id = R.drawable.ic_calendar),
                            contentDescription = null,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = date.format(dateFormatter),
                            fontWeight = FontWeight.Bold,
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Spacer(modifier = Modifier.width(8.dp))

                        // Uhr-Icon und Zeit
                        Icon(
                            painter = painterResource(id = R.drawable.ic_clock),
                            contentDescription = null,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "${time.format(timeFormatter)} Uhr",
                            fontWeight = FontWeight.Bold,
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }

                    // Rechts ausgerichtetes Icon
                    Icon(
                        painter = painterResource(id = icon),
                        contentDescription = null,
                        tint = color2,
                        modifier = Modifier.size(30.dp)
                    )
                }
            }
        }
    }


@RequiresApi(Build.VERSION_CODES.O)
@Preview(showBackground = true)
@Composable
fun TermindCardPreview() {
    MaterialTheme {
        Surface {
            Column {
                TermindCard(
                    title = "Vorstandswahl",
                    date = LocalDate.now(),
                    time = LocalTime.now(),
                    status = 0,
                    color1 = Color(0xFFEEEFE3),
                    color2 = Color(0xFF2EA100),
                    color3 = Color(0xFFBFEFB1),
                    icon = R.drawable.ic_check_circle
                )
                TermindCard(
                    title = "Vorstandswahl",
                    date = LocalDate.now(),
                    time = LocalTime.now(),
                    status = 0,
                    color1 = Color(0xFFEEEFE3),
                    color2 = Color(0xFFFF5449),
                    color3 = Color(0xFFF68E90),
                    icon = R.drawable.ic_cancel
                )
                TermindCard(
                    title = "Vorstandswahl",
                    date = LocalDate.now(),
                    time = LocalTime.now(),
                    status = 0,
                    color1 = Color(0xFFEEEFE3),
                    color2 = Color(0xFF1A1C15),
                    color3 = Color(0xFF1A1C15).copy(alpha = 0.6f),
                    icon = R.drawable.ic_open
                )
            }
        }
    }
}
//FFBFEFB1 grünn
//FFFF5449 rot-icon
//FF1A1C15 schwartz-icon
//FFEEEFE3 grau
//FFF68E90 rot
//FF2EA100 grün-icon

/*
Box(
modifier = Modifier
.fillMaxWidth()
.padding(12.dp)
.clip(RoundedCornerShape(8.dp))
.background(color = color1)
.padding(8.dp)
)



// Äußere Box als Rahmen (Border)

Box(
modifier = Modifier
.fillMaxWidth()
.padding(16.dp)
.clip(shape = RoundedCornerShape(8.dp))
.background(color = color2)
.padding(2.dp)
) {
    // Innere Box für den eigentlichen Inhalt
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFFBFEFB1), shape = RoundedCornerShape(8.dp)) // Innerer Hintergrund als Border
            .padding(12.dp)
    )
*/