package net.ipv64.kivop.moduls

import java.time.LocalDate
import java.time.LocalTime

data class AttendancesListsData(
    val title: String,
    val date: LocalDate?,
    val time: LocalTime?,
    val attendanceStatus: Int? = null,
    val membersCoud: Int? = null,
    val id: String,
    val iconRend: Boolean? = true,
    val timeRend: Boolean? = true,
    val meetingStatus: String,
    val myAttendanceStatus: String? = null
)
