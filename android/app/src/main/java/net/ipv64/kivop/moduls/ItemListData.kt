package net.ipv64.kivop.moduls

import java.time.LocalDate
import java.time.LocalTime

//todo: change id to UUID
data class ItemListData(
  val title: String,
  val date: LocalDate?,
  val time: LocalTime?,
  val attendanceStatus: Int? = null,
  val membersCount: Int? = null,
  val id: String,
  val iconRend: Boolean? = true,
  val timeRend: Boolean? = true,
  val meetingStatus: String,
  val myAttendanceStatus: String? = null
)
