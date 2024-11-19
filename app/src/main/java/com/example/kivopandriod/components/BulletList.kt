package com.example.kivopandriod.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.ui.theme.BulletDotGrey
import com.example.kivopandriod.ui.theme.ForestGreen
import com.example.kivopandriod.ui.theme.LightGreen



@Composable
fun BulletList(
    title: String,
    list: List<EventItem>,
    gap: Dp =16.dp
){

    Column(modifier = Modifier
        .background(
            color = LightGreen,
            shape = RoundedCornerShape(8.dp)
        )
        .padding(15.dp)
        .height(IntrinsicSize.Min),
    ) {
        Text(text = title)
        Spacer(modifier = Modifier.size(8.dp))
        Row {
            //val height = maxHeight
            //val width = maxWidth
            Column(modifier = Modifier
                .width(8.dp)
                .fillMaxHeight()
                .drawBehind {
                    line(list.size, gap.toPx())
                }){
            }
            Column(modifier = Modifier
                .fillMaxHeight()
            ) {
                Spacer(modifier = Modifier.size(gap))
                list.forEach{event ->
                    Eintrag(event = event,gap)
                }
            }
        }
    }
}

fun DrawScope.line(items: Int, gap: Float){
    val height = size.height
    val elementHeight = (height - (gap * (items.toFloat() + 1.0f))) / items
    val offsetStart = Offset(0.0f,0.0f)
    val offsetEnd = Offset(0.0f, height)

    val jump = elementHeight + gap
    val offsetCircleStart = Offset(0.0f, elementHeight/2+gap)


    drawLine(BulletDotGrey, offsetStart,offsetEnd,6.0f, StrokeCap.Round)
    for (i in 0..<items){

        drawCircle(BulletDotGrey,12.0f, Offset(offsetCircleStart.x,offsetCircleStart.y + jump*i))
    }
}


@Composable
fun Eintrag(
    event: EventItem,
    gap: Dp
){
    Row(modifier = Modifier
        .fillMaxWidth()
        .then(
            if (event.isHighlighted){
                Modifier.background(
                    color = ForestGreen,
                    shape = RoundedCornerShape(4.dp)
                )
            }else{
                Modifier
            }
        )
        .padding(4.dp)

    ) {
        Spacer(modifier = Modifier.size(4.dp))
        Text(text = "[ "+ event.date+ " ]", color = if (event.isHighlighted) Color.White else Color.Black)
        Spacer(modifier = Modifier.size(4.dp))
        Text(text = event.description, color = if (event.isHighlighted) Color.White else Color.Black)
    }
    Spacer(modifier = Modifier.size(gap))
}