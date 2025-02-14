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

package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.KeyboardArrowLeft
import androidx.compose.material.icons.outlined.Email
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.IconBoxClickable
import net.ipv64.kivop.components.IconTextField
import net.ipv64.kivop.components.ImgPicker
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.handleLogout
import net.ipv64.kivop.models.alertButtonStyle
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.viewModel.UserViewModel
import net.ipv64.kivop.services.StringProvider.getString
import net.ipv64.kivop.services.uriToBase64String
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime_light

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UserPage(navController: NavController, userViewModel: UserViewModel) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  var editMode by remember { mutableStateOf(false) }
  val user = userViewModel.getProfile()
  var newImgByteArray by remember { mutableStateOf<String?>(null) }
  val topBarModifier =
      Modifier.zIndex(1f).padding(vertical = 12.dp, horizontal = 14.dp).height(48.dp)

  TopAppBar(
      modifier = topBarModifier,
      colors =
          TopAppBarDefaults.topAppBarColors(
              containerColor = Color.Transparent), // transparente NavBar
      title = {},
      actions = {
        IconBoxClickable(
            Icons.Default.Edit,
            height = 50.dp,
            Background_secondary.copy(alpha = 0.15f),
            Background_secondary,
            onClick = { editMode = true })
      },
      navigationIcon = {
        IconBoxClickable(
            Icons.Default.KeyboardArrowLeft,
            height = 50.dp,
            Background_secondary.copy(alpha = 0.15f),
            Background_secondary,
            onClick = {
              navController.popBackStack()
              isBackPressed = true
            })
      })

  Column(modifier = Modifier.background(Primary)) {
    SpacerTopBar()
    Column(
        modifier =
            Modifier.weight(1f).fillMaxWidth().padding(top = 16.dp, start = 18.dp, end = 18.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        // verticalArrangement = Arrangement.Center,
    ) {
      if (user != null) {
        ImgPicker(
            img = user.profileImage.takeIf { !editMode },
            userName = user.name ?: "User",
            edit = editMode,
            onImagePicked = { uri ->
              newImgByteArray = uri?.let { uriToBase64String(navController.context, it) }
            })
        //        if (editMode) {
        //          ImgPicker(
        //            img = user.profileImage.takeIf { !editMode },
        //            userName = user.name ?: "User",
        //            edit = true,
        //            onImagePicked = {
        //              uri -> newImgByteArray = uri?.let { uriToBase64String(navController.context,
        // it) }
        //            } // Capture selected image
        //          )
        //        } else {
        //          if (user.profileImage != null) {
        //            ImgPicker(user.profileImage, edit = false, onImagePicked = {})
        //          } else {
        //            ImgPicker(userName = user.name, edit = false, onImagePicked = {})
        //          }
        //        }
      }
    }
    Column(
        modifier =
            Modifier.fillMaxWidth()
                .weight(2.5f)
                .background(
                    Background_prime,
                    shape =
                        RoundedCornerShape(
                            topStart = 22.dp, topEnd = 22.dp)) // todo: Rounded Corner anpassen
                .padding(top = 18.dp)
                .padding(horizontal = 18.dp)) {
          Text(
              text = getString(R.string.user_info),
              style = TextStyles.subHeadingStyle,
          )
          SpacerBetweenElements()
          var name by remember { mutableStateOf<String>("") }
          IconTextField(
              icon = Icons.Outlined.Person,
              text = user?.name ?: "",
              edit = editMode,
              newText = name,
              textStyle = TextStyles.largeContentStyle,
              onValueChange = { name = it },
              isClickable = false)
          SpacerBetweenElements()
          IconTextField(
              icon = Icons.Outlined.Email,
              text = user?.email ?: "",
              textStyle = TextStyles.largeContentStyle,
              isClickable = false)
          Spacer(modifier = Modifier.weight(1f))
          if (editMode) {
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Signal_blue, contentColor = Text_prime_light),
                onClick = {
                  editMode = false
                  name = ""
                  newImgByteArray = null
                }) {
                  Text(text = getString(R.string.btn_cancel_change_user))
                }
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Signal_blue, contentColor = Text_prime_light),
                onClick = {
                  userViewModel.updateUser(name = name, profileImage = newImgByteArray)
                  editMode = false
                  name = ""
                }) {
                  Text(text = getString(R.string.btn_save_change_user))
                }
          } else {
            CustomButton(
                modifier = Modifier.fillMaxWidth(),
                text = getString(R.string.btn_change_password),
                buttonStyle = primaryButtonStyle,
                onClick = {})
            SpacerBetweenElements(8.dp)
            CustomButton(
                modifier = Modifier.fillMaxWidth(),
                text = getString(R.string.btn_logout),
                buttonStyle = primaryButtonStyle,
                onClick = { handleLogout(navController.context) })
            SpacerBetweenElements(8.dp)
            CustomButton(
                modifier = Modifier.fillMaxWidth(),
                text = getString(R.string.btn_del_user),
                buttonStyle = alertButtonStyle,
                onClick = {})
          }
          SpacerBetweenElements()
        }
  }
}
