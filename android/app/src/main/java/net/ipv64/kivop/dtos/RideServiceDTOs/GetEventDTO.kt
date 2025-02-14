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

package net.ipv64.kivop.dtos.RideServiceDTOs

import com.example.kivopandriod.services.stringToLocalDateTime
import java.util.UUID
import java.time.LocalDateTime

data class GetEventDTO (
    var id : UUID,
    var name : String,
    var starts : LocalDateTime,
    var ends : LocalDateTime,
    var myState : UsersEventState,
)
enum class UsersEventState {
    nothing,
    absent,
    present,
}
//TODO: REMOVE BEFORE MERGE INTO MAIN
// Mockdaten
 val eventA = GetEventDTO(
   UUID.randomUUID(),"Event #1",
   stringToLocalDateTime("2025-01-30T10:44:45Z"),
   stringToLocalDateTime("2025-01-31T10:44:45Z"),UsersEventState.nothing)

val eventB = GetEventDTO(
  UUID.randomUUID(),"Event #2",
  stringToLocalDateTime("2025-02-14T10:44:45Z"),
  stringToLocalDateTime("2025-02-28T10:44:45Z"),UsersEventState.present)

val eventC = GetEventDTO(
  UUID.randomUUID(),"Event #3",
  stringToLocalDateTime("2025-03-01T13:44:45Z"),
  stringToLocalDateTime("2025-03-08T09:44:45Z"),UsersEventState.absent)

val eventD = GetEventDTO(
  UUID.randomUUID(),"Event #4",
  stringToLocalDateTime("2025-02-02T13:20:45Z"),
  stringToLocalDateTime("2025-02-02T16:44:45Z"),UsersEventState.present)