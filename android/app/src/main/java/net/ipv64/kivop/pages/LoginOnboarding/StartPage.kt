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

package net.ipv64.kivop.pages.LoginOnboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Tertiary

@Composable
fun StartPage(navController: NavController) {
  val pages =
      listOf<@Composable () -> Unit>(
          { DescriptionOnePage() }, { DescriptionTwoPage() }, { WelcomePage(navController) })
  var pagerState =
      rememberPagerState(
          initialPage = 0, initialPageOffsetFraction = 0F, pageCount = { pages.size })
  Box(modifier = Modifier.fillMaxSize()) {
    HorizontalPager(state = pagerState, modifier = Modifier) { page ->
      // Our page content
      pages[page]()
      Text(text = "Page: $page", modifier = Modifier.fillMaxWidth().background(Color.Red))
    }
    Row(
        Modifier.wrapContentHeight()
            .fillMaxWidth()
            .align(Alignment.BottomCenter)
            .padding(bottom = 8.dp),
        horizontalArrangement = Arrangement.Center) {
          // var scope = rememberCoroutineScope()
          repeat(pagerState.pageCount) { iteration ->
            val color = if (pagerState.currentPage == iteration) Tertiary else Secondary
            Box(
                modifier =
                    Modifier.padding(16.dp)
                        .clip(CircleShape)
                        .background(color)
                        .width(80.dp)
                        .height(18.dp)
                //            .clickable {
                //              scope.launch {
                //                pagerState.scrollToPage(iteration)
                //              }
                //            }
                )
          }
        }
  }
}
