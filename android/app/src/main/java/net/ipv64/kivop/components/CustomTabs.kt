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

import androidx.compose.animation.core.animateDp
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.updateTransition
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ScrollableTabRow
import androidx.compose.material3.TabPosition
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.google.accompanist.pager.ExperimentalPagerApi
import com.google.accompanist.pager.HorizontalPager
import com.google.accompanist.pager.PagerState
import com.google.accompanist.pager.rememberPagerState
import kotlinx.coroutines.launch
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

@OptIn(ExperimentalPagerApi::class)
@Composable
fun GenerateTabs(tabs: List<String>, tabContents: List<@Composable (() -> Unit)?>) {
  val pagerState = rememberPagerState()
  val coroutineScope = rememberCoroutineScope()

  Column {
    ScrollableTabRow(
        selectedTabIndex = pagerState.currentPage,
        edgePadding = 0.dp,
        contentColor = Color.Transparent,
        containerColor = Color.Transparent,
        divider = {},
        indicator = { tabPositions -> CustomIndicator(tabPositions, pagerState) }) {
          tabs.forEachIndexed { index, title ->
            Box(
                modifier =
                    Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                        .height(40.dp) // Normale Tab-Höhe für bessere Optik
                        .wrapContentWidth() // Passt sich der Tab-Breite an
                        .background(
                            if (pagerState.currentPage == index) Color.Transparent
                            else Background_secondary,
                            shape = RoundedCornerShape(50.dp))
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null, // Entfernt das Standard-Click-Verhalten
                            onClick = {
                              coroutineScope.launch { pagerState.animateScrollToPage(index) }
                            }),
                contentAlignment = Alignment.Center) {
                  Text(
                      text = title,
                      color = if (pagerState.currentPage == index) Text_prime else Text_tertiary,
                      style = MaterialTheme.typography.labelMedium,
                      modifier =
                          Modifier.padding(
                              horizontal = 16.dp, vertical = 8.dp) // Text richtig ausrichten
                      )
                }
          }
        }

    HorizontalPager(count = tabs.size, state = pagerState, verticalAlignment = Alignment.Top) { page
      ->
      if (page < 0 || page >= tabContents.size) {
        Text(text = "Kein Inhalt in diesem Tab")
      } else {
        tabContents[page]?.invoke()
      }
    }
  }
}

@OptIn(ExperimentalPagerApi::class)
@Composable
private fun CustomIndicator(tabPositions: List<TabPosition>, pagerState: PagerState) {
  val transition = updateTransition(pagerState.currentPage)
  val indicatorStart by
      transition.animateDp(
          transitionSpec = {
            if (initialState < targetState) {
              spring(dampingRatio = 1f, stiffness = 200f)
            } else {
              spring(dampingRatio = 1f, stiffness = 500f)
            }
          },
          label = "") {
            tabPositions[it].left
          }

  val indicatorEnd by
      transition.animateDp(
          transitionSpec = {
            if (initialState < targetState) {
              spring(dampingRatio = 1f, stiffness = 500f)
            } else {
              spring(dampingRatio = 1f, stiffness = 200f)
            }
          },
          label = "") {
            tabPositions[it].right
          }

  Box(
      Modifier.offset(x = indicatorStart, y = -4.dp)
          .wrapContentSize(align = Alignment.BottomStart)
          .width(indicatorEnd - indicatorStart)
          // .padding(2.dp)
          .heightIn(45.dp)
          .background(Signal_blue.copy(0.19f), RoundedCornerShape(50))
          .zIndex(-1f))
}
