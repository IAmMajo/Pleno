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

package net.ipv64.kivop.pages.mainApp.Posters

import android.Manifest.permission.CAMERA
import android.util.Log
import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import coil3.compose.AsyncImage
import com.example.kivopandriod.components.CallToConfirmation
import com.google.android.gms.maps.model.LatLng
import java.time.LocalDateTime
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.IconBox
import net.ipv64.kivop.components.MapSingleMarker
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.components.UserCard
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionStatus
import net.ipv64.kivop.models.alertButtonStyle
import net.ipv64.kivop.models.posterButtonStyle
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.viewModel.PosterDetailedViewModel
import net.ipv64.kivop.models.viewModel.PosterDetailedViewModelFactory
import net.ipv64.kivop.models.viewModel.UserViewModel
import net.ipv64.kivop.services.checkAndRequestPermissions
import net.ipv64.kivop.services.createTempUri
import net.ipv64.kivop.services.uriToBase64String
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Primary_20
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light

@OptIn(ExperimentalEncodingApi::class)
@Composable
fun PosterDetailedPage(
    navController: NavController,
    userViewModel: UserViewModel,
    posterID: String,
    locationID: String
) {
  // popup states
  var confirmationHangPoster by remember { mutableStateOf(false) }
  var confirmationTakeOffPoster by remember { mutableStateOf(false) }
  var confirmationReportDamagePoster by remember { mutableStateOf(false) }

  // Format image string
  val posterDetailedViewModel: PosterDetailedViewModel =
      viewModel(factory = PosterDetailedViewModelFactory(posterID, locationID))

  // Converts poster image into ByteArray - for displaying in AsyncImage
  val base64ImageByteArray = remember { mutableStateOf<ByteArray?>(null) }
  LaunchedEffect(posterDetailedViewModel.posterImage) {
    Log.i("image", "image changed")
    withContext(Dispatchers.IO) {
      if (posterDetailedViewModel.posterImage != null) {
        val decodedImage =
            posterDetailedViewModel.posterImage!!.substringAfter("base64").let { Base64.decode(it) }
        base64ImageByteArray.value = decodedImage
      }
    }
  }

  // fetch profile image
  LaunchedEffect(posterDetailedViewModel.poster?.responsibleUsers) {
    posterDetailedViewModel.fetchUserImages()
  }

  // Capture image for posting poster
  val context = LocalContext.current
  var capturedImageUri = remember { createTempUri(context) }
  var base64Image by remember { mutableStateOf("") }
  var currentPosterAction by remember { mutableStateOf<PosterAction?>(null) }

  // Register for activity result to handle the camera capture
  val cameraLauncher =
      rememberLauncherForActivityResult(
          contract = ActivityResultContracts.TakePicture(),
          onResult = { success ->
            if (success) {
              capturedImageUri.let { base64Image = uriToBase64String(context, it).toString() }
            }
          })

  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  Column(modifier = Modifier.background(Primary)) {
    // header
    Column(
        modifier =
            Modifier.fillMaxWidth()
                .wrapContentHeight()
                .padding(top = 18.dp, start = 18.dp, end = 18.dp)) {
          SpacerTopBar()
          Text(text = "Plakatposition", style = TextStyles.headingStyle, color = Text_prime_light)
          SpacerBetweenElements()
          Column(
              modifier = Modifier.fillMaxWidth(),
              horizontalAlignment = Alignment.CenterHorizontally) {
                // Poster Image Box
                Box(
                    modifier =
                        Modifier.size(200.dp)
                            .customShadow()
                            .clip(shape = RoundedCornerShape(8.dp))
                            .background(Background_prime.copy(0.2f))
                    // .padding(horizontal = 40.dp)
                    ) {
                      if (!posterDetailedViewModel.isLoading) {
                        // Is loggedIn User in responsibleUsers list
                        if (posterDetailedViewModel.poster?.responsibleUsers?.any {
                          it.id == userViewModel?.getID()
                        } == true) {
                          when (posterDetailedViewModel.poster?.status) {
                            // Show button if the poster is to be hung
                            PosterPositionStatus.toHang -> {
                              Column(
                                  modifier = Modifier.fillMaxHeight(),
                                  verticalArrangement = Arrangement.Center,
                                  horizontalAlignment = Alignment.CenterHorizontally,
                              ) {
                                IconBox(
                                    icon = ImageVector.vectorResource(R.drawable.ic_image),
                                    height = 80.dp,
                                    backgroundColor = Color.Transparent,
                                    tint = Background_secondary,
                                )
                                SpacerBetweenElements(4.dp)
                                CustomButton(
                                    modifier = Modifier,
                                    text = "Plakat aufhängen",
                                    buttonStyle = posterButtonStyle,
                                    onClick = { confirmationHangPoster = true })
                              }
                            }
                            // Show image if poster is already hung
                            else -> {
                              AsyncImage(
                                  model = base64ImageByteArray.value,
                                  contentDescription = "Poster_Image",
                                  contentScale = ContentScale.Crop)
                            }
                          }
                        } else {
                          // if the user is not responsible, just show the image or placeholder
                          if (posterDetailedViewModel.posterImage != null) {
                            AsyncImage(
                                model = base64ImageByteArray.value,
                                contentDescription = "Poster_Image",
                                contentScale = ContentScale.Crop)
                          } else {
                            // if the poster has no image, show placeholder
                            Box(
                                modifier = Modifier.fillMaxSize(),
                                contentAlignment = Alignment.Center) {
                                  IconBox(
                                      icon = ImageVector.vectorResource(R.drawable.ic_image),
                                      height = 80.dp,
                                      backgroundColor = Color.Transparent,
                                      tint = Background_secondary,
                                  )
                                }
                          }
                        }
                      } else {
                        // if the poster is loading, show placeholder
                        Box(
                            modifier = Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center) {
                              IconBox(
                                  icon = ImageVector.vectorResource(R.drawable.ic_image),
                                  height = 80.dp,
                                  backgroundColor = Color.Transparent,
                                  tint = Background_secondary,
                              )
                            }
                      }
                    }
              }
          SpacerBetweenElements()
          Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
            if (posterDetailedViewModel.poster?.responsibleUsers?.any {
              it.id == userViewModel.getID()
            } == true) {
              when (posterDetailedViewModel.poster?.status) {
                // Shows button to remove poster when poster already hangs
                PosterPositionStatus.hangs -> {
                  CustomButton(
                      modifier = Modifier.width(270.dp),
                      text = "Plakat abhängen",
                      buttonStyle = primaryButtonStyle,
                      onClick = { confirmationTakeOffPoster = true })
                }
                // Shows button to remove poster when poster is overdue
                PosterPositionStatus.overdue -> {
                  Text(
                      text = "Plakat muss dringend entfert werden!",
                      style = TextStyles.subHeadingStyle,
                      color = Text_prime_light)
                  SpacerBetweenElements()
                  CustomButton(
                      modifier = Modifier.width(270.dp),
                      text = "Plakat abhängen",
                      buttonStyle = primaryButtonStyle,
                      onClick = { confirmationTakeOffPoster = true })
                }
                // Shows text that the poster has been removed
                PosterPositionStatus.takenDown -> {
                  Text(
                      text = "Plakat wurde entfernt",
                      style = TextStyles.subHeadingStyle,
                      color = Text_prime_light)
                  if (LocalDateTime.now() < posterDetailedViewModel.poster!!.expiresAt) {
                    SpacerBetweenElements(4.dp)
                    CustomButton(
                        modifier = Modifier.width(270.dp),
                        text = "Plakat neu aufhängen",
                        buttonStyle = primaryButtonStyle,
                        onClick = { confirmationHangPoster = true })
                  }
                }
                PosterPositionStatus.damaged -> {
                  Text(
                      text = "Plakat neu aufhängen!",
                      style = TextStyles.subHeadingStyle,
                      color = Text_prime_light)
                  SpacerBetweenElements()
                  CustomButton(
                      modifier = Modifier.width(270.dp),
                      text = "Plakat aufhängen",
                      buttonStyle = primaryButtonStyle,
                      onClick = { confirmationHangPoster = true })
                }
                else -> {}
              }
            }
          }
          SpacerBetweenElements()
        }
    // content
    Column(
        modifier =
            Modifier.fillMaxWidth()
                .fillMaxHeight()
                .background(
                    Background_prime, shape = RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
                .padding(top = 18.dp)
                .padding(horizontal = 18.dp)) {
          // Displays loading screen if poster is loading
          if (posterDetailedViewModel.isLoading) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
              CircularProgressIndicator(
                  modifier = Modifier.size(50.dp),
                  trackColor = Background_secondary,
                  color = Primary,
                  strokeWidth = 5.dp,
                  strokeCap = StrokeCap.Round)
            }
          }
          if (posterDetailedViewModel.posterAddress != null) {
            LazyColumn() {
              item {
                if (posterDetailedViewModel.poster != null) {
                  when {
                    posterDetailedViewModel.poster!!.status == PosterPositionStatus.hangs -> {
                      CustomButton(
                          modifier = Modifier,
                          text = "Schaden am Plakat melden",
                          buttonStyle = alertButtonStyle,
                          onClick = { confirmationReportDamagePoster = true })
                      SpacerBetweenElements()
                    }
                  }
                }
              }
              item {
                Text(text = "Standort", style = TextStyles.subHeadingStyle, color = Text_prime)
                SpacerBetweenElements()
                // Location
                Row(verticalAlignment = Alignment.CenterVertically) {
                  IconBox(
                      icon = ImageVector.vectorResource(R.drawable.ic_place),
                      backgroundColor = Tertiary.copy(0.20f),
                      tint = Tertiary,
                      height = 50.dp)
                  SpacerBetweenElements(8.dp)
                  Column {
                    Text(
                        text =
                            posterDetailedViewModel.posterAddress!!.road +
                                " " +
                                posterDetailedViewModel.posterAddress!!.houseNumber,
                        style = MaterialTheme.typography.bodyMedium,
                        color = Text_prime)
                    Text(
                        text =
                            posterDetailedViewModel.posterAddress!!.postcode +
                                " " +
                                posterDetailedViewModel.posterAddress!!.city,
                        style = MaterialTheme.typography.bodyMedium,
                        color = Text_prime.copy(0.6f))
                  }
                }
                if (posterDetailedViewModel.poster != null) {
                  SpacerBetweenElements()
                  val markerPosition =
                      LatLng(
                          posterDetailedViewModel.poster!!.latitude,
                          posterDetailedViewModel.poster!!.longitude)
                  Box(
                      modifier =
                          Modifier.fillMaxWidth()
                              .height(150.dp)
                              .clip(shape = RoundedCornerShape(8.dp))) {
                        MapSingleMarker(markerPosition)
                      }
                }
                SpacerBetweenElements()
                // Displays all responsible users for that poster
                Text(
                    text = "Verantwortliche",
                    style = TextStyles.subHeadingStyle,
                    color = Text_prime)
                for (user in posterDetailedViewModel.poster?.responsibleUsers!!) {
                  SpacerBetweenElements()
                  UserCard(
                      name = user.name,
                      image = posterDetailedViewModel.userImages[user.id],
                      backgroundColor = Primary_20)
                }
                SpacerBetweenElements()
              }
            }
          }
        }
  }
  // Permission for camera request - launches camera if granted
  val cameraPermissionLauncher =
      rememberLauncherForActivityResult(
          contract = ActivityResultContracts.RequestPermission(),
          onResult = { isGranted ->
            if (isGranted) {
              cameraLauncher.launch(capturedImageUri)
            } else {
              confirmationHangPoster = false
            }
          })
  // Launches when base64Image changes - when captured photo
  LaunchedEffect(base64Image) {
    if (base64Image.isNotEmpty()) {
      when (currentPosterAction) {
        PosterAction.HANG -> {
          posterDetailedViewModel.hangPoster(base64Image)
        }
        PosterAction.TAKE_OFF -> {
          posterDetailedViewModel.takeOffPoster(base64Image)
        }
        PosterAction.REPORT_DAMAGE -> {
          posterDetailedViewModel.reportDamage(base64Image)
        }
        else -> {}
      }
    }
  }
  when {
    confirmationHangPoster -> {
      CallToConfirmation(
          onDismissRequest = { confirmationHangPoster = false },
          onConfirmation = {
            // Checks if CAMERA permission is granted
            // runs cameraPermissionLauncher if not granted
            if (checkAndRequestPermissions(context, CAMERA, cameraPermissionLauncher)) {
              currentPosterAction = PosterAction.HANG
              cameraLauncher.launch(capturedImageUri)
              confirmationHangPoster = false
            } else {
              Toast.makeText(context, "Kamera Zugriff nicht gewährt", Toast.LENGTH_SHORT).show()
              confirmationHangPoster = false
            }
          },
          dialogTitle = "Bild erstellen",
          dialogText =
              "Zur Bestätigung wird ein Bild des aufgehangenen Plakats benötigt. \n" +
                  "Achten Sie bei der Aufnahme darauf, dass die Umgebung gut zu erkennen ist.",
          buttonOneText = "Kamera öffnen",
          buttonTextDismiss = "Abbrechen",
          alert = false,
      )
    }
    confirmationTakeOffPoster -> {
      CallToConfirmation(
          onDismissRequest = { confirmationTakeOffPoster = false },
          onConfirmation = {
            // Checks if CAMERA permission is granted
            // runs cameraPermissionLauncher if not granted
            if (checkAndRequestPermissions(context, CAMERA, cameraPermissionLauncher)) {
              currentPosterAction = PosterAction.TAKE_OFF
              cameraLauncher.launch(capturedImageUri)
              confirmationTakeOffPoster = false
            } else {
              Toast.makeText(context, "Kamera Zugriff nicht gewährt", Toast.LENGTH_SHORT).show()
              confirmationTakeOffPoster = false
            }
          },
          dialogTitle = "Bild erstellen",
          dialogText =
              "Zur Bestätigung wird ein Bild des abgehangenen Plakats benötigt. \n" +
                  "Achten Sie bei der Aufnahme darauf, dass die Umgebung gut zu erkennen ist.",
          buttonOneText = "Kamera öffnen",
          buttonTextDismiss = "Abbrechen",
          alert = false,
      )
    }
    confirmationReportDamagePoster -> {
      CallToConfirmation(
          onDismissRequest = { confirmationReportDamagePoster = false },
          onConfirmation = {
            // Checks if CAMERA permission is granted
            // runs cameraPermissionLauncher if not granted
            if (checkAndRequestPermissions(context, CAMERA, cameraPermissionLauncher)) {
              currentPosterAction = PosterAction.REPORT_DAMAGE
              cameraLauncher.launch(capturedImageUri)
              confirmationReportDamagePoster = false
            } else {
              Toast.makeText(context, "Kamera Zugriff nicht gewährt", Toast.LENGTH_SHORT).show()
              confirmationReportDamagePoster = false
            }
          },
          dialogTitle = "Bild erstellen",
          dialogText =
              "Zur Bestätigung wird ein Bild des beschädigten Plakats benötigt. \n" +
                  "Achten Sie bei der Aufnahme darauf, dass die Umgebung gut zu erkennen ist.",
          buttonOneText = "Kamera öffnen",
          buttonTextDismiss = "Abbrechen",
          alert = false,
      )
    }
  }
}

enum class PosterAction {
  HANG,
  TAKE_OFF,
  REPORT_DAMAGE
}
