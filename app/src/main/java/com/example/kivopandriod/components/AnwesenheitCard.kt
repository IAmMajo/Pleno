package com.example.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R

// Standardfarben
private val attendanceCardBackgroundColor = Color(0xFFF8F8F8)
private val buttonEnabledColor = Color(0xFF00796B)
private val buttonDisabledColor = Color(0xFFBDBDBD)
private val profileTextColor = Color(0xFF000000)

@Composable
fun AttendanceCard(
    modifier: Modifier = Modifier,
    initialAttendance: Int = 0,
    maxAttendance: Int,
    onAttendanceUpdate: (currentAttendance: Int) -> Unit = {},
    buttonText: String = "Anwesenheit bestätigen",
    participantsLabel: String = "Teilnehmer",
    iconResource: Int = R.drawable.baseline_groups_24,
    iconDescription: String = "Icon of people",
    cardBackgroundColor: Color = attendanceCardBackgroundColor,
    buttonEnabledColor: Color = buttonEnabledColor,
    buttonDisabledColor: Color = buttonDisabledColor,
    textColor: Color = profileTextColor
) {
    var currentAttendance by remember {
        mutableStateOf(initialAttendance)
    }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .padding(16.dp),
        colors = CardDefaults.cardColors(containerColor = cardBackgroundColor),
        shape = RoundedCornerShape(8.dp)
    ) {
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth()
        ) {
            Button(
                onClick = {
                    currentAttendance++
                    onAttendanceUpdate(currentAttendance)
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = buttonEnabledColor
                ),
                modifier = Modifier
                    .align(Alignment.CenterHorizontally)
                    .padding(bottom = 8.dp)
                    .width(200.dp)
            ) {
                Text(text = buttonText, color = Color.White)
            }
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = participantsLabel,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Normal,
                    color = textColor
                )
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = "$currentAttendance/$maxAttendance",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Normal,
                    color = textColor
                )
                Spacer(modifier = Modifier.width(8.dp))
                Icon(
                    painter = painterResource(id = iconResource),
                    contentDescription = iconDescription,
                    tint = textColor,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}

@Preview
@Composable
fun PreviewAttendanceCard() {
    AttendanceCard(
        initialAttendance = 5,
        maxAttendance = 20,
        onAttendanceUpdate = { newAttendance ->
            println("Current attendance updated: $newAttendance")
        }
    )
}
