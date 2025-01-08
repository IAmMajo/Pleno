package net.ipv64.kivop.models

import java.time.LocalDateTime
import java.util.UUID

data class PosterNeedDTO (
  var id : UUID,
  var name : String,
  var description : String?,
  var imageBase64 : String,
  var removeDate : LocalDateTime,
 
  var needHangedPosters : Int,
  var hangedPosters : Int,
  var tokenDownPosters : Int,
  var lat : Double,
  var lon : Double
)