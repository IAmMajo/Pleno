package com.example.kivopandriod.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.R
import java.time.LocalDate
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import com.example.kivopandriod.ui.theme.*
import androidx.compose.foundation.layout.Box
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.sp
import com.example.kivopandriod.moduls.AttendancesListsData


@Composable
fun ListenItem(
    attendancesListsData: AttendancesListsData,
    onClick: () -> Unit = {},
    backgroundColor: Color = Background_secondary_light
) {
    val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
    val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")
    var iconPainter: Painter = painterResource(id = R.drawable.ic_groups)
    var iconColor: Color = Text_light

    if (attendancesListsData.membersCoud == null && attendancesListsData.icon == true) {
        val (iconPainterM: Painter, iconColorM: Color) = when (attendancesListsData.attendanceStatus) {
            0 -> painterResource(id = R.drawable.ic_open) to Text_light
            1 -> painterResource(id = R.drawable.ic_check_circle) to Primary_dark
            else -> painterResource(id = R.drawable.ic_cancel) to Error_dark
        }
        iconPainter = iconPainterM
        iconColor = iconColorM

    }


    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(6.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(backgroundColor)
            .padding(8.dp)
            .clickable(onClick = onClick)
    ){
        Column {
            // Titeltext
            Text(
                text = attendancesListsData.title,
                fontWeight = FontWeight.Bold,
                fontSize = 14.sp
            )

            // Datum- und Zeitzeile
            Row(
                modifier = Modifier.fillMaxWidth().padding(top = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween

            ) {

                Row(verticalAlignment = Alignment.CenterVertically) {
                    // Kalender-Icon und Datum
                    Icon(
                        painter = painterResource(id = R.drawable.ic_calendar),
                        contentDescription = null,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "${attendancesListsData.date?.format(dateFormatter)}",
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 12.sp
                    )
                    Spacer(modifier = Modifier.width(8.dp))

                    // Uhr-Icon und Zeit
                    Icon(
                        painter = painterResource(id = R.drawable.ic_clock),
                        contentDescription = null,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "${attendancesListsData.time?.format(timeFormatter)} Uhr",
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 12.sp
                    )
                }

                if (attendancesListsData.membersCoud == null&& attendancesListsData.icon == true) {
                    Icon(
                        painter = iconPainter,
                        contentDescription = null,
                        tint = iconColor,
                    //    modifier = Modifier.size(30.dp)
                    )

                }else if (attendancesListsData.icon == true) {
                    Row() {
                        Icon(
                            painter = iconPainter,
                            contentDescription = null,
                            tint = iconColor,

                            )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            modifier = Modifier.padding(top = 4.dp),
                            text = "${attendancesListsData.membersCoud}",
                            fontWeight = FontWeight.Medium,
                            fontSize = 12.sp
                        )
                    }
                }
            }
        }
    }
}



@Preview(showBackground = true)
@Composable
fun ListsItemPreview() {
    MaterialTheme {

            Column {
                ListenItem(
                    attendancesListsData = AttendancesListsData(
                        title = "Vorstandswahl",
                        date = LocalDate.now(),
                        time = LocalTime.now(),
                        id = "test",
                        meetingStatus = "d",
                        membersCoud = 12,
                        attendanceStatus = 1
                    )
                )
                ListenItem(
                    attendancesListsData = AttendancesListsData(
                        title = "Vorstandswahl",
                        date = LocalDate.now(),
                        time = LocalTime.now(),
                        id = "test",
                        meetingStatus = "d",
                        membersCoud = 23,
                        attendanceStatus = 1
                    )
                )
                ListenItem(
                    attendancesListsData = AttendancesListsData(
                        title = "Vorstandswahl",
                        date = LocalDate.now(),
                        time = LocalTime.now(),
                        id = "test",
                        meetingStatus = "",
                       // membersCoud = null,
                        attendanceStatus = 1,
                        icon = false
                    )
                )
            }

    }
}
