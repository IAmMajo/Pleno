package com.example.kivopandriod.components

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.background
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.R
import java.time.LocalDate
import java.time.LocalTime
import java.time.format.DateTimeFormatter

import androidx.compose.foundation.layout.Box


@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun TermindCard(
    title: String,
    date: LocalDate,
    time: LocalTime,
    status: Int,
) {
    val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
    val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")

    val colorH: Color = when (status) {
        0 -> Color(0xFFEEEFE3)
        1 -> Color(0xFFBFEFB1)
        else -> Color(0xFFFF5449).copy(alpha = 0.4f)
    }

    val (iconPainter: Painter, iconColor: Color) = when (status) {
        0 -> painterResource(id = R.drawable.ic_open) to Color(0xFF1A1C15)
        1 -> painterResource(id = R.drawable.ic_check_circle) to Color(0xFF2EA100)
        else -> painterResource(id = R.drawable.ic_cancel) to Color(0xFFFF5449)
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(12.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(colorH)
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
                        painter = iconPainter,
                        contentDescription = null,
                        tint = iconColor,
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
                    status = 1,

                )
                TermindCard(
                    title = "Vorstandswahl",
                    date = LocalDate.now(),
                    time = LocalTime.now(),
                    status = 2,

                )
                TermindCard(
                    title = "Vorstandswahl",
                    date = LocalDate.now(),
                    time = LocalTime.now(),
                    status = 0,

                )
            }
        }
    }
}

//FFBFEFB1 grün
//FFFF5449 rot-icon
//FF1A1C15 schwartz-icon
//FFEEEFE3 grau
//FFFF312B rot
//FF2EA100 grün-icon
