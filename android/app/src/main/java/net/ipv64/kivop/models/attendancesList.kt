package net.ipv64.kivop.models

import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus

data class attendancesList(val name: String, val status: AttendanceStatus?)
