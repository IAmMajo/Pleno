
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.noties.markwon.Markwon
import net.ipv64.kivop.R
import net.ipv64.kivop.components.ExpandableBox
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun AgendaCard(
    modifier: Modifier = Modifier,
    content: String = "",
    backgroundColor: Color = Background_secondary,
    fontColor: Color = Text_prime,
    name: String = "",
) {
  val context = LocalContext.current
  val markwon = Markwon.create(context)
  val maxLength = 300
  var shortenedContent = ""
  Box(
      modifier =
          modifier
              .wrapContentHeight()
              .fillMaxWidth()
              .background(
                  color = backgroundColor,
                  shape = RoundedCornerShape(8.dp) // todo: get dp from stylesheet
                  )
              .padding(16.dp)) {

    if (content.length > maxLength) {
      shortenedContent =  content.take(maxLength) + "..."
      ExpandableBox(
        contentFoldedIn = {
        Column() {
          Row(modifier = Modifier.fillMaxWidth())
          {
            Text(
              text = name,
              color = fontColor,
              style = MaterialTheme.typography.labelLarge,
              fontWeight = FontWeight.SemiBold,
              fontSize = 19.sp
            )
          }
          Spacer(modifier = Modifier.height(8.dp))
          Row(modifier = Modifier.fillMaxWidth())
          {
            Text(
              text = shortenedContent,
              color = fontColor,
              fontWeight = FontWeight.Medium,
              fontSize = 14.sp,
              lineHeight = 20.sp,
              letterSpacing = 0.25.sp
            )
          }
          Spacer(modifier = Modifier.height(6.dp))
          Row(
            modifier = Modifier.fillMaxWidth().height(25.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.End
          ) {
            Icon(
              painter = painterResource(id = R.drawable.ic_chevron_down_24),
              contentDescription = null,
              tint = Text_prime,
              modifier = Modifier.size(30.dp)
            )
          }
        }
      },
        contentFoldedOut = {
          Column() {
            Row(modifier = Modifier.fillMaxWidth())
            {
              Text(
                text = name,
                color = fontColor,
                style = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.SemiBold,
                fontSize = 19.sp
              )
            }
            Spacer(modifier = Modifier.height(8.dp))
            Row(modifier = Modifier.fillMaxWidth())
            {
              Text(
                text = content,
                color = fontColor,
                fontWeight = FontWeight.Medium,
                fontSize = 14.sp,
                lineHeight = 20.sp,
                letterSpacing = 0.25.sp
              )
            }
            Spacer(modifier = Modifier.height(6.dp))
            Row(
              modifier = Modifier.fillMaxWidth().height(25.dp),
              verticalAlignment = Alignment.CenterVertically,
              horizontalArrangement = Arrangement.End
            ) {
              Icon(
                painter = painterResource(id = R.drawable.ic_chevron_up_24),
                contentDescription = null,
                tint = Text_prime,
                modifier = Modifier.size(30.dp)
              )
            }
          }
        })
    } else {
      Column() {
        Row(modifier = Modifier.fillMaxWidth())
        {
          Text(
            text = name,
            color = fontColor,
            style = MaterialTheme.typography.labelLarge,
            fontWeight = FontWeight.SemiBold,
            fontSize = 19.sp
          )
        }
        Spacer(modifier = Modifier.height(8.dp))
        Row(modifier = Modifier.fillMaxWidth())
        {
          Text(
            text = content,
            color = fontColor,
            fontWeight = FontWeight.Medium,
            fontSize = 14.sp,
            lineHeight = 20.sp,
            letterSpacing = 0.25.sp
          )
        }
      }
    }
    
    

    
    
    
//        AndroidView(
//            factory = { context ->
//              TextView(context).apply { setTextColor(fontColor.toArgb()) }
//            }) { textView ->
//              markwon.setMarkdown(textView, markdown)
//            }
      }
}
@Preview
@Composable
fun AgendaCardPreview() {
  AgendaCard(
      name = "Test Sitzung",
      content = "## Agendaedölfm oläksdmglöksdfmgpölkdfamgffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffkläfnmdokähnfdlägmfdngfdnaghjkmafdokgnsdfajgfdangm ofkgoipndfsgp okfdoignafpdgiofd ngadfkhofadgjfdgsdfjhbojafdnjafdg+df+nhpfd igpsodfmgofdkgpadf"
  )
}