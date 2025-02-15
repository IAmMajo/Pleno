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

package net.ipv64.kivop.pages.mainApp.Carpool.onBoardingCreateRide

import android.app.Activity
import android.content.pm.PackageManager
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.models.viewModel.CreateSpecialRideViewModel
import net.ipv64.kivop.models.viewModel.MapViewModel
import net.ipv64.kivop.services.checkAndRequestPermissions

@Composable
fun CreateRidePage(navController: NavController) {
  if (ContextCompat.checkSelfPermission(
      LocalContext.current, android.Manifest.permission.ACCESS_FINE_LOCATION) ==
      PackageManager.PERMISSION_GRANTED ||
      ContextCompat.checkSelfPermission(
          LocalContext.current, android.Manifest.permission.ACCESS_COARSE_LOCATION) ==
          PackageManager.PERMISSION_GRANTED) {
    val createSpecialRideViewModel: CreateSpecialRideViewModel = viewModel()
    val mapViewModel: MapViewModel = viewModel()
    mapViewModel.fetchCurrentLocation(LocalContext.current)
    var pagerState =
        rememberPagerState(initialPage = 0, initialPageOffsetFraction = 0F, pageCount = { 5 })
    Box(modifier = Modifier.fillMaxSize()) {
      HorizontalPager(state = pagerState, modifier = Modifier, userScrollEnabled = false) { page ->
        when (page) {
          0 -> CreateRide00Page(pagerState)
          1 -> CreateRide01Page(pagerState, createSpecialRideViewModel)
          2 -> CreateRide02Page(pagerState, createSpecialRideViewModel)
          3 -> CreateRide03Page(pagerState, createSpecialRideViewModel, mapViewModel)
          4 -> CreateRide04Page(navController, pagerState, createSpecialRideViewModel)
        }
      }
    }
  } else {
    // If permissions are not granted, request them
    checkAndRequestPermissions(LocalContext.current as Activity)

    // After permission request, check if permissions are denied (go back if declined)
    if (ContextCompat.checkSelfPermission(
        LocalContext.current, android.Manifest.permission.ACCESS_FINE_LOCATION) ==
        PackageManager.PERMISSION_DENIED &&
        ContextCompat.checkSelfPermission(
            LocalContext.current, android.Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_DENIED) {
      // If permission is denied, go back to the previous screen
      navController.popBackStack()
    }
  }
}
