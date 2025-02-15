// MIT No Attribution
//
// Copyright 2025 KIVoP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.ipv64.kivop.R

// Standardfarben
private val attendanceCardBackgroundColor = Color(0xFFF8F8F8)
private val attendanceButtonEnabledColor = Color(0xFF00796B)
private val attendanceButtonDisabledColor = Color(0xFFBDBDBD)
private val profileTextColor = Color(0xFF000000)

@Composable
fun AttendanceCard(
    modifier: Modifier = Modifier,
    initialAttendance: Int = 0,
    maxAttendance: Int,
    onAttendanceUpdate: (currentAttendance: Int) -> Unit = {},
    buttonText: String = "Anwesenheit bestätigen",
    participantsLabel: String = "Teilnehmer",
    iconResource: Int = R.drawable.ic_groups,
    iconDescription: String = "Icon of people",
    cardBackgroundColor: Color = attendanceCardBackgroundColor,
    buttonEnabledColor: Color = attendanceButtonEnabledColor,
    buttonDisabledColor: Color = attendanceButtonDisabledColor,
    textColor: Color = profileTextColor
) {
  var currentAttendance by remember { mutableStateOf(initialAttendance) }

  Card(
      modifier = modifier.fillMaxWidth().padding(16.dp),
      colors = CardDefaults.cardColors(containerColor = cardBackgroundColor),
      shape = RoundedCornerShape(8.dp)) {
        Column(modifier = Modifier.padding(16.dp).fillMaxWidth()) {
          Button(
              onClick = {
                currentAttendance++
                onAttendanceUpdate(currentAttendance)
              },
              colors = ButtonDefaults.buttonColors(containerColor = buttonEnabledColor),
              modifier =
                  Modifier.align(Alignment.CenterHorizontally)
                      .padding(bottom = 8.dp)
                      .width(200.dp)) {
                Text(text = buttonText, color = Color.White)
              }
          Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = participantsLabel,
                fontSize = 16.sp,
                fontWeight = FontWeight.Normal,
                color = textColor)
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = "$currentAttendance/$maxAttendance",
                fontSize = 16.sp,
                fontWeight = FontWeight.Normal,
                color = textColor)
            Spacer(modifier = Modifier.width(8.dp))
            Icon(
                painter = painterResource(id = iconResource),
                contentDescription = iconDescription,
                tint = textColor,
                modifier = Modifier.size(24.dp))
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
      })
}
